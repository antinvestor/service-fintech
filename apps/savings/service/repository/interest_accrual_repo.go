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

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
)

type InterestAccrualRepository interface {
	datastore.BaseRepository[*models.InterestAccrual]
	// GetByAccountAndPeriod returns the accrual row for a specific closing
	// period if one exists. Used by the accrual job to detect reruns and
	// avoid double-crediting a member's interest.
	GetByAccountAndPeriod(
		ctx context.Context,
		savingsAccountID string,
		periodEnd time.Time,
	) (*models.InterestAccrual, error)

	// Claim writes the accrual row synchronously so it is the authoritative
	// idempotency record for (savings_account_id, period_end). A concurrent
	// or rerun accrual for the same closing period loses the insert and
	// receives the stored row with created=false.
	Claim(ctx context.Context, ia *models.InterestAccrual) (row *models.InterestAccrual, created bool, err error)

	// Settle records the ledger transaction on a claimed accrual and credits
	// the running balance interest counter in one database transaction. An
	// accrual with no ledger transaction id is rejected: storing an empty id
	// would leave the settlement guard satisfied and let a rerun credit the
	// interest twice.
	Settle(ctx context.Context, ia *models.InterestAccrual) error
}

// ErrLedgerTransactionIDRequired is returned when a settlement is attempted
// without the ledger transaction it is supposed to record.
var ErrLedgerTransactionIDRequired = errors.New("ledger transaction id is required to settle")

type interestAccrualRepository struct {
	datastore.BaseRepository[*models.InterestAccrual]
	dbPool pool.Pool
}

func NewInterestAccrualRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) InterestAccrualRepository {
	return &interestAccrualRepository{
		BaseRepository: datastore.NewBaseRepository[*models.InterestAccrual](
			ctx, dbPool, workMan, func() *models.InterestAccrual { return &models.InterestAccrual{} },
		),
		dbPool: dbPool,
	}
}

func (r *interestAccrualRepository) GetByAccountAndPeriod(
	ctx context.Context,
	savingsAccountID string,
	periodEnd time.Time,
) (*models.InterestAccrual, error) {
	entity := &models.InterestAccrual{}
	err := r.dbPool.DB(ctx, true).
		Where("savings_account_id = ? AND period_end = ?", savingsAccountID, periodEnd).
		First(entity).Error
	if err != nil {
		return nil, err
	}
	return entity, nil
}

func (r *interestAccrualRepository) Claim(
	ctx context.Context,
	ia *models.InterestAccrual,
) (*models.InterestAccrual, bool, error) {
	return claimRow(ctx, r.dbPool.DB(ctx, false), ia, func(innerCtx context.Context) (*models.InterestAccrual, error) {
		return r.GetByAccountAndPeriod(innerCtx, ia.SavingsAccountID, *ia.PeriodEnd)
	})
}

func (r *interestAccrualRepository) Settle(ctx context.Context, ia *models.InterestAccrual) error {
	if ia.LedgerTransactionID == "" {
		return ErrLedgerTransactionIDRequired
	}
	return r.dbPool.DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		res := tx.Table("interest_accruals").
			Where("id = ? AND deleted_at IS NULL AND ledger_transaction_id = ?", ia.GetID(), "").
			Updates(map[string]any{
				colLedgerTxnID: ia.LedgerTransactionID,
				colModifiedAt:  gorm.Expr("now()"),
				colVersion:     gorm.Expr("version + 1"),
			})
		if res.Error != nil {
			return res.Error
		}
		if res.RowsAffected == 0 {
			// Another run already settled this accrual and credited interest.
			return nil
		}

		return balanceUpdate(tx, ia.SavingsAccountID, "", nil, map[string]any{
			colBalance:       gorm.Expr("balance + ?", ia.Amount),
			"total_interest": gorm.Expr("total_interest + ?", ia.Amount),
		})
	})
}
