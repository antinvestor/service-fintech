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

package limits

import (
	"context"
	"errors"
	"fmt"
	"time"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/util"
)

// Mode controls how Gate reacts to deny/pending verdicts from the limits service.
type Mode int

const (
	// ModeEnforce is the default mode (zero value). A denied or pending
	// reservation blocks the operation and returns an error to the caller.
	ModeEnforce Mode = iota
	// ModeShadow logs and audits the verdict but proceeds with the operation
	// anyway. The dummy reservation is released fire-and-forget so it does
	// not accumulate in the limits service.
	ModeShadow
)

// releaseTimeout bounds the detached Release call issued after a handler error.
const releaseTimeout = 30 * time.Second

// ParseMode converts a string config value to a Mode constant.
// "shadow" → ModeShadow; everything else (including "enforce" or "") → ModeEnforce.
func ParseMode(s string) Mode {
	if s == "shadow" {
		return ModeShadow
	}
	return ModeEnforce
}

// Architecture note: Gate calls Commit and Release synchronously via
// Connect RPC. An earlier design proposed a transactional outbox to
// bridge handler-success → Commit so the consumer would not have to
// retry on Commit RPC failure. That design was deliberately rejected
// (see docs/superpowers/plans/2026-05-06-limits-prod-readiness.md
// Phase 1). The synchronous path with idempotent Commit + the limits
// service's TTL-based reservation expiry is sufficient: a failed Commit
// after handler-success leaves a reservation that TTL-expires (default
// 5 min); cap math reverts on the next Reserve as if the operation
// never happened. Drift is in the audit/ledger sense (handled by the
// audit pipeline), not in cap enforcement.

// Gate runs the standard Reserve → handler → Commit/Release lifecycle
// against the supplied limits Connect client. The handler is invoked
// only when the reservation is ACTIVE; PENDING_APPROVAL and Reserve
// errors short-circuit before the handler runs (in ModeEnforce).
//
// Behaviour (ModeEnforce, the default):
//   - Reserve error  → Gate returns the error verbatim. Handler is NOT called.
//   - PENDING_APPROVAL → Gate returns *PendingApprovalError. Handler is NOT called.
//     Caller is expected to persist a local pending row and
//     resume via the limits.approval.* event when approval lands.
//   - ACTIVE → handler is invoked.
//   - Handler success → Gate calls Commit synchronously, returns nil
//     (or returns the Commit error if it fails;
//     reconciliation closes the gap).
//   - Handler error → Gate calls Release synchronously and returns the
//     handler's error. Release errors are logged.
//
// Behaviour (ModeShadow):
//   - Reserve RPC error → logs shadow_outcome=rpc_error, runs handler with empty reservationID.
//   - DENY (unexpected status) → logs shadow_outcome=would_block, fire-and-forget Release, runs handler.
//   - PENDING_APPROVAL → logs shadow_outcome=would_pend, fire-and-forget Release, runs handler.
//   - ACTIVE → unchanged from ModeEnforce.
func Gate(
	ctx context.Context,
	rpc limitsv1connect.LimitsServiceClient,
	intent *limitsv1.LimitIntent,
	idempotencyKey string,
	mode Mode,
	handler func(ctx context.Context, reservationID string) error,
) error {
	if rpc == nil {
		return errors.New("limits.Gate: nil rpc client")
	}
	if handler == nil {
		return errors.New("limits.Gate: nil handler")
	}

	res, err := rpc.Reserve(ctx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent:         intent,
		IdempotencyKey: idempotencyKey,
	}))
	if err != nil {
		if mode == ModeShadow {
			util.Log(ctx).WithError(err).
				With("shadow_outcome", "rpc_error").
				With("idempotency_key", idempotencyKey).
				Warn("limits.Gate: shadow mode — Reserve RPC error, proceeding with operation")
			return handler(ctx, "")
		}
		return err
	}

	reservation := res.Msg.GetReservation()
	if reservation == nil {
		return errors.New("limits.Gate: Reserve returned no reservation")
	}

	//nolint:exhaustive // only PENDING_APPROVAL diverts the flow; every other status proceeds to the handler
	switch reservation.GetStatus() {
	case limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL:
		if mode == ModeShadow {
			util.Log(ctx).
				With("shadow_outcome", "would_pend").
				With("reservation_id", reservation.GetId()).
				With("idempotency_key", idempotencyKey).
				Warn("limits.Gate: shadow mode — reservation PENDING_APPROVAL, proceeding with operation")
			go shadowRelease(ctx, rpc, reservation.GetId(), "shadow_mode_would_pend")
			return handler(ctx, "")
		}
		var verdicts []*limitsv1.PolicyVerdict
		if check := res.Msg.GetCheck(); check != nil {
			verdicts = check.GetVerdicts()
		}
		return &PendingApprovalError{ReservationID: reservation.GetId(), Verdicts: verdicts}
	case limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE:
		// Continue below.
	default:
		if mode == ModeShadow {
			util.Log(ctx).
				With("shadow_outcome", "would_block").
				With("reservation_id", reservation.GetId()).
				With("reservation_status", reservation.GetStatus().String()).
				With("idempotency_key", idempotencyKey).
				Warn("limits.Gate: shadow mode — reservation denied, proceeding with operation")
			go shadowRelease(ctx, rpc, reservation.GetId(), "shadow_mode_would_block")
			return handler(ctx, "")
		}
		return fmt.Errorf("limits.Gate: unexpected reservation status %s", reservation.GetStatus())
	}

	if handlerErr := handler(ctx, reservation.GetId()); handlerErr != nil {
		// Use a detached context so a client-side cancellation (timeout/disconnect)
		// does not prevent Release from reaching the limits service. Without this,
		// ctx.Err() != nil causes the RPC to fail immediately and the reservation
		// would hold cap-space for the full TTL (default 5 min).
		relCtx, relCancel := context.WithTimeout(context.WithoutCancel(ctx), releaseTimeout)
		defer relCancel()
		if _, relErr := rpc.Release(relCtx, connect.NewRequest(&limitsv1.ReleaseRequest{
			ReservationId: reservation.GetId(),
			Reason:        "handler_error",
		})); relErr != nil {
			util.Log(ctx).WithError(relErr).
				With("reservation_id", reservation.GetId()).
				Error("limits release after handler error failed")
		}
		return handlerErr
	}

	if _, commitErr := rpc.Commit(ctx, connect.NewRequest(&limitsv1.CommitRequest{
		ReservationId: reservation.GetId(),
	})); commitErr != nil {
		util.Log(ctx).WithError(commitErr).
			With("reservation_id", reservation.GetId()).
			Error("limits.Gate: Commit failed after handler success — reconciliation gap")
		return commitErr
	}
	return nil
}

// shadowRelease issues a fire-and-forget Release for reservations created in
// shadow mode that would have blocked in enforce mode. Uses a detached context
// so the originating request's cancellation does not abort the release.
func shadowRelease(ctx context.Context, rpc limitsv1connect.LimitsServiceClient, reservationID, reason string) {
	releaseCtx := context.WithoutCancel(ctx)
	if _, releaseErr := rpc.Release(releaseCtx, connect.NewRequest(&limitsv1.ReleaseRequest{
		ReservationId: reservationID,
		Reason:        reason,
	})); releaseErr != nil {
		util.Log(ctx).WithError(releaseErr).
			With("reservation_id", reservationID).
			Warn("limits.Gate: shadow Release failed; reservation will expire via TTL")
	}
}
