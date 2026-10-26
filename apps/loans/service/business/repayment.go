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
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/antinvestor/service-fintech/pkg/transferorder"

	"go.opentelemetry.io/otel/attribute"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
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
	fundingSettlement *FundingSettlement
	applier           repository.RepaymentApplier
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
	opts ...Option,
) RepaymentBusiness {
	return &repaymentBusiness{
		scope:             applyOptions(opts).scope,
		fundingSettlement: applyOptions(opts).fundingSettlement,
		applier:           applyOptions(opts).repaymentApplier,
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

	// Nobody records a repayment by hand. The borrower pays from their own
	// contact and the payment rail, having matched the inbound payment,
	// applies it; field agents and staff never handle the money.
	if claims := security.ClaimsFromContext(ctx); claims == nil || !claims.IsInternalSystem() {
		return nil, ErrRepaymentRecordInternalOnly
	}
	if NormalizeRepaymentChannel(req.GetChannel()) == RepaymentChannelCash {
		return nil, ErrCashRepaymentRefused
	}

	la, err := b.loanAccountRepo.GetByID(ctx, req.GetLoanAccountId())
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}

	// A key already used on another loan is a conflict, never a way to read
	// someone else's repayment; a finished one is returned as it was.
	if existing, existErr := b.repaymentRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey()); existErr == nil &&
		existing != nil {
		if existing.LoanAccountID != la.GetID() {
			return nil, ErrIdempotencyKeyConflict
		}
		if existing.AppliedAt != nil {
			return existing.ToAPI(), nil
		}
		// Recorded but not finished: recordInner resumes it.
	}

	// No transaction limit applies here: the money has already arrived on
	// the rail, so refusing to apply it would only strand the borrower's
	// payment. Limits gate money leaving, not money received.
	return b.recordInner(ctx, req)
}

// recordInner applies a repayment.
//
// Repayments on one loan are taken one at a time under the loan's repayment
// lease, so two payments never allocate against the same installments. The
// allocation is computed and stored on the repayment row with the
// idempotency key; the ledger is then posted; and only then are the
// installments and the balance moved, together with marking the row applied,
// in one transaction. A failure at any step leaves a row that a retry with
// the same key resumes from where it stopped, with the amounts it stored, so
// nothing posts or applies twice.
func (b *repaymentBusiness) recordInner(
	ctx context.Context,
	req *loansv1.RepaymentRecordRequest,
) (*loansv1.RepaymentObject, error) {
	logger := util.Log(ctx).WithField("method", "RepaymentBusiness.Record")

	la, err := b.loanAccountRepo.GetByID(ctx, req.GetLoanAccountId())
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}

	locked, lockErr := b.loanAccountRepo.ClaimRepaymentLock(ctx, la.GetID())
	if lockErr != nil {
		return nil, fmt.Errorf("claim the loan for repayment: %w", lockErr)
	}
	if !locked {
		return nil, ErrRepaymentInProgress
	}
	defer func() {
		if relErr := b.loanAccountRepo.ReleaseRepaymentLock(ctx, la.GetID()); relErr != nil {
			logger.WithError(relErr).Warn("could not release the loan's repayment lease; it lapses on its own")
		}
	}()

	if existing, existErr := b.repaymentRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey()); existErr == nil &&
		existing != nil {
		if existing.LoanAccountID != la.GetID() {
			return nil, ErrIdempotencyKeyConflict
		}
		return b.finishRepayment(ctx, logger, la, existing, req)
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

	r := &models.Repayment{
		LoanAccountID:    req.GetLoanAccountId(),
		Amount:           amount,
		CurrencyCode:     la.CurrencyCode,
		Status:           int32(alloc.status),
		PaymentReference: req.GetPaymentReference(),
		Channel:          channel,
		PayerReference:   req.GetPayerReference(),
		PrincipalApplied: alloc.principalApplied,
		InterestApplied:  alloc.interestApplied,
		FeesApplied:      alloc.feesApplied,
		PenaltiesApplied: alloc.penaltiesApplied,
		ExcessAmount:     alloc.excessAmount,
		IdempotencyKey:   req.GetIdempotencyKey(),
		Properties:       data.JSONMap{repaymentAllocationKey: encodeEntryAllocations(alloc.entryAllocations)},
	}
	r.GenID(ctx)

	stored, _, claimErr := b.repaymentRepo.ClaimIdempotencyKey(ctx, r)
	if claimErr != nil {
		logger.WithError(claimErr).Error("could not claim repayment idempotency key")
		return nil, claimErr
	}
	return b.finishRepayment(ctx, logger, la, stored, req)
}

// finishRepayment takes a recorded repayment the rest of the way: the ledger
// postings, then the installments and balance in one transaction, then the
// consequences (messages, pay-off, funder shares). Each step is safe to
// repeat, which is what lets a retry resume a repayment that stopped part way.
func (b *repaymentBusiness) finishRepayment(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	r *models.Repayment,
	req *loansv1.RepaymentRecordRequest,
) (*loansv1.RepaymentObject, error) {
	if r.AppliedAt != nil {
		return r.ToAPI(), nil
	}
	alloc := allocationOf(r)

	if toErr := b.emitRepaymentTransferOrders(ctx, logger, la, r, alloc); toErr != nil {
		// Nothing counts against the loan yet. The ledger references are
		// keyed on the idempotency key, so the retry that resumes this row
		// posts only the components that did not go through.
		return nil, toErr
	}

	if b.applier == nil {
		return nil, ErrRepaymentPostingFailed
	}
	applied, fresh, applyErr := b.applier.Apply(ctx, r.GetID(), la.GetID(), alloc.entryAllocations,
		repository.LoanBalanceDelta{
			PrincipalApplied: alloc.principalApplied,
			InterestApplied:  alloc.interestApplied,
			FeesApplied:      alloc.feesApplied,
			PenaltiesApplied: alloc.penaltiesApplied,
		})
	if applyErr != nil {
		logger.WithError(applyErr).Error("repayment posted but not yet applied; a retry with the same key finishes it")
		return nil, applyErr
	}
	now := time.Now().UTC()
	r.AppliedAt = &now
	if !applied {
		// Another attempt applied it first; its consequences ran there.
		return r.ToAPI(), nil
	}

	b.afterRepaymentApplied(ctx, logger, la, r, fresh)

	// A repayment can clear arrears; bring the loan's assessment forward so
	// the next delinquency run cures it rather than a day later.
	if la.Status == int32(loansv1.LoanStatus_LOAN_STATUS_DELINQUENT) {
		if soonErr := b.loanAccountRepo.AssessSoon(ctx, la.GetID()); soonErr != nil {
			logger.WithError(soonErr).Warn("could not bring the loan's delinquency assessment forward")
		}
	}

	// The funders' shares are a consequence of the repayment, not part of
	// it: a failure here leaves the repayment recorded and the scheduled
	// settlement job finishes the shares.
	if b.fundingSettlement != nil {
		if settleErr := b.fundingSettlement.Settle(ctx, la, r); settleErr != nil {
			logger.WithError(settleErr).Warn("repayment recorded; funder shares left to the settlement job")
		}
	}

	b.auditRepayment(ctx, logger, la, r, alloc, req)

	currencyAttr := attribute.String("currency", la.CurrencyCode)
	LoansRepaid.Add(ctx, 1, currencyAttr)
	LoansRepaidAmount.Add(ctx,
		float64(r.Amount)/minorUnitsPerMajor,
		currencyAttr)

	return r.ToAPI(), nil
}

// repaymentAllocationKey holds, on the repayment row, how the payment was
// spread over the installments, so a resumed repayment applies exactly what
// was allocated when it was recorded.
const repaymentAllocationKey = "allocation"

// allocationOf rebuilds the allocation stored on a repayment row.
func allocationOf(r *models.Repayment) waterfallResult {
	return waterfallResult{
		principalApplied: r.PrincipalApplied,
		interestApplied:  r.InterestApplied,
		feesApplied:      r.FeesApplied,
		penaltiesApplied: r.PenaltiesApplied,
		excessAmount:     r.ExcessAmount,
		status:           loansv1.RepaymentStatus(r.Status),
		entryAllocations: decodeEntryAllocations(r.Properties[repaymentAllocationKey]),
	}
}

func encodeEntryAllocations(entries []repository.EntryAllocation) []any {
	raw, _ := json.Marshal(entries)
	var out []any
	_ = json.Unmarshal(raw, &out)
	return out
}

func decodeEntryAllocations(v any) []repository.EntryAllocation {
	if v == nil {
		return nil
	}
	raw, err := json.Marshal(v)
	if err != nil {
		return nil
	}
	var out []repository.EntryAllocation
	if json.Unmarshal(raw, &out) != nil {
		return nil
	}
	return out
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
			"payment_reference": req.GetPaymentReference(),
			"payer_reference":   req.GetPayerReference(),
			fieldIdempotencyKey: req.GetIdempotencyKey(),
		},
		Parent: &r.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for repayment")
	})
}

// isRepayableStatus reports whether a loan in this status can take money. A
// defaulted loan still can: a borrower paying it back is the recovery the
// status exists for, and paying it in full moves it to PAID_OFF.
func isRepayableStatus(status int32) bool {
	return status == int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE) ||
		status == int32(loansv1.LoanStatus_LOAN_STATUS_DELINQUENT) ||
		status == int32(loansv1.LoanStatus_LOAN_STATUS_DEFAULT) ||
		status == int32(loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED)
}

// afterRepaymentApplied tells the borrower and, when the repayment cleared
// the loan, moves it to PAID_OFF. It runs once, for the call that applied
// the repayment.
func (b *repaymentBusiness) afterRepaymentApplied(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	r *models.Repayment,
	fresh *models.LoanBalance,
) {
	paid := r.PrincipalApplied + r.InterestApplied + r.FeesApplied + r.PenaltiesApplied
	b.notifier.NotifyRepaymentReceived(ctx, la, paid, fresh.TotalOutstanding, r.Channel, r.PaymentReference)

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
	// entryAllocations are what the payment puts onto each installment. They
	// are stored with the repayment and applied only once the ledger has
	// accepted the money, so a failed posting never leaves installments paid.
	entryAllocations []repository.EntryAllocation
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
	// The money reached the borrower's own account first: they paid it from
	// their own contact.
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
		Data: transferorder.Typed(&operationsv1.TransferOrderObject{
			DebitAccountRef:  debitAccount,
			CreditAccountRef: creditAccount,
			Amount:           moneyx.FromMinorUnitsByCurrency(currency, amount),
			Reference:        reference,
			Description:      description,
			ExtraData:        extraData.ToProtoStruct(),
		}, orderType),
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
	share := repository.EntryAllocation{EntryID: entry.GetID()}

	// 1. Interest first
	if owed := entry.InterestDue - entry.InterestPaid; owed > 0 {
		share.Interest = min64(owed, remaining)
		remaining -= share.Interest
	}
	// 2. Fees (insurance + processing)
	if owed := entry.FeesDue - entry.FeesPaid; owed > 0 {
		share.Fees = min64(owed, remaining)
		remaining -= share.Fees
	}
	// 3. Principal last
	if owed := entry.PrincipalDue - entry.PrincipalPaid; owed > 0 {
		share.Principal = min64(owed, remaining)
		remaining -= share.Principal
	}

	result.interestApplied += share.Interest
	result.feesApplied += share.Fees
	result.principalApplied += share.Principal
	if share.Total() > 0 {
		result.entryAllocations = append(result.entryAllocations, share)
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
	if loanID := req.GetLoanAccountId(); loanID != "" {
		if err := authorizeLoanAccount(ctx, b.scope, b.loanAccountRepo, loanID); err != nil {
			return nil, err
		}
		filters["loan_account_id = ?"] = loanID
		return filters, nil
	}

	// Without a loan the search spans the partition, which is for staff.
	if !b.scope.IsStaff(ctx) {
		return nil, ErrLoanNotOwned
	}
	return filters, nil
}

// Repayment channels as stored. Callers send free text; it is folded onto
// these so reports, ledger legs and messages agree on what happened. Cash is
// recognised only to be refused: no one hands over cash for a borrower.
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
