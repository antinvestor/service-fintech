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
	"crypto/sha256"
	"fmt"
	"sort"
	"strings"

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
)

func Migrate(ctx context.Context, dbManager datastore.Manager, migrationPath string) error {
	dbPool, err := dbmigrate.Pool(ctx, dbManager)
	if err != nil {
		return err
	}

	// Run pre-migrations before AutoMigrate to handle table renames and the
	// column type changes AutoMigrate cannot perform on its own.
	if preErr := preMigrate(ctx, dbPool); preErr != nil {
		util.Log(ctx).WithError(preErr).Error("preMigrate -- failed")
		return preErr
	}

	if migrateErr := dbManager.Migrate(ctx, dbPool, migrationPath,
		&models.Organization{}, &models.Branch{}, &models.Agent{}, &models.AgentBranch{},
		&models.Client{}, &models.ClientAssignmentHistory{}, &models.ClientResponsibilityHistory{},
		&models.CreditLimitChangeRequest{},
		&models.ApprovalCase{},
		&models.ClientGroup{}, &models.Membership{},
		&models.Investor{},
		&models.WorkforceMember{}, &models.Department{}, &models.Position{},
		&models.PositionAssignment{}, &models.InternalTeam{}, &models.TeamMembership{},
		&models.AccessRoleAssignment{},
		&models.ClientDataEntry{}, &models.ClientDataEntryHistory{},
		&models.FormTemplate{}, &models.FormSubmission{},
		&models.ClientRelationship{}); migrateErr != nil {
		return migrateErr
	}

	if postErr := postMigrate(ctx, dbPool); postErr != nil {
		util.Log(ctx).WithError(postErr).Error("postMigrate -- failed")
		return postErr
	}

	return nil
}

// preMigrate handles structural changes that must happen before GORM AutoMigrate.
// Currently renames the 'banks' table to 'organizations' and updates foreign key columns.
//
//nolint:gocognit // migration steps are inherently sequential
func preMigrate(
	ctx context.Context,
	dbPool pool.Pool,
) error {
	db := dbPool.DB(ctx, false)
	if db == nil {
		return nil
	}

	migrator := db.Migrator()

	// Rename banks → organizations if the old table exists
	if migrator.HasTable("banks") && !migrator.HasTable("organizations") {
		util.Log(ctx).Info("preMigrate -- renaming 'banks' table to 'organizations'")
		if err := db.Exec("ALTER TABLE banks RENAME TO organizations").Error; err != nil {
			return err
		}

		// Rename indexes
		safeRenameIndex(db, "organizations", "uq_bank_code", "uq_organization_code")
	}

	// Rename branches → org_units before AutoMigrate so the canonical hierarchy table is used.
	if migrator.HasTable("branches") && !migrator.HasTable("org_units") {
		util.Log(ctx).Info("preMigrate -- renaming 'branches' table to 'org_units'")
		if err := db.Exec("ALTER TABLE branches RENAME TO org_units").Error; err != nil {
			return err
		}

		safeRenameIndex(db, "org_units", "idx_branch_organization", "idx_branch_organization")
		safeRenameIndex(db, "org_units", "uq_branch_code", "uq_branch_code")
	}

	// Rename bank_id → organization_id in org_units if the old column exists.
	if migrator.HasTable("org_units") && migrator.HasColumn(&models.Branch{}, "bank_id") {
		util.Log(ctx).Info("preMigrate -- renaming 'bank_id' to 'organization_id' in org_units")
		if err := db.Exec("ALTER TABLE org_units RENAME COLUMN bank_id TO organization_id").Error; err != nil {
			return err
		}

		safeRenameIndex(db, "org_units", "idx_branch_bank", "idx_branch_organization")
	}

	// Add organization_type column if it doesn't exist on organizations table
	if migrator.HasTable("organizations") && !migrator.HasColumn(&models.Organization{}, "organization_type") {
		util.Log(ctx).Info("preMigrate -- adding 'organization_type' column to organizations")
		if err := db.Exec(
			"ALTER TABLE organizations ADD COLUMN IF NOT EXISTS organization_type integer DEFAULT 0",
		).Error; err != nil {
			return err
		}
	}

	// Rename groups → client_groups if the old table exists
	if migrator.HasTable("groups") && !migrator.HasTable("client_groups") {
		util.Log(ctx).Info("preMigrate -- renaming 'groups' table to 'client_groups'")
		if err := db.Exec("ALTER TABLE groups RENAME TO client_groups").Error; err != nil {
			return err
		}
	}

	return convertLegacyEnumColumns(ctx, db)
}

// legacyEnumColumn is a column that used to store an enum ordinal and now
// stores an organization defined string.
type legacyEnumColumn struct {
	Table  string
	Column string
	Values map[int]string
}

// legacyEnumColumns must be converted before AutoMigrate runs: Postgres will
// not widen an integer column to varchar without an explicit USING clause, and
// AutoMigrate does not emit one.
//
//nolint:gochecknoglobals // static migration description
var legacyEnumColumns = []legacyEnumColumn{
	{
		Table:  "workforce_members",
		Column: "engagement_type",
		Values: map[int]string{
			1: "employee", 2: "contractor", 3: "service_account",
			4: "agent", 5: "volunteer", 6: "intern",
		},
	},
	{
		Table:  "internal_teams",
		Column: "team_type",
		Values: map[int]string{
			1: "portfolio", 2: "servicing", 3: "collections",
			4: "sales", 5: "pilot", 6: "shared_service",
		},
	},
	{
		Table:  "team_memberships",
		Column: "membership_role",
		Values: map[int]string{
			1: "lead", 2: "deputy", 3: "member",
			4: "specialist", 5: "supervisor", 6: "coordinator",
		},
	},
}

func convertLegacyEnumColumns(ctx context.Context, db *gorm.DB) error {
	for _, spec := range legacyEnumColumns {
		isInteger, err := columnIsInteger(db, spec.Table, spec.Column)
		if err != nil {
			return err
		}
		if !isInteger {
			continue
		}

		util.Log(ctx).
			WithField("table", spec.Table).
			WithField("column", spec.Column).
			Info("preMigrate -- converting legacy enum column to varchar")

		if err = db.Exec(fmt.Sprintf(
			"ALTER TABLE %s ALTER COLUMN %s DROP DEFAULT", spec.Table, spec.Column,
		)).Error; err != nil {
			return err
		}
		if err = db.Exec(fmt.Sprintf(
			"ALTER TABLE %s ALTER COLUMN %s TYPE VARCHAR(50) USING (%s)",
			spec.Table, spec.Column, enumCaseExpression(spec),
		)).Error; err != nil {
			return err
		}
		if err = db.Exec(fmt.Sprintf(
			"ALTER TABLE %s ALTER COLUMN %s SET DEFAULT ''", spec.Table, spec.Column,
		)).Error; err != nil {
			return err
		}
	}
	return nil
}

// enumCaseExpression renders the CASE that maps stored ordinals onto their
// string equivalents. Both sides are compile-time constants.
func enumCaseExpression(spec legacyEnumColumn) string {
	ordinals := make([]int, 0, len(spec.Values))
	for ordinal := range spec.Values {
		ordinals = append(ordinals, ordinal)
	}
	sort.Ints(ordinals)

	var builder strings.Builder
	builder.WriteString("CASE ")
	for _, ordinal := range ordinals {
		fmt.Fprintf(&builder, "WHEN %s = %d THEN '%s' ", spec.Column, ordinal, spec.Values[ordinal])
	}
	builder.WriteString("ELSE '' END")
	return builder.String()
}

// columnIsInteger reports whether the column still holds the legacy integer
// type. A table or column that does not exist yet reports false.
func columnIsInteger(db *gorm.DB, table, column string) (bool, error) {
	var dataType string
	err := db.Raw(
		`SELECT data_type FROM information_schema.columns
		 WHERE table_schema = current_schema() AND table_name = ? AND column_name = ?`,
		table, column,
	).Scan(&dataType).Error
	if err != nil {
		return false, err
	}
	switch dataType {
	case "smallint", "integer", "bigint":
		return true, nil
	default:
		return false, nil
	}
}

func safeRenameIndex(db *gorm.DB, _, oldName, newName string) {
	// PostgreSQL syntax for renaming indexes
	db.Exec("ALTER INDEX IF EXISTS " + oldName + " RENAME TO " + newName)
}

type searchableTerm struct {
	Weight string
	Expr   string
}

type searchableSpec struct {
	Table string
	Terms []searchableTerm
}

func postMigrate(ctx context.Context, dbPool pool.Pool) error { //nolint:funlen // sequential post-migration setup
	db := dbPool.DB(ctx, false)
	if db == nil {
		return nil
	}

	specs := []searchableSpec{
		{
			Table: "organizations",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceName},
				{Weight: "A", Expr: exprCoalesceCode},
				{Weight: "B", Expr: exprCoalesceProfileID},
				{Weight: "B", Expr: "coalesce(%sclient_id, '')"},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "org_units",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceName},
				{Weight: "A", Expr: exprCoalesceCode},
				{Weight: "B", Expr: exprCoalesceGeoID},
				{Weight: "B", Expr: "coalesce(%sclient_id, '')"},
				{Weight: "C", Expr: "coalesce(%sparent_id, '')"},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "agents",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceName},
				{Weight: "A", Expr: exprCoalesceProfileID},
				{Weight: "B", Expr: exprCoalesceGeoID},
				{Weight: "C", Expr: "coalesce(%sparent_agent_id, '')"},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "clients",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceName},
				{Weight: "B", Expr: exprCoalesceProfileID},
				{Weight: "B", Expr: "coalesce(%sowning_team_id, '')"},
				{Weight: "C", Expr: "coalesce(%scurrency_code, '')"},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "client_groups",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceName},
				{Weight: "B", Expr: exprCoalesceProfileID},
				{Weight: "C", Expr: "coalesce(%scurrency_code, '')"},
				{Weight: "C", Expr: "coalesce(%stime_zone, '')"},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "memberships",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceName},
				{Weight: "B", Expr: exprCoalesceProfileID},
				{Weight: "B", Expr: "coalesce(%scontact_id, '')"},
				{Weight: "C", Expr: "coalesce(%stime_zone, '')"},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "investors",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceName},
				{Weight: "B", Expr: exprCoalesceProfileID},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "workforce_members",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceProfileID},
				{Weight: "B", Expr: exprCoalesceOrganizationID},
				{Weight: "B", Expr: "coalesce(%shome_org_unit_id, '')"},
				{Weight: "B", Expr: exprCoalesceGeoID},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "departments",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceName},
				{Weight: "A", Expr: exprCoalesceCode},
				{Weight: "B", Expr: exprCoalesceOrganizationID},
				{Weight: "B", Expr: "coalesce(%sparent_id, '')"},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "positions",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceName},
				{Weight: "A", Expr: exprCoalesceCode},
				{Weight: "B", Expr: exprCoalesceOrganizationID},
				{Weight: "B", Expr: "coalesce(%sorg_unit_id, '')"},
				{Weight: "B", Expr: "coalesce(%sdepartment_id, '')"},
				{Weight: "C", Expr: "coalesce(%sreports_to_position_id, '')"},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "position_assignments",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceMemberID},
				{Weight: "A", Expr: "coalesce(%sposition_id, '')"},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "internal_teams",
			Terms: []searchableTerm{
				{Weight: "A", Expr: exprCoalesceName},
				{Weight: "A", Expr: exprCoalesceCode},
				{Weight: "B", Expr: exprCoalesceOrganizationID},
				{Weight: "B", Expr: "coalesce(%shome_org_unit_id, '')"},
				{Weight: "B", Expr: "coalesce(%sobjective, '')"},
				{Weight: "B", Expr: exprCoalesceGeoID},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "team_memberships",
			Terms: []searchableTerm{
				{Weight: "A", Expr: "coalesce(%steam_id, '')"},
				{Weight: "A", Expr: exprCoalesceMemberID},
				{Weight: "C", Expr: exprCoalesceProperties},
			},
		},
		{
			Table: "access_role_assignments",
			Terms: []searchableTerm{
				{Weight: "A", Expr: "coalesce(%srole_key, '')"},
				{Weight: "A", Expr: exprCoalesceMemberID},
				{Weight: "B", Expr: "coalesce(%sscope_id, '')"},
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
	functionName := fmt.Sprintf("%s_searchable_update", spec.Table)
	triggerName := fmt.Sprintf("%s_searchable_trigger", spec.Table)
	indexName := fmt.Sprintf("idx_%s_searchable", spec.Table)

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
		util.Log(ctx).
			WithField("table", spec.Table).
			WithError(err).
			Error("failed to create searchable trigger function")
		return err
	}

	if err := db.Exec("DROP TRIGGER IF EXISTS " + triggerName + " ON " + spec.Table).Error; err != nil {
		util.Log(ctx).WithField("table", spec.Table).WithError(err).Error("failed to drop searchable trigger")
		return err
	}

	triggerSQL := fmt.Sprintf(
		"CREATE TRIGGER %s BEFORE INSERT OR UPDATE ON %s FOR EACH ROW EXECUTE FUNCTION %s()",
		triggerName,
		spec.Table,
		functionName,
	)
	if err := db.Exec(triggerSQL).Error; err != nil {
		util.Log(ctx).WithField("table", spec.Table).WithError(err).Error("failed to create searchable trigger")
		return err
	}

	if err := backfillSearchable(ctx, db, spec); err != nil {
		return err
	}

	indexSQL := fmt.Sprintf("CREATE INDEX IF NOT EXISTS %s ON %s USING GIN (searchable)", indexName, spec.Table)
	if err := db.Exec(indexSQL).Error; err != nil {
		util.Log(ctx).WithField("table", spec.Table).WithError(err).Error("failed to create searchable index")
		return err
	}

	return nil
}

// searchableSpecsTable records the tsvector expression each table was last
// backfilled with.
const searchableSpecsTable = "searchable_column_specs"

// backfillSearchable populates the searchable column.
//
// The trigger keeps rows current from here on, so normally only rows that never
// had the column populated need rewriting, and an unconditional UPDATE would
// rewrite every table on every deploy while holding the migration lock. But
// when the expression itself changes, the rows written under the old expression
// are stale and `WHERE searchable IS NULL` skips every one of them — the
// searches silently keep matching on the old weights and columns. So the
// expression is hashed and recorded; a changed hash rewrites the whole table
// exactly once.
func backfillSearchable(ctx context.Context, db *gorm.DB, spec searchableSpec) error {
	expression := buildSearchableExpression(spec.Terms, "")

	if err := db.Exec(fmt.Sprintf(
		`CREATE TABLE IF NOT EXISTS %s (
			table_name text PRIMARY KEY,
			expression_hash text NOT NULL,
			updated_at timestamptz NOT NULL DEFAULT now()
		)`, searchableSpecsTable,
	)).Error; err != nil {
		util.Log(ctx).WithError(err).Error("failed to create searchable spec table")
		return err
	}

	hash := fmt.Sprintf("%x", sha256.Sum256([]byte(expression)))

	var storedHash string
	if err := db.Raw(
		"SELECT expression_hash FROM "+searchableSpecsTable+" WHERE table_name = ?", spec.Table,
	).Scan(&storedHash).Error; err != nil {
		util.Log(ctx).WithField("table", spec.Table).WithError(err).Error("failed to read searchable spec hash")
		return err
	}

	where := "WHERE searchable IS NULL"
	if storedHash != hash {
		util.Log(ctx).
			WithField("table", spec.Table).
			Info("searchable expression changed -- rewriting every row")
		where = ""
	}

	backfillSQL := fmt.Sprintf("UPDATE %s SET searchable = %s %s", spec.Table, expression, where)
	if err := db.Exec(backfillSQL).Error; err != nil {
		util.Log(ctx).WithField("table", spec.Table).WithError(err).Error("failed to backfill searchable column")
		return err
	}

	if err := db.Exec(fmt.Sprintf(
		`INSERT INTO %s (table_name, expression_hash, updated_at) VALUES (?, ?, now())
		 ON CONFLICT (table_name) DO UPDATE SET expression_hash = EXCLUDED.expression_hash,
		                                        updated_at = EXCLUDED.updated_at`,
		searchableSpecsTable,
	), spec.Table, hash).Error; err != nil {
		util.Log(ctx).WithField("table", spec.Table).WithError(err).Error("failed to record searchable spec hash")
		return err
	}

	return nil
}

func buildSearchableExpression(terms []searchableTerm, prefix string) string {
	parts := make([]string, 0, len(terms))
	for _, term := range terms {
		expr := fmt.Sprintf(term.Expr, prefix)
		parts = append(parts, fmt.Sprintf(
			"setweight(to_tsvector('english', %s), '%s')",
			expr,
			term.Weight,
		))
	}

	return strings.Join(parts, " || ")
}
