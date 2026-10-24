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
	"strings"
	"time"

	"go.opentelemetry.io/otel/attribute"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

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
	scope             *ReadScope
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
	opts ...Option,
) RepaymentBusiness {
	return &repaymentBusiness{
		scope:             applyOptions(opts).scope,
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
	// Required whatever the limits configuration says. Without a key the
	// unique index on it collapses every key-less repayment in the partition
	// onto one row, and the second one is lost after its ledger orders have
	// already posted.
	if req.GetIdempotencyKey() == "" {
		return nil, ErrIdempotencyKeyRequired
	}

	la, err := b.loanAccountRepo.GetByID(ctx, req.GetLoanAccountId())
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}
	// Recording a repayment credits the loan, so it is a lender-side action:
	// staff, the payment rail (internal), or the field agent serving the
	// client who took the cash. A borrower cannot mark their own loan paid.
	if scopeErr := b.scope.AuthorizeAgent(ctx, la.ClientID); scopeErr != nil {
		return nil, scopeErr
	}
	// A field agent records cash taken in the field. Mobile money, bank and
	// savings repayments arrive through the payment rail or staff, where the
	// money is confirmed before the loan is credited.
	if !b.scope.IsStaff(ctx) && NormalizeRepaymentChannel(req.GetChannel()) != RepaymentChannelCash {
		return nil, ErrAgentCashOnly
	}

	// Idempotency short-circuit before the gate, so retries do not consume a
	// fresh reservation. A key already used on another loan is a conflict,
	// never a way to read someone else's repayment.
	if existing, existErr := b.repaymentRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey()); existErr == nil &&
		existing != nil {
		if existing.LoanAccountID != la.GetID() {
			return nil, ErrIdempotencyKeyConflict
		}
		return existing.ToAPI(), nil
	}

	if !b.limitsGateEnabled || b.limitsCli == nil || b.limitsGateMode == gateModeOff {
		return b.recordInner(ctx, req)
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
		},
		limits.InPartition(la.TenantID, la.PartitionID),
	)

	var pendingErr *limits.PendingApprovalError
	if errors.As(gateErr, &pendingErr) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, gateErr.Error()).WithCause(gateErr)
	}
	if gateErr != nil {
		return nil, gateErr
	}
	return result, nil
}

// recordInner is the pre-Gate body factored out so Gate's handler can wrap it.
// The idempotency check lives in the outer Record.
//
// The order of operations is deliberate. The allocation is computed in memory,
// the repayment row claims the idempotency key, the ledger is posted, and only
// then are the schedule entries and the balance moved. Posting the ledger
// after the schedule would let a transfer failure leave installments marked
// paid against money that never arrived.
func (b *repaymentBusiness) recordInner(
	ctx context.Context,
	req *loansv1.RepaymentRecordRequest,
) (*loansv1.RepaymentObject, error) {
	logger := util.Log(ctx).WithField("method", "RepaymentBusiness.Record")

	la, err := b.loanAccountRepo.GetByID(ctx, req.GetLoanAccountId())
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}
	if !isRepayableStatus(la.Status) {
		return nil, ErrLoanNotRepayable
	}

	amount, repCurrencyCode := models.MoneyToMinorUnits(req.GetAmount())
	if amount <= 0 {
		return nil, ErrRepaymentAmountInvalid
	}
	if repCurrencyCode != "" && repCurrencyCode != la.CurrencyCode {
		return nil, ErrRepaymentCurrencyMismatch
	}

	// Loaded once and shared by the penalty step of the waterfall and the
	// balance update, so the two cannot see different balance states.
	balance, balErr := b.loanBalanceRepo.GetByLoanAccountID(ctx, req.GetLoanAccountId())
	if balErr != nil {
		return nil, ErrBalanceNotFound
	}

	alloc := b.waterfallAllocate(ctx, req.GetLoanAccountId(), amount, balance)

	channel := NormalizeRepaymentChannel(req.GetChannel())
	collector := b.collectorFor(ctx, la)
	if channel == RepaymentChannelCash && collector == "" {
		// Cash exists only in someone's hands. A cash repayment nobody is
		// accountable for cannot be booked.
		return nil, ErrCashRepaymentNeedsCollector
	}

	r := &models.Repayment{
		LoanAccountID:    req.GetLoanAccountId(),
		Amount:           amount,
		CurrencyCode:     la.CurrencyCode,
		Status:           int32(alloc.status),
		PaymentReference: req.GetPaymentReference(),
		Channel:          channel,
		PayerReference:   req.GetPayerReference(),
		CollectedBy:      collector,
		PrincipalApplied: alloc.principalApplied,
		InterestApplied:  alloc.interestApplied,
		FeesApplied:      alloc.feesApplied,
		PenaltiesApplied: alloc.penaltiesApplied,
		ExcessAmount:     alloc.excessAmount,
		IdempotencyKey:   req.GetIdempotencyKey(),
	}
	r.GenID(ctx)

	stored, created, claimErr := b.repaymentRepo.ClaimIdempotencyKey(ctx, r)
	if claimErr != nil {
		logger.WithError(claimErr).Error("could not claim repayment idempotency key")
		return nil, claimErr
	}
	if !created {
		return stored.ToAPI(), nil
	}

	if toErr := b.emitRepaymentTransferOrders(ctx, logger, la, r, alloc); toErr != nil {
		// Nothing has been marked paid yet, so handing the key back leaves
		// the loan exactly as it was and lets the caller retry. The ledger
		// references are derived from the idempotency key, so any component
		// that did post is recognised as a duplicate on that retry.
		if _, relErr := b.repaymentRepo.UpdateColumns(ctx, r.GetID(), map[string]any{
			fieldStatus:         int32(loansv1.RepaymentStatus_REPAYMENT_STATUS_REVERSED),
			fieldIdempotencyKey: "failed:" + r.GetID(),
		}); relErr != nil {
			logger.WithError(relErr).Error("could not release the idempotency key of a failed repayment")
		}
		return nil, toErr
	}

	b.persistAllocatedEntries(ctx, logger, alloc)

	if applyErr := b.applyRepaymentToBalance(
		ctx,
		logger,
		la,
		alloc,
		channel,
		req.GetPaymentReference(),
	); applyErr != nil {
		return nil, applyErr
	}

	b.auditRepayment(ctx, logger, la, r, alloc, req)
	if collector != "" {
		b.notifier.NotifyAgentCollectionRecorded(ctx, la, collector, amount, channel, req.GetPaymentReference())
	}

	currencyAttr := attribute.String("currency", la.CurrencyCode)
	LoansRepaid.Add(ctx, 1, currencyAttr)
	LoansRepaidAmount.Add(ctx,
		float64(amount)/minorUnitsPerMajor,
		currencyAttr)

	return r.ToAPI(), nil
}

// auditRepayment records what happened when money came in, as an entry that
// joins naturally with the transfer orders and the balance snapshot.
func (b *repaymentBusiness) auditRepayment(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	r *models.Repayment,
	alloc waterfallResult,
	req *loansv1.RepaymentRecordRequest,
) {
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
			fieldAmount:         r.Amount,
			fieldCurrency:       la.CurrencyCode,
			"channel":           r.Channel,
			"collected_by":      r.CollectedBy,
			"payment_reference": req.GetPaymentReference(),
			"payer_reference":   req.GetPayerReference(),
			fieldIdempotencyKey: req.GetIdempotencyKey(),
		},
		Parent: &r.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for repayment")
	})
}

// isRepayableStatus reports whether a loan in this status can take money.
func isRepayableStatus(status int32) bool {
	return status == int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE) ||
		status == int32(loansv1.LoanStatus_LOAN_STATUS_DELINQUENT) ||
		status == int32(loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED)
}

// persistAllocatedEntries publishes the schedule entries the waterfall
// touched. It runs only once the ledger has accepted the money.
func (b *repaymentBusiness) persistAllocatedEntries(
	ctx context.Context,
	logger *util.LogEntry,
	alloc waterfallResult,
) {
	for _, entry := range alloc.touchedEntries {
		if emitErr := b.eventsMan.Emit(ctx, events.ScheduleEntrySaveEvent, entry); emitErr != nil {
			logger.WithField("entry_id", entry.GetID()).
				WithError(emitErr).
				Error("could not persist the updated schedule entry")
		}
	}
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
	channel, reference string,
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

	b.notifier.NotifyRepaymentReceived(ctx, la, delta.Total(), fresh.TotalOutstanding, channel, reference)

	if fresh.TotalOutstanding <= 0 {
		// The automatic pay-off goes through the same state machine as an
		// operator-driven transition, so a status the machine does not allow
		// to reach PAID_OFF is never claimed here either.
		fromStatus := loansv1.LoanStatus(la.Status)
		switch {
		case !transitionAllowed(fromStatus, loansv1.LoanStatus_LOAN_STATUS_PAID_OFF):
			logger.WithField("from_status", fromStatus.String()).
				Warn("loan is fully settled but its status cannot transition to PAID_OFF")
		default:
			// Claimed conditionally against the status we read, so the whole
			// loan row is never rewritten from this copy and a concurrent
			// transition cannot be clobbered.
			paidOff, claimErr := b.loanAccountRepo.ClaimStatus(
				ctx, la.GetID(), la.Status,
				int32(loansv1.LoanStatus_LOAN_STATUS_PAID_OFF),
			)
			switch {
			case claimErr != nil:
				logger.WithError(claimErr).Error("could not transition loan to PAID_OFF")
			case paidOff:
				b.recordPaidOffStatusChange(ctx, logger, la, fromStatus)
				la.Status = int32(loansv1.LoanStatus_LOAN_STATUS_PAID_OFF)
				logger.WithField("loan_id", la.GetID()).Info("loan fully paid off")
				// Only the call that won the PAID_OFF claim tells
				// downstream products (seed's credit profile). Hook errors
				// are logged: the money has moved and the loan is settled.
				b.firePaidOffHook(ctx, logger, la, fresh.TotalPaid)
			}
		}

		b.notifier.NotifyLoanFullyPaid(ctx, la)
	}
	return nil
}

func (b *repaymentBusiness) firePaidOffHook(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	totalPaid int64,
) {
	if b.paidOffHook == nil {
		return
	}
	if hookErr := b.paidOffHook.HandlePaidOff(ctx, la.GetID(), totalPaid); hookErr != nil {
		logger.WithError(hookErr).WithField("loan_id", la.GetID()).Warn("paid-off hook failed")
	}
}

// recordPaidOffStatusChange writes the audit row for an automatic pay-off, so
// the loan's history shows which status it was settled from and why.
func (b *repaymentBusiness) recordPaidOffStatusChange(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	fromStatus loansv1.LoanStatus,
) {
	statusChange := &models.LoanStatusChange{
		LoanAccountID: la.GetID(),
		FromStatus:    int32(fromStatus),
		ToStatus:      int32(loansv1.LoanStatus_LOAN_STATUS_PAID_OFF),
		ChangedBy:     "system",
		Reason:        "loan fully repaid",
	}
	statusChange.GenID(ctx)

	if err := b.eventsMan.Emit(ctx, events.LoanStatusChangeSaveEvent, statusChange); err != nil {
		logger.WithError(err).Warn("could not record the pay-off status change")
	}
}

// waterfallResult holds the outcome of waterfall allocation against schedule entries.
type waterfallResult struct {
	principalApplied int64
	interestApplied  int64
	feesApplied      int64
	penaltiesApplied int64
	excessAmount     int64
	status           loansv1.RepaymentStatus
	// touchedEntries are the schedule entries the allocation changed. They are
	// held in memory until the ledger has accepted the money, so a failed
	// posting never leaves installments marked paid.
	touchedEntries []*models.ScheduleEntry
	// amountDue is what the schedule and balance were still asking for at the
	// time of allocation. It is what separates a partial payment from a
	// settlement.
	amountDue int64
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
	// The ledger references are keyed on the caller's idempotency key, not on
	// the repayment row id: a partial failure hands the key back and the
	// retry mints a new row, so a row-keyed reference would let components
	// that already posted post a second time.
	repRef := repayment.IdempotencyKey
	// Where the money comes from depends on how it arrived. Cash collected in
	// the field sits with the agent until remitted, so it is debited from the
	// agent's cash-in-hand account, which is what the agent then owes the
	// till. Every other channel reached the borrower's own account first.
	memberAccount := constants.MemberLoansAccount(la.ClientID)
	if repayment.Channel == RepaymentChannelCash && repayment.CollectedBy != "" {
		memberAccount = constants.AgentCashAccount(repayment.CollectedBy)
	}
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
			fmt.Sprintf("repayment:%s:principal", repRef),
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
			fmt.Sprintf("repayment:%s:interest", repRef),
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
			fmt.Sprintf("repayment:%s:fees", repRef),
			"Fee repayment",
			baseExtraData.Copy(),
		); err != nil {
			return err
		}
	}

	if alloc.penaltiesApplied > 0 {
		// Penalty income was recognised when the penalty accrued (debit the
		// member's penalty receivable, credit penalty income). Settling it
		// clears that receivable; crediting income again would count the
		// same penalty twice and leave the receivable open for ever.
		if err := b.emitTransferOrder(ctx, logger,
			memberAccount, constants.MemberPenaltyReceivableAccount(la.ClientID),
			alloc.penaltiesApplied, la.CurrencyCode,
			constants.TransferTypePenaltyRepayment,
			fmt.Sprintf("repayment:%s:penalties", repRef),
			"Penalty repayment",
			baseExtraData.Copy(),
		); err != nil {
			return err
		}
	}

	// Money paid beyond what the loan was owed is still the borrower's. It
	// goes to their suspense account, where reconciliation can refund it or
	// apply it to the next obligation, rather than being recorded on the
	// repayment row and left off the ledger entirely.
	if alloc.excessAmount > 0 {
		if err := b.emitTransferOrder(ctx, logger,
			memberAccount, constants.ClientSuspenseAccount(la.ClientID),
			alloc.excessAmount, la.CurrencyCode,
			constants.TransferTypePayment,
			fmt.Sprintf("repayment:%s:excess", repRef),
			"Repayment in excess of amount due",
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
		return ErrOperationsClientUnavailable
	}

	req := &operationsv1.TransferOrderExecuteRequest{
		Data: &operationsv1.TransferOrderObject{
			DebitAccountRef:  debitAccount,
			CreditAccountRef: creditAccount,
			Amount:           moneyx.FromMinorUnitsByCurrency(currency, amount),
			OrderType:        constants.SafeInt32FromInt(orderType),
			Reference:        reference,
			Description:      description,
			ExtraData:        extraData.ToProtoStruct(),
		},
	}

	if _, execErr := b.operationsCli.TransferOrderExecute(ctx, req); execErr != nil {
		logger.WithError(execErr).
			WithField("reference", reference).
			Error("could not execute transfer order for repayment")
		return ErrRepaymentPostingFailed
	}
	return nil
}

// waterfallAllocate applies a payment amount in waterfall order:
// penalties -> interest -> fees -> principal. Penalties are allocated from the
// balance first, then schedule entries are processed for interest, fees,
// and principal.
//
// Allocation is pure: it mutates the schedule entry structs it loaded but
// persists nothing. The caller decides when those changes become durable.
func (b *repaymentBusiness) waterfallAllocate(
	ctx context.Context,
	loanAccountID string,
	amount int64,
	balance *models.LoanBalance,
) waterfallResult {
	result := waterfallResult{status: loansv1.RepaymentStatus_REPAYMENT_STATUS_PENDING}
	remaining := amount

	// 1. Allocate to outstanding penalties first (balance-level, not schedule-level)
	if balance != nil && balance.PenaltiesOutstanding > 0 && remaining > 0 {
		result.amountDue += balance.PenaltiesOutstanding
		penaltyPay := min64(balance.PenaltiesOutstanding, remaining)
		result.penaltiesApplied = penaltyPay
		remaining -= penaltyPay
	}

	// 2. Allocate remaining amount to schedule entries: interest -> fees -> principal
	entries := b.activeScheduleEntries(ctx, loanAccountID)
	if entries == nil {
		// With no schedule to allocate against, principal is the only thing
		// left to reduce, and only down to what is actually outstanding.
		// Anything past that is the borrower's money and leaves through the
		// same suspense route as any other excess.
		var principalOutstanding int64
		if balance != nil {
			principalOutstanding = balance.PrincipalOutstanding
		}
		result.principalApplied = min64(remaining, principalOutstanding)
		result.amountDue += principalOutstanding
		remaining -= result.principalApplied
		result.excessAmount = remaining
		result.status = repaymentStatusFor(amount, remaining, result.amountDue)
		return result
	}

	for _, entry := range entries {
		entryOutstanding := entry.TotalDue - (entry.PrincipalPaid + entry.InterestPaid + entry.FeesPaid)
		if entryOutstanding <= 0 {
			continue
		}
		result.amountDue += entryOutstanding
		if remaining <= 0 {
			continue
		}
		remaining = b.allocateToEntry(entry, remaining, &result)
	}

	result.excessAmount = remaining
	result.status = repaymentStatusFor(amount, remaining, result.amountDue)

	return result
}

// activeScheduleEntries loads the installments of the loan's active schedule,
// or nil when there is no usable schedule.
func (b *repaymentBusiness) activeScheduleEntries(
	ctx context.Context,
	loanAccountID string,
) []*models.ScheduleEntry {
	schedule, schedErr := b.scheduleRepo.GetActivByLoanAccountID(ctx, loanAccountID)
	if schedErr != nil || schedule == nil {
		return nil
	}
	entries, entryErr := b.scheduleEntryRepo.GetByScheduleID(ctx, schedule.GetID())
	if entryErr != nil {
		return nil
	}
	return entries
}

// repaymentStatusFor classifies a payment against what was owed. PARTIAL and
// OVERPAYMENT are real outcomes a collections officer needs to see, not
// decorative enum values.
func repaymentStatusFor(amount, remaining, amountDue int64) loansv1.RepaymentStatus {
	switch {
	case remaining > 0:
		return loansv1.RepaymentStatus_REPAYMENT_STATUS_OVERPAYMENT
	case amount < amountDue:
		return loansv1.RepaymentStatus_REPAYMENT_STATUS_PARTIAL
	default:
		return loansv1.RepaymentStatus_REPAYMENT_STATUS_MATCHED
	}
}

// allocateToEntry applies payment to a single schedule entry in waterfall
// order and records it as touched. Returns the remaining amount.
func (b *repaymentBusiness) allocateToEntry(
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

	entryTotalPaid := entry.PrincipalPaid + entry.InterestPaid + entry.FeesPaid
	switch {
	case entryTotalPaid >= entry.TotalDue:
		entry.Status = int32(loansv1.ScheduleEntryStatus_SCHEDULE_ENTRY_STATUS_PAID)
	case entryTotalPaid > 0:
		entry.Status = int32(loansv1.ScheduleEntryStatus_SCHEDULE_ENTRY_STATUS_PARTIAL)
	}
	entry.TotalPaid = entryTotalPaid
	entry.Outstanding = entry.TotalDue - entryTotalPaid

	result.touchedEntries = append(result.touchedEntries, entry)

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
	if scopeErr := authorizeLoanAccount(ctx, b.scope, b.loanAccountRepo, r.LoanAccountID); scopeErr != nil {
		return nil, scopeErr
	}
	return r.ToAPI(), nil
}

func (b *repaymentBusiness) Search(
	ctx context.Context,
	req *loansv1.RepaymentSearchRequest,
	consumer func(ctx context.Context, batch []*loansv1.RepaymentObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "RepaymentBusiness.Search")

	andQueryVal, scopeErr := b.searchScope(ctx, req)
	if scopeErr != nil {
		return scopeErr
	}

	var searchOpts []data.SearchOption

	cursor := req.GetCursor()
	if cursor != nil {
		offset, offsetErr := strconv.Atoi(cursor.GetPage())
		if offsetErr != nil {
			offset = 0
		}
		searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(int(cursor.GetLimit())))
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

// searchScope builds the filters a repayment search is confined to. A search
// names a loan the caller may read, or a collector: field agents may list
// their own collections across loans, staff anyone's. Staff may also search
// the whole partition.
func (b *repaymentBusiness) searchScope(
	ctx context.Context,
	req *loansv1.RepaymentSearchRequest,
) (map[string]any, error) {
	filters := map[string]any{}
	if after := strings.TrimSpace(req.GetReceivedAfter()); after != "" {
		t, err := time.Parse(time.RFC3339, after)
		if err != nil {
			return nil, ErrInvalidTimeRange
		}
		filters["created_at >= ?"] = t
	}
	if before := strings.TrimSpace(req.GetReceivedBefore()); before != "" {
		t, err := time.Parse(time.RFC3339, before)
		if err != nil {
			return nil, ErrInvalidTimeRange
		}
		filters["created_at < ?"] = t
	}
	if collector := strings.TrimSpace(req.GetCollectedBy()); collector != "" {
		filters["collected_by = ?"] = collector
	}

	if loanID := req.GetLoanAccountId(); loanID != "" {
		if err := authorizeLoanAccount(ctx, b.scope, b.loanAccountRepo, loanID); err != nil {
			return nil, err
		}
		filters["loan_account_id = ?"] = loanID
		return filters, nil
	}

	if b.scope.IsStaff(ctx) {
		return filters, nil
	}
	// Without a loan, a non-staff caller lists only what they collected: an
	// empty collector means "mine", any other collector is refused.
	subject := callerSubject(ctx)
	collector := strings.TrimSpace(req.GetCollectedBy())
	if subject == "" || (collector != "" && collector != subject) {
		return nil, ErrLoanNotOwned
	}
	filters["collected_by = ?"] = subject
	return filters, nil
}

// Repayment channels as stored. Callers send free text; it is folded onto
// these so reports, ledger legs and messages agree on what happened.
const (
	RepaymentChannelCash        = "cash"
	RepaymentChannelMobileMoney = "mobile_money"
	RepaymentChannelBank        = "bank"
	RepaymentChannelSavings     = "savings"
	RepaymentChannelOther       = "other"
)

// NormalizeRepaymentChannel folds the channel a caller typed onto the stored
// vocabulary. Unknown values become "other" rather than a new spelling.
func NormalizeRepaymentChannel(raw string) string {
	v := strings.ToLower(strings.TrimSpace(raw))
	v = strings.NewReplacer("-", "_", " ", "_").Replace(v)
	switch v {
	case "cash", "agent_cash", "cash_agent", "field_cash", "field":
		return RepaymentChannelCash
	case "mobile_money", "mobile", "momo", "mpesa", "m_pesa", "airtel_money", "mtn_momo", "ussd":
		return RepaymentChannelMobileMoney
	case "bank", "bank_transfer", "eft", "rtgs", "cheque", "check":
		return RepaymentChannelBank
	case "savings", "wallet", "savings_account":
		return RepaymentChannelSavings
	case "":
		return RepaymentChannelOther
	default:
		return RepaymentChannelOther
	}
}

// collectorFor names the staff member or field agent recording the repayment
// on the borrower's behalf: the caller, unless the caller is the borrower.
func (b *repaymentBusiness) collectorFor(ctx context.Context, la *models.LoanAccount) string {
	subject := callerSubject(ctx)
	if subject == "" {
		return ""
	}
	if b.scope != nil && b.scope.IsBorrowerOf(ctx, la.ClientID) {
		// The borrower paying for themselves is not a collector.
		return ""
	}
	return subject
}
