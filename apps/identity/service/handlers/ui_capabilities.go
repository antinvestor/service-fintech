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
	"encoding/json"
	"errors"
	"fmt"

	"net/http"
	"sort"

	"connectrpc.com/connect/v2"

	fieldpb "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	fundingpb "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	identitypb "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	limitspb "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	loanspb "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	operationspb "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	savingspb "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"github.com/antinvestor/common/v3/permissions"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/reflect/protoreflect"
)

const (
	// CapabilitiesPath serves the caller's full permission set.
	CapabilitiesPath = "/ui/capabilities"
	// CapabilitiesBatchCheckPath serves a bounded subset check.
	CapabilitiesBatchCheckPath = "/ui/capabilities/batch-check"

	maxCapabilityBodyBytes               = 64 << 10
	maxCapabilityNamespaces              = 20
	maxCapabilityPermissionsPerNamespace = 100
)

// ErrCapabilitySubjectUnknown is returned when the request carries no
// authenticated subject.
var ErrCapabilitySubjectUnknown = errors.New("no authenticated subject")

// CapabilityRequest names one permission within one Keto namespace.
type CapabilityRequest struct {
	Namespace  string
	Permission string
}

// CapabilityChecker resolves which of the requested permissions the caller in
// ctx holds. The returned slice is the granted subset of requests.
type CapabilityChecker interface {
	Granted(ctx context.Context, requests []CapabilityRequest) ([]CapabilityRequest, error)
}

type ketoCapabilityChecker struct {
	authorizer       security.Authorizer
	subjectNamespace string
}

// NewCapabilityChecker builds a CapabilityChecker over the same authorizer the
// function access interceptor uses, so a UI grant means exactly what the RPC
// guard means: permission P on <tenant>/<partition> in namespace N for the
// caller's profile.
func NewCapabilityChecker(auth security.Authorizer) CapabilityChecker {
	return &ketoCapabilityChecker{authorizer: auth, subjectNamespace: security.NamespaceProfile}
}

func (c *ketoCapabilityChecker) Granted(
	ctx context.Context,
	requests []CapabilityRequest,
) ([]CapabilityRequest, error) {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return nil, ErrCapabilitySubjectUnknown
	}

	subjectID := claims.GetProfileID()
	tenantID := claims.GetTenantID()
	partitionID := claims.GetPartitionID()
	if subjectID == "" || tenantID == "" || partitionID == "" {
		return nil, nil
	}

	if len(requests) == 0 {
		return nil, nil
	}

	tenancyPath := fmt.Sprintf("%s/%s", tenantID, partitionID)
	checks := make([]security.CheckRequest, 0, len(requests))
	for _, req := range requests {
		checks = append(checks, security.CheckRequest{
			Object:     security.ObjectRef{Namespace: req.Namespace, ID: tenancyPath},
			Permission: req.Permission,
			Subject:    security.SubjectRef{Namespace: c.subjectNamespace, ID: subjectID},
		})
	}

	results, err := c.authorizer.BatchCheck(ctx, checks)
	if err != nil {
		// connect v2 sends a plain error as Unknown with no message; say what failed.
		return nil, connect.NewError(connect.CodeUnavailable, "capability check unavailable").WithCause(err)
	}
	if len(results) != len(requests) {
		return nil, connect.NewError(connect.CodeInternal, "capability check returned an incomplete answer").
			WithCause(fmt.Errorf("authorizer returned %d results for %d checks", len(results), len(requests)))
	}

	granted := make([]CapabilityRequest, 0, len(requests))
	for i, result := range results {
		if result.Allowed {
			granted = append(granted, requests[i])
		}
	}
	return granted, nil
}

// UICapabilitiesHandler serves the two REST endpoints the operator consoles use
// to decide which permission-gated surfaces to render. Both are authenticated
// and read-only; the server re-checks every RPC regardless of what they return.
type UICapabilitiesHandler struct {
	checker CapabilityChecker
	catalog map[string][]string
	known   map[string]map[string]struct{}
}

// NewUICapabilitiesHandler builds the handler over a namespace catalog mapping
// each known Keto namespace to the permissions declared for it.
func NewUICapabilitiesHandler(checker CapabilityChecker, catalog map[string][]string) *UICapabilitiesHandler {
	known := make(map[string]map[string]struct{}, len(catalog))
	ordered := make(map[string][]string, len(catalog))
	for namespace, perms := range catalog {
		set := make(map[string]struct{}, len(perms))
		list := make([]string, 0, len(perms))
		for _, perm := range perms {
			if perm == "" {
				continue
			}
			if _, seen := set[perm]; seen {
				continue
			}
			set[perm] = struct{}{}
			list = append(list, perm)
		}
		sort.Strings(list)
		known[namespace] = set
		ordered[namespace] = list
	}
	return &UICapabilitiesHandler{checker: checker, catalog: ordered, known: known}
}

// ServiceNamespaceCatalog lists every service namespace this deployment knows
// about together with the permissions declared on its proto services. It is the
// allow-list the endpoints validate requested namespaces and keys against.
func ServiceNamespaceCatalog() map[string][]string {
	catalog := map[string][]string{}
	files := []protoreflect.FileDescriptor{
		identitypb.File_identity_v1_identity_proto,
		fieldpb.File_field_v1_field_proto,
		limitspb.File_limits_v1_limits_proto,
		loanspb.File_loans_v1_loans_proto,
		savingspb.File_savings_v1_savings_proto,
		fundingpb.File_funding_v1_funding_proto,
		operationspb.File_operations_v1_operations_proto,
	}
	for _, file := range files {
		services := file.Services()
		for i := range services.Len() {
			svcPerms := permissions.ForService(services.Get(i))
			if svcPerms.Namespace == "" {
				continue
			}
			catalog[svcPerms.Namespace] = append(catalog[svcPerms.Namespace], svcPerms.Permissions...)
		}
	}
	return catalog
}

type batchCheckEntry struct {
	Namespace   string   `json:"namespace"`
	Permissions []string `json:"permissions"`
}

type batchCheckRequest struct {
	Checks []batchCheckEntry `json:"checks"`
}

type batchCheckResponse struct {
	Granted []string `json:"granted"`
}

type capabilitiesResponse struct {
	User capabilitiesUser `json:"user"`
}

type capabilitiesUser struct {
	Permissions []string `json:"permissions"`
}

// BatchCheck handles POST /ui/capabilities/batch-check.
func (h *UICapabilitiesHandler) BatchCheck(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if security.ClaimsFromContext(r.Context()) == nil {
		http.Error(w, "unauthenticated", http.StatusUnauthorized)
		return
	}

	r.Body = http.MaxBytesReader(w, r.Body, maxCapabilityBodyBytes)

	var payload batchCheckRequest
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		var tooLarge *http.MaxBytesError
		if errors.As(err, &tooLarge) {
			http.Error(w, "request body too large", http.StatusRequestEntityTooLarge)
			return
		}
		http.Error(w, "malformed request body", http.StatusBadRequest)
		return
	}

	if len(payload.Checks) > maxCapabilityNamespaces {
		http.Error(w, "too many namespaces requested", http.StatusBadRequest)
		return
	}

	requests := make([]CapabilityRequest, 0)
	seen := make(map[CapabilityRequest]struct{})
	for _, entry := range payload.Checks {
		if len(entry.Permissions) > maxCapabilityPermissionsPerNamespace {
			http.Error(w, "too many permissions requested", http.StatusBadRequest)
			return
		}
		namespacePerms, ok := h.known[entry.Namespace]
		if !ok {
			continue
		}
		for _, perm := range entry.Permissions {
			if _, declared := namespacePerms[perm]; !declared {
				continue
			}
			req := CapabilityRequest{Namespace: entry.Namespace, Permission: perm}
			if _, dup := seen[req]; dup {
				continue
			}
			seen[req] = struct{}{}
			requests = append(requests, req)
		}
	}

	granted, err := h.checker.Granted(r.Context(), requests)
	if err != nil {
		h.writeCheckerError(r.Context(), w, err)
		return
	}

	writeJSON(r.Context(), w, batchCheckResponse{Granted: permissionKeys(granted)})
}

// List handles GET /ui/capabilities.
func (h *UICapabilitiesHandler) List(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if security.ClaimsFromContext(r.Context()) == nil {
		http.Error(w, "unauthenticated", http.StatusUnauthorized)
		return
	}

	namespaces := make([]string, 0, len(h.catalog))
	for namespace := range h.catalog {
		namespaces = append(namespaces, namespace)
	}
	sort.Strings(namespaces)

	requests := make([]CapabilityRequest, 0)
	for _, namespace := range namespaces {
		for _, perm := range h.catalog[namespace] {
			requests = append(requests, CapabilityRequest{Namespace: namespace, Permission: perm})
		}
	}

	granted, err := h.checker.Granted(r.Context(), requests)
	if err != nil {
		h.writeCheckerError(r.Context(), w, err)
		return
	}

	writeJSON(r.Context(), w, capabilitiesResponse{
		User: capabilitiesUser{Permissions: permissionKeys(granted)},
	})
}

func (h *UICapabilitiesHandler) writeCheckerError(ctx context.Context, w http.ResponseWriter, err error) {
	if errors.Is(err, ErrCapabilitySubjectUnknown) {
		http.Error(w, "unauthenticated", http.StatusUnauthorized)
		return
	}
	util.Log(ctx).WithError(err).Warn("ui capabilities -- permission check failed")
	http.Error(w, "capability service unavailable", http.StatusServiceUnavailable)
}

// permissionKeys flattens granted requests to the bare permission keys the UI
// registry uses, de-duplicated across namespaces and ordered for stability.
func permissionKeys(granted []CapabilityRequest) []string {
	seen := make(map[string]struct{}, len(granted))
	keys := make([]string, 0, len(granted))
	for _, req := range granted {
		if _, dup := seen[req.Permission]; dup {
			continue
		}
		seen[req.Permission] = struct{}{}
		keys = append(keys, req.Permission)
	}
	sort.Strings(keys)
	return keys
}

func writeJSON(ctx context.Context, w http.ResponseWriter, payload any) {
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		util.Log(ctx).WithError(err).Warn("ui capabilities -- could not encode response")
	}
}
