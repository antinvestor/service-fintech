// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package business

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/seed/service/events"
	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/apps/seed/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// KYCStatus is the verdict the KYCVerifier returns for a client.
type KYCStatus int32

const (
	// KYCStatusUnknown means the verifier could not determine a status.
	KYCStatusUnknown KYCStatus = 0
	// KYCStatusVerified means the client has the documents seed requires.
	KYCStatusVerified KYCStatus = 1
	// KYCStatusPending means verification is in progress. Borrowing is
	// not allowed but the profile can still be provisioned.
	KYCStatusPending KYCStatus = 2
	// KYCStatusFailed means verification was attempted and rejected.
	KYCStatusFailed KYCStatus = 3
)

// KYCVerifier is the abstraction seed uses to decide whether a client
// has the necessary verified documents to borrow. A production
// deployment plugs in an implementation that calls the identity
// service's ClientData* RPCs and enforces the seed-product's specific
// KYC checklist; tests plug in a fake that returns a canned verdict.
type KYCVerifier interface {
	VerifyClient(ctx context.Context, clientID string) (KYCStatus, error)
}

// LoanCreator is the subset of the loan management surface seed needs
// to actually create a loan account and trigger disbursement. Wrapping
// this in an interface (rather than taking a loansv1connect client
// directly) lets the seed package stay decoupled from the exact proto
// surface and makes it trivial to test.
type LoanCreator interface {
	// CreateApplication creates a loan request in the loans service
	// and returns the loan request id.
	CreateApplication(
		ctx context.Context,
		req LoanCreationRequest,
	) (applicationID string, err error)

	// CreateLoanAccount turns an accepted application into a loan
	// account ready for disbursement. Returns the loan account id.
	CreateLoanAccount(
		ctx context.Context,
		applicationID string,
	) (loanAccountID string, err error)

	// Disburse triggers the disbursement pipeline for an existing
	// loan account. Returns the disbursement id.
	Disburse(
		ctx context.Context,
		loanAccountID string,
		idempotencyKey string,
	) (disbursementID string, err error)
}

// LoanCreationRequest is the payload passed to LoanCreator. Kept as a
// seed-local struct so the business layer is not coupled to a specific
// upstream proto shape.
type LoanCreationRequest struct {
	ClientID       string
	ProductID      string
	Amount         int64 // minor units
	CurrencyCode   string
	Purpose        string
	InterestRateBP int64 // basis points
	TermDays       int32
	IdempotencyKey string
}

// ErrClientNotKYCVerified is returned when a loan request cannot proceed
// because the KYC verifier reports the client is not verified.
var ErrClientNotKYCVerified = errors.New("seed: client is not KYC verified")

// ErrAmountExceedsLimit is returned when a loan request asks for more
// than the client's current MaxLoanAmount.
var ErrAmountExceedsLimit = errors.New("seed: requested amount exceeds credit limit")

// ErrLoanAlreadyOutstanding is returned when a client with an active
// unrepaid loan tries to open a second one. Seed enforces "one active
// loan per client per currency" by default; an operator can relax this
// per profile via properties.
var ErrLoanAlreadyOutstanding = errors.New("seed: client already has an outstanding loan")

// LoanRequestBusiness is the customer-facing entry point into the
// seed product. RequestLoan is the happy-path flow; HandlePaidOff is
// the lifecycle hook called when a loan reaches PAID_OFF so the
// client's credit profile can be updated.
type LoanRequestBusiness interface {
	RequestLoan(
		ctx context.Context,
		req RequestLoanInput,
	) (*models.LoanRequest, error)

	HandlePaidOff(
		ctx context.Context,
		loanAccountID string,
		totalRepaid int64,
	) error

	Get(ctx context.Context, id string) (*models.LoanRequest, error)
}

// RequestLoanInput is the customer-supplied input for RequestLoan.
type RequestLoanInput struct {
	ClientID       string
	ProductID      string
	Amount         int64 // minor units
	CurrencyCode   string
	Purpose        string
	IdempotencyKey string
	ActorID        string
	ActorType      string
}

type loanRequestBusiness struct {
	cpBusiness  CreditProfileBusiness
	cpRepo      repository.CreditProfileRepository
	lrRepo      repository.LoanRequestRepository
	tierRepo    repository.CreditTierRepository
	kycVerifier KYCVerifier
	loanCreator LoanCreator
	eventsMan   fevents.Manager
	auditWriter *audit.Writer
}

// NewLoanRequestBusiness builds the business bound to its dependencies.
// The KYC verifier and loan creator are interfaces so a future PR can
// swap in a real implementation backed by the identity and loans
// services without touching this package.
func NewLoanRequestBusiness(
	_ context.Context,
	cpBusiness CreditProfileBusiness,
	cpRepo repository.CreditProfileRepository,
	lrRepo repository.LoanRequestRepository,
	tierRepo repository.CreditTierRepository,
	kycVerifier KYCVerifier,
	loanCreator LoanCreator,
	eventsMan fevents.Manager,
	auditWriter *audit.Writer,
) LoanRequestBusiness {
	return &loanRequestBusiness{
		cpBusiness:  cpBusiness,
		cpRepo:      cpRepo,
		lrRepo:      lrRepo,
		tierRepo:    tierRepo,
		kycVerifier: kycVerifier,
		loanCreator: loanCreator,
		eventsMan:   eventsMan,
		auditWriter: auditWriter,
	}
}

// RequestLoan is the complete customer-initiated loan pipeline. The
// stages are:
//
//  1. Idempotency  — a non-empty key that already maps to a row short-
//     circuits to that row so retries are safe.
//  2. KYC check    — the verifier reports verified/pending/failed.
//  3. Profile      — seed ensures a credit profile exists for the
//     client, provisioned to tier-1 with the product's policy.
//  4. Eligibility  — the amount must be within the profile's current
//     MaxLoanAmount, the profile must be active, and the client must
//     not have an outstanding seed loan.
//  5. Submit       — seed persists the loan request and emits an
//     audit event.
//  6. Suspense     — the client's suspense account ref is ensured so
//     every downstream money movement can flow through client suspense.
//  7. Application  — seed calls LoanCreator.CreateApplication.
//  8. Loan account — seed calls LoanCreator.CreateLoanAccount.
//  9. Disburse     — seed calls LoanCreator.Disburse.
//
// 10. Counters     — seed marks the profile borrowed (outstanding+1).
// 11. Audit finish — seed records a final loan.disbursed audit event.
//
// Any step after (5) that fails leaves the LoanRequest row in its
// intermediate state with an informative status and reason, and
// returns the error to the caller so retries can resume from the
// last-good point.
func (b *loanRequestBusiness) RequestLoan( //nolint:gocognit,funlen // multi-step loan origination pipeline
	ctx context.Context,
	req RequestLoanInput,
) (*models.LoanRequest, error) {
	logger := util.Log(ctx).WithField("method", "LoanRequestBusiness.RequestLoan").
		WithField("client_id", req.ClientID)

	if err := validateRequestInput(req); err != nil {
		return nil, err
	}

	// Idempotency first: a retry with the same key must not create a
	// second loan request. If the prior row exists we return it as-is
	// regardless of what state it's in, matching the rest of the
	// platform's "retries converge on a single record" convention.
	if req.IdempotencyKey != "" {
		existing, err := b.lrRepo.GetByIdempotencyKey(ctx, req.IdempotencyKey)
		if err == nil && existing != nil {
			return existing, nil
		}
		if err != nil && !errors.Is(err, repository.ErrLoanRequestNotFound) {
			return nil, fmt.Errorf("idempotency lookup: %w", err)
		}
	}

	// KYC check.
	kycStatus, kycErr := b.kycVerifier.VerifyClient(ctx, req.ClientID)
	if kycErr != nil {
		return nil, fmt.Errorf("kyc verification: %w", kycErr)
	}
	if kycStatus != KYCStatusVerified {
		return b.persistEligibilityFailure(
			ctx, req, ErrClientNotKYCVerified,
			fmt.Sprintf("kyc status %d; borrowing refused", kycStatus),
		)
	}

	// Credit profile.
	profile, err := b.cpBusiness.EnsureProfile(ctx, req.ClientID, req.CurrencyCode, req.ProductID)
	if err != nil {
		return nil, fmt.Errorf("ensure credit profile: %w", err)
	}

	if models.CreditProfileStatus(profile.Status) != models.CreditProfileStatusActive {
		return b.persistEligibilityFailure(ctx, req, ErrProfileSuspended,
			fmt.Sprintf("profile status is %d", profile.Status))
	}

	if profile.OutstandingLoanCount > 0 {
		return b.persistEligibilityFailure(ctx, req, ErrLoanAlreadyOutstanding,
			"client already has an outstanding seed loan")
	}

	if profile.MaxLoanAmount > 0 && req.Amount > profile.MaxLoanAmount {
		return b.persistEligibilityFailure(ctx, req, ErrAmountExceedsLimit,
			fmt.Sprintf("requested %d exceeds tier %d limit %d",
				req.Amount, profile.Tier, profile.MaxLoanAmount))
	}

	tier, tierErr := b.cpBusiness.EvaluateTier(ctx, profile)
	if tierErr != nil {
		return nil, fmt.Errorf("evaluate tier: %w", tierErr)
	}

	// Persist the submitted loan request so downstream steps have a
	// persistent anchor to link their records back to.
	now := time.Now().UTC()
	lr := &models.LoanRequest{
		ClientID:               req.ClientID,
		CreditProfileID:        profile.GetID(),
		ProductID:              req.ProductID,
		Amount:                 req.Amount,
		CurrencyCode:           req.CurrencyCode,
		Purpose:                req.Purpose,
		Status:                 int32(models.LoanRequestStatusSubmitted),
		TierAtApproval:         tier.Tier,
		InterestRateAtApproval: tier.InterestRate,
		TermDaysAtApproval:     tier.TermDays,
		IdempotencyKey:         req.IdempotencyKey,
		RequestedAt:            &now,
	}
	lr.GenID(ctx)
	lr.CopyPartitionInfo(&profile.BaseModel)

	if emitErr := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); emitErr != nil {
		return nil, fmt.Errorf("persist loan request: %w", emitErr)
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityLoanRequest,
		EntityID:   lr.GetID(),
		Action:     "seed.loan_request.submitted",
		ActorID:    req.ActorID,
		ActorType:  req.ActorType,
		Reason:     req.Purpose,
		After: data.JSONMap{
			fieldStatus:         lr.Status,
			fieldAmount:         lr.Amount,
			"tier_at_approval":  lr.TierAtApproval,
			"interest_rate_bps": lr.InterestRateAtApproval,
			"term_days":         lr.TermDaysAtApproval,
		},
		Metadata: data.JSONMap{
			fieldClientID:     lr.ClientID,
			fieldProductID:    lr.ProductID,
			fieldCurrencyCode: lr.CurrencyCode,
		},
		Parent: &lr.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for loan request submission")
	})

	// Ensure the client suspense account ref exists before downstream
	// money movement flows through it. The operations service is the
	// authority on AccountRef records; this call is a best-effort
	// idempotent provisioning.
	if err = b.ensureClientSuspense(ctx, logger, req.ClientID, req.CurrencyCode, lr); err != nil {
		return nil, b.persistRequestFailure(ctx, lr, err, "ensure client suspense account")
	}

	// Downstream application.
	appID, appErr := b.loanCreator.CreateApplication(ctx, LoanCreationRequest{
		ClientID:       req.ClientID,
		ProductID:      req.ProductID,
		Amount:         req.Amount,
		CurrencyCode:   req.CurrencyCode,
		Purpose:        req.Purpose,
		InterestRateBP: tier.InterestRate,
		TermDays:       tier.TermDays,
		IdempotencyKey: "seed:" + lr.GetID(),
	})
	if appErr != nil {
		return nil, b.persistRequestFailure(ctx, lr, appErr, "create application")
	}
	lr.ApplicationID = appID

	// Loan account.
	loanAccountID, laErr := b.loanCreator.CreateLoanAccount(ctx, appID)
	if laErr != nil {
		return nil, b.persistRequestFailure(ctx, lr, laErr, "create loan account")
	}
	lr.LoanAccountID = loanAccountID
	lr.Status = int32(models.LoanRequestStatusApproved)
	lr.ApprovedAt = &now
	if emitErr := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); emitErr != nil {
		logger.WithError(emitErr).Warn("could not persist loan request after approval")
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityLoanRequest,
		EntityID:   lr.GetID(),
		Action:     "seed.loan_request.approved",
		Reason:     "downstream application and loan account created",
		After: data.JSONMap{
			fieldStatus:        lr.Status,
			"application_id":   lr.ApplicationID,
			fieldLoanAccountID: lr.LoanAccountID,
		},
		Parent: &lr.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for loan request approval")
	})

	// Disburse.
	disbID, disbErr := b.loanCreator.Disburse(ctx, loanAccountID, "seed:"+lr.GetID())
	if disbErr != nil {
		return nil, b.persistRequestFailure(ctx, lr, disbErr, "disburse loan")
	}
	lr.DisbursementID = disbID
	lr.Status = int32(models.LoanRequestStatusDisbursed)
	disbursedAt := time.Now().UTC()
	lr.DisbursedAt = &disbursedAt

	// Mark the profile borrowed (outstanding+1, lifetime totals). Any
	// concurrent paid-off hook against a previous loan for the same
	// client still serialises cleanly via the SQL arithmetic.
	if _, borrowErr := b.cpRepo.AtomicMarkBorrowed(ctx, profile.GetID(), req.Amount); borrowErr != nil {
		logger.WithError(borrowErr).
			Error("could not mark profile borrowed after disbursement")
		// Don't fail the request: the money has moved. Audit captures
		// the drift so operators can reconcile.
	}

	if emitErr := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); emitErr != nil {
		logger.WithError(emitErr).Warn("could not persist loan request after disbursement")
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityLoanRequest,
		EntityID:   lr.GetID(),
		Action:     "seed.loan_request.disbursed",
		Reason:     "loan principal disbursed to client",
		After: data.JSONMap{
			fieldStatus:       lr.Status,
			"disbursement_id": lr.DisbursementID,
			"disbursed_at":    disbursedAt.Format(time.RFC3339),
		},
		Metadata: data.JSONMap{
			fieldLoanAccountID: lr.LoanAccountID,
			fieldAmount:        lr.Amount,
			fieldCurrencyCode:  lr.CurrencyCode,
		},
		Parent: &lr.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for loan request disbursement")
	})

	return lr, nil
}

// HandlePaidOff is the lifecycle hook called when a loan account
// reaches PAID_OFF. The loans service invokes this path with the
// loan account id; seed resolves it to the originating LoanRequest,
// marks it completed, and updates the client's credit profile so the
// successful repayment counter and potential tier promotion land in
// one descriptive, audited operation.
//
// Idempotency is handled by checking CompletedAt on the loan request
// before doing anything: a second paid-off event for the same loan
// is a no-op.
func (b *loanRequestBusiness) HandlePaidOff(
	ctx context.Context,
	loanAccountID string,
	totalRepaid int64,
) error {
	logger := util.Log(ctx).WithField("method", "LoanRequestBusiness.HandlePaidOff").
		WithField("loan_account_id", loanAccountID)

	lr, err := b.lrRepo.GetByLoanAccountID(ctx, loanAccountID)
	if err != nil {
		if errors.Is(err, repository.ErrLoanRequestNotFound) {
			// Not a seed loan: nothing to do.
			return nil
		}
		return fmt.Errorf("lookup loan request: %w", err)
	}
	if lr.CompletedAt != nil {
		return nil
	}

	now := time.Now().UTC()
	lr.CompletedAt = &now
	if emitErr := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); emitErr != nil {
		logger.WithError(emitErr).Warn("could not mark loan request completed")
	}

	if _, err = b.cpBusiness.RecordSuccessfulRepayment(
		ctx, lr.ClientID, lr.CurrencyCode, totalRepaid,
		fmt.Sprintf("loan %s paid off", loanAccountID),
	); err != nil {
		return fmt.Errorf("record successful repayment: %w", err)
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityLoanRequest,
		EntityID:   lr.GetID(),
		Action:     "seed.loan_request.completed",
		Reason:     "loan paid off",
		After: data.JSONMap{
			"completed_at": now.Format(time.RFC3339),
		},
		Metadata: data.JSONMap{
			fieldLoanAccountID: loanAccountID,
			"total_repaid":     totalRepaid,
			fieldClientID:      lr.ClientID,
		},
		Parent: &lr.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for loan request completion")
	})

	return nil
}

func (b *loanRequestBusiness) Get(ctx context.Context, id string) (*models.LoanRequest, error) {
	return b.lrRepo.GetByID(ctx, id)
}

// ensureClientSuspense records the convention that the client's
// inbound-payment landing zone is client:{id}:suspense. The actual
// AccountRef row in the operations service is provisioned lazily by
// the operations resolve-account-ref path (it falls back to treating
// the composite name as a synthetic ledger id the first time it sees
// one), so this function's job is to declare the intent in the audit
// stream. A follow-up PR that adds an AccountRefEnsure RPC on
// operations can wire it in here without changing call sites.
func (b *loanRequestBusiness) ensureClientSuspense(
	ctx context.Context,
	logger *util.LogEntry,
	clientID, currencyCode string,
	lr *models.LoanRequest,
) error { //nolint:unparam // error return reserved for future AccountRefEnsure RPC
	accountName := constants.ClientSuspenseAccount(clientID)

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityLoanRequest,
		EntityID:   lr.GetID(),
		Action:     "seed.client_suspense.declared",
		Reason:     "client suspense account convention applied",
		Metadata: data.JSONMap{
			fieldClientID:  clientID,
			"account_name": accountName,
			"currency":     currencyCode,
		},
		Parent: &lr.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for client suspense declaration")
	})
	return nil
}

// persistEligibilityFailure persists a loan request row in the
// EligibilityFailed state so the failure is auditable, even though the
// downstream pipeline never ran.
func (b *loanRequestBusiness) persistEligibilityFailure(
	ctx context.Context,
	req RequestLoanInput,
	cause error,
	detail string,
) (*models.LoanRequest, error) {
	now := time.Now().UTC()
	lr := &models.LoanRequest{
		ClientID:       req.ClientID,
		ProductID:      req.ProductID,
		Amount:         req.Amount,
		CurrencyCode:   req.CurrencyCode,
		Purpose:        req.Purpose,
		Status:         int32(models.LoanRequestStatusEligibilityFailed),
		DeniedReason:   detail,
		IdempotencyKey: req.IdempotencyKey,
		RequestedAt:    &now,
	}
	lr.GenID(ctx)
	if emitErr := b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr); emitErr != nil {
		// Best-effort: we still return the eligibility failure to the
		// caller, using the audit log as the authoritative record.
		util.Log(ctx).WithError(emitErr).Warn("could not persist eligibility failure loan request")
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityLoanRequest,
		EntityID:   lr.GetID(),
		Action:     "seed.loan_request.eligibility_failed",
		ActorID:    req.ActorID,
		ActorType:  req.ActorType,
		Reason:     detail,
		After:      data.JSONMap{fieldStatus: lr.Status},
		Metadata: data.JSONMap{
			fieldClientID:     req.ClientID,
			fieldAmount:       req.Amount,
			fieldCurrencyCode: req.CurrencyCode,
			fieldProductID:    req.ProductID,
			"error":           cause.Error(),
		},
		Parent: &lr.BaseModel,
	}, func(auErr error) {
		util.Log(ctx).WithError(auErr).Warn("audit emission failed for eligibility failure")
	})

	return lr, cause
}

// persistRequestFailure marks a previously-submitted loan request as
// Failed after the eligibility step passed but a downstream step
// errored. The row is preserved for retry and the audit stream
// captures where the failure happened.
func (b *loanRequestBusiness) persistRequestFailure(
	ctx context.Context,
	lr *models.LoanRequest,
	cause error,
	stage string,
) error {
	lr.Status = int32(models.LoanRequestStatusFailed)
	lr.DeniedReason = fmt.Sprintf("%s: %s", stage, cause.Error())
	_ = b.eventsMan.Emit(ctx, events.LoanRequestSaveEvent, lr)

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityLoanRequest,
		EntityID:   lr.GetID(),
		Action:     "seed.loan_request.failed",
		Reason:     lr.DeniedReason,
		After:      data.JSONMap{fieldStatus: lr.Status},
		Metadata: data.JSONMap{
			"stage":            stage,
			"error":            cause.Error(),
			"application_id":   lr.ApplicationID,
			fieldLoanAccountID: lr.LoanAccountID,
		},
		Parent: &lr.BaseModel,
	}, func(auErr error) {
		util.Log(ctx).WithError(auErr).Warn("audit emission failed for loan request failure")
	})

	return fmt.Errorf("%s: %w", stage, cause)
}

// validateRequestInput performs cheap structural validation on the
// incoming RequestLoanInput. Business rules (KYC, limit, status) are
// enforced later in the pipeline; these checks catch missing required
// fields before we commit any state.
func validateRequestInput(req RequestLoanInput) error {
	if req.ClientID == "" {
		return errors.New("client id is required")
	}
	if req.ProductID == "" {
		return errors.New("product id is required")
	}
	if req.CurrencyCode == "" {
		return errors.New("currency code is required")
	}
	if req.Amount <= 0 {
		return errors.New("amount must be positive")
	}
	return nil
}
