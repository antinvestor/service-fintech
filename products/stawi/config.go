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

package stawi

import (
	"slices"
	"strings"
	"time"
)

// ProductConfig defines SACCO/Grameen-model product configuration.
// These are product-level defaults that can be overridden per group.
type ProductConfig struct {
	// Group formation
	MinGroupSize int32 `envDefault:"5"  env:"STAWI_MIN_GROUP_SIZE"`
	MaxGroupSize int32 `envDefault:"50" env:"STAWI_MAX_GROUP_SIZE"`

	// Tenure and periods
	GroupLifeDuration int32  `envDefault:"52"     env:"STAWI_GROUP_LIFE_DURATION"` // periods per tenure
	PeriodType        string `envDefault:"WEEKLY" env:"STAWI_PERIOD_TYPE"`

	// Leverage
	MinLeverage int64 `envDefault:"190" env:"STAWI_MIN_LEVERAGE"` // basis points (1.90x)
	MaxLeverage int64 `envDefault:"220" env:"STAWI_MAX_LEVERAGE"` // basis points (2.20x)

	// Loan terms
	LoanInterestRatePA int64 `envDefault:"2400" env:"STAWI_LOAN_INTEREST_RATE"`  // basis points (24%)
	LoanInsuranceRate  int64 `envDefault:"0"    env:"STAWI_LOAN_INSURANCE_RATE"` // basis points
	LoanTenurePeriods  int32 `envDefault:"4"    env:"STAWI_LOAN_TENURE_PERIODS"`
	// LoanProductID is the loans-service product group loans are written on.
	LoanProductID       string `envDefault:"stawi" env:"STAWI_LOAN_PRODUCT_ID"`
	LoanGracePeriod     int32  `envDefault:"1"     env:"STAWI_LOAN_GRACE_PERIOD"`
	LoanMaturityPeriods int32  `envDefault:"4"     env:"STAWI_LOAN_MATURITY_PERIODS"`

	// Savings
	RegistrationFee int64 `envDefault:"0" env:"STAWI_REGISTRATION_FEE"` // minor units
	// ReminderOffsetsHours are how long before a period ends members still
	// owing its savings are reminded; each offset is sent once.
	ReminderOffsetsHours []int `envDefault:"72,24" env:"STAWI_REMINDER_OFFSETS_HOURS" envSeparator:","`

	// GroupTypes are the identity group types stawi runs (2 Grameen,
	// 5 merry-go-round, 6 voluntary). Groups of other types are left alone.
	GroupTypes []int32 `envDefault:"2,5,6" env:"STAWI_GROUP_TYPES" envSeparator:","`

	// Fees
	ServiceFeePercentage int64 `envDefault:"1000" env:"STAWI_SERVICE_FEE_PCT"` // basis points (10%)

	// Penalties (escalating fine tiers, basis points)
	LateFineRate1 int64 `envDefault:"1000" env:"STAWI_LATE_FINE_1"` // 10%
	LateFineRate2 int64 `envDefault:"2000" env:"STAWI_LATE_FINE_2"` // 20%
	LateFineRate3 int64 `envDefault:"3000" env:"STAWI_LATE_FINE_3"` // 30%

	// Funding proportions (basis points, must sum to 10000)
	FundingInternalSavings int64 `envDefault:"6500" env:"STAWI_FUNDING_INTERNAL"` // 65%
	FundingInternalExtra   int64 `envDefault:"2000" env:"STAWI_FUNDING_EXTRA"`    // 20%
	FundingExternalLending int64 `envDefault:"1500" env:"STAWI_FUNDING_EXTERNAL"` // 15%
}

// FineRates returns the escalating fine rates as a slice.
func (c *ProductConfig) FineRates() []int64 {
	return []int64{c.LateFineRate1, c.LateFineRate2, c.LateFineRate3}
}

// Days in each period type, as the loans service counts a term.
const (
	daysPerWeeklyPeriod   int32 = 7
	daysPerBiweeklyPeriod int32 = 14
	daysPerMonthlyPeriod  int32 = 30
)

// LoanTermDays is the loan tenure expressed in days for the loans service.
func (c *ProductConfig) LoanTermDays() int32 {
	days := daysPerWeeklyPeriod
	switch strings.ToUpper(strings.TrimSpace(c.PeriodType)) {
	case "BIWEEKLY":
		days = daysPerBiweeklyPeriod
	case "MONTHLY":
		days = daysPerMonthlyPeriod
	}
	return c.LoanTenurePeriods * days
}

// ReminderOffsets returns the positive reminder offsets, longest first.
func (c *ProductConfig) ReminderOffsets() []time.Duration {
	offsets := make([]time.Duration, 0, len(c.ReminderOffsetsHours))
	for _, h := range c.ReminderOffsetsHours {
		if h > 0 {
			offsets = append(offsets, time.Duration(h)*time.Hour)
		}
	}
	slices.Sort(offsets)
	slices.Reverse(offsets)
	return slices.Compact(offsets)
}

// RunsGroupType reports whether stawi runs groups of the identity type.
func (c *ProductConfig) RunsGroupType(groupType int32) bool {
	return slices.Contains(c.GroupTypes, groupType)
}
