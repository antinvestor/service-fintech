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

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/frametests"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/frame/v3/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/workerpool"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

// migrationPath points at the SQL migrations shipped with the service, so the
// suite exercises the same schema a deployment gets.
const migrationPath = "../../migrations"

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
				"loans_repository",
				definition.WithUserName("ant"),
				definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false),
			),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

type migrateEnv struct {
	ctx      context.Context
	products repository.LoanProductRepository
	dbPool   pool.Pool
}

func (s *migrateSuite) newEnv() *migrateEnv {
	s.T().Helper()

	ctx := (&security.AuthenticationClaims{
		TenantID:         "tenant-loans",
		PartitionID:      "partition-loans",
		RegisteredClaims: jwt.RegisteredClaims{Subject: "profile-loans"},
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
		frame.WithName("loans-repository-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	s.Require().NoError(repository.Migrate(ctx, svc.DatastoreManager(), migrationPath))

	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	workMan := svc.WorkManager()
	return &migrateEnv{
		ctx:      ctx,
		products: repository.NewLoanProductRepository(ctx, dbPool, workMan),
		dbPool:   dbPool,
	}
}

// TestFullTextSearchFindsProduct is the regression test for search against a
// column the schema never created: every text query used to fail outright.
func (s *migrateSuite) TestFullTextSearchFindsProduct() {
	e := s.newEnv()

	product := &models.LoanProduct{
		OrganizationID: "org-1",
		Name:           "Harvest Boost Loan",
		Code:           "HARVEST",
		Description:    "Seasonal working capital for smallholder farmers",
		CurrencyCode:   "KES",
		MinAmount:      1000,
		MaxAmount:      500000,
		MinTermDays:    30,
		MaxTermDays:    365,
	}
	product.GenID(e.ctx)
	s.Require().NoError(e.products.Create(e.ctx, product))

	found := s.searchProducts(e, "harvest")
	s.Require().Len(found, 1)
	s.Require().Equal(product.GetID(), found[0].GetID())

	s.Require().Empty(s.searchProducts(e, "mortgage"))

	// The trigger has to keep the column current, not only populate it on
	// insert, or a renamed product stays findable only under its old name.
	product.Name = "Irrigation Boost Loan"
	_, err := e.products.Update(e.ctx, product)
	s.Require().NoError(err)

	s.Require().Len(s.searchProducts(e, "irrigation"), 1)
}

func (s *migrateSuite) searchProducts(e *migrateEnv, query string) []*models.LoanProduct {
	s.T().Helper()

	results, err := e.products.Search(e.ctx, data.NewSearchQuery(
		data.WithSearchFiltersOrByValue(map[string]any{
			"searchable @@ websearch_to_tsquery( 'english', ?) ": query,
		}),
	))
	s.Require().NoError(err)

	var found []*models.LoanProduct
	s.Require().NoError(workerpool.ConsumeResultStream(e.ctx, results,
		func(batch []*models.LoanProduct) error {
			found = append(found, batch...)
			return nil
		}))
	return found
}

// TestLoanRequestClaimIsExclusive covers the conditional claim that stops a
// second LoanAccountCreate from reserving funding for a request that already
// has a loan.
func (s *migrateSuite) TestLoanRequestClaimIsExclusive() {
	e := s.newEnv()

	requests := repository.NewLoanRequestRepository(e.ctx, e.dbPool, nil)

	lr := &models.LoanRequest{
		ClientID:          "client-1",
		OrganizationID:    "org-1",
		CurrencyCode:      "KES",
		RequestedAmount:   50000,
		ApprovedAmount:    50000,
		RequestedTermDays: 90,
		ApprovedTermDays:  90,
		Status:            int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED),
	}
	lr.GenID(e.ctx)
	s.Require().NoError(requests.Create(e.ctx, lr))

	claimed, err := requests.ClaimForLoanCreation(e.ctx, lr.GetID(), "loan-account-1")
	s.Require().NoError(err)
	s.Require().True(claimed)

	second, err := requests.ClaimForLoanCreation(e.ctx, lr.GetID(), "loan-account-2")
	s.Require().NoError(err)
	s.Require().False(second, "a second claim on the same request must not succeed")

	stored, err := requests.GetByID(e.ctx, lr.GetID())
	s.Require().NoError(err)
	s.Require().Equal("loan-account-1", stored.LoanAccountID)
	s.Require().Equal(
		int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_LOAN_CREATED),
		stored.Status,
	)
}

// TestPenaltyDeltaMovesBalanceAndReverses covers the charge-and-waive pair that
// keeps penalties_outstanding and total_outstanding in step.
func (s *migrateSuite) TestPenaltyDeltaMovesBalanceAndReverses() {
	e := s.newEnv()

	balances := repository.NewLoanBalanceRepository(e.ctx, e.dbPool, nil)

	balance := &models.LoanBalance{
		LoanAccountID:        "loan-account-1",
		CurrencyCode:         "KES",
		PrincipalOutstanding: 100000,
		TotalOutstanding:     100000,
	}
	balance.GenID(e.ctx)
	s.Require().NoError(balances.Create(e.ctx, balance))

	charged, err := balances.ApplyPenaltyDelta(e.ctx, "loan-account-1", 2500)
	s.Require().NoError(err)
	s.Require().Equal(int64(2500), charged.PenaltiesOutstanding)
	s.Require().Equal(int64(102500), charged.TotalOutstanding)

	waived, err := balances.ApplyPenaltyDelta(e.ctx, "loan-account-1", -2500)
	s.Require().NoError(err)
	s.Require().Equal(int64(0), waived.PenaltiesOutstanding)
	s.Require().Equal(int64(100000), waived.TotalOutstanding)
}

// TestPenaltyMarkIsClaimedOnce covers the mark that stops a daily delinquency
// scan from charging the same installment every day it stays overdue.
func (s *migrateSuite) TestPenaltyMarkIsClaimedOnce() {
	e := s.newEnv()

	entries := repository.NewScheduleEntryRepository(e.ctx, e.dbPool, nil)

	entry := &models.ScheduleEntry{
		ScheduleID:        "schedule-1",
		LoanAccountID:     "loan-account-1",
		InstallmentNumber: 1,
		CurrencyCode:      "KES",
		PrincipalDue:      10000,
		TotalDue:          10000,
		Outstanding:       10000,
	}
	entry.GenID(e.ctx)
	s.Require().NoError(entries.Create(e.ctx, entry))

	claimed, err := entries.MarkPenaltyApplied(e.ctx, entry.GetID())
	s.Require().NoError(err)
	s.Require().True(claimed)

	second, err := entries.MarkPenaltyApplied(e.ctx, entry.GetID())
	s.Require().NoError(err)
	s.Require().False(second, "an installment must only be penalised once")

	stored, err := entries.GetByID(e.ctx, entry.GetID())
	s.Require().NoError(err)
	s.Require().Equal(true, stored.Properties["penalty_applied"])
}

// Two disbursements with different idempotency keys for one loan cannot both
// be live: the second insert is answered with the first row and
// ErrLiveDisbursementExists, before any money moves.
func (s *migrateSuite) TestOneLiveDisbursementPerLoan() {
	e := s.newEnv()
	repo := repository.NewDisbursementRepository(e.ctx, e.dbPool, nil)

	newDisb := func(key string) *models.Disbursement {
		d := &models.Disbursement{
			LoanAccountID:  "loan-live-1",
			Amount:         50_000,
			CurrencyCode:   "KES",
			Status:         int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_PROCESSING),
			IdempotencyKey: key,
		}
		d.GenID(e.ctx)
		d.PartitionID = "partition-1"
		d.TenantID = "tenant-1"
		return d
	}

	first := newDisb("key-a")
	stored, created, err := repo.ClaimIdempotencyKey(e.ctx, first)
	s.Require().NoError(err)
	s.Require().True(created)
	s.Require().Equal(first.GetID(), stored.GetID())

	second := newDisb("key-b")
	live, created, err := repo.ClaimIdempotencyKey(e.ctx, second)
	s.Require().ErrorIs(err, repository.ErrLiveDisbursementExists)
	s.Require().False(created)
	s.Require().Equal(first.GetID(), live.GetID(), "the loser is told which row owns the payout")

	// The same key is a retry, not a second payout.
	again := newDisb("key-a")
	stored, created, err = repo.ClaimIdempotencyKey(e.ctx, again)
	s.Require().NoError(err)
	s.Require().False(created)
	s.Require().Equal(first.GetID(), stored.GetID())

	// Once the live row is failed, a fresh key may try again.
	_, err = repo.UpdateColumns(e.ctx, first.GetID(), map[string]any{
		"status": int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_FAILED),
	})
	s.Require().NoError(err)
	third := newDisb("key-c")
	_, created, err = repo.ClaimIdempotencyKey(e.ctx, third)
	s.Require().NoError(err)
	s.Require().True(created)
}

// One late penalty per installment: a second claim for the same installment
// and type hands back the first row instead of inserting another.
func (s *migrateSuite) TestOnePenaltyPerInstallmentAndType() {
	e := s.newEnv()
	repo := repository.NewPenaltyRepository(e.ctx, e.dbPool, nil)

	newPenalty := func(amount int64) *models.Penalty {
		p := &models.Penalty{
			LoanAccountID: "loan-pen-1", ScheduleEntryID: "entry-1", Amount: amount, CurrencyCode: "KES",
			PenaltyType: int32(loansv1.PenaltyType_PENALTY_TYPE_LATE_PAYMENT),
		}
		p.GenID(e.ctx)
		p.PartitionID = "partition-1"
		p.TenantID = "tenant-1"
		return p
	}

	first := newPenalty(500)
	stored, created, err := repo.ClaimForEntry(e.ctx, first)
	s.Require().NoError(err)
	s.Require().True(created)
	s.Require().Equal(first.GetID(), stored.GetID())

	second := newPenalty(500)
	stored, created, err = repo.ClaimForEntry(e.ctx, second)
	s.Require().NoError(err)
	s.Require().False(created, "the installment is already penalised")
	s.Require().Equal(first.GetID(), stored.GetID())

	// A different type on the same installment is a different slot.
	other := newPenalty(100)
	other.PenaltyType = int32(loansv1.PenaltyType_PENALTY_TYPE_DEFAULT)
	_, created, err = repo.ClaimForEntry(e.ctx, other)
	s.Require().NoError(err)
	s.Require().True(created)
}

// Charging a penalty to the balance happens once, however many times the
// charge is attempted, and the marker lives in the same transaction.
func (s *migrateSuite) TestPenaltyBalanceChargeIsOnce() {
	e := s.newEnv()
	penalties := repository.NewPenaltyRepository(e.ctx, e.dbPool, nil)
	balances := repository.NewLoanBalanceRepository(e.ctx, e.dbPool, nil)

	balance := &models.LoanBalance{LoanAccountID: "loan-charge-1", CurrencyCode: "KES", TotalOutstanding: 10_000}
	balance.GenID(e.ctx)
	s.Require().NoError(balances.Create(e.ctx, balance))

	penalty := &models.Penalty{LoanAccountID: "loan-charge-1", Amount: 500, CurrencyCode: "KES",
		PenaltyType: int32(loansv1.PenaltyType_PENALTY_TYPE_LATE_PAYMENT)}
	penalty.GenID(e.ctx)
	s.Require().NoError(penalties.Create(e.ctx, penalty))

	charged, err := penalties.ChargeBalanceOnce(e.ctx, penalty)
	s.Require().NoError(err)
	s.Require().True(charged)
	again, err := penalties.ChargeBalanceOnce(e.ctx, penalty)
	s.Require().NoError(err)
	s.Require().False(again, "a second attempt must not charge again")

	stored, err := balances.GetByLoanAccountID(e.ctx, "loan-charge-1")
	s.Require().NoError(err)
	s.Require().Equal(int64(500), stored.PenaltiesOutstanding)
	s.Require().Equal(int64(10_500), stored.TotalOutstanding)

	// No balance row: nothing is charged and the marker does not stick.
	orphan := &models.Penalty{LoanAccountID: "loan-no-balance", Amount: 500, CurrencyCode: "KES",
		PenaltyType: int32(loansv1.PenaltyType_PENALTY_TYPE_LATE_PAYMENT)}
	orphan.GenID(e.ctx)
	s.Require().NoError(penalties.Create(e.ctx, orphan))
	_, err = penalties.ChargeBalanceOnce(e.ctx, orphan)
	s.Require().Error(err)
	reloaded, err := penalties.GetByID(e.ctx, orphan.GetID())
	s.Require().NoError(err)
	_, marked := reloaded.Properties["balance_applied"]
	s.Require().False(marked, "the marker rolls back with the failed charge")
}
