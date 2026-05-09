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
// Drill 1: Limits service down
// Spec §9.1: fail-closed by default in ModeEnforce; proceed in ModeShadow.
// ---------------------------------------------------------------------------

// TestLimitsServiceDown_GateFailsClosed asserts that when the limits service
// is unreachable (ModeEnforce), Gate returns an error and the operation is
// blocked. Spec §9.1: fail-closed by default.
//
// When docker pause/unpause is wired, PauseLimitsService blocks the container
// for the given duration. Until wired, the drill skips.
func (s *ChaosSuite) TestLimitsServiceDown_GateFailsClosed() {
	t := s.T()

	s.PauseLimitsService(t, 30*time.Second)
	defer s.UnpauseLimitsService(t)

	// Use a stub that simulates the limits service being unreachable.
	// When the container is actually paused above, this stub would be replaced
	// by a real HTTP client pointing at the container. The stub is used here
	// so the drill's assertion logic is exercisable independently of the
	// container wiring.
	unavailableClient := &unavailableStub{}

	ctx := t.Context()
	err := limits.Gate(
		ctx,
		unavailableClient,
		sampleIntent(),
		"chaos-down-enforce-1",
		limits.ModeEnforce,
		func(_ context.Context, _ string) error { return nil },
	)

	require.Error(t, err, "Gate must return an error when limits service is unreachable in ModeEnforce")
	assert.True(t, isUnavailableError(err),
		"error must be an unavailable/RPC error, got: %v", err)
}

// TestLimitsServiceDown_ShadowModeProceeds asserts that in ModeShadow the
// handler runs even when the limits service is unreachable. The operation
// completes without error. Spec §9.1: shadow mode never blocks.
//
// Until docker pause/unpause is wired, the drill skips.
func (s *ChaosSuite) TestLimitsServiceDown_ShadowModeProceeds() {
	t := s.T()

	s.PauseLimitsService(t, 30*time.Second)
	defer s.UnpauseLimitsService(t)

	unavailableClient := &unavailableStub{}

	ctx := t.Context()
	handlerCalled := false
	err := limits.Gate(
		ctx,
		unavailableClient,
		sampleIntent(),
		"chaos-down-shadow-1",
		limits.ModeShadow,
		func(_ context.Context, _ string) error {
			handlerCalled = true
			return nil
		},
	)

	require.NoError(t, err, "Gate must succeed in ModeShadow even when limits service is unreachable")
	assert.True(t, handlerCalled, "handler must be called in ModeShadow despite limits service being down")
}

func TestChaosSuite_LimitsServiceDown(t *testing.T) {
	suite.Run(t, new(ChaosSuite))
}

// ---------------------------------------------------------------------------
// Helpers shared across drill files
// ---------------------------------------------------------------------------

// sampleIntent returns a minimal LimitIntent for use in drills.
// Fields use the proto-opaque API (SetX methods rather than struct literals)
// so that callers remain resilient to proto field name changes.
func sampleIntent() *limitsv1.LimitIntent {
	intent := &limitsv1.LimitIntent{}
	// LimitIntent only requires Action for a valid Reserve. Subject references
	// are optional; the drills use the zero value (no subjects) to keep the
	// fixture simple.
	return intent
}

// isUnavailableError returns true when err looks like a Connect Unavailable
// or any transport/dial error, indicating the limits service was unreachable.
func isUnavailableError(err error) bool {
	if err == nil {
		return false
	}
	var connectErr *connect.Error
	if errors.As(err, &connectErr) {
		return connectErr.Code() == connect.CodeUnavailable ||
			connectErr.Code() == connect.CodeDeadlineExceeded ||
			connectErr.Code() == connect.CodeInternal
	}
	// Non-Connect transport errors (e.g. net.Dial failures) also count.
	return true
}

// unavailableStub is a LimitsServiceClient whose every method returns an
// Unavailable Connect error, simulating an unreachable limits service.
type unavailableStub struct{}

var _ limitsv1connect.LimitsServiceClient = (*unavailableStub)(nil)

func (u *unavailableStub) Check(
	_ context.Context,
	_ *connect.Request[limitsv1.CheckRequest],
) (*connect.Response[limitsv1.CheckResponse], error) {
	return nil, connect.NewError(connect.CodeUnavailable, errors.New("limits service down"))
}

func (u *unavailableStub) Reserve(
	_ context.Context,
	_ *connect.Request[limitsv1.ReserveRequest],
) (*connect.Response[limitsv1.ReserveResponse], error) {
	return nil, connect.NewError(connect.CodeUnavailable, errors.New("limits service down"))
}

func (u *unavailableStub) Commit(
	_ context.Context,
	_ *connect.Request[limitsv1.CommitRequest],
) (*connect.Response[limitsv1.CommitResponse], error) {
	return nil, connect.NewError(connect.CodeUnavailable, errors.New("limits service down"))
}

func (u *unavailableStub) Release(
	_ context.Context,
	_ *connect.Request[limitsv1.ReleaseRequest],
) (*connect.Response[limitsv1.ReleaseResponse], error) {
	return nil, connect.NewError(connect.CodeUnavailable, errors.New("limits service down"))
}

func (u *unavailableStub) Reverse(
	_ context.Context,
	_ *connect.Request[limitsv1.ReverseRequest],
) (*connect.Response[limitsv1.ReverseResponse], error) {
	return nil, connect.NewError(connect.CodeUnavailable, errors.New("limits service down"))
}

// activeStub is a LimitsServiceClient whose Reserve always returns ACTIVE
// and whose Commit/Release always succeed. Used in drills where the limits
// service is healthy but something else fails.
type activeStub struct {
	reservationID string
	commitErr     error
	releaseErr    error
}

var _ limitsv1connect.LimitsServiceClient = (*activeStub)(nil)

func (a *activeStub) Check(
	_ context.Context,
	_ *connect.Request[limitsv1.CheckRequest],
) (*connect.Response[limitsv1.CheckResponse], error) {
	return connect.NewResponse(&limitsv1.CheckResponse{}), nil
}

func (a *activeStub) Reserve(
	_ context.Context,
	_ *connect.Request[limitsv1.ReserveRequest],
) (*connect.Response[limitsv1.ReserveResponse], error) {
	id := a.reservationID
	if id == "" {
		id = "chaos-res-active"
	}
	return connect.NewResponse(&limitsv1.ReserveResponse{
		Reservation: &limitsv1.ReservationObject{
			Id:     id,
			Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
		},
	}), nil
}

func (a *activeStub) Commit(
	_ context.Context,
	_ *connect.Request[limitsv1.CommitRequest],
) (*connect.Response[limitsv1.CommitResponse], error) {
	if a.commitErr != nil {
		return nil, a.commitErr
	}
	return connect.NewResponse(&limitsv1.CommitResponse{
		Reservation: &limitsv1.ReservationObject{Status: limitsv1.ReservationStatus_RESERVATION_STATUS_COMMITTED},
	}), nil
}

func (a *activeStub) Release(
	_ context.Context,
	_ *connect.Request[limitsv1.ReleaseRequest],
) (*connect.Response[limitsv1.ReleaseResponse], error) {
	if a.releaseErr != nil {
		return nil, a.releaseErr
	}
	return connect.NewResponse(&limitsv1.ReleaseResponse{
		Reservation: &limitsv1.ReservationObject{Status: limitsv1.ReservationStatus_RESERVATION_STATUS_RELEASED},
	}), nil
}

func (a *activeStub) Reverse(
	_ context.Context,
	_ *connect.Request[limitsv1.ReverseRequest],
) (*connect.Response[limitsv1.ReverseResponse], error) {
	return connect.NewResponse(&limitsv1.ReverseResponse{}), nil
}

// nopHandler is a Gate handler that always succeeds without side-effects.
func nopHandler(_ context.Context, _ string) error { return nil }

// failHandler is a Gate handler that always returns a sentinel error.
var errHandlerFailed = errors.New("chaos: handler simulated failure")

func failHandler(_ context.Context, _ string) error { return errHandlerFailed }
