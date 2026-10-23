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
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/frametests"
	"github.com/pitabwire/frame/v2/frametests/definition"
	"github.com/pitabwire/frame/v2/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/frame/v2/workerpool"
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
