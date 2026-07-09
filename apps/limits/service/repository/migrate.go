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

package repository

import (
	"context"
	"errors"

	"github.com/pitabwire/frame/v2/datastore"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

// Migrate runs Frame's AutoMigrate over every limits-service model and applies
// any SQL migrations dropped into migrationPath. Subsequent plans add the
// Reservation/Ledger/Approval models to this slice.
//
// The migration pool (DefaultMigrationPoolName) is preferred when available —
// it is registered by Frame only when the service config enables migrations.
// In test environments (and any service that omits the migration pool) the
// function falls back to the default read-write pool.
func Migrate(ctx context.Context, dbManager datastore.Manager, migrationPath string) error {
	dbPool := dbManager.GetPool(ctx, datastore.DefaultMigrationPoolName)
	if dbPool == nil {
		dbPool = dbManager.GetPool(ctx, datastore.DefaultPoolName)
	}
	if dbPool == nil {
		return errors.New("datastore pool is not initialised")
	}
	return dbManager.Migrate(ctx, dbPool, migrationPath,
		&models.Policy{},
		&models.PolicyVersion{},
		&models.Reservation{},
		&models.LedgerEntry{},
		&models.ApprovalRequest{},
		&models.ApprovalDecision{},
		&models.SubjectAttributeSnapshot{},
		&audit.Event{},
	)
}
