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

//go:build chaos

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

// Package chaostests contains opt-in chaos drills for the limits service
// and its consumers. Build with -tags=chaos; intended for nightly CI, not
// per-PR runs. Each drill spins up dependent containers via testcontainers,
// induces a failure mode, and asserts consumer behaviour matches the spec
// (§9 operational concerns).
//
// Docker pause/unpause wiring: the pause/unpause helpers below are stubs
// that call t.Skip. To wire them into a real CI environment, inject the
// testcontainers ContainerID (stored in LimitsContainerID) and call the
// Docker daemon's pause/unpause API (e.g. via github.com/docker/docker/client).
// The field is set to an empty string here so the suite is always structurally
// correct and can be wired later without changing the drill files.
package chaostests

import (
	"context"
	"testing"
	"time"

	"github.com/pitabwire/frame/frametests"
	"github.com/pitabwire/frame/frametests/definition"
	"github.com/pitabwire/frame/frametests/deps/testpostgres"
	"github.com/stretchr/testify/suite"
)

// ChaosSuite holds the shared testcontainers infrastructure for all chaos
// drills. A Postgres instance is started to emulate the limits service's
// own database. The LimitsContainerID field is a hook for the CI environment
// to inject the running container ID so that pause/unpause helpers can
// forward calls to the Docker daemon.
type ChaosSuite struct {
	frametests.FrameBaseTestSuite

	// LimitsContainerID is the Docker container ID of the limits-service
	// postgres container. Set this in a CI environment to enable
	// PauseLimitsService / UnpauseLimitsService.
	LimitsContainerID string
}

func (s *ChaosSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

// RunChaosSuite is a convenience entry-point used by TestMain-style wrappers.
func RunChaosSuite(t *testing.T) {
	t.Helper()
	suite.Run(t, new(ChaosSuite))
}

// ---------------------------------------------------------------------------
// Fault-injection helpers
// ---------------------------------------------------------------------------

// PauseLimitsService suspends the limits-service container for d and schedules
// an automatic unpause after the duration via t.Cleanup.
//
// TODO(ci): Wire LimitsContainerID and call the Docker daemon pause API here.
// Example using github.com/docker/docker/client:
//
//	cli, _ := dockerclient.NewClientWithOpts(dockerclient.FromEnv)
//	cli.ContainerPause(ctx, s.LimitsContainerID)
//	t.Cleanup(func() { cli.ContainerUnpause(ctx, s.LimitsContainerID) })
func (s *ChaosSuite) PauseLimitsService(t *testing.T, _ time.Duration) {
	t.Helper()
	// TODO: docker pause/unpause not yet wired into frametests control client.
	// Operators: set s.LimitsContainerID and call cli.ContainerPause here.
	t.Skip("PauseLimitsService: docker pause/unpause not yet wired into frametests control client")
}

// UnpauseLimitsService resumes the limits-service container. No-op when
// PauseLimitsService was skipped.
func (s *ChaosSuite) UnpauseLimitsService(t *testing.T) {
	t.Helper()
	// No-op until wired; the t.Cleanup in PauseLimitsService handles the
	// corresponding unpause once wired.
}

// BlockLimitsToDB induces a network partition between the limits-service
// and its database for d. In a fully-wired CI environment this is
// implemented by adding an iptables rule (or tc qdisc netem) inside the
// limits-service container; the rule is cleaned up by t.Cleanup.
//
// TODO(ci): Wire container network manipulation here (e.g. via
// testcontainers Exec + iptables, or docker network disconnect/connect).
func (s *ChaosSuite) BlockLimitsToDB(t *testing.T, _ time.Duration) {
	t.Helper()
	// TODO: network partition not yet wired into frametests control client.
	// Operators: exec `iptables -A OUTPUT -p tcp --dport 5432 -j DROP`
	// inside the limits container and restore in t.Cleanup.
	t.Skip("BlockLimitsToDB: network partition not yet wired into frametests control client")
}

// UnblockLimitsToDB removes the network partition between the limits-service
// and its database. No-op when BlockLimitsToDB was skipped.
func (s *ChaosSuite) UnblockLimitsToDB(t *testing.T) {
	t.Helper()
}
