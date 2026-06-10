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
	"strings"
	"time"

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
)

// stateActive is the numeric value for the active state used in database queries.
const stateActive = 3

// ErrInvestorAccountNotFound is returned by atomic mutators when no row
// matches the filter, so callers can distinguish missing state from a
// guard-clause rejection.
var ErrInvestorAccountNotFound = errors.New("investor account not found")

// ErrInvestorInsufficientFunds is returned by AtomicWithdraw when the
// available balance (available - reserved) is below the requested amount.
var ErrInvestorInsufficientFunds = errors.New("investor account insufficient available balance")

// sanitizeJSONKey removes any characters that could break JSON structure,
// allowing only alphanumeric characters, hyphens, and underscores.
func sanitizeJSONKey(s string) string {
	var b strings.Builder
	for _, r := range s {
		if (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9') || r == '-' || r == '_' {
			b.WriteRune(r)
		}
	}
	return b.String()
}

// InvestorAccountRepository provides data access for investor accounts.
type InvestorAccountRepository interface {
	datastore.BaseRepository[*models.InvestorAccount]
	GetByInvestorID(ctx context.Context, investorID string) ([]*models.InvestorAccount, error)
	GetEligibleForLoan(
		ctx context.Context,
		currency string,
		interestRate int64,
		amount int64,
		productType string,
		region string,
	) ([]*models.InvestorAccount, error)
	GetAffiliatedForGroup(
		ctx context.Context,
		groupID string,
		currency string,
		interestRate int64,
	) ([]*models.InvestorAccount, error)

	// AtomicDeposit increases available_balance on an investor account with
	// a single arithmetic UPDATE. Eliminates the read-modify-write race of
	// mutating the struct and re-emitting it via the event bus.
	AtomicDeposit(ctx context.Context, accountID string, amount int64) (*models.InvestorAccount, error)

	// AtomicWithdraw decreases available_balance iff there are enough
	// available (unreserved) funds to cover the amount. The SQL guard
	// predicate makes concurrent withdrawals against overlapping funds
	// serialize correctly, with losers receiving ErrInvestorInsufficientFunds.
	AtomicWithdraw(ctx context.Context, accountID string, amount int64) (*models.InvestorAccount, error)

	// AtomicAbsorbLoss decrements reserved_balance (clamped at zero) when a
	// loan tranche held by the investor is written off.
	AtomicAbsorbLoss(ctx context.Context, accountID string, lossAmount int64) (*models.InvestorAccount, error)

	// AtomicReserve moves funds from available to reserved when capital is
	// committed to a loan. The SQL guard refuses the reservation if the
	// account has insufficient unreserved funds so the reserve cannot
	// over-commit a concurrent allocation pipeline.
	AtomicReserve(ctx context.Context, accountID string, amount int64) (*models.InvestorAccount, error)

	// AtomicRelease releases a prior reservation without returning capital,
	// typically when a funding allocation is cancelled before disbursement.
	AtomicRelease(ctx context.Context, accountID string, amount int64) (*models.InvestorAccount, error)

	// AtomicReleaseWithReturn settles a reservation after loan principal is
	// returned (and optionally interest earned). Principal reduces reserved
	// and increases available; interest only increases available. Total
	// returned counter tracks lifetime.
	AtomicReleaseWithReturn(
		ctx context.Context,
		accountID string,
		principalReturned int64,
		interestEarned int64,
	) (*models.InvestorAccount, error)
}

// NewInvestorAccountRepository creates a new InvestorAccountRepository.
func NewInvestorAccountRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) InvestorAccountRepository {
	return &investorAccountRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.InvestorAccount {
			return &models.InvestorAccount{}
		}),
	}
}

type investorAccountRepository struct {
	datastore.BaseRepository[*models.InvestorAccount]
}

func (r *investorAccountRepository) GetByInvestorID(
	ctx context.Context,
	investorID string,
) ([]*models.InvestorAccount, error) {
	var accounts []*models.InvestorAccount
	err := r.Pool().DB(ctx, true).Where("investor_id = ?", investorID).Find(&accounts).Error
	return accounts, err
}

// GetEligibleForLoan returns investor accounts that match the loan criteria.
// Results are ordered by utilization ratio ASC (least-utilized investors first)
// so that idle capital is deployed before heavily-utilized capital, ensuring
// fair rotation across all investors.
func (r *investorAccountRepository) GetEligibleForLoan(
	ctx context.Context,
	currency string,
	interestRate int64,
	amount int64,
	productType string,
	region string,
) ([]*models.InvestorAccount, error) {
	var accounts []*models.InvestorAccount

	db := r.Pool().DB(ctx, true).
		Where("currency = ?", currency).
		Where("state = ?", stateActive).
		Where("min_interest_rate = 0 OR min_interest_rate <= ?", interestRate).
		Where("max_exposure = 0 OR (reserved_balance + ?) <= max_exposure", amount)

	if productType != "" {
		db = db.Where(
			"allowed_products IS NULL OR allowed_products @> ?",
			fmt.Sprintf(`{"%s": true}`, sanitizeJSONKey(productType)),
		)
	}
	if region != "" {
		db = db.Where(
			"allowed_regions IS NULL OR allowed_regions @> ?",
			fmt.Sprintf(`{"%s": true}`, sanitizeJSONKey(region)),
		)
	}

	// Order by utilization ratio ASC: investors whose capital is least deployed
	// get priority. This ensures fair rotation — every investor's money works.
	// Utilization = total_deployed / (available_balance + total_deployed).
	// NULLIF prevents division by zero; COALESCE defaults to 0 for fresh accounts.
	err := db.Order("COALESCE(total_deployed * 1.0 / NULLIF(available_balance + total_deployed, 0), 0) ASC, last_deployed_at ASC NULLS FIRST, available_balance DESC").
		Find(&accounts).
		Error
	return accounts, err
}

// GetAffiliatedForGroup returns investor accounts affiliated with a specific group.
// Ordered by utilization ratio ASC for fair rotation.
func (r *investorAccountRepository) GetAffiliatedForGroup(
	ctx context.Context,
	groupID string,
	currency string,
	interestRate int64,
) ([]*models.InvestorAccount, error) {
	var accounts []*models.InvestorAccount
	err := r.Pool().DB(ctx, true).
		Where("group_affiliations @> ?", fmt.Sprintf(`{"%s": true}`, sanitizeJSONKey(groupID))).
		Where("currency = ?", currency).
		Where("state = ?", stateActive).
		Where("min_interest_rate = 0 OR min_interest_rate <= ?", interestRate).
		Order("COALESCE(total_deployed * 1.0 / NULLIF(available_balance + total_deployed, 0), 0) ASC, last_deployed_at ASC NULLS FIRST, available_balance DESC").
		Find(&accounts).Error
	return accounts, err
}

func (r *investorAccountRepository) AtomicDeposit(
	ctx context.Context,
	accountID string,
	amount int64,
) (*models.InvestorAccount, error) {
	if amount <= 0 {
		return nil, errors.New("deposit amount must be positive")
	}
	now := time.Now().UTC()
	result := r.Pool().DB(ctx, false).
		Model(&models.InvestorAccount{}).
		Where("id = ?", accountID).
		Updates(map[string]any{
			colAvailableBalance: gorm.Expr("available_balance + ?", amount),
			colModifiedAt:       now,
			colVersion:          gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, ErrInvestorAccountNotFound
	}
	return r.GetByID(ctx, accountID)
}

func (r *investorAccountRepository) AtomicWithdraw(
	ctx context.Context,
	accountID string,
	amount int64,
) (*models.InvestorAccount, error) {
	if amount <= 0 {
		return nil, errors.New("withdraw amount must be positive")
	}
	now := time.Now().UTC()
	result := r.Pool().DB(ctx, false).
		Model(&models.InvestorAccount{}).
		Where("id = ? AND (available_balance - reserved_balance) >= ?", accountID, amount).
		Updates(map[string]any{
			colAvailableBalance: gorm.Expr("available_balance - ?", amount),
			colModifiedAt:       now,
			colVersion:          gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		// Distinguish missing row from insufficient funds.
		existing := &models.InvestorAccount{}
		if lookupErr := r.Pool().DB(ctx, true).
			First(existing, "id = ?", accountID).Error; lookupErr != nil {
			if errors.Is(lookupErr, gorm.ErrRecordNotFound) {
				return nil, ErrInvestorAccountNotFound
			}
			return nil, lookupErr
		}
		return nil, ErrInvestorInsufficientFunds
	}
	return r.GetByID(ctx, accountID)
}

func (r *investorAccountRepository) AtomicAbsorbLoss(
	ctx context.Context,
	accountID string,
	lossAmount int64,
) (*models.InvestorAccount, error) {
	if lossAmount <= 0 {
		return nil, errors.New("loss amount must be positive")
	}
	now := time.Now().UTC()
	result := r.Pool().DB(ctx, false).
		Model(&models.InvestorAccount{}).
		Where("id = ?", accountID).
		Updates(map[string]any{
			colReservedBalance: gorm.Expr("GREATEST(reserved_balance - ?, 0)", lossAmount),
			colModifiedAt:      now,
			colVersion:         gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, ErrInvestorAccountNotFound
	}
	return r.GetByID(ctx, accountID)
}

func (r *investorAccountRepository) AtomicReserve(
	ctx context.Context,
	accountID string,
	amount int64,
) (*models.InvestorAccount, error) {
	if amount <= 0 {
		return nil, errors.New("reserve amount must be positive")
	}
	now := time.Now().UTC()
	result := r.Pool().DB(ctx, false).
		Model(&models.InvestorAccount{}).
		Where("id = ? AND (available_balance - reserved_balance) >= ?", accountID, amount).
		Updates(map[string]any{
			colReservedBalance: gorm.Expr("reserved_balance + ?", amount),
			"total_deployed":   gorm.Expr("total_deployed + ?", amount),
			"last_deployed_at": now,
			colModifiedAt:      now,
			colVersion:         gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		existing := &models.InvestorAccount{}
		if lookupErr := r.Pool().DB(ctx, true).
			First(existing, "id = ?", accountID).Error; lookupErr != nil {
			if errors.Is(lookupErr, gorm.ErrRecordNotFound) {
				return nil, ErrInvestorAccountNotFound
			}
			return nil, lookupErr
		}
		return nil, ErrInvestorInsufficientFunds
	}
	return r.GetByID(ctx, accountID)
}

func (r *investorAccountRepository) AtomicRelease(
	ctx context.Context,
	accountID string,
	amount int64,
) (*models.InvestorAccount, error) {
	if amount <= 0 {
		return nil, errors.New("release amount must be positive")
	}
	now := time.Now().UTC()
	result := r.Pool().DB(ctx, false).
		Model(&models.InvestorAccount{}).
		Where("id = ? AND reserved_balance >= ?", accountID, amount).
		Updates(map[string]any{
			colReservedBalance: gorm.Expr("reserved_balance - ?", amount),
			colModifiedAt:      now,
			colVersion:         gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		existing := &models.InvestorAccount{}
		if lookupErr := r.Pool().DB(ctx, true).
			First(existing, "id = ?", accountID).Error; lookupErr != nil {
			if errors.Is(lookupErr, gorm.ErrRecordNotFound) {
				return nil, ErrInvestorAccountNotFound
			}
			return nil, lookupErr
		}
		return nil, errors.New("release exceeded reserved balance")
	}
	return r.GetByID(ctx, accountID)
}

func (r *investorAccountRepository) AtomicReleaseWithReturn(
	ctx context.Context,
	accountID string,
	principalReturned int64,
	interestEarned int64,
) (*models.InvestorAccount, error) {
	if principalReturned < 0 || interestEarned < 0 {
		return nil, errors.New("returns must be non-negative")
	}
	if principalReturned == 0 && interestEarned == 0 {
		return r.GetByID(ctx, accountID)
	}

	now := time.Now().UTC()
	result := r.Pool().DB(ctx, false).
		Model(&models.InvestorAccount{}).
		Where("id = ?", accountID).
		Updates(map[string]any{
			colReservedBalance:  gorm.Expr("GREATEST(reserved_balance - ?, 0)", principalReturned),
			colAvailableBalance: gorm.Expr("available_balance + ?", principalReturned+interestEarned),
			"total_returned":    gorm.Expr("total_returned + ?", principalReturned+interestEarned),
			colModifiedAt:       now,
			colVersion:          gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, ErrInvestorAccountNotFound
	}
	return r.GetByID(ctx, accountID)
}
