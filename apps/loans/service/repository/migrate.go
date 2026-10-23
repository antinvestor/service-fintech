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
	"fmt"
	"strings"

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
)

const (
	exprCoalesceName           = "coalesce(%sname, '')"
	exprCoalesceCode           = "coalesce(%scode, '')"
	exprCoalesceClientID       = "coalesce(%sclient_id, '')"
	exprCoalesceOrganizationID = "coalesce(%sorganization_id, '')"
	exprCoalesceCurrencyCode   = "coalesce(%scurrency_code, '')"
	exprCoalesceProperties     = "coalesce(%sproperties::text, '')"
)

func Migrate(ctx context.Context, dbManager datastore.Manager, migrationPath string) error {
	dbPool, err := dbmigrate.Pool(ctx, dbManager)
	if err != nil {
		return err
	}

	// Run pre-migrations before AutoMigrate to handle column renames
	if preErr := preMigrate(ctx, dbPool); preErr != nil {
		util.Log(ctx).WithError(preErr).Warn("preMigrate -- non-fatal pre-migration issue")
	}

	if migrateErr := dbManager.Migrate(ctx, dbPool, migrationPath,
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
	); migrateErr != nil {
		return migrateErr
	}

	if postErr := postMigrate(ctx, dbPool); postErr != nil {
		util.Log(ctx).WithError(postErr).Error("postMigrate -- failed")
		return postErr
	}

	return nil
}

type searchableTerm struct {
	Weight string
	Expr   string
}

type searchableSpec struct {
	Table string
	Terms []searchableTerm
}

// postMigrate creates the generated full-text column the search RPCs query.
// Frame does not manage it, so without this step every search with a text
// query fails against a column that does not exist.
func postMigrate(ctx context.Context, dbPool pool.Pool) error {
	db := dbPool.DB(ctx, false)
	if db == nil {
		return nil
	}

	specs := []searchableSpec{
		{
			Table: "loan_products",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceName},
				{Weight: "A", Expr: exprCoalesceCode},
				{Weight: "B", Expr: "coalesce(%sdescription, '')"},
				{Weight: "B", Expr: exprCoalesceOrganizationID},
				{Weight: "C", Expr: exprCoalesceCurrencyCode},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "loan_requests",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceClientID},
				{Weight: "A", Expr: "coalesce(%ssource_request_id, '')"},
				{Weight: "B", Expr: "coalesce(%spurpose, '')"},
				{Weight: "B", Expr: exprCoalesceOrganizationID},
				{Weight: "C", Expr: "coalesce(%sagent_id, '')"},
				{Weight: "C", Expr: "coalesce(%sbranch_id, '')"},
				{Weight: "C", Expr: "coalesce(%ssource_service, '')"},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "loan_accounts",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceClientID},
				{Weight: "A", Expr: "coalesce(%sloan_request_id, '')"},
				{Weight: "B", Expr: exprCoalesceOrganizationID},
				{Weight: "B", Expr: "coalesce(%sproduct_id, '')"},
				{Weight: "C", Expr: "coalesce(%sagent_id, '')"},
				{Weight: "C", Expr: "coalesce(%sbranch_id, '')"},
				{Weight: "C", Expr: "coalesce(%spayment_account_ref, '')"},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
	}

	for _, spec := range specs {
		if err := ensureSearchableColumn(ctx, db, spec); err != nil {
			return err
		}
	}

	return nil
}

func ensureSearchableColumn(ctx context.Context, db *gorm.DB, spec searchableSpec) error {
	functionName := spec.Table + "_searchable_update"
	triggerName := spec.Table + "_searchable_trigger"
	indexName := "idx_" + spec.Table + "_searchable"

	if err := db.Exec("ALTER TABLE " + spec.Table + " ADD COLUMN IF NOT EXISTS searchable tsvector").Error; err != nil {
		util.Log(ctx).WithField("table", spec.Table).WithError(err).Error("failed to add searchable column")
		return err
	}

	functionSQL := fmt.Sprintf(
		`CREATE OR REPLACE FUNCTION %s() RETURNS trigger AS $$
BEGIN
  NEW.searchable := %s;
  RETURN NEW;
END
$$ LANGUAGE plpgsql;`,
		functionName,
		buildSearchableExpression(spec.Terms, "NEW."),
	)
	if err := db.Exec(functionSQL).Error; err != nil {
		util.Log(ctx).WithField("table", spec.Table).WithError(err).
			Error("failed to create searchable trigger function")
		return err
	}

	if err := db.Exec("DROP TRIGGER IF EXISTS " + triggerName + " ON " + spec.Table).Error; err != nil {
		util.Log(ctx).WithField("table", spec.Table).WithError(err).Error("failed to drop searchable trigger")
		return err
	}

	triggerSQL := fmt.Sprintf(
		"CREATE TRIGGER %s BEFORE INSERT OR UPDATE ON %s FOR EACH ROW EXECUTE FUNCTION %s()",
		triggerName, spec.Table, functionName,
	)
	if err := db.Exec(triggerSQL).Error; err != nil {
		util.Log(ctx).WithField("table", spec.Table).WithError(err).Error("failed to create searchable trigger")
		return err
	}

	backfillSQL := fmt.Sprintf("UPDATE %s SET searchable = %s", spec.Table, buildSearchableExpression(spec.Terms, ""))
	if err := db.Exec(backfillSQL).Error; err != nil {
		util.Log(ctx).WithField("table", spec.Table).WithError(err).Error("failed to backfill searchable column")
		return err
	}

	indexSQL := fmt.Sprintf("CREATE INDEX IF NOT EXISTS %s ON %s USING GIN (searchable)", indexName, spec.Table)
	if err := db.Exec(indexSQL).Error; err != nil {
		util.Log(ctx).WithField("table", spec.Table).WithError(err).Error("failed to create searchable index")
		return err
	}

	return nil
}

func buildSearchableExpression(terms []searchableTerm, prefix string) string {
	parts := make([]string, 0, len(terms))
	for _, term := range terms {
		parts = append(parts, fmt.Sprintf(
			"setweight(to_tsvector('english', %s), '%s')",
			fmt.Sprintf(term.Expr, prefix),
			term.Weight,
		))
	}

	return strings.Join(parts, " || ")
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
