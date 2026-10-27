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

// Every shipped workflow must pass trustage's own validation: a schedule that
// fails to register is periodic work that never runs, and the setup jobs
// refuse to deploy without them.
func TestShippedWorkflowsValidate(t *testing.T) {
	var files []string
	for _, dir := range []string{"loans", "operations", "limits", "savings", "stawi"} {
		found, err := filepath.Glob("../../products/" + dir + "/workflows/*.json")
		require.NoError(t, err)
		require.NotEmpty(t, found, dir)
		files = append(files, found...)
	}
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
