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
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	operationspb "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"github.com/antinvestor/common/v3/permissions"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/security/authorizer"

	"github.com/antinvestor/service-fintech/apps/stawi/service/handlers"
	stawiv1 "github.com/antinvestor/service-fintech/gen/go/stawi/protocolbuffers/go/stawi/v1"
)

const respondRoute = "/api/v1/groups/g-1/loan-offers/o-1/respond"

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
		security.ObjectRef{Namespace: "service_stawi", ID: "t/p"},
		permission,
		security.SubjectRef{Namespace: "profile_user", ID: "p-1"},
		"no relation",
	)
}

func manifestRoutes(t *testing.T) handlers.RoutePermissions {
	t.Helper()
	sd := stawiv1.File_stawi_v1_stawi_proto.Services().ByName("StawiService")
	routes, err := handlers.BuildRoutePermissions(sd)
	if err != nil {
		t.Fatalf("build route permissions: %v", err)
	}
	return routes
}

// TestManifestRoutesResolveAgainstMux asserts that every route in the
// stawi.v1 permission manifest is served by the mux, and that the mux
// resolves it to the same route key the middleware will look up.
func TestManifestRoutesResolveAgainstMux(t *testing.T) {
	t.Parallel()

	mux := http.NewServeMux()
	handlers.RegisterRoutes(mux, &fakeResponder{})

	for key, perms := range manifestRoutes(t) {
		t.Run(key, func(t *testing.T) {
			t.Parallel()
			if len(perms) == 0 {
				t.Fatalf("manifest route %q names no permission", key)
			}

			method, template, _ := strings.Cut(key, " ")
			path := strings.ReplaceAll(template, "{}", "x")
			_, pattern := mux.Handler(httptest.NewRequest(method, path, nil))
			if pattern == "" {
				t.Fatalf("manifest route %q is not served by the mux", key)
			}
			patternMethod, patternPath, _ := strings.Cut(pattern, " ")
			if got := handlers.RouteKey(patternMethod, patternPath); got != key {
				t.Fatalf("mux resolves %q to %q, want the manifest key", path, got)
			}
		})
	}
}

// Only the routes the manifest binds are served over HTTP; the job RPC is
// Connect only, and its permission is still in the manifest.
func TestManifestServesOnlyBoundRoutes(t *testing.T) {
	t.Parallel()

	routes := manifestRoutes(t)
	if len(routes) != 1 {
		t.Fatalf("routes = %v, want only the loan offer answer", routes)
	}
	if perms := routes[handlers.RouteKey(http.MethodPost, "/api/v1/groups/{}/loan-offers/{}/respond")]; strings.Join(
		perms, ",") != "stawi_loan_offer_respond" {
		t.Fatalf("respond route permissions = %v", perms)
	}

	sd := stawiv1.File_stawi_v1_stawi_proto.Services().ByName("StawiService")
	procedures := permissions.BuildProcedureMap(sd)
	if got := procedures["/stawi.v1.StawiService/StawiJobRun"]; strings.Join(got, ",") != "stawi_job_run" {
		t.Fatalf("StawiJobRun permissions = %v, want stawi_job_run", got)
	}
}

func TestFunctionAccessMiddleware(t *testing.T) {
	t.Parallel()

	mux := http.NewServeMux()
	handlers.RegisterRoutes(mux, &fakeResponder{})
	// A route the service registers but the manifest does not know about.
	mux.HandleFunc("POST /api/v1/groups/{groupId}/unmapped", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	tests := []struct {
		name       string
		checker    *grantChecker
		method     string
		path       string
		wantStatus int
		wantCode   string
		wantChecks []string
	}{
		{
			name:       "principal without the permission is refused",
			checker:    &grantChecker{granted: map[string]bool{"stawi_job_run": true}},
			method:     http.MethodPost,
			path:       respondRoute,
			wantStatus: http.StatusForbidden,
			wantCode:   "forbidden",
			wantChecks: []string{"stawi_loan_offer_respond"},
		},
		{
			name:       "principal with the permission gets through",
			checker:    &grantChecker{granted: map[string]bool{"stawi_loan_offer_respond": true}},
			method:     http.MethodPost,
			path:       respondRoute,
			wantStatus: http.StatusOK,
			wantChecks: []string{"stawi_loan_offer_respond"},
		},
		{
			name:       "no principal is unauthenticated",
			checker:    &grantChecker{},
			method:     http.MethodPost,
			path:       respondRoute,
			wantStatus: http.StatusUnauthorized,
			wantCode:   "unauthenticated",
			wantChecks: []string{"stawi_loan_offer_respond"},
		},
		{
			name:       "registered route missing from the manifest fails closed",
			checker:    &grantChecker{granted: map[string]bool{"stawi_loan_offer_respond": true}},
			method:     http.MethodPost,
			path:       "/api/v1/groups/g-1/unmapped",
			wantStatus: http.StatusForbidden,
			wantCode:   "forbidden",
		},
		{
			name:       "unknown path is a plain 404 without a permission check",
			checker:    &grantChecker{granted: map[string]bool{"stawi_loan_offer_respond": true}},
			method:     http.MethodPost,
			path:       "/api/v1/nowhere",
			wantStatus: http.StatusNotFound,
		},
		{
			name:       "wrong method is a plain 405 without a permission check",
			checker:    &grantChecker{granted: map[string]bool{"stawi_loan_offer_respond": true}},
			method:     http.MethodGet,
			path:       respondRoute,
			wantStatus: http.StatusMethodNotAllowed,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			handler := handlers.FunctionAccessMiddleware(mux, tt.checker, manifestRoutes(t))
			rec := httptest.NewRecorder()
			handler.ServeHTTP(rec, httptest.NewRequest(tt.method, tt.path, strings.NewReader(`{"response":2}`)))

			if rec.Code != tt.wantStatus {
				t.Fatalf("status = %d, want %d (body %s)", rec.Code, tt.wantStatus, rec.Body.String())
			}
			if strings.Join(tt.checker.calls, ",") != strings.Join(tt.wantChecks, ",") {
				t.Errorf("checked permissions %v, want %v", tt.checker.calls, tt.wantChecks)
			}
			if tt.wantCode == "" {
				return
			}
			var body struct {
				Code string `json:"code"`
			}
			if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
				t.Fatalf("decode body %q: %v", rec.Body.String(), err)
			}
			if body.Code != tt.wantCode {
				t.Errorf("code = %q, want %q", body.Code, tt.wantCode)
			}
		})
	}
}

// TestBuildRoutePermissions_RejectsServiceWithoutHTTPBindings guards the
// build-time contract: a descriptor that binds no google.api.http route at
// all is not a route manifest.
func TestBuildRoutePermissions_RejectsServiceWithoutHTTPBindings(t *testing.T) {
	t.Parallel()

	sd := operationspb.File_operations_v1_operations_proto.Services().ByName("OperationsService")
	if sd == nil {
		t.Fatal("operations service descriptor not found")
	}
	if _, err := handlers.BuildRoutePermissions(sd); err == nil {
		t.Fatal("a service without google.api.http bindings must not build a route manifest")
	}
}
