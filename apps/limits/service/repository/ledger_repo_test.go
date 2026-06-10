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

type LedgerRepoSuite struct {
	frametests.FrameBaseTestSuite
}

func (s *LedgerRepoSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *LedgerRepoSuite) newEnv(tenantID, partitionID string) (context.Context, repository.LedgerRepository) {
	s.T().Helper()
	ctx, p, repo := s.newEnvWithPool(tenantID, partitionID)
	_ = p
	return ctx, repo
}

// newEnvWithPool is like newEnv but also returns the pool so tests that need to
// open explicit transactions (e.g. WindowSumTx/WindowCountTx) can do so.
func (s *LedgerRepoSuite) newEnvWithPool(
	tenantID, partitionID string,
) (context.Context, pool.Pool, repository.LedgerRepository) {
	s.T().Helper()

	ctx := s.T().Context()
	ctx = s.WithAuthClaims(ctx, tenantID, partitionID, "test-user")

	db := s.ledgerDatabaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-ledger-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctx, dbManager, ""))

	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	return ctx, dbPool, repository.NewLedgerRepository(ctx, dbPool, svc.WorkManager())
}

func (s *LedgerRepoSuite) ledgerDatabaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

func entry(rid string, amt int64, at time.Time) *models.LedgerEntry {
	return &models.LedgerEntry{
		ReservationID: rid,
		Action:        models.ActionLoanDisbursement,
		SubjectType:   models.SubjectClient,
		SubjectID:     "c1",
		CurrencyCode:  "KES",
		Amount:        amt,
		CommittedAt:   at,
	}
}

func (s *LedgerRepoSuite) TestCreateBatchAndWindowSum() {
	ctx, repo := s.newEnv("t-1", "p-1")
	now := time.Now().UTC()

	entries := []*models.LedgerEntry{
		entry("rid-1", 100, now.Add(-1*time.Hour)),
		entry("rid-2", 200, now.Add(-30*time.Minute)),
		entry("rid-3", 50, now.Add(-2*time.Hour)),
	}
	s.Require().NoError(repo.CreateBatch(ctx, entries))

	since := now.Add(-90 * time.Minute)
	sum, err := repo.WindowSum(ctx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"}, since)
	s.Require().NoError(err)
	// 100 (at -1h, in window) + 200 (at -30m, in window) = 300; 50 (at -2h) excluded
	s.Equal(int64(300), sum)
}

func (s *LedgerRepoSuite) TestMarkReversedExcludedFromSum() {
	ctx, repo := s.newEnv("t-1", "p-1")
	now := time.Now().UTC()

	entries := []*models.LedgerEntry{
		entry("rid-a", 500, now.Add(-10*time.Minute)),
		entry("rid-b", 300, now.Add(-5*time.Minute)),
	}
	s.Require().NoError(repo.CreateBatch(ctx, entries))

	s.Require().NoError(repo.MarkReversed(ctx, "rid-a", now))

	since := now.Add(-1 * time.Hour)
	sum, err := repo.WindowSum(ctx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"}, since)
	s.Require().NoError(err)
	// rid-a is reversed, only rid-b (300) should count
	s.Equal(int64(300), sum)
}

func (s *LedgerRepoSuite) TestWindowCount() {
	ctx, repo := s.newEnv("t-1", "p-1")
	now := time.Now().UTC()
	since := now.Add(-1 * time.Hour)

	entries := make([]*models.LedgerEntry, 5)
	for i := range entries {
		entries[i] = entry("rid-cnt-"+util.IDString(), 100, now.Add(-30*time.Minute))
	}
	s.Require().NoError(repo.CreateBatch(ctx, entries))

	count, err := repo.WindowCount(ctx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"}, since)
	s.Require().NoError(err)
	s.Equal(int64(5), count)
}

func (s *LedgerRepoSuite) TestSearchByAction() {
	ctx, repo := s.newEnv("t-1", "p-1")
	now := time.Now().UTC()

	entries := []*models.LedgerEntry{
		entry("rid-s1", 100, now.Add(-1*time.Hour)),
		entry("rid-s2", 200, now.Add(-30*time.Minute)),
		entry("rid-s3", 300, now.Add(-10*time.Minute)),
	}
	s.Require().NoError(repo.CreateBatch(ctx, entries))

	result, err := repo.Search(ctx, repository.LedgerSearchFilter{
		Action: models.ActionLoanDisbursement,
	}, 100, "")
	s.Require().NoError(err)
	s.Len(result.Items, 3)
}

// ─── WindowSumTx / WindowCountTx ─────────────────────────────────────────────
// These tests exercise the Tx variants directly against Postgres, verifying that
// the query executes correctly inside an explicit transaction handle.

func (s *LedgerRepoSuite) TestWindowSumTx_ReturnsCorrectSum() {
	ctx, dbPool, repo := s.newEnvWithPool("t-tx-1", "p-tx-1")
	now := time.Now().UTC()

	entries := []*models.LedgerEntry{
		entry("tx-rid-1", 100, now.Add(-10*time.Minute)),
		entry("tx-rid-2", 200, now.Add(-20*time.Minute)),
		entry("tx-rid-3", 300, now.Add(-30*time.Minute)),
	}
	s.Require().NoError(repo.CreateBatch(ctx, entries))

	tx := dbPool.DB(ctx, false).Begin()
	s.Require().NoError(tx.Error)
	defer tx.Rollback()

	since := now.Add(-1 * time.Hour)
	sum, err := repo.WindowSumTx(ctx, tx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"}, since)
	s.Require().NoError(err)
	s.Equal(int64(600), sum, "sum of 100+200+300 should be 600")
}

func (s *LedgerRepoSuite) TestWindowSumTx_ReversedEntriesExcluded() {
	ctx, dbPool, repo := s.newEnvWithPool("t-tx-2", "p-tx-2")
	now := time.Now().UTC()

	entries := []*models.LedgerEntry{
		entry("tx-rev-1", 100, now.Add(-10*time.Minute)),
		entry("tx-rev-2", 200, now.Add(-20*time.Minute)),
		entry("tx-rev-3", 300, now.Add(-30*time.Minute)),
	}
	s.Require().NoError(repo.CreateBatch(ctx, entries))
	// Mark the 200 entry as reversed.
	s.Require().NoError(repo.MarkReversed(ctx, "tx-rev-2", now))

	tx := dbPool.DB(ctx, false).Begin()
	s.Require().NoError(tx.Error)
	defer tx.Rollback()

	since := now.Add(-1 * time.Hour)
	sum, err := repo.WindowSumTx(ctx, tx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"}, since)
	s.Require().NoError(err)
	s.Equal(int64(400), sum, "reversed entry (200) must be excluded; expect 100+300=400")
}

func (s *LedgerRepoSuite) TestWindowSumTx_OutsideWindowExcluded() {
	ctx, dbPool, repo := s.newEnvWithPool("t-tx-3", "p-tx-3")
	now := time.Now().UTC()

	// Entry is 2 hours old; window is only 1 hour.
	entries := []*models.LedgerEntry{
		entry("tx-old-1", 500, now.Add(-2*time.Hour)),
	}
	s.Require().NoError(repo.CreateBatch(ctx, entries))

	tx := dbPool.DB(ctx, false).Begin()
	s.Require().NoError(tx.Error)
	defer tx.Rollback()

	since := now.Add(-1 * time.Hour)
	sum, err := repo.WindowSumTx(ctx, tx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"}, since)
	s.Require().NoError(err)
	s.Equal(int64(0), sum, "entry older than the window must be excluded")
}

func (s *LedgerRepoSuite) TestWindowCountTx_CountsActiveOnly() {
	ctx, dbPool, repo := s.newEnvWithPool("t-tx-4", "p-tx-4")
	now := time.Now().UTC()

	entries := make([]*models.LedgerEntry, 5)
	for i := range entries {
		entries[i] = entry("tx-cnt-"+util.IDString(), 100, now.Add(-30*time.Minute))
	}
	s.Require().NoError(repo.CreateBatch(ctx, entries))
	// Reverse one entry.
	s.Require().NoError(repo.MarkReversed(ctx, entries[0].ReservationID, now))

	tx := dbPool.DB(ctx, false).Begin()
	s.Require().NoError(tx.Error)
	defer tx.Rollback()

	since := now.Add(-1 * time.Hour)
	count, err := repo.WindowCountTx(ctx, tx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"}, since)
	s.Require().NoError(err)
	s.Equal(int64(4), count, "reversed entry must not be counted; expect 4 active out of 5")
}

func (s *LedgerRepoSuite) TestWindowSumTx_AppliesTenantPartition() {
	// Use two isolated environments to simulate two tenants.
	ctxA, dbPoolA, repoA := s.newEnvWithPool("t-ta", "p-ta")
	ctxB, _, repoB := s.newEnvWithPool("t-tb", "p-tb")
	now := time.Now().UTC()

	// Insert 500 for tenant-A and 999 for tenant-B.
	s.Require().NoError(repoA.CreateBatch(ctxA, []*models.LedgerEntry{
		entry("tx-part-a1", 500, now.Add(-10*time.Minute)),
	}))
	s.Require().NoError(repoB.CreateBatch(ctxB, []*models.LedgerEntry{
		entry("tx-part-b1", 999, now.Add(-10*time.Minute)),
	}))

	// Open a tx scoped to tenant-A's pool and run WindowSumTx with ctxA.
	tx := dbPoolA.DB(ctxA, false).Begin()
	s.Require().NoError(tx.Error)
	defer tx.Rollback()

	since := now.Add(-1 * time.Hour)
	sum, err := repoA.WindowSumTx(ctxA, tx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"}, since)
	s.Require().NoError(err)
	s.Equal(int64(500), sum, "WindowSumTx must only see tenant-A's entries")
}

func TestLedgerRepoSuite(t *testing.T) {
	suite.Run(t, new(LedgerRepoSuite))
}
