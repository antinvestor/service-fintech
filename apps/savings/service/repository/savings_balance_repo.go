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

	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
)

// ErrSavingsBalanceNotFound is returned when no balance row exists for the
// target savings account. Callers should provision the row via Ensure before
// any deposit/withdrawal flow runs.
var ErrSavingsBalanceNotFound = errors.New("savings balance not found for account")

// ErrInsufficientFunds is returned when a withdrawal reservation cannot be
// placed because available funds (balance - reserved) are below the requested
// amount. It is the authoritative atomic check and must be surfaced to the
// caller.
var ErrInsufficientFunds = errors.New("insufficient available balance")

// SavingsBalanceRepository exposes the running-balance row for a savings
// account. Balance mutations do not live here: every one of them belongs to
// a money movement and is applied in the same transaction as that movement's
// row, by DepositRepository.Settle, WithdrawalRepository.ClaimWithHold /
// Settle / ReleaseHold, and InterestAccrualRepository.Settle. Keeping a
// single write path is what makes the row and the movement impossible to
// disagree.
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

	// OpeningBalance is the settled balance the account held immediately
	// before `at`, summed from the completed movements that preceded it. It
	// is the anchor a statement's running balance is computed from.
	OpeningBalance(ctx context.Context, savingsAccountID string, at time.Time) (int64, error)
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

func (r *savingsBalanceRepository) OpeningBalance(
	ctx context.Context,
	savingsAccountID string,
	at time.Time,
) (int64, error) {
	db := r.dbPool.DB(ctx, true)

	sum := func(table, statusColumn string, status int32) (int64, error) {
		var total *int64
		q := db.Table(table).
			Where("savings_account_id = ? AND created_at < ?", savingsAccountID, at)
		if statusColumn != "" {
			q = q.Where(statusColumn, status)
		}
		if err := q.Select("SUM(amount)").Scan(&total).Error; err != nil {
			return 0, err
		}
		if total == nil {
			return 0, nil
		}
		return *total, nil
	}

	deposits, err := sum("deposits", "status = ?",
		int32(savingsv1.DepositStatus_DEPOSIT_STATUS_COMPLETED))
	if err != nil {
		return 0, err
	}
	withdrawals, err := sum("withdrawals", "status = ?",
		int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_COMPLETED))
	if err != nil {
		return 0, err
	}
	interest, err := sum("interest_accruals", "", 0)
	if err != nil {
		return 0, err
	}

	return deposits + interest - withdrawals, nil
}
