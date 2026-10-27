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
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// payoutUndecidedAlertAfter is how long a payout may stay undecided at the
// rail before operators are told to look at it.
const payoutUndecidedAlertAfter = 24 * time.Hour

const lateFailureReason = "the payment rail failed the payout after accepting it"

// errNoPayoutOriginator is returned for a payout whose reference names no
// service operations knows to tell.
var errNoPayoutOriginator = errors.New("no originator is known for this payout reference")

// PayoutReconciler settles how payouts the rail accepted ended, and tells
// the service that raised a payout the rail failed afterwards.
type PayoutReconciler interface {
	ReconcilePayout(ctx context.Context, orderID string) error
	NotifyOriginator(ctx context.Context, order *models.TransferOrder) error
}

// ReconcilePayout asks the payment service how one payout ended. An order
// that never completed is resumed, which settles it the same way. For a
// completed order: confirmed money is recorded as confirmed; a payout the
// rail failed after accepting it is marked failed and its ledger leg
// reversed, and its originator is told on the next pass; one still
// undecided is looked at again later and reported once it has waited a day.
func (b *transferOrderBusiness) ReconcilePayout(ctx context.Context, orderID string) error {
	logger := util.Log(ctx).WithField("method", "ReconcilePayout").WithField("order_id", orderID)
	order, err := b.toRepo.GetByID(ctx, orderID)
	if err != nil {
		return fmt.Errorf("load transfer order: %w", err)
	}
	if order.PayoutFailed() || !isPayoutOrderType(int(order.OrderType)) {
		return nil
	}
	if order.State != int32(constants.StateInactive) {
		// Not completed: resuming confirms an earlier payout or reverses a
		// failed one, exactly as a caller's retry would.
		return b.Execute(ctx, orderID)
	}

	payment, err := b.payoutLocator().FindByReference(ctx, order.Reference)
	if err != nil {
		_ = b.toRepo.TouchPayoutChecked(ctx, orderID)
		return fmt.Errorf("look up payout: %w", err)
	}
	// Act only on this order's own payout: the payment id it recorded, or,
	// with none recorded, an outbound payment of exactly its amount. Any
	// other answer is not ours to reverse or confirm; it stays undecided
	// and, after a day, goes to an operator.
	if payment == nil ||
		(order.PaymentID != "" && payment.GetId() != order.PaymentID) ||
		(order.PaymentID == "" && !payoutMatchesOrder(payment, order)) {
		_ = b.toRepo.TouchPayoutChecked(ctx, orderID)
		b.reportUndecided(logger, order)
		return nil
	}

	switch payment.GetStatus() { //nolint:exhaustive // the rest are undecided
	case commonv1.STATUS_SUCCESSFUL:
		return b.toRepo.SetPayoutOutcome(ctx, orderID, models.PayoutStatusConfirmed)
	case commonv1.STATUS_FAILED:
		if markErr := b.toRepo.MarkPayoutFailed(ctx, orderID, payment.GetId(), lateFailureReason); markErr != nil {
			return fmt.Errorf("record late payout failure: %w", markErr)
		}
		order.PayoutStatus = models.PayoutStatusFailed
		logger.WithField("payment_id", payment.GetId()).Error("payout failed at the rail after it was accepted")
		if revErr := b.reverseRejectedPayout(ctx, logger, order); revErr != nil {
			return fmt.Errorf("reverse late-failed payout: %w", revErr)
		}
		return nil
	default:
		if setErr := b.toRepo.SetPayoutOutcome(ctx, orderID, models.PayoutStatusPending); setErr != nil {
			return setErr
		}
		b.reportUndecided(logger, order)
		return nil
	}
}

// reportUndecided logs, for operators, a payout the rail has not decided
// after a day.
func (b *transferOrderBusiness) reportUndecided(logger *util.LogEntry, order *models.TransferOrder) {
	if order.PaymentInitiatedAt == nil || time.Since(*order.PaymentInitiatedAt) < payoutUndecidedAlertAfter {
		return
	}
	logger.WithFields(map[string]any{
		"reference":    order.Reference,
		fieldPaymentID: order.PaymentID,
		"sent_at":      order.PaymentInitiatedAt.UTC().Format(time.RFC3339),
	}).Error("payout still undecided at the payment rail after a day; check it with the provider")
}

// NotifyOriginator tells the service that raised a payout the rail failed
// after accepting it, so it undoes its own record: the disbursement, the
// withdrawal or the commission payout. The ledger leg is already reversed.
// It is told until it answers.
func (b *transferOrderBusiness) NotifyOriginator(ctx context.Context, order *models.TransferOrder) error {
	logger := util.Log(ctx).WithField("order_id", order.GetID()).WithField("reference", order.Reference)
	if err := b.tellOriginator(ctx, order.Reference); err != nil {
		if errors.Is(err, errNoPayoutOriginator) {
			logger.Error("late-failed payout has no originator to tell; an operator must settle it")
			return b.toRepo.MarkOriginatorNotified(ctx, order.GetID())
		}
		return fmt.Errorf("tell originator: %w", err)
	}
	return b.toRepo.MarkOriginatorNotified(ctx, order.GetID())
}

// tellOriginator calls the service whose reference the payout carries.
func (b *transferOrderBusiness) tellOriginator(ctx context.Context, reference string) error {
	if b.clients == nil {
		return errNoPayoutOriginator
	}
	switch {
	case strings.HasPrefix(reference, "disbursement:"), strings.HasPrefix(reference, "team_commission_payout:"):
		if b.clients.LenderLoanMgmt == nil {
			return errors.New("loans client is not configured")
		}
		_, err := b.clients.LenderLoanMgmt.PayoutFailedApply(ctx,
			&loansv1.PayoutFailedApplyRequest{Reference: reference, Reason: lateFailureReason})
		return err
	case strings.HasPrefix(reference, "withdrawal:"):
		if b.clients.LenderSavings == nil {
			return errors.New("savings client is not configured")
		}
		_, err := b.clients.LenderSavings.PayoutFailedApply(ctx,
			&savingsv1.PayoutFailedApplyRequest{Reference: reference, Reason: lateFailureReason})
		return err
	case strings.HasPrefix(reference, "investor_capital_movement:"):
		if b.clients.LenderFunding == nil {
			return errors.New("funding client is not configured")
		}
		_, err := b.clients.LenderFunding.PayoutFailedApply(ctx,
			&fundingv1.PayoutFailedApplyRequest{Reference: reference, Reason: lateFailureReason})
		return err
	default:
		return errNoPayoutOriginator
	}
}

// payoutOrderTypes are the order types whose side effect pays out through
// the payment rail.
func payoutOrderTypes() []int {
	return []int{
		constants.TransferTypeDisbursement,
		constants.TransferTypeDisbursementReversalReroute,
		constants.TransferTypeLoan,
		constants.TransferTypeTerminalDisbursement,
		constants.TransferTypeInvestorWithdrawal,
		constants.TransferTypeTeamCommissionPayout,
	}
}
