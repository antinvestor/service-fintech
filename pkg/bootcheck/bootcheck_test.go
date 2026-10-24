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

package bootcheck_test

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/pkg/bootcheck"
)

type fakeConfig struct {
	secure    bool
	pushAuth  string
	queueURL  string
	migration string
}

func (f fakeConfig) IsRunSecurely() bool              { return f.secure }
func (f fakeConfig) GetQueuePushAuth() string         { return f.pushAuth }
func (f fakeConfig) GetEventsQueueURL() string        { return f.queueURL }
func (f fakeConfig) GetDatabaseMigrationPath() string { return f.migration }

func safe() fakeConfig {
	return fakeConfig{
		secure: true, pushAuth: "oidc", queueURL: "nats://broker:4222?subject=x", migration: "/migrations",
	}
}

// with returns a deployment-safe config with one field changed.
func with(mutate func(*fakeConfig)) fakeConfig {
	c := safe()
	mutate(&c)
	return c
}

func TestViolations_Matrix(t *testing.T) {
	cases := []struct {
		name string
		cfg  fakeConfig
		want []string
	}{
		{name: "deployment safe", cfg: safe(), want: nil},
		{name: "bearer push auth is accepted", cfg: with(func(c *fakeConfig) { c.pushAuth = "bearer" })},
		{name: "push auth case insensitive", cfg: with(func(c *fakeConfig) { c.pushAuth = " OIDC " })},
		{name: "push auth none", cfg: with(func(c *fakeConfig) { c.pushAuth = "none" }),
			want: []string{`FRAME_QUEUE_PUSH_AUTH must be oidc or bearer, got "none"`}},
		{name: "push auth empty", cfg: with(func(c *fakeConfig) { c.pushAuth = "" }),
			want: []string{`FRAME_QUEUE_PUSH_AUTH must be oidc or bearer, got ""`}},
		{name: "mem queue", cfg: with(func(c *fakeConfig) { c.queueURL = "mem://frame.events.internal_._queue" }),
			want: []string{
				`EVENTS_QUEUE_URL must point at a durable broker, got "mem://frame.events.internal_._queue"`,
			}},
		{name: "empty queue", cfg: with(func(c *fakeConfig) { c.queueURL = "" }),
			want: []string{`EVENTS_QUEUE_URL must point at a durable broker, got ""`}},
		{name: "missing migration path", cfg: with(func(c *fakeConfig) { c.migration = "  " }),
			want: []string{"MIGRATION_PATH must be set"}},
		{name: "insecure flag alone", cfg: with(func(c *fakeConfig) { c.secure = false }),
			want: []string{"RUN_SERVICE_SECURELY must be true"}},
		{name: "frame defaults report everything at once",
			cfg: fakeConfig{secure: true, pushAuth: "none", queueURL: "mem://q", migration: ""},
			want: []string{
				`FRAME_QUEUE_PUSH_AUTH must be oidc or bearer, got "none"`,
				`EVENTS_QUEUE_URL must point at a durable broker, got "mem://q"`,
				"MIGRATION_PATH must be set",
			}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			require.Equal(t, tc.want, bootcheck.Violations(tc.cfg))
		})
	}
}

func TestValidate(t *testing.T) {
	t.Run("safe secure config starts", func(t *testing.T) {
		require.NoError(t, bootcheck.Validate(t.Context(), safe()))
	})

	t.Run("secure config refuses with every violation listed", func(t *testing.T) {
		cfg := fakeConfig{secure: true, pushAuth: "none", queueURL: "mem://q", migration: ""}
		err := bootcheck.Validate(t.Context(), cfg)
		require.ErrorIs(t, err, bootcheck.ErrUnsafeEnvironment)
		require.Contains(t, err.Error(), "FRAME_QUEUE_PUSH_AUTH")
		require.Contains(t, err.Error(), "EVENTS_QUEUE_URL")
		require.Contains(t, err.Error(), "MIGRATION_PATH")
	})

	t.Run("insecure config only warns", func(t *testing.T) {
		cfg := fakeConfig{secure: false, pushAuth: "none", queueURL: "mem://q", migration: ""}
		require.NoError(t, bootcheck.Validate(t.Context(), cfg))
	})
}

// setupConfig is a fakeConfig that frame reports as a setup Job.
type setupConfig struct{ fakeConfig }

func (setupConfig) IsSetupMode() bool                   { return true }
func (setupConfig) GetSetupTasks() []string             { return nil }
func (setupConfig) GetPermissionsRegisterOnStart() bool { return false }

// TestViolations_SetupJobSkipsQueueRules: a setup Job is given an in-memory
// queue and no push auth on purpose (it never consumes events), so only the
// rules it can break still apply.
func TestViolations_SetupJobSkipsQueueRules(t *testing.T) {
	job := setupConfig{with(func(c *fakeConfig) {
		c.pushAuth = "none"
		c.queueURL = "mem://frame.events.migrate"
	})}
	require.Empty(t, bootcheck.Violations(job))
	require.NoError(t, bootcheck.Validate(t.Context(), job))

	job.migration = ""
	require.Equal(t, []string{"MIGRATION_PATH must be set"}, bootcheck.Violations(job))

	serving := with(func(c *fakeConfig) { c.queueURL = "mem://frame.events.migrate" })
	require.Error(t, bootcheck.Validate(t.Context(), serving), "the serving process still refuses an in-memory queue")
}
