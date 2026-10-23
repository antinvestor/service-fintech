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

	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
)

type DepositRepository interface {
	datastore.BaseRepository[*models.Deposit]
	GetByIdempotencyKey(ctx context.Context, key string) (*models.Deposit, error)

	// Claim writes the pending deposit row synchronously so it is the
	// authoritative idempotency record: a concurrent or retried call carrying
	// the same idempotency key loses the insert and receives the stored row
	// with created=false, without moving any money a second time.
	Claim(ctx context.Context, dep *models.Deposit) (row *models.Deposit, created bool, err error)

	// Settle marks a claimed deposit completed against its ledger transaction
	// and credits the running balance in one database transaction, so the
	// deposit row and the balance can never disagree.
	Settle(ctx context.Context, dep *models.Deposit, amount int64) error
}

type depositRepository struct {
	datastore.BaseRepository[*models.Deposit]
}

func NewDepositRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) DepositRepository {
	return &depositRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Deposit](
			ctx, dbPool, workMan, func() *models.Deposit { return &models.Deposit{} },
		),
	}
}

func (repo *depositRepository) GetByIdempotencyKey(
	ctx context.Context,
	key string,
) (*models.Deposit, error) {
	deposit := models.Deposit{}
	err := repo.Pool().DB(ctx, true).
		First(&deposit, "idempotency_key = ?", key).Error
	if err != nil {
		return nil, err
	}
	return &deposit, nil
}

func (repo *depositRepository) Claim(
	ctx context.Context,
	dep *models.Deposit,
) (*models.Deposit, bool, error) {
	return claimRow(ctx, repo.Pool().DB(ctx, false), dep, func(innerCtx context.Context) (*models.Deposit, error) {
		return repo.GetByIdempotencyKey(innerCtx, dep.IdempotencyKey)
	})
}

func (repo *depositRepository) Settle(ctx context.Context, dep *models.Deposit, amount int64) error {
	return repo.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		res := tx.Table("deposits").
			Where("id = ? AND deleted_at IS NULL AND status = ?", dep.GetID(),
				int32(savingsv1.DepositStatus_DEPOSIT_STATUS_PENDING)).
			Updates(map[string]any{
				"status":       int32(savingsv1.DepositStatus_DEPOSIT_STATUS_COMPLETED),
				colLedgerTxnID: dep.LedgerTransactionID,
				colModifiedAt:  gorm.Expr("now()"),
				colVersion:     gorm.Expr("version + 1"),
			})
		if res.Error != nil {
			return res.Error
		}
		if res.RowsAffected == 0 {
			// Another settlement already completed this deposit; the balance
			// credit went with it, so this call must not credit again.
			return nil
		}

		return balanceUpdate(tx, dep.SavingsAccountID, "", nil, map[string]any{
			colBalance:       gorm.Expr("balance + ?", amount),
			"total_deposits": gorm.Expr("total_deposits + ?", amount),
		})
	})
}
