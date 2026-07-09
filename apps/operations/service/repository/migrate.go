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
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

// Migrate runs database migrations for all operations models.
func Migrate(ctx context.Context, dbManager datastore.Manager, migrationsDirPath string) error {
	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	if dbPool == nil {
		return errors.New("datastore pool is not initialised")
	}

	if err := preMigrate(ctx, dbPool); err != nil {
		util.Log(ctx).WithError(err).Warn("preMigrate -- non-fatal pre-migration issue")
	}

	if err := dbManager.Migrate(ctx, dbPool, migrationsDirPath,
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

	if err := postMigrate(ctx, dbPool); err != nil {
		util.Log(ctx).WithError(err).Error("postMigrate -- failed")
		return err
	}

	return nil
}

func preMigrate(_ context.Context, _ pool.Pool) error {
	return nil
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

	return nil
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
