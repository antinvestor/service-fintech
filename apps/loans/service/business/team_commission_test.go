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

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect/v2"
	moneyx "github.com/pitabwire/util/moneyx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/structpb"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// memCommissions is an in-memory TeamCommissionRepository with one team's
// balance.
type memCommissions struct {
	accrued, paidOut int64
	byRef            map[string]*loansmodels.TeamCommissionMovement
}

func newMemCommissions(accrued int64) *memCommissions {
	return &memCommissions{accrued: accrued, byRef: map[string]*loansmodels.TeamCommissionMovement{}}
}

func (m *memCommissions) Accrue(_ context.Context, mv *loansmodels.TeamCommissionMovement) (bool, error) {
	if _, ok := m.byRef[mv.Reference]; ok {
		return false, nil
	}
	m.byRef[mv.Reference] = mv
	m.accrued += mv.Amount
	return true, nil
}

func (m *memCommissions) ClaimPayout(
	_ context.Context,
	mv *loansmodels.TeamCommissionMovement,
) (*loansmodels.TeamCommissionMovement, bool, error) {
	if stored, ok := m.byRef[mv.Reference]; ok {
		return stored, false, nil
	}
	mv.ID = "payout-" + mv.Reference
	m.byRef[mv.Reference] = mv
	return mv, true, nil
}

func (m *memCommissions) PayoutByReference(
	_ context.Context,
	reference string,
) (*loansmodels.TeamCommissionMovement, error) {
	if stored, ok := m.byRef[reference]; ok {
		return stored, nil
	}
	return nil, errors.New("not found")
}

func (m *memCommissions) DebitPayout(_ context.Context, mv *loansmodels.TeamCommissionMovement) error {
	if m.accrued-m.paidOut < mv.Amount {
		return repository.ErrCommissionInsufficient
	}
	m.paidOut += mv.Amount
	m.byRef[mv.Reference].Status = int32(loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_PROCESSING)
	return nil
}

func (m *memCommissions) RevertPayout(_ context.Context, mv *loansmodels.TeamCommissionMovement, reason string) error {
	m.paidOut -= mv.Amount
	stored := m.byRef[mv.Reference]
	stored.Status = int32(loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_PENDING)
	stored.FailureReason = reason
	return nil
}

func (m *memCommissions) ReturnPaidPayout(_ context.Context, id, reason string) (bool, error) {
	for _, mv := range m.byRef {
		if mv.GetID() == id &&
			mv.Status == int32(loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_COMPLETED) {
			mv.Status = int32(loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_PENDING)
			mv.FailureReason = reason
			m.paidOut -= mv.Amount
			return true, nil
		}
	}
	return false, nil
}

func (m *memCommissions) CompletePayout(_ context.Context, id string) error {
	for _, mv := range m.byRef {
		if mv.GetID() == id {
			mv.Status = int32(loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_COMPLETED)
		}
	}
	return nil
}

func (m *memCommissions) Search(context.Context, string, int, int) ([]*loansmodels.TeamCommission, error) {
	return nil, nil
}

func (m *memCommissions) SearchPayouts(
	context.Context, string, int, int,
) ([]*loansmodels.TeamCommissionMovement, error) {
	return nil, nil
}

type fixedMember struct {
	dest MemberPayout
	err  error
}

func (f fixedMember) MemberPayout(context.Context, string, string) (MemberPayout, error) {
	return f.dest, f.err
}

// failingOperations refuses or loses every order it is handed.
type failingOperations struct {
	recordingOperationsClient
	err error
}

func (c *failingOperations) TransferOrderExecute(
	ctx context.Context,
	req *operationsv1.TransferOrderExecuteRequest,
) (*operationsv1.TransferOrderExecuteResponse, error) {
	_, _ = c.recordingOperationsClient.TransferOrderExecute(ctx, req)
	return nil, c.err
}

func payoutRequest(key string, amount int64) *loansv1.TeamCommissionPayoutRequest {
	return &loansv1.TeamCommissionPayoutRequest{
		TeamId:         "team-7",
		MemberId:       "member-1",
		Amount:         moneyx.FromMinorUnitsByCurrency("KES", amount),
		IdempotencyKey: key,
		Reason:         "October commission",
	}
}

func memberDest() fixedMember {
	return fixedMember{dest: MemberPayout{ProfileID: "profile-1", ContactID: "contact-1"}}
}

// A payout goes to the member's own contact as a payout order from the
// team's payable, and replaying the key returns it without paying again.
func TestCommissionPayoutPaysTheMembersOwnContactOnce(t *testing.T) {
	repo := newMemCommissions(10_000)
	ops := &recordingOperationsClient{}
	tc := NewTeamCommissions(repo, memberDest(), ops, audit.NewWriter(nil))

	got, err := tc.Payout(context.Background(), payoutRequest("key-00001", 6_000))
	require.NoError(t, err)
	assert.Equal(t, loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_COMPLETED, got.GetStatus())

	orders := ops.snapshot()
	require.Len(t, orders, 1)
	o := orders[0]
	assert.Equal(t, constants.TeamCommissionPayableAccount("team-7"), o.GetDebitAccountRef())
	assert.Equal(t, constants.PlatformExternalCashAccount(), o.GetCreditAccountRef())
	extra := o.GetExtraData().AsMap()
	assert.Equal(t, "profile-1", extra["recipient_profile_id"])
	assert.Equal(t, "contact-1", extra["payment_account_ref"])

	_, err = tc.Payout(context.Background(), payoutRequest("key-00001", 6_000))
	require.NoError(t, err)
	assert.Len(t, ops.snapshot(), 1, "a replayed key does not pay again")
	assert.Equal(t, int64(6_000), repo.paidOut)

	_, err = tc.Payout(context.Background(), payoutRequest("key-00001", 5_000))
	require.ErrorIs(t, err, ErrCommissionPayoutKeyReused)

	_, err = tc.Payout(context.Background(), payoutRequest("key-00002", 5_000))
	require.ErrorIs(t, err, ErrCommissionInsufficient, "only 4 000 is left")
}

// Nothing is taken when the member cannot be paid.
func TestCommissionPayoutNeedsAPayableMember(t *testing.T) {
	repo := newMemCommissions(10_000)
	ops := &recordingOperationsClient{}
	tc := NewTeamCommissions(repo, fixedMember{err: ErrCommissionMemberNotOnTeam}, ops, audit.NewWriter(nil))

	_, err := tc.Payout(context.Background(), payoutRequest("key-00003", 1_000))
	require.ErrorIs(t, err, ErrCommissionMemberNotOnTeam)
	assert.Empty(t, ops.snapshot())
	assert.Zero(t, repo.paidOut)
}

// A refused payout goes back to the balance; one whose outcome is unknown
// stays taken until a retry of the same key settles it.
func TestCommissionPayoutRefusedGoesBackUnknownStaysTaken(t *testing.T) {
	repo := newMemCommissions(10_000)
	refused := &failingOperations{err: connect.NewError(connect.CodeFailedPrecondition, "no route")}
	tc := NewTeamCommissions(repo, memberDest(), refused, audit.NewWriter(nil))
	_, err := tc.Payout(context.Background(), payoutRequest("key-00004", 2_000))
	require.Error(t, err)
	assert.Zero(t, repo.paidOut, "a refused payout went back to the balance")

	lost := &failingOperations{err: connect.NewError(connect.CodeUnavailable, "timeout")}
	tc = NewTeamCommissions(repo, memberDest(), lost, audit.NewWriter(nil))
	_, err = tc.Payout(context.Background(), payoutRequest("key-00005", 2_000))
	require.Error(t, err)
	assert.Equal(t, int64(2_000), repo.paidOut, "an unknown outcome keeps the payout taken")

	ops := &recordingOperationsClient{}
	tc = NewTeamCommissions(repo, memberDest(), ops, audit.NewWriter(nil))
	got, err := tc.Payout(context.Background(), payoutRequest("key-00005", 2_000))
	require.NoError(t, err)
	assert.Equal(t, loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_COMPLETED, got.GetStatus())
	assert.Equal(t, int64(2_000), repo.paidOut, "the retry resumes without taking again")
}

// Each repayment's commission lands on the team's balance once.
func TestCommissionAccruesToTheTeamsBalance(t *testing.T) {
	repo := newMemCommissions(0)
	balances := NewTeamCommissions(repo, nil, nil, audit.NewWriter(nil))
	c := NewAgentCommission(commissionProducts{rate: 1_000}, fixedTeam("team-7"),
		&recordingOperationsClient{}, balances)
	r := &loansmodels.Repayment{CurrencyCode: "KES", InterestApplied: 50_000}
	r.ID = "rep-1"

	require.NoError(t, c.Post(context.Background(), commissionLoan(), r))
	require.NoError(t, c.Post(context.Background(), commissionLoan(), r))
	assert.Equal(t, int64(5_000), repo.accrued, "a retried settlement accrues once")
}

// A payout already taken from the balance resumes even if the member has
// left the team since: the money may have gone, and the order operations
// stored still names the recipient it checked.
func TestCommissionPayoutResumesAfterTheMemberLeaves(t *testing.T) {
	repo := newMemCommissions(10_000)
	lost := &failingOperations{err: connect.NewError(connect.CodeUnavailable, "timeout")}
	_, err := NewTeamCommissions(repo, memberDest(), lost, audit.NewWriter(nil)).
		Payout(context.Background(), payoutRequest("key-00006", 3_000))
	require.Error(t, err)

	gone := fixedMember{err: ErrCommissionMemberNotOnTeam}
	got, err := NewTeamCommissions(repo, gone, &recordingOperationsClient{}, audit.NewWriter(nil)).
		Payout(context.Background(), payoutRequest("key-00006", 3_000))
	require.NoError(t, err)
	assert.Equal(t, loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_COMPLETED, got.GetStatus())
	assert.Equal(t, int64(3_000), repo.paidOut)
}

// storedOrderOperations answers like operations does for a reference it
// already holds: with the stored order, whatever the request said.
type storedOrderOperations struct {
	recordingOperationsClient
	team string
}

func (c *storedOrderOperations) TransferOrderExecute(
	_ context.Context,
	_ *operationsv1.TransferOrderExecuteRequest,
) (*operationsv1.TransferOrderExecuteResponse, error) {
	extra, _ := structpb.NewStruct(map[string]any{"team_id": c.team})
	return &operationsv1.TransferOrderExecuteResponse{
		Data: &operationsv1.TransferOrderObject{Id: "txn-commission", ExtraData: extra},
	}, nil
}

// A retried settlement credits the team the ledger posting credited, even
// when the client has moved to another team in between.
func TestCommissionAccruesToTheTeamTheLedgerCredited(t *testing.T) {
	repo := newMemCommissions(0)
	c := NewAgentCommission(commissionProducts{rate: 1_000}, fixedTeam("team-new"),
		&storedOrderOperations{team: "team-old"}, NewTeamCommissions(repo, nil, nil, audit.NewWriter(nil)))
	r := &loansmodels.Repayment{CurrencyCode: "KES", InterestApplied: 50_000}
	r.ID = "rep-moved"

	require.NoError(t, c.Post(context.Background(), commissionLoan(), r))
	require.Len(t, repo.byRef, 1)
	for _, mv := range repo.byRef {
		assert.Equal(t, "team-old", mv.TeamID)
	}
}
