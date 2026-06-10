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
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/frametests"
	"github.com/pitabwire/frame/frametests/definition"
	"github.com/pitabwire/frame/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/frametests/rlstest"
	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/frame/tenancy"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

type migrateSuite struct {
	frametests.FrameBaseTestSuite
}

func TestMigrateSuite(t *testing.T) {
	suite.Run(t, new(migrateSuite))
}

func (s *migrateSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts(
				"identity_migrate",
				definition.WithUserName("ant"),
				definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false),
			),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *migrateSuite) TestPostMigrateAddsSearchableColumnsAndSupportsSearchQueries() {
	ctx := (&security.AuthenticationClaims{
		TenantID:    "tenant-migrate",
		PartitionID: "partition-migrate",
		RegisteredClaims: jwt.RegisteredClaims{
			Subject: "profile-migrate",
		},
	}).ClaimsToContext(s.T().Context())

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() {
		cleanup(ctx)
	})

	// frame enforces tenant isolation via Postgres RLS, and the
	// testcontainer superuser bypasses RLS even with FORCE. rlstest
	// drops every connection to an unprivileged role once Enable is
	// called (after migration + grants below) so the searchable-column
	// queries here run with the same isolation as production.
	s.Require().NoError(rlstest.CreateRole(ctx, dsn.String()))
	rlsProv := rlstest.New()

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("identity-migrate-test"),
		frame.WithTenancyProvider(rlsProv),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() {
		svc.Stop(ctx)
	})
	svc.Init(ctx)

	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	migrationModels := []any{
		&models.Organization{},
		&models.Branch{},
		&models.Agent{},
		&models.AgentBranch{},
		&models.Client{},
		&models.ClientGroup{},
		&models.Membership{},
		&models.Investor{},
		&models.WorkforceMember{},
		&models.Department{},
		&models.Position{},
		&models.PositionAssignment{},
		&models.InternalTeam{},
		&models.TeamMembership{},
		&models.AccessRoleAssignment{},
		&models.ClientDataEntry{},
		&models.ClientDataEntryHistory{},
		&models.FormTemplate{},
		&models.FormSubmission{},
		&models.ClientRelationship{},
	}

	superDB := dbPool.DB(ctx, false)
	s.Require().NoError(superDB.AutoMigrate(migrationModels...))
	s.Require().NoError(postMigrate(ctx, dbPool))

	// Raw AutoMigrate does not run frame's tenancy install, so install
	// the RLS policies explicitly, grant the test role access, then
	// flip queries onto the unprivileged role.
	enrolled, err := tenancy.EnrolledModels(superDB, migrationModels)
	s.Require().NoError(err)
	s.Require().NoError(rlsProv.Install(ctx, superDB, enrolled))
	s.Require().NoError(rlstest.GrantAll(ctx, dsn.String()))
	rlsProv.Enable()

	s.assertSearchableColumnExists(ctx, dbPool, "organizations")
	s.assertSearchableColumnExists(ctx, dbPool, "org_units")
	s.assertSearchableColumnExists(ctx, dbPool, "agents")
	s.assertSearchableColumnExists(ctx, dbPool, "clients")
	s.assertSearchableColumnExists(ctx, dbPool, "client_groups")
	s.assertSearchableColumnExists(ctx, dbPool, "memberships")
	s.assertSearchableColumnExists(ctx, dbPool, "investors")

	org := &models.Organization{
		Name:       "Seed Capital",
		Code:       "seedcapital",
		State:      int32(commonv1.STATE_ACTIVE),
		Properties: data.JSONMap{"display_name": "Seed Capital Ltd"},
	}
	// GenID fills tenant/partition from the context claims; rows must
	// stay inside the session's tenancy scope or the RLS WITH CHECK
	// rejects the insert.
	org.GenID(ctx)
	s.Require().NoError(dbPool.DB(ctx, false).Create(org).Error)

	unit := &models.Branch{
		OrganizationID: org.GetID(),
		Name:           "Northern Region",
		Code:           "north-region",
		GeoID:          "gulu",
		UnitType:       2,
		State:          int32(commonv1.STATE_ACTIVE),
		Properties:     data.JSONMap{"label": "Regional Office"},
	}
	unit.GenID(ctx)
	s.Require().NoError(dbPool.DB(ctx, false).Create(unit).Error)

	agent := &models.Agent{
		OrganizationID: org.GetID(),
		Name:           "Alice Branch",
		ProfileID:      "profile-alice",
		State:          int32(commonv1.STATE_ACTIVE),
		Properties:     data.JSONMap{"contact_detail": "alice@example.com"},
	}
	agent.GenID(ctx)
	s.Require().NoError(dbPool.DB(ctx, false).Create(agent).Error)

	s.assertSearchMatches(ctx, dbPool, "organizations", "seedcapital")
	s.assertSearchMatches(ctx, dbPool, "org_units", "north")
	s.assertSearchMatches(ctx, dbPool, "agents", "profile-alice")
}

func (s *migrateSuite) assertSearchableColumnExists(ctx context.Context, dbPool pool.Pool, table string) {
	s.T().Helper()

	var exists bool
	err := dbPool.DB(ctx, true).Raw(`
		SELECT EXISTS (
			SELECT 1
			FROM information_schema.columns
			WHERE table_schema = 'public'
			  AND table_name = ?
			  AND column_name = 'searchable'
		)
	`, table).Scan(&exists).Error
	s.Require().NoError(err)
	s.True(exists, "expected searchable column on %s", table)
}

func (s *migrateSuite) assertSearchMatches(ctx context.Context, dbPool pool.Pool, table, query string) {
	s.T().Helper()

	var count int64
	err := dbPool.DB(ctx, true).Raw(
		"SELECT COUNT(*) FROM "+table+" WHERE searchable @@ websearch_to_tsquery('english', ?)",
		query,
	).Scan(&count).Error
	s.Require().NoError(err)
	s.Positive(count, "expected search match in %s for query %q", table, query)
}

func (s *migrateSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()

	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}
