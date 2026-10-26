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

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
)

// LoanWindowBusiness is the subset of loan window business used by workflow callbacks.
type LoanWindowBusiness interface {
	Evaluate(ctx context.Context, groupID string) (map[string]interface{}, error)
	Open(ctx context.Context, groupID string) (*models.LoanWindow, error)
}

// LoanOfferBusiness is the subset of loan offer business used by workflow callbacks.
type LoanOfferBusiness interface {
	CreateLoanAccount(ctx context.Context, offerID string) (map[string]interface{}, error)
	Respond(ctx context.Context, groupID, offerID string, response int32) error
}

// PaymentRoutingBusiness is the subset of operations business used by workflow callbacks.
type PaymentRoutingBusiness interface {
	SuspenseBalance(ctx context.Context, membershipID string) (map[string]interface{}, error)
	ApplySuspense(ctx context.Context, membershipID string, maxAmount int64) (map[string]interface{}, error)
}

// ObligationBusiness is the subset of operations business used by workflow callbacks.
type ObligationBusiness interface {
	CalculateForGroup(ctx context.Context, groupID string) (map[string]interface{}, error)
	CalculatePenaltiesForPeriod(ctx context.Context, periodID string) (map[string]interface{}, error)
	ReconcilePeriod(ctx context.Context, periodID string) (map[string]interface{}, error)
	OutstandingForPeriod(ctx context.Context, periodID string) (map[string]interface{}, error)
}
