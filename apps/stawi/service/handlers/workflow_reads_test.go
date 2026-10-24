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
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
)

// workflowDefinitionsDir is the product's workflow definition directory,
// relative to this package.
const workflowDefinitionsDir = "../../../../products/stawi/workflows"

var (
	// interpolation matches a Trustage template such as {{ payload.group_id }}.
	interpolation = regexp.MustCompile(`\{\{[^}]*\}\}`)
	// variableRead matches a read of a call's JSON response body.
	variableRead = regexp.MustCompile(`vars\.([A-Za-z0-9_]+)\.body\.([A-Za-z0-9_]+)`)
)

// variableRead is one `vars.<variable>.body.<field>` read, together with the
// route that produced the variable in the same workflow.
type bodyRead struct {
	workflow   string
	variable   string
	field      string
	routeByVar map[string]string
}

// route resolves the mux pattern of the step that declared this read's
// output_var.
func (r bodyRead) route() (string, bool) {
	pattern, ok := r.routeByVar[r.variable]
	return pattern, ok
}

// collectVariableReads walks every workflow definition and pairs each body read
// with the registered route whose response the variable holds.
func collectVariableReads(t *testing.T) []bodyRead {
	t.Helper()

	mux := http.NewServeMux()
	RegisterWorkflowCallbacks(mux, Businesses{})

	entries, err := os.ReadDir(workflowDefinitionsDir)
	if err != nil {
		t.Fatalf("read workflows dir: %v", err)
	}

	var reads []bodyRead
	for _, entry := range entries {
		if entry.IsDir() || filepath.Ext(entry.Name()) != ".json" {
			continue
		}
		raw, readErr := os.ReadFile(filepath.Join(workflowDefinitionsDir, entry.Name()))
		if readErr != nil {
			t.Fatalf("read %s: %v", entry.Name(), readErr)
		}

		var doc any
		if unmarshalErr := json.Unmarshal(raw, &doc); unmarshalErr != nil {
			t.Fatalf("parse %s: %v", entry.Name(), unmarshalErr)
		}

		routeByVar := map[string]string{}
		collectOutputVarRoutes(t, mux, doc, routeByVar)

		seen := map[string]bool{}
		for _, match := range variableRead.FindAllStringSubmatch(string(raw), -1) {
			key := match[1] + "." + match[2]
			if seen[key] {
				continue
			}
			seen[key] = true
			reads = append(reads, bodyRead{
				workflow:   entry.Name(),
				variable:   match[1],
				field:      match[2],
				routeByVar: routeByVar,
			})
		}
	}
	return reads
}

// collectOutputVarRoutes records, per workflow, which registered route fills
// each output_var.
func collectOutputVarRoutes(t *testing.T, mux *http.ServeMux, node any, out map[string]string) {
	t.Helper()

	switch typed := node.(type) {
	case map[string]any:
		outputVar, hasVar := typed["output_var"].(string)
		input, hasInput := typed["input"].(map[string]any)
		if hasVar && hasInput {
			if pattern, ok := routePatternFor(mux, input); ok {
				out[outputVar] = pattern
			}
		}
		for _, value := range typed {
			collectOutputVarRoutes(t, mux, value, out)
		}
	case []any:
		for _, value := range typed {
			collectOutputVarRoutes(t, mux, value, out)
		}
	}
}

// routePatternFor resolves a workflow call's URL template and method against
// the registered mux.
func routePatternFor(mux *http.ServeMux, input map[string]any) (string, bool) {
	rawURL, hasURL := input["url"].(string)
	method, hasMethod := input["method"].(string)
	if !hasURL || !hasMethod {
		return "", false
	}

	resolved := interpolation.ReplaceAllString(rawURL, "x")
	idx := strings.Index(resolved, "/api/")
	if idx < 0 {
		return "", false
	}

	_, pattern := mux.Handler(httptest.NewRequest(strings.ToUpper(method), resolved[idx:], nil))
	if pattern == "" {
		return "", false
	}
	return pattern, true
}
