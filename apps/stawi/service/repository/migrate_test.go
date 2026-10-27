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

package repository_test

import (
	"context"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/frametests"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/frame/v3/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	"github.com/antinvestor/service-fintech/pkg/constants"
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
				"stawi_migrate",
				definition.WithUserName("ant"),
				definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false),
			),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

type migrateEnv struct {
	ctx     context.Context
	periods repository.PeriodRepository
	tenures repository.TenureRepository
	offers  repository.LoanOfferRepository
	notices repository.NoticeRepository
}

func (s *migrateSuite) newEnv() *migrateEnv {
	s.T().Helper()

	ctx := (&security.AuthenticationClaims{
		TenantID:         "tenant-stawi",
		PartitionID:      "partition-stawi",
		RegisteredClaims: jwt.RegisteredClaims{Subject: "profile-stawi"},
	}).ClaimsToContext(s.T().Context())

	var db definition.DependancyConn
	for _, r := range s.Resources() {
		if r.Name() == testpostgres.PostgresqlDBImage && r.GetDS(ctx).IsDB() {
			db = r
		}
	}
	s.Require().NotNil(db, "postgres resource not found")

	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("stawi-migrate-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)
	s.Require().NoError(repository.MigrateForTest(ctx, dbPool))

	workMan := svc.WorkManager()
	return &migrateEnv{
		ctx:     ctx,
		periods: repository.NewPeriodRepository(ctx, dbPool, workMan),
		tenures: repository.NewTenureRepository(ctx, dbPool, workMan),
		offers:  repository.NewLoanOfferRepository(ctx, dbPool, workMan),
		notices: repository.NewNoticeRepository(ctx, dbPool, workMan),
	}
}

func (s *migrateSuite) newPeriod(
	ctx context.Context,
	groupID, tenureID, parentID string,
	position int32,
) *models.Period {
	s.T().Helper()
	start := time.Now().UTC()
	end := start.AddDate(0, 0, 7)
	period := &models.Period{
		GroupID:        groupID,
		TenureID:       tenureID,
		StartDate:      &start,
		EndDate:        &end,
		Position:       position,
		ParentPeriodID: parentID,
		State:          int32(constants.StateActive),
	}
	period.GenID(ctx)
	return period
}

// Before the partial index, every first period stored parent_period_id = ”
// and a plain unique index let exactly one group in the deployment open one.
func (s *migrateSuite) TestEveryTenureCanOpenItsFirstPeriod() {
	e := s.newEnv()

	for _, group := range []string{"group-a", "group-b", "group-c"} {
		period := s.newPeriod(e.ctx, group, "tenure-"+group, "", 1)
		s.Require().NoError(e.periods.Create(e.ctx, period),
			"group %s must be able to open its first period", group)
	}
}

// A named parent may still only be claimed once: two periods cannot both
// follow the same predecessor.
func (s *migrateSuite) TestParentPeriodIsStillUnique() {
	e := s.newEnv()

	first := s.newPeriod(e.ctx, "group-d", "tenure-d", "", 1)
	s.Require().NoError(e.periods.Create(e.ctx, first))

	second := s.newPeriod(e.ctx, "group-d", "tenure-d", first.GetID(), 2)
	s.Require().NoError(e.periods.Create(e.ctx, second))

	duplicate := s.newPeriod(e.ctx, "group-d", "tenure-d", first.GetID(), 3)
	err := e.periods.Create(e.ctx, duplicate)
	s.Require().Error(err)
	s.Require().True(data.ErrorIsDuplicateKey(err), "expected a duplicate key error, got %v", err)
}

// One period per position within a tenure.
func (s *migrateSuite) TestPeriodPositionIsUniquePerTenure() {
	e := s.newEnv()

	first := s.newPeriod(e.ctx, "group-e", "tenure-e", "", 1)
	s.Require().NoError(e.periods.Create(e.ctx, first))

	clash := s.newPeriod(e.ctx, "group-e", "tenure-e", "", 1)
	err := e.periods.Create(e.ctx, clash)
	s.Require().Error(err)
	s.Require().True(data.ErrorIsDuplicateKey(err), "expected a duplicate key error, got %v", err)
}

// A group may only hold one active tenure, but closed ones may pile up.
func (s *migrateSuite) TestOneActiveTenurePerGroup() {
	e := s.newEnv()

	start := time.Now().UTC()
	active := &models.Tenure{GroupID: "group-f", StartDate: &start, Duration: 52, Position: 1,
		State: int32(constants.StateActive)}
	active.GenID(e.ctx)
	s.Require().NoError(e.tenures.Create(e.ctx, active))

	clash := &models.Tenure{GroupID: "group-f", StartDate: &start, Duration: 52, Position: 2,
		State: int32(constants.StateActive)}
	clash.GenID(e.ctx)
	err := e.tenures.Create(e.ctx, clash)
	s.Require().Error(err)
	s.Require().True(data.ErrorIsDuplicateKey(err), "expected a duplicate key error, got %v", err)

	closed := &models.Tenure{GroupID: "group-f", StartDate: &start, Duration: 52, Position: 2,
		State: int32(constants.StateShutdown)}
	closed.GenID(e.ctx)
	s.Require().NoError(e.tenures.Create(e.ctx, closed))
}
