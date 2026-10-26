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
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
)

// TestNoWorkflowCallbackIsAStub fails if any callback route is parked behind a
// not-implemented response. Every URL products/stawi/workflows/*.json calls
// must be served by real business logic; a step that always fails means the
// workflow can never run to completion.
func TestNoWorkflowCallbackIsAStub(t *testing.T) {
	t.Parallel()

	// The files that define every workflow callback. The stub guard reads them
	// directly: a route that answers "not implemented" is a workflow step that
	// can never complete.
	handlerSourceFiles := []string{"workflow_callbacks.go", "workflow_lifecycle.go"}

	for _, name := range handlerSourceFiles {
		raw, err := os.ReadFile(filepath.Clean(name))
		if err != nil {
			t.Fatalf("read %s: %v", name, err)
		}
		if strings.Contains(string(raw), "not implemented") {
			t.Errorf("%s registers a not-implemented workflow callback; "+
				"implement the route or remove the step from the workflow definition", name)
		}
	}
}

// TestWorkflowVariableReadsResolveToResponseFields asserts the other half of
// the workflow contract: every `vars.<output_var>.body.<field>` a step reads
// must be a field the handler that produced <output_var> actually returns. A
// read of a field nobody emits interpolates empty and the step silently does
// the wrong thing.
func TestWorkflowVariableReadsResolveToResponseFields(t *testing.T) {
	t.Parallel()

	fieldsByRoute := routeResponseFields()
	reads := collectVariableReads(t)
	if len(reads) == 0 {
		t.Fatal("no vars.<x>.body.<field> reads found in the workflow definitions")
	}

	for _, read := range reads {
		t.Run(read.workflow+":"+read.variable+"."+read.field, func(t *testing.T) {
			t.Parallel()

			route, ok := read.route()
			if !ok {
				t.Fatalf("%s reads vars.%s.body.%s but no step declares output_var %q",
					read.workflow, read.variable, read.field, read.variable)
			}
			fields, known := fieldsByRoute[route]
			if !known {
				t.Fatalf("no response field contract recorded for route %s "+
					"(add it to routeResponseFields)", route)
			}
			if !fields[read.field] {
				t.Fatalf("%s reads vars.%s.body.%s, but %s returns no %q field",
					read.workflow, read.variable, read.field, route, read.field)
			}
		})
	}
}

// routeResponseFields is the response contract for every workflow callback
// route: the JSON keys each one emits.
//
// Handler-owned envelopes are derived from the real response builders so the
// contract cannot drift from the code. Business-owned payloads are listed
// explicitly because their builders live behind repository dependencies.
func routeResponseFields() map[string]map[string]bool {
	period := keysOf(periodResponse(&models.Period{}))
	tenure := keysOf(tenureResponse(&models.Tenure{}))

	return map[string]map[string]bool{
		"POST /api/v1/groups/{groupId}/check-formation": setOf(
			"group_id", "member_count", "min_members", "formed", "current_state", "transitioned_to",
		),
		"POST /api/v1/groups/{groupId}/create-tenure":             tenure,
		"POST /api/v1/groups/{groupId}/open-period":               period,
		"POST /api/v1/groups/{groupId}/periods/{periodId}/freeze": period,
		"POST /api/v1/groups/{groupId}/periods/{periodId}/extend": period,
		"GET /api/v1/groups/{groupId}/members":                    keysOf(membersResponse(nil)),
		"POST /api/v1/groups/{groupId}/loan-window/open":          keysOf(loanWindowResponse(&models.LoanWindow{})),

		"POST /api/v1/groups/{groupId}/evaluate-loan-window": setOf(
			"group_id", "eligible", "should_open", "window_duration",
			"window_closes_at", "cycle_position", "completed_periods",
		),
		"POST /api/v1/groups/{groupId}/loans": setOf(
			"offer_id", "amount", "currency", "membership_id",
			"loan_request_id", "loan_account_id", "loan_id", "idempotent",
		),
		"POST /api/v1/groups/{groupId}/periods/{periodId}/calculate-obligations": setOf(
			"group_id", "period_id", "obligations_created", "members_processed", "member_obligations",
			"members", "count", "total_outstanding",
		),
		"POST /api/v1/groups/{groupId}/periods/{periodId}/reconcile": setOf(
			"group_id", "period_id", "members", "count", "collected", "total_outstanding",
		),
	}
}

func keysOf(payload map[string]any) map[string]bool {
	keys := make(map[string]bool, len(payload))
	for key := range payload {
		keys[key] = true
	}
	return keys
}

func setOf(names ...string) map[string]bool {
	keys := make(map[string]bool, len(names))
	for _, name := range names {
		keys[name] = true
	}
	return keys
}
