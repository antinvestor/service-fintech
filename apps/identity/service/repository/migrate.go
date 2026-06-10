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
	"fmt"
	"strings"

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

func Migrate(ctx context.Context, dbManager datastore.Manager, migrationPath string) error {
	dbPool := dbManager.GetPool(ctx, datastore.DefaultMigrationPoolName)
	if dbPool == nil {
		return errors.New("datastore pool is not initialised")
	}

	// Run pre-migrations before AutoMigrate to handle table renames
	if err := preMigrate(ctx, dbPool); err != nil {
		util.Log(ctx).WithError(err).Warn("preMigrate -- non-fatal pre-migration issue")
	}

	if err := dbManager.Migrate(ctx, dbPool, migrationPath,
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
		&models.ClientRelationship{}); err != nil {
		return err
	}

	if err := postMigrate(ctx, dbPool); err != nil {
		util.Log(ctx).WithError(err).Error("postMigrate -- failed")
		return err
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

	return nil
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
		expr := fmt.Sprintf(term.Expr, prefix)
		parts = append(parts, fmt.Sprintf(
			"setweight(to_tsvector('english', %s), '%s')",
			expr,
			term.Weight,
		))
	}

	return strings.Join(parts, " || ")
}
