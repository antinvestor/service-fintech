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

package upsert_test

import (
	"context"
	"testing"

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

	"github.com/antinvestor/service-fintech/pkg/upsert"
)

// widget embeds BaseModel directly, like every domain model in this repo.
type widget struct {
	data.BaseModel
	Name string `gorm:"type:varchar(100)"`
	Code string `gorm:"type:varchar(50);uniqueIndex:uq_widget_code"`
}

// gadget provides SetVersion, like the stawi and identity group models.
type gadget struct {
	data.BaseModel
	Name string `gorm:"type:varchar(100)"`
}

func (g *gadget) SetVersion(v uint) { g.Version = v }

type upsertSuite struct {
	frametests.FrameBaseTestSuite
}

func TestUpsertSuite(t *testing.T) {
	suite.Run(t, new(upsertSuite))
}

func (s *upsertSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts(
				"pkg_upsert",
				definition.WithUserName("ant"),
				definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false),
			),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

type env struct {
	ctx     context.Context
	widgets datastore.BaseRepository[*widget]
	gadgets datastore.BaseRepository[*gadget]
}

func (s *upsertSuite) newEnv() *env {
	s.T().Helper()

	ctx := (&security.AuthenticationClaims{
		TenantID:         "tenant-upsert",
		PartitionID:      "partition-upsert",
		RegisteredClaims: jwt.RegisteredClaims{Subject: "profile-upsert"},
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
		frame.WithName("upsert-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)
	s.Require().NoError(dbPool.DB(ctx, false).AutoMigrate(&widget{}, &gadget{}))

	return &env{
		ctx: ctx,
		widgets: datastore.NewBaseRepository[*widget](
			ctx, dbPool, svc.WorkManager(), func() *widget { return &widget{} },
		),
		gadgets: datastore.NewBaseRepository[*gadget](
			ctx, dbPool, svc.WorkManager(), func() *gadget { return &gadget{} },
		),
	}
}

func (s *upsertSuite) TestCreateThenUpdateWithZeroVersionPayload() {
	e := s.newEnv()

	first := &widget{Name: "one", Code: "w1"}
	first.GenID(e.ctx)
	s.Require().NoError(upsert.ByID(e.ctx, e.widgets, first))

	stored, err := e.widgets.GetByID(e.ctx, first.GetID())
	s.Require().NoError(err)
	s.Require().Equal(uint(1), stored.GetVersion())

	// A payload rebuilt from an API object carries version 0. Before the
	// helper existed this update matched no row and reported success.
	second := &widget{Name: "two", Code: "w1"}
	second.ID = first.GetID()
	s.Require().NoError(upsert.ByID(e.ctx, e.widgets, second))

	stored, err = e.widgets.GetByID(e.ctx, first.GetID())
	s.Require().NoError(err)
	s.Require().Equal("two", stored.Name)
	s.Require().Equal(uint(2), stored.GetVersion())
}

func (s *upsertSuite) TestStalePayloadVersionStillLands() {
	e := s.newEnv()

	g := &gadget{Name: "v1"}
	g.GenID(e.ctx)
	s.Require().NoError(upsert.ByID(e.ctx, e.gadgets, g))

	g.Name = "v2"
	s.Require().NoError(upsert.ByID(e.ctx, e.gadgets, g))

	stale := &gadget{Name: "v3"}
	stale.ID = g.GetID()
	stale.Version = 1 // behind the stored version 2
	s.Require().NoError(upsert.ByID(e.ctx, e.gadgets, stale))

	stored, err := e.gadgets.GetByID(e.ctx, g.GetID())
	s.Require().NoError(err)
	s.Require().Equal("v3", stored.Name)
	s.Require().Equal(uint(3), stored.GetVersion())
}

func (s *upsertSuite) TestSecondaryUniqueViolationIsNotSwallowed() {
	e := s.newEnv()

	a := &widget{Name: "a", Code: "same"}
	a.GenID(e.ctx)
	s.Require().NoError(upsert.ByID(e.ctx, e.widgets, a))

	b := &widget{Name: "b", Code: "same"}
	b.GenID(e.ctx)
	err := upsert.ByID(e.ctx, e.widgets, b)
	s.Require().Error(err)
	s.Require().True(data.ErrorIsDuplicateKey(err), "expected duplicate key, got %v", err)

	_, err = e.widgets.GetByID(e.ctx, b.GetID())
	s.Require().True(data.ErrorIsNoRows(err))
}

func (s *upsertSuite) TestRejectsEntityWithoutID() {
	e := s.newEnv()
	s.Require().Error(upsert.ByID(e.ctx, e.widgets, &widget{Name: "no-id"}))
}
