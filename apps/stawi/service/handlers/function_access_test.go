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
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/security/authorizer"

	"github.com/antinvestor/service-fintech/apps/stawi/service/handlers"
	stawiv1 "github.com/antinvestor/service-fintech/gen/go/stawi/protocolbuffers/go/stawi/v1"
)

const evaluateWindowRoute = "/api/v1/groups/g-1/evaluate-loan-window"

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
	sd := stawiv1.File_stawi_v1_stawi_proto.Services().ByName("StawiWorkflowService")
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
	handlers.RegisterWorkflowCallbacks(mux, handlers.Businesses{})

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

// TestWorkflowRoutesAreInManifest asserts the other direction: every route a
// workflow definition calls is in the manifest, so no callback runs without a
// permission check.
func TestWorkflowRoutesAreInManifest(t *testing.T) {
	t.Parallel()

	mux := http.NewServeMux()
	handlers.RegisterWorkflowCallbacks(mux, handlers.Businesses{})
	routes := manifestRoutes(t)

	for _, req := range collectWorkflowRequests(t) {
		_, pattern := mux.Handler(httptest.NewRequest(req.method, req.path, nil))
		if pattern == "" {
			continue // TestWorkflowURLsResolveAgainstMux reports these.
		}
		method, path, _ := strings.Cut(pattern, " ")
		if _, ok := routes[handlers.RouteKey(method, path)]; !ok {
			t.Errorf("workflow %s calls %s, which is served but missing from the manifest", req.workflow, pattern)
		}
	}
}

func TestFunctionAccessMiddleware(t *testing.T) {
	t.Parallel()

	windowBiz := &fakeLoanWindowBusiness{result: map[string]any{"eligible": true}}
	mux := http.NewServeMux()
	handlers.RegisterWorkflowCallbacks(mux, handlers.Businesses{LoanWindow: windowBiz})
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
			checker:    &grantChecker{granted: map[string]bool{"stawi_group_view": true}},
			method:     http.MethodPost,
			path:       evaluateWindowRoute,
			wantStatus: http.StatusForbidden,
			wantCode:   "forbidden",
			wantChecks: []string{"stawi_loan_window_manage"},
		},
		{
			name:       "principal with the permission gets through",
			checker:    &grantChecker{granted: map[string]bool{"stawi_loan_window_manage": true}},
			method:     http.MethodPost,
			path:       evaluateWindowRoute,
			wantStatus: http.StatusOK,
			wantChecks: []string{"stawi_loan_window_manage"},
		},
		{
			name:       "no principal is unauthenticated",
			checker:    &grantChecker{},
			method:     http.MethodPost,
			path:       evaluateWindowRoute,
			wantStatus: http.StatusUnauthorized,
			wantCode:   "unauthenticated",
			wantChecks: []string{"stawi_loan_window_manage"},
		},
		{
			name:       "registered route missing from the manifest fails closed",
			checker:    &grantChecker{granted: map[string]bool{"stawi_group_manage": true}},
			method:     http.MethodPost,
			path:       "/api/v1/groups/g-1/unmapped",
			wantStatus: http.StatusForbidden,
			wantCode:   "forbidden",
		},
		{
			name:       "unknown path is a plain 404 without a permission check",
			checker:    &grantChecker{granted: map[string]bool{"stawi_group_manage": true}},
			method:     http.MethodPost,
			path:       "/api/v1/nowhere",
			wantStatus: http.StatusNotFound,
		},
		{
			name:       "wrong method is a plain 405 without a permission check",
			checker:    &grantChecker{granted: map[string]bool{"stawi_loan_window_manage": true}},
			method:     http.MethodGet,
			path:       evaluateWindowRoute,
			wantStatus: http.StatusMethodNotAllowed,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			handler := handlers.FunctionAccessMiddleware(mux, tt.checker, manifestRoutes(t))
			rec := httptest.NewRecorder()
			handler.ServeHTTP(rec, httptest.NewRequest(tt.method, tt.path, nil))

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
// fail-closed contract at build time: a descriptor whose methods carry
// permissions but no google.api.http route cannot become an HTTP manifest.
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
