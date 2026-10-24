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
	"strings"
	"time"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/types/known/durationpb"
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
	// ModeOff skips the limits service entirely and runs the handler. This is
	// the coldest rollback lever documented in docs/runbook/limits-rollout.md.
	ModeOff
)

const (
	// releaseTimeout bounds the detached Release call issued after a handler error.
	releaseTimeout = 30 * time.Second
	// defaultGateTTL applies when the caller's context carries no deadline.
	defaultGateTTL = 5 * time.Minute
	// minGateTTL keeps a very short handler deadline from producing a
	// reservation the reaper expires before Commit lands.
	minGateTTL = 30 * time.Second
	// maxGateTTL mirrors the limits service's own server-side ceiling.
	maxGateTTL = time.Hour
)

// reserveTTLFor derives the reservation TTL from the handler's own deadline so
// a slow handler cannot have its reservation reaped mid-flight — the Commit
// would then fail after the money had already moved.
func reserveTTLFor(ctx context.Context) time.Duration {
	ttl := defaultGateTTL
	if deadline, ok := ctx.Deadline(); ok {
		// Leave headroom for the Commit round-trip after the handler returns.
		ttl = time.Until(deadline) + releaseTimeout
	}
	if ttl < minGateTTL {
		return minGateTTL
	}
	if ttl > maxGateTTL {
		return maxGateTTL
	}
	return ttl
}

// ParseMode converts a string config value to a Mode constant, case- and
// whitespace-insensitively. "shadow" → ModeShadow, "off"/"disabled" → ModeOff,
// everything else (including "enforce" and "") → ModeEnforce.
//
// "off" must map to ModeOff and not to full enforcement: the rollout runbook
// names it as the emergency rollback, and a helper that did the opposite of
// the documented lever is worse than no lever at all.
func ParseMode(s string) Mode {
	switch strings.ToLower(strings.TrimSpace(s)) {
	case "shadow":
		return ModeShadow
	case "off", "disabled", "none":
		return ModeOff
	default:
		return ModeEnforce
	}
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
//
//nolint:funlen // the reservation status matrix is one auditable switch
func Gate(
	ctx context.Context,
	rpc limitsv1connect.LimitsServiceClient,
	intent *limitsv1.LimitIntent,
	idempotencyKey string,
	mode Mode,
	handler func(ctx context.Context, reservationID string) error,
	opts ...GateOption,
) error {
	if rpc == nil {
		return errors.New("limits.Gate: nil rpc client")
	}
	if handler == nil {
		return errors.New("limits.Gate: nil handler")
	}
	if mode == ModeOff {
		return handler(ctx, "")
	}
	// The limits RPCs run in the partition that owns the record; the handler
	// keeps the caller's own tenancy.
	limitsCtx := applyGateOptions(ctx, opts)

	res, err := rpc.Reserve(limitsCtx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent:         intent,
		IdempotencyKey: idempotencyKey,
		Ttl:            durationpb.New(reserveTTLFor(ctx)),
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

	//nolint:exhaustive // the remaining statuses are handled by the default arm
	switch reservation.GetStatus() {
	case limitsv1.ReservationStatus_RESERVATION_STATUS_COMMITTED:
		// A replay of an idempotency key whose operation already completed.
		// The work is done; re-running the handler would move money twice.
		util.Log(ctx).
			With("reservation_id", reservation.GetId()).
			With("idempotency_key", idempotencyKey).
			Info("limits.Gate: reservation already committed; treating replay as success")
		return nil
	case limitsv1.ReservationStatus_RESERVATION_STATUS_RELEASED,
		limitsv1.ReservationStatus_RESERVATION_STATUS_EXPIRED,
		limitsv1.ReservationStatus_RESERVATION_STATUS_REVERSED:
		if mode == ModeShadow {
			util.Log(ctx).
				With("shadow_outcome", "terminal_replay").
				With("reservation_id", reservation.GetId()).
				With("reservation_status", reservation.GetStatus().String()).
				Warn("limits.Gate: shadow mode — terminal reservation replay, proceeding with operation")
			return handler(ctx, "")
		}
		return fmt.Errorf("limits.Gate: reservation %s is terminal (%s); use a fresh idempotency key",
			reservation.GetId(), reservation.GetStatus())
	case limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL:
		if mode == ModeShadow {
			util.Log(ctx).
				With("shadow_outcome", "would_pend").
				With("reservation_id", reservation.GetId()).
				With("idempotency_key", idempotencyKey).
				Warn("limits.Gate: shadow mode — reservation PENDING_APPROVAL, proceeding with operation")
			go shadowRelease(limitsCtx, rpc, reservation.GetId(), "shadow_mode_would_pend")
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
			go shadowRelease(limitsCtx, rpc, reservation.GetId(), "shadow_mode_would_block")
			return handler(ctx, "")
		}
		return &LimitBreachedError{Verdicts: res.Msg.GetCheck().GetVerdicts()}
	}

	if handlerErr := handler(ctx, reservation.GetId()); handlerErr != nil {
		// Use a detached context so a client-side cancellation (timeout/disconnect)
		// does not prevent Release from reaching the limits service. Without this,
		// ctx.Err() != nil causes the RPC to fail immediately and the reservation
		// would hold cap-space for the full TTL (default 5 min).
		relCtx, relCancel := context.WithTimeout(context.WithoutCancel(limitsCtx), releaseTimeout)
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

	if _, commitErr := rpc.Commit(limitsCtx, connect.NewRequest(&limitsv1.CommitRequest{
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
	releaseCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), releaseTimeout)
	defer cancel()
	if _, releaseErr := rpc.Release(releaseCtx, connect.NewRequest(&limitsv1.ReleaseRequest{
		ReservationId: reservationID,
		Reason:        reason,
	})); releaseErr != nil {
		util.Log(ctx).WithError(releaseErr).
			With("reservation_id", reservationID).
			Warn("limits.Gate: shadow Release failed; reservation will expire via TTL")
	}
}

// GateOption adjusts how Gate talks to the limits service.
type GateOption func(*gateOptions)

type gateOptions struct {
	tenancy util.TenancyInfo
}

// InPartition evaluates the transaction in the partition that owns the
// record being moved (the loan, the account, the order) rather than the
// partition of whoever triggered it. The limits service applies every
// policy set on that partition and on each of its ancestors, so the record's
// place in the partition tree decides which caps bind it. Empty ids leave
// the caller's tenancy in place.
func InPartition(tenantID, partitionID string) GateOption {
	return func(o *gateOptions) {
		if tenantID == "" || partitionID == "" {
			return
		}
		o.tenancy = recordTenancy{tenantID: tenantID, partitionID: partitionID}
	}
}

func applyGateOptions(ctx context.Context, opts []GateOption) context.Context {
	var o gateOptions
	for _, opt := range opts {
		if opt != nil {
			opt(&o)
		}
	}
	if o.tenancy == nil {
		return ctx
	}
	return util.SetTenancy(ctx, o.tenancy)
}

type recordTenancy struct {
	tenantID    string
	partitionID string
}

func (r recordTenancy) GetTenantID() string    { return r.tenantID }
func (r recordTenancy) GetPartitionID() string { return r.partitionID }
func (r recordTenancy) GetAccessID() string    { return "" }
