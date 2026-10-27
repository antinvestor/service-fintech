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
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	audit "github.com/antinvestor/common/audit"
	"github.com/pitabwire/frame/v3/security"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/operations/service/business"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// requireInternalCaller refuses anyone but an internal service: what a
// member owes comes only from the group service, never from a person.
func requireInternalCaller(ctx context.Context) error {
	if claims := security.ClaimsFromContext(ctx); claims == nil || !claims.IsInternalSystem() {
		return business.ErrGroupObligationsInternalOnly
	}
	return nil
}

// GroupObligationsRaise raises a group period's savings obligations.
func (s *OperationsServer) GroupObligationsRaise(
	ctx context.Context,
	req *operationsv1.GroupObligationsRaiseRequest,
) (*operationsv1.GroupObligationsRaiseResponse, error) {
	if err := requireInternalCaller(ctx); err != nil {
		return nil, apperrors.CleanErr(err)
	}
	if s.obBusiness == nil {
		return nil, apperrors.CleanErr(apperrors.NewError(apperrors.ServiceUnavailable,
			"group obligations are not available"))
	}

	currency := strings.ToUpper(strings.TrimSpace(req.GetCurrencyCode()))
	dueAt, err := time.Parse(time.RFC3339, strings.TrimSpace(req.GetDueAt()))
	if err != nil {
		return nil, apperrors.CleanErr(apperrors.NewError(apperrors.BadRequest, "due_at must be an RFC3339 time"))
	}
	members := make([]business.GroupMemberDue, 0, len(req.GetMembers()))
	for _, member := range req.GetMembers() {
		amount, amountErr := minorUnitsIn(member.GetAmount(), currency)
		if amountErr != nil {
			return nil, apperrors.CleanErr(amountErr)
		}
		members = append(members, business.GroupMemberDue{
			MembershipID: member.GetMembershipId(),
			ProfileID:    member.GetProfileId(),
			Amount:       amount,
		})
	}

	audit.WithResource(ctx, audit.ResourceClientGroup, req.GetGroupId())
	audit.WithAction(ctx, "raise_obligations")
	audit.WithDetail(ctx, "period_id", req.GetPeriodId())

	standing, err := s.obBusiness.RaiseGroupObligations(ctx, business.GroupObligationsRaise{
		GroupID:  req.GetGroupId(),
		PeriodID: req.GetPeriodId(),
		Currency: currency,
		DueAt:    dueAt,
		Members:  members,
	})
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	out := make([]*operationsv1.GroupMemberObligationResult, 0, len(standing.Members))
	for _, member := range standing.Members {
		out = append(out, &operationsv1.GroupMemberObligationResult{
			MembershipId: member.MembershipID,
			ProfileId:    member.ProfileID,
			Raised:       member.Raised,
			Due:          moneyx.FromMinorUnitsByCurrency(standing.Currency, member.Due),
			Paid:         moneyx.FromMinorUnitsByCurrency(standing.Currency, member.Paid),
			Outstanding:  moneyx.FromMinorUnitsByCurrency(standing.Currency, member.Outstanding),
		})
	}
	return &operationsv1.GroupObligationsRaiseResponse{
		Members:          out,
		TotalOutstanding: moneyx.FromMinorUnitsByCurrency(standing.Currency, standing.Outstanding),
	}, nil
}

// GroupPeriodClose charges the period's penalty to members still owing and
// returns the period's statement.
func (s *OperationsServer) GroupPeriodClose(
	ctx context.Context,
	req *operationsv1.GroupPeriodCloseRequest,
) (*operationsv1.GroupPeriodCloseResponse, error) {
	if err := requireInternalCaller(ctx); err != nil {
		return nil, apperrors.CleanErr(err)
	}
	if s.obBusiness == nil {
		return nil, apperrors.CleanErr(apperrors.NewError(apperrors.ServiceUnavailable,
			"group obligations are not available"))
	}

	currency := strings.ToUpper(strings.TrimSpace(req.GetPenalty().GetCurrencyCode()))
	penalty, err := minorUnitsIn(req.GetPenalty(), currency)
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	audit.WithResource(ctx, audit.ResourceClientGroup, req.GetGroupId())
	audit.WithAction(ctx, "close_period")
	audit.WithDetail(ctx, "period_id", req.GetPeriodId())

	standing, err := s.obBusiness.CloseGroupPeriod(ctx, business.GroupPeriodClose{
		GroupID:  req.GetGroupId(),
		PeriodID: req.GetPeriodId(),
		Currency: currency,
		Penalty:  penalty,
	})
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	out := make([]*operationsv1.GroupMemberOutstanding, 0, len(standing.Members))
	for _, member := range standing.Members {
		out = append(out, &operationsv1.GroupMemberOutstanding{
			MembershipId:  member.MembershipID,
			ProfileId:     member.ProfileID,
			Outstanding:   moneyx.FromMinorUnitsByCurrency(standing.Currency, member.Outstanding),
			PenaltyRaised: moneyx.FromMinorUnitsByCurrency(standing.Currency, member.Penalty),
			Paid:          moneyx.FromMinorUnitsByCurrency(standing.Currency, member.Paid),
		})
	}
	return &operationsv1.GroupPeriodCloseResponse{
		Members:     out,
		Collected:   moneyx.FromMinorUnitsByCurrency(standing.Currency, standing.Collected),
		Outstanding: moneyx.FromMinorUnitsByCurrency(standing.Currency, standing.Outstanding),
	}, nil
}

// GroupMemberStanding reports what each member has saved in a group and
// what they are behind on. Read only, and for internal services alone: it
// sizes what the group service lends.
func (s *OperationsServer) GroupMemberStanding(
	ctx context.Context,
	req *operationsv1.GroupMemberStandingRequest,
) (*operationsv1.GroupMemberStandingResponse, error) {
	if err := requireInternalCaller(ctx); err != nil {
		return nil, apperrors.CleanErr(err)
	}
	if s.obBusiness == nil {
		return nil, apperrors.CleanErr(apperrors.NewError(apperrors.ServiceUnavailable,
			"group obligations are not available"))
	}

	currency := strings.ToUpper(strings.TrimSpace(req.GetCurrencyCode()))
	members, err := s.obBusiness.GroupMemberSavings(ctx, business.GroupMemberSavingsQuery{
		GroupID:       req.GetGroupId(),
		Currency:      currency,
		MembershipIDs: req.GetMembershipIds(),
	})
	if err != nil {
		return nil, apperrors.CleanErr(err)
	}

	out := make([]*operationsv1.MemberStanding, 0, len(members))
	for _, member := range members {
		out = append(out, &operationsv1.MemberStanding{
			MembershipId: member.MembershipID,
			Saved:        moneyx.FromMinorUnitsByCurrency(currency, member.Saved),
			Arrears:      moneyx.FromMinorUnitsByCurrency(currency, member.Arrears),
		})
	}
	return &operationsv1.GroupMemberStandingResponse{Members: out}, nil
}

// minorUnitsIn converts an amount to minor units, refusing one in a currency
// other than the request's. An absent amount is zero.
func minorUnitsIn(amount *commonv1.Money, currency string) (int64, error) {
	if amount == nil {
		return 0, nil
	}
	if code := strings.TrimSpace(amount.GetCurrencyCode()); code != "" && !strings.EqualFold(code, currency) {
		return 0, apperrors.NewError(apperrors.BadRequest, "every amount must be in the request's currency")
	}
	return moneyx.ToSmallestUnit(amount, moneyx.Decimals(currency)), nil
}
