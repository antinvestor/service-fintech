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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	"github.com/pitabwire/frame/v3/data"

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
	SourceForRequest(ctx context.Context, loanRequestID string) (*AllocationResult, error)

	// AbsorbLoss walks the loan's tranches first-loss first and reports what
	// they actually covered. It is idempotent on the loss reference: a repeat
	// returns the first call's split rather than eating further tranches.
	AbsorbLoss(ctx context.Context, loss LossApplication) (*LossResult, error)

	// ReleaseForRequest gives back the capital reserved for a loan request
	// whose loan was cancelled before disbursement, and returns how much.
	// Each funding record is released once, however often it is called.
	ReleaseForRequest(ctx context.Context, loanRequestID string) (int64, string, error)
}

// LossApplication is a loss on a loan to charge to its funders.
type LossApplication struct {
	LoanRequestID string
	// ProductID names the product whose bad-debt expense the funders take
	// over on the ledger. Empty records the absorption without postings.
	ProductID string
	Amount    int64
	Currency  string
}

// AllocationResult is the outcome of sourcing capital for a loan request.
type AllocationResult struct {
	LoanRequestID  string
	Currency       string
	LoanAmount     int64
	TotalAllocated int64
	Deficit        int64
	FullyFunded    bool
	IsGroupLoan    bool
	Allocations    []Allocation
}

// Allocation is one funded slice of a loan request.
type Allocation struct {
	ID            string
	LoanRequestID string
	SourceID      string
	SourceType    string
	TrancheLevel  int32
	Amount        int64
	Currency      string
}

// LossResult reports how a loss was split between the tranches that could
// carry it and the remainder that nothing could.
type LossResult struct {
	Absorbed      int64
	Unrecoverable int64
	Currency      string
	// Settled is true once the ledger postings for the absorbed loss are done.
	Settled bool
}

// InvestorAccountBusiness handles investor account operations.
type InvestorAccountBusiness interface {
	Save(ctx context.Context, account *models.InvestorAccount) (*models.InvestorAccount, error)
	SetState(ctx context.Context, accountID string, state int32) (*models.InvestorAccount, error)
	Get(ctx context.Context, accountID string) (*models.InvestorAccount, error)
	Search(ctx context.Context, req *fundingv1.InvestorAccountSearchRequest) ([]*models.InvestorAccount, error)
	Deposit(ctx context.Context, accountID string, amount *commonv1.Money, idempotencyKey string) error
	Withdraw(ctx context.Context, accountID string, amount *commonv1.Money, idempotencyKey string) error
	GetAvailable(ctx context.Context, accountID string) (int64, error)
	ReserveBalance(ctx context.Context, accountID string, amount int64) error
	ReleaseBalance(ctx context.Context, accountID string, principalReturned int64, interestEarned int64) error
	AbsorbLoss(ctx context.Context, accountID string, lossAmount int64) error
}
