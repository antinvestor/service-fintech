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

package repository //nolint:dupl // similar patterns for different entity types

import (
	"context"

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// PeriodRepository provides data access for periods.
type PeriodRepository interface {
	datastore.BaseRepository[*models.Period]
	GetCurrentByGroupID(ctx context.Context, groupID string) (*models.Period, error)
}

// NewPeriodRepository creates a new PeriodRepository.
func NewPeriodRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) PeriodRepository {
	return &periodRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.Period {
			return &models.Period{}
		}),
	}
}

type periodRepository struct {
	datastore.BaseRepository[*models.Period]
}

func (r *periodRepository) GetCurrentByGroupID(ctx context.Context, groupID string) (*models.Period, error) {
	var period models.Period
	err := r.Pool().
		DB(ctx, true).
		Where("group_id = ? AND state != ?", groupID, constants.StateDeleted).
		Order("created_at DESC").
		First(&period).
		Error
	return &period, err
}
