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

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

type ClientProductAccessRepository interface {
	datastore.BaseRepository[*models.ClientProductAccess]
	GetByClientAndProduct(ctx context.Context, clientID, productID string) (*models.ClientProductAccess, error)
}

type clientProductAccessRepository struct {
	datastore.BaseRepository[*models.ClientProductAccess]
}

func NewClientProductAccessRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) ClientProductAccessRepository {
	return &clientProductAccessRepository{
		BaseRepository: datastore.NewBaseRepository[*models.ClientProductAccess](
			ctx, dbPool, workMan, func() *models.ClientProductAccess { return &models.ClientProductAccess{} },
		),
	}
}

func (repo *clientProductAccessRepository) GetByClientAndProduct(
	ctx context.Context,
	clientID, productID string,
) (*models.ClientProductAccess, error) {
	cpa := models.ClientProductAccess{}
	err := repo.Pool().DB(ctx, true).
		First(&cpa, "client_id = ? AND product_id = ?", clientID, productID).Error
	if err != nil {
		return nil, err
	}
	return &cpa, nil
}
