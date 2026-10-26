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

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// TenureRepository provides data access for tenures.
type TenureRepository interface {
	datastore.BaseRepository[*models.Tenure]
	GetActiveByGroupID(ctx context.Context, groupID string) (*models.Tenure, error)
	// LatestByGroupIDs returns each named group's most recent tenure; a
	// group with none is absent from the map.
	LatestByGroupIDs(ctx context.Context, groupIDs []string) (map[string]*models.Tenure, error)
	// ListPendingSetup returns up to limit active tenures whose setup has
	// not finished and is not held off after a failure.
	ListPendingSetup(ctx context.Context, now time.Time, limit int) ([]*models.Tenure, error)
	// ListDueForCheck returns up to limit active tenures whose group was
	// last compared with identity before checkedBefore, or never.
	ListDueForCheck(ctx context.Context, checkedBefore time.Time, limit int) ([]*models.Tenure, error)
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

func (r *tenureRepository) LatestByGroupIDs(
	ctx context.Context,
	groupIDs []string,
) (map[string]*models.Tenure, error) {
	latest := make(map[string]*models.Tenure, len(groupIDs))
	if len(groupIDs) == 0 {
		return latest, nil
	}
	var tenures []*models.Tenure
	err := r.Pool().DB(ctx, true).
		Where("group_id IN ? AND state != ?", groupIDs, constants.StateDeleted).
		Order("created_at ASC").Find(&tenures).Error
	if err != nil {
		return nil, err
	}
	for _, t := range tenures {
		latest[t.GroupID] = t
	}
	return latest, nil
}

func (r *tenureRepository) ListPendingSetup(ctx context.Context, now time.Time, limit int) ([]*models.Tenure, error) {
	var tenures []*models.Tenure
	err := r.Pool().DB(ctx, true).
		Where("state = ? AND welcomed = ? AND (setup_retry_at IS NULL OR setup_retry_at <= ?)",
			constants.StateActive, false, now).
		Order("created_at ASC").Limit(limit).Find(&tenures).Error
	return tenures, err
}

func (r *tenureRepository) ListDueForCheck(
	ctx context.Context,
	checkedBefore time.Time,
	limit int,
) ([]*models.Tenure, error) {
	var tenures []*models.Tenure
	err := r.Pool().DB(ctx, true).
		Where("state = ? AND (checked_at IS NULL OR checked_at < ?)", constants.StateActive, checkedBefore).
		Order("checked_at ASC NULLS FIRST").Limit(limit).Find(&tenures).Error
	return tenures, err
}
