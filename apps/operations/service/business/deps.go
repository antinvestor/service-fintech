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

// deps.go defines local interfaces and lightweight data types for cross-domain
// dependencies that lack SDK RPCs. Identity lookups use the SDK client directly;
// funding and stawi period data still use local repo interfaces since they share
// the same database and have no dedicated RPCs yet.

import (
	"context"
	"time"

	"github.com/pitabwire/frame/v2/data"
)

// ---------------------------------------------------------------------------
// Stawi: periods
// ---------------------------------------------------------------------------

// PeriodInfo is a lightweight projection of stawi's Period model.
type PeriodInfo struct {
	data.BaseModel
	EndDate  *time.Time
	Position int32
}

// PeriodReader provides read access to period data.
type PeriodReader interface {
	GetCurrentByGroupID(ctx context.Context, groupID string) (*PeriodInfo, error)
}

// ---------------------------------------------------------------------------
// Funding: loan fundings, tranches, investor accounts
// ---------------------------------------------------------------------------

// FundingSource defines the source of loan funding (mirrors fundingmodels.FundingSource).
type FundingSource int32

const (
	FundingSourceUnspecified        FundingSource = 0
	FundingSourceGroupSavings       FundingSource = 1
	FundingSourceGroupIncome        FundingSource = 2
	FundingSourceInvestorAffiliated FundingSource = 3
	FundingSourceInvestorGeneral    FundingSource = 4
	FundingSourcePlatformReserve    FundingSource = 5
)

// LoanFundingInfo is a lightweight projection of funding's LoanFunding model.
type LoanFundingInfo struct {
	data.BaseModel
	OwnerID     string
	FundingType int32
	Proportion  int64
}

// FundingTrancheInfo is a lightweight projection of funding's FundingTranche model.
type FundingTrancheInfo struct {
	data.BaseModel
	PrincipalRepaid int64
	InterestEarned  int64
}

// InvestorAccountInfo is a lightweight projection of funding's InvestorAccount model.
type InvestorAccountInfo struct {
	data.BaseModel
	ReservedBalance  int64
	AvailableBalance int64
	TotalReturned    int64
}

// LoanFundingReader provides read access to loan funding data.
type LoanFundingReader interface {
	GetByLoanRequestID(ctx context.Context, loanRequestID string) ([]*LoanFundingInfo, error)
}

// FundingTrancheManager provides read/write access to funding tranche data.
type FundingTrancheManager interface {
	GetByLoanFundingID(ctx context.Context, loanFundingID string) ([]*FundingTrancheInfo, error)
	Save(ctx context.Context, tranche *FundingTrancheInfo) error
}

// InvestorAccountManager provides read/write access to investor account data.
type InvestorAccountManager interface {
	GetByID(ctx context.Context, id string) (*InvestorAccountInfo, error)
	Save(ctx context.Context, account *InvestorAccountInfo) error
}
