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

	"buf.build/gen/go/antinvestor/ledger/connectrpc/go/v2/v1/ledgerv1connect"
	ledgerv1 "buf.build/gen/go/antinvestor/ledger/protocolbuffers/go/v1"
	"connectrpc.com/connect/v2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/pkg/constants"
)

// strictLedger refuses postings to accounts it does not hold and accounts
// in ledgers it does not hold, like the real ledger service.
type strictLedger struct {
	ledgerv1connect.LedgerServiceClient
	mu       sync.Mutex
	ledgers  map[string]ledgerv1.LedgerType
	accounts map[string]string
	posts    int
}

func (l *strictLedger) CreateTransaction(
	_ context.Context,
	req *ledgerv1.CreateTransactionRequest,
) (*ledgerv1.CreateTransactionResponse, error) {
	l.mu.Lock()
	defer l.mu.Unlock()
	for _, e := range req.GetEntries() {
		if _, ok := l.accounts[e.GetAccountId()]; !ok {
			return nil, connect.NewError(connect.CodeNotFound, "account was not found")
		}
	}
	l.posts++
	txn := (&ledgerv1.Transaction_builder{Id: "ledger-" + req.GetId()}).Build()
	return (&ledgerv1.CreateTransactionResponse_builder{Data: txn}).Build(), nil
}

func (l *strictLedger) CreateAccount(
	_ context.Context,
	req *ledgerv1.CreateAccountRequest,
) (*ledgerv1.CreateAccountResponse, error) {
	l.mu.Lock()
	defer l.mu.Unlock()
	if _, ok := l.ledgers[req.GetLedgerId()]; !ok {
		return nil, connect.NewError(connect.CodeNotFound, "ledger was not found")
	}
	if _, ok := l.accounts[req.GetId()]; ok {
		return nil, connect.NewError(connect.CodeAlreadyExists, "account exists")
	}
	l.accounts[req.GetId()] = req.GetLedgerId()
	return &ledgerv1.CreateAccountResponse{}, nil
}

func (l *strictLedger) CreateLedger(
	_ context.Context,
	req *ledgerv1.CreateLedgerRequest,
) (*ledgerv1.CreateLedgerResponse, error) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.ledgers[req.GetId()] = req.GetType()
	return &ledgerv1.CreateLedgerResponse{}, nil
}

// The first posting to platform accounts creates them, and their chart
// ledgers, in the right category, then posts.
func TestFirstPostingCreatesChartAccounts(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	ledger := &strictLedger{ledgers: map[string]ledgerv1.LedgerType{}, accounts: map[string]string{}}
	f.biz.clients.LedgerClient = ledger
	f.repo.order.OrderType = constants.SafeInt32FromInt(constants.TransferTypeLoanRepayment)
	f.repo.order.DebitAccountRef = constants.ProductExternalCashAccount("p1")
	f.repo.order.CreditAccountRef = constants.MemberLoansAccount("c1")

	require.NoError(t, f.biz.Execute(context.Background(), f.repo.order.GetID()))
	assert.Equal(t, 1, ledger.posts)
	assert.Equal(t, constants.LedgerCash, ledger.accounts[constants.ProductExternalCashAccount("p1")])
	assert.Equal(t, constants.LedgerMemberFunds, ledger.accounts[constants.MemberLoansAccount("c1")])
	assert.Equal(t, ledgerv1.LedgerType_ASSET, ledger.ledgers[constants.LedgerCash])
	assert.Equal(t, ledgerv1.LedgerType_LIABILITY, ledger.ledgers[constants.LedgerMemberFunds])
}

// A name that is not exactly one the platform builds is never created; the
// posting fails instead.
func TestOffChartAccountsAreNotCreated(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	ledger := &strictLedger{ledgers: map[string]ledgerv1.LedgerType{}, accounts: map[string]string{}}
	f.biz.clients.LedgerClient = ledger
	f.repo.order.OrderType = constants.SafeInt32FromInt(constants.TransferTypeLoanRepayment)
	f.repo.order.DebitAccountRef = constants.ProductExternalCashAccount("p1")
	f.repo.order.CreditAccountRef = "member:a:b:loans"

	require.Error(t, f.biz.Execute(context.Background(), f.repo.order.GetID()))
	assert.Equal(t, 0, ledger.posts)
	_, created := ledger.accounts["member:a:b:loans"]
	assert.False(t, created)
}
