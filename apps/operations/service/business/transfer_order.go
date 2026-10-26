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
	"io"
	"strings"
	"time"

	"connectrpc.com/connect/v2"

	"go.opentelemetry.io/otel/attribute"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	ledgerv1 "buf.build/gen/go/antinvestor/ledger/protocolbuffers/go/v1"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/payment/connectrpc/go/v2/v1/paymentv1connect"
	paymentv1 "buf.build/gen/go/antinvestor/payment/protocolbuffers/go/v1"
	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"
	utilmoney "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/operations/service/events"
	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

// errUnresolvedAccountRef is returned when a transfer order's debit or credit
// account cannot be resolved to a ledger account.
var errUnresolvedAccountRef = errors.New("transfer order account ref could not be resolved to a ledger account")

type transferOrderBusiness struct {
	eventsMan         fevents.Manager
	toRepo            repository.TransferOrderRepository
	csRepo            repository.CBSSyncRecordRepository
	arRepo            repository.AccountRefRepository
	clients           *clients.PlatformClients
	auditWriter       *audit.Writer
	limitsCli         limitsv1connect.LimitsServiceClient
	limitsGateEnabled bool
	limitsGateMode    string
	// locator overrides the payment-service lookup used to confirm an
	// earlier payout; nil means search the configured payment client.
	locator PayoutLocator
}

func NewTransferOrderBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	toRepo repository.TransferOrderRepository,
	csRepo repository.CBSSyncRecordRepository,
	arRepo repository.AccountRefRepository,
	pc *clients.PlatformClients,
	auditWriter *audit.Writer,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsGateEnabled bool,
	limitsGateMode string,
) TransferOrderBusiness {
	return &transferOrderBusiness{
		eventsMan:         eventsMan,
		toRepo:            toRepo,
		csRepo:            csRepo,
		arRepo:            arRepo,
		clients:           pc,
		auditWriter:       auditWriter,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsGateEnabled,
		limitsGateMode:    limitsGateMode,
	}
}

// Save persists a transfer order via the event system.
//
// If the order carries a non-empty Reference, it is treated as an
// idempotency key. A lookup by reference runs first; if a prior row with
// that reference already exists, the incoming order is populated with its
// identifiers and persisted state and no duplicate is emitted. This makes
// the whole Save→Execute pipeline safe to retry end-to-end: repeated calls
// with the same reference converge on a single ledger posting.
func (b *transferOrderBusiness) Save(ctx context.Context, order *models.TransferOrder) error {
	if order.Reference != "" {
		existing, lookupErr := b.toRepo.GetByReference(ctx, order.Reference)
		if lookupErr == nil && existing != nil {
			order.ID = existing.ID
			order.State = existing.State
			order.CreatedAt = existing.CreatedAt
			order.ModifiedAt = existing.ModifiedAt
			order.Version = existing.Version
			return nil
		}
	}

	if order.State == 0 {
		order.State = int32(constants.StateJustCreated)
	}
	order.GenID(ctx)

	// The write is synchronous: Execute reads the row back by id immediately
	// after Save returns, so a queued projection would race the read.
	return b.toRepo.CreateIfAbsent(ctx, order)
}

// Execute processes a transfer order based on its type.
// The execution flow is:
//  1. Load the transfer order from the repository
//  2. Resolve debit/credit account references
//  3. Post the base ledger transaction (debit source, credit destination)
//  4. Run type-specific side effects (e.g. loan repayment notifies Lender)
//  5. Log a CBS sync record for external reconciliation
//  6. Mark the transfer order as completed
//
// When the limits gate is enabled, a reservation is obtained from the limits
// service before execution proceeds. DENY returns an error; PENDING_APPROVAL
// returns PendingApprovalError.
func (b *transferOrderBusiness) Execute(ctx context.Context, orderID string) error {
	if !b.limitsGateEnabled || b.limitsCli == nil || b.limitsGateMode == "off" {
		return b.executeInner(ctx, orderID)
	}

	order, err := b.toRepo.GetByID(ctx, orderID)
	if err != nil {
		return fmt.Errorf("transfer order not found: %w", err)
	}
	// An order allocating a payment the rail received moves money that has
	// already arrived; a limit refusing it would only strand the payer's
	// money. Limits gate money leaving, not money received.
	if extraDataString(order, extraKeySource) == allocationSourceMarker {
		return b.executeInner(ctx, orderID)
	}

	intent := &limitsv1.LimitIntent{
		Action:   limitsv1.LimitAction_LIMIT_ACTION_TRANSFER_ORDER_EXECUTE,
		TenantId: order.TenantID,
		Amount:   minorToMoney(order.Currency, order.Amount),
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT, Id: order.DebitAccountRef},
		},
	}
	idemKey := "operations_transfer:" + orderID

	return limits.Gate(ctx, b.limitsCli, intent, idemKey, limits.ParseMode(b.limitsGateMode),
		func(innerCtx context.Context, reservationID string) error {
			util.Log(innerCtx).With("limits_reservation_id", reservationID).
				Info("transfer order execute gated by limits")
			return b.executeInner(innerCtx, orderID)
		},
		limits.InPartition(order.TenantID, order.PartitionID),
	)
}

// postLedgerOnce posts the ledger leg unless an earlier attempt already did,
// recording the transaction id on the order so no retry posts twice. On
// failure the execution claim is released and the error returned.
func (b *transferOrderBusiness) postLedgerOnce(
	ctx context.Context,
	logger *util.LogEntry,
	order *models.TransferOrder,
) (string, error) {
	orderID := order.GetID()
	if order.LedgerTransactionID != "" {
		logger.WithField("ledger_transaction_id", order.LedgerTransactionID).
			Info("ledger already posted by an earlier attempt, resuming side effects")
		return order.LedgerTransactionID, nil
	}

	debitRef, creditRef := b.resolveAccountRefs(ctx, order)
	ledgerTxnID, err := b.executeBaseLedgerTransfer(ctx, order, debitRef, creditRef)
	if err != nil {
		logger.WithError(err).Error("base ledger transfer failed")
		b.releaseExecution(ctx, logger, orderID, "ledger: "+err.Error())
		return "", err
	}
	if markErr := b.toRepo.MarkLedgerPosted(ctx, orderID, ledgerTxnID); markErr != nil {
		// The ledger dedupes on the order id, so a retry that re-posts
		// converges on the same transaction; the release below is safe.
		logger.WithError(markErr).Error("could not record ledger transaction id")
		b.releaseExecution(ctx, logger, orderID, "record ledger id: "+markErr.Error())
		return "", markErr
	}
	order.LedgerTransactionID = ledgerTxnID
	return ledgerTxnID, nil
}

// claimForExecution takes the order into StateCheckCreated. A fresh order is
// claimed from JustCreated/Active. An order another execution left in
// CheckCreated is resumed only once that execution is stale; while it is
// fresh the caller gets ErrTransferOrderInProgress so it retries later rather
// than racing a live posting.
func (b *transferOrderBusiness) claimForExecution(ctx context.Context, order *models.TransferOrder) error {
	claimed, err := b.toRepo.ClaimState(
		ctx,
		order.GetID(),
		[]int32{int32(constants.StateJustCreated), int32(constants.StateActive)},
		int32(constants.StateCheckCreated),
	)
	if err != nil {
		return fmt.Errorf("could not claim transfer order for execution: %w", err)
	}
	if claimed {
		return nil
	}

	current, err := b.toRepo.GetByID(ctx, order.GetID())
	if err != nil {
		return fmt.Errorf("transfer order not found: %w", err)
	}
	switch current.State {
	case int32(constants.StateInactive), int32(constants.StateDeleted):
		// Finished between our read and our claim: report success through
		// the caller's normal path by re-running the completed guard.
		*order = *current
		return errAlreadyCompleted
	case int32(constants.StateShutdown):
		return ErrTransferOrderFailed
	case int32(constants.StateCheckCreated):
		staleBefore := time.Now().Add(-staleExecutionAfter)
		if current.ModifiedAt.After(staleBefore) {
			return ErrTransferOrderInProgress
		}
		resumed, resumeErr := b.toRepo.ClaimStaleExecution(ctx, order.GetID(), staleBefore)
		if resumeErr != nil {
			return fmt.Errorf("could not resume stale transfer order: %w", resumeErr)
		}
		if !resumed {
			return ErrTransferOrderInProgress
		}
		*order = *current
		util.Log(ctx).WithField("order_id", order.GetID()).
			WithField("stale_since", current.ModifiedAt).
			Warn("resuming transfer order abandoned by an earlier execution")
		return nil
	default:
		return ErrTransferOrderInProgress
	}
}

// errAlreadyCompleted is an internal signal that the order finished while
// this execution was claiming it; Execute maps it to success.
var errAlreadyCompleted = errors.New("transfer order completed by another execution")

// releaseExecution hands the order back to JustCreated after a failed
// attempt. It is best-effort: if the release itself fails the row stays in
// CheckCreated and the stale-execution path resumes it later.
func (b *transferOrderBusiness) releaseExecution(ctx context.Context, logger *util.LogEntry, orderID, reason string) {
	released, err := b.toRepo.ReleaseExecution(ctx, orderID, reason)
	if err != nil {
		logger.WithError(err).Error("could not release transfer order after failure")
		return
	}
	if !released {
		logger.Warn("transfer order was not in the executing state when released")
	}
}

// RecordFailure marks the transfer order behind a reference as failed and
// records why. The workflow compensation step calls it when a ledger transfer
// comes back non-2xx, so the order stops looking executable and an operator
// can see the reason without reading logs.
func (b *transferOrderBusiness) RecordFailure(
	ctx context.Context,
	reference, reason string,
) (map[string]interface{}, error) {
	reference = strings.TrimSpace(reference)
	if reference == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "reference is required")
	}

	order, err := b.toRepo.GetByReference(ctx, reference)
	if err != nil || order == nil {
		return nil, apperrors.ErrDataNotFound.Extend("transfer order")
	}

	if order.State == int32(constants.StateInactive) {
		return map[string]interface{}{
			fieldReference:       reference,
			fieldTransferOrderID: order.GetID(),
			fieldStatus:          "already_completed",
		}, nil
	}

	// An order whose ledger leg posted or whose payout reached the rail has
	// moved money. It cannot be declared failed; it needs a reversal order.
	if order.LedgerPosted() || order.PaymentInitiatedAt != nil {
		return nil, ErrTransferOrderProgressed
	}
	claimed, claimErr := b.toRepo.MarkFailedIfUnposted(ctx, order.GetID())
	if claimErr != nil {
		return nil, claimErr
	}
	if !claimed {
		// Lost a race with an execution that progressed the order between
		// our read and the conditional update.
		return nil, ErrTransferOrderProgressed
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityTransferOrder,
		EntityID:   order.GetID(),
		Action:     "transfer_order.failed",
		Reason:     reason,
		Metadata: data.JSONMap{
			fieldReference: reference,
		},
		Parent: &order.BaseModel,
	}, func(auErr error) {
		util.Log(ctx).WithError(auErr).Warn("audit emission failed for transfer order failure")
	})

	return map[string]interface{}{
		fieldReference:       reference,
		fieldTransferOrderID: order.GetID(),
		fieldStatus:          "recorded",
		"newly_failed":       claimed,
	}, nil
}

// staleExecutionAfter is how long an order may sit in StateCheckCreated before
// a retry treats the previous execution as dead and resumes it. Live
// executions finish in seconds; anything older was interrupted mid-flight.
const staleExecutionAfter = 2 * time.Minute

var (
	// ErrTransferOrderInProgress is returned when another execution currently
	// holds the order. The caller must retry later; it must not treat the
	// order as settled.
	ErrTransferOrderInProgress = apperrors.NewError(apperrors.ServiceUnavailable,
		"transfer order execution is in progress; retry later")
	// ErrTransferOrderFailed is returned for an order an operator or the
	// workflow marked failed through RecordFailure. It will not execute again.
	ErrTransferOrderFailed = apperrors.NewError(apperrors.Unprocessable,
		"transfer order was marked failed and cannot be executed")
	// ErrTransferOrderProgressed is returned when a caller tries to mark an
	// order failed after its ledger leg posted or its payout reached the
	// rail. Money has moved; the remedy is a reversal order, not a flag.
	ErrTransferOrderProgressed = apperrors.NewError(apperrors.Unprocessable,
		"transfer order has already moved money and cannot be marked failed; reverse it instead")
	// ErrPayoutPendingConfirmation is returned while an earlier attempt's
	// payout is being confirmed with the payment service. The order is not
	// settled; the caller retries later.
	ErrPayoutPendingConfirmation = apperrors.NewError(apperrors.ServiceUnavailable,
		"payout from an earlier attempt is awaiting confirmation; retry later")
	// ErrPayoutFailed is returned when the payment rail reports the payout as
	// failed after the ledger leg posted. The order is not settled and must
	// not be resent; it needs a reversal or re-route by an operator.
	ErrPayoutFailed = apperrors.NewError(apperrors.Unprocessable,
		"payout failed at the payment rail after the ledger posted; reverse or re-route the order")
)

// payoutConfirmationGrace is how long after an unconfirmed payout claim the
// payment service is given to show the payment before the claim is treated
// as never having reached the rail. The payment service persists a Send
// through its queue, so a lookup right after an ambiguous error can miss a
// payment that did land.
const payoutConfirmationGrace = 10 * time.Minute

// PayoutLocator finds a payout the payment service holds for an order
// reference. It is the slice of the payment client sendPayment needs to
// confirm an earlier attempt without sending again.
type PayoutLocator interface {
	FindByReference(ctx context.Context, reference string) (*paymentv1.Payment, error)
}

// connectPayoutLocator searches the payment service by reference id.
type connectPayoutLocator struct {
	cli paymentv1connect.PaymentServiceClient
}

func (l connectPayoutLocator) FindByReference(ctx context.Context, reference string) (*paymentv1.Payment, error) {
	stream, err := l.cli.Search(ctx, commonv1.SearchRequest_builder{
		Query:      reference,
		Properties: []string{"reference_id"},
		Cursor:     commonv1.PageCursor_builder{Limit: payoutSearchLimit}.Build(),
	}.Build())
	if err != nil {
		return nil, err
	}
	defer func() { _ = stream.Close() }()
	seen := 0
	for {
		msg, recvErr := stream.Receive()
		if recvErr != nil {
			if errors.Is(recvErr, io.EOF) {
				break
			}
			return nil, recvErr
		}
		for _, p := range msg.GetData() {
			seen++
			if p.GetReferenceId() == reference {
				return p, nil
			}
		}
	}

	if seen > 0 {
		// The search ORs a text match with the exact reference filter, so
		// any result set that holds other payments but not ours may have
		// crowded ours out. Only an empty answer means "not found": "not
		// found" licenses a resend, "inconclusive" does not.
		return nil, ErrPayoutLookupInconclusive
	}
	return nil, nil //nolint:nilnil // no payment is a valid answer, not an error
}

// ErrPayoutLookupInconclusive is returned when the payment service search
// could not rule a payout in or out; the caller keeps waiting.
var ErrPayoutLookupInconclusive = errors.New("payout lookup inconclusive: results returned without the reference")

const payoutSearchLimit = 100

// executeInner runs the core transfer order execution logic after any gate check.
//
// The order is a small state machine the caller may drive any number of
// times with the same reference:
//
//	JustCreated/Active ──claim──▶ CheckCreated ──ledger, side effects──▶ Inactive
//	        ▲                          │
//	        └──────release on error────┘
//
// Every failure releases the claim and returns the error, so a retry
// re-enters instead of being told the order is done. Progress that already
// cost money is remembered on the row: a posted ledger transaction id means
// the ledger leg is skipped on resume, and a claimed payment initiation means
// the payout is never sent twice. Only reaching StateInactive is success;
// callers must treat every returned error as "not settled".
func (b *transferOrderBusiness) executeInner(ctx context.Context, orderID string) error {
	logger := util.Log(ctx).WithField("method", "TransferOrderBusiness.Execute").
		WithField("order_id", orderID)

	order, err := b.toRepo.GetByID(ctx, orderID)
	if err != nil {
		return fmt.Errorf("transfer order not found: %w", err)
	}

	orderType := int(order.OrderType)
	typeName := constants.TransferTypeName(orderType)
	logger = logger.WithField("order_type", typeName)

	switch order.State {
	case int32(constants.StateInactive), int32(constants.StateDeleted):
		logger.Info("transfer order already completed, skipping")
		return nil
	case int32(constants.StateShutdown):
		return ErrTransferOrderFailed
	}

	if err = b.claimForExecution(ctx, order); err != nil {
		if errors.Is(err, errAlreadyCompleted) {
			logger.Info("transfer order completed by another execution")
			return nil
		}
		return err
	}
	order.State = int32(constants.StateCheckCreated)

	logger.Info("executing transfer order")

	// A payout is addressed before any money moves: an order whose
	// recipient or destination does not check out never posts its ledger leg.
	if err = b.checkPayoutRecipient(ctx, logger, order); err != nil {
		return err
	}

	ledgerTxnID, err := b.postLedgerOnce(ctx, logger, order)
	if err != nil {
		return err
	}

	if sideEffectErr := b.dispatchSideEffect(ctx, logger, orderType, order); sideEffectErr != nil {
		logger.WithError(sideEffectErr).Error("side effect failed")
		return b.failSideEffect(ctx, logger, order, "side effect: "+sideEffectErr.Error(), sideEffectErr)
	}

	// Step 5: Log CBS sync record for external reconciliation. The ledger
	// transaction id captured above goes into the record so reconciliation
	// has a direct link from the local transfer order to the posted ledger
	// entry.
	if syncErr := b.logCBSSyncRecord(ctx, order, ledgerTxnID); syncErr != nil {
		logger.WithError(syncErr).Warn("CBS sync record logging failed (non-fatal)")
	}

	// Step 6: Mark the transfer order as completed. An order whose payout
	// the rail rejected never completes; it is released for a reversal.
	if order.PayoutFailed() {
		return b.failSideEffect(ctx, logger, order, "payout failed at the payment rail", ErrPayoutFailed)
	}
	done, doneErr := b.toRepo.ClaimState(
		ctx,
		orderID,
		[]int32{int32(constants.StateCheckCreated)},
		int32(constants.StateInactive),
	)
	if doneErr != nil {
		logger.WithError(doneErr).Error("could not update transfer order state")
		return doneErr
	}
	if !done {
		// Someone else moved the row while we held it. The ledger id is
		// persisted, so whichever execution finishes converges on one posting.
		logger.Warn("transfer order left the executing state during completion")
		return ErrTransferOrderInProgress
	}
	order.State = int32(constants.StateInactive)

	// Step 7: Audit. Captures every successful money movement in one
	// descriptive record for later tracing. Best-effort: we don't fail
	// the operation if audit recording fails because the money has
	// already moved and the primary record of it lives in transfer_orders.
	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityTransferOrder,
		EntityID:   order.GetID(),
		Action:     "transfer_order.executed",
		Reason:     fmt.Sprintf("posted %s ledger transaction", typeName),
		After: data.JSONMap{
			fieldState:              "inactive",
			"ledger_transaction_id": ledgerTxnID,
		},
		Metadata: data.JSONMap{
			"order_type":         orderType,
			"order_type_name":    typeName,
			fieldAmount:          order.Amount,
			fieldCurrency:        order.Currency,
			"debit_account_ref":  order.DebitAccountRef,
			"credit_account_ref": order.CreditAccountRef,
			fieldReference:       order.Reference,
		},
		Parent: &order.BaseModel,
	}, func(err error) {
		logger.WithError(err).Warn("audit record emission failed for transfer order")
	})

	currencyAttr := attribute.String("currency", order.Currency)
	OpsTransfersExecuted.Add(ctx, 1, currencyAttr)
	OpsTransfersAmount.Add(ctx, float64(order.Amount)/minorUnitsPerMajor, currencyAttr)

	logger.Info("transfer order executed successfully")
	return nil
}

// transferHandler is the signature for side-effect handlers that may return an error.
type transferHandler func(ctx context.Context, order *models.TransferOrder) error

// noErr wraps a void handler into a transferHandler returning nil.
func noErr(fn func(ctx context.Context, order *models.TransferOrder)) transferHandler {
	return func(ctx context.Context, order *models.TransferOrder) error {
		fn(ctx, order)
		return nil
	}
}

// sideEffectHandlers returns a dispatch map from order type to handler.
func (b *transferOrderBusiness) sideEffectHandlers() map[int]transferHandler {
	return map[int]transferHandler{
		constants.TransferTypeLoan:                                      b.handleLoanDisbursement,
		constants.TransferTypeLoanRepayment:                             b.handleLoanRepayment,
		constants.TransferTypeLoanInterest:                              noErr(b.handleLoanInterest),
		constants.TransferTypeLoanInterestRepayment:                     noErr(b.handleLoanInterestRepayment),
		constants.TransferTypeLoanInsurance:                             noErr(b.handleLoanInsurance),
		constants.TransferTypeLoanInsuranceRepayment:                    noErr(b.handleLoanInsuranceRepayment),
		constants.TransferTypeDisbursement:                              b.handleDisbursement,
		constants.TransferTypeDisbursementReversal:                      noErr(b.handleDisbursementReversal),
		constants.TransferTypeDisbursementReversalReroute:               b.handleDisbursementReversalReroute,
		constants.TransferTypePeriodicSaving:                            noErr(b.handlePeriodicSaving),
		constants.TransferTypePeriodicSavingRecovery:                    noErr(b.handlePeriodicSavingRecovery),
		constants.TransferTypePeriodicSavingsInterestIncomeDistribution: noErr(b.handleSavingsInterestDistribution),
		constants.TransferTypeRegistrationFee:                           noErr(b.handleRegistrationFee),
		constants.TransferTypeTerminalDisbursement:                      b.handleTerminalDisbursement,
		constants.TransferTypeTerminalDisbursementRecovery:              noErr(b.handleTerminalDisbursementRecovery),
		constants.TransferTypePayment:                                   noErr(b.handlePaymentOutflow),
		constants.TransferTypePaymentIdentified:                         noErr(b.handlePaymentIdentified),
		constants.TransferTypePaymentAllocated:                          noErr(b.handlePaymentAllocated),
		constants.TransferTypePenalty:                                   noErr(b.handlePenalty),
		constants.TransferTypePenaltyCancel:                             noErr(b.handlePenaltyCancel),
		constants.TransferTypePenaltyRepayment:                          noErr(b.handlePenaltyRepayment),
		constants.TransferTypePenaltyIncomeDistribution:                 noErr(b.handlePenaltyIncomeDistribution),
		constants.TransferTypeCost:                                      noErr(b.handleCost),
		constants.TransferTypeServiceFee:                                noErr(b.handleServiceFee),
		constants.TransferTypeLoanFundingExternalLending:                noErr(b.handleExternalLending),
		constants.TransferTypeLoanFundingExternalLendingPayback:         b.handleExternalLendingPayback,
		constants.TransferTypeShutdownLoanRecovery:                      noErr(b.handleShutdownLoanRecovery),
		constants.TransferTypeInterSubscriptionPayment:                  noErr(b.handleInterSubscriptionPayment),
		constants.TransferTypeLoanInterestIncomeDistribution:            noErr(b.handleLoanInterestIncomeDistribution),
		constants.TransferTypeInvestorDeployment:                        noErr(b.handleInvestorDeployment),
		constants.TransferTypeInvestorPrincipalReturn:                   noErr(b.handleInvestorPrincipalReturn),
		constants.TransferTypeInvestorWithdrawal:                        b.handleInvestorWithdrawal,
		constants.TransferTypeInvestorIncomeDistribution:                noErr(b.handleInvestorIncomeDistribution),
		constants.TransferTypePlatformFirstLossAbsorption:               noErr(b.handlePlatformFirstLossAbsorption),
		constants.TransferTypeInvestorLossAbsorption:                    noErr(b.handleInvestorLossAbsorption),
		constants.TransferTypeAgentCommission:                           noErr(b.handleAgentCommission),
		constants.TransferTypeTeamCommissionPayout:                      b.handleTeamCommissionPayout,
	}
}

// dispatchSideEffect looks up and executes the type-specific side effect handler.
func (b *transferOrderBusiness) dispatchSideEffect(
	ctx context.Context,
	logger *util.LogEntry,
	orderType int,
	order *models.TransferOrder,
) error {
	handler, ok := b.sideEffectHandlers()[orderType]
	if !ok {
		logger.Warn("unknown transfer order type, executing base transfer only")
		return nil
	}
	return handler(ctx, order)
}

// resolveAccountRefs looks up the debit and credit AccountRef records for the
// transfer order. The order stores account ref IDs; this method resolves them
// to the full AccountRef objects so downstream logic has access to ledger IDs.
func (b *transferOrderBusiness) resolveAccountRefs(
	ctx context.Context,
	order *models.TransferOrder,
) (*models.AccountRef, *models.AccountRef) {
	var debitRef, creditRef *models.AccountRef

	if order.DebitAccountRef != "" {
		debitRef = b.resolveAccountRef(ctx, order.DebitAccountRef, order.Currency)
	}

	if order.CreditAccountRef != "" {
		creditRef = b.resolveAccountRef(ctx, order.CreditAccountRef, order.Currency)
	}

	return debitRef, creditRef
}

// resolveAccountRef loads an AccountRef, falling back to treating the id as a
// ledger account name. The fallback only applies to a genuine miss: a database
// failure must not silently post against a fabricated account.
func (b *transferOrderBusiness) resolveAccountRef(
	ctx context.Context,
	refID string,
	currency string,
) *models.AccountRef {
	ref, err := b.arRepo.GetByID(ctx, refID)
	if err == nil && ref != nil {
		return ref
	}
	if err != nil && !data.ErrorIsNoRows(err) {
		util.Log(ctx).WithError(err).WithField("account_ref", refID).
			Error("could not load account ref")
		return nil
	}

	return &models.AccountRef{
		Reference: refID,
		Currency:  currency,
		LedgerID:  refID,
		Properties: data.JSONMap{
			"synthetic": true,
		},
	}
}

// executeBaseLedgerTransfer posts a double-entry transaction to the Ledger service.
// It debits the source account and credits the destination account for the
// transfer amount. When the Ledger client is available this will make the
// actual API call; until then it logs the intent.
func (b *transferOrderBusiness) executeBaseLedgerTransfer(
	ctx context.Context,
	order *models.TransferOrder,
	debitRef, creditRef *models.AccountRef,
) (string, error) {
	logger := util.Log(ctx).WithField("method", "executeBaseLedgerTransfer").
		WithField("order_id", order.GetID())

	debitLedgerID := ""
	creditLedgerID := ""
	if debitRef != nil {
		debitLedgerID = debitRef.LedgerID
	}
	if creditRef != nil {
		creditLedgerID = creditRef.LedgerID
	}

	// An order that names an account but resolves to no ledger id would post a
	// half-formed entry. Refuse instead of writing it.
	if debitLedgerID == "" || creditLedgerID == "" {
		return "", errUnresolvedAccountRef
	}

	logger.WithField("debit_ledger", debitLedgerID).
		WithField("credit_ledger", creditLedgerID).
		WithField("amount", order.Amount).
		WithField("currency", order.Currency).
		Info("posting ledger transaction")

	if b.clients.LedgerClient == nil {
		return "", errors.New("ledger client is not configured; refusing to post transfer order")
	}

	amt := minorToMoney(order.Currency, order.Amount)

	req := (&ledgerv1.CreateTransactionRequest_builder{
		Id:       order.GetID(),
		Currency: order.Currency,
		Entries: []*ledgerv1.TransactionEntry{
			(&ledgerv1.TransactionEntry_builder{
				AccountId: debitLedgerID,
				Amount:    amt,
				Credit:    false,
			}).Build(),
			(&ledgerv1.TransactionEntry_builder{
				AccountId: creditLedgerID,
				Amount:    amt,
				Credit:    true,
			}).Build(),
		},
		Cleared: true,
		Type:    ledgerv1.TransactionType_NORMAL,
	}).Build()

	resp, err := b.clients.LedgerClient.CreateTransaction(ctx, req)
	if connect.CodeOf(err) == connect.CodeNotFound {
		// A platform account is posted to for the first time: create the
		// chart accounts the ledger lacks and post once more.
		b.ensureChartAccounts(ctx, order, debitRef, creditRef)
		resp, err = b.clients.LedgerClient.CreateTransaction(ctx, req)
	}
	if err != nil {
		return "", fmt.Errorf("ledger CreateTransaction failed: %w", err)
	}

	// Capture the posted transaction's id so downstream audit records link
	// back to the ledger entry. The ledger service dedupes on the request id
	// (which is order.GetID()) so retries return the same transaction id.
	var ledgerTxnID string
	if txn := resp.GetData(); txn != nil {
		ledgerTxnID = txn.GetId()
	}
	return ledgerTxnID, nil
}

// logCBSSyncRecord persists an audit row linking this transfer order to the
// posted ledger transaction. The ledgerTxnID from the CreateTransaction
// response is stored so reconciliation can cross-reference local state with
// the external ledger without having to re-resolve via the request id.
func (b *transferOrderBusiness) logCBSSyncRecord(
	ctx context.Context,
	order *models.TransferOrder,
	ledgerTxnID string,
) error {
	cbsStatus := "posted"
	if ledgerTxnID == "" {
		cbsStatus = "unknown"
	}
	record := &models.CBSSyncRecord{
		OwnerID:          order.DebitAccountRef,
		OwnerType:        "transfer_order",
		OrderType:        order.OrderType,
		TransactionID:    order.GetID(),
		CBSTransactionID: ledgerTxnID,
		CBSStatus:        cbsStatus,
		Amount:           order.Amount,
		Currency:         order.Currency,
		LedgerID:         ledgerTxnID,
		State:            int32(constants.StateActive),
	}
	record.GenID(ctx)
	record.CopyPartitionInfo(&order.BaseModel)

	if err := b.eventsMan.Emit(ctx, events.CBSSyncRecordSaveEvent, record); err != nil {
		return fmt.Errorf("emit CBS sync record: %w", err)
	}
	return nil
}

// minorToMoney converts a minor-unit int64 amount and currency code to a
// google.type.Money protobuf value using the currency's ISO-4217 exponent.
func minorToMoney(currency string, amount int64) *commonv1.Money {
	return utilmoney.FromMinorUnitsByCurrency(currency, amount)
}

// sendPayment is a helper that calls PaymentClient.Send with common parameters.
// It returns nil if PaymentClient is not configured (graceful degradation).
func (b *transferOrderBusiness) sendPayment(
	ctx context.Context,
	order *models.TransferOrder,
	recipientID string,
	route string,
) error {
	if b.clients == nil || b.clients.PaymentClient == nil {
		return errPaymentClientUnavailable
	}

	// A payout already marked failed is never sent; it is reversed.
	if order.PayoutFailed() {
		return ErrPayoutFailed
	}

	profileID, destination, recipientErr := b.payoutRecipient(ctx, order, recipientID)
	unsendable := errors.Is(recipientErr, ErrPayoutRecipientUnresolved) ||
		errors.Is(recipientErr, ErrPayoutDestinationNotRecipient)
	if recipientErr != nil && !unsendable {
		return recipientErr
	}
	if recipientErr == nil {
		order.SetPayoutTarget(profileID, route, destination)
	}

	// Claim the payout exactly once. The payment service does not dedupe on
	// our reference, so a resumed execution that finds the claim taken must
	// not send again blindly: the earlier attempt may have reached the rail,
	// and confirmEarlierPayout settles which it was.
	claimed, err := b.toRepo.ClaimPaymentInitiation(ctx, order.GetID())
	if err != nil {
		return fmt.Errorf("claim payment initiation: %w", err)
	}
	if !claimed {
		if unsendable {
			// An earlier attempt may already have paid out; a recipient that
			// no longer checks out is no proof it did not. Never reverse on
			// that basis: wait for the payment service's word.
			return fmt.Errorf("%w: %s", ErrPayoutPendingConfirmation, recipientErr.Error())
		}
		return b.confirmEarlierPayout(ctx, order)
	}
	if unsendable {
		// This attempt holds the first claim, so nothing was ever sent, and
		// the claim now bars any later send. Only a durable failure mark
		// licenses the reversal.
		if markErr := b.toRepo.MarkPayoutFailed(ctx, order.GetID(), "", recipientErr.Error()); markErr != nil {
			return fmt.Errorf("%w: record unsendable payout: %s", ErrPayoutPendingConfirmation, markErr.Error())
		}
		order.PayoutStatus = models.PayoutStatusFailed
		return fmt.Errorf("%w: %s", ErrPayoutFailed, recipientErr.Error())
	}

	return b.sendPayoutNow(ctx, order)
}

// sendPayoutNow calls the payment rail for an order whose payout claim this
// attempt holds, and records the payment id the rail returns.
func (b *transferOrderBusiness) sendPayoutNow(ctx context.Context, order *models.TransferOrder) error {
	recipientID := order.PayoutRecipient()
	route := order.PayoutRoute()
	req := (&paymentv1.SendRequest_builder{
		Data: (&paymentv1.Payment_builder{
			ReferenceId: order.Reference,
			Route:       route,
			Recipient: (&commonv1.ContactLink_builder{
				ProfileId: recipientID,
				ContactId: order.PayoutDestination(),
			}).Build(),
			Amount:   minorToMoney(order.Currency, order.Amount),
			Outbound: true,
		}).Build(),
	}).Build()

	resp, err := b.clients.PaymentClient.Send(ctx, req)
	if err != nil {
		// The claim stays: we cannot tell whether the rail accepted the
		// request before the error. Reconciliation against the payment
		// service by reference settles it; a blind resend could pay twice.
		// The rail's own code is not passed on: whatever it said, money
		// may be in flight, so the caller only ever sees a retryable error.
		return fmt.Errorf("%w: payment send failed: %s", ErrPayoutPendingConfirmation, err.Error())
	}
	status := resp.GetData()
	if status == nil {
		return nil
	}
	if status.GetStatus() == commonv1.STATUS_FAILED {
		// Rejected synchronously by the rail: record it so no retry can
		// complete or resend this order; it needs a reversal.
		if markErr := b.toRepo.MarkPayoutFailed(ctx, order.GetID(), status.GetId(),
			"payout rejected by the payment rail"); markErr != nil {
			util.Log(ctx).WithError(markErr).WithField("order_id", order.GetID()).
				Error("could not record rejected payout on transfer order")
		}
		order.PayoutStatus = models.PayoutStatusFailed
		return ErrPayoutFailed
	}
	if status.GetId() != "" {
		if recErr := b.toRepo.RecordPaymentID(ctx, order.GetID(), status.GetId()); recErr != nil {
			util.Log(ctx).WithError(recErr).WithField("order_id", order.GetID()).
				Warn("could not record payment id on transfer order")
		}
	}
	return nil
}

var errPaymentClientUnavailable = errors.New("payment client is not configured; refusing to execute a payout order")

// confirmEarlierPayout settles what an earlier attempt's payout claim means
// when this attempt finds it taken. A recorded payment id means the rail
// accepted it: nothing more to send. Otherwise the payment service is asked
// whether it holds a payment for the order reference; if it does, its id is
// recorded and the payout counts as initiated. If it does not and the claim
// is older than the confirmation grace, the Send never landed and the claim
// is cleared so this attempt may send. Within the grace, or when the lookup
// fails, the order is left unsettled and the caller retries later.
func (b *transferOrderBusiness) confirmEarlierPayout(ctx context.Context, order *models.TransferOrder) error {
	logger := util.Log(ctx).WithField("order_id", order.GetID())

	current, err := b.toRepo.GetByID(ctx, order.GetID())
	if err != nil {
		return fmt.Errorf("reload transfer order: %w", err)
	}
	if current.PayoutFailed() {
		return ErrPayoutFailed
	}

	// A recorded payment id says the rail accepted the request, not that the
	// payout succeeded. Ask the payment service for its current word.
	payment, err := b.payoutLocator().FindByReference(ctx, order.Reference)
	if err != nil {
		logger.WithError(err).Warn("could not confirm earlier payout with the payment service")
		return ErrPayoutPendingConfirmation
	}
	if payment != nil {
		if current.PaymentID != "" && payment.GetId() != current.PaymentID {
			// The service answered with a different payment for our
			// reference. Not ours to act on either way; keep waiting.
			logger.WithFields(map[string]any{
				"recorded_payment_id": current.PaymentID,
				"found_payment_id":    payment.GetId(),
			}).Warn("payout lookup returned a payment other than the recorded one")
			return ErrPayoutPendingConfirmation
		}
		if current.PaymentID == "" && !payoutMatchesOrder(payment, order) {
			logger.WithField("found_payment_id", payment.GetId()).
				Warn("payout lookup returned a payment that does not match the order")
			return ErrPayoutPendingConfirmation
		}
		return b.settleFoundPayout(ctx, logger, order, current, payment)
	}
	if current.PaymentID != "" {
		// We hold an id the service no longer shows: not something to act on
		// blindly either way. Keep waiting for a conclusive answer.
		logger.WithField("payment_id", current.PaymentID).Warn("recorded payout not found at the payment service")
		return ErrPayoutPendingConfirmation
	}

	if current.PaymentInitiatedAt == nil {
		// Cleared between our claim attempt and now; the next attempt claims.
		return ErrPayoutPendingConfirmation
	}
	observed := *current.PaymentInitiatedAt
	if time.Since(observed) < payoutConfirmationGrace {
		return ErrPayoutPendingConfirmation
	}

	// Compare-and-swap on the stale claim: every resumer that saw the same
	// timestamp races on one UPDATE and exactly one wins the right to send.
	retaken, err := b.toRepo.RetakePaymentInitiation(ctx, order.GetID(), observed)
	if err != nil {
		return fmt.Errorf("retake stale payout claim: %w", err)
	}
	if !retaken {
		return ErrPayoutPendingConfirmation
	}
	logger.Warn("earlier payout never reached the payment service; claim retaken, sending now")
	return b.sendPayoutNow(ctx, order)
}

// settleFoundPayout interprets the payment the service holds for the order.
func (b *transferOrderBusiness) settleFoundPayout(
	ctx context.Context,
	logger *util.LogEntry,
	order, current *models.TransferOrder,
	payment *paymentv1.Payment,
) error {
	if payment.GetStatus() == commonv1.STATUS_FAILED {
		// The rail took the request and rejected it: the ledger leg is
		// posted but no cash reached the recipient. This is not settled
		// and must not be resent blindly; it needs a reversal or a
		// re-route by an operator. The marker, claim and payment id stay
		// so the order can neither complete nor pay twice meanwhile.
		if markErr := b.toRepo.MarkPayoutFailed(ctx, order.GetID(), payment.GetId(),
			"payout failed at the payment rail"); markErr != nil {
			logger.WithError(markErr).Error("could not record failed payout on transfer order")
		}
		order.PayoutStatus = models.PayoutStatusFailed
		logger.WithField("payment_id", payment.GetId()).Error("earlier payout failed at the payment rail")
		return ErrPayoutFailed
	}
	if current.PaymentID == "" {
		if recErr := b.toRepo.RecordPaymentID(ctx, order.GetID(), payment.GetId()); recErr != nil {
			logger.WithError(recErr).Warn("could not record confirmed payment id")
		}
	}
	logger.WithField("payment_id", payment.GetId()).Info("earlier payout confirmed by the payment service")
	return nil
}

// payoutMatchesOrder checks a payment found by reference really is this
// order's payout: outbound, same currency and amount.
func payoutMatchesOrder(payment *paymentv1.Payment, order *models.TransferOrder) bool {
	if payment == nil || !payment.GetOutbound() {
		return false
	}
	amt := payment.GetAmount()
	if amt == nil {
		return false
	}
	if !strings.EqualFold(amt.GetCurrencyCode(), order.Currency) {
		return false
	}
	return utilmoney.ToInt64(amt, utilmoney.Decimals(order.Currency)) == order.Amount
}

func (b *transferOrderBusiness) payoutLocator() PayoutLocator {
	if b.locator != nil {
		return b.locator
	}
	return connectPayoutLocator{cli: b.clients.PaymentClient}
}

// extraDataString safely extracts a string value from the order's ExtraData map.
func extraDataString(order *models.TransferOrder, key string) string {
	if order.ExtraData == nil {
		return ""
	}
	v, ok := order.ExtraData[key]
	if !ok {
		return ""
	}
	s, _ := v.(string)
	return s
}

// ---------------------------------------------------------------------------
// Loan-related handlers
// ---------------------------------------------------------------------------

// handleLoanDisbursement processes a loan disbursement transfer.
// Debit: subscription loans account -> Credit: group bank account.
// Side effect: initiates the actual payment disbursement to the member.
func (b *transferOrderBusiness) handleLoanDisbursement(ctx context.Context, order *models.TransferOrder) error {
	logger := util.Log(ctx).WithField("handler", "handleLoanDisbursement").
		WithField("order_id", order.GetID())

	memberID := extraDataString(order, "member_id")
	loanID := extraDataString(order, fieldLoanID)

	logger.WithField("member_id", memberID).
		WithField(fieldLoanID, loanID).
		Info("loan disbursement: creating payment initiation for member payout")

	if err := b.sendPayment(ctx, order, memberID, "loan_disbursement"); err != nil {
		return fmt.Errorf("loan disbursement payment for member %s: %w", memberID, err)
	}

	return nil
}

// recordRepaymentWithLender records an allocated group payment as a repayment
// on the loans service. The ledger leg has already posted and is retained on
// the order, so a failure here returns an error: the claim is released and
// the order retries the lender call alone. The order reference is the
// idempotency key, so a retry after a late success records one repayment.
func (b *transferOrderBusiness) recordRepaymentWithLender(
	ctx context.Context,
	logger *util.LogEntry,
	order *models.TransferOrder,
	loanID string,
) error {
	if b.clients == nil || b.clients.LenderLoanMgmt == nil {
		return errors.New("record loan repayment with lender: loans client not configured")
	}
	// Group allocations come out of the member's savings; a matched
	// borrower payment says how it arrived.
	channel := extraDataString(order, extraRepaymentChannel)
	if channel == "" {
		channel = "savings"
	}
	_, err := b.clients.LenderLoanMgmt.RepaymentRecord(ctx, &loansv1.RepaymentRecordRequest{
		LoanAccountId:    loanID,
		Amount:           minorToMoney(order.Currency, order.Amount),
		PaymentReference: order.Reference,
		Channel:          channel,
		PayerReference:   extraDataString(order, fieldPayerReference),
		IdempotencyKey:   order.Reference,
	})
	if err != nil {
		return fmt.Errorf("record loan repayment with lender for loan %s: %w", loanID, err)
	}
	logger.WithField(fieldLoanID, loanID).Info("loan repayment recorded with the lender")
	return nil
}

// handleLoanRepayment processes a loan principal repayment transfer. An order
// raised from a payment allocation is recorded with the lender; the lender's
// own repayment orders need nothing beyond the ledger posting.
func (b *transferOrderBusiness) handleLoanRepayment(
	ctx context.Context,
	order *models.TransferOrder,
) error {
	logger := util.Log(ctx).WithField("handler", "handleLoanRepayment").
		WithField("order_id", order.GetID())

	loanID := extraDataString(order, fieldLoanID)

	// A group member's payment allocated to their loan must reach the loans
	// service, or the loan never shows the repayment. Only orders this
	// service raised from a payment allocation (server-set source marker) are
	// fed back; the order reference is the idempotency key, so a replayed
	// order records one repayment. The loans service then raises its own
	// repayment orders for it.
	if loanID != "" && extraDataString(order, extraKeySource) == allocationSourceMarker {
		return b.recordRepaymentWithLender(ctx, logger, order, loanID)
	}

	// Every other repayment order was raised by the loans service, which
	// shares the repayment out to the loan's funders through the funding
	// service once the repayment is recorded. Nothing more happens here.
	logger.Debug("loan repayment order posted")
	return nil
}

// handleLoanInterest processes a loan interest charge transfer.
// Debit: group bank -> Credit: group interest income account.
// No external side effect beyond the base ledger posting.
func (b *transferOrderBusiness) handleLoanInterest(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleLoanInterest").
		WithField("order_id", order.GetID())
	logger.Info("loan interest charge posted")
}

// handleLoanInterestRepayment processes a loan interest repayment.
// Debit: member suspense -> Credit: interest account.
// Side effect: records the interest repayment in Lender.
func (b *transferOrderBusiness) handleLoanInterestRepayment(
	ctx context.Context,
	order *models.TransferOrder,
) {
	// Funders' shares of interest are moved by the funding service when the
	// loans service applies the repayment; see handleLoanRepayment.
	util.Log(ctx).WithField("handler", "handleLoanInterestRepayment").
		WithField("order_id", order.GetID()).
		WithField(fieldLoanID, extraDataString(order, fieldLoanID)).
		Debug("loan interest repayment posted")
}

// handleLoanInsurance processes a loan insurance charge.
// Debit: group bank -> Credit: product insurance account.
// No external side effect beyond the base ledger posting.
func (b *transferOrderBusiness) handleLoanInsurance(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleLoanInsurance").
		WithField("order_id", order.GetID())
	logger.Info("loan insurance charge posted")
}

// handleLoanInsuranceRepayment processes a loan insurance repayment.
// Debit: member suspense -> Credit: insurance account.
func (b *transferOrderBusiness) handleLoanInsuranceRepayment(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleLoanInsuranceRepayment").
		WithField("order_id", order.GetID())
	logger.WithField("loan_request_id", extraDataLoanRequestID(order)).
		Info("loan fee repayment posted")
}

// handleDisbursement processes an external disbursement via the payment service.
// This is the actual money-out to the member's external account/mobile wallet.
func (b *transferOrderBusiness) handleDisbursement(ctx context.Context, order *models.TransferOrder) error {
	logger := util.Log(ctx).WithField("handler", "handleDisbursement").
		WithField("order_id", order.GetID())

	recipientID := extraDataString(order, "recipient_id")
	paymentChannel := extraDataString(order, "payment_channel")

	logger.WithField("recipient_id", recipientID).
		WithField("payment_channel", paymentChannel).
		Info("initiating external disbursement")

	route := paymentChannel
	if route == "" {
		route = "disbursement"
	}

	if err := b.sendPayment(ctx, order, recipientID, route); err != nil {
		return fmt.Errorf("disbursement payment for recipient %s: %w", recipientID, err)
	}

	return nil
}

// handleDisbursementReversal reverses a failed disbursement.
// Credit goes back to group bank from the disbursement holding account.
func (b *transferOrderBusiness) handleDisbursementReversal(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleDisbursementReversal").
		WithField("order_id", order.GetID())

	originalOrderID := extraDataString(order, "original_order_id")

	logger.WithField("original_order_id", originalOrderID).
		Info("disbursement reversal processed")
}

// handleDisbursementReversalReroute processes a disbursement reversal that is
// rerouted to a different payment channel or account.
func (b *transferOrderBusiness) handleDisbursementReversalReroute(
	ctx context.Context,
	order *models.TransferOrder,
) error {
	logger := util.Log(ctx).WithField("handler", "handleDisbursementReversalReroute").
		WithField("order_id", order.GetID())

	originalOrderID := extraDataString(order, "original_order_id")
	newChannel := extraDataString(order, "new_payment_channel")

	recipientID := extraDataString(order, "recipient_id")

	logger.WithField("original_order_id", originalOrderID).
		WithField("new_channel", newChannel).
		Info("disbursement reversal rerouted to new channel")

	route := newChannel
	if route == "" {
		route = "disbursement_reroute"
	}

	if err := b.sendPayment(ctx, order, recipientID, route); err != nil {
		return fmt.Errorf("rerouted disbursement for recipient %s: %w", recipientID, err)
	}

	return nil
}

// ---------------------------------------------------------------------------
// Savings-related handlers
// ---------------------------------------------------------------------------

// handlePeriodicSaving processes a periodic savings deposit.
// Debit: member suspense -> Credit: member periodic savings.
// Side effect: records the deposit in Lender savings.
func (b *transferOrderBusiness) handlePeriodicSaving(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handlePeriodicSaving").
		WithField("order_id", order.GetID())

	memberID := extraDataString(order, "member_id")
	savingsAccountID := extraDataString(order, "savings_account_id")

	logger.WithField("member_id", memberID).
		WithField("savings_account_id", savingsAccountID).
		WithField("amount", order.Amount).
		Info("recording periodic savings deposit")

	// Savings deposit recording is handled by the savings app via its own event
	// pipeline. The operations app manages the ledger posting which handles the
	// accounting side of the deposit.
}

// handlePeriodicSavingRecovery processes a recovery transfer for a missed periodic saving.
// The member is being charged for previously missed savings contributions.
func (b *transferOrderBusiness) handlePeriodicSavingRecovery(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handlePeriodicSavingRecovery").
		WithField("order_id", order.GetID())

	memberID := extraDataString(order, "member_id")
	periodID := extraDataString(order, "period_id")

	logger.WithField("member_id", memberID).
		WithField("period_id", periodID).
		Info("periodic saving recovery processed")
}

// handleSavingsInterestDistribution processes the distribution of savings interest
// income to group members proportional to their savings balances.
func (b *transferOrderBusiness) handleSavingsInterestDistribution(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleSavingsInterestDistribution").
		WithField("order_id", order.GetID())

	groupID := extraDataString(order, "group_id")

	logger.WithField("group_id", groupID).
		Info("savings interest income distribution processed")
}

// handleRegistrationFee processes a member registration fee payment.
// Debit: member suspense -> Credit: group joining fee account.
func (b *transferOrderBusiness) handleRegistrationFee(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleRegistrationFee").
		WithField("order_id", order.GetID())

	memberID := extraDataString(order, "member_id")

	logger.WithField("member_id", memberID).
		Info("registration fee processed")
}

// handleTerminalDisbursement processes a terminal (end-of-tenure) savings
// disbursement back to the member.
func (b *transferOrderBusiness) handleTerminalDisbursement(ctx context.Context, order *models.TransferOrder) error {
	logger := util.Log(ctx).WithField("handler", "handleTerminalDisbursement").
		WithField("order_id", order.GetID())

	memberID := extraDataString(order, "member_id")

	logger.WithField("member_id", memberID).
		Info("terminal disbursement: initiating payout to member")

	if err := b.sendPayment(ctx, order, memberID, "terminal_disbursement"); err != nil {
		return fmt.Errorf("terminal disbursement payment for member %s: %w", memberID, err)
	}

	return nil
}

// handleTerminalDisbursementRecovery processes a recovery for a failed terminal
// disbursement. Funds are moved back to the savings account for retry.
func (b *transferOrderBusiness) handleTerminalDisbursementRecovery(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleTerminalDisbursementRecovery").
		WithField("order_id", order.GetID())

	originalOrderID := extraDataString(order, "original_order_id")

	logger.WithField("original_order_id", originalOrderID).
		Info("terminal disbursement recovery processed")
}

// ---------------------------------------------------------------------------
// Payment flow handlers
// ---------------------------------------------------------------------------

// handlePaymentOutflow processes an outgoing payment.
// Debit: group bank -> Credit: product unidentified account.
// This is the initial receipt of funds before identification.
func (b *transferOrderBusiness) handlePaymentOutflow(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handlePaymentOutflow").
		WithField("order_id", order.GetID())

	transactionID := extraDataString(order, "transaction_id")

	logger.WithField("transaction_id", transactionID).
		Info("payment outflow posted to unidentified holding")
}

// handlePaymentIdentified processes a payment that has been identified to a
// specific member. Funds move from unidentified to unallocated.
func (b *transferOrderBusiness) handlePaymentIdentified(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handlePaymentIdentified").
		WithField("order_id", order.GetID())

	memberID := extraDataString(order, "member_id")
	paymentID := extraDataString(order, "payment_id")

	logger.WithField("member_id", memberID).
		WithField("payment_id", paymentID).
		Info("payment identified and moved to member suspense")
}

// handlePaymentAllocated processes a payment that has been allocated to specific
// obligations (loan repayment, savings, fees, etc.). This triggers creation of
// the downstream transfer orders for each allocation target.
func (b *transferOrderBusiness) handlePaymentAllocated(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handlePaymentAllocated").
		WithField("order_id", order.GetID())

	memberID := extraDataString(order, "member_id")
	paymentID := extraDataString(order, "payment_id")

	logger.WithField("member_id", memberID).
		WithField("payment_id", paymentID).
		Info("payment allocated to obligations")

	// NOTE: The payment routing business handles the creation of downstream
	// transfer orders for each obligation the payment is allocated against.
	// This handler only manages the base ledger movement.
}

// ---------------------------------------------------------------------------
// Penalty handlers
// ---------------------------------------------------------------------------

// handlePenalty processes a penalty charge against a member.
// Debit: member suspense -> Credit: group penalty income account.
func (b *transferOrderBusiness) handlePenalty(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handlePenalty").
		WithField("order_id", order.GetID())

	memberID := extraDataString(order, "member_id")
	reason := extraDataString(order, "penalty_reason")

	logger.WithField("member_id", memberID).
		WithField("reason", reason).
		Info("penalty charge posted")
}

// handlePenaltyCancel reverses a previously posted penalty.
// Debit: group penalty income -> Credit: member suspense.
// handlePenaltyRepayment is the settlement of an accrued penalty: the base
// transfer clears the member's penalty receivable. No further side effect.
func (b *transferOrderBusiness) handlePenaltyRepayment(ctx context.Context, order *models.TransferOrder) {
	util.Log(ctx).WithField("handler", "handlePenaltyRepayment").
		WithField("order_id", order.GetID()).
		Info("penalty repayment: penalty receivable settled")
}

func (b *transferOrderBusiness) handlePenaltyCancel(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handlePenaltyCancel").
		WithField("order_id", order.GetID())

	originalOrderID := extraDataString(order, "original_order_id")

	logger.WithField("original_order_id", originalOrderID).
		Info("penalty cancellation processed")
}

// handlePenaltyIncomeDistribution distributes accumulated penalty income to
// group members at the end of a tenure or period.
func (b *transferOrderBusiness) handlePenaltyIncomeDistribution(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handlePenaltyIncomeDistribution").
		WithField("order_id", order.GetID())

	groupID := extraDataString(order, "group_id")

	logger.WithField("group_id", groupID).
		Info("penalty income distribution processed")
}

// ---------------------------------------------------------------------------
// Other handlers
// ---------------------------------------------------------------------------

// handleCost processes a transaction cost charge.
// Debit: group bank -> Credit: group transaction costs account.
func (b *transferOrderBusiness) handleCost(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleCost").
		WithField("order_id", order.GetID())

	costType := extraDataString(order, "cost_type")

	logger.WithField("cost_type", costType).
		Info("transaction cost posted")
}

// handleServiceFee processes a platform service fee charge.
// Debit: group bank -> Credit: product service fee payable account.
func (b *transferOrderBusiness) handleServiceFee(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleServiceFee").
		WithField("order_id", order.GetID())

	periodID := extraDataString(order, "period_id")

	logger.WithField("period_id", periodID).
		Info("service fee posted")
}

// handleExternalLending processes a loan funding transfer from an external
// lending source into the group's bank account.
func (b *transferOrderBusiness) handleExternalLending(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleExternalLending").
		WithField("order_id", order.GetID())

	funderID := extraDataString(order, "funder_id")
	fundingID := extraDataString(order, "funding_id")

	logger.WithField("funder_id", funderID).
		WithField("funding_id", fundingID).
		Info("external lending funding received")
}

// handleExternalLendingPayback processes a payback from the group to the
// external lending source. This returns principal + interest to the funder.
func (b *transferOrderBusiness) handleExternalLendingPayback(ctx context.Context, order *models.TransferOrder) error {
	logger := util.Log(ctx).WithField("handler", "handleExternalLendingPayback").
		WithField("order_id", order.GetID())

	funderID := extraDataString(order, "funder_id")
	fundingID := extraDataString(order, "funding_id")

	logger.WithField("funder_id", funderID).
		WithField("funding_id", fundingID).
		Info("external lending payback: initiating funder payout")

	if err := b.sendPayment(ctx, order, funderID, "external_lending_payback"); err != nil {
		return fmt.Errorf("external lending payback payment for funder %s: %w", funderID, err)
	}

	return nil
}

// handleShutdownLoanRecovery processes loan recovery during group shutdown.
// Outstanding loan balances are recovered from member savings or guarantors.
func (b *transferOrderBusiness) handleShutdownLoanRecovery(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleShutdownLoanRecovery").
		WithField("order_id", order.GetID())

	memberID := extraDataString(order, "member_id")
	loanID := extraDataString(order, fieldLoanID)

	logger.WithField("member_id", memberID).
		WithField(fieldLoanID, loanID).
		Info("shutdown loan recovery processed")
}

// handleInterSubscriptionPayment processes a payment between two different
// group subscriptions (e.g., transferring savings from one group to fund
// a loan in another).
func (b *transferOrderBusiness) handleInterSubscriptionPayment(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleInterSubscriptionPayment").
		WithField("order_id", order.GetID())

	sourceGroupID := extraDataString(order, "source_group_id")
	targetGroupID := extraDataString(order, "target_group_id")

	logger.WithField("source_group_id", sourceGroupID).
		WithField("target_group_id", targetGroupID).
		Info("inter-subscription payment processed")
}

// handleLoanInterestIncomeDistribution distributes accumulated loan interest
// income to group members proportional to their savings balances.
func (b *transferOrderBusiness) handleLoanInterestIncomeDistribution(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleLoanInterestIncomeDistribution").
		WithField("order_id", order.GetID())

	groupID := extraDataString(order, "group_id")

	logger.WithField("group_id", groupID).
		Info("loan interest income distribution processed")
}

// ---------------------------------------------------------------------------
// Investor-related handlers
// ---------------------------------------------------------------------------

// handleInvestorDeployment processes capital deployment from an investor account to fund a loan.
func (b *transferOrderBusiness) handleInvestorDeployment(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleInvestorDeployment").
		WithField("order_id", order.GetID())

	investorAccountID := extraDataString(order, "investor_account_id")
	loanRequestID := extraDataLoanRequestID(order)

	logger.WithField("investor_account_id", investorAccountID).
		WithField("loan_request_id", loanRequestID).
		WithField("amount", order.Amount).
		Info("investor capital deployed to loan")
}

// handleInvestorPrincipalReturn processes principal being returned to an investor account.
func (b *transferOrderBusiness) handleInvestorPrincipalReturn(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleInvestorPrincipalReturn").
		WithField("order_id", order.GetID())

	investorAccountID := extraDataString(order, "investor_account_id")

	logger.WithField("investor_account_id", investorAccountID).
		WithField("amount", order.Amount).
		Info("principal returned to investor")
}

// handleAgentCommission records a product's commission accrued to the field
// team serving the borrower. It is a ledger accrual only: the team's
// payable is settled separately, never from the borrower's money.
func (b *transferOrderBusiness) handleAgentCommission(ctx context.Context, order *models.TransferOrder) {
	util.Log(ctx).WithField("handler", "handleAgentCommission").
		WithField("order_id", order.GetID()).
		WithField("team_id", extraDataString(order, "team_id")).
		WithField("amount", order.Amount).
		Info("commission accrued to the serving team")
}

// handleInvestorWithdrawal pays investor capital out to the investor's own
// verified mobile-money contact. The recipient and destination are checked
// before the ledger leg posts, and a payout the rail rejects is reversed, as
// for a loan disbursement.
func (b *transferOrderBusiness) handleInvestorWithdrawal(ctx context.Context, order *models.TransferOrder) error {
	route := extraDataString(order, "payment_channel")
	if route == "" {
		route = "investor_withdrawal"
	}
	if err := b.sendPayment(ctx, order, "", route); err != nil {
		return fmt.Errorf("investor withdrawal payout: %w", err)
	}
	return nil
}

// handleTeamCommissionPayout pays a team's commission out to one of its
// members' own verified mobile-money contact, checked like any payout.
func (b *transferOrderBusiness) handleTeamCommissionPayout(ctx context.Context, order *models.TransferOrder) error {
	route := extraDataString(order, "payment_channel")
	if route == "" {
		route = "team_commission_payout"
	}
	if err := b.sendPayment(ctx, order, "", route); err != nil {
		return fmt.Errorf("team commission payout: %w", err)
	}
	return nil
}

// handleInvestorIncomeDistribution processes interest/income distribution to an investor.
// Platform fees and withholding tax have already been deducted by redistributeRepayment.
func (b *transferOrderBusiness) handleInvestorIncomeDistribution(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleInvestorIncomeDistribution").
		WithField("order_id", order.GetID())

	investorAccountID := extraDataString(order, "investor_account_id")

	logger.WithField("investor_account_id", investorAccountID).
		WithField("amount", order.Amount).
		Info("income distributed to investor (net of platform fees and tax)")
}

// handlePlatformFirstLossAbsorption processes a first-loss absorption from the platform reserve.
func (b *transferOrderBusiness) handlePlatformFirstLossAbsorption(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handlePlatformFirstLossAbsorption").
		WithField("order_id", order.GetID())

	loanRequestID := extraDataLoanRequestID(order)

	logger.WithField("loan_request_id", loanRequestID).
		WithField("amount", order.Amount).
		Info("platform first-loss reserve absorbed loss")
}

func extraDataLoanRequestID(order *models.TransferOrder) string {
	return extraDataString(order, "loan_request_id")
}

// handleInvestorLossAbsorption processes a loss absorption from an investor account.
func (b *transferOrderBusiness) handleInvestorLossAbsorption(
	ctx context.Context,
	order *models.TransferOrder,
) {
	logger := util.Log(ctx).WithField("handler", "handleInvestorLossAbsorption").
		WithField("order_id", order.GetID())

	investorAccountID := extraDataString(order, "investor_account_id")

	logger.WithField("investor_account_id", investorAccountID).
		WithField("amount", order.Amount).
		Info("investor account absorbed loss")
}
