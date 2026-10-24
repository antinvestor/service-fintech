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

// Package handlers wires Connect-RPC handlers to business-layer interfaces.
// Handlers are responsible for serialisation, error mapping, validation,
// and tracing — never domain logic.
package handlers

import (
	"context"
	"errors"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect/v2"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
)

// AdminService implements limitsv1connect.LimitsAdminServiceHandler.
// It covers policy CRUD, approval workflow management, ledger search, and audit search.
type AdminService struct {
	limitsv1connect.UnimplementedLimitsAdminServiceHandler
	policy   business.PolicyBusiness
	approval business.ApprovalBusiness
	ledger   business.LedgerSearchBusiness
	audit    business.AuditSearchBusiness
}

// NewAdminService constructs a Connect handler.
// approval, ledger, and audit may be nil if those RPCs are not yet wired (existing
// tests pass nil for them; the Unimplemented embed handles the fallback).
func NewAdminService(
	policy business.PolicyBusiness,
	approval business.ApprovalBusiness,
	ledger business.LedgerSearchBusiness,
	audit business.AuditSearchBusiness,
) *AdminService {
	return &AdminService{policy: policy, approval: approval, ledger: ledger, audit: audit}
}

// PolicySave creates or updates a policy.
func (s *AdminService) PolicySave(
	ctx context.Context,
	req *limitsv1.PolicySaveRequest,
) (*limitsv1.PolicySaveResponse, error) {
	out, err := s.policy.Save(ctx, req.GetData())
	if err != nil {
		return nil, mapBusinessErr(err)
	}
	return &limitsv1.PolicySaveResponse{Data: out}, nil
}

// PolicyGet returns a single policy.
func (s *AdminService) PolicyGet(
	ctx context.Context,
	req *limitsv1.PolicyGetRequest,
) (*limitsv1.PolicyGetResponse, error) {
	out, err := s.policy.Get(ctx, req.GetId())
	if err != nil {
		return nil, mapBusinessErr(err)
	}
	return &limitsv1.PolicyGetResponse{Data: out}, nil
}

// PolicySearch streams matching policies in batches.
func (s *AdminService) PolicySearch(
	ctx context.Context,
	req *limitsv1.PolicySearchRequest,
	stream limitsv1connect.LimitsAdminServicePolicySearchServerStream,
) error {
	return s.policy.Search(ctx, req, func(_ context.Context, items []*limitsv1.PolicyObject) error {
		return stream.Send(&limitsv1.PolicySearchResponse{Data: items})
	})
}

// PolicyDelete soft-deletes a policy.
func (s *AdminService) PolicyDelete(
	ctx context.Context,
	req *limitsv1.PolicyDeleteRequest,
) (*limitsv1.PolicyDeleteResponse, error) {
	if err := s.policy.Delete(ctx, req.GetId()); err != nil {
		return nil, mapBusinessErr(err)
	}
	return &limitsv1.PolicyDeleteResponse{}, nil
}

// ApprovalRequestList streams approval requests filtered by tenant/status/role.
func (s *AdminService) ApprovalRequestList(
	ctx context.Context,
	req *limitsv1.ApprovalRequestListRequest,
	stream limitsv1connect.LimitsAdminServiceApprovalRequestListServerStream,
) error {
	return s.approval.List(ctx, req, func(_ context.Context, items []*limitsv1.ApprovalRequestObject) error {
		return stream.Send(&limitsv1.ApprovalRequestListResponse{Data: items})
	})
}

// ApprovalRequestGet returns a single approval request with its decisions.
func (s *AdminService) ApprovalRequestGet(
	ctx context.Context,
	req *limitsv1.ApprovalRequestGetRequest,
) (*limitsv1.ApprovalRequestGetResponse, error) {
	out, err := s.approval.Get(ctx, req.GetId())
	if err != nil {
		return nil, mapBusinessErr(err)
	}
	return &limitsv1.ApprovalRequestGetResponse{Data: out}, nil
}

// ApprovalRequestDecide records an approver decision and transitions the workflow.
func (s *AdminService) ApprovalRequestDecide(
	ctx context.Context,
	req *limitsv1.ApprovalRequestDecideRequest,
) (*limitsv1.ApprovalRequestDecideResponse, error) {
	out, err := s.approval.Decide(ctx, req)
	if err != nil {
		return nil, mapBusinessErr(err)
	}
	return &limitsv1.ApprovalRequestDecideResponse{Data: out}, nil
}

// LedgerSearch streams committed ledger entries matching the filter.
func (s *AdminService) LedgerSearch(
	ctx context.Context,
	req *limitsv1.LedgerSearchRequest,
	stream limitsv1connect.LimitsAdminServiceLedgerSearchServerStream,
) error {
	return s.ledger.Search(ctx, req, func(_ context.Context, items []*limitsv1.LedgerEntryObject) error {
		return stream.Send(&limitsv1.LedgerSearchResponse{Data: items})
	})
}

// LimitsAuditSearch streams audit events matching the filter.
// Returns Unimplemented if the audit dep has not been wired yet.
func (s *AdminService) LimitsAuditSearch(
	ctx context.Context,
	req *limitsv1.LimitsAuditSearchRequest,
	stream limitsv1connect.LimitsAdminServiceLimitsAuditSearchServerStream,
) error {
	if s.audit == nil {
		return connect.NewError(connect.CodeUnimplemented, "audit search not wired")
	}
	return s.audit.Search(ctx, req, func(_ context.Context, items []*limitsv1.LimitsAuditEventObject) error {
		return stream.Send(&limitsv1.LimitsAuditSearchResponse{Data: items})
	})
}

// mapBusinessErr translates business-layer errors into Connect codes. Errors
// that already carry a Connect code are passed through untouched.
func mapBusinessErr(err error) error {
	var connectErr *connect.Error
	if errors.As(err, &connectErr) {
		if connectErr.IsRemote() {
			// A peer's verdict is not forwarded by connect v2; re-author it.
			return connect.NewError(connectErr.Code(), connectErr.Message()).WithCause(err)
		}
		return err
	}
	switch {
	case errors.Is(err, business.ErrPolicyNotFound):
		return connect.NewError(connect.CodeNotFound, err.Error()).WithCause(err)
	case errors.Is(err, business.ErrInvalidPolicy),
		errors.Is(err, business.ErrCurrencyMismatch),
		errors.Is(err, business.ErrApproverTiersInvalid):
		return connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	case errors.Is(err, business.ErrPolicyVersionConflict):
		return connect.NewError(connect.CodeAborted, err.Error()).WithCause(err)
	case errors.Is(err, business.ErrPolicyScopeForbidden):
		return connect.NewError(connect.CodePermissionDenied, err.Error()).WithCause(err)
	default:
		return connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
}
