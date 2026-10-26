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

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
)

// InvestorCapitalMovementRepository owns the durable record of investor
// deposits and withdrawals.
type InvestorCapitalMovementRepository interface {
	datastore.BaseRepository[*models.InvestorCapitalMovement]

	// Claim writes the movement synchronously. When a movement already holds
	// the same (investor_account_id, idempotency_key) the insert loses and
	// the stored row is returned with created=false. The caller inspects the
	// stored status: only a COMPLETED movement is finished, anything else is
	// an attempt that died part-way and has to be resumed.
	Claim(
		ctx context.Context,
		movement *models.InvestorCapitalMovement,
	) (row *models.InvestorCapitalMovement, created bool, err error)

	// GetByIdempotencyKey returns the movement recorded for an account under
	// a given key.
	GetByIdempotencyKey(
		ctx context.Context,
		accountID, idempotencyKey string,
	) (*models.InvestorCapitalMovement, error)

	// MarkCompleted records that the movement's ledger posting and balance
	// change both landed. It is guarded on the movement not already being
	// completed so a resumed attempt cannot bump the row twice.
	MarkCompleted(ctx context.Context, movementID string) error

	// CreditDeposit applies a deposit: it moves the movement from PENDING to
	// COMPLETED and credits the investor's available balance in a single
	// transaction. applied is false when another attempt already completed
	// the movement, and in that case no money moves.
	CreditDeposit(ctx context.Context, movement *models.InvestorCapitalMovement) (applied bool, err error)

	// DebitWithdrawal takes the funds out of the investor's available balance
	// and moves the movement from PENDING to DEBITED in a single transaction,
	// so a crash between the two can never lose track of a debit. applied is
	// false when the movement has already left PENDING. The balance guard
	// returns ErrInvestorInsufficientFunds when free capital cannot cover it.
	DebitWithdrawal(ctx context.Context, movement *models.InvestorCapitalMovement) (applied bool, err error)

	// RevertCompletedWithdrawal returns the funds of a completed withdrawal
	// the payment rail failed afterwards and marks it reverted. It reports
	// whether this call reverted it.
	RevertCompletedWithdrawal(ctx context.Context, movementID string) (bool, error)
	// RevertWithdrawalDebit undoes DebitWithdrawal, returning the funds and
	// putting the movement back to PENDING so the caller can retry.
	RevertWithdrawalDebit(ctx context.Context, movement *models.InvestorCapitalMovement) error
}

type investorCapitalMovementRepository struct {
	datastore.BaseRepository[*models.InvestorCapitalMovement]
}

// NewInvestorCapitalMovementRepository creates an InvestorCapitalMovementRepository.
func NewInvestorCapitalMovementRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) InvestorCapitalMovementRepository {
	return &investorCapitalMovementRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.InvestorCapitalMovement {
			return &models.InvestorCapitalMovement{}
		}),
	}
}

func (r *investorCapitalMovementRepository) GetByIdempotencyKey(
	ctx context.Context,
	accountID, idempotencyKey string,
) (*models.InvestorCapitalMovement, error) {
	movement := &models.InvestorCapitalMovement{}
	err := r.Pool().DB(ctx, true).
		First(movement, "investor_account_id = ? AND idempotency_key = ?", accountID, idempotencyKey).Error
	if err != nil {
		return nil, err
	}
	return movement, nil
}

func (r *investorCapitalMovementRepository) Claim(
	ctx context.Context,
	movement *models.InvestorCapitalMovement,
) (*models.InvestorCapitalMovement, bool, error) {
	err := r.Pool().DB(ctx, false).Create(movement).Error
	if err == nil {
		return movement, true, nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return nil, false, err
	}
	existing, rereadErr := r.GetByIdempotencyKey(ctx, movement.InvestorAccountID, movement.IdempotencyKey)
	if rereadErr != nil {
		return nil, false, err
	}
	return existing, false, nil
}

func (r *investorCapitalMovementRepository) MarkCompleted(ctx context.Context, movementID string) error {
	return r.Pool().DB(ctx, false).
		Table("investor_capital_movements").
		Where("id = ? AND deleted_at IS NULL AND status <> ?", movementID, models.CapitalMovementCompleted).
		Updates(map[string]any{
			"status":      models.CapitalMovementCompleted,
			colModifiedAt: gormNow(),
			colVersion:    gormVersionIncrement(),
		}).Error
}

func (r *investorCapitalMovementRepository) CreditDeposit(
	ctx context.Context,
	movement *models.InvestorCapitalMovement,
) (bool, error) {
	var applied bool
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		claimed, claimErr := claimMovementStatus(
			tx, movement.GetID(), models.CapitalMovementPending, models.CapitalMovementCompleted)
		if claimErr != nil || !claimed {
			return claimErr
		}
		applied = true
		return investorBalanceUpdate(tx, movement.InvestorAccountID, "", nil, map[string]any{
			colAvailableBalance: gorm.Expr("available_balance + ?", movement.Amount),
		})
	})
	if err != nil {
		return false, err
	}
	return applied, nil
}

func (r *investorCapitalMovementRepository) DebitWithdrawal(
	ctx context.Context,
	movement *models.InvestorCapitalMovement,
) (bool, error) {
	var applied bool
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		claimed, claimErr := claimMovementStatus(
			tx, movement.GetID(), models.CapitalMovementPending, models.CapitalMovementDebited)
		if claimErr != nil || !claimed {
			return claimErr
		}
		applied = true
		return investorBalanceUpdate(tx, movement.InvestorAccountID,
			" AND (available_balance - reserved_balance) >= ?", []any{movement.Amount},
			map[string]any{colAvailableBalance: gorm.Expr("available_balance - ?", movement.Amount)})
	})
	switch {
	case err == nil:
		return applied, nil
	case errors.Is(err, errInvestorBalanceGuard):
		return false, ErrInvestorInsufficientFunds
	default:
		return false, err
	}
}

func (r *investorCapitalMovementRepository) RevertCompletedWithdrawal(
	ctx context.Context,
	movementID string,
) (bool, error) {
	var reverted bool
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		movement := &models.InvestorCapitalMovement{}
		if err := tx.Where("id = ? AND deleted_at IS NULL AND direction = ?",
			movementID, int32(models.CapitalMovementWithdraw)).First(movement).Error; err != nil {
			if data.ErrorIsNoRows(err) {
				return nil
			}
			return err
		}
		claimed, err := claimMovementStatus(
			tx, movementID, models.CapitalMovementCompleted, models.CapitalMovementReverted)
		if err != nil || !claimed {
			return err
		}
		reverted = true
		return investorBalanceUpdate(tx, movement.InvestorAccountID, "", nil, map[string]any{
			colAvailableBalance: gorm.Expr("available_balance + ?", movement.Amount),
		})
	})
	return reverted, err
}

func (r *investorCapitalMovementRepository) RevertWithdrawalDebit(
	ctx context.Context,
	movement *models.InvestorCapitalMovement,
) error {
	return r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		claimed, claimErr := claimMovementStatus(
			tx, movement.GetID(), models.CapitalMovementDebited, models.CapitalMovementPending)
		if claimErr != nil || !claimed {
			return claimErr
		}
		return investorBalanceUpdate(tx, movement.InvestorAccountID, "", nil, map[string]any{
			colAvailableBalance: gorm.Expr("available_balance + ?", movement.Amount),
		})
	})
}

// claimMovementStatus moves one movement from an expected status to the next
// one and reports whether this call was the one that made the move.
func claimMovementStatus(tx *gorm.DB, movementID string, from, to int32) (bool, error) {
	res := tx.Table("investor_capital_movements").
		Where("id = ? AND deleted_at IS NULL AND status = ?", movementID, from).
		Updates(map[string]any{
			"status":      to,
			colModifiedAt: gormNow(),
			colVersion:    gormVersionIncrement(),
		})
	if res.Error != nil {
		return false, res.Error
	}
	return res.RowsAffected > 0, nil
}

// errInvestorBalanceGuard reports that a guarded balance update matched no
// row, so the transaction has to roll back rather than silently do nothing.
var errInvestorBalanceGuard = errors.New("investor balance guard rejected the mutation")

// investorBalanceUpdate applies a guarded arithmetic update to one investor
// account inside the caller's transaction.
func investorBalanceUpdate(
	tx *gorm.DB,
	accountID, guard string,
	guardArgs []any,
	values map[string]any,
) error {
	values[colModifiedAt] = gormNow()
	values[colVersion] = gormVersionIncrement()

	where := append([]any{accountID}, guardArgs...)
	res := tx.Table("investor_accounts").
		Where("id = ? AND deleted_at IS NULL"+guard, where...).
		Updates(values)
	if res.Error != nil {
		return res.Error
	}
	if res.RowsAffected == 0 {
		return errInvestorBalanceGuard
	}
	return nil
}
