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
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
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
	req *identityv1.OrganizationSaveRequest,
) (*identityv1.OrganizationSaveResponse, error) {
	result, err := s.organizationBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceOrganization, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	return &identityv1.OrganizationSaveResponse{Data: result}, nil
}

func (s *IdentityServer) OrganizationGet(
	ctx context.Context,
	req *identityv1.OrganizationGetRequest,
) (*identityv1.OrganizationGetResponse, error) {
	result, err := s.organizationBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.OrganizationGetResponse{Data: result}, nil
}

func (s *IdentityServer) OrganizationSearch(
	ctx context.Context,
	req *commonv1.SearchRequest,
	stream identityv1connect.IdentityServiceOrganizationSearchServerStream,
) error {
	searchReq := &commonv1.SearchRequest{
		Query:      req.GetQuery(),
		Extras:     req.GetExtras(),
		IdQuery:    req.GetIdQuery(),
		Properties: req.GetProperties(),
	}
	if cursor := req.GetCursor(); cursor != nil {
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
	req *identityv1.OrgUnitSaveRequest,
) (*identityv1.OrgUnitSaveResponse, error) {
	result, err := s.orgUnitBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceOrgUnit, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	return &identityv1.OrgUnitSaveResponse{Data: result}, nil
}

func (s *IdentityServer) OrgUnitGet(
	ctx context.Context,
	req *identityv1.OrgUnitGetRequest,
) (*identityv1.OrgUnitGetResponse, error) {
	result, err := s.orgUnitBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.OrgUnitGetResponse{Data: result}, nil
}

func (s *IdentityServer) OrgUnitSearch(
	ctx context.Context,
	req *identityv1.OrgUnitSearchRequest,
	stream identityv1connect.IdentityServiceOrgUnitSearchServerStream,
) error {
	err := s.orgUnitBusiness.Search(ctx, req,
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
	req *identityv1.InvestorSaveRequest,
) (*identityv1.InvestorSaveResponse, error) {
	result, err := s.investorBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceInvestor, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return &identityv1.InvestorSaveResponse{Data: result}, nil
}

func (s *IdentityServer) InvestorGet(
	ctx context.Context,
	req *identityv1.InvestorGetRequest,
) (*identityv1.InvestorGetResponse, error) {
	result, err := s.investorBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.InvestorGetResponse{Data: result}, nil
}

func (s *IdentityServer) InvestorSearch(
	ctx context.Context,
	req *identityv1.InvestorSearchRequest,
	stream identityv1connect.IdentityServiceInvestorSearchServerStream,
) error {
	err := s.investorBusiness.Search(ctx, req,
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
	req *identityv1.WorkforceMemberSaveRequest,
) (*identityv1.WorkforceMemberSaveResponse, error) {
	result, err := s.workforceBusiness.WorkforceMemberSave(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceWorkforceMember, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return &identityv1.WorkforceMemberSaveResponse{Data: result}, nil
}

func (s *IdentityServer) WorkforceMemberGet(
	ctx context.Context,
	req *identityv1.WorkforceMemberGetRequest,
) (*identityv1.WorkforceMemberGetResponse, error) {
	result, err := s.workforceBusiness.WorkforceMemberGet(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.WorkforceMemberGetResponse{Data: result}, nil
}

func (s *IdentityServer) WorkforceMemberSearch(
	ctx context.Context,
	req *identityv1.WorkforceMemberSearchRequest,
	stream identityv1connect.IdentityServiceWorkforceMemberSearchServerStream,
) error {
	err := s.workforceBusiness.WorkforceMemberSearch(ctx, req,
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
	req *identityv1.DepartmentSaveRequest,
) (*identityv1.DepartmentSaveResponse, error) {
	result, err := s.workforceBusiness.DepartmentSave(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceDepartment, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	return &identityv1.DepartmentSaveResponse{Data: result}, nil
}

func (s *IdentityServer) DepartmentGet(
	ctx context.Context,
	req *identityv1.DepartmentGetRequest,
) (*identityv1.DepartmentGetResponse, error) {
	result, err := s.workforceBusiness.DepartmentGet(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.DepartmentGetResponse{Data: result}, nil
}

func (s *IdentityServer) DepartmentSearch(
	ctx context.Context,
	req *identityv1.DepartmentSearchRequest,
	stream identityv1connect.IdentityServiceDepartmentSearchServerStream,
) error {
	err := s.workforceBusiness.DepartmentSearch(ctx, req,
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
	req *identityv1.PositionSaveRequest,
) (*identityv1.PositionSaveResponse, error) {
	result, err := s.workforceBusiness.PositionSave(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourcePosition, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	return &identityv1.PositionSaveResponse{Data: result}, nil
}

func (s *IdentityServer) PositionGet(
	ctx context.Context,
	req *identityv1.PositionGetRequest,
) (*identityv1.PositionGetResponse, error) {
	result, err := s.workforceBusiness.PositionGet(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.PositionGetResponse{Data: result}, nil
}

func (s *IdentityServer) PositionSearch(
	ctx context.Context,
	req *identityv1.PositionSearchRequest,
	stream identityv1connect.IdentityServicePositionSearchServerStream,
) error {
	err := s.workforceBusiness.PositionSearch(ctx, req,
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
	req *identityv1.PositionAssignmentSaveRequest,
) (*identityv1.PositionAssignmentSaveResponse, error) {
	result, err := s.workforceBusiness.PositionAssignmentSave(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourcePositionAssignment, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "position_id", result.GetPositionId())
	audit.WithDetail(ctx, "member_id", result.GetMemberId())
	return &identityv1.PositionAssignmentSaveResponse{Data: result}, nil
}

func (s *IdentityServer) PositionAssignmentGet(
	ctx context.Context,
	req *identityv1.PositionAssignmentGetRequest,
) (*identityv1.PositionAssignmentGetResponse, error) {
	result, err := s.workforceBusiness.PositionAssignmentGet(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.PositionAssignmentGetResponse{Data: result}, nil
}

func (s *IdentityServer) PositionAssignmentSearch(
	ctx context.Context,
	req *identityv1.PositionAssignmentSearchRequest,
	stream identityv1connect.IdentityServicePositionAssignmentSearchServerStream,
) error {
	err := s.workforceBusiness.PositionAssignmentSearch(ctx, req,
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
	req *identityv1.InternalTeamSaveRequest,
) (*identityv1.InternalTeamSaveResponse, error) {
	result, err := s.workforceBusiness.InternalTeamSave(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceTeam, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "name", result.GetName())
	audit.WithDetail(ctx, "team_type", result.GetTeamType())
	return &identityv1.InternalTeamSaveResponse{Data: result}, nil
}

func (s *IdentityServer) InternalTeamGet(
	ctx context.Context,
	req *identityv1.InternalTeamGetRequest,
) (*identityv1.InternalTeamGetResponse, error) {
	result, err := s.workforceBusiness.InternalTeamGet(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.InternalTeamGetResponse{Data: result}, nil
}

func (s *IdentityServer) InternalTeamSearch(
	ctx context.Context,
	req *identityv1.InternalTeamSearchRequest,
	stream identityv1connect.IdentityServiceInternalTeamSearchServerStream,
) error {
	err := s.workforceBusiness.InternalTeamSearch(ctx, req,
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
	req *identityv1.TeamMembershipSaveRequest,
) (*identityv1.TeamMembershipSaveResponse, error) {
	result, err := s.workforceBusiness.TeamMembershipSave(ctx, req.GetData())
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
	return &identityv1.TeamMembershipSaveResponse{Data: result}, nil
}

func (s *IdentityServer) TeamMembershipGet(
	ctx context.Context,
	req *identityv1.TeamMembershipGetRequest,
) (*identityv1.TeamMembershipGetResponse, error) {
	result, err := s.workforceBusiness.TeamMembershipGet(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.TeamMembershipGetResponse{Data: result}, nil
}

func (s *IdentityServer) TeamMembershipSearch(
	ctx context.Context,
	req *identityv1.TeamMembershipSearchRequest,
	stream identityv1connect.IdentityServiceTeamMembershipSearchServerStream,
) error {
	err := s.workforceBusiness.TeamMembershipSearch(ctx, req,
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
	req *identityv1.AccessRoleAssignmentSaveRequest,
) (*identityv1.AccessRoleAssignmentSaveResponse, error) {
	result, err := s.workforceBusiness.AccessRoleAssignmentSave(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceAccessRole, result.GetId())
	audit.WithAction(ctx, audit.ActionAssign)
	audit.WithDetail(ctx, "role_key", result.GetRoleKey())
	audit.WithDetail(ctx, "member_id", result.GetMemberId())
	return &identityv1.AccessRoleAssignmentSaveResponse{Data: result}, nil
}

func (s *IdentityServer) AccessRoleAssignmentGet(
	ctx context.Context,
	req *identityv1.AccessRoleAssignmentGetRequest,
) (*identityv1.AccessRoleAssignmentGetResponse, error) {
	result, err := s.workforceBusiness.AccessRoleAssignmentGet(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.AccessRoleAssignmentGetResponse{Data: result}, nil
}

func (s *IdentityServer) AccessRoleAssignmentSearch(
	ctx context.Context,
	req *identityv1.AccessRoleAssignmentSearchRequest,
	stream identityv1connect.IdentityServiceAccessRoleAssignmentSearchServerStream,
) error {
	err := s.workforceBusiness.AccessRoleAssignmentSearch(ctx, req,
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
	req *identityv1.ClientGroupSaveRequest,
) (*identityv1.ClientGroupSaveResponse, error) {
	group := models.ClientGroupFromAPI(ctx, req.GetData())
	result, err := s.clientGroupBusiness.Save(ctx, group)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceClientGroup, result.GetID())
	audit.WithAction(ctx, audit.ActionSave)
	return &identityv1.ClientGroupSaveResponse{Data: result.ToAPI()}, nil
}

func (s *IdentityServer) ClientGroupGet(
	ctx context.Context,
	req *identityv1.ClientGroupGetRequest,
) (*identityv1.ClientGroupGetResponse, error) {
	result, err := s.clientGroupBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.ClientGroupGetResponse{Data: result.ToAPI()}, nil
}

func (s *IdentityServer) ClientGroupSearch(
	ctx context.Context,
	req *identityv1.ClientGroupSearchRequest,
	stream identityv1connect.IdentityServiceClientGroupSearchServerStream,
) error {
	err := s.clientGroupBusiness.Search(ctx,
		req.GetQuery(), req.GetAgentId(), req.GetBranchId(), req.GetCursor(),
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
	req *identityv1.MembershipSaveRequest,
) (*identityv1.MembershipSaveResponse, error) {
	membership := models.MembershipFromAPI(ctx, req.GetData())
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
	return &identityv1.MembershipSaveResponse{Data: result.ToAPI()}, nil
}

func (s *IdentityServer) MembershipGet(
	ctx context.Context,
	req *identityv1.MembershipGetRequest,
) (*identityv1.MembershipGetResponse, error) {
	result, err := s.membershipBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.MembershipGetResponse{Data: result.ToAPI()}, nil
}

func (s *IdentityServer) MembershipSearch(
	ctx context.Context,
	req *identityv1.MembershipSearchRequest,
	stream identityv1connect.IdentityServiceMembershipSearchServerStream,
) error {
	err := s.membershipBusiness.Search(ctx,
		req.GetQuery(), req.GetGroupId(), req.GetProfileId(), req.GetCursor(),
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
	req *identityv1.ClientDataSaveRequest,
) (*identityv1.ClientDataSaveResponse, error) {
	entry := models.ClientDataEntryFromAPI(ctx, req.GetData())
	result, err := s.clientDataBusiness.Save(ctx, entry)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, auditResourceClientDataEntry, result.GetID())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithDetail(ctx, "field_key", result.FieldKey)
	audit.WithDetail(ctx, "client_id", result.ClientID)
	return &identityv1.ClientDataSaveResponse{Data: result.ToAPI()}, nil
}

func (s *IdentityServer) ClientDataGet(
	ctx context.Context,
	req *identityv1.ClientDataGetRequest,
) (*identityv1.ClientDataGetResponse, error) {
	result, err := s.clientDataBusiness.Get(ctx, req.GetClientId(), req.GetFieldKey())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.ClientDataGetResponse{Data: result.ToAPI()}, nil
}

func (s *IdentityServer) ClientDataList(
	ctx context.Context,
	req *identityv1.ClientDataListRequest,
	stream identityv1connect.IdentityServiceClientDataListServerStream,
) error {
	offset, limit, err := pageBounds(req.GetCursor())
	if err != nil {
		return apperrors.CleanErr(err)
	}

	status := int32(req.GetVerificationStatus())
	for {
		results, listErr := s.clientDataBusiness.List(ctx, req.GetClientId(), status, offset, limit)
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

// ClientKYCRequirements reports the client's organization's KYC
// requirements and, for a client, where each required field stands.
func (s *IdentityServer) ClientKYCRequirements(
	ctx context.Context,
	req *identityv1.ClientKYCRequirementsRequest,
) (*identityv1.ClientKYCRequirementsResponse, error) {
	reqs, err := s.clientDataBusiness.Requirements(ctx, req.GetClientId(), req.GetOwningTeamId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.ClientKYCRequirementsResponse{
		Template:     reqs.Template.ToAPI(),
		Requirements: reqs.Requirements,
		Complete:     reqs.Complete,
	}, nil
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

func (s *IdentityServer) ClientDataStartReview(
	ctx context.Context,
	req *identityv1.ClientDataStartReviewRequest,
) (*identityv1.ClientDataStartReviewResponse, error) {
	result, err := s.clientDataBusiness.StartReview(ctx, req.GetEntryId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, auditResourceClientDataEntry, result.GetID())
	audit.WithAction(ctx, audit.ActionUpdate)
	audit.WithDetail(ctx, "reviewer_id", result.ReviewerID)
	return &identityv1.ClientDataStartReviewResponse{Data: result.ToAPI()}, nil
}

func (s *IdentityServer) ClientDataVerify(
	ctx context.Context,
	req *identityv1.ClientDataVerifyRequest,
) (*identityv1.ClientDataVerifyResponse, error) {
	result, err := s.clientDataBusiness.Verify(ctx, req.GetEntryId(), req.GetComment())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, auditResourceClientDataEntry, result.GetID())
	audit.WithAction(ctx, audit.ActionVerify)
	audit.WithDetail(ctx, "reviewer_id", result.ReviewerID)
	return &identityv1.ClientDataVerifyResponse{Data: result.ToAPI()}, nil
}

func (s *IdentityServer) ClientDataReject(
	ctx context.Context,
	req *identityv1.ClientDataRejectRequest,
) (*identityv1.ClientDataRejectResponse, error) {
	result, err := s.clientDataBusiness.Reject(ctx, req.GetEntryId(), req.GetReason())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, auditResourceClientDataEntry, result.GetID())
	audit.WithAction(ctx, audit.ActionReject)
	audit.WithDetail(ctx, "reviewer_id", result.ReviewerID)
	return &identityv1.ClientDataRejectResponse{Data: result.ToAPI()}, nil
}

func (s *IdentityServer) ClientDataRequestInfo(
	ctx context.Context,
	req *identityv1.ClientDataRequestInfoRequest,
) (*identityv1.ClientDataRequestInfoResponse, error) {
	result, err := s.clientDataBusiness.RequestInfo(ctx, req.GetEntryId(), req.GetComment())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, auditResourceClientDataEntry, result.GetID())
	audit.WithAction(ctx, auditActionRequestInfo)
	audit.WithDetail(ctx, "reviewer_id", result.ReviewerID)
	return &identityv1.ClientDataRequestInfoResponse{Data: result.ToAPI()}, nil
}

func (s *IdentityServer) ClientDataHistory(
	ctx context.Context,
	req *identityv1.ClientDataHistoryRequest,
) (*identityv1.ClientDataHistoryResponse, error) {
	results, err := s.clientDataBusiness.History(ctx, req.GetEntryId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	var apiResults []*identityv1.ClientDataEntryHistoryObject
	for _, h := range results {
		apiResults = append(apiResults, h.ToAPI())
	}
	return &identityv1.ClientDataHistoryResponse{Data: apiResults}, nil
}

// --- FormTemplate RPCs ---

func (s *IdentityServer) FormTemplateSave(
	ctx context.Context,
	req *identityv1.FormTemplateSaveRequest,
) (*identityv1.FormTemplateSaveResponse, error) {
	result, err := s.formTemplateBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceFormTemplate, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return &identityv1.FormTemplateSaveResponse{Data: result}, nil
}

func (s *IdentityServer) FormTemplateGet(
	ctx context.Context,
	req *identityv1.FormTemplateGetRequest,
) (*identityv1.FormTemplateGetResponse, error) {
	result, err := s.formTemplateBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.FormTemplateGetResponse{Data: result}, nil
}

func (s *IdentityServer) FormTemplateSearch(
	ctx context.Context,
	req *identityv1.FormTemplateSearchRequest,
	stream identityv1connect.IdentityServiceFormTemplateSearchServerStream,
) error {
	err := s.formTemplateBusiness.Search(
		ctx,
		req,
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
	req *identityv1.FormTemplatePublishRequest,
) (*identityv1.FormTemplatePublishResponse, error) {
	result, err := s.formTemplateBusiness.Publish(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceFormTemplate, req.GetId())
	audit.WithAction(ctx, "publish")
	return &identityv1.FormTemplatePublishResponse{Data: result}, nil
}

// --- FormSubmission RPCs ---

func (s *IdentityServer) FormSubmissionSave(
	ctx context.Context,
	req *identityv1.FormSubmissionSaveRequest,
) (*identityv1.FormSubmissionSaveResponse, error) {
	result, err := s.formSubmissionBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceFormSubmission, result.GetId())
	audit.WithAction(ctx, audit.ActionSubmit)
	return &identityv1.FormSubmissionSaveResponse{Data: result}, nil
}

func (s *IdentityServer) FormSubmissionGet(
	ctx context.Context,
	req *identityv1.FormSubmissionGetRequest,
) (*identityv1.FormSubmissionGetResponse, error) {
	result, err := s.formSubmissionBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &identityv1.FormSubmissionGetResponse{Data: result}, nil
}

func (s *IdentityServer) FormSubmissionSearch(
	ctx context.Context,
	req *identityv1.FormSubmissionSearchRequest,
	stream identityv1connect.IdentityServiceFormSubmissionSearchServerStream,
) error {
	err := s.formSubmissionBusiness.Search(
		ctx,
		req,
		func(_ context.Context, batch []*identityv1.FormSubmissionObject) error {
			return stream.Send(&identityv1.FormSubmissionSearchResponse{Data: batch})
		},
	)
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}
