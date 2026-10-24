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
	"slices"
	"strings"

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/security"
	"google.golang.org/protobuf/types/known/structpb"

	"github.com/antinvestor/service-fintech/apps/seed/service/business"
	"github.com/antinvestor/service-fintech/gen/go/seed/connectrpc/go/seed/v1/seedv1connect"
	seedv1 "github.com/antinvestor/service-fintech/gen/go/seed/protocolbuffers/go/seed/v1"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// ConnectServer serves the seed RPCs peer services call over Connect. Only
// the loans paid-off hook is served here; every other method is answered by
// the HTTP routes. Permissions are enforced in front of it by the function
// access middleware, which maps each Connect procedure to the same manifest
// permissions as its HTTP route (ROLE_SERVICE for the hook).
type ConnectServer struct {
	seedv1connect.UnimplementedSeedServiceHandler
	loanRequest business.LoanRequestBusiness
	staffRole   string
}

// NewConnectServer builds the Connect handler. staffRole is the role that,
// besides internal service principals, may call the paid-off hook, exactly
// as on the HTTP route.
func NewConnectServer(loanRequest business.LoanRequestBusiness, staffRole string) *ConnectServer {
	return &ConnectServer{loanRequest: loanRequest, staffRole: staffRole}
}

// LoanPaidOffNotify marks the seed loan request behind a paid-off loan as
// completed and credits the borrower's credit profile. It is idempotent.
func (s *ConnectServer) LoanPaidOffNotify(
	ctx context.Context,
	req *seedv1.LoanPaidOffRequest,
) (*seedv1.JSONResponse, error) {
	// This hook promotes credit tiers off claimed repayments. Only the loans
	// service (or an operator tool running as one) may call it, whatever
	// the transport.
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return nil, connect.NewError(connect.CodeUnauthenticated, "an authenticated caller is required")
	}
	if !claims.IsInternalSystem() && (s.staffRole == "" || !slices.Contains(claims.GetRoles(), s.staffRole)) {
		return nil, connect.NewError(connect.CodePermissionDenied,
			"the paid-off hook is restricted to internal callers")
	}
	loanAccountID := strings.TrimSpace(req.GetLoanAccountId())
	if loanAccountID == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "loan_account_id is required")
	}
	if req.GetTotalRepaid() < 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "total_repaid cannot be negative")
	}
	if err := s.loanRequest.HandlePaidOff(ctx, loanAccountID, req.GetTotalRepaid()); err != nil {
		return nil, apperrors.CleanErr(err)
	}
	data, _ := structpb.NewStruct(map[string]any{fieldStatus: "ok"})
	return &seedv1.JSONResponse{Data: data}, nil
}
