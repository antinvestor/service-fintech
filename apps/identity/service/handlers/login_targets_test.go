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

package handlers

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/identity/service/business"
)

type fakeLoginClientBusiness struct{}

func (fakeLoginClientBusiness) EnableForOrganization(context.Context, string) (string, error) {
	return "", nil
}

func (fakeLoginClientBusiness) EnableForBranch(context.Context, string) (string, error) {
	return "", nil
}

func (fakeLoginClientBusiness) GetLoginTargets(
	_ context.Context,
	_ string,
) (*business.LoginTargetsResponse, error) {
	return &business.LoginTargetsResponse{}, nil
}

func newLoginTargetsRequest(origin, remote string) *http.Request {
	req := httptest.NewRequest(http.MethodGet, "/api/v1/login-targets/client-1", nil)
	if origin != "" {
		req.Header.Set("Origin", origin)
	}
	req.RemoteAddr = remote
	return req
}

func TestLoginTargetsCORSOnlyForLoginOrigins(t *testing.T) {
	h := NewLoginTargetsHandler(fakeLoginClientBusiness{}, []string{
		"https://app.stawi.org/auth/callback",
		"com.antinvestor.app://auth/callback",
	})

	tests := []struct {
		name        string
		origin      string
		wantAllowed string
	}{
		{name: "login origin is echoed", origin: "https://app.stawi.org", wantAllowed: "https://app.stawi.org"},
		{name: "case-insensitive host", origin: "https://APP.stawi.org", wantAllowed: "https://APP.stawi.org"},
		{name: "foreign origin gets nothing", origin: "https://evil.example", wantAllowed: ""},
		{name: "no origin gets nothing", origin: "", wantAllowed: ""},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			rec := httptest.NewRecorder()
			h.ServeHTTP(rec, newLoginTargetsRequest(tc.origin, "10.0.0.1:1234"))
			require.Equal(t, http.StatusOK, rec.Code)
			require.Equal(t, tc.wantAllowed, rec.Header().Get("Access-Control-Allow-Origin"))
		})
	}
}

func TestLoginTargetsPreflight(t *testing.T) {
	h := NewLoginTargetsHandler(fakeLoginClientBusiness{}, []string{"http://localhost:5174/auth/callback"})
	req := httptest.NewRequest(http.MethodOptions, "/api/v1/login-targets/client-1", nil)
	req.Header.Set("Origin", "http://localhost:5174")
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	require.Equal(t, http.StatusNoContent, rec.Code)
	require.Equal(t, "http://localhost:5174", rec.Header().Get("Access-Control-Allow-Origin"))
}

func TestLoginTargetsRateLimitPerClientAddress(t *testing.T) {
	h := NewLoginTargetsHandler(fakeLoginClientBusiness{}, nil)

	var limited int
	for range loginTargetsBurst + 5 {
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, newLoginTargetsRequest("", "10.0.0.2:1234"))
		if rec.Code == http.StatusTooManyRequests {
			limited++
		}
	}
	require.Positive(t, limited)

	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, newLoginTargetsRequest("", "10.0.0.3:1234"))
	require.Equal(t, http.StatusOK, rec.Code, "another address has its own budget")
}
