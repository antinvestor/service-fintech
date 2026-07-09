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
	"github.com/pitabwire/frame/v2/data"
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

// FundingAllocation represents a specific allocation from a savings account to a loan funding.
type FundingAllocation struct {
	data.BaseModel
	LoanFundingID    string `gorm:"type:varchar(50);index:idx_fa_funding;not null"`
	SavingsAccountID string `gorm:"type:varchar(50);index:idx_fa_savings"`
	Amount           int64  // minor units - allocated amount
	ReservedAmount   int64  // minor units - reserved (may differ from allocated)
	Currency         string `gorm:"type:varchar(3)"`
	State            int32
	Properties       data.JSONMap
}

func (m *FundingAllocation) TableName() string { return "funding_allocations" }

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
