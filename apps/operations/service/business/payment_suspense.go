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
	"fmt"
	"strings"
	"time"

	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// paymentRemainder reads the unallocated remainder recorded on a payment. A
// payment that has never been through allocation carries no remainder key and
// its whole amount is still in suspense.
func paymentRemainder(payment *models.IncomingPayment) int64 {
	if payment.Properties != nil {
		if raw, ok := payment.Properties[fieldRemainingAmount]; ok {
			switch typed := raw.(type) {
			case float64:
				return int64(typed)
			case int64:
				return typed
			}
		}
	}
	return payment.Amount
}

// SuspenseBalance reports how much of a member's received money is still
// sitting unallocated. It is the sum of the remainders left by every
// allocation run against that member's payments.
func (b *paymentRoutingBusiness) SuspenseBalance(
	ctx context.Context,
	membershipID string,
) (map[string]interface{}, error) {
	membershipID = strings.TrimSpace(membershipID)
	if membershipID == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "a member id is required")
	}

	payments, err := b.ipRepo.GetWithSuspenseByOwnerID(ctx, membershipID)
	if err != nil {
		return nil, err
	}

	var balance int64
	currency := ""
	for _, payment := range payments {
		balance += paymentRemainder(payment)
		if currency == "" {
			currency = payment.Currency
		}
	}

	return map[string]interface{}{
		fieldMemberID:        membershipID,
		fieldMembershipID:    membershipID,
		"balance":            balance,
		fieldCurrency:        currency,
		"payment_count":      len(payments),
		fieldRemainingAmount: balance,
	}, nil
}

// ApplySuspense drains a member's suspense balance against their outstanding
// obligations, in the same priority order a fresh payment would follow. It is
// the recovery path for money that arrived before the obligations it should
// settle existed.
//
// maxAmount caps how much is applied; a non-positive cap means "apply
// everything available".
func (b *paymentRoutingBusiness) ApplySuspense(
	ctx context.Context,
	membershipID string,
	maxAmount int64,
) (map[string]interface{}, error) {
	logger := util.Log(ctx).WithField("method", "PaymentRoutingBusiness.ApplySuspense").
		WithField(fieldMembershipID, membershipID)

	membershipID = strings.TrimSpace(membershipID)
	if membershipID == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "a member id is required")
	}

	payments, err := b.ipRepo.GetWithSuspenseByOwnerID(ctx, membershipID)
	if err != nil {
		return nil, err
	}

	obligations, err := b.obRepo.GetByMembershipID(ctx, membershipID)
	if err != nil {
		return nil, err
	}

	budget := maxAmount
	var applied int64
	buckets := buildAllocationBuckets()

	for _, payment := range payments {
		available := paymentRemainder(payment)
		if available <= 0 {
			continue
		}
		if maxAmount > 0 {
			if budget <= 0 {
				break
			}
			available = min(available, budget)
		}

		consumed, applyErr := b.applySuspensePayment(
			ctx,
			logger,
			buckets,
			payment,
			membershipID,
			available,
		)
		if applyErr != nil {
			return nil, applyErr
		}
		applied += consumed
		if maxAmount > 0 {
			budget -= consumed
		}
	}

	remainingObligation := outstandingTotal(obligations)

	logger.WithField("amount_applied", applied).Info("suspense balance applied to obligations")

	return map[string]interface{}{
		fieldMemberID:          membershipID,
		fieldMembershipID:      membershipID,
		"amount_applied":       applied,
		"remaining_obligation": remainingObligation,
	}, nil
}

// outstandingTotal sums what is still owed across a member's obligations. The
// obligation rows are mutated in place as buckets consume them, so this
// reflects the state after an application run.
func outstandingTotal(obligations []*models.Obligation) int64 {
	var total int64
	for _, obl := range obligations {
		if obl.State == int32(constants.StateActive) && obl.Amount > 0 {
			total += obl.Amount
		}
	}
	return total
}

// RecordSuspenseDeposit books money that arrived without an identifiable payer
// so it is held against the group rather than lost. The payment is created
// with no owner; identification and allocation happen later.
func (b *paymentRoutingBusiness) RecordSuspenseDeposit(
	ctx context.Context,
	deposit SuspenseDeposit,
) (map[string]interface{}, error) {
	if strings.TrimSpace(deposit.TransactionID) == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "transaction_id is required")
	}
	if deposit.Amount <= 0 {
		return nil, apperrors.NewError(apperrors.BadRequest, "amount must be positive")
	}

	payment, err := b.loadOrCreateIncomingPayment(ctx, map[string]interface{}{
		fieldTransactionID:  strings.TrimSpace(deposit.TransactionID),
		fieldAmount:         deposit.Amount,
		fieldCurrency:       strings.TrimSpace(deposit.Currency),
		fieldGroupID:        strings.TrimSpace(deposit.GroupID),
		fieldPayerReference: strings.TrimSpace(deposit.SenderIdentifier),
		fieldReference:      strings.TrimSpace(deposit.Reference),
	})
	if err != nil {
		return nil, err
	}

	return map[string]interface{}{
		fieldPaymentID:     payment.GetID(),
		fieldTransactionID: payment.TransactionID,
		fieldAmount:        payment.Amount,
		fieldCurrency:      payment.Currency,
		fieldState:         payment.State,
		fieldStatus:        "recorded",
	}, nil
}

// SuspenseDeposit is the payload for booking an unidentified receipt.
type SuspenseDeposit struct {
	GroupID          string
	TransactionID    string
	Amount           int64
	Currency         string
	SenderIdentifier string
	Reference        string
}

// ConfirmPayment stamps a payment as confirmed once its routing has been
// settled. It is idempotent: a second confirmation reports the first one's
// outcome rather than re-stamping the row.
func (b *paymentRoutingBusiness) ConfirmPayment(
	ctx context.Context,
	transactionID string,
) (map[string]interface{}, error) {
	transactionID = strings.TrimSpace(transactionID)
	if transactionID == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "transaction_id is required")
	}

	payment, err := b.ipRepo.GetByTransactionID(ctx, transactionID)
	if err != nil {
		return nil, apperrors.ErrDataNotFound.Extend("incoming payment")
	}
	if payment.OwnerID == "" {
		return nil, apperrors.NewError(apperrors.Unprocessable,
			"the payment has not been identified and cannot be confirmed")
	}

	stamped, err := b.ipRepo.MarkConfirmed(ctx, payment.GetID(), time.Now().UTC())
	if err != nil {
		return nil, err
	}

	return map[string]interface{}{
		fieldPaymentID:       payment.GetID(),
		fieldTransactionID:   payment.TransactionID,
		fieldMemberID:        payment.OwnerID,
		fieldMembershipID:    payment.OwnerID,
		fieldState:           payment.State,
		fieldRemainingAmount: paymentRemainder(payment),
		"status":             "confirmed",
		"newly_confirmed":    stamped,
	}, nil
}

// applySuspensePayment runs the allocation buckets against one payment's
// remainder under the allocation lease and records the outcome. It returns
// how much of the payment was applied.
func (b *paymentRoutingBusiness) applySuspensePayment(
	ctx context.Context,
	logger *util.LogEntry,
	buckets []allocationBucket,
	payment *models.IncomingPayment,
	membershipID string,
	available int64,
) (int64, error) {
	// Same lease as AllocatePayment: suspense application is an allocation
	// run and must not race one.
	fresh, claimed, claimErr := b.ipRepo.ClaimAllocation(
		ctx,
		payment.GetID(),
		time.Now().Add(-allocationLeaseStaleAfter),
	)
	if claimErr != nil {
		return 0, fmt.Errorf("claim payment for suspense application: %w", claimErr)
	}
	if !claimed {
		logger.WithField(fieldPaymentID, payment.GetID()).Info("payment is being allocated elsewhere; skipping")
		return 0, nil
	}
	lease := leaseOf(fresh)

	// Work from the row and the obligations as they are under the lease; the
	// list read before claiming may have been consumed by another run.
	freshRemainder, known := allocatableRemainder(fresh)
	if !known {
		b.releaseAllocationLease(ctx, logger, fresh.GetID(), lease)
		return 0, nil
	}
	available = min(available, freshRemainder)
	if available <= 0 {
		b.releaseAllocationLease(ctx, logger, fresh.GetID(), lease)
		return 0, nil
	}
	obligations, err := b.obRepo.GetByMembershipID(ctx, membershipID)
	if err != nil {
		b.releaseAllocationLease(ctx, logger, fresh.GetID(), lease)
		return 0, fmt.Errorf("could not retrieve obligations for member: %w", err)
	}

	leftover, _ := b.runAllocationBuckets(
		ctx, logger, buckets, obligations, fresh, fresh.GetID(), membershipID, available,
	)
	consumed := available - leftover
	if consumed <= 0 {
		b.releaseAllocationLease(ctx, logger, fresh.GetID(), lease)
		return 0, nil
	}

	remaining := freshRemainder - consumed
	state := resolvePaymentState(remaining, fresh.Amount-remaining)
	landed, outcomeErr := b.ipRepo.SetAllocationOutcome(ctx, fresh.GetID(), lease, state, remaining)
	if outcomeErr != nil {
		logger.WithError(outcomeErr).WithField(fieldPaymentID, fresh.GetID()).
			Error("could not record suspense application outcome")
	} else if !landed {
		logger.WithField(fieldPaymentID, fresh.GetID()).Warn("suspense outcome not recorded: lease was taken over")
	}
	return consumed, nil
}
