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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/funding/connectrpc/go/v2/funding/v1/fundingv1connect"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type investorFunds struct {
	fundingv1connect.UnimplementedFundingServiceHandler
	mu       sync.Mutex
	deposits []*fundingv1.InvestorDepositRequest
}

func (f *investorFunds) InvestorAccountGet(
	_ context.Context, req *fundingv1.InvestorAccountGetRequest,
) (*fundingv1.InvestorAccountGetResponse, error) {
	if req.GetId() != "inv-acct-1" {
		return nil, connect.NewError(connect.CodeNotFound, "no account")
	}
	return &fundingv1.InvestorAccountGetResponse{Data: &fundingv1.InvestorAccountObject{
		Id: "inv-acct-1", InvestorId: "investor-1",
		AvailableBalance: &commonv1.Money{CurrencyCode: "UGX"},
	}}, nil
}

func (f *investorFunds) InvestorDeposit(
	_ context.Context, req *fundingv1.InvestorDepositRequest,
) (*fundingv1.InvestorDepositResponse, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.deposits = append(f.deposits, req)
	return &fundingv1.InvestorDepositResponse{}, nil
}

type investorRegistry struct {
	identityv1connect.UnimplementedIdentityServiceHandler
}

func (investorRegistry) InvestorGet(
	_ context.Context, req *identityv1.InvestorGetRequest,
) (*identityv1.InvestorGetResponse, error) {
	if req.GetId() != "investor-1" {
		return nil, connect.NewError(connect.CodeNotFound, "no investor")
	}
	return &identityv1.InvestorGetResponse{Data: &identityv1.InvestorObject{Id: "investor-1",
		ProfileId: "profile-investor"}}, nil
}

func newInvestorRouting(t *testing.T) (*paymentRoutingBusiness, *investorFunds) {
	t.Helper()
	routing, _, _ := newBorrowerRouting(t, nil)
	funds := &investorFunds{}
	routing.clients.LenderFunding = fundingv1connect.NewFundingServiceClient(serveConnect(t, func(s *connect.Server) {
		fundingv1connect.RegisterFundingServiceHandler(s, funds)
	}))
	routing.clients.LenderRegistry = identityv1connect.NewIdentityServiceClient(
		serveConnect(t, func(s *connect.Server) {
			identityv1connect.RegisterIdentityServiceHandler(s, investorRegistry{})
		}))
	return routing, funds
}

func investorPayment(txn, payer string) map[string]interface{} {
	return map[string]interface{}{
		"transaction_id":  txn,
		"amount":          int64(500_000),
		"currency":        "UGX",
		"payer_reference": payer,
		"properties":      data.JSONMap{"reference": "inv-acct-1"},
	}
}

func TestInvestorsOwnPaymentBecomesCapitalOnce(t *testing.T) {
	routing, funds := newInvestorRouting(t)

	result, err := routing.IdentifyPayment(internalContext(), investorPayment("txn-inv-1", "profile-investor"))
	require.NoError(t, err)
	assert.Equal(t, strategyInvestorDeposit, result["strategy"])
	assert.Equal(t, int64(500_000), result[fieldAllocatedAmount], "deposited as soon as it is matched")

	require.Len(t, funds.deposits, 1)
	dep := funds.deposits[0]
	paymentID, _ := result["payment_id"].(string)
	assert.Equal(t, "inv-acct-1", dep.GetAccountId())
	assert.Equal(t, int64(500_000), dep.GetAmount().GetUnits(), "the rail's amount, in full")
	assert.Equal(t, "payment:"+paymentID+":investor:inv-acct-1", dep.GetIdempotencyKey())

	_, err = routing.AllocatePayment(internalContext(), paymentID)
	require.NoError(t, err)
	assert.Len(t, funds.deposits, 1, "a later allocate deposits nothing more")
}

func TestQuotingAnInvestorAccountFromAnotherProfileCreditsNothing(t *testing.T) {
	routing, funds := newInvestorRouting(t)

	result, err := routing.IdentifyPayment(internalContext(), investorPayment("txn-inv-2", "profile-stranger"))
	require.NoError(t, err)
	assert.Equal(t, "unidentified", result["strategy"], "capital is never credited on a reference alone")
	assert.Empty(t, funds.deposits)
}
