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
	"strconv"

	"go.opentelemetry.io/otel/attribute"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

const moneyDecimalPlaces = 2

type RepaymentBusiness interface {
	Record(ctx context.Context, req *loansv1.RepaymentRecordRequest) (*loansv1.RepaymentObject, error)
	Get(ctx context.Context, id string) (*loansv1.RepaymentObject, error)
	Search(
		ctx context.Context,
		req *loansv1.RepaymentSearchRequest,
		consumer func(ctx context.Context, batch []*loansv1.RepaymentObject) error,
	) error
}

// PaidOffHook is the extension point for downstream products (such as
// seed) that want to react when a loan reaches PAID_OFF. Implementations
// must be safe to call synchronously from inside the repayment pipeline
// and must be idempotent: the hook might fire more than once for the
// same loan if a retry or replay happens.
//
// A nil PaidOffHook is fine; the repayment business simply skips the
// notification in that case.
type PaidOffHook interface {
	HandlePaidOff(ctx context.Context, loanAccountID string, totalRepaid int64) error
}

type repaymentBusiness struct {
	eventsMan         fevents.Manager
	loanAccountRepo   repository.LoanAccountRepository
	repaymentRepo     repository.RepaymentRepository
	scheduleRepo      repository.RepaymentScheduleRepository
	scheduleEntryRepo repository.ScheduleEntryRepository
	loanBalanceRepo   repository.LoanBalanceRepository
	notifier          *LoanNotifier
	operationsCli     operationsv1connect.OperationsServiceClient
	auditWriter       *audit.Writer
	paidOffHook       PaidOffHook
	limitsCli         limitsv1connect.LimitsServiceClient
	limitsGateEnabled bool
	limitsGateMode    string
}

func NewRepaymentBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	loanAccountRepo repository.LoanAccountRepository,
	repaymentRepo repository.RepaymentRepository,
	scheduleRepo repository.RepaymentScheduleRepository,
	scheduleEntryRepo repository.ScheduleEntryRepository,
	loanBalanceRepo repository.LoanBalanceRepository,
	notifier *LoanNotifier,
	operationsCli operationsv1connect.OperationsServiceClient,
	auditWriter *audit.Writer,
	paidOffHook PaidOffHook,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsGateEnabled bool,
	limitsGateMode string,
) RepaymentBusiness {
	return &repaymentBusiness{
		eventsMan:         eventsMan,
		loanAccountRepo:   loanAccountRepo,
		repaymentRepo:     repaymentRepo,
		scheduleRepo:      scheduleRepo,
		scheduleEntryRepo: scheduleEntryRepo,
		loanBalanceRepo:   loanBalanceRepo,
		notifier:          notifier,
		operationsCli:     operationsCli,
		auditWriter:       auditWriter,
		paidOffHook:       paidOffHook,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsGateEnabled,
		limitsGateMode:    limitsGateMode,
	}
}

func (b *repaymentBusiness) Record(
	ctx context.Context,
	req *loansv1.RepaymentRecordRequest,
) (*loansv1.RepaymentObject, error) {
	// Idempotency check (outer — before Gate so retries short-circuit cleanly).
	if req.GetIdempotencyKey() != "" {
		existing, err := b.repaymentRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey())
		if err == nil && existing != nil {
			return existing.ToAPI(), nil
		}
	}

	if !b.limitsGateEnabled || b.limitsCli == nil || b.limitsGateMode == gateModeOff {
		return b.recordInner(ctx, req)
	}

	// Load loan account to build the intent before the gate.
	la, err := b.loanAccountRepo.GetByID(ctx, req.GetLoanAccountId())
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}

	intent := &limitsv1.LimitIntent{
		Action: limitsv1.LimitAction_LIMIT_ACTION_LOAN_REPAYMENT,
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: la.ClientID},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: la.OrganizationID},
		},
		TenantId: la.OrganizationID,
		Amount:   req.GetAmount(),
		MakerId:  callerSubject(ctx),
	}
	if req.GetIdempotencyKey() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("idempotency_key required"))
	}
	idemKey := "loan_repayment:" + req.GetLoanAccountId() + ":" + req.GetIdempotencyKey()

	var result *loansv1.RepaymentObject
	gateErr := limits.Gate(ctx, b.limitsCli, intent, idemKey, limits.ParseMode(b.limitsGateMode),
		func(innerCtx context.Context, reservationID string) error {
			util.Log(innerCtx).With("limits_reservation_id", reservationID).Info("repayment gated by limits")
			inner, innerErr := b.recordInner(innerCtx, req)
			if innerErr != nil {
				return innerErr
			}
			result = inner
			return nil
		})

	var pendingErr *limits.PendingApprovalError
	if errors.As(gateErr, &pendingErr) {
		return nil, fmt.Errorf("repayment requires approval (reservation %s): %w",
			pendingErr.ReservationID, gateErr)
	}
	if gateErr != nil {
		return nil, gateErr
	}
	return result, nil
}

// recordInner is the pre-Gate body factored out so Gate's handler can wrap it.
// The idempotency check lives in the outer Record.
func (b *repaymentBusiness) recordInner(
	ctx context.Context,
	req *loansv1.RepaymentRecordRequest,
) (*loansv1.RepaymentObject, error) {
	logger := util.Log(ctx).WithField("method", "RepaymentBusiness.Record")

	// Validate loan account exists
	la, err := b.loanAccountRepo.GetByID(ctx, req.GetLoanAccountId())
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}

	// Only accept repayments on active, delinquent, or restructured loans
	if la.Status != int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE) &&
		la.Status != int32(loansv1.LoanStatus_LOAN_STATUS_DELINQUENT) &&
		la.Status != int32(loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED) {
		return nil, fmt.Errorf("loan is not in a repayable state (status=%d)", la.Status)
	}

	amount, repCurrencyCode := models.MoneyToMinorUnits(req.GetAmount())

	if amount <= 0 {
		return nil, fmt.Errorf("repayment amount must be positive, got %d", amount)
	}

	if repCurrencyCode != "" && repCurrencyCode != la.CurrencyCode {
		return nil, fmt.Errorf("repayment currency %s does not match loan currency %s",
			repCurrencyCode, la.CurrencyCode)
	}

	// Load balance once — used for both penalty allocation and balance update.
	// This avoids a race condition where two concurrent repayments could read
	// different balance states between the waterfall and the update.
	balance, balErr := b.loanBalanceRepo.GetByLoanAccountID(ctx, req.GetLoanAccountId())

	// Waterfall allocation: penalties (from balance) -> interest -> fees -> principal (from schedule)
	alloc := b.waterfallAllocate(ctx, logger, req.GetLoanAccountId(), amount, balance)

	r := &models.Repayment{
		LoanAccountID:    req.GetLoanAccountId(),
		Amount:           amount,
		CurrencyCode:     la.CurrencyCode,
		Status:           int32(alloc.status),
		PaymentReference: req.GetPaymentReference(),
		Channel:          req.GetChannel(),
		PayerReference:   req.GetPayerReference(),
		PrincipalApplied: alloc.principalApplied,
		InterestApplied:  alloc.interestApplied,
		FeesApplied:      alloc.feesApplied,
		PenaltiesApplied: alloc.penaltiesApplied,
		ExcessAmount:     alloc.excessAmount,
		IdempotencyKey:   req.GetIdempotencyKey(),
	}
	r.GenID(ctx)

	err = b.eventsMan.Emit(ctx, events.RepaymentSaveEvent, r)
	if err != nil {
		logger.WithError(err).Error("could not emit repayment save event")
		return nil, err
	}

	// Emit transfer orders for each allocation component (ledger double-entry).
	// Each transfer order carries a stable reference (the idempotency key),
	// so retries of this call are safe: the operations service dedupes on
	// reference and converges on a single ledger posting per component.
	// We surface any emission error so the caller can retry the repayment;
	// on retry the repayment's own idempotency_key short-circuits the record
	// creation and the transfer orders reconcile via their references.
	if toErr := b.emitRepaymentTransferOrders(ctx, logger, la, r, alloc); toErr != nil {
		return nil, toErr
	}

	// Apply the allocation to the loan balance atomically. A single SQL
	// UPDATE with arithmetic expressions clamps each bucket at zero and
	// serializes concurrent repayments at the row-level, so no read-modify-
	// write race is possible here regardless of how the event pipeline
	// interleaves.
	if balErr == nil && balance != nil {
		if applyErr := b.applyRepaymentToBalance(ctx, logger, la, alloc); applyErr != nil {
			return nil, applyErr
		}
	}

	// Descriptive audit capture. The Repayment table holds the normalised
	// record, but the audit event gives a traceable "what happened when
	// money came in" entry that joins naturally with transfer orders,
	// loan balance snapshots, and future credit profile changes.
	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "repayment",
		EntityID:   r.GetID(),
		Action:     "repayment.applied",
		Reason:     "inbound repayment applied via waterfall",
		After: data.JSONMap{
			fieldStatus:         alloc.status.String(),
			"principal_applied": alloc.principalApplied,
			"interest_applied":  alloc.interestApplied,
			"fees_applied":      alloc.feesApplied,
			"penalties_applied": alloc.penaltiesApplied,
			"excess_amount":     alloc.excessAmount,
		},
		Metadata: data.JSONMap{
			fieldLoanAccountID:  la.GetID(),
			fieldClientID:       la.ClientID,
			fieldAmount:         amount,
			fieldCurrency:       la.CurrencyCode,
			"channel":           req.GetChannel(),
			"payment_reference": req.GetPaymentReference(),
			"payer_reference":   req.GetPayerReference(),
			"idempotency_key":   req.GetIdempotencyKey(),
		},
		Parent: &r.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for repayment")
	})

	currencyAttr := attribute.String("currency", la.CurrencyCode)
	LoansRepaid.Add(ctx, 1, currencyAttr)
	LoansRepaidAmount.Add(ctx,
		float64(amount)/minorUnitsPerMajor,
		currencyAttr)

	return r.ToAPI(), nil
}

// applyRepaymentToBalance applies a waterfall allocation to the authoritative
// loan balance row using an atomic SQL delta, then re-reads the fresh row to
// check for full payoff. Because the UPDATE uses arithmetic expressions and
// clamps each bucket at zero in the database itself, concurrent repayments
// on the same loan serialize correctly without any application-side locking.
func (b *repaymentBusiness) applyRepaymentToBalance(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	alloc waterfallResult,
) error {
	delta := repository.LoanBalanceDelta{
		PrincipalApplied: alloc.principalApplied,
		InterestApplied:  alloc.interestApplied,
		FeesApplied:      alloc.feesApplied,
		PenaltiesApplied: alloc.penaltiesApplied,
	}

	fresh, err := b.loanBalanceRepo.ApplyRepaymentDelta(ctx, la.GetID(), delta)
	if err != nil {
		logger.WithError(err).Error("could not apply repayment delta to loan balance")
		return err
	}

	if b.notifier != nil {
		b.notifier.NotifyRepaymentReceived(ctx, la.ClientID, "",
			models.MinorUnitsToString(delta.Total()),
			la.CurrencyCode,
			models.MinorUnitsToString(fresh.TotalOutstanding),
		)
	}

	if fresh.TotalOutstanding <= 0 { //nolint:nestif // paid-off transition involves multiple side effects
		la.Status = int32(loansv1.LoanStatus_LOAN_STATUS_PAID_OFF)
		if emitErr := b.eventsMan.Emit(ctx, events.LoanAccountSaveEvent, la); emitErr != nil {
			logger.WithError(emitErr).Error("could not transition loan to PAID_OFF")
		} else {
			logger.WithField("loan_id", la.GetID()).Info("loan fully paid off")
		}

		if b.notifier != nil {
			b.notifier.NotifyLoanFullyPaid(ctx, la.ClientID, "")
		}

		// Fire the paid-off hook so downstream products (seed credit
		// profile, for instance) can react to a fully settled loan.
		// Hook errors are logged but do not fail the repayment: the
		// money has moved and the loan is settled regardless.
		if b.paidOffHook != nil {
			if hookErr := b.paidOffHook.HandlePaidOff(ctx, la.GetID(), fresh.TotalPaid); hookErr != nil {
				logger.WithError(hookErr).
					WithField("loan_id", la.GetID()).
					Warn("paid-off hook failed")
			}
		}
	}
	return nil
}

// waterfallResult holds the outcome of waterfall allocation against schedule entries.
type waterfallResult struct {
	principalApplied int64
	interestApplied  int64
	feesApplied      int64
	penaltiesApplied int64
	excessAmount     int64
	status           loansv1.RepaymentStatus
}

// emitRepaymentTransferOrders creates transfer orders for each allocation
// component of a repayment. Each call uses a stable reference built from the
// repayment id and the component name; the operations service treats that
// reference as an idempotency key, so retrying this function after a partial
// failure converges on a single ledger posting per component rather than
// duplicating money movement.
//
// Errors surface to the caller so the repayment cannot be reported as
// successful with missing ledger postings.
func (b *repaymentBusiness) emitRepaymentTransferOrders(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	repayment *models.Repayment,
	alloc waterfallResult,
) error {
	repID := repayment.GetID()
	memberAccount := constants.MemberLoansAccount(la.ClientID)
	loanRequestID := loanRequestIDFromProperties(la.Properties, la.LoanRequestID)
	baseExtraData := data.JSONMap{
		"loan_id":          la.GetID(),
		fieldLoanRequestID: loanRequestID,
		fieldClientID:      la.ClientID,
		"repayment_id":     repayment.GetID(),
	}

	if alloc.principalApplied > 0 {
		if err := b.emitTransferOrder(ctx, logger,
			memberAccount, la.LedgerAssetAccountID,
			alloc.principalApplied, la.CurrencyCode,
			constants.TransferTypeLoanRepayment,
			fmt.Sprintf("repayment:%s:principal", repID),
			"Principal repayment",
			baseExtraData.Copy(),
		); err != nil {
			return err
		}
	}

	if alloc.interestApplied > 0 {
		if err := b.emitTransferOrder(ctx, logger,
			memberAccount, la.LedgerInterestIncomeAccountID,
			alloc.interestApplied, la.CurrencyCode,
			constants.TransferTypeLoanInterestRepayment,
			fmt.Sprintf("repayment:%s:interest", repID),
			"Interest repayment",
			baseExtraData.Copy(),
		); err != nil {
			return err
		}
	}

	if alloc.feesApplied > 0 {
		if err := b.emitTransferOrder(ctx, logger,
			memberAccount, la.LedgerFeeIncomeAccountID,
			alloc.feesApplied, la.CurrencyCode,
			constants.TransferTypeLoanInsuranceRepayment,
			fmt.Sprintf("repayment:%s:fees", repID),
			"Fee repayment",
			baseExtraData.Copy(),
		); err != nil {
			return err
		}
	}

	if alloc.penaltiesApplied > 0 {
		if err := b.emitTransferOrder(ctx, logger,
			memberAccount, la.LedgerPenaltyIncomeAccountID,
			alloc.penaltiesApplied, la.CurrencyCode,
			constants.TransferTypePenaltyCancel,
			fmt.Sprintf("repayment:%s:penalties", repID),
			"Penalty repayment",
			baseExtraData.Copy(),
		); err != nil {
			return err
		}
	}

	return nil
}

// emitTransferOrder creates and executes a single transfer order via the
// operations service SDK. A missing operations client is treated as a hard
// configuration error rather than a silent skip: every money movement must
// reach the ledger, and running without an operations client means nothing
// is reaching it.
func (b *repaymentBusiness) emitTransferOrder(
	ctx context.Context,
	logger *util.LogEntry,
	debitAccount, creditAccount string,
	amount int64,
	currency string,
	orderType int,
	reference, description string,
	extraData data.JSONMap,
) error {
	if b.operationsCli == nil {
		return fmt.Errorf("operations client is not configured; cannot post transfer order %s", reference)
	}

	req := connect.NewRequest(&operationsv1.TransferOrderExecuteRequest{
		Data: &operationsv1.TransferOrderObject{
			DebitAccountRef:  debitAccount,
			CreditAccountRef: creditAccount,
			Amount:           moneyx.FromSmallestUnit(currency, amount, moneyDecimalPlaces),
			OrderType:        constants.SafeInt32FromInt(orderType),
			Reference:        reference,
			Description:      description,
			ExtraData:        extraData.ToProtoStruct(),
		},
	})

	if _, execErr := b.operationsCli.TransferOrderExecute(ctx, req); execErr != nil {
		logger.WithError(execErr).
			WithField("reference", reference).
			Error("could not execute transfer order for repayment")
		return fmt.Errorf("transfer order %s failed: %w", reference, execErr)
	}
	return nil
}

// waterfallAllocate applies a payment amount in waterfall order:
// penalties -> interest -> fees -> principal. Penalties are allocated from the
// balance first, then schedule entries are processed for interest, fees,
// and principal. The balance parameter is optional (may be nil).
func (b *repaymentBusiness) waterfallAllocate(
	ctx context.Context,
	logger *util.LogEntry,
	loanAccountID string,
	amount int64,
	balance *models.LoanBalance,
) waterfallResult {
	result := waterfallResult{status: loansv1.RepaymentStatus_REPAYMENT_STATUS_PENDING}
	remaining := amount

	// 1. Allocate to outstanding penalties first (balance-level, not schedule-level)
	if balance != nil && balance.PenaltiesOutstanding > 0 && remaining > 0 {
		penaltyPay := min64(balance.PenaltiesOutstanding, remaining)
		result.penaltiesApplied = penaltyPay
		remaining -= penaltyPay
	}

	// 2. Allocate remaining amount to schedule entries: interest -> fees -> principal
	schedule, schedErr := b.scheduleRepo.GetActivByLoanAccountID(ctx, loanAccountID)
	if schedErr != nil || schedule == nil {
		// No schedule found, fall back to applying full remaining as principal
		result.principalApplied = remaining
		return result
	}

	entries, entryErr := b.scheduleEntryRepo.GetByScheduleID(ctx, schedule.GetID())
	if entryErr != nil {
		result.principalApplied = remaining
		return result
	}

	for _, entry := range entries {
		if remaining <= 0 {
			break
		}
		totalPaid := entry.PrincipalPaid + entry.InterestPaid + entry.FeesPaid
		if totalPaid >= entry.TotalDue {
			continue
		}

		remaining = b.allocateToEntry(ctx, logger, entry, remaining, &result)
	}

	result.excessAmount = remaining
	totalAllocated := result.penaltiesApplied + result.principalApplied +
		result.interestApplied + result.feesApplied
	if remaining == 0 || totalAllocated > 0 {
		result.status = loansv1.RepaymentStatus_REPAYMENT_STATUS_MATCHED
	}

	return result
}

// allocateToEntry applies payment to a single schedule entry in waterfall order
// and emits the updated entry. Returns the remaining amount.
func (b *repaymentBusiness) allocateToEntry(
	ctx context.Context,
	logger *util.LogEntry,
	entry *models.ScheduleEntry,
	remaining int64,
	result *waterfallResult,
) int64 {
	// 1. Interest first
	interestOwed := entry.InterestDue - entry.InterestPaid
	if interestOwed > 0 {
		pay := min64(interestOwed, remaining)
		entry.InterestPaid += pay
		result.interestApplied += pay
		remaining -= pay
	}

	// 2. Fees (insurance + processing)
	feesOwed := entry.FeesDue - entry.FeesPaid
	if feesOwed > 0 {
		pay := min64(feesOwed, remaining)
		entry.FeesPaid += pay
		result.feesApplied += pay
		remaining -= pay
	}

	// 3. Principal last
	principalOwed := entry.PrincipalDue - entry.PrincipalPaid
	if principalOwed > 0 {
		pay := min64(principalOwed, remaining)
		entry.PrincipalPaid += pay
		result.principalApplied += pay
		remaining -= pay
	}

	// Update entry status
	entryTotalPaid := entry.PrincipalPaid + entry.InterestPaid + entry.FeesPaid
	switch {
	case entryTotalPaid >= entry.TotalDue:
		entry.Status = int32(loansv1.ScheduleEntryStatus_SCHEDULE_ENTRY_STATUS_PAID)
	case entryTotalPaid > 0:
		entry.Status = int32(loansv1.ScheduleEntryStatus_SCHEDULE_ENTRY_STATUS_PARTIAL)
	}
	entry.TotalPaid = entryTotalPaid
	entry.Outstanding = entry.TotalDue - entryTotalPaid

	if emitErr := b.eventsMan.Emit(ctx, events.ScheduleEntrySaveEvent, entry); emitErr != nil {
		logger.WithField("entry_id", entry.GetID()).
			WithError(emitErr).
			Warn("could not emit schedule entry update")
	}

	return remaining
}

// min64 returns the smaller of two int64 values.
func min64(a, b int64) int64 {
	if a < b {
		return a
	}
	return b
}

func (b *repaymentBusiness) Get(ctx context.Context, id string) (*loansv1.RepaymentObject, error) {
	r, err := b.repaymentRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrRepaymentNotFound
	}
	return r.ToAPI(), nil
}

//nolint:dupl // similar search logic for different entity types
func (b *repaymentBusiness) Search(
	ctx context.Context,
	req *loansv1.RepaymentSearchRequest,
	consumer func(ctx context.Context, batch []*loansv1.RepaymentObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "RepaymentBusiness.Search")

	var searchOpts []data.SearchOption

	cursor := req.GetCursor()
	if cursor != nil {
		offset, offsetErr := strconv.Atoi(cursor.GetPage())
		if offsetErr != nil {
			offset = 0
		}
		searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(int(cursor.GetLimit())))
	}

	andQueryVal := map[string]any{}
	if req.GetLoanAccountId() != "" {
		andQueryVal["loan_account_id = ?"] = req.GetLoanAccountId()
	}
	if req.GetStatus() != loansv1.RepaymentStatus_REPAYMENT_STATUS_UNSPECIFIED {
		andQueryVal["status = ?"] = int32(req.GetStatus())
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.repaymentRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search repayments")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.Repayment) error {
		var apiResults []*loansv1.RepaymentObject
		for _, r := range res {
			apiResults = append(apiResults, r.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}
