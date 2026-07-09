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

	"github.com/pitabwire/frame/v2/data"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
)

// LoanRequestInfo is a lightweight projection of the loan request for funding allocation.
type LoanRequestInfo struct {
	data.BaseModel
	Amount     int64
	Currency   string
	Properties data.JSONMap
}

// LoanRequestReader provides read access to canonical loan request data.
// Implemented by adapters in cmd/ that bridge legacy sources into a coherent request view.
type LoanRequestReader interface {
	GetByID(ctx context.Context, id string) (*LoanRequestInfo, error)
}

// FundingAllocationBusiness handles funding allocation operations.
type FundingAllocationBusiness interface {
	SourceForRequest(ctx context.Context, loanRequestID string) (map[string]interface{}, error)
	AbsorbLoss(ctx context.Context, loanRequestID string, lossAmount int64) error
}

// InvestorAccountBusiness handles investor account operations.
type InvestorAccountBusiness interface {
	Create(ctx context.Context, account *models.InvestorAccount) (*models.InvestorAccount, error)
	Get(ctx context.Context, accountID string) (*models.InvestorAccount, error)
	GetByInvestorID(ctx context.Context, investorID string) ([]*models.InvestorAccount, error)
	Deposit(ctx context.Context, accountID string, amount int64, idempotencyKey string) error
	Withdraw(ctx context.Context, accountID string, amount int64, idempotencyKey string) error
	GetAvailable(ctx context.Context, accountID string) (int64, error)
	ReserveBalance(ctx context.Context, accountID string, amount int64) error
	ReleaseBalance(ctx context.Context, accountID string, principalReturned int64, interestEarned int64) error
	AbsorbLoss(ctx context.Context, accountID string, lossAmount int64) error
}
