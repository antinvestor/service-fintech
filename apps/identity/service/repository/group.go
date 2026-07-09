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

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

type ClientGroupRepository interface {
	datastore.BaseRepository[*models.ClientGroup]
	GetByAgentID(ctx context.Context, agentID string, offset, limit int) ([]*models.ClientGroup, error)
}

type clientGroupRepository struct {
	datastore.BaseRepository[*models.ClientGroup]
}

func NewClientGroupRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) ClientGroupRepository {
	return &clientGroupRepository{
		BaseRepository: datastore.NewBaseRepository[*models.ClientGroup](
			ctx, dbPool, workMan, func() *models.ClientGroup { return &models.ClientGroup{} },
		),
	}
}

func (repo *clientGroupRepository) GetByAgentID(
	ctx context.Context,
	agentID string,
	offset, limit int,
) ([]*models.ClientGroup, error) {
	var groups []*models.ClientGroup
	err := repo.Pool().DB(ctx, true).
		Where("agent_id = ?", agentID).
		Offset(offset).Limit(limit).
		Find(&groups).Error
	if err != nil {
		return nil, err
	}
	return groups, nil
}
