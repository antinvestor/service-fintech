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

	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// Archival hard-deletes terminal reservations and old ledger entries to bound
// long-term disk and index growth. Intended to be called periodically (e.g.
// hourly) via POST /admin/archive.
type Archival struct {
	resvRepo          repository.ReservationRepository
	ledgerRepo        repository.LedgerRepository
	policyRepo        repository.PolicyRepository
	reservationRetain time.Duration
	ledgerRetain      time.Duration
}

// Default retention windows, used when the configured values are non-positive.
const (
	defaultReservationRetention = 7 * 24 * time.Hour
	defaultLedgerRetention      = 90 * 24 * time.Hour
	// ledgerWindowSlack is the extra margin kept behind the widest live rolling
	// window so a cap never reads a truncated ledger at its own boundary.
	ledgerWindowSlack = 24 * time.Hour
)

// NewArchival constructs an Archival job. Non-positive retentions fall back to
// the defaults. policyRepo may be nil, in which case the live-window guard is
// skipped (test wiring only).
func NewArchival(
	resvRepo repository.ReservationRepository,
	ledgerRepo repository.LedgerRepository,
	policyRepo repository.PolicyRepository,
	reservationRetain, ledgerRetain time.Duration,
) *Archival {
	if reservationRetain <= 0 {
		reservationRetain = defaultReservationRetention
	}
	if ledgerRetain <= 0 {
		ledgerRetain = defaultLedgerRetention
	}
	return &Archival{
		resvRepo:          resvRepo,
		ledgerRepo:        ledgerRepo,
		policyRepo:        policyRepo,
		reservationRetain: reservationRetain,
		ledgerRetain:      ledgerRetain,
	}
}

// Run hard-deletes terminal reservations and ledger entries older than their
// configured retention. The ledger cutoff is pushed back so it never falls
// inside the widest live rolling window: deleting there would silently
// under-count usage for that cap for the rest of its life. Cross-tenant.
// Returns counts per category.
func (a *Archival) Run(ctx context.Context) (int, int, error) {
	log := util.Log(ctx).With("job", "archival")

	now := time.Now().UTC()
	ledgerRetain := a.ledgerRetain
	if a.policyRepo != nil {
		maxWindow, err := a.policyRepo.MaxLiveWindowSeconds(ctx)
		if err != nil {
			log.WithError(err).Error("archival: could not read live policy windows")
			return 0, 0, err
		}
		// Keep a full window plus a day of slack behind the widest live cap.
		if guard := time.Duration(maxWindow)*time.Second + ledgerWindowSlack; guard > ledgerRetain {
			log.With("ledger_retention_seconds", int64(guard/time.Second)).
				Info("archival: ledger retention widened to cover the longest live rolling window")
			ledgerRetain = guard
		}
	}

	cutoffResv := now.Add(-a.reservationRetain)
	cutoffLedger := now.Add(-ledgerRetain)

	resvDeleted, err := a.resvRepo.HardDeleteTerminalBefore(ctx, cutoffResv)
	if err != nil {
		log.WithError(err).Error("archival: reservation hard-delete failed")
		return 0, 0, err
	}

	ledgerDeleted, err := a.ledgerRepo.HardDeleteBefore(ctx, cutoffLedger)
	if err != nil {
		log.WithError(err).Error("archival: ledger hard-delete failed")
		return resvDeleted, 0, err
	}

	log.With("reservations_deleted", resvDeleted).
		With("ledger_deleted", ledgerDeleted).
		Info("archival run complete")

	return resvDeleted, ledgerDeleted, nil
}
