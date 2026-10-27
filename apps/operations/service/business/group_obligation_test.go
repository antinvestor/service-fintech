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
	"slices"
	"strings"
	"testing"
	"time"

	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// memObligationRepo keeps obligations in memory with the uniqueness the
// database enforces: one savings and one penalty per member per period.
// Reads hand out copies, as rows read from the database would be.
type memObligationRepo struct {
	obligationRepoStub
	rows []*models.Obligation
}

func (r *memObligationRepo) copies(keep func(*models.Obligation) bool) []*models.Obligation {
	var out []*models.Obligation
	for _, obl := range r.rows {
		if keep(obl) {
			clone := *obl
			clone.Properties = obl.Properties.Copy()
			out = append(out, &clone)
		}
	}
	return out
}

func (r *memObligationRepo) GetByMembershipID(_ context.Context, membershipID string) ([]*models.Obligation, error) {
	return r.copies(func(o *models.Obligation) bool {
		return o.MembershipID == membershipID && o.State == int32(constants.StateActive)
	}), nil
}

func (r *memObligationRepo) GetByPeriodID(_ context.Context, periodID string) ([]*models.Obligation, error) {
	return r.copies(func(o *models.Obligation) bool { return o.PeriodID == periodID }), nil
}

func (r *memObligationRepo) GetGroupMemberObligations(
	_ context.Context,
	groupID string,
	membershipIDs, causeTypes []string,
) ([]*models.Obligation, error) {
	return r.copies(func(o *models.Obligation) bool {
		return o.CauseID == groupID && slices.Contains(membershipIDs, o.MembershipID) &&
			slices.Contains(causeTypes, o.CauseType)
	}), nil
}

func (r *memObligationRepo) CreateIfAbsent(_ context.Context, obligation *models.Obligation) (bool, error) {
	for _, existing := range r.rows {
		if existing.MembershipID == obligation.MembershipID && existing.PeriodID == obligation.PeriodID &&
			existing.CauseType == obligation.CauseType {
			return false, nil
		}
	}
	clone := *obligation
	clone.Properties = obligation.Properties.Copy()
	r.rows = append(r.rows, &clone)
	return true, nil
}

func (r *memObligationRepo) ConsumeAmount(_ context.Context, id string, amount int64) (bool, error) {
	for _, obl := range r.rows {
		if obl.GetID() == id && obl.State == int32(constants.StateActive) && obl.Amount >= amount {
			obl.Amount -= amount
			if obl.Amount == 0 {
				obl.State = int32(constants.StateInactive)
			}
			return true, nil
		}
	}
	return false, nil
}

func (r *memObligationRepo) causes(membershipID, cause string) []*models.Obligation {
	return r.copies(func(o *models.Obligation) bool {
		return o.MembershipID == membershipID && o.CauseType == cause
	})
}

// groupOrderRepo consumes obligations from the in-memory store.
type groupOrderRepo struct {
	allocOrderRepoStub
	store *memObligationRepo
}

func (r *groupOrderRepo) ConsumeObligationForOrder(
	ctx context.Context,
	orderID, obligationID string,
	amount int64,
) (bool, error) {
	consumed, err := r.store.ConsumeAmount(ctx, obligationID, amount)
	if err != nil || !consumed {
		return consumed, err
	}
	for _, o := range r.byReference {
		if o.GetID() == orderID {
			o.ObligationConsumed = true
		}
	}
	return true, nil
}

type groupFixture struct {
	payments    *incomingPaymentRepoStub
	obligations *memObligationRepo
	orders      *groupOrderRepo
	routing     *paymentRoutingBusiness
	business    *obligationBusiness
}

func newGroupFixture() *groupFixture {
	payments := newIncomingPaymentRepoStub()
	obligations := &memObligationRepo{}
	orders := &groupOrderRepo{store: obligations}
	routing := &paymentRoutingBusiness{
		eventsMan: &paymentEventsManagerStub{paymentRepo: payments},
		ipRepo:    payments,
		obRepo:    obligations,
		toRepo:    orders,
	}
	return &groupFixture{
		payments:    payments,
		obligations: obligations,
		orders:      orders,
		routing:     routing,
		business:    &obligationBusiness{obRepo: obligations, settler: routing},
	}
}

// memberPayment stores a group member's matched payment the rail announced.
func (f *groupFixture) memberPayment(txn, membershipID string, amount int64) *models.IncomingPayment {
	payment := &models.IncomingPayment{
		TransactionID: txn, Amount: amount, Currency: "KES",
		OwnerID: membershipID, OwnerType: ownerTypeMembership,
		PayableID: "group-1", PayableType: "group",
		State:      int32(constants.StateJustCreated),
		Properties: data.JSONMap{fieldProductID: "stawi", fieldGroupID: "group-1"},
	}
	payment.GenID(context.Background())
	f.payments.store(payment)
	return payment
}

func groupRaise(members ...GroupMemberDue) GroupObligationsRaise {
	return GroupObligationsRaise{
		GroupID: "group-1", PeriodID: "period-1", Currency: "KES",
		DueAt:   time.Now().Add(7 * 24 * time.Hour),
		Members: members,
	}
}

func member(id string, amount int64) GroupMemberDue {
	return GroupMemberDue{MembershipID: id, ProfileID: "profile-" + id, Amount: amount}
}

func TestRaiseGroupObligationsIsIdempotent(t *testing.T) {
	t.Parallel()
	f := newGroupFixture()
	ctx := internalContext()

	first, err := f.business.RaiseGroupObligations(ctx, groupRaise(member("m1", 1000), member("m2", 1000)))
	require.NoError(t, err)
	require.Len(t, first.Members, 2)
	for _, row := range first.Members {
		assert.True(t, row.Raised)
		assert.EqualValues(t, 1000, row.Due)
		assert.EqualValues(t, 1000, row.Outstanding)
	}
	assert.Equal(t, "profile-m1", first.Members[0].ProfileID)

	second, err := f.business.RaiseGroupObligations(ctx, groupRaise(member("m1", 1000), member("m2", 1000)))
	require.NoError(t, err)
	for _, row := range second.Members {
		assert.False(t, row.Raised, "a retry raises nothing new")
		assert.EqualValues(t, 1000, row.Due)
	}
	assert.Len(t, f.obligations.rows, 2)
	assert.EqualValues(t, 2000, second.Outstanding)
}

func TestRaiseGroupObligationsRefusesAnotherGroupsPeriod(t *testing.T) {
	t.Parallel()
	f := newGroupFixture()
	ctx := internalContext()

	_, err := f.business.RaiseGroupObligations(ctx, groupRaise(member("m1", 1000)))
	require.NoError(t, err)

	other := groupRaise(member("m9", 1000))
	other.GroupID = "group-2"
	_, err = f.business.RaiseGroupObligations(ctx, other)
	require.Error(t, err)
	assert.Len(t, f.obligations.rows, 1)
}

// Money a member paid before the period's obligation existed waits in their
// suspense; raising the obligation pays it from there.
func TestEarlyPaymentInSuspensePaysANewlyRaisedObligation(t *testing.T) {
	t.Parallel()
	f := newGroupFixture()
	ctx := internalContext()

	early := f.memberPayment("txn-early", "m1", 1500)
	allocation, err := f.routing.AllocatePayment(ctx, early.GetID())
	require.NoError(t, err)
	require.EqualValues(t, 1500, allocation[fieldRemainingAmount], "nothing owed yet: all of it is suspense")
	require.NotNil(t, f.orders.byReference["payment:"+early.GetID()+":member:m1"],
		"the payment is moved into the member's suspense")

	// A second payment the settle job has not reached yet.
	waiting := f.memberPayment("txn-waiting", "m2", 400)

	standing, err := f.business.RaiseGroupObligations(ctx, groupRaise(member("m1", 1000), member("m2", 1000)))
	require.NoError(t, err)

	m1, m2 := standing.Members[0], standing.Members[1]
	assert.EqualValues(t, 1000, m1.Paid)
	assert.EqualValues(t, 0, m1.Outstanding)
	assert.EqualValues(t, 400, m2.Paid, "a waiting payment is allocated when the obligation is raised")
	assert.EqualValues(t, 600, m2.Outstanding)

	stored, _ := f.payments.GetByID(ctx, early.GetID())
	assert.EqualValues(t, 500, paymentRemainder(stored), "the rest stays in the member's suspense")
	stored, _ = f.payments.GetByID(ctx, waiting.GetID())
	assert.Equal(t, int32(constants.StateInactive), stored.State)

	saving := f.obligations.causes("m1", obligationPeriodicSaving)[0]
	order := f.orders.byReference["payment:"+early.GetID()+":obligation:"+saving.GetID()]
	require.NotNil(t, order)
	assert.Equal(t, constants.MemberSuspenseAccount("m1"), order.DebitAccountRef)
	assert.Equal(t, constants.MemberPeriodicSavingsAccount("m1"), order.CreditAccountRef)
	assert.Equal(t, true, order.ExtraData[extraKeySuspenseFunded])
}

// A member who paid is not penalised at close; one who did not is charged
// once, however many times the close is retried.
func TestCloseGroupPeriodPenalisesOnlyMembersStillOwingOnce(t *testing.T) {
	t.Parallel()
	f := newGroupFixture()
	ctx := internalContext()

	_, err := f.business.RaiseGroupObligations(ctx, groupRaise(member("m1", 1000), member("m2", 1000)))
	require.NoError(t, err)
	// m1 pays after the raise; the settle job has not run yet.
	f.memberPayment("txn-m1", "m1", 1000)

	closeReq := GroupPeriodClose{GroupID: "group-1", PeriodID: "period-1", Currency: "KES", Penalty: 200}
	first, err := f.business.CloseGroupPeriod(ctx, closeReq)
	require.NoError(t, err)
	require.Len(t, first.Members, 2)

	m1, m2 := first.Members[0], first.Members[1]
	assert.EqualValues(t, 0, m1.Outstanding)
	assert.EqualValues(t, 0, m1.Penalty, "a member who paid is not penalised")
	assert.EqualValues(t, 1000, m2.Outstanding)
	assert.EqualValues(t, 200, m2.Penalty)
	assert.Equal(t, "profile-m2", m2.ProfileID)
	assert.EqualValues(t, 1000, first.Collected)
	assert.EqualValues(t, 1000, first.Outstanding)

	second, err := f.business.CloseGroupPeriod(ctx, closeReq)
	require.NoError(t, err)
	assert.EqualValues(t, 200, second.Members[1].Penalty, "a retry reports the penalty charged first")
	assert.Len(t, f.obligations.causes("m2", obligationPenalty), 1, "exactly one penalty")
	assert.Empty(t, f.obligations.causes("m1", obligationPenalty))
}

func TestCloseGroupPeriodWithoutPenaltyChargesNothing(t *testing.T) {
	t.Parallel()
	f := newGroupFixture()
	ctx := internalContext()

	_, err := f.business.RaiseGroupObligations(ctx, groupRaise(member("m1", 1000)))
	require.NoError(t, err)

	standing, err := f.business.CloseGroupPeriod(ctx, GroupPeriodClose{GroupID: "group-1", PeriodID: "period-1"})
	require.NoError(t, err)
	assert.EqualValues(t, 1000, standing.Members[0].Outstanding)
	assert.Empty(t, f.obligations.causes("m1", obligationPenalty))
}

// The settle job allocates a group member's matched payment against their
// obligations and posts the orders it raised, suspense first.
func TestSettleJobAllocatesAMembershipPayment(t *testing.T) {
	t.Parallel()
	f := newGroupFixture()
	ctx := internalContext()

	_, err := f.business.RaiseGroupObligations(ctx, groupRaise(member("m1", 1000)))
	require.NoError(t, err)
	payment := f.memberPayment("txn-settle", "m1", 1000)

	exec := &recordingExecutor{}
	jobs := NewOperationsJobs(f.routing, exec, f.payments, f.orders, "service_operations")
	_, _, err = jobs.Run(ctx, operationsv1.OperationsJob_OPERATIONS_JOB_SETTLE_PAYMENTS, 50)
	require.NoError(t, err)

	stored, _ := f.payments.GetByID(ctx, payment.GetID())
	assert.Equal(t, int32(constants.StateInactive), stored.State, "the payment is fully allocated")
	saving := f.obligations.causes("m1", obligationPeriodicSaving)[0]
	assert.Equal(t, int32(constants.StateInactive), saving.State, "the obligation is paid")

	var references []string
	for _, id := range exec.executed {
		for ref, o := range f.orders.byReference {
			if o.GetID() == id {
				references = append(references, ref)
			}
		}
	}
	funding := "payment:" + payment.GetID() + ":member:m1"
	obligation := "payment:" + payment.GetID() + ":obligation:" + saving.GetID()
	assert.ElementsMatch(t, []string{funding, obligation}, compact(references))
	// The member's suspense is funded before the obligation order spends it;
	// posting the funding order again is harmless, it is idempotent.
	assert.Less(t, slices.Index(references, funding), slices.Index(references, obligation))
}

// compact drops repeats, keeping first occurrences.
func compact(refs []string) []string {
	var out []string
	for _, r := range refs {
		if !slices.Contains(out, r) {
			out = append(out, r)
		}
	}
	return out
}

// refusingExecutor fails every order whose reference contains refuse.
type refusingExecutor struct {
	orders   *groupOrderRepo
	refuse   string
	executed []string
}

func (e *refusingExecutor) Execute(_ context.Context, orderID string) error {
	for ref, o := range e.orders.byReference {
		if o.GetID() == orderID && strings.Contains(ref, e.refuse) {
			return errors.New("ledger unavailable")
		}
	}
	e.executed = append(e.executed, orderID)
	return nil
}

// An obligation order never posts while the order funding the member's
// suspense cannot: it would spend money the member's suspense does not hold.
func TestSettleJobHoldsAnObligationOrderUntilItsSuspenseIsFunded(t *testing.T) {
	t.Parallel()
	f := newGroupFixture()
	ctx := internalContext()

	_, err := f.business.RaiseGroupObligations(ctx, groupRaise(member("m1", 1000)))
	require.NoError(t, err)
	f.memberPayment("txn-held", "m1", 1000)

	exec := &refusingExecutor{orders: f.orders, refuse: ":member:"}
	jobs := NewOperationsJobs(f.routing, exec, f.payments, f.orders, "service_operations")
	_, _, err = jobs.Run(ctx, operationsv1.OperationsJob_OPERATIONS_JOB_SETTLE_PAYMENTS, 50)
	require.NoError(t, err)

	for _, id := range exec.executed {
		for ref, o := range f.orders.byReference {
			if o.GetID() == id {
				assert.NotContains(t, ref, ":obligation:", "no obligation order posts before its funding")
			}
		}
	}
}
