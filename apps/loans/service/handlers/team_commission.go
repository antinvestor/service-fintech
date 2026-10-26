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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"connectrpc.com/connect/v2"
	audit "github.com/antinvestor/common/audit"

	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

const auditResourceTeamCommission = "team_commission"

func (s *LoanManagementServer) TeamCommissionSearch(
	ctx context.Context,
	req *loansv1.TeamCommissionSearchRequest,
	stream loansv1connect.LoanManagementServiceTeamCommissionSearchServerStream,
) error {
	if s.commissions == nil {
		return connect.NewError(connect.CodeUnavailable, "team commission is not configured")
	}
	offset, limit := cursorPage(req.GetCursor())
	rows, err := s.commissions.Search(ctx, req.GetTeamId(), offset, limit)
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return stream.Send(&loansv1.TeamCommissionSearchResponse{Data: rows})
}

func (s *LoanManagementServer) TeamCommissionPayout(
	ctx context.Context,
	req *loansv1.TeamCommissionPayoutRequest,
) (*loansv1.TeamCommissionPayoutResponse, error) {
	if s.commissions == nil {
		return nil, connect.NewError(connect.CodeUnavailable, "team commission is not configured")
	}
	result, err := s.commissions.Payout(ctx, req)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}
	audit.WithResource(ctx, auditResourceTeamCommission, req.GetTeamId())
	audit.WithAction(ctx, "payout")
	audit.WithDetail(ctx, "member_id", req.GetMemberId())
	audit.WithDetail(ctx, "reason", req.GetReason())
	return &loansv1.TeamCommissionPayoutResponse{Data: result}, nil
}

func (s *LoanManagementServer) TeamCommissionPayoutSearch(
	ctx context.Context,
	req *loansv1.TeamCommissionPayoutSearchRequest,
	stream loansv1connect.LoanManagementServiceTeamCommissionPayoutSearchServerStream,
) error {
	if s.commissions == nil {
		return connect.NewError(connect.CodeUnavailable, "team commission is not configured")
	}
	offset, limit := cursorPage(req.GetCursor())
	rows, err := s.commissions.SearchPayouts(ctx, req.GetTeamId(), offset, limit)
	if err != nil {
		return apperrors.CleanErr(err)
	}
	return stream.Send(&loansv1.TeamCommissionPayoutSearchResponse{Data: rows})
}

// cursorPage reads a page cursor as an offset and a limit.
func cursorPage(cursor *commonv1.PageCursor) (int, int) {
	offset, err := strconv.Atoi(cursor.GetPage())
	if err != nil || offset < 0 {
		offset = 0
	}
	return offset, int(cursor.GetLimit())
}
