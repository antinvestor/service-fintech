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

// mapClientResolver resolves profiles from a fixed table.
type mapClientResolver struct {
	clients map[string]string
	err     error
}

func (r *mapClientResolver) ResolveByProfileID(_ context.Context, profileID string) (string, error) {
	if r.err != nil {
		return "", r.err
	}
	if id, ok := r.clients[profileID]; ok {
		return id, nil
	}
	return "", ErrNoClientForProfile
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
