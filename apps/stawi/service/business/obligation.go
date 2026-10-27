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
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"github.com/pitabwire/util"
	"github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
	stawiproduct "github.com/antinvestor/service-fintech/products/stawi"
)

// Identity's group and membership values, as identity stores them.
const (
	membershipTypeMember int32 = 3
	// basisPoints is 100% in basis points.
	basisPoints int64 = 10_000
)

const (
	fieldPeriodID         = "period_id"
	fieldMemberID         = "member_id"
	fieldProfileID        = "profile_id"
	fieldDueDate          = "due_date"
	fieldMembers          = "members"
	fieldCount            = "count"
	fieldTotalOutstanding = "total_outstanding"
)

// GroupOperationsClient is the part of the operations service stawi uses.
// Operations owns obligations and the money that settles them; stawi sends
// the period and membership facts it owns.
type GroupOperationsClient interface {
	GroupObligationsRaise(
		ctx context.Context,
		req *operationsv1.GroupObligationsRaiseRequest,
	) (*operationsv1.GroupObligationsRaiseResponse, error)
	GroupPeriodClose(
		ctx context.Context,
		req *operationsv1.GroupPeriodCloseRequest,
	) (*operationsv1.GroupPeriodCloseResponse, error)
}

// GroupReader reads a group from identity.
type GroupReader interface {
	Get(ctx context.Context, id string) (*identityv1.ClientGroupObject, error)
}

// MemberLister lists a group's memberships from identity.
type MemberLister interface {
	GetByGroupID(ctx context.Context, groupID string) ([]*identityv1.MembershipObject, error)
}

// PeriodReader reads one of stawi's periods.
type PeriodReader interface {
	GetByID(ctx context.Context, id string) (*models.Period, error)
}

type groupObligationBusiness struct {
	product    stawiproduct.ProductConfig
	groups     GroupReader
	members    MemberLister
	periods    PeriodReader
	operations GroupOperationsClient
}

// NewGroupObligationBusiness builds the business that raises and closes a
// period's member obligations in operations.
func NewGroupObligationBusiness(
	_ context.Context,
	product stawiproduct.ProductConfig,
	groups GroupReader,
	members MemberLister,
	periods PeriodReader,
	operations GroupOperationsClient,
) GroupObligationBusiness {
	return &groupObligationBusiness{
		product:    product,
		groups:     groups,
		members:    members,
		periods:    periods,
		operations: operations,
	}
}

// Raise asks operations to raise the period's savings obligation for every
// member at the group's saving amount. Operations applies money the members
// already paid, so the reply says what each still owes; raising again is
// how a reminder reads that, since a retry raises nothing new.
func (b *groupObligationBusiness) Raise(ctx context.Context, groupID, periodID string) (map[string]any, error) {
	group, period, err := b.groupPeriod(ctx, groupID, periodID)
	if err != nil {
		return nil, err
	}
	if period.State != int32(constants.StateActive) {
		return nil, apperrors.NewError(apperrors.Unprocessable, "obligations are raised only in an open period")
	}
	if period.EndDate == nil {
		return nil, apperrors.NewError(apperrors.Unprocessable, "the period has no end date to fall due on")
	}
	if !liveState(group.GetState()) {
		return nil, apperrors.NewError(apperrors.Unprocessable, "the group no longer collects savings")
	}
	if group.GetSavingAmount() <= 0 {
		return nil, apperrors.NewError(apperrors.Unprocessable, "the group has no saving amount")
	}

	memberships, err := b.members.GetByGroupID(ctx, groupID)
	if err != nil {
		return nil, err
	}
	currency := group.GetCurrencyCode()
	amount := moneyx.FromMinorUnitsByCurrency(currency, group.GetSavingAmount())
	req := &operationsv1.GroupObligationsRaiseRequest{
		GroupId:      groupID,
		PeriodId:     periodID,
		CurrencyCode: currency,
		DueAt:        period.EndDate.UTC().Format(time.RFC3339),
	}
	for _, membership := range memberships {
		if !savingMember(membership) {
			continue
		}
		req.Members = append(req.Members, &operationsv1.GroupMemberObligation{
			MembershipId: membership.GetId(),
			ProfileId:    membership.GetProfileId(),
			Amount:       amount,
		})
	}
	if len(req.GetMembers()) == 0 {
		util.Log(ctx).WithField(fieldGroupID, groupID).Warn("no saving members; no obligations raised")
		return raiseSummary(groupID, periodID, "", nil, nil), nil
	}

	resp, err := b.operations.GroupObligationsRaise(ctx, req)
	if err != nil {
		return nil, err
	}
	return raiseSummary(groupID, periodID, req.GetDueAt(), resp.GetMembers(), resp.GetTotalOutstanding()), nil
}

// Close asks operations to settle the period: money members paid is applied
// and every member still owing is charged the group's late fine once. The
// reply is the period statement members are sent.
func (b *groupObligationBusiness) Close(ctx context.Context, groupID, periodID string) (map[string]any, error) {
	group, period, err := b.groupPeriod(ctx, groupID, periodID)
	if err != nil {
		return nil, err
	}
	// Late fines fall due only once members have had the whole period to
	// pay: a period still running is not closed.
	if !periodClosable(period, time.Now().UTC()) {
		return nil, ErrPeriodStillRunning
	}

	resp, err := b.operations.GroupPeriodClose(ctx, &operationsv1.GroupPeriodCloseRequest{
		GroupId:  groupID,
		PeriodId: periodID,
		Penalty:  moneyx.FromMinorUnitsByCurrency(group.GetCurrencyCode(), b.latePenalty(group)),
	})
	if err != nil {
		return nil, err
	}

	members := make([]map[string]any, 0, len(resp.GetMembers()))
	for _, member := range resp.GetMembers() {
		members = append(members, map[string]any{
			"id":              member.GetMembershipId(),
			fieldMemberID:     member.GetMembershipId(),
			fieldMembershipID: member.GetMembershipId(),
			fieldProfileID:    member.GetProfileId(),
			"savings_total":   minorUnits(member.GetPaid()),
			"penalties":       minorUnits(member.GetPenaltyRaised()),
			"outstanding":     minorUnits(member.GetOutstanding()),
		})
	}
	return map[string]any{
		fieldGroupID:          groupID,
		fieldPeriodID:         periodID,
		fieldMembers:          members,
		fieldCount:            len(members),
		"collected":           minorUnits(resp.GetCollected()),
		fieldTotalOutstanding: minorUnits(resp.GetOutstanding()),
	}, nil
}

// latePenalty is the group's late fine for a missed period: the first tier
// of the product's fine ladder applied to the period's contribution.
func (b *groupObligationBusiness) latePenalty(group *identityv1.ClientGroupObject) int64 {
	if b.product.LateFineRate1 <= 0 || group.GetSavingAmount() <= 0 {
		return 0
	}
	return group.GetSavingAmount() * b.product.LateFineRate1 / basisPoints
}

// groupPeriod loads the group and the period, refusing a period that is not
// the group's.
func (b *groupObligationBusiness) groupPeriod(
	ctx context.Context,
	groupID, periodID string,
) (*identityv1.ClientGroupObject, *models.Period, error) {
	if groupID == "" || periodID == "" {
		return nil, nil, apperrors.NewError(apperrors.BadRequest, "a group id and a period id are required")
	}
	period, err := b.periods.GetByID(ctx, periodID)
	if err != nil {
		return nil, nil, apperrors.ErrDataNotFound.Extend("period")
	}
	if period.GroupID != groupID {
		return nil, nil, apperrors.ErrDataNotFound.Extend("period")
	}
	group, err := b.groups.Get(ctx, groupID)
	if err != nil {
		return nil, nil, err
	}
	return group, period, nil
}

// ErrPeriodStillRunning is returned when a period that has neither ended
// nor been frozen is asked to close.
var ErrPeriodStillRunning = apperrors.NewError(apperrors.Unprocessable,
	"the period has not ended; it closes after its end date or once frozen")

// periodClosable reports whether a period may be closed and its late fines
// charged: it was frozen, it is no longer active, or its end date has passed.
func periodClosable(period *models.Period, now time.Time) bool {
	if period.Properties.GetString(propertyFrozenAt) != "" ||
		period.State != int32(constants.StateActive) {
		return true
	}
	return period.EndDate != nil && !period.EndDate.After(now)
}

// savingMember reports whether a membership owes the period's savings: a
// regular member whose membership is still live.
func savingMember(membership *identityv1.MembershipObject) bool {
	if membership.GetMembershipType() != membershipTypeMember {
		return false
	}
	return liveState(membership.GetState())
}

// liveState reports whether an identity group or membership still takes
// part. Identity stores the platform STATE enum and starts records at
// CREATED; nothing moves a membership to ACTIVE, so only deactivated and
// deleted records are out.
func liveState(state commonv1.STATE) bool {
	return state != commonv1.STATE_INACTIVE && state != commonv1.STATE_DELETED
}

// raiseSummary shapes the raise reply for the savings workflow: every
// member's dues, and the members still owing for its reminders.
func raiseSummary(
	groupID, periodID, dueAt string,
	results []*operationsv1.GroupMemberObligationResult,
	totalOutstanding *commonv1.Money,
) map[string]any {
	obligations := make([]map[string]any, 0, len(results))
	owing := make([]map[string]any, 0, len(results))
	created := 0
	for _, result := range results {
		if result.GetRaised() {
			created++
		}
		due := minorUnits(result.GetDue())
		outstanding := minorUnits(result.GetOutstanding())
		obligations = append(obligations, map[string]any{
			fieldMemberID:        result.GetMembershipId(),
			fieldMembershipID:    result.GetMembershipId(),
			fieldProfileID:       result.GetProfileId(),
			"savings_due":        due,
			"loan_repayment_due": int64(0),
			"total_due":          due,
			"paid":               minorUnits(result.GetPaid()),
			"outstanding":        outstanding,
			fieldDueDate:         dueAt,
		})
		if outstanding > 0 {
			owing = append(owing, map[string]any{
				"id":                 result.GetMembershipId(),
				fieldMemberID:        result.GetMembershipId(),
				fieldMembershipID:    result.GetMembershipId(),
				fieldProfileID:       result.GetProfileId(),
				"amount_outstanding": outstanding,
				fieldDueDate:         dueAt,
			})
		}
	}

	return map[string]any{
		fieldGroupID:          groupID,
		fieldPeriodID:         periodID,
		"obligations_created": created,
		"members_processed":   len(results),
		"member_obligations":  obligations,
		fieldMembers:          owing,
		fieldCount:            len(owing),
		fieldTotalOutstanding: minorUnits(totalOutstanding),
	}
}

// minorUnits reads an amount operations returned in its currency's minor
// units, the unit stawi's workflows template with. An absent amount is zero.
func minorUnits(amount *commonv1.Money) int64 {
	if amount == nil {
		return 0
	}
	return moneyx.ToSmallestUnit(amount, moneyx.Decimals(amount.GetCurrencyCode()))
}
