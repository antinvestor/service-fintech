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

	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// ReservationReaper transitions expired-active reservations to terminal
// 'expired' and emits the corresponding audit verb.
type ReservationReaper struct {
	repo      repository.ReservationRepository
	auditing  *Auditing
	batchSize int
	cfg       reaperConfig
}

// NewReservationReaper constructs a reaper. Default batchSize=1000. Pass
// WithReaperPool so the expiry UPDATE and its audit rows commit together.
func NewReservationReaper(
	repo repository.ReservationRepository,
	auditing *Auditing,
	batchSize int,
	opts ...ReaperOption,
) *ReservationReaper {
	if batchSize <= 0 {
		batchSize = 1000
	}
	return &ReservationReaper{repo: repo, auditing: auditing, batchSize: batchSize, cfg: applyReaperOptions(opts)}
}

// Run scans for active reservations past their TTL and expires them.
// Intended to be invoked periodically (e.g. every 30s) by a Frame Queue
// subscriber. Errors on individual rows do not abort the batch — they
// are logged and the next pass will re-attempt.
func (r *ReservationReaper) Run(ctx context.Context) error {
	now := time.Now().UTC()
	rows, err := r.repo.ListExpiredActive(ctx, now, r.batchSize)
	if err != nil {
		return err
	}
	log := util.Log(ctx).With("reaper", "reservation_ttl")

	ids := make([]string, len(rows))
	byID := make(map[string]*models.Reservation, len(rows))
	for i, row := range rows {
		ids[i] = row.ID
		byID[row.ID] = row
	}

	var expired []string
	txErr := r.cfg.runInTx(ctx, func(tx *gorm.DB) error {
		var bulkErr error
		if tx == nil {
			expired, bulkErr = r.repo.BulkSetExpired(ctx, ids, now)
		} else {
			expired, bulkErr = r.repo.BulkSetExpiredTx(ctx, tx, ids, now)
		}
		if bulkErr != nil {
			return bulkErr
		}
		// Audit only the rows the UPDATE actually transitioned. A reservation
		// committed between the SELECT and the UPDATE is not expired and must
		// not get an expiry record.
		for _, id := range expired {
			row, ok := byID[id]
			if !ok {
				continue
			}
			row.Status = models.ReservationStatusExpired
			if tx == nil {
				r.auditing.RecordReservationExpiredTTL(ctx, row)
				continue
			}
			if auditErr := r.auditing.RecordReservationExpiredTTLTx(ctx, tx, row); auditErr != nil {
				return auditErr
			}
		}
		return nil
	})
	if txErr != nil {
		return txErr
	}
	if len(expired) > 0 {
		log.With("count", len(expired)).Info("reaped expired reservations")
	}
	return nil
}
