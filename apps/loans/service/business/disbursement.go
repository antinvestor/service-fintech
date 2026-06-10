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
	"go.opentelemetry.io/otel/metric"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
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
	eventsMan         fevents.Manager
	disbRepo          repository.DisbursementRepository
	loanAccountRepo   repository.LoanAccountRepository
	laBusiness        LoanAccountBusiness
	operationsCli     operationsv1connect.OperationsServiceClient
	auditWriter       *audit.Writer
	limitsCli         limitsv1connect.LimitsServiceClient
	limitsGateEnabled bool
	limitsGateMode    string
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
) DisbursementBusiness {
	return &disbursementBusiness{
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

	// Idempotency short-circuit (local).
	if req.GetIdempotencyKey() != "" {
		existing, idErr := b.disbRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey())
		if idErr == nil && existing != nil {
			return existing.ToAPI(), nil
		}
	}

	if req.GetIdempotencyKey() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("idempotency_key required for loan disbursement"))
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
		return nil, fmt.Errorf("disbursement requires approval (reservation %s): %w",
			pendingErr.ReservationID, gateErr)
	}
	if gateErr != nil {
		return nil, gateErr
	}
	return result, nil
}

// createInner is the pre-Gate body factored out so Gate's handler
// can wrap it. The idempotency check lives in the outer Create.
func (b *disbursementBusiness) createInner( //nolint:funlen // sequential disbursement pipeline
	ctx context.Context,
	req *loansv1.DisbursementCreateRequest,
) (*loansv1.DisbursementObject, error) {
	logger := util.Log(ctx).WithField("method", "DisbursementBusiness.Create")

	loanAccountID := req.GetLoanAccountId()

	// Verify loan is in PENDING_DISBURSEMENT state
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

	// Create the disbursement record
	now := time.Now().UTC()
	disb := &models.Disbursement{
		LoanAccountID:      loanAccountID,
		Amount:             la.PrincipalAmount,
		CurrencyCode:       la.CurrencyCode,
		Status:             int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_PROCESSING),
		Channel:            req.GetChannel(),
		RecipientReference: req.GetRecipientReference(),
		IdempotencyKey:     req.GetIdempotencyKey(),
	}
	disb.GenID(ctx)

	if err = b.eventsMan.Emit(ctx, events.DisbursementSaveEvent, disb); err != nil {
		logger.WithError(err).Error("could not emit disbursement save event")
		return nil, err
	}

	// Execute the disbursement transfer order via operations service
	if b.operationsCli == nil {
		return nil, errors.New("operations client is not configured; cannot execute disbursement")
	}
	toResp, toErr := b.executeDisbursementTransfer(ctx, req, la, disb)
	if toErr != nil {
		logger.WithError(toErr).Error("transfer order execution failed")
		disb.Status = int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_FAILED)
		disb.FailureReason = toErr.Error()
		_ = b.eventsMan.Emit(ctx, events.DisbursementSaveEvent, disb)
		return disb.ToAPI(), nil
	}
	disb.LedgerTransactionID = toResp.Msg.GetData().GetId()

	// Mark disbursement as completed
	disb.Status = int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_COMPLETED)
	if err = b.eventsMan.Emit(ctx, events.DisbursementSaveEvent, disb); err != nil {
		logger.WithError(err).Error("could not update disbursement status")
	}

	la.DisbursedAt = &now
	if la.FirstRepaymentDate == nil {
		firstRepayment := now.AddDate(
			0,
			0,
			computeFirstRepaymentDays(loansv1.RepaymentFrequency(la.RepaymentFrequency)),
		)
		la.FirstRepaymentDate = &firstRepayment
	}
	if saveErr := b.eventsMan.Emit(ctx, events.LoanAccountSaveEvent, la); saveErr != nil {
		logger.WithError(saveErr).Error("could not update loan account with disbursement details")
	}

	// Transition loan to ACTIVE
	if _, transErr := b.laBusiness.TransitionStatus(
		ctx, loanAccountID,
		loansv1.LoanStatus_LOAN_STATUS_ACTIVE,
		"system", "disbursement completed",
	); transErr != nil {
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
			fieldStatus:             disb.Status,
			"ledger_transaction_id": disb.LedgerTransactionID,
		},
		Metadata: data.JSONMap{
			fieldLoanAccountID:    la.GetID(),
			fieldClientID:         la.ClientID,
			fieldAmount:           la.PrincipalAmount,
			fieldCurrency:         la.CurrencyCode,
			"channel":             req.GetChannel(),
			"recipient_reference": req.GetRecipientReference(),
			"idempotency_key":     req.GetIdempotencyKey(),
		},
		Parent: &disb.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for disbursement")
	})

	audit := constants.AuditTrailFromContext(ctx)
	disbAttrs := metric.WithAttributes(
		attribute.String("tenant_id", audit.TenantID),
		attribute.String("partition_id", audit.PartitionID),
		attribute.String("currency", la.CurrencyCode),
	)
	LoansDisbursed.Add(ctx, 1, disbAttrs)
	LoansDisbursedAmount.Add(ctx,
		float64(la.PrincipalAmount)/minorUnitsPerMajor,
		disbAttrs)

	return disb.ToAPI(), nil
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
				Amount:           moneyx.FromSmallestUnit(la.CurrencyCode, la.PrincipalAmount, decimalPrecision),
				OrderType:        constants.SafeInt32FromInt(constants.TransferTypeDisbursement),
				Reference:        "disbursement:" + disb.GetID(),
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
	return disb.ToAPI(), nil
}

func (b *disbursementBusiness) Search(
	ctx context.Context,
	req *loansv1.DisbursementSearchRequest,
	consumer func(ctx context.Context, batch []*loansv1.DisbursementObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "DisbursementBusiness.Search")

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
