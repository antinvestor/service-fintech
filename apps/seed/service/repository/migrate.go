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

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
)

// Migrate runs GORM auto-migration for every seed model plus the shared
// audit_events table. Seed shares the platform postgres instance with
// the other fintech services, so the migration is additive and cannot
// conflict with existing tables.
func Migrate(ctx context.Context, dbManager datastore.Manager, migrationPath string) error {
	dbPool, err := dbmigrate.Pool(ctx, dbManager)
	if err != nil {
		return err
	}

	if migrateErr := dbManager.Migrate(ctx, dbPool, migrationPath,
		&models.CreditProfile{},
		&models.CreditTierConfig{},
		&models.LoanRequest{},
		&audit.Event{},
	); migrateErr != nil {
		return migrateErr
	}

	return postMigrate(ctx, dbPool)
}

// MigrateForTest applies the schema plus postMigrate against an already-open
// pool, so tests exercise the partial indexes the production path relies on.
func MigrateForTest(ctx context.Context, dbPool pool.Pool) error {
	if err := dbPool.DB(ctx, false).AutoMigrate(
		&models.CreditProfile{},
		&models.CreditTierConfig{},
		&models.LoanRequest{},
		&audit.Event{},
	); err != nil {
		return err
	}
	return postMigrate(ctx, dbPool)
}

// postMigrate replaces the plain unique index AutoMigrate builds for
// idempotency_key with a partial one. Every loan request that never carried a
// key stores an empty string, and a plain unique index would let only one such
// row exist in the whole table.
func postMigrate(ctx context.Context, dbPool pool.Pool) error {
	db := dbPool.DB(ctx, false)
	if db == nil {
		return nil
	}

	if err := db.Exec("DROP INDEX IF EXISTS uq_lr_idempotency").Error; err != nil {
		return err
	}

	stmt := "CREATE UNIQUE INDEX IF NOT EXISTS uq_seed_loan_requests_idempotency_key " +
		"ON seed_loan_requests (idempotency_key) WHERE idempotency_key <> ''"
	if err := db.Exec(stmt).Error; err != nil {
		util.Log(ctx).WithError(err).Error("postMigrate -- could not create idempotency key index")
		return err
	}
	return nil
}
