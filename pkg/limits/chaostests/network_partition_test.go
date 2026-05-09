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

package chaostests

import (
	"context"
	"errors"
	"testing"
	"time"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-fintech/pkg/limits"
)

// ---------------------------------------------------------------------------
// Drill 4: Partial network partition
// Spec §9.3: when the limits service cannot reach its own DB, it returns
// Unavailable. The consumer fails closed in ModeEnforce; no half-applied
// state exists because the limits service rolls back the Reserve attempt.
// ---------------------------------------------------------------------------

// TestNetworkPartition_LimitsCannotReachDB asserts that when the limits
// service's database is blocked (partial partition: consumer can reach limits,
// but limits cannot reach its DB), Gate returns an Unavailable error and the
// operation is blocked. No half-applied state should exist.
//
// Until BlockLimitsToDB/UnblockLimitsToDB is wired, the drill skips.
func (s *ChaosSuite) TestNetworkPartition_LimitsCannotReachDB() {
	t := s.T()

	s.BlockLimitsToDB(t, 30*time.Second)
	defer s.UnblockLimitsToDB(t)

	// When wired, the real limits HTTP client would be used here.
	// The partitionedStub simulates the limits service returning Unavailable
	// because its own DB is unreachable.
	partitioned := &partitionedLimitsStub{}

	ctx := t.Context()
	handlerCalled := false
	err := limits.Gate(
		ctx,
		partitioned,
		sampleIntent(),
		"chaos-partition-1",
		limits.ModeEnforce,
		func(_ context.Context, _ string) error {
			handlerCalled = true
			return nil
		},
	)

	require.Error(t, err, "Gate must return an error when limits service DB is partitioned")
	assert.True(t, isUnavailableError(err),
		"error must indicate unavailability, got: %v", err)
	assert.False(t, handlerCalled,
		"handler must NOT be called when limits service returns Unavailable")
}

// TestNetworkPartition_ShadowModeProceeds asserts that in ModeShadow the
// handler runs even when the limits service reports a DB partition. The
// operation completes without error; no half-applied state is introduced
// because the handler is the sole unit of work.
//
// Until BlockLimitsToDB/UnblockLimitsToDB is wired, the drill skips.
func (s *ChaosSuite) TestNetworkPartition_ShadowModeProceeds() {
	t := s.T()

	s.BlockLimitsToDB(t, 30*time.Second)
	defer s.UnblockLimitsToDB(t)

	partitioned := &partitionedLimitsStub{}

	ctx := t.Context()
	handlerCalled := false
	err := limits.Gate(
		ctx,
		partitioned,
		sampleIntent(),
		"chaos-partition-shadow-1",
		limits.ModeShadow,
		func(_ context.Context, _ string) error {
			handlerCalled = true
			return nil
		},
	)

	require.NoError(t, err, "Gate must succeed in ModeShadow even during partial partition")
	assert.True(t, handlerCalled, "handler must be called in ModeShadow despite partition")
}

// TestNetworkPartition_NoHalfAppliedState is a documentation drill asserting
// that a partial partition leaves no persistent half-applied state in either
// the limits service or the consumer. A Reserve that fails at the limits
// service DB layer is rolled back by the limits service itself; the consumer
// never receives a reservation ID and therefore the handler is never invoked.
//
// This is a static invariant test: it documents the expected behaviour using
// the stub, not a running service. The invariant holds if Gate's error path
// skips the handler (verified in TestNetworkPartition_LimitsCannotReachDB).
func (s *ChaosSuite) TestNetworkPartition_NoHalfAppliedState() {
	t := s.T()

	partitioned := &partitionedLimitsStub{}

	ctx := t.Context()
	handlerInvoked := false

	_ = limits.Gate(
		ctx,
		partitioned,
		sampleIntent(),
		"chaos-partition-invariant-1",
		limits.ModeEnforce,
		func(_ context.Context, _ string) error {
			// The handler must NOT be called when Reserve fails.
			handlerInvoked = true
			return nil
		},
	)

	assert.False(t, handlerInvoked,
		"handler must not be invoked when Reserve fails due to partition")
}

func TestChaosSuite_NetworkPartition(t *testing.T) {
	suite.Run(t, new(ChaosSuite))
}

// ---------------------------------------------------------------------------
// Helpers local to this drill file
// ---------------------------------------------------------------------------

// partitionedLimitsStub simulates a limits service whose own database is
// unreachable. All mutating RPCs (Reserve, Commit, Release) return
// Unavailable. The stub represents what a real limits service would return
// when it cannot complete a DB transaction due to a network partition.
type partitionedLimitsStub struct{}

var _ limitsv1connect.LimitsServiceClient = (*partitionedLimitsStub)(nil)

func (p *partitionedLimitsStub) Check(
	_ context.Context,
	_ *connect.Request[limitsv1.CheckRequest],
) (*connect.Response[limitsv1.CheckResponse], error) {
	return nil, connect.NewError(connect.CodeUnavailable, errors.New("limits DB partitioned"))
}

func (p *partitionedLimitsStub) Reserve(
	_ context.Context,
	_ *connect.Request[limitsv1.ReserveRequest],
) (*connect.Response[limitsv1.ReserveResponse], error) {
	return nil, connect.NewError(connect.CodeUnavailable, errors.New("limits DB partitioned: Reserve failed"))
}

func (p *partitionedLimitsStub) Commit(
	_ context.Context,
	_ *connect.Request[limitsv1.CommitRequest],
) (*connect.Response[limitsv1.CommitResponse], error) {
	return nil, connect.NewError(connect.CodeUnavailable, errors.New("limits DB partitioned"))
}

func (p *partitionedLimitsStub) Release(
	_ context.Context,
	_ *connect.Request[limitsv1.ReleaseRequest],
) (*connect.Response[limitsv1.ReleaseResponse], error) {
	return nil, connect.NewError(connect.CodeUnavailable, errors.New("limits DB partitioned"))
}

func (p *partitionedLimitsStub) Reverse(
	_ context.Context,
	_ *connect.Request[limitsv1.ReverseRequest],
) (*connect.Response[limitsv1.ReverseResponse], error) {
	return nil, connect.NewError(connect.CodeUnavailable, errors.New("limits DB partitioned"))
}
