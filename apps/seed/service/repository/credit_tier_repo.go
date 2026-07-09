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

	"github.com/antinvestor/service-fintech/apps/seed/service/models"
)

// CreditTierRepository owns the seed_credit_tiers ladder. The tier
// config is small (a handful of rows per product) and rarely mutates,
// so the read surface loads the whole ladder for a product at once.
type CreditTierRepository interface {
	datastore.BaseRepository[*models.CreditTierConfig]

	// ListForProduct returns every tier row for the given product and
	// currency, ordered ascending by MinSuccessfulRepayments so callers
	// can walk them in "lowest-requirement-first" order. EvaluateTier
	// (in the business layer) picks the highest rung whose threshold
	// is met.
	ListForProduct(
		ctx context.Context,
		productID, currencyCode string,
	) ([]*models.CreditTierConfig, error)
}

type creditTierRepository struct {
	datastore.BaseRepository[*models.CreditTierConfig]
	dbPool pool.Pool
}

// NewCreditTierRepository constructs a repository bound to the given pool.
func NewCreditTierRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) CreditTierRepository {
	return &creditTierRepository{
		BaseRepository: datastore.NewBaseRepository[*models.CreditTierConfig](
			ctx, dbPool, workMan, func() *models.CreditTierConfig { return &models.CreditTierConfig{} },
		),
		dbPool: dbPool,
	}
}

func (r *creditTierRepository) ListForProduct(
	ctx context.Context,
	productID, currencyCode string,
) ([]*models.CreditTierConfig, error) {
	var rows []*models.CreditTierConfig
	err := r.dbPool.DB(ctx, true).
		Where("product_id = ? AND currency_code = ?", productID, currencyCode).
		Order("min_successful_repayments ASC, tier ASC").
		Find(&rows).Error
	if err != nil {
		return nil, err
	}
	return rows, nil
}
