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

	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
)

type WithdrawalRepository interface {
	datastore.BaseRepository[*models.Withdrawal]
	GetByIdempotencyKey(ctx context.Context, key string) (*models.Withdrawal, error)

	// ClaimWithHold writes the pending withdrawal row and places the balance
	// hold in one transaction. The idempotency key is the authoritative
	// record: a retry carrying the same key loses the insert, receives the
	// stored row with created=false, and places no second hold.
	// ErrInsufficientFunds is returned when available funds cannot cover it,
	// and ErrSavingsBalanceNotFound when the account has no balance row at
	// all: an unprovisioned account is a setup fault, not a poor customer.
	ClaimWithHold(ctx context.Context, wdr *models.Withdrawal) (row *models.Withdrawal, created bool, err error)

	// Settle marks a pending withdrawal completed against its ledger
	// transaction and consumes the hold in one transaction.
	Settle(ctx context.Context, wdr *models.Withdrawal) error

	// ReleaseHold marks a pending withdrawal rejected and returns the held
	// funds to available in one transaction. released is false when the row
	// had already left PENDING, so the caller reports a failed transition
	// rather than a release that never happened.
	ReleaseHold(ctx context.Context, wdr *models.Withdrawal, reason string) (released bool, err error)

	// ReverseSettled marks a completed withdrawal reversed and credits its
	// amount back, for a payout the rail failed after it completed. It
	// reports whether this call reversed it.
	ReverseSettled(ctx context.Context, withdrawalID, reason string) (bool, error)
}

type withdrawalRepository struct {
	datastore.BaseRepository[*models.Withdrawal]
}

func NewWithdrawalRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) WithdrawalRepository {
	return &withdrawalRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Withdrawal](
			ctx, dbPool, workMan, func() *models.Withdrawal { return &models.Withdrawal{} },
		),
	}
}

func (repo *withdrawalRepository) GetByIdempotencyKey(
	ctx context.Context,
	key string,
) (*models.Withdrawal, error) {
	withdrawal := models.Withdrawal{}
	err := repo.Pool().DB(ctx, true).
		First(&withdrawal, "idempotency_key = ?", key).Error
	if err != nil {
		return nil, err
	}
	return &withdrawal, nil
}

func (repo *withdrawalRepository) ClaimWithHold(
	ctx context.Context,
	wdr *models.Withdrawal,
) (*models.Withdrawal, bool, error) {
	err := repo.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		if createErr := tx.Create(wdr).Error; createErr != nil {
			return createErr
		}
		return balanceUpdate(tx, wdr.SavingsAccountID,
			" AND (balance - reserved_balance) >= ?", []any{wdr.Amount},
			map[string]any{colReservedBalance: gorm.Expr("reserved_balance + ?", wdr.Amount)})
	})

	switch {
	case err == nil:
		return wdr, true, nil
	case data.ErrorIsDuplicateKey(err):
		existing, rereadErr := repo.GetByIdempotencyKey(ctx, wdr.IdempotencyKey)
		if rereadErr != nil {
			return nil, false, err
		}
		return existing, false, nil
	case errors.Is(err, ErrBalanceGuardViolated):
		// The guard matches nothing both when funds are short and when the
		// account was never provisioned with a balance row. Those are
		// different faults and must not be reported as the same one.
		var balance models.SavingsBalance
		if lookupErr := repo.Pool().DB(ctx, true).
			First(&balance, "savings_account_id = ? AND deleted_at IS NULL", wdr.SavingsAccountID).
			Error; lookupErr != nil {
			if errors.Is(lookupErr, gorm.ErrRecordNotFound) {
				return nil, false, ErrSavingsBalanceNotFound
			}
			return nil, false, lookupErr
		}
		return nil, false, ErrInsufficientFunds
	default:
		return nil, false, err
	}
}

func (repo *withdrawalRepository) Settle(ctx context.Context, wdr *models.Withdrawal) error {
	return repo.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		claimed, err := claimStatus(tx, wdr,
			savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_COMPLETED,
			map[string]any{colLedgerTxnID: wdr.LedgerTransactionID})
		if err != nil || !claimed {
			return err
		}
		return balanceUpdate(tx, wdr.SavingsAccountID,
			" AND reserved_balance >= ? AND balance >= ?", []any{wdr.Amount, wdr.Amount},
			map[string]any{
				colBalance:          gorm.Expr("balance - ?", wdr.Amount),
				colReservedBalance:  gorm.Expr("reserved_balance - ?", wdr.Amount),
				"total_withdrawals": gorm.Expr("total_withdrawals + ?", wdr.Amount),
			})
	})
}

func (repo *withdrawalRepository) ReleaseHold(
	ctx context.Context,
	wdr *models.Withdrawal,
	reason string,
) (bool, error) {
	var released bool
	err := repo.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		claimed, err := claimStatus(tx, wdr,
			savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_REJECTED,
			map[string]any{"reason": reason})
		if err != nil || !claimed {
			return err
		}
		released = true
		return balanceUpdate(tx, wdr.SavingsAccountID,
			" AND reserved_balance >= ?", []any{wdr.Amount},
			map[string]any{colReservedBalance: gorm.Expr("reserved_balance - ?", wdr.Amount)})
	})
	if err != nil {
		return false, err
	}
	return released, nil
}

func (repo *withdrawalRepository) ReverseSettled(ctx context.Context, withdrawalID, reason string) (bool, error) {
	var reversed bool
	err := repo.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		wdr := &models.Withdrawal{}
		if err := tx.Where("id = ? AND deleted_at IS NULL", withdrawalID).First(wdr).Error; err != nil {
			if data.ErrorIsNoRows(err) {
				return nil
			}
			return err
		}
		res := tx.Table("withdrawals").
			Where("id = ? AND deleted_at IS NULL AND status = ?", withdrawalID,
				int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_COMPLETED)).
			Updates(map[string]any{
				colStatus:     int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_REVERSED),
				"reason":      reason,
				colModifiedAt: gorm.Expr("now()"),
				colVersion:    gorm.Expr("version + 1"),
			})
		if res.Error != nil || res.RowsAffected == 0 {
			return res.Error
		}
		reversed = true
		return balanceUpdate(tx, wdr.SavingsAccountID, "", nil, map[string]any{
			colBalance:          gorm.Expr("balance + ?", wdr.Amount),
			"total_withdrawals": gorm.Expr("total_withdrawals - ?", wdr.Amount),
		})
	})
	return reversed, err
}

// claimStatus moves a withdrawal out of PENDING into next, and reports
// whether this call was the one that made the transition. A false return
// means another caller already settled or released the hold.
func claimStatus(
	tx *gorm.DB,
	wdr *models.Withdrawal,
	next savingsv1.WithdrawalStatus,
	extra map[string]any,
) (bool, error) {
	values := map[string]any{
		colStatus:     int32(next),
		colModifiedAt: gorm.Expr("now()"),
		colVersion:    gorm.Expr("version + 1"),
	}
	for k, v := range extra {
		values[k] = v
	}

	res := tx.Table("withdrawals").
		Where("id = ? AND deleted_at IS NULL AND status = ?", wdr.GetID(),
			int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_PENDING)).
		Updates(values)
	if res.Error != nil {
		return false, res.Error
	}
	return res.RowsAffected > 0, nil
}
