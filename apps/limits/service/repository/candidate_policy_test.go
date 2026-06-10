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
)

type CandidatePolicySuite struct {
	frametests.FrameBaseTestSuite
}

func (s *CandidatePolicySuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *CandidatePolicySuite) candidateDBResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// newCandidateEnv creates an isolated DB, migrates it, and returns:
//   - a base context (no auth claims) for platform-scoped inserts,
//   - an org-A context for org-scoped inserts,
//   - the raw dbPool (for CandidatePolicyRepository),
//   - a PolicyRepository for inserting test rows (scoped to org-A),
//   - a factory func to create PolicyRepositories for arbitrary tenants.
func (s *CandidatePolicySuite) newCandidateEnv() (
	context.Context,
	context.Context,
	pool.Pool,
	repository.PolicyRepository,
	func(ctx context.Context) repository.PolicyRepository,
) {
	s.T().Helper()

	ctxBase := s.T().Context()

	db := s.candidateDBResource(ctxBase)
	dsn, cleanup, err := db.GetRandomisedDS(ctxBase, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctxBase) })

	// Start the Frame service with no auth claims so svc.Init does not inject a tenant.
	ctxBase, svc := frame.NewServiceWithContext(
		ctxBase,
		frame.WithName("limits-candidate-policy-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctxBase) })
	svc.Init(ctxBase)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctxBase, dbManager, ""))

	dbPool := dbManager.GetPool(ctxBase, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	workMan := svc.WorkManager()
	newRepo := func(ctx context.Context) repository.PolicyRepository {
		return repository.NewPolicyRepository(ctx, dbPool, workMan)
	}

	ctxOrgA := s.WithAuthClaims(ctxBase, "org-A", "p-1", "wf-1")
	policyRepo := newRepo(ctxOrgA)

	return ctxBase, ctxOrgA, dbPool, policyRepo, newRepo
}

func (s *CandidatePolicySuite) TestFindCandidates() {
	ctxBase, ctxOrgA, dbPool, policyRepo, newRepo := s.newCandidateEnv()

	now := time.Now().UTC()
	future := now.Add(2 * time.Hour)
	past := now.Add(-2 * time.Hour)

	// 1. Platform-scoped policy (tenant_id = ''): inserted with no-claims context so
	//    Frame's BeforeCreate leaves TenantID empty.
	platformPol := &models.Policy{
		Scope:         models.ScopePlatform,
		Action:        models.ActionLoanDisbursement,
		SubjectType:   models.SubjectClient,
		CurrencyCode:  "KES",
		LimitKind:     models.KindPerTxnMax,
		Value:         500_000,
		Mode:          models.ModeShadow,
		EffectiveFrom: past,
	}
	platformRepo := newRepo(ctxBase)
	s.Require().NoError(platformRepo.Save(ctxBase, platformPol))

	// 2. Org-A org-scoped policy: tenant_id = 'org-A'.
	orgAPol := &models.Policy{
		Scope:         models.ScopeOrg,
		Action:        models.ActionLoanDisbursement,
		SubjectType:   models.SubjectClient,
		CurrencyCode:  "KES",
		LimitKind:     models.KindPerTxnMax,
		Value:         1_000_000,
		Mode:          models.ModeEnforce,
		EffectiveFrom: past,
	}
	s.Require().NoError(policyRepo.Save(ctxOrgA, orgAPol))

	// 3. Org-A org_unit-scoped policy for branch-x.
	branchPol := &models.Policy{
		Scope:         models.ScopeOrgUnit,
		OrgUnitID:     "branch-x",
		Action:        models.ActionLoanDisbursement,
		SubjectType:   models.SubjectClient,
		CurrencyCode:  "KES",
		LimitKind:     models.KindPerTxnMax,
		Value:         200_000,
		Mode:          models.ModeEnforce,
		EffectiveFrom: past,
	}
	s.Require().NoError(policyRepo.Save(ctxOrgA, branchPol))

	// 4. Org-B policy: should NOT appear in results for org-A query.
	ctxOrgB := s.WithAuthClaims(ctxBase, "org-B", "p-1", "wf-1")
	orgBRepo := newRepo(ctxOrgB)
	orgBPol := &models.Policy{
		Scope:         models.ScopeOrg,
		Action:        models.ActionLoanDisbursement,
		SubjectType:   models.SubjectClient,
		CurrencyCode:  "KES",
		LimitKind:     models.KindPerTxnMax,
		Value:         99_000,
		Mode:          models.ModeEnforce,
		EffectiveFrom: past,
	}
	s.Require().NoError(orgBRepo.Save(ctxOrgB, orgBPol))

	// 5. Different action: should not match.
	diffActionPol := &models.Policy{
		Scope:         models.ScopeOrg,
		Action:        models.ActionSavingsDeposit,
		SubjectType:   models.SubjectClient,
		CurrencyCode:  "KES",
		LimitKind:     models.KindPerTxnMax,
		Value:         10_000,
		Mode:          models.ModeShadow,
		EffectiveFrom: past,
	}
	s.Require().NoError(policyRepo.Save(ctxOrgA, diffActionPol))

	// 6. Different currency (non-empty): should not match.
	diffCurrencyPol := &models.Policy{
		Scope:         models.ScopeOrg,
		Action:        models.ActionLoanDisbursement,
		SubjectType:   models.SubjectClient,
		CurrencyCode:  "USD",
		LimitKind:     models.KindPerTxnMax,
		Value:         10_000,
		Mode:          models.ModeShadow,
		EffectiveFrom: past,
	}
	s.Require().NoError(policyRepo.Save(ctxOrgA, diffCurrencyPol))

	// 7. Mode = off: should not match.
	modOffPol := &models.Policy{
		Scope:         models.ScopeOrg,
		Action:        models.ActionLoanDisbursement,
		SubjectType:   models.SubjectClient,
		CurrencyCode:  "KES",
		LimitKind:     models.KindPerTxnMax,
		Value:         10_000,
		Mode:          models.ModeOff,
		EffectiveFrom: past,
	}
	s.Require().NoError(policyRepo.Save(ctxOrgA, modOffPol))

	// 8. effective_from in the future: should not match.
	futurePol := &models.Policy{
		Scope:         models.ScopeOrg,
		Action:        models.ActionLoanDisbursement,
		SubjectType:   models.SubjectClient,
		CurrencyCode:  "KES",
		LimitKind:     models.KindPerTxnMax,
		Value:         10_000,
		Mode:          models.ModeShadow,
		EffectiveFrom: future,
	}
	s.Require().NoError(policyRepo.Save(ctxOrgA, futurePol))

	// Execute the query under test.
	candidateRepo := repository.NewCandidatePolicyRepository(dbPool)
	results, err := candidateRepo.FindCandidates(ctxBase, repository.CandidateQuery{
		Action:       models.ActionLoanDisbursement,
		CurrencyCode: "KES",
		TenantID:     "org-A",
		OrgUnitID:    "branch-x",
	})
	s.Require().NoError(err)

	// Collect result IDs for assertions.
	resultIDs := make(map[string]struct{}, len(results))
	for _, p := range results {
		resultIDs[p.ID] = struct{}{}
	}

	s.Len(results, 3, "expected exactly 3 matching policies")
	s.Contains(resultIDs, platformPol.ID, "platform-scoped policy should be included")
	s.Contains(resultIDs, orgAPol.ID, "org-A org policy should be included")
	s.Contains(resultIDs, branchPol.ID, "org-A branch-x policy should be included")

	s.NotContains(resultIDs, orgBPol.ID, "org-B policy must not appear")
	s.NotContains(resultIDs, diffActionPol.ID, "different action must not appear")
	s.NotContains(resultIDs, diffCurrencyPol.ID, "different currency must not appear")
	s.NotContains(resultIDs, modOffPol.ID, "mode=off policy must not appear")
	s.NotContains(resultIDs, futurePol.ID, "future effective_from policy must not appear")
}

func TestCandidatePolicySuite(t *testing.T) {
	suite.Run(t, new(CandidatePolicySuite))
}
