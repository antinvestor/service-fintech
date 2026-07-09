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
	"testing"

	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/frame/v2/security/interceptors/httptor"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/limits/service/handlers"
)

// stubArchival satisfies handlers.ArchivalRunner without a real database.
type stubArchival struct{}

func (s *stubArchival) Run(_ context.Context) (int, int, error) { return 0, 0, nil }

// stubAuthenticator always rejects tokens unless they equal "valid-token".
type stubAuthenticator struct{}

func (s *stubAuthenticator) Authenticate(
	ctx context.Context,
	jwtToken string,
	_ ...security.AuthOption,
) (context.Context, error) {
	if jwtToken == "valid-token" {
		return ctx, nil
	}
	return ctx, &authError{"invalid token"}
}

type authError struct{ msg string }

func (e *authError) Error() string { return e.msg }

// archiveHandlerWithAuth wires the ArchivalHandler behind the httptor
// AuthenticationMiddleware, mirroring what setupConnectServer does in main.go.
func archiveHandlerWithAuth(t *testing.T) http.Handler {
	t.Helper()
	h := handlers.NewArchivalHandler(&stubArchival{})
	return httptor.AuthenticationMiddleware(h, &stubAuthenticator{})
}

// TestArchivalHandler_RejectsUnauthenticated asserts that a POST without an
// Authorization header receives HTTP 401.
func TestArchivalHandler_RejectsUnauthenticated(t *testing.T) {
	handler := archiveHandlerWithAuth(t)

	req := httptest.NewRequest(http.MethodPost, "/admin/archive", nil)
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	require.Equal(t, http.StatusUnauthorized, rec.Code,
		"expected 401 when Authorization header is absent")
}

// TestArchivalHandler_RejectsMalformedToken asserts that a POST with a
// non-Bearer Authorization value receives HTTP 401.
func TestArchivalHandler_RejectsMalformedToken(t *testing.T) {
	handler := archiveHandlerWithAuth(t)

	req := httptest.NewRequest(http.MethodPost, "/admin/archive", nil)
	req.Header.Set("Authorization", "Basic dXNlcjpwYXNz")
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	require.Equal(t, http.StatusUnauthorized, rec.Code,
		"expected 401 when Authorization scheme is not Bearer")
}

// TestArchivalHandler_RejectsInvalidBearerToken asserts that a POST with a
// Bearer token that the authenticator rejects receives HTTP 403.
func TestArchivalHandler_RejectsInvalidBearerToken(t *testing.T) {
	handler := archiveHandlerWithAuth(t)

	req := httptest.NewRequest(http.MethodPost, "/admin/archive", nil)
	req.Header.Set("Authorization", "Bearer bad-token")
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	require.Equal(t, http.StatusForbidden, rec.Code,
		"expected 403 when the bearer token fails authenticator validation")
}

// TestArchivalHandler_AcceptsValidToken asserts that a POST with a recognised
// Bearer token passes authentication and reaches the inner handler.
// The inner handler returns 200 with a JSON body even when no rows are deleted.
func TestArchivalHandler_AcceptsValidToken(t *testing.T) {
	handler := archiveHandlerWithAuth(t)

	req := httptest.NewRequest(http.MethodPost, "/admin/archive", nil)
	req.Header.Set("Authorization", "Bearer valid-token")
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	// The stub archival returns (0,0,nil) so the inner handler succeeds.
	assert.Equal(t, http.StatusOK, rec.Code,
		"expected 200 for a POST with a valid bearer token")
	assert.Contains(t, rec.Header().Get("Content-Type"), "application/json",
		"response should be JSON")
}

// TestArchivalHandler_RejectsGetMethod asserts that a GET on /admin/archive
// after authentication receives HTTP 405 from the inner handler.
func TestArchivalHandler_RejectsGetMethod(t *testing.T) {
	handler := archiveHandlerWithAuth(t)

	req := httptest.NewRequest(http.MethodGet, "/admin/archive", nil)
	req.Header.Set("Authorization", "Bearer valid-token")
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	assert.Equal(t, http.StatusMethodNotAllowed, rec.Code,
		"inner handler must reject GET even after successful authentication")
}
