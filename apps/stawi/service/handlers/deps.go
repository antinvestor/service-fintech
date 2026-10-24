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

package handlers

import (
	"context"

	fundingbusiness "github.com/antinvestor/service-fintech/apps/funding/service/business"
	opsbusiness "github.com/antinvestor/service-fintech/apps/operations/service/business"
	opsmodels "github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
)

// LoanWindowBusiness is the subset of loan window business used by workflow callbacks.
type LoanWindowBusiness interface {
	Evaluate(ctx context.Context, groupID string) (map[string]interface{}, error)
	Open(ctx context.Context, groupID string) (*models.LoanWindow, error)
}

// LoanOfferBusiness is the subset of loan offer business used by workflow callbacks.
type LoanOfferBusiness interface {
	GenerateForWindow(ctx context.Context, windowID string) (interface{}, error)
	CreateLoanAccount(ctx context.Context, offerID string) (map[string]interface{}, error)
	ExpireStale(ctx context.Context, membershipID string) (int, error)
	CheckEligibility(ctx context.Context, groupID, membershipID string) (map[string]interface{}, error)
	EnsureSchedule(ctx context.Context, loanAccountID string) (map[string]interface{}, error)
	Disburse(ctx context.Context, loanAccountID string) (map[string]interface{}, error)
}

// FundingAllocationBusiness is the subset of funding business used by workflow callbacks.
type FundingAllocationBusiness interface {
	SourceForRequest(ctx context.Context, loanRequestID string) (*fundingbusiness.AllocationResult, error)
}

// PaymentRoutingBusiness is the subset of operations business used by workflow callbacks.
type PaymentRoutingBusiness interface {
	IdentifySender(ctx context.Context, senderIdentifier, groupID, reference string) (map[string]interface{}, error)
	AllocatePaymentByTransactionID(ctx context.Context, transactionID string) (map[string]interface{}, error)
	SuspenseBalance(ctx context.Context, membershipID string) (map[string]interface{}, error)
	ApplySuspense(ctx context.Context, membershipID string, maxAmount int64) (map[string]interface{}, error)
	RecordSuspenseDeposit(
		ctx context.Context,
		deposit opsbusiness.SuspenseDeposit,
	) (map[string]interface{}, error)
	ConfirmPayment(ctx context.Context, transactionID string) (map[string]interface{}, error)
}

// TransferOrderBusiness is the subset of operations business used by workflow callbacks.
type TransferOrderBusiness interface {
	Save(ctx context.Context, order *opsmodels.TransferOrder) error
	Execute(ctx context.Context, orderID string) error
	RecordFailure(ctx context.Context, reference, reason string) (map[string]interface{}, error)
}

// ObligationBusiness is the subset of operations business used by workflow callbacks.
type ObligationBusiness interface {
	CalculateForGroup(ctx context.Context, groupID string) (map[string]interface{}, error)
	CalculatePenaltiesForPeriod(ctx context.Context, periodID string) (map[string]interface{}, error)
	ReconcilePeriod(ctx context.Context, periodID string) (map[string]interface{}, error)
	OutstandingForPeriod(ctx context.Context, periodID string) (map[string]interface{}, error)
	CheckForMember(ctx context.Context, membershipID string) (map[string]interface{}, error)
	GetStatus(ctx context.Context, obligationID string) (map[string]interface{}, error)
}
