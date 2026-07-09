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

type MembershipRepository interface {
	datastore.BaseRepository[*models.Membership]
	GetByGroupID(ctx context.Context, groupID string, offset, limit int) ([]*models.Membership, error)
	GetByProfileID(ctx context.Context, profileID string, offset, limit int) ([]*models.Membership, error)
}

type membershipRepository struct {
	datastore.BaseRepository[*models.Membership]
}

func NewMembershipRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) MembershipRepository {
	return &membershipRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Membership](
			ctx, dbPool, workMan, func() *models.Membership { return &models.Membership{} },
		),
	}
}

func (repo *membershipRepository) GetByGroupID(
	ctx context.Context,
	groupID string,
	offset, limit int,
) ([]*models.Membership, error) {
	var memberships []*models.Membership
	err := repo.Pool().DB(ctx, true).
		Where("group_id = ?", groupID).
		Offset(offset).Limit(limit).
		Find(&memberships).Error
	if err != nil {
		return nil, err
	}
	return memberships, nil
}

func (repo *membershipRepository) GetByProfileID(
	ctx context.Context,
	profileID string,
	offset, limit int,
) ([]*models.Membership, error) {
	var memberships []*models.Membership
	err := repo.Pool().DB(ctx, true).
		Where("profile_id = ?", profileID).
		Offset(offset).Limit(limit).
		Find(&memberships).Error
	if err != nil {
		return nil, err
	}
	return memberships, nil
}
