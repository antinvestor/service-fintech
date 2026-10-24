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
	"gorm.io/gorm"

	opsmodels "github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
)

// Migrate runs database migrations for all group models.
//
// Stawi also reads and writes the operations tables (transfer orders,
// obligations, incoming payments, account refs, CBS sync records) on the same
// database, so it migrates them too rather than depending on the operations
// service having run first.
func Migrate(ctx context.Context, dbManager datastore.Manager, migrationsDirPath string) error {
	dbPool, err := dbmigrate.Pool(ctx, dbManager)
	if err != nil {
		return err
	}
	return migratePool(ctx, dbPool, migrationsDirPath)
}

func migratePool(ctx context.Context, dbPool pool.Pool, migrationsDirPath string) error {
	if err := dbPool.Migrate(ctx, migrationsDirPath,
		&models.Tenure{},
		&models.Period{},
		&models.Motion{},
		&models.MotionVote{},
		&models.Infraction{},
		&models.GroupWarning{},
		&models.MemberScore{},
		&models.Occurrence{},
		&models.RequestLog{},
		&models.LoanWindow{},
		&models.LoanOffer{},
		&opsmodels.TransferOrder{},
		&opsmodels.Obligation{},
		&opsmodels.IncomingPayment{},
		&opsmodels.AccountRef{},
		&opsmodels.LedgerRef{},
		&opsmodels.CBSSyncRecord{},
		&audit.Event{},
	); err != nil {
		return err
	}

	return postMigrate(ctx, dbPool)
}

// MigrateForTest applies the schema plus postMigrate against an already-open
// pool, so tests exercise the partial indexes the production path relies on.
func MigrateForTest(ctx context.Context, dbPool pool.Pool) error {
	return migratePool(ctx, dbPool, "")
}

// postMigrate applies schema constraints AutoMigrate cannot express: the
// partial unique indexes that back the idempotency and single-writer
// guarantees in the stawi and shared operations tables.
func postMigrate(ctx context.Context, dbPool pool.Pool) error {
	db := dbPool.DB(ctx, false)
	if db == nil {
		return nil
	}

	// The first period of every tenure has an empty parent_period_id, so a
	// plain unique index would let only one group in the whole deployment open
	// its first period. Drop the legacy index and scope uniqueness to periods
	// that actually name a parent.
	if err := db.Exec("DROP INDEX IF EXISTS uq_per_parent").Error; err != nil {
		return err
	}

	indexes := []struct {
		name, table, column, where string
	}{
		{"uq_periods_parent_period_id", "periods", "parent_period_id", "parent_period_id <> ''"},
		{"uq_transfer_orders_reference", "transfer_orders", "reference", "reference <> ''"},
		{
			"uq_incoming_payments_transaction_id",
			"incoming_payments",
			"transaction_id",
			"transaction_id <> ''",
		},
	}
	for _, idx := range indexes {
		if err := createPartialUniqueIndex(db, idx.name, idx.table, idx.column, idx.where); err != nil {
			return err
		}
	}

	// One period per position within a tenure, and one active tenure per group.
	// Both are what "open the next period" and "open a tenure" claim to
	// guarantee; only the database can actually enforce them under concurrency.
	if err := createPartialUniqueIndexExpr(
		db,
		"uq_periods_tenure_position",
		"periods",
		"(tenure_id, position)",
		"tenure_id <> ''",
	); err != nil {
		return err
	}

	return createPartialUniqueIndexExpr(
		db,
		"uq_tenures_active_group",
		"tenures",
		"(group_id)",
		"state = 3",
	)
}

func createPartialUniqueIndex(db *gorm.DB, indexName, table, column, whereClause string) error {
	return createPartialUniqueIndexExpr(db, indexName, table, "("+column+")", whereClause)
}

func createPartialUniqueIndexExpr(db *gorm.DB, indexName, table, columns, whereClause string) error {
	stmt := "CREATE UNIQUE INDEX IF NOT EXISTS " + indexName +
		" ON " + table + " " + columns + " WHERE " + whereClause
	if err := db.Exec(stmt).Error; err != nil {
		util.Log(db.Statement.Context).
			WithField("index", indexName).
			WithError(err).
			Error("failed to create partial unique index")
		return err
	}
	return nil
}
