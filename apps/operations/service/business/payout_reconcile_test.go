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
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	utilmoney "github.com/pitabwire/util/moneyx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// recordingLoans notes the late payout failures loans is told about.
type recordingLoans struct {
	loansv1connect.LoanManagementServiceClient
	told []string
}

func (r *recordingLoans) PayoutFailedApply(
	_ context.Context,
	req *loansv1.PayoutFailedApplyRequest,
) (*loansv1.PayoutFailedApplyResponse, error) {
	r.told = append(r.told, req.GetReference())
	return &loansv1.PayoutFailedApplyResponse{Applied: true}, nil
}

// paidOut runs the fixture's payout to completion: the rail accepted it.
func paidOut(t *testing.T) *executeFixture {
	t.Helper()
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	require.NoError(t, f.biz.Execute(context.Background(), f.repo.order.GetID()))
	got := f.repo.snapshot()
	require.Equal(t, int32(constants.StateInactive), got.State)
	require.Equal(t, models.PayoutStatusPending, got.PayoutStatus, "accepted is not paid")
	return f
}

// A payout the rail fails after accepting it is reversed on the ledger and
// its originator is told, once.
func TestReconcile_LateFailureIsReversedAndTheOriginatorTold(t *testing.T) {
	f := paidOut(t)
	loans := &recordingLoans{}
	f.biz.clients.LenderLoanMgmt = loans
	f.locator.found = matchingPayout(f.repo.order, "pay-1", commonv1.STATUS_FAILED)

	require.NoError(t, f.biz.ReconcilePayout(context.Background(), f.repo.order.GetID()))
	got := f.repo.snapshot()
	assert.Equal(t, models.PayoutStatusFailed, got.PayoutStatus)
	rev := f.repo.otherByReference("payout-reversal:" + got.Reference)
	require.NotNil(t, rev, "the ledger leg is reversed")
	assert.Equal(t, got.CreditAccountRef, rev.DebitAccountRef)
	assert.Equal(t, got.Amount, rev.Amount)
	assert.Equal(t, int32(constants.StateInactive), rev.State)

	require.NoError(t, f.biz.NotifyOriginator(context.Background(), &got))
	assert.Equal(t, []string{"disbursement:key-1"}, loans.told)
	assert.NotNil(t, f.repo.snapshot().OriginatorNotifiedAt)

	// A retry of the failed payout is refused, never told it succeeded.
	require.ErrorIs(t, f.biz.Execute(context.Background(), f.repo.order.GetID()), ErrPayoutFailed)

	// A further pass leaves a failed payout alone.
	require.NoError(t, f.biz.ReconcilePayout(context.Background(), f.repo.order.GetID()))
	assert.Equal(t, 1, f.locator.calls)
}

// The rail's word decides: paid is confirmed, undecided stays pending.
func TestReconcile_ConfirmsPaidAndKeepsUndecidedPending(t *testing.T) {
	f := paidOut(t)
	f.locator.found = matchingPayout(f.repo.order, "pay-1", commonv1.STATUS_IN_PROCESS)
	require.NoError(t, f.biz.ReconcilePayout(context.Background(), f.repo.order.GetID()))
	assert.Equal(t, models.PayoutStatusPending, f.repo.snapshot().PayoutStatus)

	f.locator.found = matchingPayout(f.repo.order, "pay-1", commonv1.STATUS_SUCCESSFUL)
	require.NoError(t, f.biz.ReconcilePayout(context.Background(), f.repo.order.GetID()))
	assert.Equal(t, models.PayoutStatusConfirmed, f.repo.snapshot().PayoutStatus)
	assert.Nil(t, f.repo.otherByReference("payout-reversal:"+f.repo.order.Reference), "nothing reversed")
}

// A payment found by reference that is not this order's payout is never
// acted on: without a recorded payment id, only an outbound payment of the
// order's amount counts.
func TestReconcile_UnmatchedPaymentIsNotActedOn(t *testing.T) {
	f := paidOut(t)
	f.repo.order.PaymentID = ""
	other := matchingPayout(f.repo.order, "pay-other", commonv1.STATUS_FAILED)
	other.SetAmount(utilmoney.FromMinorUnitsByCurrency(f.repo.order.Currency, f.repo.order.Amount+1))
	f.locator.found = other

	require.NoError(t, f.biz.ReconcilePayout(context.Background(), f.repo.order.GetID()))
	got := f.repo.snapshot()
	assert.NotEqual(t, models.PayoutStatusFailed, got.PayoutStatus, "a foreign payment's failure is not ours")
	assert.Nil(t, f.repo.otherByReference("payout-reversal:"+got.Reference), "nothing reversed")
}
