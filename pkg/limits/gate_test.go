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

package limits_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/pkg/limits"
)

// stubLimitsClient implements limitsv1connect.LimitsServiceClient. Each
// method records its call and returns the configured response/error.
type stubLimitsClient struct {
	checkResp    *limitsv1.CheckResponse
	checkErr     error
	reserveResp  *limitsv1.ReserveResponse
	reserveErr   error
	commitResp   *limitsv1.CommitResponse
	commitErr    error
	releaseResp  *limitsv1.ReleaseResponse
	releaseErr   error
	reverseResp  *limitsv1.ReverseResponse
	reverseErr   error
	checkCalls   int
	reserveCalls int
	commitCalls  int
	releaseCalls int
	reverseCalls int
}

func (s *stubLimitsClient) Check(
	_ context.Context,
	_ *limitsv1.CheckRequest,
) (*limitsv1.CheckResponse, error) {
	s.checkCalls++
	if s.checkErr != nil {
		return nil, s.checkErr
	}
	return s.checkResp, nil
}

func (s *stubLimitsClient) Reserve(
	_ context.Context,
	_ *limitsv1.ReserveRequest,
) (*limitsv1.ReserveResponse, error) {
	s.reserveCalls++
	if s.reserveErr != nil {
		return nil, s.reserveErr
	}
	return s.reserveResp, nil
}

func (s *stubLimitsClient) Commit(
	_ context.Context,
	_ *limitsv1.CommitRequest,
) (*limitsv1.CommitResponse, error) {
	s.commitCalls++
	if s.commitErr != nil {
		return nil, s.commitErr
	}
	return s.commitResp, nil
}

func (s *stubLimitsClient) Release(
	_ context.Context,
	_ *limitsv1.ReleaseRequest,
) (*limitsv1.ReleaseResponse, error) {
	s.releaseCalls++
	if s.releaseErr != nil {
		return nil, s.releaseErr
	}
	return s.releaseResp, nil
}

func (s *stubLimitsClient) Reverse(
	_ context.Context,
	_ *limitsv1.ReverseRequest,
) (*limitsv1.ReverseResponse, error) {
	s.reverseCalls++
	if s.reverseErr != nil {
		return nil, s.reverseErr
	}
	return s.reverseResp, nil
}

// SetReleaseError configures the stub to return err on the next Release call.
func (s *stubLimitsClient) SetReleaseError(err error) {
	s.releaseErr = err
}

// ReleaseCallCount returns the number of times Release was called.
func (s *stubLimitsClient) ReleaseCallCount() int {
	return s.releaseCalls
}

// Compile-time interface check.
var _ limitsv1connect.LimitsServiceClient = (*stubLimitsClient)(nil)

func TestGate_HappyPath_CallsCommitOnSuccess(t *testing.T) {
	stub := &stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-1",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
			},
		},
		commitResp: &limitsv1.CommitResponse{
			Reservation: &limitsv1.ReservationObject{Status: limitsv1.ReservationStatus_RESERVATION_STATUS_COMMITTED},
		},
	}
	called := false
	err := limits.Gate(context.Background(), stub, &limitsv1.LimitIntent{}, "idem-1", limits.ModeEnforce,
		func(_ context.Context, reservationID string) error {
			called = true
			assert.Equal(t, "res-1", reservationID)
			return nil
		})
	require.NoError(t, err)
	assert.True(t, called, "handler must be invoked")
	assert.Equal(t, 1, stub.reserveCalls)
	assert.Equal(t, 1, stub.commitCalls)
	assert.Equal(t, 0, stub.releaseCalls)
}

func TestGate_HandlerError_CallsRelease(t *testing.T) {
	stub := &stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-1",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
			},
		},
		releaseResp: &limitsv1.ReleaseResponse{
			Reservation: &limitsv1.ReservationObject{Status: limitsv1.ReservationStatus_RESERVATION_STATUS_RELEASED},
		},
	}
	handlerErr := errors.New("local DB write failed")
	err := limits.Gate(context.Background(), stub, &limitsv1.LimitIntent{}, "idem-1", limits.ModeEnforce,
		func(_ context.Context, _ string) error {
			return handlerErr
		})
	require.ErrorIs(t, err, handlerErr)
	assert.Equal(t, 1, stub.reserveCalls)
	assert.Equal(t, 0, stub.commitCalls)
	assert.Equal(t, 1, stub.releaseCalls)
}

func TestGate_PendingApproval_ReturnsTypedError(t *testing.T) {
	verdict := &limitsv1.PolicyVerdict{
		PolicyId: "pol-1", WouldRequireApproval: true, Reason: "amount above max",
	}
	stub := &stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-1",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
			},
			Check: &limitsv1.CheckResponse{Verdicts: []*limitsv1.PolicyVerdict{verdict}},
		},
		releaseResp: &limitsv1.ReleaseResponse{
			Reservation: &limitsv1.ReservationObject{Status: limitsv1.ReservationStatus_RESERVATION_STATUS_RELEASED},
		},
	}
	called := false
	err := limits.Gate(context.Background(), stub, &limitsv1.LimitIntent{}, "idem-1", limits.ModeEnforce,
		func(_ context.Context, _ string) error {
			called = true
			return nil
		})
	require.Error(t, err)
	var pendingErr *limits.PendingApprovalError
	require.ErrorAs(t, err, &pendingErr)
	assert.Equal(t, "res-1", pendingErr.ReservationID)
	assert.Len(t, pendingErr.Verdicts, 1)
	assert.False(t, called, "handler must NOT run when reservation is pending approval")
	assert.Equal(t, 0, stub.commitCalls)
	assert.Equal(t, 0, stub.releaseCalls)
}

func TestGate_ReserveError_PropagatesAndDoesNotCallHandler(t *testing.T) {
	stub := &stubLimitsClient{reserveErr: errors.New("limits unavailable")}
	called := false
	err := limits.Gate(context.Background(), stub, &limitsv1.LimitIntent{}, "idem-1", limits.ModeEnforce,
		func(_ context.Context, _ string) error {
			called = true
			return nil
		})
	require.Error(t, err)
	assert.Contains(t, err.Error(), "limits unavailable")
	assert.False(t, called)
	assert.Equal(t, 0, stub.commitCalls)
	assert.Equal(t, 0, stub.releaseCalls)
}

func TestGate_NilClient_Errors(t *testing.T) {
	err := limits.Gate(context.Background(), nil, &limitsv1.LimitIntent{}, "idem-1", limits.ModeEnforce,
		func(_ context.Context, _ string) error { return nil })
	require.Error(t, err)
}

func TestGate_Shadow_DeniedReservation_RunsHandler(t *testing.T) {
	// Simulate an unexpected/denied reservation status (not ACTIVE, not PENDING_APPROVAL).
	stub := &stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-shadow-denied",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_UNSPECIFIED,
			},
		},
		releaseResp: &limitsv1.ReleaseResponse{
			Reservation: &limitsv1.ReservationObject{Status: limitsv1.ReservationStatus_RESERVATION_STATUS_RELEASED},
		},
	}
	called := false
	err := limits.Gate(context.Background(), stub, &limitsv1.LimitIntent{}, "idem-shadow-deny", limits.ModeShadow,
		func(_ context.Context, _ string) error {
			called = true
			return nil
		})
	require.NoError(t, err)
	assert.True(t, called, "handler must run in shadow mode despite deny")
	assert.Equal(t, 1, stub.reserveCalls)
}

func TestGate_Shadow_PendingReservation_RunsHandler(t *testing.T) {
	stub := &stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-shadow-pending",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
			},
			Check: &limitsv1.CheckResponse{Verdicts: []*limitsv1.PolicyVerdict{
				{PolicyId: "pol-shadow", WouldRequireApproval: true, Reason: "shadow test"},
			}},
		},
		releaseResp: &limitsv1.ReleaseResponse{
			Reservation: &limitsv1.ReservationObject{Status: limitsv1.ReservationStatus_RESERVATION_STATUS_RELEASED},
		},
	}
	called := false
	err := limits.Gate(context.Background(), stub, &limitsv1.LimitIntent{}, "idem-shadow-pend", limits.ModeShadow,
		func(_ context.Context, _ string) error {
			called = true
			return nil
		})
	require.NoError(t, err)
	assert.True(t, called, "handler must run in shadow mode despite pending approval")
	assert.Equal(t, 1, stub.reserveCalls)
}

func TestGate_Shadow_RPCError_RunsHandler(t *testing.T) {
	stub := &stubLimitsClient{reserveErr: errors.New("limits service down")}
	called := false
	err := limits.Gate(context.Background(), stub, &limitsv1.LimitIntent{}, "idem-shadow-err", limits.ModeShadow,
		func(_ context.Context, reservationID string) error {
			called = true
			assert.Empty(t, reservationID, "shadow RPC-error path passes empty reservationID")
			return nil
		})
	require.NoError(t, err)
	assert.True(t, called, "handler must run in shadow mode despite RPC error")
	assert.Equal(t, 1, stub.reserveCalls)
	assert.Equal(t, 0, stub.commitCalls)
	assert.Equal(t, 0, stub.releaseCalls)
}

// TestGate_HandlerError_ReleaseAlsoFails_ReturnsHandlerError exercises the
// double-failure path: handler errors AND the subsequent Release RPC also errors.
// Gate must log the Release error (swallow it) and return the original handler error.
func TestGate_HandlerError_ReleaseAlsoFails_ReturnsHandlerError(t *testing.T) {
	stub := &stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-double-fail",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
			},
		},
	}
	stub.SetReleaseError(errors.New("release rpc failed"))

	handlerErr := errors.New("handler-side failure")
	err := limits.Gate(context.Background(), stub, &limitsv1.LimitIntent{}, "key-double-fail", limits.ModeEnforce,
		func(_ context.Context, _ string) error {
			return handlerErr
		})

	require.Error(t, err)
	require.ErrorIs(t, err, handlerErr,
		"outer error must be the original handler error, not the Release error")
	assert.Equal(t, 1, stub.ReleaseCallCount(),
		"Release must still have been attempted despite expected failure")
	assert.Equal(t, 0, stub.commitCalls,
		"Commit must not be called when handler fails")
}

func TestGate_HandlerError_ClientCancel_StillReleases(t *testing.T) {
	stub := &stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-cancel-1",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
			},
		},
		releaseResp: &limitsv1.ReleaseResponse{
			Reservation: &limitsv1.ReservationObject{Status: limitsv1.ReservationStatus_RESERVATION_STATUS_RELEASED},
		},
	}

	ctx, cancel := context.WithCancel(context.Background())
	handlerErr := errors.New("simulated handler failure")

	err := limits.Gate(ctx, stub, &limitsv1.LimitIntent{}, "test-key-1", limits.ModeEnforce,
		func(_ context.Context, _ string) error {
			cancel() // simulate client cancel mid-handler
			return handlerErr
		})

	require.Error(t, err)
	require.ErrorIs(t, err, handlerErr)

	// Despite ctx being cancelled, Release was still called because Gate uses
	// context.WithoutCancel to detach the Release RPC from the original context.
	assert.Equal(t, 1, stub.reserveCalls)
	assert.Equal(t, 0, stub.commitCalls)
	assert.Equal(t, 1, stub.releaseCalls, "Release must be called even when the request context is cancelled")
}

// TestGate_CommittedReplay_IsSuccess asserts that replaying an idempotency key
// whose reservation already committed is reported as success and does not
// re-run the handler. Reserve returns the existing COMMITTED reservation on a
// replay, so any other treatment either moves the money twice (shadow) or
// reports failure for an operation that in fact succeeded (enforce).
func TestGate_CommittedReplay_IsSuccess(t *testing.T) {
	for _, mode := range []limits.Mode{limits.ModeEnforce, limits.ModeShadow} {
		stub := &stubLimitsClient{
			reserveResp: &limitsv1.ReserveResponse{
				Reservation: &limitsv1.ReservationObject{
					Id:     "res-committed",
					Status: limitsv1.ReservationStatus_RESERVATION_STATUS_COMMITTED,
				},
			},
		}
		called := false
		err := limits.Gate(context.Background(), stub, &limitsv1.LimitIntent{}, "idem-replay", mode,
			func(_ context.Context, _ string) error {
				called = true
				return nil
			})
		require.NoError(t, err)
		assert.False(t, called, "the handler must not run again for an already-committed reservation")
		assert.Equal(t, 0, stub.commitCalls)
		assert.Equal(t, 0, stub.releaseCalls)
	}
}

// TestGate_TerminalReplay_IsError asserts a released/expired/reversed
// reservation is a terminal replay: in enforce mode the caller is told to use a
// fresh key rather than silently proceeding.
func TestGate_TerminalReplay_IsError(t *testing.T) {
	for _, status := range []limitsv1.ReservationStatus{
		limitsv1.ReservationStatus_RESERVATION_STATUS_RELEASED,
		limitsv1.ReservationStatus_RESERVATION_STATUS_EXPIRED,
		limitsv1.ReservationStatus_RESERVATION_STATUS_REVERSED,
	} {
		stub := &stubLimitsClient{
			reserveResp: &limitsv1.ReserveResponse{
				Reservation: &limitsv1.ReservationObject{Id: "res-terminal", Status: status},
			},
		}
		called := false
		err := limits.Gate(context.Background(), stub, &limitsv1.LimitIntent{}, "idem-terminal", limits.ModeEnforce,
			func(_ context.Context, _ string) error {
				called = true
				return nil
			})
		require.Error(t, err, "status %s must not be treated as success", status)
		assert.False(t, called, "the handler must not run for a terminal reservation")
	}
}

// TestGate_Denied_ReturnsTypedBreachError asserts callers can tell a cap breach
// apart from an infrastructure failure.
func TestGate_Denied_ReturnsTypedBreachError(t *testing.T) {
	stub := &stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-denied",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_UNSPECIFIED,
			},
			Check: &limitsv1.CheckResponse{
				Verdicts: []*limitsv1.PolicyVerdict{{PolicyId: "pol-1", Breached: true}},
			},
		},
	}
	err := limits.Gate(context.Background(), stub, &limitsv1.LimitIntent{}, "idem-denied", limits.ModeEnforce,
		func(_ context.Context, _ string) error { return nil })

	var breached *limits.LimitBreachedError
	require.ErrorAs(t, err, &breached)
	assert.Len(t, breached.Verdicts, 1)
}

// TestGate_ModeOff_SkipsLimitsService asserts the documented emergency rollback
// actually bypasses the service rather than enforcing it.
func TestGate_ModeOff_SkipsLimitsService(t *testing.T) {
	stub := &stubLimitsClient{}
	called := false
	err := limits.Gate(context.Background(), stub, &limitsv1.LimitIntent{}, "idem-off", limits.ParseMode("off"),
		func(_ context.Context, _ string) error {
			called = true
			return nil
		})
	require.NoError(t, err)
	assert.True(t, called, "the handler must run with the gate off")
	assert.Equal(t, 0, stub.reserveCalls, "no Reserve may be issued with the gate off")
}

func TestParseMode(t *testing.T) {
	cases := map[string]limits.Mode{
		"shadow":   limits.ModeShadow,
		"SHADOW":   limits.ModeShadow,
		"Shadow\t": limits.ModeShadow,
		"off":      limits.ModeOff,
		"OFF":      limits.ModeOff,
		"disabled": limits.ModeOff,
		"enforce":  limits.ModeEnforce,
		"":         limits.ModeEnforce,
		"typo":     limits.ModeEnforce,
	}
	for in, want := range cases {
		assert.Equal(t, want, limits.ParseMode(in), "ParseMode(%q)", in)
	}
}

// TestGate_ReserveTTLFollowsDeadline asserts the reservation TTL is derived
// from the handler's own deadline. A handler slower than the service default
// would otherwise have its reservation reaped mid-flight and fail Commit after
// the money had moved.
func TestGate_ReserveTTLFollowsDeadline(t *testing.T) {
	stub := &ttlCapturingClient{stubLimitsClient: stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-ttl",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
			},
		},
		commitResp: &limitsv1.CommitResponse{Reservation: &limitsv1.ReservationObject{}},
	}}

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Minute)
	defer cancel()
	err := limits.Gate(ctx, stub, &limitsv1.LimitIntent{}, "idem-ttl", limits.ModeEnforce,
		func(_ context.Context, _ string) error { return nil })
	require.NoError(t, err)
	assert.Greater(t, stub.ttl, 20*time.Minute, "the TTL must outlast the handler deadline")
	assert.LessOrEqual(t, stub.ttl, time.Hour)
}

// ttlCapturingClient records the TTL Gate asked for.
type ttlCapturingClient struct {
	stubLimitsClient
	ttl time.Duration
}

func (s *ttlCapturingClient) Reserve(
	ctx context.Context,
	req *limitsv1.ReserveRequest,
) (*limitsv1.ReserveResponse, error) {
	s.ttl = req.GetTtl().AsDuration()
	return s.stubLimitsClient.Reserve(ctx, req)
}
