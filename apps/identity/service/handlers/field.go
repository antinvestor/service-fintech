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

	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	audit "github.com/antinvestor/common/audit"

	"github.com/antinvestor/service-fintech/apps/identity/service/business"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// FieldServer implements the FieldService RPC handler.
// Tenant-level permission checks are handled by the FunctionAccessInterceptor.
type FieldServer struct {
	agentBusiness              business.AgentBusiness
	clientBusiness             business.ClientBusiness
	clientRelationshipBusiness business.ClientRelationshipBusiness

	fieldv1connect.UnimplementedFieldServiceHandler
}

func NewFieldServer(
	agentBusiness business.AgentBusiness,
	clientBusiness business.ClientBusiness,
	clientRelationshipBusiness business.ClientRelationshipBusiness,
) fieldv1connect.FieldServiceHandler {
	return &FieldServer{
		agentBusiness:              agentBusiness,
		clientBusiness:             clientBusiness,
		clientRelationshipBusiness: clientRelationshipBusiness,
	}
}

// --- Agent RPCs ---

func (s *FieldServer) AgentSave(
	ctx context.Context,
	req *fieldv1.AgentSaveRequest,
) (*fieldv1.AgentSaveResponse, error) {
	result, err := s.agentBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceAgent, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return &fieldv1.AgentSaveResponse{Data: result}, nil
}

func (s *FieldServer) AgentGet(
	ctx context.Context,
	req *fieldv1.AgentGetRequest,
) (*fieldv1.AgentGetResponse, error) {
	result, err := s.agentBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &fieldv1.AgentGetResponse{Data: result}, nil
}

func (s *FieldServer) AgentSearch(
	ctx context.Context,
	req *fieldv1.AgentSearchRequest,
	stream fieldv1connect.FieldServiceAgentSearchServerStream,
) error {
	err := s.agentBusiness.Search(ctx, req,
		func(_ context.Context, batch []*fieldv1.AgentObject) error {
			return stream.Send(&fieldv1.AgentSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

func (s *FieldServer) AgentHierarchy(
	ctx context.Context,
	req *fieldv1.AgentHierarchyRequest,
	stream fieldv1connect.FieldServiceAgentHierarchyServerStream,
) error {
	err := s.agentBusiness.Hierarchy(ctx, req,
		func(_ context.Context, batch []*fieldv1.AgentObject) error {
			return stream.Send(&fieldv1.AgentHierarchyResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

// --- Agent Branch RPCs ---

func (s *FieldServer) AgentBranchSave(
	ctx context.Context,
	req *fieldv1.AgentBranchSaveRequest,
) (*fieldv1.AgentBranchSaveResponse, error) {
	model := models.AgentBranchFromAPI(ctx, req.GetData())
	result, err := s.agentBusiness.SaveBranch(ctx, model)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceAgent, result.GetID())
	audit.WithAction(ctx, audit.ActionSave)
	audit.WithRelation(ctx, audit.Relation{
		ParentType: audit.ResourceAgent,
		ParentID:   result.AgentID,
		ChildType:  audit.ResourceOrgUnit,
		ChildID:    result.BranchID,
		Action:     audit.RelationAdded,
	})
	return &fieldv1.AgentBranchSaveResponse{Data: result.ToAPI()}, nil
}

func (s *FieldServer) AgentBranchDelete(
	ctx context.Context,
	req *fieldv1.AgentBranchDeleteRequest,
) (*fieldv1.AgentBranchDeleteResponse, error) {
	if err := s.agentBusiness.DeleteBranch(ctx, req.GetId()); err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceAgent, req.GetId())
	audit.WithAction(ctx, audit.ActionDelete)
	return &fieldv1.AgentBranchDeleteResponse{}, nil
}

func (s *FieldServer) AgentBranchList(
	ctx context.Context,
	req *fieldv1.AgentBranchListRequest,
	stream fieldv1connect.FieldServiceAgentBranchListServerStream,
) error {
	var results []*models.AgentBranch
	var err error

	switch {
	case req.GetAgentId() != "":
		results, err = s.agentBusiness.ListBranchesByAgent(ctx, req.GetAgentId())
	case req.GetBranchId() != "":
		results, err = s.agentBusiness.ListBranchesByBranch(ctx, req.GetBranchId())
	default:
		return apperrors.CleanErr(apperrors.ErrInvalidInput.Extend("agent_id or branch_id is required"))
	}

	if err != nil {
		return apperrors.CleanErr(err)
	}

	var apiResults []*fieldv1.AgentBranchObject
	for _, ab := range results {
		apiResults = append(apiResults, ab.ToAPI())
	}

	return stream.Send(&fieldv1.AgentBranchListResponse{Data: apiResults})
}

// --- Client RPCs ---

func (s *FieldServer) ClientSave(
	ctx context.Context,
	req *fieldv1.ClientSaveRequest,
) (*fieldv1.ClientSaveResponse, error) {
	result, err := s.clientBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceClient, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return &fieldv1.ClientSaveResponse{Data: result}, nil
}

func (s *FieldServer) ClientGet(
	ctx context.Context,
	req *fieldv1.ClientGetRequest,
) (*fieldv1.ClientGetResponse, error) {
	result, err := s.clientBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &fieldv1.ClientGetResponse{Data: result}, nil
}

func (s *FieldServer) ClientSearch(
	ctx context.Context,
	req *fieldv1.ClientSearchRequest,
	stream fieldv1connect.FieldServiceClientSearchServerStream,
) error {
	err := s.clientBusiness.Search(ctx, req,
		func(_ context.Context, batch []*fieldv1.ClientObject) error {
			return stream.Send(&fieldv1.ClientSearchResponse{Data: batch})
		})
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return nil
}

func (s *FieldServer) ClientReassign(
	ctx context.Context,
	req *fieldv1.ClientReassignRequest,
) (*fieldv1.ClientReassignResponse, error) {
	result, err := s.clientBusiness.Reassign(ctx, req)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceClient, result.GetId())
	audit.WithAction(ctx, audit.ActionAssign)
	return &fieldv1.ClientReassignResponse{Data: result}, nil
}

func (s *FieldServer) ClientOwnershipTransfer(
	ctx context.Context,
	req *fieldv1.ClientOwnershipTransferRequest,
) (*fieldv1.ClientOwnershipTransferResponse, error) {
	result, err := s.clientBusiness.TransferOwnership(ctx, req)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceClient, result.GetId())
	audit.WithAction(ctx, audit.ActionTransfer)
	return &fieldv1.ClientOwnershipTransferResponse{Data: result}, nil
}

// --- ClientRelationship RPCs ---

func (s *FieldServer) ClientRelationshipSave(
	ctx context.Context,
	req *fieldv1.ClientRelationshipSaveRequest,
) (*fieldv1.ClientRelationshipSaveResponse, error) {
	result, err := s.clientRelationshipBusiness.Save(ctx, req.GetData())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, audit.ResourceClientRelationship, result.GetId())
	audit.WithAction(ctx, audit.ActionSave)
	return &fieldv1.ClientRelationshipSaveResponse{Data: result}, nil
}

func (s *FieldServer) ClientRelationshipGet(
	ctx context.Context,
	req *fieldv1.ClientRelationshipGetRequest,
) (*fieldv1.ClientRelationshipGetResponse, error) {
	result, err := s.clientRelationshipBusiness.Get(ctx, req.GetId())
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	return &fieldv1.ClientRelationshipGetResponse{Data: result}, nil
}

func (s *FieldServer) ClientRelationshipSearch(
	ctx context.Context,
	req *fieldv1.ClientRelationshipSearchRequest,
	stream fieldv1connect.FieldServiceClientRelationshipSearchServerStream,
) error {
	return s.clientRelationshipBusiness.Search(
		ctx,
		req,
		func(_ context.Context, batch []*fieldv1.ClientRelationshipObject) error {
			return stream.Send(&fieldv1.ClientRelationshipSearchResponse{Data: batch})
		},
	)
}
