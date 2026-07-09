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

package repository //nolint:dupl // similar repository patterns for different entity types

import (
	"context"

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
)

type DepositRepository interface {
	datastore.BaseRepository[*models.Deposit]
	GetByIdempotencyKey(ctx context.Context, key string) (*models.Deposit, error)
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
