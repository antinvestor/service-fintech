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

package business

import (
	"context"
	"errors"
	"fmt"
	"strconv"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"buf.build/gen/go/antinvestor/tenancy/connectrpc/go/tenancy/v1/tenancyv1connect"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

const (
	AccessRoleKeyApprovalVerifier      = "approval_verifier"
	AccessRoleKeyApprovalApprover      = "approval_approver"
	AccessRoleKeyIdentityAdministrator = "identity_administrator"
)

type WorkforceBusiness interface {
	WorkforceMemberSave(
		ctx context.Context,
		obj *identityv1.WorkforceMemberObject,
	) (*identityv1.WorkforceMemberObject, error)
	WorkforceMemberGet(ctx context.Context, id string) (*identityv1.WorkforceMemberObject, error)
	WorkforceMemberSearch(
		ctx context.Context,
		req *identityv1.WorkforceMemberSearchRequest,
		consumer func(ctx context.Context, batch []*identityv1.WorkforceMemberObject) error,
	) error
	DepartmentSave(ctx context.Context, obj *identityv1.DepartmentObject) (*identityv1.DepartmentObject, error)
	DepartmentGet(ctx context.Context, id string) (*identityv1.DepartmentObject, error)
	DepartmentSearch(
		ctx context.Context,
		req *identityv1.DepartmentSearchRequest,
		consumer func(ctx context.Context, batch []*identityv1.DepartmentObject) error,
	) error
	PositionSave(ctx context.Context, obj *identityv1.PositionObject) (*identityv1.PositionObject, error)
	PositionGet(ctx context.Context, id string) (*identityv1.PositionObject, error)
	PositionSearch(
		ctx context.Context,
		req *identityv1.PositionSearchRequest,
		consumer func(ctx context.Context, batch []*identityv1.PositionObject) error,
	) error
	PositionAssignmentSave(
		ctx context.Context,
		obj *identityv1.PositionAssignmentObject,
	) (*identityv1.PositionAssignmentObject, error)
	PositionAssignmentGet(ctx context.Context, id string) (*identityv1.PositionAssignmentObject, error)
	PositionAssignmentSearch(
		ctx context.Context,
		req *identityv1.PositionAssignmentSearchRequest,
		consumer func(ctx context.Context, batch []*identityv1.PositionAssignmentObject) error,
	) error
	InternalTeamSave(ctx context.Context, obj *identityv1.InternalTeamObject) (*identityv1.InternalTeamObject, error)
	InternalTeamGet(ctx context.Context, id string) (*identityv1.InternalTeamObject, error)
	InternalTeamSearch(
		ctx context.Context,
		req *identityv1.InternalTeamSearchRequest,
		consumer func(ctx context.Context, batch []*identityv1.InternalTeamObject) error,
	) error
	TeamMembershipSave(
		ctx context.Context,
		obj *identityv1.TeamMembershipObject,
	) (*identityv1.TeamMembershipObject, error)
	TeamMembershipGet(ctx context.Context, id string) (*identityv1.TeamMembershipObject, error)
	TeamMembershipSearch(
		ctx context.Context,
		req *identityv1.TeamMembershipSearchRequest,
		consumer func(ctx context.Context, batch []*identityv1.TeamMembershipObject) error,
	) error
	AccessRoleAssignmentSave(
		ctx context.Context,
		obj *identityv1.AccessRoleAssignmentObject,
	) (*identityv1.AccessRoleAssignmentObject, error)
	AccessRoleAssignmentGet(ctx context.Context, id string) (*identityv1.AccessRoleAssignmentObject, error)
	AccessRoleAssignmentSearch(
		ctx context.Context,
		req *identityv1.AccessRoleAssignmentSearchRequest,
		consumer func(ctx context.Context, batch []*identityv1.AccessRoleAssignmentObject) error,
	) error
}

type workforceBusiness struct {
	eventsMan              fevents.Manager
	organizationRepo       repository.OrganizationRepository
	orgUnitRepo            repository.OrgUnitRepository
	workforceRepo          repository.WorkforceMemberRepository
	departmentRepo         repository.DepartmentRepository
	positionRepo           repository.PositionRepository
	positionAssignmentRepo repository.PositionAssignmentRepository
	internalTeamRepo       repository.InternalTeamRepository
	teamMembershipRepo     repository.TeamMembershipRepository
	accessRoleRepo         repository.AccessRoleAssignmentRepository
	platformAccessCli      platformAccessClient
}

func NewWorkforceBusiness(
	eventsMan fevents.Manager,
	organizationRepo repository.OrganizationRepository,
	orgUnitRepo repository.OrgUnitRepository,
	workforceRepo repository.WorkforceMemberRepository,
	departmentRepo repository.DepartmentRepository,
	positionRepo repository.PositionRepository,
	positionAssignmentRepo repository.PositionAssignmentRepository,
	internalTeamRepo repository.InternalTeamRepository,
	teamMembershipRepo repository.TeamMembershipRepository,
	accessRoleRepo repository.AccessRoleAssignmentRepository,
	partitionCli tenancyv1connect.TenancyServiceClient,
) WorkforceBusiness {
	return &workforceBusiness{
		eventsMan:              eventsMan,
		organizationRepo:       organizationRepo,
		orgUnitRepo:            orgUnitRepo,
		workforceRepo:          workforceRepo,
		departmentRepo:         departmentRepo,
		positionRepo:           positionRepo,
		positionAssignmentRepo: positionAssignmentRepo,
		internalTeamRepo:       internalTeamRepo,
		teamMembershipRepo:     teamMembershipRepo,
		accessRoleRepo:         accessRoleRepo,
		platformAccessCli:      newTenancyPlatformAccessClient(partitionCli),
	}
}

func (b *workforceBusiness) WorkforceMemberSave(
	ctx context.Context,
	obj *identityv1.WorkforceMemberObject,
) (*identityv1.WorkforceMemberObject, error) {
	member := models.WorkforceMemberFromAPI(ctx, obj)
	if err := b.validateOrganization(ctx, member.OrganizationID); err != nil {
		return nil, err
	}
	if err := b.validateOrgUnitInOrganization(ctx, member.HomeOrgUnitID, member.OrganizationID); err != nil {
		return nil, err
	}
	if obj.GetId() == "" && member.State == 0 {
		member.State = int32(commonv1.STATE_CREATED)
	}

	isNew := obj.GetId() == ""

	// The previous state decides whether this save is an activation; it has to
	// be read before the save event overwrites the stored row.
	previousState := int32(0)
	if !isNew {
		if existing, err := b.workforceRepo.GetByID(ctx, obj.GetId()); err == nil && existing != nil {
			previousState = existing.State
		}
	}

	if err := b.eventsMan.Emit(ctx, events.WorkforceMemberSaveEvent, member); err != nil {
		util.Log(ctx).WithError(err).Error("could not emit workforce member save event")
		return nil, err
	}

	if isNew {
		IdentityWorkforceAdded.Add(ctx, 1)
	} else if member.State == int32(commonv1.STATE_INACTIVE) || member.State == int32(commonv1.STATE_DELETED) {
		IdentityWorkforceRemoved.Add(ctx, 1)
	}

	activated := member.State == int32(commonv1.STATE_ACTIVE) &&
		(isNew || previousState != int32(commonv1.STATE_ACTIVE))
	if activated {
		if err := b.ensurePlatformAccess(ctx, member); err != nil {
			util.Log(ctx).WithError(err).
				WithField("workforce_member_id", member.GetID()).
				Error("could not grant platform access for workforce member")
			// The member is already persisted; surface the tenancy failure so
			// the caller can retry the grant by saving again.
			//nolint:errorlint // the tenancy cause is rendered for operators; callers match on ErrPlatformAccessFailed
			return member.ToAPI(), fmt.Errorf("%w: %v", ErrPlatformAccessFailed, err)
		}
	}

	return member.ToAPI(), nil
}

func (b *workforceBusiness) WorkforceMemberGet(
	ctx context.Context,
	id string,
) (*identityv1.WorkforceMemberObject, error) {
	member, err := b.workforceRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrWorkforceMemberNotFound
	}
	return member.ToAPI(), nil
}

func (b *workforceBusiness) WorkforceMemberSearch(
	ctx context.Context,
	req *identityv1.WorkforceMemberSearchRequest,
	consumer func(ctx context.Context, batch []*identityv1.WorkforceMemberObject) error,
) error {
	results, err := b.workforceRepo.Search(ctx, buildSearchQuery(
		req.GetQuery(),
		req.GetCursor(),
		map[string]any{
			whereOrganizationID:    req.GetOrganizationId(),
			"home_org_unit_id = ?": req.GetHomeOrgUnitId(),
		},
	))
	if err != nil {
		return err
	}
	return workerpoolConsumeStream(ctx, results, func(batch []*models.WorkforceMember) error {
		out := make([]*identityv1.WorkforceMemberObject, 0, len(batch))
		for _, item := range batch {
			out = append(out, item.ToAPI())
		}
		return consumer(ctx, out)
	})
}

func (b *workforceBusiness) DepartmentSave(
	ctx context.Context,
	obj *identityv1.DepartmentObject,
) (*identityv1.DepartmentObject, error) {
	department := models.DepartmentFromAPI(ctx, obj)
	if err := b.validateOrganization(ctx, department.OrganizationID); err != nil {
		return nil, err
	}
	if err := b.validateDepartmentParent(ctx, department); err != nil {
		return nil, err
	}
	if obj.GetId() == "" && department.State == 0 {
		department.State = int32(commonv1.STATE_CREATED)
	}

	if err := b.eventsMan.Emit(ctx, events.DepartmentSaveEvent, department); err != nil {
		util.Log(ctx).WithError(err).Error("could not emit department save event")
		return nil, err
	}
	return department.ToAPI(), nil
}

func (b *workforceBusiness) DepartmentGet(ctx context.Context, id string) (*identityv1.DepartmentObject, error) {
	department, err := b.departmentRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrDepartmentNotFound
	}
	return department.ToAPI(), nil
}

func (b *workforceBusiness) DepartmentSearch(
	ctx context.Context,
	req *identityv1.DepartmentSearchRequest,
	consumer func(ctx context.Context, batch []*identityv1.DepartmentObject) error,
) error {
	filters := map[string]any{
		whereOrganizationID: req.GetOrganizationId(),
		"parent_id = ?":     req.GetParentId(),
	}
	if req.GetKind() != identityv1.DepartmentKind_DEPARTMENT_KIND_UNSPECIFIED {
		filters["kind = ?"] = int32(req.GetKind())
	}
	results, err := b.departmentRepo.Search(ctx, buildSearchQuery(req.GetQuery(), req.GetCursor(), filters))
	if err != nil {
		return err
	}
	return workerpoolConsumeStream(ctx, results, func(batch []*models.Department) error {
		out := make([]*identityv1.DepartmentObject, 0, len(batch))
		for _, item := range batch {
			out = append(out, item.ToAPI())
		}
		return consumer(ctx, out)
	})
}

func (b *workforceBusiness) PositionSave(
	ctx context.Context,
	obj *identityv1.PositionObject,
) (*identityv1.PositionObject, error) {
	position := models.PositionFromAPI(ctx, obj)
	if err := b.validateOrganization(ctx, position.OrganizationID); err != nil {
		return nil, err
	}
	if err := b.validateOrgUnitInOrganization(ctx, position.OrgUnitID, position.OrganizationID); err != nil {
		return nil, err
	}
	if err := b.validateDepartmentInOrganization(ctx, position.DepartmentID, position.OrganizationID); err != nil {
		return nil, err
	}
	if err := b.validateReportsToPosition(ctx, position); err != nil {
		return nil, err
	}
	if obj.GetId() == "" && position.State == 0 {
		position.State = int32(commonv1.STATE_CREATED)
	}

	if err := b.eventsMan.Emit(ctx, events.PositionSaveEvent, position); err != nil {
		util.Log(ctx).WithError(err).Error("could not emit position save event")
		return nil, err
	}
	return position.ToAPI(), nil
}

func (b *workforceBusiness) PositionGet(ctx context.Context, id string) (*identityv1.PositionObject, error) {
	position, err := b.positionRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrPositionNotFound
	}
	return position.ToAPI(), nil
}

func (b *workforceBusiness) PositionSearch(
	ctx context.Context,
	req *identityv1.PositionSearchRequest,
	consumer func(ctx context.Context, batch []*identityv1.PositionObject) error,
) error {
	results, err := b.positionRepo.Search(ctx, buildSearchQuery(
		req.GetQuery(),
		req.GetCursor(),
		map[string]any{
			whereOrganizationID:          req.GetOrganizationId(),
			"org_unit_id = ?":            req.GetOrgUnitId(),
			"department_id = ?":          req.GetDepartmentId(),
			"reports_to_position_id = ?": req.GetReportsToPositionId(),
		},
	))
	if err != nil {
		return err
	}
	return workerpoolConsumeStream(ctx, results, func(batch []*models.Position) error {
		out := make([]*identityv1.PositionObject, 0, len(batch))
		for _, item := range batch {
			out = append(out, item.ToAPI())
		}
		return consumer(ctx, out)
	})
}

//nolint:dupl // similar save/get/search pattern for different entity types
func (b *workforceBusiness) PositionAssignmentSave(
	ctx context.Context,
	obj *identityv1.PositionAssignmentObject,
) (*identityv1.PositionAssignmentObject, error) {
	assignment := models.PositionAssignmentFromAPI(ctx, obj)
	member, err := b.workforceRepo.GetByID(ctx, assignment.MemberID)
	if err != nil {
		return nil, ErrWorkforceMemberNotFound
	}
	position, err := b.positionRepo.GetByID(ctx, assignment.PositionID)
	if err != nil {
		return nil, ErrPositionNotFound
	}
	if member.OrganizationID != position.OrganizationID {
		return nil, ErrOrgUnitNotInOrganization.Extend("member and position belong to different organizations")
	}
	if errValidate := b.validatePrimaryPositionAssignment(ctx, assignment); errValidate != nil {
		return nil, errValidate
	}
	if obj.GetId() == "" && assignment.State == 0 {
		assignment.State = int32(commonv1.STATE_CREATED)
	}

	if errEmit := b.eventsMan.Emit(ctx, events.PositionAssignmentSaveEvent, assignment); errEmit != nil {
		util.Log(ctx).WithError(errEmit).Error("could not emit position assignment save event")
		return nil, errEmit
	}
	return assignment.ToAPI(), nil
}

func (b *workforceBusiness) PositionAssignmentGet(
	ctx context.Context,
	id string,
) (*identityv1.PositionAssignmentObject, error) {
	assignment, err := b.positionAssignmentRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrPositionAssignmentNotFound
	}
	return assignment.ToAPI(), nil
}

func (b *workforceBusiness) PositionAssignmentSearch(
	ctx context.Context,
	req *identityv1.PositionAssignmentSearchRequest,
	consumer func(ctx context.Context, batch []*identityv1.PositionAssignmentObject) error,
) error {
	results, err := b.positionAssignmentRepo.Search(ctx, buildSearchQuery(
		req.GetQuery(),
		req.GetCursor(),
		map[string]any{
			whereMemberID:     req.GetMemberId(),
			"position_id = ?": req.GetPositionId(),
		},
	))
	if err != nil {
		return err
	}
	return workerpoolConsumeStream(ctx, results, func(batch []*models.PositionAssignment) error {
		out := make([]*identityv1.PositionAssignmentObject, 0, len(batch))
		for _, item := range batch {
			out = append(out, item.ToAPI())
		}
		return consumer(ctx, out)
	})
}

func (b *workforceBusiness) InternalTeamSave(
	ctx context.Context,
	obj *identityv1.InternalTeamObject,
) (*identityv1.InternalTeamObject, error) {
	team := models.InternalTeamFromAPI(ctx, obj)
	if err := b.validateOrganization(ctx, team.OrganizationID); err != nil {
		return nil, err
	}
	if err := b.validateOrgUnitInOrganization(ctx, team.HomeOrgUnitID, team.OrganizationID); err != nil {
		return nil, err
	}
	if err := b.validateParentTeam(ctx, team); err != nil {
		return nil, err
	}
	if obj.GetId() == "" && team.State == 0 {
		team.State = int32(commonv1.STATE_CREATED)
	}

	if err := b.eventsMan.Emit(ctx, events.InternalTeamSaveEvent, team); err != nil {
		util.Log(ctx).WithError(err).Error("could not emit internal team save event")
		return nil, err
	}
	return team.ToAPI(), nil
}

func (b *workforceBusiness) InternalTeamGet(ctx context.Context, id string) (*identityv1.InternalTeamObject, error) {
	team, err := b.internalTeamRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrInternalTeamNotFound
	}
	return team.ToAPI(), nil
}

func (b *workforceBusiness) InternalTeamSearch(
	ctx context.Context,
	req *identityv1.InternalTeamSearchRequest,
	consumer func(ctx context.Context, batch []*identityv1.InternalTeamObject) error,
) error {
	filters := map[string]any{
		whereOrganizationID:    req.GetOrganizationId(),
		"home_org_unit_id = ?": req.GetHomeOrgUnitId(),
	}
	if req.GetTeamType() != "" {
		filters["team_type = ?"] = req.GetTeamType()
	}
	results, err := b.internalTeamRepo.Search(ctx, buildSearchQuery(req.GetQuery(), req.GetCursor(), filters))
	if err != nil {
		return err
	}
	return workerpoolConsumeStream(ctx, results, func(batch []*models.InternalTeam) error {
		out := make([]*identityv1.InternalTeamObject, 0, len(batch))
		for _, item := range batch {
			out = append(out, item.ToAPI())
		}
		return consumer(ctx, out)
	})
}

//nolint:dupl // similar save/get/search pattern for different entity types
func (b *workforceBusiness) TeamMembershipSave(
	ctx context.Context,
	obj *identityv1.TeamMembershipObject,
) (*identityv1.TeamMembershipObject, error) {
	membership := models.TeamMembershipFromAPI(ctx, obj)
	member, err := b.workforceRepo.GetByID(ctx, membership.MemberID)
	if err != nil {
		return nil, ErrWorkforceMemberNotFound
	}
	team, err := b.internalTeamRepo.GetByID(ctx, membership.TeamID)
	if err != nil {
		return nil, ErrInternalTeamNotFound
	}
	if member.OrganizationID != team.OrganizationID {
		return nil, ErrOrgUnitNotInOrganization.Extend("member and team belong to different organizations")
	}
	if errValidate := b.validatePrimaryTeamMembership(ctx, membership); errValidate != nil {
		return nil, errValidate
	}
	if obj.GetId() == "" && membership.State == 0 {
		membership.State = int32(commonv1.STATE_CREATED)
	}

	if errEmit := b.eventsMan.Emit(ctx, events.TeamMembershipSaveEvent, membership); errEmit != nil {
		util.Log(ctx).WithError(errEmit).Error("could not emit team membership save event")
		return nil, errEmit
	}
	return membership.ToAPI(), nil
}

func (b *workforceBusiness) TeamMembershipGet(
	ctx context.Context,
	id string,
) (*identityv1.TeamMembershipObject, error) {
	membership, err := b.teamMembershipRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrTeamMembershipNotFound
	}
	return membership.ToAPI(), nil
}

func (b *workforceBusiness) TeamMembershipSearch(
	ctx context.Context,
	req *identityv1.TeamMembershipSearchRequest,
	consumer func(ctx context.Context, batch []*identityv1.TeamMembershipObject) error,
) error {
	results, err := b.teamMembershipRepo.Search(ctx, buildSearchQuery(
		req.GetQuery(),
		req.GetCursor(),
		map[string]any{
			"team_id = ?": req.GetTeamId(),
			whereMemberID: req.GetMemberId(),
		},
	))
	if err != nil {
		return err
	}
	return workerpoolConsumeStream(ctx, results, func(batch []*models.TeamMembership) error {
		out := make([]*identityv1.TeamMembershipObject, 0, len(batch))
		for _, item := range batch {
			out = append(out, item.ToAPI())
		}
		return consumer(ctx, out)
	})
}

func (b *workforceBusiness) AccessRoleAssignmentSave(
	ctx context.Context,
	obj *identityv1.AccessRoleAssignmentObject,
) (*identityv1.AccessRoleAssignmentObject, error) {
	assignment := models.AccessRoleAssignmentFromAPI(ctx, obj)
	if assignment.RoleKey == "" {
		return nil, ErrInvalidRoleKey
	}
	member, err := b.workforceRepo.GetByID(ctx, assignment.MemberID)
	if err != nil {
		return nil, ErrWorkforceMemberNotFound
	}
	if errScope := b.validateAccessScope(ctx, member, assignment); errScope != nil {
		return nil, errScope
	}
	if obj.GetId() == "" && assignment.State == 0 {
		assignment.State = int32(commonv1.STATE_CREATED)
	}

	if errEmit := b.eventsMan.Emit(ctx, events.AccessRoleAssignmentSaveEvent, assignment); errEmit != nil {
		util.Log(ctx).WithError(errEmit).Error("could not emit access role assignment save event")
		return nil, errEmit
	}
	return assignment.ToAPI(), nil
}

func (b *workforceBusiness) AccessRoleAssignmentGet(
	ctx context.Context,
	id string,
) (*identityv1.AccessRoleAssignmentObject, error) {
	assignment, err := b.accessRoleRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrAccessRoleAssignmentNotFound
	}
	return assignment.ToAPI(), nil
}

func (b *workforceBusiness) AccessRoleAssignmentSearch(
	ctx context.Context,
	req *identityv1.AccessRoleAssignmentSearchRequest,
	consumer func(ctx context.Context, batch []*identityv1.AccessRoleAssignmentObject) error,
) error {
	filters := map[string]any{
		whereMemberID:  req.GetMemberId(),
		"role_key = ?": req.GetRoleKey(),
		"scope_id = ?": req.GetScopeId(),
	}
	if req.GetScopeType() != identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_UNSPECIFIED {
		filters["scope_type = ?"] = int32(req.GetScopeType())
	}
	results, err := b.accessRoleRepo.Search(ctx, buildSearchQuery(req.GetQuery(), req.GetCursor(), filters))
	if err != nil {
		return err
	}
	return workerpoolConsumeStream(ctx, results, func(batch []*models.AccessRoleAssignment) error {
		out := make([]*identityv1.AccessRoleAssignmentObject, 0, len(batch))
		for _, item := range batch {
			out = append(out, item.ToAPI())
		}
		return consumer(ctx, out)
	})
}

func buildSearchQuery(query string, cursor *commonv1.PageCursor, filters map[string]any) *data.SearchQuery {
	var searchOpts []data.SearchOption
	if cursor != nil {
		offset, offsetErr := strconv.Atoi(cursor.GetPage())
		if offsetErr != nil {
			offset = 0
		}
		searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(int(cursor.GetLimit())))
	}

	andFilters := make(map[string]any, len(filters))
	for clause, value := range filters {
		if isEmptyFilterValue(value) {
			continue
		}
		andFilters[clause] = value
	}
	if len(andFilters) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andFilters))
	}
	if query != "" {
		searchOpts = append(searchOpts, data.WithSearchFiltersOrByValue(
			map[string]any{searchableTSQuery: query},
		))
	}

	return data.NewSearchQuery(searchOpts...)
}

func isEmptyFilterValue(value any) bool {
	switch typed := value.(type) {
	case string:
		return typed == ""
	case int32:
		return typed == 0
	default:
		return value == nil
	}
}

func (b *workforceBusiness) validateOrganization(ctx context.Context, organizationID string) error {
	if organizationID == "" {
		return ErrOrganizationNotFound
	}
	if _, err := b.organizationRepo.GetByID(ctx, organizationID); err != nil {
		return ErrOrganizationNotFound
	}
	return nil
}

func (b *workforceBusiness) validateOrgUnitInOrganization(
	ctx context.Context,
	orgUnitID, organizationID string,
) error {
	if orgUnitID == "" {
		return nil
	}
	orgUnit, err := b.orgUnitRepo.GetByID(ctx, orgUnitID)
	if err != nil {
		return ErrOrgUnitNotFound
	}
	if organizationID != "" && orgUnit.OrganizationID != organizationID {
		return ErrOrgUnitNotInOrganization
	}
	return nil
}

//nolint:dupl // similar hierarchy validation for different entity types
func (b *workforceBusiness) validateDepartmentParent(
	ctx context.Context,
	department *models.Department,
) error {
	if department.ParentID == "" {
		return nil
	}
	if department.GetID() != "" && department.GetID() == department.ParentID {
		return ErrCircularParentChain
	}
	parent, err := b.departmentRepo.GetByID(ctx, department.ParentID)
	if err != nil {
		return ErrDepartmentNotFound.Extend("parent department not found")
	}
	if parent.OrganizationID != department.OrganizationID {
		return ErrOrgUnitNotInOrganization.Extend("parent department belongs to another organization")
	}
	// Detect circular parent chains (max 20 levels deep).
	if department.GetID() != "" {
		visited := map[string]bool{department.GetID(): true}
		current := parent
		for depth := 0; depth < 20 && current.ParentID != ""; depth++ {
			if visited[current.ParentID] {
				return ErrCircularParentChain
			}
			visited[current.GetID()] = true
			ancestor, aErr := b.departmentRepo.GetByID(ctx, current.ParentID)
			if aErr != nil {
				// Cannot resolve further ancestors; stop walking the chain.
				return nil //nolint:nilerr // partial chain walk is not an error
			}
			current = ancestor
		}
	}
	return nil
}

func (b *workforceBusiness) validateDepartmentInOrganization(
	ctx context.Context,
	departmentID, organizationID string,
) error {
	if departmentID == "" {
		return nil
	}
	department, err := b.departmentRepo.GetByID(ctx, departmentID)
	if err != nil {
		return ErrDepartmentNotFound
	}
	if department.OrganizationID != organizationID {
		return ErrOrgUnitNotInOrganization.Extend("department belongs to another organization")
	}
	return nil
}

func (b *workforceBusiness) validateReportsToPosition(ctx context.Context, position *models.Position) error {
	if position.ReportsToPositionID == "" {
		return nil
	}
	parent, err := b.positionRepo.GetByID(ctx, position.ReportsToPositionID)
	if err != nil {
		return ErrPositionNotFound.Extend("parent position not found")
	}
	if parent.OrganizationID != position.OrganizationID {
		return ErrOrgUnitNotInOrganization.Extend("reporting line crosses organizations")
	}
	if position.GetID() != "" && parent.GetID() == position.GetID() {
		return ErrInvalidReportingLine.Extend("position cannot report to itself")
	}
	return nil
}

func (b *workforceBusiness) validatePrimaryPositionAssignment(
	ctx context.Context,
	assignment *models.PositionAssignment,
) error {
	if !assignment.IsPrimary ||
		assignment.State == int32(commonv1.STATE_INACTIVE) ||
		assignment.State == int32(commonv1.STATE_DELETED) {
		return nil
	}
	existing, err := b.positionAssignmentRepo.GetActivePrimaryByMemberID(ctx, assignment.MemberID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil
		}
		return err
	}
	if existing.GetID() != assignment.GetID() {
		return ErrPrimaryPositionAssignmentExists
	}
	return nil
}

//nolint:dupl // similar hierarchy validation for different entity types
func (b *workforceBusiness) validateParentTeam(ctx context.Context, team *models.InternalTeam) error {
	if team.ParentTeamID == "" {
		return nil
	}
	if team.GetID() != "" && team.GetID() == team.ParentTeamID {
		return ErrCircularParentChain
	}
	parent, err := b.internalTeamRepo.GetByID(ctx, team.ParentTeamID)
	if err != nil {
		return ErrInternalTeamNotFound.Extend("parent team not found")
	}
	if parent.OrganizationID != team.OrganizationID {
		return ErrOrgUnitNotInOrganization.Extend("parent team belongs to another organization")
	}
	// Detect circular parent chains (max 20 levels deep).
	if team.GetID() != "" {
		visited := map[string]bool{team.GetID(): true}
		current := parent
		for depth := 0; depth < 20 && current.ParentTeamID != ""; depth++ {
			if visited[current.ParentTeamID] {
				return ErrCircularParentChain
			}
			visited[current.GetID()] = true
			ancestor, aErr := b.internalTeamRepo.GetByID(ctx, current.ParentTeamID)
			if aErr != nil {
				// Cannot resolve further ancestors; stop walking the chain.
				return nil //nolint:nilerr // partial chain walk is not an error
			}
			current = ancestor
		}
	}
	return nil
}

func (b *workforceBusiness) validatePrimaryTeamMembership(
	ctx context.Context,
	membership *models.TeamMembership,
) error {
	if !membership.IsPrimaryTeam ||
		membership.State == int32(commonv1.STATE_INACTIVE) ||
		membership.State == int32(commonv1.STATE_DELETED) {
		return nil
	}
	existing, err := b.teamMembershipRepo.GetActivePrimaryByMemberID(ctx, membership.MemberID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil
		}
		return err
	}
	if existing.GetID() != membership.GetID() {
		return ErrPrimaryTeamMembershipExists
	}
	return nil
}

func (b *workforceBusiness) validateAccessScope(
	ctx context.Context,
	member *models.WorkforceMember,
	assignment *models.AccessRoleAssignment,
) error {
	switch identityv1.AccessScopeType(assignment.ScopeType) {
	case identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_UNSPECIFIED:
		return ErrInvalidAccessScope
	case identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_GLOBAL:
		return nil
	case identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_ORGANIZATION:
		if assignment.ScopeID == "" || assignment.ScopeID != member.OrganizationID {
			return ErrInvalidAccessScope
		}
		if _, err := b.organizationRepo.GetByID(ctx, assignment.ScopeID); err != nil {
			return ErrOrganizationNotFound
		}
		return nil
	case identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_ORG_UNIT:
		return b.validateOrgUnitInOrganization(ctx, assignment.ScopeID, member.OrganizationID)
	case identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_TEAM:
		team, err := b.internalTeamRepo.GetByID(ctx, assignment.ScopeID)
		if err != nil {
			return ErrInternalTeamNotFound
		}
		if team.OrganizationID != member.OrganizationID {
			return ErrInvalidAccessScope
		}
		return nil
	default:
		return ErrInvalidAccessScope
	}
}
