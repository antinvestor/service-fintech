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

package models

import (
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/pitabwire/frame/v3/data"
	moneyx "github.com/pitabwire/util/moneyx"
)

// MinorUnitsToMoney converts minor units and a currency code to a *commonv1.Money.
// Precision follows ISO 4217 via moneyx.Decimals (JPY=0, KWD/BHD/OMR=3, else=2).
func MinorUnitsToMoney(v int64, currencyCode string) *commonv1.Money {
	return moneyx.FromMinorUnitsByCurrency(currencyCode, v)
}

// FundingSource defines the source of loan funding.
type FundingSource int32

const (
	FundingSourceUnspecified        FundingSource = 0
	FundingSourceGroupSavings       FundingSource = 1 // group member savings (first-loss for group loans)
	FundingSourceGroupIncome        FundingSource = 2 // group retained earnings
	FundingSourceInvestorAffiliated FundingSource = 3 // investors affiliated with the group
	FundingSourceInvestorGeneral    FundingSource = 4 // general investor pool
	FundingSourcePlatformReserve    FundingSource = 5 // platform first-loss reserve (for direct loans)
)

// TrancheLevel defines the loss absorption priority.
type TrancheLevel int32

const (
	TrancheLevelFirstLoss TrancheLevel = 1
	TrancheLevelMezzanine TrancheLevel = 2
	TrancheLevelSenior    TrancheLevel = 3
)

// LoanFunding represents a funding source for a loan request.
type LoanFunding struct {
	data.BaseModel
	OwnerID       string `gorm:"type:varchar(50);index:idx_lfund_owner"`
	OwnerType     string `gorm:"type:varchar(50)"`
	FundingType   int32  `gorm:"column:funding_type"` // FundingSource
	LoanRequestID string `gorm:"column:loan_request_id;type:varchar(50);index:idx_lfund_request;not null"`
	LoanAccountID string `gorm:"type:varchar(50)"` // cross-ref to Lender
	Proportion    int64  // basis points (e.g. 6500 = 65%)
	Amount        int64  // minor units
	Currency      string `gorm:"type:varchar(3)"`
	Description   string `gorm:"type:text"`
	State         int32
	Properties    data.JSONMap
}

func (m *LoanFunding) TableName() string { return "loan_fundings" }

// InvestorAccount represents a pre-funded investor capital account.
type InvestorAccount struct {
	data.BaseModel
	InvestorID        string       `gorm:"type:varchar(50);index:idx_ia_investor;not null"`
	AccountName       string       `gorm:"type:varchar(255)"`
	Currency          string       `gorm:"type:varchar(3);not null"`
	AvailableBalance  int64        // minor units, pre-funded capital
	ReservedBalance   int64        // committed to active loans, not yet repaid
	TotalDeployed     int64        // lifetime deployed
	TotalReturned     int64        // lifetime returned (principal + interest)
	TotalLost         int64        // lifetime capital written off through loss absorption
	MaxExposure       int64        // max total outstanding at any time (0 = unlimited)
	MinInterestRate   int64        // basis points, won't fund loans below this rate
	LastDeployedAt    *time.Time   // when capital was last deployed to a loan
	AllowedProducts   data.JSONMap `gorm:"type:jsonb"` // product type whitelist (empty = all)
	AllowedRegions    data.JSONMap `gorm:"type:jsonb"` // geographic whitelist (empty = all)
	GroupAffiliations data.JSONMap `gorm:"type:jsonb"` // group IDs this investor is affiliated with
	State             int32
	Properties        data.JSONMap
}

func (m *InvestorAccount) TableName() string { return "investor_accounts" }

// FundingTranche represents a tranche within a loan's funding structure.
type FundingTranche struct {
	data.BaseModel
	LoanFundingID     string `gorm:"type:varchar(50);index:idx_ft_funding;not null"`
	InvestorAccountID string `gorm:"type:varchar(50);index:idx_ft_investor"` // empty for group/platform sources
	TrancheLevel      int32  // 1=first-loss, 2=mezzanine, 3=senior
	Amount            int64  // minor units committed
	Currency          string `gorm:"type:varchar(3)"`
	PrincipalRepaid   int64  // tracking repayment
	InterestEarned    int64  // tracking earnings
	LossAbsorbed      int64  // tracking losses taken
	State             int32
	Properties        data.JSONMap
}

func (m *FundingTranche) TableName() string { return "funding_tranches" }

// InvestorCapitalMovement is the durable record of one investor deposit or
// withdrawal. It is written before the money moves and is unique on
// (investor_account_id, idempotency_key), so it is what makes those two
// operations idempotent: a retry loses the insert and reads back the
// original movement instead of posting to the ledger twice. The ledger
// transfer reference is derived from this row's id, never from a balance
// version that a concurrent caller could also observe.
type InvestorCapitalMovement struct {
	data.BaseModel
	InvestorAccountID string `gorm:"type:varchar(50);index:idx_icm_account;not null"`
	Direction         int32  `gorm:"column:direction"` // CapitalMovementDirection
	Amount            int64  // minor units
	Currency          string `gorm:"type:varchar(3);not null"`
	IdempotencyKey    string `gorm:"type:varchar(255);not null"`
	Status            int32
	Properties        data.JSONMap
}

func (m *InvestorCapitalMovement) TableName() string { return "investor_capital_movements" }

// CapitalMovementDirection distinguishes an inflow from an outflow.
type CapitalMovementDirection int32

const (
	CapitalMovementDeposit  CapitalMovementDirection = 1
	CapitalMovementWithdraw CapitalMovementDirection = 2
)

// CapitalMovementStatus tracks how far a movement got.
const (
	CapitalMovementPending   int32 = 1
	CapitalMovementCompleted int32 = 2
	// CapitalMovementDebited marks a withdrawal whose funds have left the
	// investor balance but whose ledger transfer has not been posted yet.
	// A resumed attempt reads it to know the debit must not be repeated.
	CapitalMovementDebited int32 = 3
)

// LoanFundingClaim is the synchronous idempotency lock for allocating a loan
// request. Its unique loan_request_id means only one FundLoan call can build
// an allocation for a request; every concurrent or retried call reads back
// the allocation that the winner persisted rather than reserving investor
// capital a second time.
type LoanFundingClaim struct {
	data.BaseModel
	LoanRequestID string `gorm:"type:varchar(50);index:idx_lfclaim_request;not null"`
	Status        int32
	Properties    data.JSONMap
}

func (m *LoanFundingClaim) TableName() string { return "loan_funding_claims" }

// LossAbsorption is the durable record of one absorbed loss, unique on its
// reference, so repeating an AbsorbLoss call reports what the first call
// actually absorbed instead of eating further tranches.
type LossAbsorption struct {
	data.BaseModel
	LoanRequestID string `gorm:"type:varchar(50);index:idx_loss_request;not null"`
	Reference     string `gorm:"type:varchar(255);not null"`
	LossAmount    int64  // minor units requested
	Absorbed      int64  // minor units actually taken by tranches
	Unrecoverable int64  // minor units no tranche could cover
	Currency      string `gorm:"type:varchar(3)"`
	Properties    data.JSONMap
}

func (m *LossAbsorption) TableName() string { return "loss_absorptions" }
