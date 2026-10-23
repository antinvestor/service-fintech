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

package repository

import (
	"context"
	"errors"
	"fmt"
	"strconv"
	"strings"

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"gorm.io/gorm/clause"

	"github.com/antinvestor/service-fintech/apps/seed/service/models"
)

// tierFieldCount is the number of required ":"-separated fields per ladder
// entry; a sixth optional field carries the display name.
const tierFieldCount = 5

// DefaultTierLadder is the ladder seed provisions when no override is
// configured. Without at least one rung, EvaluateTier refuses every request
// and the product cannot originate a single loan.
const DefaultTierLadder = "1:0:500000:2400:30:Starter," +
	"2:1:1500000:2200:30:Builder," +
	"3:3:5000000:2000:45:Trusted," +
	"4:6:15000000:1800:60:Premium"

var (
	errTierLadderScope = errors.New("tier ladder needs a product id and currency code")
	errNoWritableDB    = errors.New("no writable database configured for tier seeding")
)

// ParseTierLadder reads the env-driven ladder specification. Each entry is
// tier:min_successful_repayments:max_loan_amount:interest_bp:term_days[:name].
//
// Seed refuses to originate loans without a configured ladder, so the spec is
// validated strictly rather than silently dropping malformed rungs.
func ParseTierLadder(spec, productID, currencyCode string) ([]*models.CreditTierConfig, error) {
	spec = strings.TrimSpace(spec)
	if spec == "" {
		spec = DefaultTierLadder
	}
	if productID == "" || currencyCode == "" {
		return nil, errTierLadderScope
	}

	var tiers []*models.CreditTierConfig
	for _, raw := range strings.Split(spec, ",") {
		entry := strings.TrimSpace(raw)
		if entry == "" {
			continue
		}
		tier, err := parseTierEntry(entry, productID, currencyCode)
		if err != nil {
			return nil, err
		}
		tiers = append(tiers, tier)
	}
	return tiers, nil
}

func parseTierEntry(entry, productID, currencyCode string) (*models.CreditTierConfig, error) {
	parts := strings.Split(entry, ":")
	if len(parts) < tierFieldCount {
		return nil, fmt.Errorf(
			"credit tier %q must be tier:min_repayments:max_amount:interest_bp:term_days[:name]", entry)
	}

	// Field 2 is money in minor units and needs the full 64-bit range; the
	// rest are small counters.
	numbers := make(map[int]int32, tierFieldCount)
	for _, i := range []int{0, 1, 3, 4} {
		value, err := strconv.ParseInt(strings.TrimSpace(parts[i]), 10, 32)
		if err != nil {
			return nil, fmt.Errorf("credit tier %q has a non-numeric field: %w", entry, err)
		}
		numbers[i] = int32(value)
	}

	maxLoanAmount, err := strconv.ParseInt(strings.TrimSpace(parts[2]), 10, 64)
	if err != nil {
		return nil, fmt.Errorf("credit tier %q has a non-numeric max loan amount: %w", entry, err)
	}

	tier := &models.CreditTierConfig{
		ProductID:               productID,
		CurrencyCode:            currencyCode,
		Tier:                    numbers[0],
		MinSuccessfulRepayments: numbers[1],
		MaxLoanAmount:           maxLoanAmount,
		InterestRate:            int64(numbers[3]),
		TermDays:                numbers[4],
		State:                   stateActive,
	}
	if len(parts) > tierFieldCount {
		tier.Name = strings.TrimSpace(parts[tierFieldCount])
	}
	if tier.Tier <= 0 || tier.MaxLoanAmount <= 0 || tier.TermDays <= 0 {
		return nil, fmt.Errorf("credit tier %q must have a positive tier, amount and term", entry)
	}
	return tier, nil
}

// EnsureTierLadder writes the ladder, leaving any operator-tuned row that
// already exists for a (product, currency, tier) untouched. It is safe to run
// on every setup.
func EnsureTierLadder(ctx context.Context, dbPool pool.Pool, tiers []*models.CreditTierConfig) error {
	if len(tiers) == 0 {
		return nil
	}
	db := dbPool.DB(ctx, false)
	if db == nil {
		return errNoWritableDB
	}

	for _, tier := range tiers {
		tier.GenID(ctx)
		err := db.Clauses(clause.OnConflict{
			Columns: []clause.Column{
				{Name: "product_id"}, {Name: "currency_code"}, {Name: "tier"},
			},
			DoNothing: true,
		}).Create(tier).Error
		if err != nil && !data.ErrorIsDuplicateKey(err) {
			return fmt.Errorf("seed credit tier %d: %w", tier.Tier, err)
		}
	}
	return nil
}
