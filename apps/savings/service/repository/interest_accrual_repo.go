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

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"

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
}

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
