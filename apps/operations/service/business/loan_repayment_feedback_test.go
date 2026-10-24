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
	"sync"
	"testing"

	"buf.build/gen/go/antinvestor/loans/connectrpc/go/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

type fakeLender struct {
	loansv1connect.LoanManagementServiceClient
	mu    sync.Mutex
	calls []*loansv1.RepaymentRecordRequest
	fail  error
}

func (f *fakeLender) RepaymentRecord(
	_ context.Context,
	req *connect.Request[loansv1.RepaymentRecordRequest],
) (*connect.Response[loansv1.RepaymentRecordResponse], error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.calls = append(f.calls, req.Msg)
	if f.fail != nil {
		return nil, f.fail
	}
	return connect.NewResponse(&loansv1.RepaymentRecordResponse{}), nil
}

func TestObligationLoanAccountID_ComesFromThePropertyNotTheCause(t *testing.T) {
	entryCaused := &models.Obligation{CauseType: "loan_principal", CauseID: "entry-7"}
	assert.Empty(t, obligationLoanAccountID(entryCaused), "cause id is the schedule entry, never a loan")

	withLoan := &models.Obligation{
		CauseType:  "loan_interest",
		CauseID:    "entry-7",
		Properties: data.JSONMap{fieldLoanAccountID: " loan-42 "},
	}
	assert.Equal(t, "loan-42", obligationLoanAccountID(withLoan))

	saving := &models.Obligation{CauseType: obligationSaving, Properties: data.JSONMap{fieldLoanAccountID: "loan-42"}}
	assert.Empty(t, obligationLoanAccountID(saving), "only loan obligations feed the lender")
	assert.Empty(t, obligationLoanAccountID(nil))
}

func TestExecute_AllocationRepaymentRetriesLenderWithoutRepostingLedger(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	f.repo.order.OrderType = constants.SafeInt32FromInt(constants.TransferTypeLoanRepayment)
	f.repo.order.Reference = "payment:p1:obligation:o1"
	f.repo.order.ExtraData = data.JSONMap{
		extraKeySource: allocationSourceMarker,
		"loan_id":      "loan-42",
	}
	lender := &fakeLender{fail: errors.New("loans unavailable")}
	f.biz.clients.LenderLoanMgmt = lender

	err := f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.Error(t, err, "an unrecorded repayment must not complete the order")

	got := f.repo.snapshot()
	assert.Equal(t, int32(constants.StateJustCreated), got.State, "the claim is released for a retry")
	assert.Contains(t, got.FailureReason, "loans unavailable")
	assert.NotEmpty(t, got.LedgerTransactionID, "the posted ledger leg is kept")
	assert.Equal(t, 1, f.ledger.calls)
	require.Len(t, lender.calls, 1)

	lender.fail = nil
	require.NoError(t, f.biz.Execute(context.Background(), f.repo.order.GetID()))

	got = f.repo.snapshot()
	assert.Equal(t, int32(constants.StateInactive), got.State)
	assert.Equal(t, 1, f.ledger.calls, "the retry records with the lender only; the ledger is not posted twice")
	require.Len(t, lender.calls, 2)
	assert.Equal(t, "loan-42", lender.calls[1].GetLoanAccountId())
	assert.Equal(t, got.Reference, lender.calls[1].GetIdempotencyKey(), "the order reference dedupes a replay")
	assert.Equal(t, 0, f.payment.sends, "a repayment never pays anything out")
}

func TestExecute_AllocationRepaymentWithoutLenderClientDoesNotComplete(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	f.repo.order.OrderType = constants.SafeInt32FromInt(constants.TransferTypeLoanRepayment)
	f.repo.order.ExtraData = data.JSONMap{extraKeySource: allocationSourceMarker, "loan_id": "loan-42"}

	err := f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.Error(t, err)
	assert.Equal(t, int32(constants.StateJustCreated), f.repo.snapshot().State)
}
