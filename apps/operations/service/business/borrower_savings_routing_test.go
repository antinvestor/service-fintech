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
	"sync"
	"testing"

	"buf.build/gen/go/antinvestor/savings/connectrpc/go/v2/savings/v1/savingsv1connect"
	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type saverAccounts struct {
	savingsv1connect.UnimplementedSavingsServiceHandler
	mu       sync.Mutex
	accounts []*savingsv1.SavingsAccountObject
	deposits []*savingsv1.DepositRecordRequest
}

func (s *saverAccounts) SavingsAccountGet(
	_ context.Context, req *savingsv1.SavingsAccountGetRequest,
) (*savingsv1.SavingsAccountGetResponse, error) {
	for _, a := range s.accounts {
		if a.GetId() == req.GetId() {
			return &savingsv1.SavingsAccountGetResponse{Data: a}, nil
		}
	}
	return nil, connect.NewError(connect.CodeNotFound, "no account")
}

func (s *saverAccounts) SavingsAccountSearch(
	_ context.Context, req *savingsv1.SavingsAccountSearchRequest,
	stream savingsv1connect.SavingsServiceSavingsAccountSearchServerStream,
) error {
	var out []*savingsv1.SavingsAccountObject
	for _, a := range s.accounts {
		if a.GetOwnerId() == req.GetOwnerId() {
			out = append(out, a)
		}
	}
	return stream.Send(&savingsv1.SavingsAccountSearchResponse{Data: out})
}

func (s *saverAccounts) DepositRecord(
	_ context.Context, req *savingsv1.DepositRecordRequest,
) (*savingsv1.DepositRecordResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.deposits = append(s.deposits, req)
	return &savingsv1.DepositRecordResponse{Data: &savingsv1.DepositObject{Id: "dep-1"}}, nil
}

func openSavings(id, product string) *savingsv1.SavingsAccountObject {
	return &savingsv1.SavingsAccountObject{Id: id, OwnerId: "client-1", ProductId: product,
		OwnerType: savingsv1.SavingsAccountOwnerType_SAVINGS_ACCOUNT_OWNER_TYPE_INDIVIDUAL,
		Status:    savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_ACTIVE}
}

func newSaverRouting(
	t *testing.T,
	accounts ...*savingsv1.SavingsAccountObject,
) (*paymentRoutingBusiness, *saverAccounts) {
	t.Helper()
	routing, _, _ := newBorrowerRouting(t, nil)
	savings := &saverAccounts{accounts: accounts}
	routing.clients.LenderSavings = savingsv1connect.NewSavingsServiceClient(serveConnect(t, func(s *connect.Server) {
		savingsv1connect.RegisterSavingsServiceHandler(s, savings)
	}))
	return routing, savings
}

func TestSaversPaymentIsDepositedToTheirOwnAccount(t *testing.T) {
	routing, savings := newSaverRouting(t, openSavings("sav-1", "save-prod"))

	result, err := routing.IdentifyPayment(context.Background(), map[string]interface{}{
		"transaction_id":  "txn-s1",
		"amount":          int64(20_000),
		"currency":        "UGX",
		"payer_reference": "+256701000111",
		"product_id":      "save-prod",
		"properties":      data.JSONMap{},
	})
	require.NoError(t, err)
	assert.Equal(t, strategyBorrowerSavings, result["strategy"])

	assert.Equal(t, int64(20_000), result["allocated_amount"], "deposited as soon as it is matched")
	assert.Equal(t, "dep-1", result["deposit_id"])

	paymentID, _ := result["payment_id"].(string)
	_, err = routing.AllocatePayment(context.Background(), paymentID)
	require.NoError(t, err)

	require.Len(t, savings.deposits, 1)
	dep := savings.deposits[0]
	assert.Equal(t, "sav-1", dep.GetSavingsAccountId())
	assert.Equal(t, int64(20_000), dep.GetAmount().GetUnits(), "the rail's amount, in full (UGX has no minor unit)")
	assert.Equal(t, "payment:"+paymentID+":savings:sav-1", dep.GetIdempotencyKey())
	assert.Equal(t, "profile-1", dep.GetPayerReference(), "the saver is named by profile, never by number")
	assert.Equal(t, channelMobileMoney, dep.GetChannel())
}

func TestSaversPaymentToAnotherProductIsNotDeposited(t *testing.T) {
	routing, savings := newSaverRouting(t, openSavings("sav-1", "save-prod"))

	result, err := routing.IdentifyPayment(context.Background(), map[string]interface{}{
		"transaction_id":  "txn-s2",
		"amount":          int64(20_000),
		"currency":        "UGX",
		"payer_reference": "+256701000111",
		"product_id":      "other-prod",
		"properties":      data.JSONMap{},
	})
	require.NoError(t, err)
	assert.Equal(t, "unidentified", result["strategy"])
	assert.Empty(t, savings.deposits)
}

func TestStaffAssignAnUnmatchedPaymentToASavingsAccount(t *testing.T) {
	routing, savings := newSaverRouting(t, openSavings("sav-1", "prod-1"))
	paymentID := unmatchedPayment(t, routing, "txn-s3", "prod-1")

	_, _, err := routing.AssignPayment(staffContext(), paymentID, "loan-1", "sav-1", "both")
	require.ErrorIs(t, err, ErrPaymentAssignInvalid, "exactly one target")

	payment, _, err := routing.AssignPayment(staffContext(), paymentID, "", "sav-1", "saver called in")
	require.NoError(t, err)
	assert.Equal(t, ownerTypeClientSavings, payment.OwnerType)
	assert.Equal(t, "sav-1", payment.PayableID)
	require.Len(t, savings.deposits, 1)
}
