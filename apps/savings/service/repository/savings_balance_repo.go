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

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
)

// ErrSavingsBalanceNotFound is returned by mutation methods when no balance
// row exists for the target savings account. Callers should provision the row
// via Ensure before any deposit/withdrawal flow runs.
var ErrSavingsBalanceNotFound = errors.New("savings balance not found for account")

// ErrInsufficientFunds is returned when a withdrawal reservation cannot be
// placed because available funds (balance - reserved) are below the requested
// amount. It is the authoritative atomic check and must be surfaced to the
// caller.
var ErrInsufficientFunds = errors.New("insufficient available balance")

// SavingsBalanceRepository exposes atomic balance mutations for a savings
// account. All mutation methods are implemented as single-statement SQL
// UPDATEs guarded by row-level locking in Postgres; no application-side
// optimistic locking is required to keep concurrent flows correct.
type SavingsBalanceRepository interface {
	datastore.BaseRepository[*models.SavingsBalance]

	// GetBySavingsAccountID returns the running balance snapshot for the
	// account, or a wrapped gorm.ErrRecordNotFound if the row has not been
	// provisioned yet.
	GetBySavingsAccountID(ctx context.Context, savingsAccountID string) (*models.SavingsBalance, error)

	// Ensure idempotently creates a zero-value balance row for the account if
	// one does not yet exist. Safe to call repeatedly; the unique index on
	// savings_account_id makes it a no-op on the second call.
	Ensure(
		ctx context.Context,
		savingsAccountID, currencyCode string,
		parent *data.BaseModel,
	) (*models.SavingsBalance, error)

	// Credit atomically increases the balance and the lifetime total_deposits
	// counter. Used to settle deposits after the corresponding transfer
	// order has reached the Ledger successfully.
	Credit(ctx context.Context, savingsAccountID string, amount int64) (*models.SavingsBalance, error)

	// CreditInterest atomically increases the balance and the lifetime
	// total_interest counter. Used by the interest accrual job so interest
	// income is distinguishable from principal deposits in the running
	// balance snapshot.
	CreditInterest(ctx context.Context, savingsAccountID string, amount int64) (*models.SavingsBalance, error)

	// Reserve atomically places a hold on funds for a pending withdrawal.
	// The UPDATE only matches rows where (balance - reserved_balance) >= amount,
	// so two concurrent reservations against overlapping funds serialize
	// correctly and one of them receives ErrInsufficientFunds.
	Reserve(ctx context.Context, savingsAccountID string, amount int64) (*models.SavingsBalance, error)

	// DebitReserved settles a previously reserved withdrawal after its
	// transfer order has reached the Ledger successfully. It decrements both
	// balance and reserved_balance in a single statement.
	DebitReserved(ctx context.Context, savingsAccountID string, amount int64) (*models.SavingsBalance, error)

	// ReleaseReserved rolls back a reservation whose withdrawal was rejected,
	// cancelled, or failed before settlement.
	ReleaseReserved(ctx context.Context, savingsAccountID string, amount int64) (*models.SavingsBalance, error)
}

type savingsBalanceRepository struct {
	datastore.BaseRepository[*models.SavingsBalance]
	dbPool pool.Pool
}

func NewSavingsBalanceRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) SavingsBalanceRepository {
	return &savingsBalanceRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.SavingsBalance {
			return &models.SavingsBalance{}
		}),
		dbPool: dbPool,
	}
}

func (r *savingsBalanceRepository) GetBySavingsAccountID(
	ctx context.Context,
	savingsAccountID string,
) (*models.SavingsBalance, error) {
	entity := &models.SavingsBalance{}
	err := r.dbPool.DB(ctx, true).
		Where("savings_account_id = ?", savingsAccountID).
		First(entity).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrSavingsBalanceNotFound
		}
		return nil, err
	}
	return entity, nil
}

func (r *savingsBalanceRepository) Ensure(
	ctx context.Context,
	savingsAccountID, currencyCode string,
	parent *data.BaseModel,
) (*models.SavingsBalance, error) {
	existing, err := r.GetBySavingsAccountID(ctx, savingsAccountID)
	if err == nil {
		return existing, nil
	}
	if !errors.Is(err, ErrSavingsBalanceNotFound) {
		return nil, err
	}

	row := &models.SavingsBalance{
		SavingsAccountID: savingsAccountID,
		CurrencyCode:     currencyCode,
	}
	if parent != nil {
		row.CopyPartitionInfo(parent)
	}
	row.GenID(ctx)

	// Use the insert path directly. If a concurrent caller beats us to it the
	// unique index will reject the insert and we simply re-read.
	if createErr := r.dbPool.DB(ctx, false).Create(row).Error; createErr != nil {
		if data.ErrorIsDuplicateKey(createErr) {
			return r.GetBySavingsAccountID(ctx, savingsAccountID)
		}
		return nil, createErr
	}
	return row, nil
}

func (r *savingsBalanceRepository) Credit(
	ctx context.Context,
	savingsAccountID string,
	amount int64,
) (*models.SavingsBalance, error) {
	if amount < 0 {
		return nil, errors.New("credit amount must be non-negative")
	}
	now := time.Now().UTC()
	result := r.dbPool.DB(ctx, false).
		Model(&models.SavingsBalance{}).
		Where("savings_account_id = ?", savingsAccountID).
		Updates(map[string]any{
			colBalance:       gorm.Expr("balance + ?", amount),
			"total_deposits": gorm.Expr("total_deposits + ?", amount),
			colModifiedAt:    now,
			colVersion:       gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, ErrSavingsBalanceNotFound
	}
	return r.GetBySavingsAccountID(ctx, savingsAccountID)
}

func (r *savingsBalanceRepository) CreditInterest(
	ctx context.Context,
	savingsAccountID string,
	amount int64,
) (*models.SavingsBalance, error) {
	if amount < 0 {
		return nil, errors.New("interest credit amount must be non-negative")
	}
	now := time.Now().UTC()
	result := r.dbPool.DB(ctx, false).
		Model(&models.SavingsBalance{}).
		Where("savings_account_id = ?", savingsAccountID).
		Updates(map[string]any{
			colBalance:       gorm.Expr("balance + ?", amount),
			"total_interest": gorm.Expr("total_interest + ?", amount),
			colModifiedAt:    now,
			colVersion:       gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, ErrSavingsBalanceNotFound
	}
	return r.GetBySavingsAccountID(ctx, savingsAccountID)
}

func (r *savingsBalanceRepository) Reserve(
	ctx context.Context,
	savingsAccountID string,
	amount int64,
) (*models.SavingsBalance, error) {
	if amount <= 0 {
		return nil, errors.New("reserve amount must be positive")
	}
	now := time.Now().UTC()
	result := r.dbPool.DB(ctx, false).
		Model(&models.SavingsBalance{}).
		Where("savings_account_id = ? AND (balance - reserved_balance) >= ?", savingsAccountID, amount).
		Updates(map[string]any{
			colReservedBalance: gorm.Expr("reserved_balance + ?", amount),
			colModifiedAt:      now,
			colVersion:         gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		// Either the row does not exist at all or the balance guard failed.
		// Distinguish between the two so callers get a useful error.
		if _, lookupErr := r.GetBySavingsAccountID(ctx, savingsAccountID); lookupErr != nil {
			return nil, lookupErr
		}
		return nil, ErrInsufficientFunds
	}
	return r.GetBySavingsAccountID(ctx, savingsAccountID)
}

func (r *savingsBalanceRepository) DebitReserved(
	ctx context.Context,
	savingsAccountID string,
	amount int64,
) (*models.SavingsBalance, error) {
	if amount <= 0 {
		return nil, errors.New("debit amount must be positive")
	}
	now := time.Now().UTC()
	result := r.dbPool.DB(ctx, false).
		Model(&models.SavingsBalance{}).
		Where("savings_account_id = ? AND reserved_balance >= ? AND balance >= ?", savingsAccountID, amount, amount).
		Updates(map[string]any{
			colBalance:          gorm.Expr("balance - ?", amount),
			colReservedBalance:  gorm.Expr("reserved_balance - ?", amount),
			"total_withdrawals": gorm.Expr("total_withdrawals + ?", amount),
			colModifiedAt:       now,
			colVersion:          gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		if _, lookupErr := r.GetBySavingsAccountID(ctx, savingsAccountID); lookupErr != nil {
			return nil, lookupErr
		}
		return nil, errors.New("debit violated reservation invariant: reserved or balance below requested amount")
	}
	return r.GetBySavingsAccountID(ctx, savingsAccountID)
}

func (r *savingsBalanceRepository) ReleaseReserved(
	ctx context.Context,
	savingsAccountID string,
	amount int64,
) (*models.SavingsBalance, error) {
	if amount <= 0 {
		return nil, errors.New("release amount must be positive")
	}
	now := time.Now().UTC()
	result := r.dbPool.DB(ctx, false).
		Model(&models.SavingsBalance{}).
		Where("savings_account_id = ? AND reserved_balance >= ?", savingsAccountID, amount).
		Updates(map[string]any{
			colReservedBalance: gorm.Expr("reserved_balance - ?", amount),
			colModifiedAt:      now,
			colVersion:         gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		if _, lookupErr := r.GetBySavingsAccountID(ctx, savingsAccountID); lookupErr != nil {
			return nil, lookupErr
		}
		return nil, errors.New("release exceeded reserved balance")
	}
	return r.GetBySavingsAccountID(ctx, savingsAccountID)
}
