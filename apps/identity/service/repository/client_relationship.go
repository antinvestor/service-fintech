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

type ClientRelationshipRepository interface {
	datastore.BaseRepository[*models.ClientRelationship]
	GetByClientAndMember(ctx context.Context, clientID, memberID string) (*models.ClientRelationship, error)
	GetPrimaryForClient(ctx context.Context, clientID string) (*models.ClientRelationship, error)
}

type clientRelationshipRepository struct {
	datastore.BaseRepository[*models.ClientRelationship]
}

func NewClientRelationshipRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) ClientRelationshipRepository {
	return &clientRelationshipRepository{
		BaseRepository: datastore.NewBaseRepository[*models.ClientRelationship](
			ctx, dbPool, workMan, func() *models.ClientRelationship { return &models.ClientRelationship{} },
		),
	}
}

func (repo *clientRelationshipRepository) GetByClientAndMember(
	ctx context.Context,
	clientID, memberID string,
) (*models.ClientRelationship, error) {
	cr := models.ClientRelationship{}
	err := repo.Pool().DB(ctx, true).
		First(&cr, "client_id = ? AND member_id = ?", clientID, memberID).Error
	if err != nil {
		return nil, err
	}
	return &cr, nil
}

func (repo *clientRelationshipRepository) GetPrimaryForClient(
	ctx context.Context,
	clientID string,
) (*models.ClientRelationship, error) {
	cr := models.ClientRelationship{}
	err := repo.Pool().DB(ctx, true).
		First(&cr, "client_id = ? AND is_primary = true", clientID).Error
	if err != nil {
		return nil, err
	}
	return &cr, nil
}
