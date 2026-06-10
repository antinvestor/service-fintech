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
	"time"

	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/limits/service/events"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// ApprovalReaper transitions pending approval requests past their
// expiration to terminal 'expired', releases the underlying reservation,
// and emits the corresponding audit verb.
type ApprovalReaper struct {
	approvalRepo repository.ApprovalRequestRepository
	resvRepo     repository.ReservationRepository
	auditing     *Auditing
	eventsMan    fevents.Manager
	batchSize    int
}

// NewApprovalReaper constructs a reaper. Default batchSize=1000.
// eventsMan may be nil, in which case event emission is a no-op.
func NewApprovalReaper(
	approvalRepo repository.ApprovalRequestRepository,
	resvRepo repository.ReservationRepository,
	auditing *Auditing,
	batchSize int,
	eventsMan fevents.Manager,
) *ApprovalReaper {
	if batchSize <= 0 {
		batchSize = 1000
	}
	return &ApprovalReaper{
		approvalRepo: approvalRepo, resvRepo: resvRepo,
		auditing: auditing, eventsMan: eventsMan, batchSize: batchSize,
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
	for _, ar := range rows {
		if setErr := r.approvalRepo.SetStatus(ctx, ar.ID, models.ApprovalStatusExpired, &now); setErr != nil {
			log.WithError(setErr).With("approval_id", ar.ID).
				Error("failed to expire approval request")
			continue
		}
		// Release the reservation. Best-effort: if the reservation has
		// already moved to a terminal state, SetReleased returns an error
		// which we log but don't propagate (the approval was already expired).
		if relErr := r.resvRepo.SetReleased(ctx, ar.ReservationID, "approval expired", now); relErr != nil {
			log.WithError(relErr).With("reservation_id", ar.ReservationID).
				Warn("could not release reservation after approval expiry")
		}
		ar.Status = models.ApprovalStatusExpired
		r.auditing.RecordApprovalExpired(ctx, ar)
		emitEvent(ctx, r.eventsMan, events.EventApprovalExpired, events.ApprovalEventPayload{
			ReservationID:     ar.ReservationID,
			ApprovalRequestID: ar.ID,
			TenantID:          ar.TenantID,
			Action:            string(ar.Action),
			MakerID:           ar.MakerID,
		})
	}
	if len(rows) > 0 {
		log.With("count", len(rows)).Info("reaped expired approval requests")
	}
	return nil
}
