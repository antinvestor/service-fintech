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

package handlers_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/pitabwire/frame/v3/security"

	"github.com/antinvestor/service-fintech/apps/seed/service/business"
	"github.com/antinvestor/service-fintech/apps/seed/service/handlers"
	"github.com/antinvestor/service-fintech/apps/seed/service/models"
)

const (
	staffRole    = "seed_staff"
	ownClientID  = "client-own"
	otherClient  = "client-other"
	callerProfil = "profile-caller"
)

type fakeLoanRequest struct {
	input       business.RequestLoanInput
	paidOffCall int
}

func (f *fakeLoanRequest) RequestLoan(
	_ context.Context,
	req business.RequestLoanInput,
) (*models.LoanRequest, error) {
	f.input = req
	return &models.LoanRequest{ClientID: req.ClientID}, nil
}

func (f *fakeLoanRequest) HandlePaidOff(_ context.Context, _ string, _ int64) error {
	f.paidOffCall++
	return nil
}

func (f *fakeLoanRequest) Get(_ context.Context, _ string) (*models.LoanRequest, error) {
	return &models.LoanRequest{}, nil
}

type fakeCreditProfile struct {
	lastClientID string
	lastStatus   models.CreditProfileStatus
	lastReason   string
	setStatusErr error
}

func (f *fakeCreditProfile) SetStatus(
	_ context.Context,
	clientID, currencyCode string,
	status models.CreditProfileStatus,
	reason string,
) (*models.CreditProfile, error) {
	f.lastClientID = clientID
	f.lastStatus = status
	f.lastReason = reason
	if f.setStatusErr != nil {
		return nil, f.setStatusErr
	}
	return &models.CreditProfile{ClientID: clientID, CurrencyCode: currencyCode, Status: int32(status)}, nil
}

func (f *fakeCreditProfile) EnsureProfile(
	_ context.Context,
	clientID, currencyCode, _ string,
) (*models.CreditProfile, error) {
	f.lastClientID = clientID
	return &models.CreditProfile{ClientID: clientID, CurrencyCode: currencyCode}, nil
}

func (f *fakeCreditProfile) GetProfile(
	_ context.Context,
	clientID, currencyCode string,
) (*models.CreditProfile, error) {
	f.lastClientID = clientID
	return &models.CreditProfile{ClientID: clientID, CurrencyCode: currencyCode}, nil
}

func (f *fakeCreditProfile) EvaluateTier(
	_ context.Context,
	_ *models.CreditProfile,
) (*models.CreditTierConfig, error) {
	return &models.CreditTierConfig{}, nil
}

func (f *fakeCreditProfile) RecordSuccessfulRepayment(
	_ context.Context,
	clientID, currencyCode string,
	_ int64,
	_ string,
) (*models.CreditProfile, error) {
	f.lastClientID = clientID
	return &models.CreditProfile{ClientID: clientID, CurrencyCode: currencyCode}, nil
}

type fakeResolver struct {
	clientID string
	err      error
	calls    int
}

func (f *fakeResolver) ResolveByProfileID(_ context.Context, _ string) (string, error) {
	f.calls++
	return f.clientID, f.err
}

func customerClaims() *security.AuthenticationClaims {
	return &security.AuthenticationClaims{ProfileID: callerProfil}
}

func staffClaims() *security.AuthenticationClaims {
	return &security.AuthenticationClaims{ProfileID: callerProfil, Roles: []string{staffRole}}
}

func internalClaims() *security.AuthenticationClaims {
	return &security.AuthenticationClaims{
		ProfileID: callerProfil,
		Roles:     []string{security.ConstantSystemInternalRole},
	}
}

func TestServerEndpoints(t *testing.T) {
	t.Parallel()

	loanBody := func(clientID string) string {
		return `{"client_id":"` + clientID +
			`","product_id":"seed","amount":1000,"currency_code":"KES","idempotency_key":"key-1"}`
	}

	tests := []struct {
		name          string
		claims        *security.AuthenticationClaims
		resolver      fakeResolver
		method        string
		path          string
		body          string
		wantStatus    int
		wantClientID  string
		wantResolves  int
		wantPaidOffed int
		wantSetTo     models.CreditProfileStatus
	}{
		{
			name:         "customer profile maps to a client",
			claims:       customerClaims(),
			resolver:     fakeResolver{clientID: ownClientID},
			method:       http.MethodPost,
			path:         "/api/v1/seed/loan-requests",
			body:         loanBody(""),
			wantStatus:   http.StatusOK,
			wantClientID: ownClientID,
			wantResolves: 1,
		},
		{
			name:         "customer profile owns no client",
			claims:       customerClaims(),
			resolver:     fakeResolver{err: business.ErrNoClientForProfile},
			method:       http.MethodPost,
			path:         "/api/v1/seed/loan-requests",
			body:         loanBody(""),
			wantStatus:   http.StatusForbidden,
			wantResolves: 1,
		},
		{
			name:         "customer names another client",
			claims:       customerClaims(),
			resolver:     fakeResolver{clientID: ownClientID},
			method:       http.MethodPost,
			path:         "/api/v1/seed/loan-requests",
			body:         loanBody(otherClient),
			wantStatus:   http.StatusForbidden,
			wantResolves: 1,
		},
		{
			name:         "staff names another client",
			claims:       staffClaims(),
			resolver:     fakeResolver{clientID: ownClientID},
			method:       http.MethodPost,
			path:         "/api/v1/seed/loan-requests",
			body:         loanBody(otherClient),
			wantStatus:   http.StatusOK,
			wantClientID: otherClient,
			wantResolves: 0,
		},
		{
			name:         "customer reads their own credit profile",
			claims:       customerClaims(),
			resolver:     fakeResolver{clientID: ownClientID},
			method:       http.MethodGet,
			path:         "/api/v1/seed/credit-profiles/" + ownClientID + "/KES",
			wantStatus:   http.StatusOK,
			wantClientID: ownClientID,
			wantResolves: 1,
		},
		{
			name:         "customer reads another client's credit profile",
			claims:       customerClaims(),
			resolver:     fakeResolver{clientID: ownClientID},
			method:       http.MethodGet,
			path:         "/api/v1/seed/credit-profiles/" + otherClient + "/KES",
			wantStatus:   http.StatusForbidden,
			wantResolves: 1,
		},
		{
			name:       "customer calls the paid-off hook",
			claims:     customerClaims(),
			resolver:   fakeResolver{clientID: ownClientID},
			method:     http.MethodPost,
			path:       "/api/v1/seed/internal/paid-off",
			body:       `{"loan_account_id":"loan-1","total_repaid":1000}`,
			wantStatus: http.StatusForbidden,
		},
		{
			name:          "internal system calls the paid-off hook",
			claims:        internalClaims(),
			resolver:      fakeResolver{clientID: ownClientID},
			method:        http.MethodPost,
			path:          "/api/v1/seed/internal/paid-off",
			body:          `{"loan_account_id":"loan-1","total_repaid":1000}`,
			wantStatus:    http.StatusOK,
			wantPaidOffed: 1,
		},
		{
			name:       "anonymous caller is refused",
			method:     http.MethodPost,
			path:       "/api/v1/seed/loan-requests",
			body:       loanBody(""),
			wantStatus: http.StatusUnauthorized,
		},
		{
			name:         "operator suspends a profile",
			claims:       staffClaims(),
			method:       http.MethodPost,
			path:         "/api/v1/seed/credit-profiles/" + otherClient + "/KES/suspend",
			body:         `{"reason":"chargeback under review"}`,
			wantStatus:   http.StatusOK,
			wantClientID: otherClient,
			wantSetTo:    models.CreditProfileStatusSuspended,
		},
		{
			name:         "operator blocks a profile",
			claims:       staffClaims(),
			method:       http.MethodPost,
			path:         "/api/v1/seed/credit-profiles/" + otherClient + "/KES/block",
			body:         `{"reason":"fraud confirmed"}`,
			wantStatus:   http.StatusOK,
			wantClientID: otherClient,
			wantSetTo:    models.CreditProfileStatusBlocked,
		},
		{
			name:         "operator reinstates a profile",
			claims:       staffClaims(),
			method:       http.MethodPost,
			path:         "/api/v1/seed/credit-profiles/" + otherClient + "/KES/reinstate",
			body:         `{"reason":"dispute resolved"}`,
			wantStatus:   http.StatusOK,
			wantClientID: otherClient,
			wantSetTo:    models.CreditProfileStatusActive,
		},
		{
			name:       "status change with a malformed body is rejected",
			claims:     staffClaims(),
			method:     http.MethodPost,
			path:       "/api/v1/seed/credit-profiles/" + otherClient + "/KES/suspend",
			body:       `{"reason":`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name:       "anonymous status change is refused",
			method:     http.MethodPost,
			path:       "/api/v1/seed/credit-profiles/" + otherClient + "/KES/block",
			body:       `{"reason":"x"}`,
			wantStatus: http.StatusUnauthorized,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			loanBusiness := &fakeLoanRequest{}
			profileBusiness := &fakeCreditProfile{}
			resolver := tt.resolver

			mux := http.NewServeMux()
			handlers.NewServer(loanBusiness, profileBusiness, &resolver, staffRole).Register(mux)

			req := httptest.NewRequest(tt.method, tt.path, strings.NewReader(tt.body))
			if tt.claims != nil {
				req = req.WithContext(tt.claims.ClaimsToContext(req.Context()))
			}
			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, req)

			if rec.Code != tt.wantStatus {
				t.Fatalf("status = %d, want %d (body %s)", rec.Code, tt.wantStatus, rec.Body.String())
			}
			assertSideEffects(t, tt.name, sideEffects{
				clientID:   actedOnClient(loanBusiness, profileBusiness),
				resolves:   resolver.calls,
				paidOffs:   loanBusiness.paidOffCall,
				status:     profileBusiness.lastStatus,
				hasReason:  profileBusiness.lastReason != "",
				wantClient: tt.wantClientID,
				wantResolv: tt.wantResolves,
				wantPaid:   tt.wantPaidOffed,
				wantStatus: tt.wantSetTo,
			})
		})
	}
}

// sideEffects pairs what the fakes observed with what a case expects.
type sideEffects struct {
	clientID   string
	resolves   int
	paidOffs   int
	status     models.CreditProfileStatus
	hasReason  bool
	wantClient string
	wantResolv int
	wantPaid   int
	wantStatus models.CreditProfileStatus
}

func assertSideEffects(t *testing.T, name string, got sideEffects) {
	t.Helper()

	if got.clientID != got.wantClient {
		t.Errorf("%s: acted on client %q, want %q", name, got.clientID, got.wantClient)
	}
	if got.resolves != got.wantResolv {
		t.Errorf("%s: resolver called %d times, want %d", name, got.resolves, got.wantResolv)
	}
	if got.paidOffs != got.wantPaid {
		t.Errorf("%s: paid-off hook ran %d times, want %d", name, got.paidOffs, got.wantPaid)
	}
	if got.status != got.wantStatus {
		t.Errorf("%s: status set to %d, want %d", name, got.status, got.wantStatus)
	}
	if got.wantStatus != models.CreditProfileStatusUnspecified && !got.hasReason {
		t.Errorf("%s: status change reached the business without its reason", name)
	}
}

func actedOnClient(loanBusiness *fakeLoanRequest, profileBusiness *fakeCreditProfile) string {
	if loanBusiness.input.ClientID != "" {
		return loanBusiness.input.ClientID
	}
	return profileBusiness.lastClientID
}
