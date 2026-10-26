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

package dbmigrate_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestEveryAppShipsItsMigrations guards how SQL migrations reach the setup
// Job. Frame reads the directory from MIGRATION_PATH and skips only files
// ending in _down.sql: an image that sets another variable, or a revert file
// named .down.sql, silently applies nothing or applies the revert.
func TestEveryAppShipsItsMigrations(t *testing.T) {
	dirs, err := filepath.Glob("../../apps/*/migrations")
	require.NoError(t, err)
	require.NotEmpty(t, dirs)

	for _, dir := range dirs {
		app := filepath.Base(filepath.Dir(dir))
		t.Run(app, func(t *testing.T) {
			files, globErr := filepath.Glob(filepath.Join(dir, "*.sql"))
			require.NoError(t, globErr)
			for _, file := range files {
				name := filepath.Base(file)
				assert.True(t, strings.HasSuffix(name, "_up.sql") || strings.HasSuffix(name, "_down.sql"),
					"%s: name migrations *_up.sql / *_down.sql", name)
			}

			dockerfile, readErr := os.ReadFile(filepath.Join(filepath.Dir(dir), "Dockerfile"))
			require.NoError(t, readErr)
			assert.Contains(t, string(dockerfile), "/app/apps/"+app+"/migrations /migrations",
				"the image must carry the migrations")
			assert.Contains(t, string(dockerfile), "ENV MIGRATION_PATH=/migrations",
				"Frame reads the migration directory from MIGRATION_PATH")
		})
	}
}
