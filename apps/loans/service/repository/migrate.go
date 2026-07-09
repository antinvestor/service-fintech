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

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

func Migrate(ctx context.Context, dbManager datastore.Manager, migrationPath string) error {
	dbPool := dbManager.GetPool(ctx, datastore.DefaultMigrationPoolName)
	if dbPool == nil {
		return errors.New("datastore pool is not initialised")
	}

	// Run pre-migrations before AutoMigrate to handle column renames
	if err := preMigrate(ctx, dbPool); err != nil {
		util.Log(ctx).WithError(err).Warn("preMigrate -- non-fatal pre-migration issue")
	}

	return dbManager.Migrate(ctx, dbPool, migrationPath,
		&models.LoanProduct{},
		&models.LoanRequest{},
		&models.ClientProductAccess{},
		&models.LoanAccount{},
		&models.RepaymentSchedule{},
		&models.ScheduleEntry{},
		&models.LoanBalance{},
		&models.Repayment{},
		&models.Penalty{},
		&models.LoanRestructure{},
		&models.LoanStatusChange{},
		&models.Reconciliation{},
		&models.Disbursement{},
		&audit.Event{},
	)
}

// preMigrate renames bank_id columns to organization_id across loan tables.
func preMigrate(ctx context.Context, dbPool pool.Pool) error {
	db := dbPool.DB(ctx, false)
	if db == nil {
		return nil
	}

	migrator := db.Migrator()

	// Rename bank_id → organization_id in loan_products
	if migrator.HasTable("loan_products") {
		if err := renameColumnIfExists(ctx, db, "loan_products", "bank_id", "organization_id"); err != nil {
			return err
		}
		safeRenameIndex(db, "loan_products", "idx_lp_bank", "idx_lp_organization")
	}

	// Rename bank_id → organization_id in loan_accounts
	if migrator.HasTable("loan_accounts") {
		if err := renameColumnIfExists(ctx, db, "loan_accounts", "bank_id", "organization_id"); err != nil {
			return err
		}
		safeRenameIndex(db, "loan_accounts", "idx_la_bank", "idx_la_organization")
	}

	return nil
}

func renameColumnIfExists(ctx context.Context, db *gorm.DB, table, oldCol, newCol string) error {
	// Check if old column exists before renaming
	var count int64
	db.Raw(`SELECT count(*) FROM information_schema.columns
		WHERE table_schema = current_schema() AND table_name = ? AND column_name = ?`, table, oldCol).Scan(&count)
	if count > 0 {
		util.Log(ctx).WithField("table", table).WithField("old", oldCol).WithField("new", newCol).
			Info("preMigrate -- renaming column")
		return db.Exec("ALTER TABLE " + table + " RENAME COLUMN " + oldCol + " TO " + newCol).Error
	}
	return nil
}

func safeRenameIndex(db *gorm.DB, _ string, oldName, newName string) {
	db.Exec("ALTER INDEX IF EXISTS " + oldName + " RENAME TO " + newName)
}
