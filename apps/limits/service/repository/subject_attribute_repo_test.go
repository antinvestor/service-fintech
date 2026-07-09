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

	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/frametests"
	"github.com/pitabwire/frame/v2/frametests/definition"
	"github.com/pitabwire/frame/v2/frametests/deps/testpostgres"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"
	"gorm.io/datatypes"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

type SubjectAttributeRepoSuite struct {
	frametests.FrameBaseTestSuite
}

func (s *SubjectAttributeRepoSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *SubjectAttributeRepoSuite) subjectAttrDBResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

func (s *SubjectAttributeRepoSuite) newSubjectAttrEnv(tenantID, partitionID string) (
	context.Context,
	repository.SubjectAttributeRepository,
) {
	s.T().Helper()

	ctx := s.T().Context()
	ctx = s.WithAuthClaims(ctx, tenantID, partitionID, "test-user")

	db := s.subjectAttrDBResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-subject-attr-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctx, dbManager, ""))

	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	return ctx, repository.NewSubjectAttributeRepository(ctx, dbPool, svc.WorkManager())
}

func (s *SubjectAttributeRepoSuite) TestSubjectAttributeUpsertCreates() {
	ctx, repo := s.newSubjectAttrEnv("t-1", "p-1")

	snap := &models.SubjectAttributeSnapshot{
		SubjectType: models.SubjectClient,
		SubjectID:   "c-1",
		Attributes:  datatypes.JSON([]byte(`{"kyc_tier":"gold"}`)),
	}
	s.Require().NoError(repo.Upsert(ctx, snap))
	s.NotEmpty(snap.ID)

	got, err := repo.Get(ctx, models.SubjectClient, "c-1")
	s.Require().NoError(err)
	s.Require().NotNil(got)
	s.Equal(snap.ID, got.ID)
	s.JSONEq(`{"kyc_tier":"gold"}`, string(got.Attributes))
}

func (s *SubjectAttributeRepoSuite) TestSubjectAttributeUpsertUpdates() {
	ctx, repo := s.newSubjectAttrEnv("t-1", "p-1")

	snap := &models.SubjectAttributeSnapshot{
		SubjectType: models.SubjectClient,
		SubjectID:   "c-2",
		Attributes:  datatypes.JSON([]byte(`{"kyc_tier":"silver"}`)),
	}
	s.Require().NoError(repo.Upsert(ctx, snap))

	snap2 := &models.SubjectAttributeSnapshot{
		SubjectType: models.SubjectClient,
		SubjectID:   "c-2",
		Attributes:  datatypes.JSON([]byte(`{"kyc_tier":"platinum"}`)),
	}
	s.Require().NoError(repo.Upsert(ctx, snap2))

	got, err := repo.Get(ctx, models.SubjectClient, "c-2")
	s.Require().NoError(err)
	s.Require().NotNil(got)
	s.JSONEq(`{"kyc_tier":"platinum"}`, string(got.Attributes))
}

func (s *SubjectAttributeRepoSuite) TestSubjectAttributeGetMissing() {
	ctx, repo := s.newSubjectAttrEnv("t-1", "p-1")

	got, err := repo.Get(ctx, models.SubjectClient, "does-not-exist")
	s.Require().NoError(err)
	s.Nil(got)
}

func TestSubjectAttributeRepoSuite(t *testing.T) {
	suite.Run(t, new(SubjectAttributeRepoSuite))
}
