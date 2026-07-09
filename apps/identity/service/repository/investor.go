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

type InvestorRepository interface {
	datastore.BaseRepository[*models.Investor]
	GetByProfileID(ctx context.Context, profileID string) (*models.Investor, error)
}

type investorRepository struct {
	datastore.BaseRepository[*models.Investor]
}

func NewInvestorRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) InvestorRepository {
	return &investorRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Investor](
			ctx, dbPool, workMan, func() *models.Investor { return &models.Investor{} },
		),
	}
}

func (repo *investorRepository) GetByProfileID(ctx context.Context, profileID string) (*models.Investor, error) {
	investor := models.Investor{}
	err := repo.Pool().DB(ctx, true).First(&investor, "profile_id = ?", profileID).Error
	if err != nil {
		return nil, err
	}
	return &investor, nil
}
