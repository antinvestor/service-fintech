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

	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/frametests"
	"github.com/pitabwire/frame/frametests/definition"
	"github.com/pitabwire/frame/frametests/deps/testpostgres"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
	"github.com/antinvestor/service-fintech/apps/limits/tests/rlstest"
)

type PolicyRepoSuite struct {
	frametests.FrameBaseTestSuite
}

func (s *PolicyRepoSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts(
				"limits_test",
				definition.WithUserName("test"),
			),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

// newEnv creates an isolated DB + migrated repo for each test. The
// service is wired with the rlstest provider so application queries
// run as a non-superuser, otherwise Postgres bypasses FORCE ROW LEVEL
// SECURITY for the testcontainer's superuser and the tenancy-isolation
// guarantees never actually get exercised.
func (s *PolicyRepoSuite) newEnv(tenantID, partitionID string) (context.Context, repository.PolicyRepository) {
	s.T().Helper()

	ctx := s.T().Context()
	ctx = s.WithAuthClaims(ctx, tenantID, partitionID, "test-user")

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	s.Require().NoError(rlstest.CreateRole(ctx, dsn.String()))

	rlsProv := rlstest.New()
	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-policy-test"),
		frame.WithTenancyProvider(rlsProv),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(Migrate(ctx, dbManager, ""))

	s.Require().NoError(rlstest.GrantAll(ctx, dsn.String()))
	rlsProv.Enable()

	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	return ctx, repository.NewPolicyRepository(ctx, dbPool, svc.WorkManager())
}

// Migrate calls the package-level Migrate using DefaultMigrationPoolName.
// In tests, DefaultMigrationPoolName and DefaultPoolName resolve to the same pool.
func Migrate(ctx context.Context, dbManager datastore.Manager, migrationPath string) error {
	return repository.Migrate(ctx, dbManager, migrationPath)
}

func (s *PolicyRepoSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

func (s *PolicyRepoSuite) TestSaveAndGet() {
	ctx, repo := s.newEnv("tenant-a", "partition-a")

	pol := &models.Policy{
		Scope:         models.ScopeOrg,
		Action:        models.ActionLoanDisbursement,
		SubjectType:   models.SubjectClient,
		CurrencyCode:  "KES",
		LimitKind:     models.KindPerTxnMax,
		Value:         1_000_000,
		Mode:          models.ModeShadow,
		EffectiveFrom: time.Now().UTC(),
	}
	s.Require().NoError(repo.Save(ctx, pol))
	s.Require().NotEmpty(pol.ID)

	got, err := repo.Get(ctx, pol.ID)
	s.Require().NoError(err)
	s.Equal(pol.Value, got.Value)
	s.Equal("tenant-a", got.TenantID)
}

func (s *PolicyRepoSuite) TestSearchByActionAndScope() {
	ctx, repo := s.newEnv("tenant-a", "partition-a")

	for i := 0; i < 3; i++ {
		s.Require().NoError(repo.Save(ctx, &models.Policy{
			Scope:         models.ScopeOrg,
			Action:        models.ActionLoanDisbursement,
			SubjectType:   models.SubjectClient,
			CurrencyCode:  "KES",
			LimitKind:     models.KindPerTxnMax,
			Value:         int64(1000 + i),
			Mode:          models.ModeShadow,
			EffectiveFrom: time.Now().UTC(),
		}))
	}

	out, err := repo.Search(ctx, repository.PolicySearchFilter{
		Action: models.ActionLoanDisbursement,
	}, 100, "")
	s.Require().NoError(err)
	s.Len(out.Items, 3)
}

func (s *PolicyRepoSuite) TestTenantIsolation() {
	// Each newEnv call creates its own isolated DB for that tenant.
	// To test cross-tenant isolation in the same DB, we need a shared DB
	// with two different auth contexts.
	ctx := s.T().Context()

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctxA := s.WithAuthClaims(ctx, "tenant-a", "partition-a", "user-a")
	ctxB := s.WithAuthClaims(ctx, "tenant-b", "partition-a", "user-b")

	s.Require().NoError(rlstest.CreateRole(ctxA, dsn.String()))

	rlsProv := rlstest.New()
	ctxA, svc := frame.NewServiceWithContext(
		ctxA,
		frame.WithName("limits-isolation-test"),
		frame.WithTenancyProvider(rlsProv),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctxA) })
	svc.Init(ctxA)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctxA, dbManager, ""))

	s.Require().NoError(rlstest.GrantAll(ctxA, dsn.String()))
	rlsProv.Enable()

	dbPool := dbManager.GetPool(ctxA, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	workMan := svc.WorkManager()
	repoA := repository.NewPolicyRepository(ctxA, dbPool, workMan)
	repoB := repository.NewPolicyRepository(ctxB, dbPool, workMan)

	s.Require().NoError(repoA.Save(ctxA, &models.Policy{
		Scope:         models.ScopeOrg,
		Action:        models.ActionLoanRequest,
		SubjectType:   models.SubjectClient,
		CurrencyCode:  "KES",
		LimitKind:     models.KindPerTxnMax,
		Value:         1,
		Mode:          models.ModeShadow,
		EffectiveFrom: time.Now().UTC(),
	}))

	out, err := repoB.Search(ctxB, repository.PolicySearchFilter{}, 10, "")
	s.Require().NoError(err)
	s.Empty(out.Items, "tenant B should not see tenant A's policies")
}

func (s *PolicyRepoSuite) TestSoftDelete() {
	ctx, repo := s.newEnv("tenant-a", "partition-a")

	pol := &models.Policy{
		Scope:         models.ScopeOrg,
		Action:        models.ActionFundingInflow,
		SubjectType:   models.SubjectClient,
		CurrencyCode:  "KES",
		LimitKind:     models.KindPerTxnMax,
		Value:         1,
		Mode:          models.ModeShadow,
		EffectiveFrom: time.Now().UTC(),
	}
	s.Require().NoError(repo.Save(ctx, pol))
	s.Require().NoError(repo.Delete(ctx, pol.ID))

	_, err := repo.Get(ctx, pol.ID)
	s.Require().Error(err)
}

func TestPolicyRepoSuite(t *testing.T) {
	suite.Run(t, new(PolicyRepoSuite))
}
