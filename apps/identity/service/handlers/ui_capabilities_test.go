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
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/identity/service/handlers"
)

type fakeCapabilityChecker struct {
	allowed  map[handlers.CapabilityRequest]bool
	err      error
	received []handlers.CapabilityRequest
}

func (f *fakeCapabilityChecker) Granted(
	_ context.Context,
	requests []handlers.CapabilityRequest,
) ([]handlers.CapabilityRequest, error) {
	f.received = append(f.received, requests...)
	if f.err != nil {
		return nil, f.err
	}
	granted := make([]handlers.CapabilityRequest, 0, len(requests))
	for _, req := range requests {
		if f.allowed[req] {
			granted = append(granted, req)
		}
	}
	return granted, nil
}

func testCatalog() map[string][]string {
	return map[string][]string{
		"service_identity": {"organization_view", "organization_manage", "workforce_member_view"},
		"service_limits":   {"limits_policy_manage", "limits_approval_act"},
	}
}

func authenticatedRequest(t *testing.T, method, path, body string) *http.Request {
	t.Helper()
	req := httptest.NewRequest(method, path, strings.NewReader(body))
	claims := &security.AuthenticationClaims{
		ProfileID:   "profile-1",
		TenantID:    "tenant-1",
		PartitionID: "partition-1",
	}
	return req.WithContext(claims.ClaimsToContext(req.Context()))
}

func TestBatchCheckReturnsOnlyGrantedKeys(t *testing.T) {
	checker := &fakeCapabilityChecker{allowed: map[handlers.CapabilityRequest]bool{
		{Namespace: "service_identity", Permission: "organization_view"}:  true,
		{Namespace: "service_limits", Permission: "limits_policy_manage"}: true,
	}}
	handler := handlers.NewUICapabilitiesHandler(checker, testCatalog())

	body := `{"checks":[
		{"namespace":"service_identity","permissions":["organization_view","organization_manage","not_a_permission"]},
		{"namespace":"service_limits","permissions":["limits_policy_manage","limits_approval_act"]},
		{"namespace":"service_unknown","permissions":["anything"]}
	]}`
	rec := httptest.NewRecorder()
	handler.BatchCheck(rec, authenticatedRequest(t, http.MethodPost, handlers.CapabilitiesBatchCheckPath, body))

	require.Equal(t, http.StatusOK, rec.Code)

	var resp struct {
		Granted []string `json:"granted"`
	}
	require.NoError(t, json.Unmarshal(rec.Body.Bytes(), &resp))
	require.Equal(t, []string{"limits_policy_manage", "organization_view"}, resp.Granted)

	require.NotContains(t, checker.received, handlers.CapabilityRequest{
		Namespace: "service_unknown", Permission: "anything",
	})
	require.NotContains(t, checker.received, handlers.CapabilityRequest{
		Namespace: "service_identity", Permission: "not_a_permission",
	})
}

func TestBatchCheckEmptyGrantSetIsNotAnError(t *testing.T) {
	handler := handlers.NewUICapabilitiesHandler(&fakeCapabilityChecker{}, testCatalog())

	body := `{"checks":[{"namespace":"service_identity","permissions":["organization_view"]}]}`
	rec := httptest.NewRecorder()
	handler.BatchCheck(rec, authenticatedRequest(t, http.MethodPost, handlers.CapabilitiesBatchCheckPath, body))

	require.Equal(t, http.StatusOK, rec.Code)
	require.JSONEq(t, `{"granted":[]}`, rec.Body.String())
}

func TestBatchCheckUnauthenticated(t *testing.T) {
	handler := handlers.NewUICapabilitiesHandler(&fakeCapabilityChecker{}, testCatalog())

	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, handlers.CapabilitiesBatchCheckPath, strings.NewReader(`{"checks":[]}`))
	handler.BatchCheck(rec, req)

	require.Equal(t, http.StatusUnauthorized, rec.Code)
}

func TestBatchCheckOversizedBody(t *testing.T) {
	handler := handlers.NewUICapabilitiesHandler(&fakeCapabilityChecker{}, testCatalog())

	body := `{"checks":[{"namespace":"service_identity","permissions":["` +
		strings.Repeat("a", 128<<10) + `"]}]}`
	rec := httptest.NewRecorder()
	handler.BatchCheck(rec, authenticatedRequest(t, http.MethodPost, handlers.CapabilitiesBatchCheckPath, body))

	require.Equal(t, http.StatusRequestEntityTooLarge, rec.Code)
}

func TestBatchCheckRejectsOversizedRequestShape(t *testing.T) {
	handler := handlers.NewUICapabilitiesHandler(&fakeCapabilityChecker{}, testCatalog())

	tests := map[string]string{
		"malformed body": `{"checks":`,
		"too many namespaces": `{"checks":[` +
			strings.TrimSuffix(strings.Repeat(`{"namespace":"service_identity","permissions":[]},`, 21), ",") +
			`]}`,
		"too many permissions": `{"checks":[{"namespace":"service_identity","permissions":[` +
			strings.TrimSuffix(strings.Repeat(`"organization_view",`, 101), ",") + `]}]}`,
	}

	for name, body := range tests {
		t.Run(name, func(t *testing.T) {
			rec := httptest.NewRecorder()
			handler.BatchCheck(
				rec,
				authenticatedRequest(t, http.MethodPost, handlers.CapabilitiesBatchCheckPath, body),
			)
			require.Equal(t, http.StatusBadRequest, rec.Code)
		})
	}
}

func TestBatchCheckRejectsNonPost(t *testing.T) {
	handler := handlers.NewUICapabilitiesHandler(&fakeCapabilityChecker{}, testCatalog())

	rec := httptest.NewRecorder()
	handler.BatchCheck(rec, authenticatedRequest(t, http.MethodGet, handlers.CapabilitiesBatchCheckPath, ""))

	require.Equal(t, http.StatusMethodNotAllowed, rec.Code)
}

func TestBatchCheckAuthorizerFailureIsAnOutage(t *testing.T) {
	handler := handlers.NewUICapabilitiesHandler(
		&fakeCapabilityChecker{err: errors.New("keto unreachable")},
		testCatalog(),
	)

	body := `{"checks":[{"namespace":"service_identity","permissions":["organization_view"]}]}`
	rec := httptest.NewRecorder()
	handler.BatchCheck(rec, authenticatedRequest(t, http.MethodPost, handlers.CapabilitiesBatchCheckPath, body))

	require.Equal(t, http.StatusServiceUnavailable, rec.Code)
}

func TestListReturnsEveryHeldPermissionAcrossNamespaces(t *testing.T) {
	checker := &fakeCapabilityChecker{allowed: map[handlers.CapabilityRequest]bool{
		{Namespace: "service_identity", Permission: "workforce_member_view"}: true,
		{Namespace: "service_limits", Permission: "limits_approval_act"}:     true,
	}}
	handler := handlers.NewUICapabilitiesHandler(checker, testCatalog())

	rec := httptest.NewRecorder()
	handler.List(rec, authenticatedRequest(t, http.MethodGet, handlers.CapabilitiesPath, ""))

	require.Equal(t, http.StatusOK, rec.Code)
	require.JSONEq(t, `{"user":{"permissions":["limits_approval_act","workforce_member_view"]}}`, rec.Body.String())
	require.Len(t, checker.received, 5)
}

func TestListUnauthenticated(t *testing.T) {
	handler := handlers.NewUICapabilitiesHandler(&fakeCapabilityChecker{}, testCatalog())

	rec := httptest.NewRecorder()
	handler.List(rec, httptest.NewRequest(http.MethodGet, handlers.CapabilitiesPath, nil))

	require.Equal(t, http.StatusUnauthorized, rec.Code)
}

func TestListEmptyGrantSetIsNotAnError(t *testing.T) {
	handler := handlers.NewUICapabilitiesHandler(&fakeCapabilityChecker{}, testCatalog())

	rec := httptest.NewRecorder()
	handler.List(rec, authenticatedRequest(t, http.MethodGet, handlers.CapabilitiesPath, ""))

	require.Equal(t, http.StatusOK, rec.Code)
	require.JSONEq(t, `{"user":{"permissions":[]}}`, rec.Body.String())
}

// fakeAuthorizer records the CheckRequests the keto-backed checker builds and
// answers from a fixed allow set.
type fakeAuthorizer struct {
	security.Authorizer
	allowed  map[string]bool
	received []security.CheckRequest
}

func (f *fakeAuthorizer) BatchCheck(
	_ context.Context,
	requests []security.CheckRequest,
) ([]security.CheckResult, error) {
	f.received = append(f.received, requests...)
	results := make([]security.CheckResult, 0, len(requests))
	for _, req := range requests {
		results = append(results, security.CheckResult{Allowed: f.allowed[req.Permission]})
	}
	return results, nil
}

func TestCapabilityCheckerScopesToClaims(t *testing.T) {
	auth := &fakeAuthorizer{allowed: map[string]bool{"organization_view": true}}
	checker := handlers.NewCapabilityChecker(auth)

	claims := &security.AuthenticationClaims{
		ProfileID:   "profile-1",
		TenantID:    "tenant-1",
		PartitionID: "partition-1",
	}
	ctx := claims.ClaimsToContext(context.Background())

	granted, err := checker.Granted(ctx, []handlers.CapabilityRequest{
		{Namespace: "service_identity", Permission: "organization_view"},
		{Namespace: "service_identity", Permission: "organization_manage"},
	})
	require.NoError(t, err)
	require.Equal(t, []handlers.CapabilityRequest{
		{Namespace: "service_identity", Permission: "organization_view"},
	}, granted)

	require.Len(t, auth.received, 2)
	require.Equal(t, security.ObjectRef{Namespace: "service_identity", ID: "tenant-1/partition-1"},
		auth.received[0].Object)
	require.Equal(t, "profile-1", auth.received[0].Subject.ID)
	require.Equal(t, security.NamespaceProfile, auth.received[0].Subject.Namespace)
}

func TestCapabilityCheckerWithoutClaims(t *testing.T) {
	checker := handlers.NewCapabilityChecker(&fakeAuthorizer{})

	_, err := checker.Granted(context.Background(), []handlers.CapabilityRequest{
		{Namespace: "service_identity", Permission: "organization_view"},
	})
	require.ErrorIs(t, err, handlers.ErrCapabilitySubjectUnknown)
}

func TestCapabilityCheckerWithoutTenancyScopeGrantsNothing(t *testing.T) {
	auth := &fakeAuthorizer{allowed: map[string]bool{"organization_view": true}}
	checker := handlers.NewCapabilityChecker(auth)

	claims := &security.AuthenticationClaims{ProfileID: "profile-1"}
	ctx := claims.ClaimsToContext(context.Background())

	granted, err := checker.Granted(ctx, []handlers.CapabilityRequest{
		{Namespace: "service_identity", Permission: "organization_view"},
	})
	require.NoError(t, err)
	require.Empty(t, granted)
	require.Empty(t, auth.received)
}

func TestServiceNamespaceCatalogCoversUIManifestNamespaces(t *testing.T) {
	catalog := handlers.ServiceNamespaceCatalog()

	require.Contains(t, catalog["service_identity"], "organization_view")
	require.Contains(t, catalog["service_identity"], "access_role_assignment_manage")
	require.Contains(t, catalog["service_identity"], "form_template_manage")
	require.Contains(t, catalog["service_limits"], "limits_policy_manage")
	require.Contains(t, catalog["service_limits"], "limits_approval_act")
}
