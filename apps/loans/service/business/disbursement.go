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

	"go.opentelemetry.io/otel/attribute"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

type DisbursementBusiness interface {
	Create(ctx context.Context, req *loansv1.DisbursementCreateRequest) (*loansv1.DisbursementObject, error)
	Get(ctx context.Context, id string) (*loansv1.DisbursementObject, error)
	Search(
		ctx context.Context,
		req *loansv1.DisbursementSearchRequest,
		consumer func(ctx context.Context, batch []*loansv1.DisbursementObject) error,
	) error
}

type disbursementBusiness struct {
	scope             *ReadScope
	eventsMan         fevents.Manager
	disbRepo          repository.DisbursementRepository
	loanAccountRepo   repository.LoanAccountRepository
	laBusiness        LoanAccountBusiness
	operationsCli     operationsv1connect.OperationsServiceClient
	auditWriter       *audit.Writer
	limitsCli         limitsv1connect.LimitsServiceClient
	limitsGateEnabled bool
	limitsGateMode    string
	scheduleBusiness  RepaymentScheduleBusiness
	notifier          *LoanNotifier
}

func NewDisbursementBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	disbRepo repository.DisbursementRepository,
	loanAccountRepo repository.LoanAccountRepository,
	laBusiness LoanAccountBusiness,
	operationsCli operationsv1connect.OperationsServiceClient,
	auditWriter *audit.Writer,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsGateEnabled bool,
	limitsGateMode string,
	opts ...Option,
) DisbursementBusiness {
	o := applyOptions(opts)
	return &disbursementBusiness{
		scope:             o.scope,
		scheduleBusiness:  o.scheduleBusiness,
		notifier:          o.notifier,
		eventsMan:         eventsMan,
		disbRepo:          disbRepo,
		loanAccountRepo:   loanAccountRepo,
		laBusiness:        laBusiness,
		operationsCli:     operationsCli,
		auditWriter:       auditWriter,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsGateEnabled,
		limitsGateMode:    limitsGateMode,
	}
}

func (b *disbursementBusiness) Create(
	ctx context.Context,
	req *loansv1.DisbursementCreateRequest,
) (*loansv1.DisbursementObject, error) {
	logger := util.Log(ctx).WithField("method", "DisbursementBusiness.Create")

	// The key is required whatever the limits configuration says: it is the
	// only thing standing between a retried request and a second payment.
	if req.GetIdempotencyKey() == "" {
		return nil, ErrIdempotencyKeyRequired
	}

	// A settled row answers the retry outright. A row still PROCESSING is
	// not an answer: the previous attempt did not reach a settled state and
	// this call drives the same transfer order again so it converges.
	if existing, idErr := b.disbRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey()); idErr == nil &&
		existing != nil {
		if existing.LoanAccountID != req.GetLoanAccountId() {
			return nil, ErrDuplicateIdempotencyKey
		}
		if !disbursementResumable(existing) {
			return existing.ToAPI(), nil
		}
	}

	if !b.limitsGateEnabled || b.limitsCli == nil || b.limitsGateMode == gateModeOff {
		return b.createInner(ctx, req)
	}

	// Build a LimitIntent from the loan account state.
	la, err := b.loanAccountRepo.GetByID(ctx, req.GetLoanAccountId())
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}
	intent := buildDisbursementIntent(ctx, la)

	var result *loansv1.DisbursementObject
	gateErr := limits.Gate(ctx, b.limitsCli, intent, req.GetIdempotencyKey(), limits.ParseMode(b.limitsGateMode),
		func(innerCtx context.Context, reservationID string) error {
			logger.With("limits_reservation_id", reservationID).Info("disbursement gated by limits")
			inner, innerErr := b.createInner(innerCtx, req)
			if innerErr != nil {
				return innerErr
			}
			result = inner
			return nil
		})

	var pendingErr *limits.PendingApprovalError
	if errors.As(gateErr, &pendingErr) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, gateErr)
	}
	if gateErr != nil {
		return nil, gateErr
	}
	return result, nil
}

// createInner is the pre-Gate body factored out so Gate's handler
// can wrap it. The idempotency check lives in the outer Create.
func (b *disbursementBusiness) createInner(
	ctx context.Context,
	req *loansv1.DisbursementCreateRequest,
) (*loansv1.DisbursementObject, error) {
	logger := util.Log(ctx).WithField("method", "DisbursementBusiness.Create")

	if b.operationsCli == nil {
		return nil, ErrOperationsClientUnavailable
	}

	la, err := b.loadDisbursableLoan(ctx, req.GetLoanAccountId())
	if err != nil {
		return nil, err
	}

	disb := &models.Disbursement{
		LoanAccountID:      la.GetID(),
		Amount:             la.PrincipalAmount,
		CurrencyCode:       la.CurrencyCode,
		Status:             int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_PROCESSING),
		Channel:            req.GetChannel(),
		RecipientReference: req.GetRecipientReference(),
		IdempotencyKey:     req.GetIdempotencyKey(),
	}
	disb.GenID(ctx)

	// The row is inserted before the money moves. Two unique indexes
	// serialise concurrent requests: the idempotency key (same key, same
	// row) and the single live disbursement per loan (different keys, one
	// winner). The loser never reaches the payment rail.
	stored, created, claimErr := b.disbRepo.ClaimIdempotencyKey(ctx, disb)
	if errors.Is(claimErr, repository.ErrLiveDisbursementExists) {
		logger.WithField("live_disbursement_id", stored.GetID()).
			Warn("refusing second disbursement for a loan that already has a live one")
		return nil, ErrDisbursementInFlight
	}
	if claimErr != nil {
		logger.WithError(claimErr).Error("could not claim disbursement idempotency key")
		return nil, claimErr
	}
	if !created {
		// The key belongs to whoever used it first. A different loan under
		// the same key is a client bug or a replay against the wrong loan;
		// it must never be answered with another loan's disbursement.
		if stored.LoanAccountID != la.GetID() {
			return nil, ErrDuplicateIdempotencyKey
		}
		if !disbursementResumable(stored) {
			return stored.ToAPI(), nil
		}
		// Same key, earlier attempt still processing: resume it. The
		// transfer order on the operations side is keyed on this row's
		// idempotency key, so driving it again converges on one posting.
		logger.WithField("disbursement_id", stored.GetID()).Info("resuming processing disbursement")
		disb = stored
	}

	toResp, toErr := b.executeDisbursementTransfer(ctx, req, la, disb)
	if toErr != nil {
		return nil, b.handleTransferFailure(ctx, logger, disb, toErr)
	}
	order := toResp.Msg.GetData()
	if order.GetState() != commonv1.STATE_INACTIVE {
		// The operations service only reports money as moved once the order
		// is inactive. Anything else is "not yet": keep the row processing
		// so the same key can drive the order to completion.
		err = fmt.Errorf("transfer order %s returned in state %s", order.GetId(), order.GetState())
		return nil, b.handleTransferFailure(ctx, logger, disb, err)
	}

	if err = b.completeDisbursement(ctx, logger, req, la, disb, order.GetId()); err != nil {
		return nil, err
	}

	currencyAttr := attribute.String("currency", la.CurrencyCode)
	LoansDisbursed.Add(ctx, 1, currencyAttr)
	LoansDisbursedAmount.Add(ctx,
		float64(la.PrincipalAmount)/minorUnitsPerMajor,
		currencyAttr)

	return disb.ToAPI(), nil
}

// completeDisbursement records a settled transfer order on the disbursement
// and the loan: the row is marked completed, the loan is stamped and its
// schedule re-anchored, the loan goes active, and the movement is audited.
func (b *disbursementBusiness) completeDisbursement(
	ctx context.Context,
	logger *util.LogEntry,
	req *loansv1.DisbursementCreateRequest,
	la *models.LoanAccount,
	disb *models.Disbursement,
	orderID string,
) error {
	disb.LedgerTransactionID = orderID
	disb.Status = int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_COMPLETED)
	if _, updErr := b.disbRepo.UpdateColumns(ctx, disb.GetID(), map[string]any{
		fieldStatus:      disb.Status,
		fieldLedgerTxnID: disb.LedgerTransactionID,
		"failure_reason": "",
	}); updErr != nil {
		logger.WithError(updErr).Error("could not mark disbursement completed")
		return updErr
	}

	b.recordDisbursementOnLoan(ctx, logger, la)
	b.notifier.NotifyLoanDisbursed(ctx, la, req.GetChannel())

	actor := callerSubject(ctx)
	if actor == "" {
		actor = "system"
	}
	if _, transErr := b.laBusiness.TransitionStatus(
		ctx, la.GetID(),
		loansv1.LoanStatus_LOAN_STATUS_ACTIVE,
		actor, "disbursement completed",
	); transErr != nil {
		// The money has moved and the disbursement row says so; a loan that
		// did not become active is visible to the reconciliation sweep via
		// COMPLETED disbursements on PENDING_DISBURSEMENT loans.
		logger.WithError(transErr).Error("could not transition loan to active after disbursement")
	}

	// Audit the disbursement so the money-out is visible in the audit
	// stream independently of the loan status change and the underlying
	// transfer order. Three records jointly describe the event:
	// disbursement.completed, transfer_order.executed, loan.status_changed.
	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "disbursement",
		EntityID:   disb.GetID(),
		Action:     "loan.disbursed",
		Reason:     "loan principal disbursed to recipient",
		After: data.JSONMap{
			fieldStatus:      disb.Status,
			fieldLedgerTxnID: disb.LedgerTransactionID,
		},
		Metadata: data.JSONMap{
			fieldLoanAccountID:    la.GetID(),
			fieldClientID:         la.ClientID,
			fieldAmount:           la.PrincipalAmount,
			fieldCurrency:         la.CurrencyCode,
			"channel":             req.GetChannel(),
			"recipient_reference": req.GetRecipientReference(),
			fieldIdempotencyKey:   req.GetIdempotencyKey(),
		},
		Parent: &disb.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for disbursement")
	})

	return nil
}

// loadDisbursableLoan resolves the loan account and checks everything that
// must hold before money can leave.
func (b *disbursementBusiness) loadDisbursableLoan(
	ctx context.Context,
	loanAccountID string,
) (*models.LoanAccount, error) {
	la, err := b.loanAccountRepo.GetByID(ctx, loanAccountID)
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}
	if loansv1.LoanStatus(la.Status) != loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT {
		return nil, ErrLoanNotPendingDisbursement
	}
	if la.PaymentAccountRef == "" {
		return nil, ErrLoanPaymentAccountMissing
	}
	if la.LedgerAssetAccountID == "" {
		return nil, ErrLoanLedgerAccountMissing
	}
	if !loanFundingReady(la.Properties) {
		return nil, ErrLoanFundingNotReady
	}
	return la, nil
}

// disbursementResumable reports whether a stored row is still waiting on the
// payment path, so a retry with its key should drive it rather than read it.
func disbursementResumable(d *models.Disbursement) bool {
	return d != nil && d.Status == int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_PROCESSING)
}

// handleTransferFailure decides what a failed transfer attempt means for the
// disbursement row. A rejection the payment path will never accept marks the
// row FAILED under its own key, so a retry with that key is answered with the
// failure and a fresh key may try again. Anything else is "not settled yet":
// the row stays PROCESSING with the reason recorded, and the same key resumes
// the same transfer order. The idempotency key is never rewritten: the audit
// trail keeps the caller's key, and the operations reference derived from it
// stays stable across attempts.
func (b *disbursementBusiness) handleTransferFailure(
	ctx context.Context,
	logger *util.LogEntry,
	disb *models.Disbursement,
	cause error,
) error {
	logger = logger.WithError(cause).WithField("disbursement_id", disb.GetID())
	values := map[string]any{"failure_reason": cause.Error()}

	if transferPermanentlyRejected(cause) {
		logger.Error("disbursement rejected by the payment path")
		values[fieldStatus] = int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_FAILED)
		if _, err := b.disbRepo.UpdateColumns(ctx, disb.GetID(), values); err != nil {
			logger.WithError(err).Error("could not mark disbursement failed")
		}
		return ErrDisbursementRejected
	}

	logger.Warn("disbursement not settled; the same idempotency key resumes it")
	if _, err := b.disbRepo.UpdateColumns(ctx, disb.GetID(), values); err != nil {
		logger.WithError(err).Error("could not record disbursement failure reason")
	}
	return ErrDisbursementNotSettled
}

// transferPermanentlyRejected classifies an operations error. Validation and
// precondition failures will not pass on a retry of the same order; everything
// else (unavailable, deadline, internal, in-progress) may.
func transferPermanentlyRejected(err error) bool {
	code := connect.CodeOf(err)
	return code == connect.CodeInvalidArgument ||
		code == connect.CodeFailedPrecondition ||
		code == connect.CodePermissionDenied ||
		code == connect.CodeNotFound
}

// recordDisbursementOnLoan stamps the disbursement date on the loan and
// re-anchors the repayment schedule to it. The schedule generated at account
// creation assumed the money would leave immediately; a loan disbursed days
// later would otherwise start life with an installment already overdue.
// Only the touched columns are written: the loan row may have moved on since
// it was read.
func (b *disbursementBusiness) recordDisbursementOnLoan(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
) {
	now := time.Now().UTC()
	firstRepayment := now.AddDate(
		0,
		0,
		computeFirstRepaymentDays(loansv1.RepaymentFrequency(la.RepaymentFrequency)),
	)
	la.DisbursedAt = &now
	la.FirstRepaymentDate = &firstRepayment

	values := map[string]any{
		"disbursed_at":         now,
		"first_repayment_date": firstRepayment,
	}
	if _, err := b.loanAccountRepo.UpdateColumns(ctx, la.GetID(), values); err != nil {
		logger.WithError(err).Error("could not record the disbursement date on the loan account")
	}

	if b.scheduleBusiness == nil {
		return
	}
	if _, err := b.scheduleBusiness.GenerateFor(ctx, la, la.PrincipalAmount); err != nil {
		logger.WithError(err).Error("could not re-anchor the repayment schedule to the disbursement date")
	}
}

// buildDisbursementIntent constructs a LimitIntent from the loan account.
func buildDisbursementIntent(ctx context.Context, la *models.LoanAccount) *limitsv1.LimitIntent {
	return &limitsv1.LimitIntent{
		Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		TenantId: la.OrganizationID,
		Amount:   moneyx.FromMinorUnitsByCurrency(la.CurrencyCode, la.PrincipalAmount),
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: la.ClientID},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: la.OrganizationID},
		},
		MakerId: callerSubject(ctx),
	}
}

// callerSubject reads the profile ID from frame security claims;
// returns "" if no claims (system-initiated jobs).
func callerSubject(ctx context.Context) string {
	if claims := security.ClaimsFromContext(ctx); claims != nil {
		return claims.GetProfileID()
	}
	return ""
}

func (b *disbursementBusiness) executeDisbursementTransfer(
	ctx context.Context,
	req *loansv1.DisbursementCreateRequest,
	la *models.LoanAccount,
	disb *models.Disbursement,
) (*connect.Response[operationsv1.TransferOrderExecuteResponse], error) {
	loanRequestID := loanRequestIDFromProperties(la.Properties, la.LoanRequestID)

	return b.operationsCli.TransferOrderExecute(ctx, connect.NewRequest(
		&operationsv1.TransferOrderExecuteRequest{
			Data: &operationsv1.TransferOrderObject{
				DebitAccountRef:  la.LedgerAssetAccountID,
				CreditAccountRef: la.PaymentAccountRef,
				Amount:           moneyx.FromMinorUnitsByCurrency(la.CurrencyCode, la.PrincipalAmount),
				OrderType:        constants.SafeInt32FromInt(constants.TransferTypeDisbursement),
				Reference:        "disbursement:" + disb.IdempotencyKey,
				Description:      "Loan disbursement for " + la.GetID(),
				State:            commonv1.STATE_ACTIVE,
				ExtraData: (&data.JSONMap{
					"loan_id":             la.GetID(),
					fieldLoanRequestID:    loanRequestID,
					"recipient_id":        la.ClientID,
					fieldClientID:         la.ClientID,
					"payment_channel":     req.GetChannel(),
					"payment_account_ref": la.PaymentAccountRef,
				}).ToProtoStruct(),
			},
		},
	))
}

func loanFundingReady(properties data.JSONMap) bool {
	if properties == nil {
		return false
	}
	value, ok := properties["funding_fully_funded"].(bool)
	return ok && value
}

func loanRequestIDFromProperties(properties data.JSONMap, fallback string) string {
	if properties != nil {
		if loanRequestID, ok := properties["loan_request_id"].(string); ok && loanRequestID != "" {
			return loanRequestID
		}
	}
	return fallback
}

func (b *disbursementBusiness) Get(ctx context.Context, id string) (*loansv1.DisbursementObject, error) {
	disb, err := b.disbRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrDisbursementNotFound
	}
	if scopeErr := authorizeLoanAccount(ctx, b.scope, b.loanAccountRepo, disb.LoanAccountID); scopeErr != nil {
		return nil, scopeErr
	}
	return disb.ToAPI(), nil
}

func (b *disbursementBusiness) Search(
	ctx context.Context,
	req *loansv1.DisbursementSearchRequest,
	consumer func(ctx context.Context, batch []*loansv1.DisbursementObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "DisbursementBusiness.Search")

	if scopeErr := authorizeLoanAccount(ctx, b.scope, b.loanAccountRepo, req.GetLoanAccountId()); scopeErr != nil {
		return scopeErr
	}

	andQueryVal := map[string]any{}
	if req.GetLoanAccountId() != "" {
		andQueryVal["loan_account_id = ?"] = req.GetLoanAccountId()
	}
	if req.GetStatus() != loansv1.DisbursementStatus_DISBURSEMENT_STATUS_UNSPECIFIED {
		andQueryVal["status = ?"] = int32(req.GetStatus())
	}

	return executeSearch(
		ctx,
		logger,
		b.disbRepo.Search,
		req.GetCursor(),
		andQueryVal,
		"failed to search disbursements",
		func(d *models.Disbursement) *loansv1.DisbursementObject {
			return d.ToAPI()
		},
		consumer,
	)
}
