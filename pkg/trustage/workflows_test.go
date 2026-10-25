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

package trustage_test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/antinvestor/service-trustage/dsl"
	"github.com/stretchr/testify/require"
)

// Every loans workflow must pass trustage's own validation: a schedule that
// fails to register is periodic work that never runs, and the loans setup job
// refuses to deploy without them. (The stawi definitions predate the current
// DSL and are rewritten separately.)
func TestShippedWorkflowsValidate(t *testing.T) {
	files, err := filepath.Glob("../../products/loans/workflows/*.json")
	require.NoError(t, err)
	require.NotEmpty(t, files)
	for _, f := range files {
		t.Run(filepath.Base(f), func(t *testing.T) {
			raw, readErr := os.ReadFile(f)
			require.NoError(t, readErr)
			spec, parseErr := dsl.Parse(raw)
			require.NoError(t, parseErr)
			result := dsl.Validate(spec)
			require.Empty(t, result.Errors, "%v", result.Errors)
		})
	}
}
