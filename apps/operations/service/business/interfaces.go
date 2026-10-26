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

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
)

// PaymentRoutingBusiness handles payment identification and allocation.
type PaymentRoutingBusiness interface {
	IdentifyPayment(ctx context.Context, paymentData map[string]interface{}) (map[string]interface{}, error)
	IdentifySender(ctx context.Context, senderIdentifier, groupID, reference string) (map[string]interface{}, error)
	AllocatePayment(ctx context.Context, paymentID string) (map[string]interface{}, error)
	AllocatePaymentByTransactionID(ctx context.Context, transactionID string) (map[string]interface{}, error)
	SuspenseBalance(ctx context.Context, membershipID string) (map[string]interface{}, error)
	ApplySuspense(ctx context.Context, membershipID string, maxAmount int64) (map[string]interface{}, error)
	RecordSuspenseDeposit(ctx context.Context, deposit SuspenseDeposit) (map[string]interface{}, error)
	ConfirmPayment(ctx context.Context, transactionID string) (map[string]interface{}, error)
	AssignPayment(
		ctx context.Context,
		paymentID, loanID, savingsAccountID, note string,
	) (*models.IncomingPayment, map[string]interface{}, error)
}

// OrderExecutor executes a transfer order by id. TransferOrderBusiness is
// one; payment routing uses it to post the orders an allocation raises.
type OrderExecutor interface {
	Execute(ctx context.Context, orderID string) error
}

// TransferOrderBusiness handles transfer order creation and execution.
type TransferOrderBusiness interface {
	Save(ctx context.Context, order *models.TransferOrder) error
	Execute(ctx context.Context, orderID string) error
	RecordFailure(ctx context.Context, reference, reason string) (map[string]interface{}, error)
}

// ObligationBusiness handles financial obligation management.
type ObligationBusiness interface {
	CalculateForGroup(ctx context.Context, groupID string) (map[string]interface{}, error)
	CalculatePenaltiesForPeriod(ctx context.Context, periodID string) (map[string]interface{}, error)
	ReconcilePeriod(ctx context.Context, periodID string) (map[string]interface{}, error)
	OutstandingForPeriod(ctx context.Context, periodID string) (map[string]interface{}, error)
	CheckForMember(ctx context.Context, membershipID string) (map[string]interface{}, error)
	CreateLoanObligations(ctx context.Context, loanAccountID string, entries []ScheduleEntryInfo) error
	GetStatus(ctx context.Context, obligationID string) (map[string]interface{}, error)
}
