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

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

type BranchRepository interface {
	datastore.BaseRepository[*models.Branch]
	GetByCode(ctx context.Context, code string) (*models.Branch, error)
	GetByOrganizationID(ctx context.Context, organizationID string, offset, limit int) ([]*models.Branch, error)
}

type branchRepository struct {
	datastore.BaseRepository[*models.Branch]
}

func NewBranchRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) BranchRepository {
	return &branchRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Branch](
			ctx, dbPool, workMan, func() *models.Branch { return &models.Branch{} },
		),
	}
}

func (repo *branchRepository) GetByCode(ctx context.Context, code string) (*models.Branch, error) {
	branch := models.Branch{}
	err := repo.Pool().DB(ctx, true).First(
		&branch,
		"code = ? AND unit_type = ?",
		code,
		int32(identityv1.OrgUnitType_ORG_UNIT_TYPE_BRANCH),
	).Error
	if err != nil {
		return nil, err
	}
	return &branch, nil
}

func (repo *branchRepository) GetByOrganizationID(
	ctx context.Context,
	organizationID string,
	offset, limit int,
) ([]*models.Branch, error) {
	var branches []*models.Branch
	err := repo.Pool().DB(ctx, true).
		Where(
			"organization_id = ? AND unit_type = ?",
			organizationID,
			int32(identityv1.OrgUnitType_ORG_UNIT_TYPE_BRANCH),
		).
		Offset(offset).Limit(limit).
		Find(&branches).Error
	if err != nil {
		return nil, err
	}
	return branches, nil
}
