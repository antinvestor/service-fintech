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
