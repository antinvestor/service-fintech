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
	"time"

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
)

// Migrate runs database migrations for all operations models.
func Migrate(ctx context.Context, dbManager datastore.Manager, migrationsDirPath string) error {
	dbPool, err := dbmigrate.Pool(ctx, dbManager)
	if err != nil {
		return err
	}

	if preErr := preMigrate(ctx, dbPool); preErr != nil {
		util.Log(ctx).WithError(preErr).Warn("preMigrate -- non-fatal pre-migration issue")
	}

	if migrateErr := dbManager.Migrate(ctx, dbPool, migrationsDirPath,
		&models.TransferOrder{},
		&models.Obligation{},
		&models.IncomingPayment{},
		&models.AccountRef{},
		&models.LedgerRef{},
		&models.CBSSyncRecord{},
		&models.PayBack{},
		&models.TransactionCost{},
		&models.ServiceFee{},
		&audit.Event{},
	); migrateErr != nil {
		return migrateErr
	}

	if postErr := postMigrate(ctx, dbPool); postErr != nil {
		util.Log(ctx).WithError(postErr).Error("postMigrate -- failed")
		return postErr
	}

	return nil
}

func preMigrate(_ context.Context, _ pool.Pool) error {
	return nil
}

// MigrateForTest applies the schema plus postMigrate against an already-open
// pool. Tests need the partial unique indexes, which are the whole point of
// the idempotency guarantees they exercise.
func MigrateForTest(ctx context.Context, dbPool pool.Pool) error {
	if err := dbPool.DB(ctx, false).AutoMigrate(
		&models.TransferOrder{},
		&models.Obligation{},
		&models.IncomingPayment{},
		&models.AccountRef{},
		&models.LedgerRef{},
		&models.CBSSyncRecord{},
		&models.PayBack{},
		&models.TransactionCost{},
		&models.ServiceFee{},
		&audit.Event{},
	); err != nil {
		return err
	}
	return postMigrate(ctx, dbPool)
}

// postMigrate applies schema changes that AutoMigrate cannot express, most
// notably partial unique indexes used as idempotency guards.
func postMigrate(ctx context.Context, dbPool pool.Pool) error {
	db := dbPool.DB(ctx, false)
	if db == nil {
		return nil
	}

	// Partial unique index on transfer_orders.reference. The reference column
	// is used as a caller-supplied idempotency key (e.g. "repayment:{id}:principal")
	// so that retries of the same logical operation resolve to a single row.
	// Legacy rows with empty reference are excluded from the uniqueness constraint.
	if err := createPartialUniqueIndex(
		db,
		"uq_transfer_orders_reference",
		"transfer_orders",
		"reference",
		"reference <> ''",
	); err != nil {
		return err
	}

	// Partial unique index on incoming_payments.transaction_id. The payment
	// provider's transaction id is the dedupe key for inbound notifications;
	// without the index a retried notification creates a second payment row.
	// Legacy rows with an empty transaction id are excluded.
	if err := createPartialUniqueIndex(
		db,
		"uq_incoming_payments_transaction_id",
		"incoming_payments",
		"transaction_id",
		"transaction_id <> ''",
	); err != nil {
		return err
	}

	// Allocation orders written before obligation_consumed existed had their
	// obligation consumed right after being written; mark them so a retry
	// does not try to consume again. Runs exactly once, behind a marker row
	// written in the same transaction: on the first deploy every existing
	// allocation order is by definition one written before the mark existed,
	// and no later deploy touches rows the new code wrote.
	if err := runBackfillOnce(ctx, db, "obligation_consumed_v1", func(tx *gorm.DB) error {
		return tx.Exec(
			"UPDATE transfer_orders SET obligation_consumed = true "+
				"WHERE reference LIKE 'payment:%:obligation:%' AND obligation_consumed = false AND state <> ?",
			int32(constants.StateShutdown),
		).Error
	}); err != nil {
		return err
	}

	return nil
}

// runBackfillOnce applies fn once per database, recording that it ran in
// operations_backfills within the same transaction so a re-run of the setup
// job is a no-op.
func runBackfillOnce(_ context.Context, db *gorm.DB, name string, fn func(tx *gorm.DB) error) error {
	if err := db.Exec(
		"CREATE TABLE IF NOT EXISTS operations_backfills (name text PRIMARY KEY, applied_at timestamptz NOT NULL)",
	).Error; err != nil {
		return err
	}
	return db.Transaction(func(tx *gorm.DB) error {
		var applied int64
		if err := tx.Table("operations_backfills").Where("name = ?", name).Count(&applied).Error; err != nil {
			return err
		}
		if applied > 0 {
			return nil
		}
		if err := fn(tx); err != nil {
			return err
		}
		return tx.Exec(
			"INSERT INTO operations_backfills (name, applied_at) VALUES (?, ?)",
			name,
			time.Now().UTC(),
		).Error
	})
}

func createPartialUniqueIndex(db *gorm.DB, indexName, table, column, whereClause string) error {
	stmt := "CREATE UNIQUE INDEX IF NOT EXISTS " + indexName +
		" ON " + table + " (" + column + ") WHERE " + whereClause
	if err := db.Exec(stmt).Error; err != nil {
		util.Log(db.Statement.Context).
			WithField("index", indexName).
			WithError(err).
			Error("failed to create partial unique index")
		return err
	}
	return nil
}
