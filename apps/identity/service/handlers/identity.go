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

package handlers

import (
	"context"
	"strconv"
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"connectrpc.com/connect"
	audit "github.com/antinvestor/common/audit"

	"github.com/antinvestor/service-fintech/apps/identity/service/business"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// Audit vocabulary that the shared audit package does not yet define.
const (
	auditResourceClientDataEntry = "client_data_entry"
	auditActionRequestInfo       = "request_info"

	// defaultPageLimit and maxPageLimit bound how many rows one streamed
	// batch may carry when the caller does not choose, or asks for too much.
	defaultPageLimit = 50
	maxPageLimit     = 200
)

// IdentityServer implements the IdentityService RPC handler.
// Tenant-level permission checks are handled by the FunctionAccessInterceptor.
type IdentityServer struct {
	organizationBusiness   business.OrganizationBusiness
	orgUnitBusiness        business.OrgUnitBusiness
	workforceBusiness      business.WorkforceBusiness
	clientGroupBusiness    business.ClientGroupBusiness
	membershipBusiness     business.MembershipBusiness
	investorBusiness       business.InvestorBusiness
	clientDataBusiness     business.ClientDataBusiness
	formTemplateBusiness   business.FormTemplateBusiness
	formSubmissionBusiness business.FormSubmissionBusiness

	identityv1connect.UnimplementedIdentityServiceHandler
}

func NewIdentityServer(
	organizationBusiness business.OrganizationBusiness,
	orgUnitBusiness business.OrgUnitBusiness,
	workforceBusiness business.WorkforceBusiness,
	clientGroupBusiness business.ClientGroupBusiness,
	membershipBusiness business.MembershipBusiness,
	investorBusiness business.InvestorBusiness,
	clientDataBusiness business.ClientDataBusiness,
	formTemplateBusiness business.FormTemplateBusiness,
	formSubmissionBusiness business.FormSubmissionBusiness,
) identityv1connect.IdentityServiceHandler {
	return &IdentityServer{
		organizationBusiness:   organizationBusiness,
		orgUnitBusiness:        orgUnitBusiness,
		workforceBusiness:      workforceBusiness,
		clientGroupBusiness:    clientGroupBusiness,
		membershipBusiness:     membershipBusiness,
		investorBusiness:       investorBusiness,
		clientDataBusiness:     clientDataBusiness,
		formTemplateBusiness:   formTemplateBusiness,
		formSubmissionBusiness: formSubmissionBusiness,
	}
}

// --- Organization RPCs ---

func (s *IdentityServer) OrganizationSave(
	ctx context.Context,
	req *connect.Request[identityv1.OrganizationSaveRequest],
) (*connect.Response[identityv1.OrganizationSaveResponse], error) {
	result, err := s.organizationBusiness.Save(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceOrganization, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	return connect.NewResponse(&identityv1.OrganizationSaveResponse{Data: result}), nil
}

func (s *IdentityServer) OrganizationGet(
	ctx context.Context,
	req *connect.Request[identityv1.OrganizationGetRequest],
) (*connect.Response[identityv1.OrganizationGetResponse], error) {
	result, err := s.organizationBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.OrganizationGetResponse{Data: result}), nil
}

func (s *IdentityServer) OrganizationSearch(
	ctx context.Context,
	req *connect.Request[commonv1.SearchRequest],
	stream *connect.ServerStream[identityv1.OrganizationSearchResponse],
) error {
	searchReq := &commonv1.SearchRequest{
		Query:      req.Msg.GetQuery(),
		Extras:     req.Msg.GetExtras(),
		IdQuery:    req.Msg.GetIdQuery(),
		Properties: req.Msg.GetProperties(),
	}
	if cursor := req.Msg.GetCursor(); cursor != nil {
		searchReq.Cursor = &commonv1.PageCursor{
			Page:  cursor.GetPage(),
			Limit: cursor.GetLimit(),
		}
	}
	err := s.organizationBusiness.Search(ctx, searchReq,
		func(_ context.Context, batch []*identityv1.OrganizationObject) error {
			return stream.Send(&identityv1.OrganizationSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- Org Unit RPCs ---

func (s *IdentityServer) OrgUnitSave(
	ctx context.Context,
	req *connect.Request[identityv1.OrgUnitSaveRequest],
) (*connect.Response[identityv1.OrgUnitSaveResponse], error) {
	result, err := s.orgUnitBusiness.Save(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceOrgUnit, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	return connect.NewResponse(&identityv1.OrgUnitSaveResponse{Data: result}), nil
}

func (s *IdentityServer) OrgUnitGet(
	ctx context.Context,
	req *connect.Request[identityv1.OrgUnitGetRequest],
) (*connect.Response[identityv1.OrgUnitGetResponse], error) {
	result, err := s.orgUnitBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.OrgUnitGetResponse{Data: result}), nil
}

func (s *IdentityServer) OrgUnitSearch(
	ctx context.Context,
	req *connect.Request[identityv1.OrgUnitSearchRequest],
	stream *connect.ServerStream[identityv1.OrgUnitSearchResponse],
) error {
	err := s.orgUnitBusiness.Search(ctx, req.Msg,
		func(_ context.Context, batch []*identityv1.OrgUnitObject) error {
			return stream.Send(&identityv1.OrgUnitSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- Investor RPCs ---

func (s *IdentityServer) InvestorSave(
	ctx context.Context,
	req *connect.Request[identityv1.InvestorSaveRequest],
) (*connect.Response[identityv1.InvestorSaveResponse], error) {
	result, err := s.investorBusiness.Save(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceInvestor, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return connect.NewResponse(&identityv1.InvestorSaveResponse{Data: result}), nil
}

func (s *IdentityServer) InvestorGet(
	ctx context.Context,
	req *connect.Request[identityv1.InvestorGetRequest],
) (*connect.Response[identityv1.InvestorGetResponse], error) {
	result, err := s.investorBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.InvestorGetResponse{Data: result}), nil
}

func (s *IdentityServer) InvestorSearch(
	ctx context.Context,
	req *connect.Request[identityv1.InvestorSearchRequest],
	stream *connect.ServerStream[identityv1.InvestorSearchResponse],
) error {
	err := s.investorBusiness.Search(ctx, req.Msg,
		func(_ context.Context, batch []*identityv1.InvestorObject) error {
			return stream.Send(&identityv1.InvestorSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- Workforce RPCs ---

func (s *IdentityServer) WorkforceMemberSave(
	ctx context.Context,
	req *connect.Request[identityv1.WorkforceMemberSaveRequest],
) (*connect.Response[identityv1.WorkforceMemberSaveResponse], error) {
	result, err := s.workforceBusiness.WorkforceMemberSave(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceWorkforceMember, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return connect.NewResponse(&identityv1.WorkforceMemberSaveResponse{Data: result}), nil
}

func (s *IdentityServer) WorkforceMemberGet(
	ctx context.Context,
	req *connect.Request[identityv1.WorkforceMemberGetRequest],
) (*connect.Response[identityv1.WorkforceMemberGetResponse], error) {
	result, err := s.workforceBusiness.WorkforceMemberGet(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.WorkforceMemberGetResponse{Data: result}), nil
}

func (s *IdentityServer) WorkforceMemberSearch(
	ctx context.Context,
	req *connect.Request[identityv1.WorkforceMemberSearchRequest],
	stream *connect.ServerStream[identityv1.WorkforceMemberSearchResponse],
) error {
	err := s.workforceBusiness.WorkforceMemberSearch(ctx, req.Msg,
		func(_ context.Context, batch []*identityv1.WorkforceMemberObject) error {
			return stream.Send(&identityv1.WorkforceMemberSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

func (s *IdentityServer) DepartmentSave(
	ctx context.Context,
	req *connect.Request[identityv1.DepartmentSaveRequest],
) (*connect.Response[identityv1.DepartmentSaveResponse], error) {
	result, err := s.workforceBusiness.DepartmentSave(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceDepartment, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	return connect.NewResponse(&identityv1.DepartmentSaveResponse{Data: result}), nil
}

func (s *IdentityServer) DepartmentGet(
	ctx context.Context,
	req *connect.Request[identityv1.DepartmentGetRequest],
) (*connect.Response[identityv1.DepartmentGetResponse], error) {
	result, err := s.workforceBusiness.DepartmentGet(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.DepartmentGetResponse{Data: result}), nil
}

func (s *IdentityServer) DepartmentSearch(
	ctx context.Context,
	req *connect.Request[identityv1.DepartmentSearchRequest],
	stream *connect.ServerStream[identityv1.DepartmentSearchResponse],
) error {
	err := s.workforceBusiness.DepartmentSearch(ctx, req.Msg,
		func(_ context.Context, batch []*identityv1.DepartmentObject) error {
			return stream.Send(&identityv1.DepartmentSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

func (s *IdentityServer) PositionSave(
	ctx context.Context,
	req *connect.Request[identityv1.PositionSaveRequest],
) (*connect.Response[identityv1.PositionSaveResponse], error) {
	result, err := s.workforceBusiness.PositionSave(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourcePosition, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	return connect.NewResponse(&identityv1.PositionSaveResponse{Data: result}), nil
}

func (s *IdentityServer) PositionGet(
	ctx context.Context,
	req *connect.Request[identityv1.PositionGetRequest],
) (*connect.Response[identityv1.PositionGetResponse], error) {
	result, err := s.workforceBusiness.PositionGet(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.PositionGetResponse{Data: result}), nil
}

func (s *IdentityServer) PositionSearch(
	ctx context.Context,
	req *connect.Request[identityv1.PositionSearchRequest],
	stream *connect.ServerStream[identityv1.PositionSearchResponse],
) error {
	err := s.workforceBusiness.PositionSearch(ctx, req.Msg,
		func(_ context.Context, batch []*identityv1.PositionObject) error {
			return stream.Send(&identityv1.PositionSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

func (s *IdentityServer) PositionAssignmentSave(
	ctx context.Context,
	req *connect.Request[identityv1.PositionAssignmentSaveRequest],
) (*connect.Response[identityv1.PositionAssignmentSaveResponse], error) {
	result, err := s.workforceBusiness.PositionAssignmentSave(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourcePositionAssignment, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "position_id", result.GetPositionId())
	audit.WithDetail(ctx, "member_id", result.GetMemberId())
	return connect.NewResponse(&identityv1.PositionAssignmentSaveResponse{Data: result}), nil
}

func (s *IdentityServer) PositionAssignmentGet(
	ctx context.Context,
	req *connect.Request[identityv1.PositionAssignmentGetRequest],
) (*connect.Response[identityv1.PositionAssignmentGetResponse], error) {
	result, err := s.workforceBusiness.PositionAssignmentGet(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.PositionAssignmentGetResponse{Data: result}), nil
}

func (s *IdentityServer) PositionAssignmentSearch(
	ctx context.Context,
	req *connect.Request[identityv1.PositionAssignmentSearchRequest],
	stream *connect.ServerStream[identityv1.PositionAssignmentSearchResponse],
) error {
	err := s.workforceBusiness.PositionAssignmentSearch(ctx, req.Msg,
		func(_ context.Context, batch []*identityv1.PositionAssignmentObject) error {
			return stream.Send(&identityv1.PositionAssignmentSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

func (s *IdentityServer) InternalTeamSave(
	ctx context.Context,
	req *connect.Request[identityv1.InternalTeamSaveRequest],
) (*connect.Response[identityv1.InternalTeamSaveResponse], error) {
	result, err := s.workforceBusiness.InternalTeamSave(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceTeam, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	audit.WithDetail(ctx, "team_type", result.GetTeamType())
	return connect.NewResponse(&identityv1.InternalTeamSaveResponse{Data: result}), nil
}

func (s *IdentityServer) InternalTeamGet(
	ctx context.Context,
	req *connect.Request[identityv1.InternalTeamGetRequest],
) (*connect.Response[identityv1.InternalTeamGetResponse], error) {
	result, err := s.workforceBusiness.InternalTeamGet(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.InternalTeamGetResponse{Data: result}), nil
}

func (s *IdentityServer) InternalTeamSearch(
	ctx context.Context,
	req *connect.Request[identityv1.InternalTeamSearchRequest],
	stream *connect.ServerStream[identityv1.InternalTeamSearchResponse],
) error {
	err := s.workforceBusiness.InternalTeamSearch(ctx, req.Msg,
		func(_ context.Context, batch []*identityv1.InternalTeamObject) error {
			return stream.Send(&identityv1.InternalTeamSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

func (s *IdentityServer) TeamMembershipSave(
	ctx context.Context,
	req *connect.Request[identityv1.TeamMembershipSaveRequest],
) (*connect.Response[identityv1.TeamMembershipSaveResponse], error) {
	result, err := s.workforceBusiness.TeamMembershipSave(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceTeamMembership, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithRelation(ctx, audit.Relation{
		ParentType: audit.ResourceTeam,
		ParentID:   result.GetTeamId(),
		ChildType:  audit.ResourceWorkforceMember,
		ChildID:    result.GetMemberId(),
		Action:     audit.RelationAdded,
	})
	return connect.NewResponse(&identityv1.TeamMembershipSaveResponse{Data: result}), nil
}

func (s *IdentityServer) TeamMembershipGet(
	ctx context.Context,
	req *connect.Request[identityv1.TeamMembershipGetRequest],
) (*connect.Response[identityv1.TeamMembershipGetResponse], error) {
	result, err := s.workforceBusiness.TeamMembershipGet(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.TeamMembershipGetResponse{Data: result}), nil
}

func (s *IdentityServer) TeamMembershipSearch(
	ctx context.Context,
	req *connect.Request[identityv1.TeamMembershipSearchRequest],
	stream *connect.ServerStream[identityv1.TeamMembershipSearchResponse],
) error {
	err := s.workforceBusiness.TeamMembershipSearch(ctx, req.Msg,
		func(_ context.Context, batch []*identityv1.TeamMembershipObject) error {
			return stream.Send(&identityv1.TeamMembershipSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

func (s *IdentityServer) AccessRoleAssignmentSave(
	ctx context.Context,
	req *connect.Request[identityv1.AccessRoleAssignmentSaveRequest],
) (*connect.Response[identityv1.AccessRoleAssignmentSaveResponse], error) {
	result, err := s.workforceBusiness.AccessRoleAssignmentSave(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceAccessRole, result.GetId())
	audit.WithAction(ctx, audit.ActionAssign)
	audit.WithDetail(ctx, "role_key", result.GetRoleKey())
	audit.WithDetail(ctx, "member_id", result.GetMemberId())
	return connect.NewResponse(&identityv1.AccessRoleAssignmentSaveResponse{Data: result}), nil
}

func (s *IdentityServer) AccessRoleAssignmentGet(
	ctx context.Context,
	req *connect.Request[identityv1.AccessRoleAssignmentGetRequest],
) (*connect.Response[identityv1.AccessRoleAssignmentGetResponse], error) {
	result, err := s.workforceBusiness.AccessRoleAssignmentGet(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.AccessRoleAssignmentGetResponse{Data: result}), nil
}

func (s *IdentityServer) AccessRoleAssignmentSearch(
	ctx context.Context,
	req *connect.Request[identityv1.AccessRoleAssignmentSearchRequest],
	stream *connect.ServerStream[identityv1.AccessRoleAssignmentSearchResponse],
) error {
	err := s.workforceBusiness.AccessRoleAssignmentSearch(ctx, req.Msg,
		func(_ context.Context, batch []*identityv1.AccessRoleAssignmentObject) error {
			return stream.Send(&identityv1.AccessRoleAssignmentSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- ClientGroup RPCs ---

func (s *IdentityServer) ClientGroupSave(
	ctx context.Context,
	req *connect.Request[identityv1.ClientGroupSaveRequest],
) (*connect.Response[identityv1.ClientGroupSaveResponse], error) {
	group := models.ClientGroupFromAPI(ctx, req.Msg.GetData())
	result, err := s.clientGroupBusiness.Save(ctx, group)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceClientGroup, result.GetID())
	audit.WithAction(ctx, audit.ActionSave)
	return connect.NewResponse(&identityv1.ClientGroupSaveResponse{Data: result.ToAPI()}), nil
}

func (s *IdentityServer) ClientGroupGet(
	ctx context.Context,
	req *connect.Request[identityv1.ClientGroupGetRequest],
) (*connect.Response[identityv1.ClientGroupGetResponse], error) {
	result, err := s.clientGroupBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.ClientGroupGetResponse{Data: result.ToAPI()}), nil
}

func (s *IdentityServer) ClientGroupSearch(
	ctx context.Context,
	req *connect.Request[identityv1.ClientGroupSearchRequest],
	stream *connect.ServerStream[identityv1.ClientGroupSearchResponse],
) error {
	err := s.clientGroupBusiness.Search(ctx,
		req.Msg.GetQuery(), req.Msg.GetAgentId(), req.Msg.GetBranchId(), req.Msg.GetCursor(),
		func(_ context.Context, batch []*models.ClientGroup) error {
			var apiResults []*identityv1.ClientGroupObject
			for _, g := range batch {
				apiResults = append(apiResults, g.ToAPI())
			}
			return stream.Send(&identityv1.ClientGroupSearchResponse{Data: apiResults})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- Membership RPCs ---

func (s *IdentityServer) MembershipSave(
	ctx context.Context,
	req *connect.Request[identityv1.MembershipSaveRequest],
) (*connect.Response[identityv1.MembershipSaveResponse], error) {
	membership := models.MembershipFromAPI(ctx, req.Msg.GetData())
	result, err := s.membershipBusiness.Save(ctx, membership)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceMembership, result.GetID())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithRelation(ctx, audit.Relation{
		ParentType: audit.ResourceClientGroup,
		ParentID:   result.GroupID,
		ChildType:  audit.ResourceClient,
		ChildID:    result.ProfileID,
		Action:     audit.RelationAdded,
	})
	return connect.NewResponse(&identityv1.MembershipSaveResponse{Data: result.ToAPI()}), nil
}

func (s *IdentityServer) MembershipGet(
	ctx context.Context,
	req *connect.Request[identityv1.MembershipGetRequest],
) (*connect.Response[identityv1.MembershipGetResponse], error) {
	result, err := s.membershipBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.MembershipGetResponse{Data: result.ToAPI()}), nil
}

func (s *IdentityServer) MembershipSearch(
	ctx context.Context,
	req *connect.Request[identityv1.MembershipSearchRequest],
	stream *connect.ServerStream[identityv1.MembershipSearchResponse],
) error {
	err := s.membershipBusiness.Search(ctx,
		req.Msg.GetQuery(), req.Msg.GetGroupId(), req.Msg.GetProfileId(), req.Msg.GetCursor(),
		func(_ context.Context, batch []*models.Membership) error {
			var apiResults []*identityv1.MembershipObject
			for _, m := range batch {
				apiResults = append(apiResults, m.ToAPI())
			}
			return stream.Send(&identityv1.MembershipSearchResponse{Data: apiResults})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- ClientData RPCs ---

func (s *IdentityServer) ClientDataSave(
	ctx context.Context,
	req *connect.Request[identityv1.ClientDataSaveRequest],
) (*connect.Response[identityv1.ClientDataSaveResponse], error) {
	entry := models.ClientDataEntryFromAPI(ctx, req.Msg.GetData())
	result, err := s.clientDataBusiness.Save(ctx, entry)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, auditResourceClientDataEntry, result.GetID())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "field_key", result.FieldKey)
	audit.WithDetail(ctx, "client_id", result.ClientID)
	return connect.NewResponse(&identityv1.ClientDataSaveResponse{Data: result.ToAPI()}), nil
}

func (s *IdentityServer) ClientDataGet(
	ctx context.Context,
	req *connect.Request[identityv1.ClientDataGetRequest],
) (*connect.Response[identityv1.ClientDataGetResponse], error) {
	result, err := s.clientDataBusiness.Get(ctx, req.Msg.GetClientId(), req.Msg.GetFieldKey())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.ClientDataGetResponse{Data: result.ToAPI()}), nil
}

func (s *IdentityServer) ClientDataList(
	ctx context.Context,
	req *connect.Request[identityv1.ClientDataListRequest],
	stream *connect.ServerStream[identityv1.ClientDataListResponse],
) error {
	offset, limit, err := pageBounds(req.Msg.GetCursor())
	if err != nil {
		return apperrors.CleanErr(err)
	}

	status := int32(req.Msg.GetVerificationStatus())
	for {
		results, listErr := s.clientDataBusiness.List(ctx, req.Msg.GetClientId(), status, offset, limit)
		if listErr != nil {
			return apperrors.CleanErr(listErr)
		}
		if len(results) == 0 {
			return nil
		}

		apiResults := make([]*identityv1.ClientDataEntryObject, 0, len(results))
		for _, e := range results {
			apiResults = append(apiResults, e.ToAPI())
		}
		if sendErr := stream.Send(&identityv1.ClientDataListResponse{Data: apiResults}); sendErr != nil {
			return sendErr
		}

		if len(results) < limit {
			return nil
		}
		offset += len(results)
	}
}

// pageBounds resolves a page cursor into an offset and a per-batch limit. A
// page token that is not a non-negative integer is rejected rather than
// silently resolving to the first page.
func pageBounds(cursor *commonv1.PageCursor) (int, int, error) {
	offset := 0
	limit := defaultPageLimit
	if cursor == nil {
		return offset, limit, nil
	}

	if page := strings.TrimSpace(cursor.GetPage()); page != "" {
		parsed, err := strconv.Atoi(page)
		if err != nil || parsed < 0 {
			return 0, 0, business.ErrInvalidPageToken
		}
		offset = parsed
	}

	if l := cursor.GetLimit(); l > 0 {
		limit = int(l)
		if limit > maxPageLimit {
			limit = maxPageLimit
		}
	}
	return offset, limit, nil
}

func (s *IdentityServer) ClientDataVerify(
	ctx context.Context,
	req *connect.Request[identityv1.ClientDataVerifyRequest],
) (*connect.Response[identityv1.ClientDataVerifyResponse], error) {
	result, err := s.clientDataBusiness.Verify(ctx, req.Msg.GetEntryId(), req.Msg.GetComment())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, auditResourceClientDataEntry, result.GetID())
	audit.WithAction(ctx, audit.ActionVerify)
	audit.WithDetail(ctx, "reviewer_id", result.ReviewerID)
	return connect.NewResponse(&identityv1.ClientDataVerifyResponse{Data: result.ToAPI()}), nil
}

func (s *IdentityServer) ClientDataReject(
	ctx context.Context,
	req *connect.Request[identityv1.ClientDataRejectRequest],
) (*connect.Response[identityv1.ClientDataRejectResponse], error) {
	result, err := s.clientDataBusiness.Reject(ctx, req.Msg.GetEntryId(), req.Msg.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, auditResourceClientDataEntry, result.GetID())
	audit.WithAction(ctx, audit.ActionReject)
	audit.WithDetail(ctx, "reviewer_id", result.ReviewerID)
	return connect.NewResponse(&identityv1.ClientDataRejectResponse{Data: result.ToAPI()}), nil
}

func (s *IdentityServer) ClientDataRequestInfo(
	ctx context.Context,
	req *connect.Request[identityv1.ClientDataRequestInfoRequest],
) (*connect.Response[identityv1.ClientDataRequestInfoResponse], error) {
	result, err := s.clientDataBusiness.RequestInfo(ctx, req.Msg.GetEntryId(), req.Msg.GetComment())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, auditResourceClientDataEntry, result.GetID())
	audit.WithAction(ctx, auditActionRequestInfo)
	audit.WithDetail(ctx, "reviewer_id", result.ReviewerID)
	return connect.NewResponse(&identityv1.ClientDataRequestInfoResponse{Data: result.ToAPI()}), nil
}

func (s *IdentityServer) ClientDataHistory(
	ctx context.Context,
	req *connect.Request[identityv1.ClientDataHistoryRequest],
) (*connect.Response[identityv1.ClientDataHistoryResponse], error) {
	results, err := s.clientDataBusiness.History(ctx, req.Msg.GetEntryId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	var apiResults []*identityv1.ClientDataEntryHistoryObject
	for _, h := range results {
		apiResults = append(apiResults, h.ToAPI())
	}
	return connect.NewResponse(&identityv1.ClientDataHistoryResponse{Data: apiResults}), nil
}

// --- FormTemplate RPCs ---

func (s *IdentityServer) FormTemplateSave(
	ctx context.Context,
	req *connect.Request[identityv1.FormTemplateSaveRequest],
) (*connect.Response[identityv1.FormTemplateSaveResponse], error) {
	result, err := s.formTemplateBusiness.Save(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceFormTemplate, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return connect.NewResponse(&identityv1.FormTemplateSaveResponse{Data: result}), nil
}

func (s *IdentityServer) FormTemplateGet(
	ctx context.Context,
	req *connect.Request[identityv1.FormTemplateGetRequest],
) (*connect.Response[identityv1.FormTemplateGetResponse], error) {
	result, err := s.formTemplateBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.FormTemplateGetResponse{Data: result}), nil
}

func (s *IdentityServer) FormTemplateSearch(
	ctx context.Context,
	req *connect.Request[identityv1.FormTemplateSearchRequest],
	stream *connect.ServerStream[identityv1.FormTemplateSearchResponse],
) error {
	err := s.formTemplateBusiness.Search(
		ctx,
		req.Msg,
		func(_ context.Context, batch []*identityv1.FormTemplateObject) error {
			return stream.Send(&identityv1.FormTemplateSearchResponse{Data: batch})
		},
	)
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

func (s *IdentityServer) FormTemplatePublish(
	ctx context.Context,
	req *connect.Request[identityv1.FormTemplatePublishRequest],
) (*connect.Response[identityv1.FormTemplatePublishResponse], error) {
	result, err := s.formTemplateBusiness.Publish(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceFormTemplate, req.Msg.GetId())
	audit.WithAction(ctx, "publish")
	return connect.NewResponse(&identityv1.FormTemplatePublishResponse{Data: result}), nil
}

// --- FormSubmission RPCs ---

func (s *IdentityServer) FormSubmissionSave(
	ctx context.Context,
	req *connect.Request[identityv1.FormSubmissionSaveRequest],
) (*connect.Response[identityv1.FormSubmissionSaveResponse], error) {
	result, err := s.formSubmissionBusiness.Save(ctx, req.Msg.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceFormSubmission, result.GetId())
	audit.WithAction(ctx, audit.ActionSubmit)
	return connect.NewResponse(&identityv1.FormSubmissionSaveResponse{Data: result}), nil
}

func (s *IdentityServer) FormSubmissionGet(
	ctx context.Context,
	req *connect.Request[identityv1.FormSubmissionGetRequest],
) (*connect.Response[identityv1.FormSubmissionGetResponse], error) {
	result, err := s.formSubmissionBusiness.Get(ctx, req.Msg.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return connect.NewResponse(&identityv1.FormSubmissionGetResponse{Data: result}), nil
}

func (s *IdentityServer) FormSubmissionSearch(
	ctx context.Context,
	req *connect.Request[identityv1.FormSubmissionSearchRequest],
	stream *connect.ServerStream[identityv1.FormSubmissionSearchResponse],
) error {
	err := s.formSubmissionBusiness.Search(
		ctx,
		req.Msg,
		func(_ context.Context, batch []*identityv1.FormSubmissionObject) error {
			return stream.Send(&identityv1.FormSubmissionSearchResponse{Data: batch})
		},
	)
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}
