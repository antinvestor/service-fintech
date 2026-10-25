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
	"errors"
	"fmt"
	"os"

	"github.com/antinvestor/common/v3"
	"github.com/antinvestor/common/v3/connection"
	"github.com/antinvestor/common/v3/servicecatalog"
	"github.com/antinvestor/service-trustage/client/workflows"
	"github.com/antinvestor/service-trustage/gen/go/workflow/v1/workflowv1connect"
)

// StepName is the setup step that registers a service's workflows.
const StepName = "workflows"

// ErrNotConfigured is returned when neither TRUSTAGE_URL nor
// TRUSTAGE_SERVICE_URI is set.
var ErrNotConfigured = errors.New("TRUSTAGE_URL is not set; scheduled workflows cannot be registered")

// SyncWorkflows creates or updates every workflow definition in the image's
// workflows directory (TRUSTAGE_WORKFLOWS_DIR, default /workflows). It runs in
// the setup job only. A service whose correctness depends on its schedules
// passes required=true so a deploy without them fails instead of shipping a
// service whose periodic work never runs.
func SyncWorkflows(ctx context.Context, cfg any, required bool) error {
	trustageURL := os.Getenv("TRUSTAGE_URL")
	if trustageURL == "" {
		trustageURL = os.Getenv("TRUSTAGE_SERVICE_URI")
	}
	if trustageURL == "" {
		if required {
			return ErrNotConfigured
		}
		return nil
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
	if err = workflows.SyncFromDir(ctx, cli, dir); err != nil {
		return fmt.Errorf("sync trustage workflows from %s: %w", dir, err)
	}
	return nil
}
