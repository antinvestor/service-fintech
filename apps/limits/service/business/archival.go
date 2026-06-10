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
	resvRepo   repository.ReservationRepository
	ledgerRepo repository.LedgerRepository
}

// NewArchival constructs an Archival job.
func NewArchival(resvRepo repository.ReservationRepository, ledgerRepo repository.LedgerRepository) *Archival {
	return &Archival{resvRepo: resvRepo, ledgerRepo: ledgerRepo}
}

// Run hard-deletes terminal reservations older than 7 days and ledger entries
// older than 90 days. Cross-tenant. Returns counts per category.
func (a *Archival) Run(ctx context.Context) (int, int, error) {
	log := util.Log(ctx).With("job", "archival")

	cutoffResv := time.Now().UTC().Add(-7 * 24 * time.Hour)
	cutoffLedger := time.Now().UTC().Add(-90 * 24 * time.Hour)

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
