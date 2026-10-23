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
	"time"

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

// LoanBalanceDelta describes a signed change to apply to a LoanBalance row.
// Positive values *decrease* outstanding buckets and increase TotalPaid.
// This is the shape the repayment waterfall produces and can be applied
// atomically via a single SQL UPDATE without any read-modify-write race.
type LoanBalanceDelta struct {
	PrincipalApplied int64
	InterestApplied  int64
	FeesApplied      int64
	PenaltiesApplied int64
}

// Total returns the sum of all applied components.
func (d LoanBalanceDelta) Total() int64 {
	return d.PrincipalApplied + d.InterestApplied + d.FeesApplied + d.PenaltiesApplied
}

// ErrLoanBalanceNotFound is returned when ApplyRepaymentDelta matches no row.
var ErrLoanBalanceNotFound = errors.New("loan balance not found for account")

type LoanBalanceRepository interface {
	datastore.BaseRepository[*models.LoanBalance]
	GetByLoanAccountID(ctx context.Context, loanAccountID string) (*models.LoanBalance, error)
	// ApplyRepaymentDelta applies a waterfall allocation to a loan balance
	// atomically in the database, clamping each bucket at zero. It performs
	// a single UPDATE with arithmetic expressions so concurrent repayments on
	// the same loan serialize correctly at the row-level without optimistic
	// locking or application-side read-modify-write. Returns the fresh row
	// after the update so callers can observe totals (e.g. for payoff detection).
	ApplyRepaymentDelta(
		ctx context.Context,
		loanAccountID string,
		delta LoanBalanceDelta,
	) (*models.LoanBalance, error)
	// ApplyPenaltyDelta moves penalties_outstanding and total_outstanding by
	// the same signed amount in one statement, so a charged penalty enters
	// the borrower's balance and a waived one leaves it without any window in
	// which the two columns disagree. Pass a negative amount to reverse.
	ApplyPenaltyDelta(ctx context.Context, loanAccountID string, amount int64) (*models.LoanBalance, error)
}

// Balance columns touched by conditional deltas.
const (
	colPenaltiesOutstanding = "penalties_outstanding"
	colTotalOutstanding     = "total_outstanding"
	colLastCalculatedAt     = "last_calculated_at"
)

type loanBalanceRepository struct {
	entityRepository[*models.LoanBalance]
	dbPool pool.Pool
}

func NewLoanBalanceRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) LoanBalanceRepository {
	return &loanBalanceRepository{
		entityRepository: newEntityRepository(ctx, dbPool, workMan, func() *models.LoanBalance {
			return &models.LoanBalance{}
		}),
		dbPool: dbPool,
	}
}

func (repo *loanBalanceRepository) GetByLoanAccountID(
	ctx context.Context,
	loanAccountID string,
) (*models.LoanBalance, error) {
	return repo.findOneByField(ctx, "loan_account_id = ?", loanAccountID)
}

func (repo *loanBalanceRepository) ApplyRepaymentDelta(
	ctx context.Context,
	loanAccountID string,
	delta LoanBalanceDelta,
) (*models.LoanBalance, error) {
	if loanAccountID == "" {
		return nil, errors.New("loan account id is required")
	}

	now := time.Now().UTC()
	totalPaidDelta := delta.Total()
	totalOutstandingDelta := totalPaidDelta

	db := repo.dbPool.DB(ctx, false)
	result := db.Table("loan_balances").
		Where("loan_account_id = ? AND deleted_at IS NULL", loanAccountID).
		Updates(map[string]any{
			"principal_outstanding": gorm.Expr("GREATEST(principal_outstanding - ?, 0)", delta.PrincipalApplied),
			"interest_accrued":      gorm.Expr("GREATEST(interest_accrued - ?, 0)", delta.InterestApplied),
			"fees_outstanding":      gorm.Expr("GREATEST(fees_outstanding - ?, 0)", delta.FeesApplied),
			colPenaltiesOutstanding: gorm.Expr("GREATEST(penalties_outstanding - ?, 0)", delta.PenaltiesApplied),
			"total_paid":            gorm.Expr("total_paid + ?", totalPaidDelta),
			colTotalOutstanding:     gorm.Expr("GREATEST(total_outstanding - ?, 0)", totalOutstandingDelta),
			colLastCalculatedAt:     &now,
			colModifiedAt:           now,
			colVersion:              gorm.Expr(colVersion + " + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, ErrLoanBalanceNotFound
	}

	return repo.GetByLoanAccountID(ctx, loanAccountID)
}

func (repo *loanBalanceRepository) ApplyPenaltyDelta(
	ctx context.Context,
	loanAccountID string,
	amount int64,
) (*models.LoanBalance, error) {
	if loanAccountID == "" {
		return nil, errors.New("loan account id is required")
	}
	if amount == 0 {
		return repo.GetByLoanAccountID(ctx, loanAccountID)
	}

	now := time.Now().UTC()
	db := repo.dbPool.DB(ctx, false)
	result := db.Table("loan_balances").
		Where("loan_account_id = ? AND deleted_at IS NULL", loanAccountID).
		Updates(map[string]any{
			colPenaltiesOutstanding: gorm.Expr("GREATEST(penalties_outstanding + ?, 0)", amount),
			colTotalOutstanding:     gorm.Expr("GREATEST(total_outstanding + ?, 0)", amount),
			colLastCalculatedAt:     &now,
			colModifiedAt:           now,
			colVersion:              gorm.Expr(colVersion + " + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, ErrLoanBalanceNotFound
	}

	return repo.GetByLoanAccountID(ctx, loanAccountID)
}
