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
	"sync"
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

	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/apps/seed/service/repository"
)

type seedRepoSuite struct {
	frametests.FrameBaseTestSuite
}

func TestSeedRepoSuite(t *testing.T) {
	suite.Run(t, new(seedRepoSuite))
}

func (s *seedRepoSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts(
				"seed_repo",
				definition.WithUserName("ant"),
				definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false),
			),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

type seedEnv struct {
	ctx      context.Context
	profiles repository.CreditProfileRepository
	requests repository.LoanRequestRepository
	tiers    repository.CreditTierRepository
	dbPool   pool.Pool
}

func (s *seedRepoSuite) newEnv() *seedEnv {
	s.T().Helper()

	ctx := (&security.AuthenticationClaims{
		TenantID:         "tenant-seed",
		PartitionID:      "partition-seed",
		RegisteredClaims: jwt.RegisteredClaims{Subject: "profile-seed"},
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
		frame.WithName("seed-repo-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)
	s.Require().NoError(repository.MigrateForTest(ctx, dbPool))

	workMan := svc.WorkManager()
	return &seedEnv{
		ctx:      ctx,
		profiles: repository.NewCreditProfileRepository(ctx, dbPool, workMan),
		requests: repository.NewLoanRequestRepository(ctx, dbPool, workMan),
		tiers:    repository.NewCreditTierRepository(ctx, dbPool, workMan),
		dbPool:   dbPool,
	}
}

func (s *seedRepoSuite) ensureProfile(e *seedEnv, clientID string) *models.CreditProfile {
	s.T().Helper()
	profile, err := e.profiles.Ensure(e.ctx, clientID, "KES", "seed", nil)
	s.Require().NoError(err)
	return profile
}

// The counter updates have to actually land; a WHERE that matches nothing
// would leave every profile stuck at its provisioning values.
func (s *seedRepoSuite) TestAtomicCountersLand() {
	e := s.newEnv()
	profile := s.ensureProfile(e, "client-counters")

	promoted, err := e.profiles.AtomicPromoteTier(e.ctx, profile.GetID(), 2, 250_000)
	s.Require().NoError(err)
	s.Require().Equal(int32(2), promoted.Tier)
	s.Require().Equal(int64(250_000), promoted.MaxLoanAmount)

	borrowed, err := e.profiles.AtomicRecordBorrowedAmount(e.ctx, profile.GetID(), 100_000)
	s.Require().NoError(err)
	s.Require().Equal(int64(100_000), borrowed.TotalBorrowed)
	s.Require().NotNil(borrowed.FirstBorrowedAt)

	repaid, err := e.profiles.AtomicRecordRepayment(e.ctx, profile.GetID(), 110_000)
	s.Require().NoError(err)
	s.Require().Equal(int32(1), repaid.SuccessfulRepayments)
	s.Require().Equal(int64(110_000), repaid.TotalRepaid)

	suspended, err := e.profiles.AtomicSetStatus(e.ctx, profile.GetID(), models.CreditProfileStatusSuspended)
	s.Require().NoError(err)
	s.Require().Equal(int32(models.CreditProfileStatusSuspended), suspended.Status)
}

// Only one concurrent loan request may take the client's outstanding-loan slot.
func (s *seedRepoSuite) TestReserveLoanSlotIsExclusive() {
	e := s.newEnv()
	profile := s.ensureProfile(e, "client-slot")

	const racers = 8
	var (
		wg   sync.WaitGroup
		mu   sync.Mutex
		wins int
	)
	for range racers {
		wg.Add(1)
		go func() {
			defer wg.Done()
			reserved, err := e.profiles.AtomicReserveLoanSlot(e.ctx, profile.GetID())
			if err == nil && reserved {
				mu.Lock()
				wins++
				mu.Unlock()
			}
		}()
	}
	wg.Wait()

	s.Require().Equal(1, wins, "exactly one request may reserve the outstanding-loan slot")

	stored, err := e.profiles.GetByID(e.ctx, profile.GetID())
	s.Require().NoError(err)
	s.Require().Equal(int32(1), stored.OutstandingLoanCount)

	// Releasing the slot makes it claimable again.
	s.Require().NoError(e.profiles.AtomicReleaseLoanSlot(e.ctx, profile.GetID()))
	reserved, err := e.profiles.AtomicReserveLoanSlot(e.ctx, profile.GetID())
	s.Require().NoError(err)
	s.Require().True(reserved)
}

// The idempotency index has to be partial: legacy rows with no key must
// coexist, while two rows with the same key must not.
func (s *seedRepoSuite) TestIdempotencyKeyUniquenessIsPartial() {
	e := s.newEnv()

	for range 2 {
		lr := &models.LoanRequest{ClientID: "client-legacy", CurrencyCode: "KES", Amount: 1}
		lr.GenID(e.ctx)
		s.Require().NoError(e.requests.Create(e.ctx, lr))
	}

	first := &models.LoanRequest{ClientID: "client-key", CurrencyCode: "KES", Amount: 1, IdempotencyKey: "key-1"}
	first.GenID(e.ctx)
	s.Require().NoError(e.requests.Create(e.ctx, first))

	second := &models.LoanRequest{ClientID: "client-key", CurrencyCode: "KES", Amount: 1, IdempotencyKey: "key-1"}
	second.GenID(e.ctx)
	err := e.requests.Create(e.ctx, second)
	s.Require().Error(err)
	s.Require().True(data.ErrorIsDuplicateKey(err), "expected a duplicate key error, got %v", err)

	stored, err := e.requests.GetByIdempotencyKey(e.ctx, "key-1")
	s.Require().NoError(err)
	s.Require().Equal(first.GetID(), stored.GetID())
}

// The setup job's ladder must be provisioned and re-runnable.
func (s *seedRepoSuite) TestEnsureTierLadderIsIdempotent() {
	e := s.newEnv()

	spec := "1:0:500000:2400:30:Starter,2:1:1500000:2200:30:Builder"
	tiers, err := repository.ParseTierLadder(spec, "seed", "KES")
	s.Require().NoError(err)
	s.Require().Len(tiers, 2)

	s.Require().NoError(repository.EnsureTierLadder(e.ctx, e.dbPool, tiers))

	rerun, err := repository.ParseTierLadder(spec, "seed", "KES")
	s.Require().NoError(err)
	s.Require().NoError(repository.EnsureTierLadder(e.ctx, e.dbPool, rerun))

	stored, err := e.tiers.ListForProduct(e.ctx, "seed", "KES")
	s.Require().NoError(err)
	s.Require().Len(stored, 2)
	s.Require().Equal(int32(1), stored[0].Tier)
	s.Require().Equal(int64(500_000), stored[0].MaxLoanAmount)
	s.Require().Equal("Builder", stored[1].Name)
}

// An unset override provisions the shipped default ladder.
func (s *seedRepoSuite) TestParseTierLadderFallsBackToDefault() {
	tiers, err := repository.ParseTierLadder("", "seed", "KES")
	s.Require().NoError(err)
	s.Require().NotEmpty(tiers)
	s.Require().Equal(int32(1), tiers[0].Tier)
	s.Require().Positive(tiers[0].MaxLoanAmount)
}

func (s *seedRepoSuite) TestParseTierLadderRejectsMalformedEntries() {
	for _, spec := range []string{"1:0:500000:2400", "a:0:1:1:1", "1:0:0:2400:30"} {
		_, err := repository.ParseTierLadder(spec, "seed", "KES")
		s.Require().Error(err, "spec %q should be rejected", spec)
	}
}

// A paid-off loan request is completed exactly once; a released claim can be
// taken again.
func (s *seedRepoSuite) TestClaimCompletionIsExclusive() {
	e := s.newEnv()
	lr := &models.LoanRequest{ClientID: "client-done", CurrencyCode: "KES", Amount: 1, LoanAccountID: "loan-done"}
	lr.GenID(e.ctx)
	s.Require().NoError(e.requests.Create(e.ctx, lr))

	at := time.Now().UTC().Truncate(time.Microsecond)
	first, err := e.requests.ClaimCompletion(e.ctx, lr.GetID(), at)
	s.Require().NoError(err)
	s.True(first)
	second, err := e.requests.ClaimCompletion(e.ctx, lr.GetID(), at.Add(time.Second))
	s.Require().NoError(err)
	s.False(second, "a second delivery does not complete it again")

	s.Require().NoError(e.requests.ReleaseCompletion(e.ctx, lr.GetID(), at))
	again, err := e.requests.ClaimCompletion(e.ctx, lr.GetID(), at)
	s.Require().NoError(err)
	s.True(again, "a released claim is retried")
}
