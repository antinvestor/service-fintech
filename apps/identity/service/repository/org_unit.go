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

type OrgUnitRepository interface {
	datastore.BaseRepository[*models.Branch]
	GetByCode(ctx context.Context, code string) (*models.Branch, error)
	GetByOrganizationID(ctx context.Context, organizationID string, offset, limit int) ([]*models.Branch, error)
	GetByParentID(ctx context.Context, parentID string, offset, limit int) ([]*models.Branch, error)
	GetRootByOrganizationID(ctx context.Context, organizationID string, offset, limit int) ([]*models.Branch, error)
	HasChildren(ctx context.Context, id string) (bool, error)
}

type orgUnitRepository struct {
	datastore.BaseRepository[*models.Branch]
}

func NewOrgUnitRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) OrgUnitRepository {
	return &orgUnitRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Branch](
			ctx, dbPool, workMan, func() *models.Branch { return &models.Branch{} },
		),
	}
}

func (repo *orgUnitRepository) GetByCode(ctx context.Context, code string) (*models.Branch, error) {
	orgUnit := models.Branch{}
	err := repo.Pool().DB(ctx, true).First(&orgUnit, "code = ?", code).Error
	if err != nil {
		return nil, err
	}
	return &orgUnit, nil
}

func (repo *orgUnitRepository) GetByOrganizationID(
	ctx context.Context,
	organizationID string,
	offset, limit int,
) ([]*models.Branch, error) {
	var orgUnits []*models.Branch
	err := repo.Pool().DB(ctx, true).
		Where("organization_id = ?", organizationID).
		Offset(offset).Limit(limit).
		Find(&orgUnits).Error
	if err != nil {
		return nil, err
	}
	return orgUnits, nil
}

func (repo *orgUnitRepository) GetByParentID(
	ctx context.Context,
	parentID string,
	offset, limit int,
) ([]*models.Branch, error) {
	var orgUnits []*models.Branch
	err := repo.Pool().DB(ctx, true).
		Where("parent_id = ?", parentID).
		Offset(offset).Limit(limit).
		Find(&orgUnits).Error
	if err != nil {
		return nil, err
	}
	return orgUnits, nil
}

func (repo *orgUnitRepository) GetRootByOrganizationID(
	ctx context.Context,
	organizationID string,
	offset, limit int,
) ([]*models.Branch, error) {
	var orgUnits []*models.Branch
	err := repo.Pool().DB(ctx, true).
		Where("organization_id = ? AND (parent_id = '' OR parent_id IS NULL)", organizationID).
		Offset(offset).Limit(limit).
		Find(&orgUnits).Error
	if err != nil {
		return nil, err
	}
	return orgUnits, nil
}

func (repo *orgUnitRepository) HasChildren(ctx context.Context, id string) (bool, error) {
	var count int64
	err := repo.Pool().DB(ctx, true).
		Model(&models.Branch{}).
		Where("parent_id = ?", id).
		Count(&count).Error
	if err != nil {
		return false, err
	}
	return count > 0, nil
}
