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
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
)

// mapClientResolver resolves profiles from fixed tables: the client a
// profile is, and the clients a field agent's profile serves.
type mapClientResolver struct {
	clients map[string]string
	served  map[string][]string
	err     error
}

func (r *mapClientResolver) ResolveAccess(_ context.Context, profileID string) (*CallerAccess, error) {
	if r.err != nil {
		return nil, r.err
	}
	access := &CallerAccess{ClientID: r.clients[profileID], ServedClientIDs: r.served[profileID]}
	if len(access.ServedClientIDs) > 0 {
		access.MemberID = "member-" + profileID
	}
	return access, nil
}

func claimsContext(t *testing.T, profileID string, roles ...string) context.Context {
	t.Helper()
	return (&security.AuthenticationClaims{
		TenantID:         "tenant-1",
		PartitionID:      "partition-1",
		Roles:            roles,
		RegisteredClaims: jwt.RegisteredClaims{Subject: profileID},
	}).ClaimsToContext(t.Context())
}

// ownedDisbursementRepo returns a fixed disbursement from GetByID.
type ownedDisbursementRepo struct {
	stubDisbursementRepo
	row *loansmodels.Disbursement
}

func (r *ownedDisbursementRepo) GetByID(_ context.Context, _ string) (*loansmodels.Disbursement, error) {
	return r.row, nil
}

// ownedRepaymentRepo returns a fixed repayment from GetByID.
type ownedRepaymentRepo struct {
	stubRepaymentRepo
	row *loansmodels.Repayment
}

func (r *ownedRepaymentRepo) GetByID(_ context.Context, _ string) (*loansmodels.Repayment, error) {
	return r.row, nil
}

// readScopeCase is one caller identity against a record owned by client-b.
type readScopeCase struct {
	name    string
	ctx     context.Context
	scope   *ReadScope
	wantErr error
}

func readScopeCases(t *testing.T) []readScopeCase {
	t.Helper()
	resolver := &mapClientResolver{clients: map[string]string{
		"profile-a": "client-a",
		"profile-b": "client-b",
	}}
	scoped := NewReadScope(resolver)
	return []readScopeCase{
		{name: "owning client reads its own record", ctx: claimsContext(t, "profile-b"), scope: scoped},
		{
			name:    "another client is refused",
			ctx:     claimsContext(t, "profile-a"),
			scope:   scoped,
			wantErr: ErrLoanNotOwned,
		},
		{
			name:    "a profile with no client is refused",
			ctx:     claimsContext(t, "profile-unknown"),
			scope:   scoped,
			wantErr: ErrLoanNotOwned,
		},
		{name: "operator staff reads partition-wide", ctx: claimsContext(t, "profile-a", "operator"), scope: scoped},
		{name: "admin staff reads partition-wide", ctx: claimsContext(t, "profile-a", "ADMIN"), scope: scoped},
		{
			name:  "internal system reads partition-wide",
			ctx:   claimsContext(t, "profile-a", security.ConstantSystemInternalRole),
			scope: scoped,
		},
		{
			name:  "custom staff role overrides the default list",
			ctx:   claimsContext(t, "profile-a", "loan_officer"),
			scope: NewReadScope(resolver, "loan_officer"),
		},
		{
			name:    "default role list does not admit an unknown role",
			ctx:     claimsContext(t, "profile-a", "loan_officer"),
			scope:   scoped,
			wantErr: ErrLoanNotOwned,
		},
		{
			name:    "client reads fail closed when no resolver is wired",
			ctx:     claimsContext(t, "profile-b"),
			scope:   NewReadScope(nil),
			wantErr: ErrReadScopeUnavailable,
		},
		{
			name:  "staff still read when no resolver is wired",
			ctx:   claimsContext(t, "profile-a", "viewer"),
			scope: NewReadScope(nil),
		},
		{name: "in-process callers without claims are trusted", ctx: t.Context(), scope: NewReadScope(nil)},
	}
}

func TestReadScope_LoanAccountReadsAreScopedToTheOwningClient(t *testing.T) {
	loan := &loansmodels.LoanAccount{ClientID: "client-b", CurrencyCode: "KES"}
	loan.ID = "loan-1"

	for _, tc := range readScopeCases(t) {
		t.Run(tc.name, func(t *testing.T) {
			b := NewLoanAccountBusiness(t.Context(), &noopEventsManager{}, nil,
				&stubLoanAccountRepo{account: loan}, nil, nil, nil, nil, nil, nil, nil, nil, nil,
				WithReadScope(tc.scope))

			got, err := b.Get(tc.ctx, "loan-1")
			if tc.wantErr != nil {
				require.ErrorIs(t, err, tc.wantErr)
				require.Nil(t, got)
				return
			}
			require.NoError(t, err)
			require.Equal(t, "loan-1", got.GetId())
		})
	}
}

func TestReadScope_GetBalanceAndStatementRefuseOtherClients(t *testing.T) {
	loan := &loansmodels.LoanAccount{ClientID: "client-b", CurrencyCode: "KES"}
	loan.ID = "loan-1"
	scope := NewReadScope(&mapClientResolver{clients: map[string]string{"profile-a": "client-a"}})
	b := NewLoanAccountBusiness(t.Context(), &noopEventsManager{}, nil,
		&stubLoanAccountRepo{account: loan}, nil, nil, nil, nil, nil, nil, nil, nil, nil,
		WithReadScope(scope))
	ctx := claimsContext(t, "profile-a")

	_, err := b.GetBalance(ctx, "loan-1")
	require.ErrorIs(t, err, ErrLoanNotOwned)

	_, err = b.GetStatement(ctx, &loansv1.LoanStatementRequest{LoanAccountId: "loan-1"})
	require.ErrorIs(t, err, ErrLoanNotOwned)
}

func TestReadScope_LoanRequestGetIsScopedToTheOwningClient(t *testing.T) {
	request := &loansmodels.LoanRequest{ClientID: "client-b"}
	request.ID = "request-1"

	for _, tc := range readScopeCases(t) {
		t.Run(tc.name, func(t *testing.T) {
			b := NewLoanRequestBusiness(t.Context(), &noopEventsManager{},
				&stubLoanRequestRepo{request: request}, &stubLoanProductRepo{}, nil, false, "",
				WithReadScope(tc.scope))

			got, err := b.Get(tc.ctx, "request-1")
			if tc.wantErr != nil {
				require.ErrorIs(t, err, tc.wantErr)
				require.Nil(t, got)
				return
			}
			require.NoError(t, err)
			require.Equal(t, "request-1", got.GetId())
		})
	}
}

func TestReadScope_DisbursementReadsAreScopedThroughTheLoan(t *testing.T) {
	loan := &loansmodels.LoanAccount{ClientID: "client-b", CurrencyCode: "KES"}
	loan.ID = "loan-1"
	disb := &loansmodels.Disbursement{LoanAccountID: "loan-1", Amount: 1000, CurrencyCode: "KES"}
	disb.ID = "disb-1"

	for _, tc := range readScopeCases(t) {
		t.Run(tc.name, func(t *testing.T) {
			b := NewDisbursementBusiness(t.Context(), &noopEventsManager{},
				&ownedDisbursementRepo{row: disb}, &stubLoanAccountRepo{account: loan},
				&stubLoanAccountBusiness{}, nil, nil, nil, false, "",
				WithReadScope(tc.scope))

			got, err := b.Get(tc.ctx, "disb-1")
			searchErr := b.Search(tc.ctx, &loansv1.DisbursementSearchRequest{LoanAccountId: "loan-1"},
				func(context.Context, []*loansv1.DisbursementObject) error { return nil })
			if tc.wantErr != nil {
				require.ErrorIs(t, err, tc.wantErr)
				require.Nil(t, got)
				require.ErrorIs(t, searchErr, tc.wantErr)
				return
			}
			require.NoError(t, err)
			require.Equal(t, "disb-1", got.GetId())
			// The stub repository cannot search; reaching it proves the gate
			// admitted the caller.
			require.NotErrorIs(t, searchErr, ErrLoanNotOwned)
			require.NotErrorIs(t, searchErr, ErrReadScopeUnavailable)
		})
	}
}

func TestReadScope_RepaymentReadsAreScopedThroughTheLoan(t *testing.T) {
	loan := &loansmodels.LoanAccount{ClientID: "client-b", CurrencyCode: "KES"}
	loan.ID = "loan-1"
	rep := &loansmodels.Repayment{LoanAccountID: "loan-1", Amount: 500, CurrencyCode: "KES"}
	rep.ID = "rep-1"

	for _, tc := range readScopeCases(t) {
		t.Run(tc.name, func(t *testing.T) {
			b := NewRepaymentBusiness(t.Context(), &noopEventsManager{},
				&stubLoanAccountRepo{account: loan}, &ownedRepaymentRepo{row: rep},
				nil, nil, nil, nil, nil, nil, nil, nil, false, "",
				WithReadScope(tc.scope))

			got, err := b.Get(tc.ctx, "rep-1")
			searchErr := b.Search(tc.ctx, &loansv1.RepaymentSearchRequest{LoanAccountId: "loan-1"},
				func(context.Context, []*loansv1.RepaymentObject) error { return nil })
			if tc.wantErr != nil {
				require.ErrorIs(t, err, tc.wantErr)
				require.Nil(t, got)
				require.ErrorIs(t, searchErr, tc.wantErr)
				return
			}
			require.NoError(t, err)
			require.Equal(t, "rep-1", got.GetId())
			require.NotErrorIs(t, searchErr, ErrLoanNotOwned)
			require.NotErrorIs(t, searchErr, ErrReadScopeUnavailable)
		})
	}
}

func TestReadScope_ResolverFailureIsNotMistakenForDenial(t *testing.T) {
	boom := errors.New("field service unavailable")
	scope := NewReadScope(&mapClientResolver{err: boom})

	err := scope.AuthorizeClient(claimsContext(t, "profile-a"), "client-a")
	require.ErrorIs(t, err, boom)
	require.NotErrorIs(t, err, ErrLoanNotOwned)
}

func agentScope() *ReadScope {
	return NewReadScope(&mapClientResolver{
		clients: map[string]string{"profile-borrower": "client-b"},
		served:  map[string][]string{"profile-agent": {"client-b", "client-c"}},
	})
}

func TestReadScope_FieldAgentActsOnlyForServedClients(t *testing.T) {
	scope := agentScope()
	agent := claimsContext(t, "profile-agent")
	borrower := claimsContext(t, "profile-borrower")
	stranger := claimsContext(t, "profile-stranger")

	require.NoError(t, scope.AuthorizeClient(agent, "client-b"))
	require.NoError(t, scope.AuthorizeClient(agent, "client-c"))
	require.ErrorIs(t, scope.AuthorizeClient(agent, "client-z"), ErrLoanNotOwned)
	require.NoError(t, scope.AuthorizeClient(borrower, "client-b"))
	require.ErrorIs(t, scope.AuthorizeClient(stranger, "client-b"), ErrLoanNotOwned)

	// Lender-side actions: the serving agent and staff only, never the
	// borrower, even on their own loan.
	require.NoError(t, scope.AuthorizeAgent(agent, "client-b"))
	require.ErrorIs(t, scope.AuthorizeAgent(agent, "client-z"), ErrNotServingClient)
	require.ErrorIs(t, scope.AuthorizeAgent(borrower, "client-b"), ErrNotServingClient)
	require.NoError(t, scope.AuthorizeAgent(claimsContext(t, "profile-x", "operator"), "client-z"))

	require.Equal(t, "member-profile-agent", scope.ServingMemberID(agent, "client-b"))
	require.Empty(t, scope.ServingMemberID(agent, "client-z"))
	require.Empty(t, scope.ServingMemberID(borrower, "client-b"))
	require.True(t, scope.IsBorrowerOf(borrower, "client-b"))
	require.False(t, scope.IsBorrowerOf(agent, "client-b"))
}

func TestReadScope_ClientFilterConfinesSearches(t *testing.T) {
	scope := agentScope()

	ids, unrestricted, err := scope.ClientFilter(claimsContext(t, "profile-agent"))
	require.NoError(t, err)
	require.False(t, unrestricted)
	require.ElementsMatch(t, []string{"client-b", "client-c"}, ids)

	ids, unrestricted, err = scope.ClientFilter(claimsContext(t, "profile-borrower"))
	require.NoError(t, err)
	require.False(t, unrestricted)
	require.Equal(t, []string{"client-b"}, ids)

	// Nothing in scope still yields a valid, never-matching IN list.
	ids, unrestricted, err = scope.ClientFilter(claimsContext(t, "profile-stranger"))
	require.NoError(t, err)
	require.False(t, unrestricted)
	require.Equal(t, []string{""}, ids)

	_, unrestricted, err = scope.ClientFilter(claimsContext(t, "profile-x", "admin"))
	require.NoError(t, err)
	require.True(t, unrestricted)
}

func TestRepaymentRecord_LenderSideGuards(t *testing.T) {
	loan := &loansmodels.LoanAccount{ClientID: "client-b", CurrencyCode: "KES",
		Status: int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE)}
	loan.ID = "loan-1"
	otherLoanRepayment := &loansmodels.Repayment{LoanAccountID: "loan-other"}
	otherLoanRepayment.ID = "rep-other"

	scope := NewReadScope(&mapClientResolver{
		clients: map[string]string{"profile-borrower": "client-b", "profile-agent-borrower": "client-b"},
		served: map[string][]string{
			"profile-agent":          {"client-b"},
			"profile-agent-borrower": {"client-b"},
		},
	})
	build := func(existing *loansmodels.Repayment) RepaymentBusiness {
		return NewRepaymentBusiness(t.Context(), &noopEventsManager{},
			&stubLoanAccountRepo{account: loan}, &stubRepaymentRepo{findResp: existing},
			nil, nil, nil, nil, nil, nil, nil, nil, false, "",
			WithReadScope(scope))
	}
	req := func(channel string) *loansv1.RepaymentRecordRequest {
		return &loansv1.RepaymentRecordRequest{LoanAccountId: "loan-1", Channel: channel, IdempotencyKey: "k-1"}
	}

	_, err := build(nil).Record(claimsContext(t, "profile-borrower"), req("cash"))
	require.ErrorIs(t, err, ErrNotServingClient, "a borrower cannot mark their own loan paid")

	_, err = build(nil).Record(claimsContext(t, "profile-agent-borrower"), req("cash"))
	require.ErrorIs(t, err, ErrNotServingClient, "an agent cannot record on a loan they owe")

	_, err = build(nil).Record(claimsContext(t, "profile-agent"), req("mpesa"))
	require.ErrorIs(t, err, ErrAgentCashOnly)

	_, err = build(otherLoanRepayment).Record(claimsContext(t, "profile-agent"), req("cash"))
	require.ErrorIs(t, err, ErrIdempotencyKeyConflict, "a key from another loan never returns its repayment")

	_, err = build(otherLoanRepayment).Record(claimsContext(t, "profile-x", "operator"), req("mpesa"))
	require.ErrorIs(t, err, ErrIdempotencyKeyConflict, "staff pass the channel rule and still hit the key check")
}

// Without a loan, a field agent's repayment search is their own collections:
// an empty collector means "mine", someone else's is refused.
func TestRepaymentSearchScope_AgentListsOwnCollections(t *testing.T) {
	b, ok := NewRepaymentBusiness(t.Context(), &noopEventsManager{},
		&stubLoanAccountRepo{}, &stubRepaymentRepo{},
		nil, nil, nil, nil, nil, nil, nil, nil, false, "",
		WithReadScope(agentScope())).(*repaymentBusiness)
	require.True(t, ok)
	agent := claimsContext(t, "profile-agent")

	filters, err := b.searchScope(agent, &loansv1.RepaymentSearchRequest{ReceivedAfter: "2026-10-24T00:00:00Z"})
	require.NoError(t, err)
	require.Equal(t, "profile-agent", filters["collected_by = ?"])
	require.Contains(t, filters, "created_at >= ?")

	_, err = b.searchScope(agent, &loansv1.RepaymentSearchRequest{CollectedBy: "profile-other"})
	require.ErrorIs(t, err, ErrLoanNotOwned)

	staffFilters, err := b.searchScope(claimsContext(t, "profile-x", "operator"), &loansv1.RepaymentSearchRequest{})
	require.NoError(t, err)
	require.NotContains(t, staffFilters, "collected_by = ?", "staff search the partition")
}
