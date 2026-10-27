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

// Package trustage registers a service's scheduled workflows with the
// platform scheduler. Scheduled work never runs on a timer inside a service:
// trustage fires each schedule and calls the service's job RPC.
package trustage

import (
	"context"
	"fmt"
	"io/fs"
	"os"
	"strings"
	"testing/fstest"

	"github.com/antinvestor/common/v3"
	"github.com/antinvestor/common/v3/connection"
	"github.com/antinvestor/common/v3/servicecatalog"
	"github.com/antinvestor/service-trustage/client/workflows"
	"github.com/antinvestor/service-trustage/gen/go/workflow/v1/workflowv1connect"
)

// StepName is the setup step that registers a service's workflows.
const StepName = "workflows"

// DefaultURL is where trustage runs in the platform cluster. A secure setup
// with no TRUSTAGE_URL or TRUSTAGE_SERVICE_URI uses it, or trustage's path on
// the platform gateway (OAUTH2_AUDIENCE_BASE_URL) when there is one, so
// registering the schedules needs no per-service configuration.
const DefaultURL = "http://service-trustage.trustage.svc:80"

// gatewayPath is trustage's path on the platform gateway.
const gatewayPath = "/trustage"

// EndpointPlaceholder stands, in a shipped workflow, for the base URL of the
// service the workflow belongs to. Setup replaces it before registering, so a
// workflow names its own service and trustage needs nothing configured for it.
const EndpointPlaceholder = "${SERVICE_ENDPOINT}"

// serviceAccountNamespaceFile is where Kubernetes tells a pod its namespace.
const serviceAccountNamespaceFile = "/var/run/secrets/kubernetes.io/serviceaccount/namespace"

// defaultNamespace is the fintech services' namespace when the pod's own is
// unknown.
const defaultNamespace = "fintech"

// SelfEndpoint is the base URL trustage calls this service on:
// TRUSTAGE_CALLBACK_ENDPOINT when set; else the service's own OAuth2 resource
// audience (OAUTH2_RESOURCE_AUDIENCE), which on the platform gateway is the
// URL the service is served at, e.g. https://api.stawi.org/loans; else, in a
// cluster, http://<service>.<namespace>.svc:80 with the pod's namespace.
func SelfEndpoint(service string) string {
	if override := strings.TrimSpace(os.Getenv("TRUSTAGE_CALLBACK_ENDPOINT")); override != "" {
		return strings.TrimRight(override, "/")
	}
	if audience := strings.TrimSpace(os.Getenv("OAUTH2_RESOURCE_AUDIENCE")); strings.HasPrefix(audience, "https://") ||
		strings.HasPrefix(audience, "http://") {
		return strings.TrimRight(audience, "/")
	}
	namespace := defaultNamespace
	if raw, err := os.ReadFile(serviceAccountNamespaceFile); err == nil && strings.TrimSpace(string(raw)) != "" {
		namespace = strings.TrimSpace(string(raw))
	}
	return "http://" + service + "." + namespace + ".svc:80"
}

// SyncWorkflows creates or updates every workflow definition in the image's
// workflows directory (TRUSTAGE_WORKFLOWS_DIR, default /workflows), with
// EndpointPlaceholder replaced by this service's own endpoint (SelfEndpoint of
// service, its Kubernetes service name). It runs in the setup job only. A
// service whose correctness depends on its schedules passes required=true so
// a deploy without them fails instead of shipping a service whose periodic
// work never runs.
func SyncWorkflows(ctx context.Context, cfg any, service string, required bool) error {
	trustageURL := os.Getenv("TRUSTAGE_URL")
	if trustageURL == "" {
		trustageURL = os.Getenv("TRUSTAGE_SERVICE_URI")
	}
	if trustageURL == "" {
		if !required {
			// Local development without trustage: nothing to register.
			return nil
		}
		trustageURL = DefaultURL
		if base := strings.TrimRight(strings.TrimSpace(os.Getenv("OAUTH2_AUDIENCE_BASE_URL")), "/"); base != "" {
			trustageURL = base + gatewayPath
		}
	}
	dir := os.Getenv("TRUSTAGE_WORKFLOWS_DIR")
	if dir == "" {
		dir = "/workflows"
	}
	cli, err := connection.NewServiceClient(ctx, cfg, common.ServiceTarget{
		Endpoint:  trustageURL,
		ServiceID: servicecatalog.ServiceTrustage,
	}, workflowv1connect.NewWorkflowServiceClient)
	if err != nil {
		return fmt.Errorf("trustage workflow client: %w", err)
	}
	fsys, err := withEndpoint(os.DirFS(dir), SelfEndpoint(service))
	if err != nil {
		return fmt.Errorf("read trustage workflows from %s: %w", dir, err)
	}
	if err = workflows.SyncFromFS(ctx, cli, fsys); err != nil {
		return fmt.Errorf("sync trustage workflows from %s: %w", dir, err)
	}
	return nil
}

// withEndpoint copies the workflow files of fsys with EndpointPlaceholder
// replaced by endpoint.
func withEndpoint(fsys fs.FS, endpoint string) (fs.FS, error) {
	out := fstest.MapFS{}
	err := fs.WalkDir(fsys, ".", func(path string, d fs.DirEntry, walkErr error) error {
		if walkErr != nil || d.IsDir() {
			return walkErr
		}
		raw, readErr := fs.ReadFile(fsys, path)
		if readErr != nil {
			return readErr
		}
		out[path] = &fstest.MapFile{Data: []byte(strings.ReplaceAll(string(raw), EndpointPlaceholder, endpoint))}
		return nil
	})
	return out, err
}
