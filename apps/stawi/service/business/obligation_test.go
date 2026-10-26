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
	"testing"
	"time"

	"github.com/pitabwire/frame/v3/data"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"github.com/pitabwire/util/moneyx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
	stawiproduct "github.com/antinvestor/service-fintech/products/stawi"
)

type fakeGroups struct{ group *identityv1.ClientGroupObject }

func (f *fakeGroups) Get(context.Context, string) (*identityv1.ClientGroupObject, error) {
	return f.group, nil
}

type fakeMembers struct {
	members []*identityv1.MembershipObject
}

func (f *fakeMembers) GetByGroupID(context.Context, string) ([]*identityv1.MembershipObject, error) {
	return f.members, nil
}

type fakePeriods struct{ period *models.Period }

func (f *fakePeriods) GetByID(_ context.Context, id string) (*models.Period, error) {
	if f.period == nil || f.period.GetID() != id {
		return nil, errors.New("not found")
	}
	return f.period, nil
}

// fakeOperations records what stawi asks operations for.
type fakeOperations struct {
	raised *operationsv1.GroupObligationsRaiseRequest
	closed *operationsv1.GroupPeriodCloseRequest

	raiseResp *operationsv1.GroupObligationsRaiseResponse
	closeResp *operationsv1.GroupPeriodCloseResponse
}

func (f *fakeOperations) GroupObligationsRaise(
	_ context.Context,
	req *operationsv1.GroupObligationsRaiseRequest,
) (*operationsv1.GroupObligationsRaiseResponse, error) {
	f.raised = req
	return f.raiseResp, nil
}

func (f *fakeOperations) GroupPeriodClose(
	_ context.Context,
	req *operationsv1.GroupPeriodCloseRequest,
) (*operationsv1.GroupPeriodCloseResponse, error) {
	f.closed = req
	return f.closeResp, nil
}

func kes(minor int64) *commonv1.Money { return moneyx.FromMinorUnitsByCurrency("KES", minor) }

func membership(id string, membershipType, state int32) *identityv1.MembershipObject {
	return &identityv1.MembershipObject{
		Id: id, GroupId: "group-1", ProfileId: "profile-" + id,
		MembershipType: membershipType, State: commonv1.STATE(state),
	}
}

type obligationFixture struct {
	ops     *fakeOperations
	periods *fakePeriods
	biz     GroupObligationBusiness
	end     time.Time
}

func newObligationFixture() *obligationFixture {
	end := time.Date(2026, 11, 2, 0, 0, 0, 0, time.UTC)
	period := &models.Period{GroupID: "group-1", EndDate: &end, State: int32(constants.StateActive)}
	period.ID = "period-1"
	ops := &fakeOperations{}
	periods := &fakePeriods{period: period}
	biz := NewGroupObligationBusiness(
		context.Background(),
		stawiproduct.ProductConfig{LateFineRate1: 1000},
		&fakeGroups{group: &identityv1.ClientGroupObject{
			Id: "group-1", CurrencyCode: "KES", SavingAmount: 50_000, State: commonv1.STATE_ACTIVE,
		}},
		&fakeMembers{members: []*identityv1.MembershipObject{
			membership("m1", membershipTypeMember, int32(commonv1.STATE_ACTIVE)),
			// Identity starts memberships at CREATED and nothing activates them.
			membership("m2", membershipTypeMember, int32(commonv1.STATE_CREATED)),
			membership("agent", 2, int32(commonv1.STATE_ACTIVE)),
			membership("gone", membershipTypeMember, int32(commonv1.STATE_DELETED)),
		}},
		periods,
		ops,
	)
	return &obligationFixture{ops: ops, periods: periods, biz: biz, end: end}
}

// Stawi names each saving member by membership and profile and sends the
// group's saving amount due at the period's end; operations decides the rest.
func TestRaiseSendsSavingMembersAtTheGroupsSavingAmount(t *testing.T) {
	t.Parallel()
	f := newObligationFixture()
	f.ops.raiseResp = &operationsv1.GroupObligationsRaiseResponse{
		Members: []*operationsv1.GroupMemberObligationResult{
			{MembershipId: "m1", ProfileId: "profile-m1", Raised: true, Due: kes(50_000), Paid: kes(50_000),
				Outstanding: kes(0)},
			{MembershipId: "m2", ProfileId: "profile-m2", Raised: true, Due: kes(50_000), Paid: kes(0),
				Outstanding: kes(50_000)},
		},
		TotalOutstanding: kes(50_000),
	}

	result, err := f.biz.Raise(t.Context(), "group-1", "period-1")
	require.NoError(t, err)

	req := f.ops.raised
	require.NotNil(t, req)
	assert.Equal(t, "group-1", req.GetGroupId())
	assert.Equal(t, "period-1", req.GetPeriodId())
	assert.Equal(t, "KES", req.GetCurrencyCode())
	assert.Equal(t, f.end.Format(time.RFC3339), req.GetDueAt())
	require.Len(t, req.GetMembers(), 2, "agents and departed members owe no savings")
	for i, id := range []string{"m1", "m2"} {
		assert.Equal(t, id, req.GetMembers()[i].GetMembershipId())
		assert.Equal(t, "profile-"+id, req.GetMembers()[i].GetProfileId())
		assert.EqualValues(t, 50_000, moneyx.ToSmallestUnit(req.GetMembers()[i].GetAmount(), 2))
	}

	assert.Equal(t, 2, result["obligations_created"])
	assert.Len(t, result["member_obligations"], 2)
	owing, _ := result["members"].([]map[string]any)
	require.Len(t, owing, 1, "only members still owing are reminded")
	assert.Equal(t, "m2", owing[0]["member_id"])
	assert.EqualValues(t, 50_000, owing[0]["amount_outstanding"])
	assert.Equal(t, 1, result["count"])
	assert.EqualValues(t, 50_000, result["total_outstanding"])
}

func TestRaiseRefusesAnotherGroupsOrAClosedPeriod(t *testing.T) {
	t.Parallel()
	f := newObligationFixture()

	_, err := f.biz.Raise(t.Context(), "group-2", "period-1")
	require.Error(t, err, "a period of another group")

	f.periods.period.State = int32(constants.StateShutdown)
	_, err = f.biz.Raise(t.Context(), "group-1", "period-1")
	require.Error(t, err, "a closed period")
	assert.Nil(t, f.ops.raised)
}

// The close fines each member still owing the first tier of the fine ladder
// on the period's contribution, and returns operations' statement.
func TestCloseSendsTheGroupsLateFineAndReturnsTheStatement(t *testing.T) {
	t.Parallel()
	f := newObligationFixture()
	f.ops.closeResp = &operationsv1.GroupPeriodCloseResponse{
		Members: []*operationsv1.GroupMemberOutstanding{
			{MembershipId: "m1", ProfileId: "profile-m1", Paid: kes(50_000), Outstanding: kes(0),
				PenaltyRaised: kes(0)},
			{MembershipId: "m2", ProfileId: "profile-m2", Paid: kes(0), Outstanding: kes(50_000),
				PenaltyRaised: kes(5_000)},
		},
		Collected:   kes(50_000),
		Outstanding: kes(50_000),
	}

	ended := time.Now().UTC().Add(-time.Hour)
	f.periods.period.EndDate = &ended
	result, err := f.biz.Close(t.Context(), "group-1", "period-1")
	require.NoError(t, err)

	require.NotNil(t, f.ops.closed)
	assert.Equal(t, "period-1", f.ops.closed.GetPeriodId())
	assert.EqualValues(t, 5_000, moneyx.ToSmallestUnit(f.ops.closed.GetPenalty(), 2), "10% of the 50,000 contribution")
	assert.Equal(t, "KES", f.ops.closed.GetPenalty().GetCurrencyCode())

	members, _ := result["members"].([]map[string]any)
	require.Len(t, members, 2)
	assert.Equal(t, "m2", members[1]["id"])
	assert.EqualValues(t, 5_000, members[1]["penalties"])
	assert.EqualValues(t, 50_000, members[0]["savings_total"])
	assert.EqualValues(t, 50_000, result["total_outstanding"])
	assert.EqualValues(t, 50_000, result["collected"])
}

// Late fines fall due only after members had the whole period: a period
// still running cannot be closed, until it ends or is frozen.
func TestCloseRefusesAPeriodStillRunning(t *testing.T) {
	t.Parallel()
	f := newObligationFixture()
	running := time.Now().UTC().Add(48 * time.Hour)
	f.periods.period.EndDate = &running

	_, err := f.biz.Close(t.Context(), "group-1", "period-1")
	require.ErrorIs(t, err, ErrPeriodStillRunning)
	assert.Nil(t, f.ops.closed, "no fine is charged")

	f.periods.period.Properties = data.JSONMap{propertyFrozenAt: time.Now().UTC().Format(time.RFC3339)}
	_, err = f.biz.Close(t.Context(), "group-1", "period-1")
	require.NoError(t, err, "a frozen period closes")
}
