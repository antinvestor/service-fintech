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

// TenureRepository provides data access for tenures.
type TenureRepository interface {
	datastore.BaseRepository[*models.Tenure]
	GetActiveByGroupID(ctx context.Context, groupID string) (*models.Tenure, error)
}

// NewTenureRepository creates a new TenureRepository.
func NewTenureRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) TenureRepository {
	return &tenureRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.Tenure {
			return &models.Tenure{}
		}),
	}
}

type tenureRepository struct {
	datastore.BaseRepository[*models.Tenure]
}

func (r *tenureRepository) GetActiveByGroupID(ctx context.Context, groupID string) (*models.Tenure, error) {
	var tenure models.Tenure
	err := r.Pool().
		DB(ctx, true).
		Where("group_id = ? AND state != ?", groupID, constants.StateDeleted).
		Order("created_at DESC").
		First(&tenure).
		Error
	return &tenure, err
}
