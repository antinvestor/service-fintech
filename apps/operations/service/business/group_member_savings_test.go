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
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func periodRaise(groupID, periodID string, dueAt time.Time, members ...GroupMemberDue) GroupObligationsRaise {
	return GroupObligationsRaise{
		GroupID: groupID, PeriodID: periodID, Currency: "KES", DueAt: dueAt, Members: members,
	}
}

// A member's standing counts every payment against their savings, partial
// ones included; arrears are only what is overdue plus unpaid penalties, and
// another group's obligations never count.
func TestGroupMemberSavingsCountsPaymentsArrearsAndPenalties(t *testing.T) {
	t.Parallel()
	f := newGroupFixture()
	ctx := internalContext()
	past := time.Now().Add(-14 * 24 * time.Hour)
	future := time.Now().Add(7 * 24 * time.Hour)

	// Period 1, now overdue: m1 pays in full, m2 pays 400 of 1000, m3 pays
	// nothing. The close charges m2 and m3 the penalty.
	f.memberPayment("txn-m1-p1", "m1", 1000)
	f.memberPayment("txn-m2-p1", "m2", 400)
	_, err := f.business.RaiseGroupObligations(ctx,
		periodRaise("group-1", "period-1", past, member("m1", 1000), member("m2", 1000), member("m3", 1000)))
	require.NoError(t, err)
	_, err = f.business.CloseGroupPeriod(ctx,
		GroupPeriodClose{GroupID: "group-1", PeriodID: "period-1", Currency: "KES", Penalty: 200})
	require.NoError(t, err)

	// Period 2, not yet due: m1 has paid 500 of it so far.
	f.memberPayment("txn-m1-p2", "m1", 500)
	_, err = f.business.RaiseGroupObligations(ctx,
		periodRaise("group-1", "period-2", future, member("m1", 1000), member("m2", 1000), member("m3", 1000)))
	require.NoError(t, err)

	// m1 is behind in another group; that is not this group's arrears.
	_, err = f.business.RaiseGroupObligations(ctx, periodRaise("group-2", "period-9", past, member("m1", 1000)))
	require.NoError(t, err)

	standing, err := f.business.GroupMemberSavings(ctx, GroupMemberSavingsQuery{
		GroupID: "group-1", Currency: "kes", MembershipIDs: []string{"m1", "m2", "m3", "m4", "m1"},
	})
	require.NoError(t, err)
	require.Len(t, standing, 4, "one row per member, in the order asked")

	assert.Equal(t, MemberSavings{MembershipID: "m1", Saved: 1500, Arrears: 0}, standing[0],
		"a partial payment counts as saved; what is not yet due is not arrears")
	assert.Equal(t, MemberSavings{MembershipID: "m2", Saved: 400, Arrears: 600 + 200}, standing[1],
		"the overdue balance and the penalty are arrears")
	assert.Equal(t, MemberSavings{MembershipID: "m3", Saved: 0, Arrears: 1000 + 200}, standing[2])
	assert.Equal(t, MemberSavings{MembershipID: "m4"}, standing[3], "a member with no obligations has nothing")
}

func TestGroupMemberSavingsCountsOnlyTheGroupsCurrency(t *testing.T) {
	t.Parallel()
	f := newGroupFixture()
	ctx := internalContext()

	_, err := f.business.RaiseGroupObligations(ctx,
		periodRaise("group-1", "period-1", time.Now().Add(-time.Hour), member("m1", 1000)))
	require.NoError(t, err)

	standing, err := f.business.GroupMemberSavings(ctx, GroupMemberSavingsQuery{
		GroupID: "group-1", Currency: "UGX", MembershipIDs: []string{"m1"},
	})
	require.NoError(t, err)
	assert.Equal(t, MemberSavings{MembershipID: "m1"}, standing[0])
}

func TestGroupMemberSavingsRefusesAnIncompleteQuery(t *testing.T) {
	t.Parallel()
	f := newGroupFixture()
	ctx := internalContext()

	for name, query := range map[string]GroupMemberSavingsQuery{
		"no group":      {Currency: "KES", MembershipIDs: []string{"m1"}},
		"no currency":   {GroupID: "group-1", MembershipIDs: []string{"m1"}},
		"no members":    {GroupID: "group-1", Currency: "KES"},
		"blank member":  {GroupID: "group-1", Currency: "KES", MembershipIDs: []string{" "}},
		"too many asks": {GroupID: "group-1", Currency: "KES", MembershipIDs: make([]string, maxGroupMembers+1)},
	} {
		_, err := f.business.GroupMemberSavings(ctx, query)
		assert.Error(t, err, name)
	}
}
