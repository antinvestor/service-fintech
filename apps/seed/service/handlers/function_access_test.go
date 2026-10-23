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

	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/frame/v2/security/authorizer"

	"github.com/antinvestor/service-fintech/apps/seed/service/handlers"
	seedv1 "github.com/antinvestor/service-fintech/gen/go/seed/protocolbuffers/go/seed/v1"
)

// registeredRoutes lists every route Server.Register wires, as mux patterns.
// It is the mux side of the manifest contract: adding a route here without a
// manifest entry fails TestRegisteredRoutesAreInManifest, and at runtime the
// middleware refuses it.
func registeredRoutes() []string {
	return []string{
		"POST /api/v1/seed/loan-requests",
		"GET /api/v1/seed/credit-profiles/{clientId}/{currency}",
		"POST /api/v1/seed/internal/paid-off",
		"POST /api/v1/seed/credit-profiles/{clientId}/{currency}/suspend",
		"POST /api/v1/seed/credit-profiles/{clientId}/{currency}/block",
		"POST /api/v1/seed/credit-profiles/{clientId}/{currency}/reinstate",
	}
}

// grantChecker allows exactly the permissions it was built with, and reports
// no principal when built with nil.
type grantChecker struct {
	granted map[string]bool
	calls   []string
}

func (c *grantChecker) Check(_ context.Context, permission string) error {
	c.calls = append(c.calls, permission)
	if c.granted == nil {
		return authorizer.ErrInvalidSubject
	}
	if c.granted[permission] {
		return nil
	}
	return authorizer.NewPermissionDeniedError(
		security.ObjectRef{Namespace: "service_seed", ID: "t/p"},
		permission,
		security.SubjectRef{Namespace: "profile_user", ID: "p-1"},
		"no relation",
	)
}

func manifestRoutes(t *testing.T) handlers.RoutePermissions {
	t.Helper()
	sd := seedv1.File_seed_v1_seed_proto.Services().ByName("SeedService")
	routes, err := handlers.BuildRoutePermissions(sd)
	if err != nil {
		t.Fatalf("build route permissions: %v", err)
	}
	return routes
}

func newServerMux() *http.ServeMux {
	mux := http.NewServeMux()
	handlers.NewServer(&fakeLoanRequest{}, &fakeCreditProfile{}, &fakeResolver{clientID: ownClientID}, staffRole).
		Register(mux)
	return mux
}

// TestManifestRoutesResolveAgainstMux asserts every manifest route is served
// and resolves to the key the middleware looks up.
func TestManifestRoutesResolveAgainstMux(t *testing.T) {
	t.Parallel()

	mux := newServerMux()
	for key := range manifestRoutes(t) {
		method, template, _ := strings.Cut(key, " ")
		path := strings.ReplaceAll(template, "{}", "x")
		_, pattern := mux.Handler(httptest.NewRequest(method, path, nil))
		if pattern == "" {
			t.Errorf("manifest route %q is not served by the mux", key)
			continue
		}
		patternMethod, patternPath, _ := strings.Cut(pattern, " ")
		if got := handlers.RouteKey(patternMethod, patternPath); got != key {
			t.Errorf("mux resolves %q to %q, want the manifest key", path, got)
		}
	}
}

// TestRegisteredRoutesAreInManifest asserts the other direction: every route
// the server registers has a permission in the manifest.
func TestRegisteredRoutesAreInManifest(t *testing.T) {
	t.Parallel()

	routes := manifestRoutes(t)
	registered := registeredRoutes()
	if len(routes) != len(registered) {
		t.Errorf("manifest has %d routes, server registers %d", len(routes), len(registered))
	}
	for _, pattern := range registered {
		method, path, _ := strings.Cut(pattern, " ")
		if _, ok := routes[handlers.RouteKey(method, path)]; !ok {
			t.Errorf("registered route %q is missing from the manifest", pattern)
		}
	}
}

func TestFunctionAccessMiddleware(t *testing.T) {
	t.Parallel()

	const suspendPath = "/api/v1/seed/credit-profiles/" + otherClient + "/KES/suspend"
	const profilePath = "/api/v1/seed/credit-profiles/" + ownClientID + "/KES"

	tests := []struct {
		name       string
		checker    *grantChecker
		claims     *security.AuthenticationClaims
		method     string
		path       string
		body       string
		wantStatus int
		wantChecks []string
	}{
		{
			name:       "customer without admin permission cannot suspend",
			checker:    &grantChecker{granted: map[string]bool{"seed_credit_profile_view": true}},
			claims:     staffClaims(),
			method:     http.MethodPost,
			path:       suspendPath,
			body:       `{"reason":"x"}`,
			wantStatus: http.StatusForbidden,
			wantChecks: []string{"seed_credit_profile_admin"},
		},
		{
			name:       "operator with admin permission suspends",
			checker:    &grantChecker{granted: map[string]bool{"seed_credit_profile_admin": true}},
			claims:     staffClaims(),
			method:     http.MethodPost,
			path:       suspendPath,
			body:       `{"reason":"x"}`,
			wantStatus: http.StatusOK,
			wantChecks: []string{"seed_credit_profile_admin"},
		},
		{
			name:       "member with view permission reads own profile",
			checker:    &grantChecker{granted: map[string]bool{"seed_credit_profile_view": true}},
			claims:     customerClaims(),
			method:     http.MethodGet,
			path:       profilePath,
			wantStatus: http.StatusOK,
			wantChecks: []string{"seed_credit_profile_view"},
		},
		{
			name:       "no principal is unauthenticated",
			checker:    &grantChecker{},
			method:     http.MethodGet,
			path:       profilePath,
			wantStatus: http.StatusUnauthorized,
			wantChecks: []string{"seed_credit_profile_view"},
		},
		{
			name:       "registered route missing from the manifest fails closed",
			checker:    &grantChecker{granted: map[string]bool{"seed_credit_profile_admin": true}},
			claims:     staffClaims(),
			method:     http.MethodGet,
			path:       "/api/v1/seed/unmapped",
			wantStatus: http.StatusForbidden,
		},
		{
			name:       "unknown path is a plain 404 without a permission check",
			checker:    &grantChecker{granted: map[string]bool{"seed_credit_profile_admin": true}},
			claims:     staffClaims(),
			method:     http.MethodGet,
			path:       "/api/v1/seed/nowhere",
			wantStatus: http.StatusNotFound,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			mux := newServerMux()
			mux.HandleFunc("GET /api/v1/seed/unmapped", func(w http.ResponseWriter, _ *http.Request) {
				w.WriteHeader(http.StatusOK)
			})
			handler := handlers.FunctionAccessMiddleware(mux, tt.checker, manifestRoutes(t))

			req := httptest.NewRequest(tt.method, tt.path, strings.NewReader(tt.body))
			if tt.claims != nil {
				req = req.WithContext(tt.claims.ClaimsToContext(req.Context()))
			}
			rec := httptest.NewRecorder()
			handler.ServeHTTP(rec, req)

			if rec.Code != tt.wantStatus {
				t.Fatalf("status = %d, want %d (body %s)", rec.Code, tt.wantStatus, rec.Body.String())
			}
			if strings.Join(tt.checker.calls, ",") != strings.Join(tt.wantChecks, ",") {
				t.Errorf("checked permissions %v, want %v", tt.checker.calls, tt.wantChecks)
			}
		})
	}
}
