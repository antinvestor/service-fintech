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

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
)

// LossAbsorptionRepository owns the durable record of absorbed losses.
type LossAbsorptionRepository interface {
	datastore.BaseRepository[*models.LossAbsorption]

	// Claim takes the absorption lock for a loss reference. created=false
	// returns the stored result of the call that won.
	Claim(
		ctx context.Context,
		absorption *models.LossAbsorption,
	) (row *models.LossAbsorption, created bool, err error)

	// GetByReference returns the absorption recorded under a reference.
	GetByReference(ctx context.Context, reference string) (*models.LossAbsorption, error)

	// Finalize records what the tranches actually covered once the walk is
	// done, so a later repeat of the same reference reports the same split.
	Finalize(ctx context.Context, id string, absorbed, unrecoverable int64) error
}

type lossAbsorptionRepository struct {
	datastore.BaseRepository[*models.LossAbsorption]
}

// NewLossAbsorptionRepository creates a LossAbsorptionRepository.
func NewLossAbsorptionRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) LossAbsorptionRepository {
	return &lossAbsorptionRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.LossAbsorption {
			return &models.LossAbsorption{}
		}),
	}
}

func (r *lossAbsorptionRepository) GetByReference(
	ctx context.Context,
	reference string,
) (*models.LossAbsorption, error) {
	absorption := &models.LossAbsorption{}
	if err := r.Pool().DB(ctx, true).First(absorption, "reference = ?", reference).Error; err != nil {
		return nil, err
	}
	return absorption, nil
}

func (r *lossAbsorptionRepository) Claim(
	ctx context.Context,
	absorption *models.LossAbsorption,
) (*models.LossAbsorption, bool, error) {
	err := r.Pool().DB(ctx, false).Create(absorption).Error
	if err == nil {
		return absorption, true, nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return nil, false, err
	}
	existing, rereadErr := r.GetByReference(ctx, absorption.Reference)
	if rereadErr != nil {
		return nil, false, err
	}
	return existing, false, nil
}

func (r *lossAbsorptionRepository) Finalize(ctx context.Context, id string, absorbed, unrecoverable int64) error {
	return r.Pool().DB(ctx, false).
		Table("loss_absorptions").
		Where("id = ? AND deleted_at IS NULL", id).
		Updates(map[string]any{
			"absorbed":      absorbed,
			"unrecoverable": unrecoverable,
			colModifiedAt:   gormNow(),
			colVersion:      gormVersionIncrement(),
		}).Error
}
