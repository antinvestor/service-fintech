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

type ClientAssignmentHistoryRepository interface {
	datastore.BaseRepository[*models.ClientAssignmentHistory]
	GetByClientID(ctx context.Context, clientID string) ([]*models.ClientAssignmentHistory, error)
}

type clientAssignmentHistoryRepository struct {
	datastore.BaseRepository[*models.ClientAssignmentHistory]
}

func NewClientAssignmentHistoryRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) ClientAssignmentHistoryRepository {
	return &clientAssignmentHistoryRepository{
		BaseRepository: datastore.NewBaseRepository[*models.ClientAssignmentHistory](
			ctx,
			dbPool,
			workMan,
			func() *models.ClientAssignmentHistory { return &models.ClientAssignmentHistory{} },
		),
	}
}

func (repo *clientAssignmentHistoryRepository) GetByClientID(
	ctx context.Context,
	clientID string,
) ([]*models.ClientAssignmentHistory, error) {
	var history []*models.ClientAssignmentHistory
	err := repo.Pool().DB(ctx, true).
		Where("client_id = ?", clientID).
		Order("created_at DESC").
		Find(&history).Error
	if err != nil {
		return nil, err
	}
	return history, nil
}
