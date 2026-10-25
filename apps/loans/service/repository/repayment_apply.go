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

	"github.com/pitabwire/frame/v3/datastore/pool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

// EntryAllocation is what one repayment pays onto one installment.
type EntryAllocation struct {
	EntryID   string `json:"entry_id"`
	Principal int64  `json:"principal"`
	Interest  int64  `json:"interest"`
	Fees      int64  `json:"fees"`
}

// Total is everything the allocation pays onto the installment.
func (a EntryAllocation) Total() int64 { return a.Principal + a.Interest + a.Fees }

// RepaymentApplier makes a posted repayment count against the loan.
type RepaymentApplier interface {
	// Apply marks the repayment applied, adds its allocation to each
	// installment and takes it off the loan balance, all in one transaction.
	// applied=false means an earlier call already applied it and nothing
	// moved. The loan's balance after the call is returned either way.
	Apply(
		ctx context.Context,
		repaymentID, loanAccountID string,
		entries []EntryAllocation,
		delta LoanBalanceDelta,
	) (applied bool, balance *models.LoanBalance, err error)
}

type repaymentApplier struct {
	dbPool   pool.Pool
	balances LoanBalanceRepository
}

// NewRepaymentApplier builds the applier.
func NewRepaymentApplier(dbPool pool.Pool, balances LoanBalanceRepository) RepaymentApplier {
	return &repaymentApplier{dbPool: dbPool, balances: balances}
}

func (a *repaymentApplier) Apply(
	ctx context.Context,
	repaymentID, loanAccountID string,
	entries []EntryAllocation,
	delta LoanBalanceDelta,
) (bool, *models.LoanBalance, error) {
	applied := false
	err := a.dbPool.DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		claim := tx.Exec(`UPDATE repayments SET applied_at = now(), modified_at = now(), version = version + 1
WHERE id = ? AND applied_at IS NULL AND deleted_at IS NULL`, repaymentID)
		if claim.Error != nil {
			return claim.Error
		}
		if claim.RowsAffected == 0 {
			return nil
		}
		applied = true
		// Every column on the right-hand side is the value before this
		// statement, so each installment moves by exactly this allocation.
		for _, e := range entries {
			if e.Total() <= 0 {
				continue
			}
			if err := tx.Exec(`UPDATE schedule_entries SET
    principal_paid = principal_paid + ?,
    interest_paid = interest_paid + ?,
    fees_paid = fees_paid + ?,
    total_paid = total_paid + ?,
    outstanding = GREATEST(total_due - (total_paid + ?), 0),
    status = CASE WHEN total_paid + ? >= total_due THEN 3 ELSE 4 END,
    paid_date = CASE WHEN total_paid + ? >= total_due THEN now() ELSE paid_date END,
    modified_at = now(), version = version + 1
WHERE id = ? AND deleted_at IS NULL`,
				e.Principal, e.Interest, e.Fees, e.Total(), e.Total(), e.Total(), e.Total(), e.EntryID,
			).Error; err != nil {
				return err
			}
		}
		now := time.Now().UTC()
		result := tx.Table("loan_balances").
			Where("loan_account_id = ? AND deleted_at IS NULL", loanAccountID).
			Updates(map[string]any{
				"principal_outstanding": gorm.Expr("GREATEST(principal_outstanding - ?, 0)", delta.PrincipalApplied),
				"interest_accrued":      gorm.Expr("GREATEST(interest_accrued - ?, 0)", delta.InterestApplied),
				"fees_outstanding":      gorm.Expr("GREATEST(fees_outstanding - ?, 0)", delta.FeesApplied),
				colPenaltiesOutstanding: gorm.Expr("GREATEST(penalties_outstanding - ?, 0)", delta.PenaltiesApplied),
				"total_paid":            gorm.Expr("total_paid + ?", delta.Total()),
				colTotalOutstanding:     gorm.Expr("GREATEST(total_outstanding - ?, 0)", delta.Total()),
				colLastCalculatedAt:     &now,
				colModifiedAt:           now,
				colVersion:              gorm.Expr(colVersion + " + 1"),
			})
		if result.Error != nil {
			return result.Error
		}
		if result.RowsAffected == 0 {
			return ErrLoanBalanceNotFound
		}
		return nil
	})
	if err != nil {
		return false, nil, err
	}
	balance, err := a.balances.GetByLoanAccountID(ctx, loanAccountID)
	if err != nil {
		return applied, nil, errors.Join(errors.New("repayment applied but balance unreadable"), err)
	}
	return applied, balance, nil
}
