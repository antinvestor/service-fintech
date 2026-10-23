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
	"time"

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
)

// TransferOrderRepository provides data access for transfer orders.
type TransferOrderRepository interface {
	datastore.BaseRepository[*models.TransferOrder]
	// GetByReference looks up a transfer order by its caller-supplied reference.
	// The reference is used as an idempotency key: callers must pass a stable,
	// deterministic value (e.g. "repayment:{id}:principal") and a unique index
	// enforces at-most-one row per non-empty reference.
	GetByReference(ctx context.Context, reference string) (*models.TransferOrder, error)

	// CreateIfAbsent inserts the order synchronously. When a row with the same
	// reference already exists the caller's order is populated from it and no
	// second row is written, so Save is safe to retry and the returned order
	// always names a row that is readable right after the call.
	CreateIfAbsent(ctx context.Context, order *models.TransferOrder) error

	// ClaimState conditionally moves an order out of one of fromStates into
	// toState in a single UPDATE. It reports whether this caller won the claim.
	ClaimState(ctx context.Context, orderID string, fromStates []int32, toState int32) (bool, error)
}

// NewTransferOrderRepository creates a new TransferOrderRepository.
func NewTransferOrderRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) TransferOrderRepository {
	return &transferOrderRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.TransferOrder {
			return &models.TransferOrder{}
		}),
		dbPool: dbPool,
	}
}

type transferOrderRepository struct {
	datastore.BaseRepository[*models.TransferOrder]
	dbPool pool.Pool
}

func (r *transferOrderRepository) CreateIfAbsent(ctx context.Context, order *models.TransferOrder) error {
	err := r.dbPool.DB(ctx, false).Create(order).Error
	if err == nil {
		return nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return err
	}

	existing, refErr := r.GetByReference(ctx, order.Reference)
	if refErr != nil {
		return err
	}
	copyStoredOrder(order, existing)
	return nil
}

// copyStoredOrder aligns an in-memory order with the row that already owns its
// reference so callers execute the winning row rather than a phantom id.
func copyStoredOrder(order, existing *models.TransferOrder) {
	order.ID = existing.ID
	order.State = existing.State
	order.CreatedAt = existing.CreatedAt
	order.ModifiedAt = existing.ModifiedAt
	order.Version = existing.Version
}

func (r *transferOrderRepository) ClaimState(
	ctx context.Context,
	orderID string,
	fromStates []int32,
	toState int32,
) (bool, error) {
	// Table, not Model: an empty model instance has its primary key filled in
	// by the frame BaseModel hooks, which would add a bogus id to the WHERE.
	result := r.dbPool.DB(ctx, false).
		Table("transfer_orders").
		Where("deleted_at IS NULL AND id = ? AND state IN ?", orderID, fromStates).
		Updates(map[string]any{
			colState:      toState,
			colModifiedAt: time.Now().UTC(),
			colVersion:    gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (r *transferOrderRepository) GetByReference(
	ctx context.Context,
	reference string,
) (*models.TransferOrder, error) {
	if reference == "" {
		return nil, gorm.ErrRecordNotFound
	}
	entity := &models.TransferOrder{}
	err := r.dbPool.DB(ctx, true).Where("reference = ?", reference).First(entity).Error
	if err != nil {
		return nil, err
	}
	return entity, nil
}
