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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

type WorkforceMemberRepository interface {
	datastore.BaseRepository[*models.WorkforceMember]
	GetByProfileID(ctx context.Context, profileID string) (*models.WorkforceMember, error)
	GetByOrganizationID(
		ctx context.Context,
		organizationID string,
		offset, limit int,
	) ([]*models.WorkforceMember, error)
	GetByIDs(ctx context.Context, ids []string) ([]*models.WorkforceMember, error)
}

type workforceMemberRepository struct {
	datastore.BaseRepository[*models.WorkforceMember]
}

func NewWorkforceMemberRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) WorkforceMemberRepository {
	return &workforceMemberRepository{
		BaseRepository: datastore.NewBaseRepository[*models.WorkforceMember](
			ctx,
			dbPool,
			workMan,
			func() *models.WorkforceMember { return &models.WorkforceMember{} },
		),
	}
}

func (repo *workforceMemberRepository) GetByProfileID(
	ctx context.Context,
	profileID string,
) (*models.WorkforceMember, error) {
	member := models.WorkforceMember{}
	err := repo.Pool().DB(ctx, true).First(&member, "profile_id = ?", profileID).Error
	if err != nil {
		return nil, err
	}
	return &member, nil
}

func (repo *workforceMemberRepository) GetByOrganizationID(
	ctx context.Context,
	organizationID string,
	offset, limit int,
) ([]*models.WorkforceMember, error) {
	var members []*models.WorkforceMember
	err := repo.Pool().DB(ctx, true).
		Where("organization_id = ?", organizationID).
		Offset(offset).
		Limit(limit).
		Find(&members).Error
	if err != nil {
		return nil, err
	}
	return members, nil
}

func (repo *workforceMemberRepository) GetByIDs(
	ctx context.Context,
	ids []string,
) ([]*models.WorkforceMember, error) {
	if len(ids) == 0 {
		return []*models.WorkforceMember{}, nil
	}

	var members []*models.WorkforceMember
	err := repo.Pool().DB(ctx, true).Where("id IN ?", ids).Find(&members).Error
	if err != nil {
		return nil, err
	}
	return members, nil
}

type DepartmentRepository interface {
	datastore.BaseRepository[*models.Department]
	GetByOrganizationID(ctx context.Context, organizationID string, offset, limit int) ([]*models.Department, error)
	GetByParentID(ctx context.Context, parentID string, offset, limit int) ([]*models.Department, error)
}

type departmentRepository struct {
	datastore.BaseRepository[*models.Department]
}

func NewDepartmentRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) DepartmentRepository {
	return &departmentRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Department](
			ctx,
			dbPool,
			workMan,
			func() *models.Department { return &models.Department{} },
		),
	}
}

func (repo *departmentRepository) GetByOrganizationID(
	ctx context.Context,
	organizationID string,
	offset, limit int,
) ([]*models.Department, error) {
	var departments []*models.Department
	err := repo.Pool().DB(ctx, true).
		Where("organization_id = ?", organizationID).
		Offset(offset).
		Limit(limit).
		Find(&departments).Error
	if err != nil {
		return nil, err
	}
	return departments, nil
}

func (repo *departmentRepository) GetByParentID(
	ctx context.Context,
	parentID string,
	offset, limit int,
) ([]*models.Department, error) {
	var departments []*models.Department
	err := repo.Pool().DB(ctx, true).
		Where("parent_id = ?", parentID).
		Offset(offset).
		Limit(limit).
		Find(&departments).Error
	if err != nil {
		return nil, err
	}
	return departments, nil
}

type PositionRepository interface {
	datastore.BaseRepository[*models.Position]
	GetByOrganizationID(ctx context.Context, organizationID string, offset, limit int) ([]*models.Position, error)
}

type positionRepository struct {
	datastore.BaseRepository[*models.Position]
}

func NewPositionRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) PositionRepository {
	return &positionRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Position](
			ctx,
			dbPool,
			workMan,
			func() *models.Position { return &models.Position{} },
		),
	}
}

func (repo *positionRepository) GetByOrganizationID(
	ctx context.Context,
	organizationID string,
	offset, limit int,
) ([]*models.Position, error) {
	var positions []*models.Position
	err := repo.Pool().DB(ctx, true).
		Where("organization_id = ?", organizationID).
		Offset(offset).
		Limit(limit).
		Find(&positions).Error
	if err != nil {
		return nil, err
	}
	return positions, nil
}

type PositionAssignmentRepository interface {
	datastore.BaseRepository[*models.PositionAssignment]
	GetActivePrimaryByMemberID(ctx context.Context, memberID string) (*models.PositionAssignment, error)
}

type positionAssignmentRepository struct {
	datastore.BaseRepository[*models.PositionAssignment]
}

func NewPositionAssignmentRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) PositionAssignmentRepository {
	return &positionAssignmentRepository{
		BaseRepository: datastore.NewBaseRepository[*models.PositionAssignment](
			ctx,
			dbPool,
			workMan,
			func() *models.PositionAssignment { return &models.PositionAssignment{} },
		),
	}
}

func (repo *positionAssignmentRepository) GetActivePrimaryByMemberID(
	ctx context.Context,
	memberID string,
) (*models.PositionAssignment, error) {
	assignment := models.PositionAssignment{}
	err := repo.Pool().DB(ctx, true).
		Where(
			"member_id = ? AND is_primary = ? AND state IN ?",
			memberID,
			true,
			[]int32{int32(commonv1.STATE_CREATED), int32(commonv1.STATE_ACTIVE)},
		).
		First(&assignment).Error
	if err != nil {
		return nil, err
	}
	return &assignment, nil
}

type InternalTeamRepository interface {
	datastore.BaseRepository[*models.InternalTeam]
	GetByOrganizationID(ctx context.Context, organizationID string, offset, limit int) ([]*models.InternalTeam, error)
}

type internalTeamRepository struct {
	datastore.BaseRepository[*models.InternalTeam]
}

func NewInternalTeamRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) InternalTeamRepository {
	return &internalTeamRepository{
		BaseRepository: datastore.NewBaseRepository[*models.InternalTeam](
			ctx,
			dbPool,
			workMan,
			func() *models.InternalTeam { return &models.InternalTeam{} },
		),
	}
}

func (repo *internalTeamRepository) GetByOrganizationID(
	ctx context.Context,
	organizationID string,
	offset, limit int,
) ([]*models.InternalTeam, error) {
	var teams []*models.InternalTeam
	err := repo.Pool().DB(ctx, true).
		Where("organization_id = ?", organizationID).
		Offset(offset).
		Limit(limit).
		Find(&teams).Error
	if err != nil {
		return nil, err
	}
	return teams, nil
}

type TeamMembershipRepository interface {
	datastore.BaseRepository[*models.TeamMembership]
	GetActivePrimaryByMemberID(ctx context.Context, memberID string) (*models.TeamMembership, error)
	GetActiveMembership(ctx context.Context, teamID, memberID string) (*models.TeamMembership, error)
}

type teamMembershipRepository struct {
	datastore.BaseRepository[*models.TeamMembership]
}

func NewTeamMembershipRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) TeamMembershipRepository {
	return &teamMembershipRepository{
		BaseRepository: datastore.NewBaseRepository[*models.TeamMembership](
			ctx,
			dbPool,
			workMan,
			func() *models.TeamMembership { return &models.TeamMembership{} },
		),
	}
}

func (repo *teamMembershipRepository) GetActivePrimaryByMemberID(
	ctx context.Context,
	memberID string,
) (*models.TeamMembership, error) {
	membership := models.TeamMembership{}
	err := repo.Pool().DB(ctx, true).
		Where(
			"member_id = ? AND is_primary_team = ? AND state IN ?",
			memberID,
			true,
			[]int32{int32(commonv1.STATE_CREATED), int32(commonv1.STATE_ACTIVE)},
		).
		First(&membership).Error
	if err != nil {
		return nil, err
	}
	return &membership, nil
}

func (repo *teamMembershipRepository) GetActiveMembership(
	ctx context.Context,
	teamID, memberID string,
) (*models.TeamMembership, error) {
	membership := models.TeamMembership{}
	err := repo.Pool().DB(ctx, true).
		Where(
			"team_id = ? AND member_id = ? AND state IN ?",
			teamID,
			memberID,
			[]int32{int32(commonv1.STATE_CREATED), int32(commonv1.STATE_ACTIVE)},
		).
		First(&membership).Error
	if err != nil {
		return nil, err
	}
	return &membership, nil
}

type AccessRoleAssignmentRepository interface {
	datastore.BaseRepository[*models.AccessRoleAssignment]
	GetActiveByRoleAndScopes(
		ctx context.Context,
		roleKey string,
		scopeType identityv1.AccessScopeType,
		scopeIDs []string,
		limit int,
	) ([]*models.AccessRoleAssignment, error)
}

type accessRoleAssignmentRepository struct {
	datastore.BaseRepository[*models.AccessRoleAssignment]
}

func NewAccessRoleAssignmentRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) AccessRoleAssignmentRepository {
	return &accessRoleAssignmentRepository{
		BaseRepository: datastore.NewBaseRepository[*models.AccessRoleAssignment](
			ctx,
			dbPool,
			workMan,
			func() *models.AccessRoleAssignment { return &models.AccessRoleAssignment{} },
		),
	}
}

func (repo *accessRoleAssignmentRepository) GetActiveByRoleAndScopes(
	ctx context.Context,
	roleKey string,
	scopeType identityv1.AccessScopeType,
	scopeIDs []string,
	limit int,
) ([]*models.AccessRoleAssignment, error) {
	if scopeType != identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_GLOBAL && len(scopeIDs) == 0 {
		return []*models.AccessRoleAssignment{}, nil
	}

	query := repo.Pool().DB(ctx, true).
		Where(
			"role_key = ? AND scope_type = ? AND state IN ?",
			roleKey,
			int32(scopeType),
			[]int32{int32(commonv1.STATE_CREATED), int32(commonv1.STATE_ACTIVE)},
		)

	if scopeType != identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_GLOBAL {
		query = query.Where("scope_id IN ?", scopeIDs)
	}
	if limit > 0 {
		query = query.Limit(limit)
	}

	var assignments []*models.AccessRoleAssignment
	err := query.Find(&assignments).Error
	if err != nil {
		return nil, err
	}
	return assignments, nil
}
