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

package business

import (
	"context"
	"errors"
	"fmt"
	"time"

	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/events"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// ApprovalReaper transitions pending approval requests past their
// expiration to terminal 'expired', releases the underlying reservation,
// and emits the corresponding audit verb.
//
// It is a safety net: Decide already settles the linked reservation in the
// decision's own transaction. The reaper only picks up requests nobody
// decided before expires_at.
type ApprovalReaper struct {
	approvalRepo repository.ApprovalRequestRepository
	resvRepo     repository.ReservationRepository
	auditing     *Auditing
	eventsMan    fevents.Manager
	batchSize    int
	cfg          reaperConfig
}

// NewApprovalReaper constructs a reaper. Default batchSize=1000.
// eventsMan may be nil, in which case event emission is a no-op. Pass
// WithReaperPool so each expiry commits atomically with its cascade.
func NewApprovalReaper(
	approvalRepo repository.ApprovalRequestRepository,
	resvRepo repository.ReservationRepository,
	auditing *Auditing,
	batchSize int,
	eventsMan fevents.Manager,
	opts ...ReaperOption,
) *ApprovalReaper {
	if batchSize <= 0 {
		batchSize = 1000
	}
	return &ApprovalReaper{
		approvalRepo: approvalRepo, resvRepo: resvRepo,
		auditing: auditing, eventsMan: eventsMan, batchSize: batchSize,
		cfg: applyReaperOptions(opts),
	}
}

// Run scans for pending approval requests past their expires_at and
// transitions them to expired. The corresponding reservation is released
// (since approval can no longer come). Per-row errors are logged.
func (r *ApprovalReaper) Run(ctx context.Context) error {
	now := time.Now().UTC()
	rows, err := r.approvalRepo.ListExpired(ctx, now, r.batchSize)
	if err != nil {
		return err
	}
	log := util.Log(ctx).With("reaper", "approval_expiry")
	expired := 0
	for _, ar := range rows {
		txErr := r.cfg.runInTx(ctx, func(tx *gorm.DB) error {
			return r.expireOne(ctx, tx, ar, now)
		})
		if txErr != nil {
			if !errors.Is(txErr, repository.ErrApprovalNotPending) {
				log.WithError(txErr).With("approval_id", ar.ID).
					Error("failed to expire approval request")
			}
			// Either another replica won the race or the request was decided
			// between the SELECT and the UPDATE; no audit row, no event.
			continue
		}
		expired++
		emitEvent(ctx, r.eventsMan, events.EventApprovalExpired, events.ApprovalEventPayload{
			ReservationID:     ar.ReservationID,
			ApprovalRequestID: ar.ID,
			TenantID:          ar.TenantID,
			Action:            string(ar.Action),
			MakerID:           ar.MakerID,
		})
	}
	if expired > 0 {
		log.With("count", expired).Info("reaped expired approval requests")
	}
	return nil
}

// expireOne moves a single approval request to expired, releases its
// reservation, and writes the audit row — all on tx when one is supplied.
// The status update is guarded on status='pending' with a rows-affected
// check, so a concurrent Decide and this reaper converge on exactly one
// outcome: whichever commits first wins and the other sees not-pending.
func (r *ApprovalReaper) expireOne(
	ctx context.Context,
	tx *gorm.DB,
	ar *models.ApprovalRequest,
	now time.Time,
) error {
	var err error
	if tx == nil {
		err = r.approvalRepo.SetStatus(ctx, ar.ID, models.ApprovalStatusExpired, &now)
	} else {
		err = r.approvalRepo.SetStatusTx(ctx, tx, ar.ID, models.ApprovalStatusExpired, &now)
	}
	if err != nil {
		return err
	}
	ar.Status = models.ApprovalStatusExpired
	ar.DecidedAt = &now

	if tx == nil {
		err = r.resvRepo.SetReleased(ctx, ar.ReservationID, reasonApprovalExpired, now)
	} else {
		err = r.resvRepo.SetReleasedTx(ctx, tx, ar.ReservationID, reasonApprovalExpired, now)
	}
	switch {
	case err == nil:
	case errors.Is(err, repository.ErrReservationNotReleasable):
		// The caller released the hold itself; the approval still expires.
		util.Log(ctx).With("reservation_id", ar.ReservationID).
			Warn("limits: reservation already terminal at approval expiry; nothing to release")
	default:
		return fmt.Errorf("release reservation %s: %w", ar.ReservationID, err)
	}

	if tx == nil {
		r.auditing.RecordApprovalExpired(ctx, ar)
		return nil
	}
	return r.auditing.RecordApprovalExpiredTx(ctx, tx, ar)
}

const reasonApprovalExpired = "approval expired"
