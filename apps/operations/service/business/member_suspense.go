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

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

const (
	// ownerTypeMembership is the owner of a payment matched to a group member.
	ownerTypeMembership = "membership"
	// extraKeySuspenseFunded marks an obligation allocation order whose
	// member suspense this service funded first, so the settle job may post
	// it. Older obligation orders were left to the group workflows.
	extraKeySuspenseFunded = "suspense_funded"
)

// ErrMemberPaymentNoProduct is returned for a member's payment that does not
// say which product's collection account the rail credited: there is no
// account to move it out of.
var ErrMemberPaymentNoProduct = apperrors.NewError(apperrors.Unprocessable,
	"the member's payment names no product, so the account the rail credited is unknown")

// fundMemberSuspense raises the order that moves a member's whole payment
// from the product's collection account into the member's suspense. It is
// keyed on the payment and member, so every allocation run converges on the
// same order.
func (b *paymentRoutingBusiness) fundMemberSuspense(
	ctx context.Context,
	payment *models.IncomingPayment,
	membershipID string,
) (*models.TransferOrder, error) {
	productID := payment.Properties.GetString(fieldProductID)
	if productID == "" {
		return nil, ErrMemberPaymentNoProduct
	}
	to := &models.TransferOrder{
		DebitAccountRef:  constants.ProductExternalCashAccount(productID),
		CreditAccountRef: constants.MemberSuspenseAccount(membershipID),
		Amount:           payment.Amount,
		Currency:         payment.Currency,
		OrderType:        constants.SafeInt32FromInt(constants.TransferTypePaymentIdentified),
		Reference:        fmt.Sprintf("payment:%s:member:%s", payment.GetID(), membershipID),
		Description:      fmt.Sprintf("Payment %s received for member %s", payment.GetID(), membershipID),
		State:            int32(constants.StateJustCreated),
		ExtraData: data.JSONMap{
			extraKeySource:    allocationSourceMarker,
			fieldPaymentID:    payment.GetID(),
			fieldMemberID:     membershipID,
			fieldMembershipID: membershipID,
			fieldGroupID:      payment.Properties.GetString(fieldGroupID),
		},
	}
	to.GenID(ctx)
	to.CopyPartitionInfo(&payment.BaseModel)
	if err := b.toRepo.CreateIfAbsent(ctx, to); err != nil {
		return nil, fmt.Errorf("raise member suspense order for payment %s: %w", payment.GetID(), err)
	}
	return to, nil
}

// executeMemberOrders posts a member's suspense order and then what the
// suspense paid, so the books show the payment without waiting for a
// sweep. An order that fails to post stays raised for the settle job; the
// obligation orders wait while the suspense they draw on is unposted.
func (b *paymentRoutingBusiness) executeMemberOrders(
	ctx context.Context,
	logger *util.LogEntry,
	fundingOrderID string,
	allocations []map[string]interface{},
) string {
	if b.executor == nil {
		return executionPending
	}
	if fundingOrderID != "" {
		if err := b.executor.Execute(ctx, fundingOrderID); err != nil {
			logger.WithError(err).WithField(fieldTransferOrderID, fundingOrderID).
				Warn("member suspense order not posted yet; the settle job retries")
			return executionPending
		}
	}
	outcome := executionPosted
	for _, allocation := range allocations {
		orderID, _ := allocation[fieldTransferOrderID].(string)
		if orderID == "" {
			continue
		}
		if err := b.executor.Execute(ctx, orderID); err != nil {
			logger.WithError(err).WithField(fieldTransferOrderID, orderID).
				Warn("member obligation order not posted yet; the settle job retries")
			outcome = executionPending
		}
	}
	return outcome
}

// SettleMember applies what a group member has paid to what they owe:
// payments matched to them that no allocation has run on yet, then whatever
// is held in their suspense. It reports how much was applied. A payment
// another run is allocating is left to that run.
func (b *paymentRoutingBusiness) SettleMember(ctx context.Context, membershipID string) (int64, error) {
	logger := util.Log(ctx).WithField("method", "PaymentRoutingBusiness.SettleMember").
		WithField(fieldMembershipID, membershipID)

	waiting, err := b.ipRepo.GetUnallocatedByOwnerID(ctx, ownerTypeMembership, membershipID)
	if err != nil {
		return 0, fmt.Errorf("member payments awaiting allocation: %w", err)
	}

	var applied int64
	for _, payment := range waiting {
		result, allocErr := b.AllocatePayment(ctx, payment.GetID())
		if allocErr != nil {
			if !errors.Is(allocErr, ErrAllocationInProgress) {
				logger.WithError(allocErr).WithField(fieldPaymentID, payment.GetID()).
					Warn("member payment not allocated yet; the settle job retries")
			}
			continue
		}
		if amount, ok := result[fieldAllocatedAmount].(int64); ok {
			applied += amount
		}
	}

	suspense, err := b.ApplySuspense(ctx, membershipID, 0)
	if err != nil {
		return applied, fmt.Errorf("apply member suspense: %w", err)
	}
	if amount, ok := suspense["amount_applied"].(int64); ok {
		applied += amount
	}
	return applied, nil
}
