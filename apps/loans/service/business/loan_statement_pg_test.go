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

package business_test

import (
	"context"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/frametests"
	"github.com/pitabwire/frame/v2/frametests/definition"
	"github.com/pitabwire/frame/v2/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/loans/service/business"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

const migrationPath = "../../migrations"

type statementSuite struct {
	frametests.FrameBaseTestSuite
}

func TestStatementSuite(t *testing.T) {
	suite.Run(t, new(statementSuite))
}

func (s *statementSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts(
				"loans_statement",
				definition.WithUserName("ant"),
				definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false),
			),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

// queryCounter counts every SELECT gorm sends to Postgres, through the
// shared callback chain, so a test can assert a code path issues a fixed
// number of queries regardless of how many rows it reads. Session set-up
// statements (tenancy variables) go through the Raw/Exec chain and are not
// counted; they are per-query overhead, not per-row reads.
type queryCounter struct {
	n   atomic.Int64
	mu  sync.Mutex
	sql []string
}

func (c *queryCounter) install(s *statementSuite, db *gorm.DB, prefix string) {
	s.T().Helper()
	tick := func(db *gorm.DB) {
		c.n.Add(1)
		c.mu.Lock()
		c.sql = append(c.sql, prefix+": "+db.Statement.SQL.String())
		c.mu.Unlock()
	}
	s.Require().NoError(db.Callback().Query().After("gorm:query").Register(prefix+":query", tick))
	s.Require().NoError(db.Callback().Row().After("gorm:row").Register(prefix+":row", tick))
}

func (c *queryCounter) reset() {
	c.n.Store(0)
	c.mu.Lock()
	c.sql = nil
	c.mu.Unlock()
}

func (c *queryCounter) count() int64 { return c.n.Load() }

func (c *queryCounter) statements() string {
	c.mu.Lock()
	defer c.mu.Unlock()
	return strings.Join(c.sql, "\n")
}

type statementEnv struct {
	ctx      context.Context
	db       *gorm.DB
	accounts repository.LoanAccountRepository
	balances repository.LoanBalanceRepository
	reps     repository.RepaymentRepository
	pens     repository.PenaltyRepository
	disbs    repository.DisbursementRepository
	entries  repository.ScheduleEntryRepository
	business business.LoanAccountBusiness
	queries  *queryCounter
}

func (s *statementSuite) newEnv() *statementEnv {
	s.T().Helper()

	ctx := (&security.AuthenticationClaims{
		TenantID:         "tenant-loans",
		PartitionID:      "partition-loans",
		Roles:            []string{"operator"},
		RegisteredClaims: jwt.RegisteredClaims{Subject: "profile-staff"},
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
		frame.WithName("loans-statement-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	s.Require().NoError(repository.Migrate(ctx, svc.DatastoreManager(), migrationPath))

	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	// Read and write sessions share one gorm callback chain, so registering
	// on either counts every statement the pool sends.
	counter := &queryCounter{}
	counter.install(s, dbPool.DB(ctx, true), "test")

	workMan := svc.WorkManager()
	e := &statementEnv{
		ctx:      ctx,
		db:       dbPool.DB(ctx, false),
		accounts: repository.NewLoanAccountRepository(ctx, dbPool, workMan),
		balances: repository.NewLoanBalanceRepository(ctx, dbPool, workMan),
		reps:     repository.NewRepaymentRepository(ctx, dbPool, workMan),
		pens:     repository.NewPenaltyRepository(ctx, dbPool, workMan),
		disbs:    repository.NewDisbursementRepository(ctx, dbPool, workMan),
		entries:  repository.NewScheduleEntryRepository(ctx, dbPool, workMan),
		queries:  counter,
	}
	// The statement sources are deliberately not passed: the business must
	// derive them from the pool, which is what the production binary relies on.
	e.business = business.NewLoanAccountBusiness(ctx, nil, nil,
		e.accounts, e.balances, nil, e.reps, e.pens, nil, nil, nil, nil, nil)
	return e
}

// seededLoan describes what was written for a loan so the test can compute
// the balance the statement must arrive at.
type seededLoan struct {
	id               string
	principal        int64
	scheduledCharges int64
	penalties        int64
	repaid           int64
}

func (l seededLoan) expectedClosingBalance() int64 {
	return l.principal + l.scheduledCharges + l.penalties - l.repaid
}

// seedLoan writes one loan with the given row volumes. Completed
// disbursements, non-waived penalties and non-reversed repayments count; the
// failed disbursement, waived penalties and reversed repayments are noise
// the statement has to ignore.
func (s *statementSuite) seedLoan(
	e *statementEnv,
	clientID string,
	repayments, penalties, installments int,
) seededLoan {
	s.T().Helper()
	base := time.Date(2026, 1, 1, 9, 0, 0, 0, time.UTC)
	disbursedAt := base

	la := &models.LoanAccount{
		ClientID:        clientID,
		OrganizationID:  "org-1",
		ProductID:       "product-1",
		LoanRequestID:   util.IDString(),
		CurrencyCode:    "KES",
		PrincipalAmount: 250_000,
		Status:          int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE),
		DisbursedAt:     &disbursedAt,
	}
	la.GenID(e.ctx)
	s.Require().NoError(e.accounts.Create(e.ctx, la))

	balance := &models.LoanBalance{LoanAccountID: la.GetID(), CurrencyCode: "KES"}
	balance.GenID(e.ctx)
	s.Require().NoError(e.balances.Create(e.ctx, balance))

	seeded := seededLoan{id: la.GetID(), principal: 250_000}

	completed := &models.Disbursement{
		LoanAccountID: la.GetID(), Amount: 250_000, CurrencyCode: "KES",
		Status: int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_COMPLETED),
	}
	completed.GenID(e.ctx)
	failed := &models.Disbursement{
		LoanAccountID: la.GetID(), Amount: 250_000, CurrencyCode: "KES",
		Status: int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_FAILED),
	}
	failed.GenID(e.ctx)
	s.Require().NoError(e.disbs.BulkCreate(e.ctx, []*models.Disbursement{failed, completed}))
	s.backdate(e, "disbursements", la.GetID(), base.Add(-time.Hour), time.Hour)

	scheduleID := util.IDString()
	entries := make([]*models.ScheduleEntry, 0, installments)
	for i := range installments {
		due := base.AddDate(0, i+1, 0)
		entry := &models.ScheduleEntry{
			ScheduleID: scheduleID, LoanAccountID: la.GetID(), InstallmentNumber: int32(i + 1),
			DueDate: &due, CurrencyCode: "KES",
			PrincipalDue: 250_000 / int64(installments), InterestDue: 3_000, FeesDue: 250,
		}
		entry.GenID(e.ctx)
		entries = append(entries, entry)
		seeded.scheduledCharges += 3_250
	}
	s.Require().NoError(e.entries.BulkCreate(e.ctx, entries))

	pens := make([]*models.Penalty, 0, penalties)
	for i := range penalties {
		p := &models.Penalty{
			LoanAccountID: la.GetID(), Amount: 100, CurrencyCode: "KES",
			Reason: "late installment", IsWaived: i%5 == 0,
		}
		p.GenID(e.ctx)
		if !p.IsWaived {
			seeded.penalties += 100
		}
		pens = append(pens, p)
	}
	s.Require().NoError(e.pens.BulkCreate(e.ctx, pens))
	s.backdate(e, "penalties", la.GetID(), base, time.Hour)

	reps := make([]*models.Repayment, 0, repayments)
	for i := range repayments {
		r := &models.Repayment{
			LoanAccountID: la.GetID(), Amount: 700, CurrencyCode: "KES", Channel: "mpesa",
			IdempotencyKey: util.IDString(),
			Status:         int32(loansv1.RepaymentStatus_REPAYMENT_STATUS_MATCHED),
		}
		if i%50 == 0 {
			r.Status = int32(loansv1.RepaymentStatus_REPAYMENT_STATUS_REVERSED)
		} else {
			seeded.repaid += 700
		}
		r.GenID(e.ctx)
		reps = append(reps, r)
	}
	s.Require().NoError(e.reps.BulkCreate(e.ctx, reps))
	s.backdate(e, "repayments", la.GetID(), base, 30*time.Minute)

	return seeded
}

// backdate spreads the created_at of a loan's rows in one table from start,
// one step apart in insertion (id) order. BeforeCreate stamps created_at
// with the wall clock on insert, so fixtures cannot carry their own history
// through Create.
func (s *statementSuite) backdate(e *statementEnv, table, loanID string, start time.Time, step time.Duration) {
	s.T().Helper()
	err := e.db.Exec(`UPDATE `+table+` t SET created_at = ?::timestamptz + make_interval(secs => ?) * sub.rn
		FROM (SELECT id, row_number() OVER (ORDER BY id) - 1 AS rn FROM `+table+` WHERE loan_account_id = ?) sub
		WHERE t.id = sub.id`, start, step.Seconds(), loanID).Error
	s.Require().NoError(err)
}

// minorUnits converts a two-decimal Money into cents.
func minorUnits(units int64, nanos int32) int64 {
	return units*100 + int64(nanos)/10_000_000
}

func (s *statementSuite) statementFor(e *statementEnv, loanID string) *loansv1.LoanStatementResponse {
	s.T().Helper()
	resp, err := e.business.GetStatement(e.ctx, &loansv1.LoanStatementRequest{LoanAccountId: loanID})
	s.Require().NoError(err)
	return resp
}

func (s *statementSuite) TestStatementQueryCountIsIndependentOfRowVolume() {
	e := s.newEnv()

	small := s.seedLoan(e, "client-a", 20, 5, 3)
	large := s.seedLoan(e, "client-b", 400, 120, 24)

	e.queries.reset()
	s.statementFor(e, small.id)
	smallQueries := e.queries.count()

	e.queries.reset()
	s.statementFor(e, large.id)
	largeQueries := e.queries.count()

	s.Require().Positive(smallQueries)
	s.Require().Equal(smallQueries, largeQueries,
		"statement must read each table once; row count must not change the query count")
	s.Require().Equal(int64(6), largeQueries,
		"account, balance, disbursements, schedule, penalties, repayments; got:\n%s", e.queries.statements())
}

func (s *statementSuite) TestStatementRunningBalanceReconciles() {
	e := s.newEnv()
	loan := s.seedLoan(e, "client-a", 400, 120, 24)

	resp := s.statementFor(e, loan.id)
	entries := resp.GetEntries()

	// 1 completed disbursement + 24 installments + 96 unwaived penalties
	// + 392 non-reversed repayments.
	s.Require().Len(entries, 1+24+96+392)

	var running int64
	var prev time.Time
	for i, entry := range entries {
		running += minorUnits(entry.GetDebit().GetUnits(), entry.GetDebit().GetNanos())
		running -= minorUnits(entry.GetCredit().GetUnits(), entry.GetCredit().GetNanos())
		got := minorUnits(entry.GetBalance().GetUnits(), entry.GetBalance().GetNanos())
		s.Require().Equal(running, got, "running balance drifted at entry %d (%s)", i, entry.GetDescription())

		s.Require().Equal("KES", entry.GetBalance().GetCurrencyCode())
		at := models.StringToTime(entry.GetDate())
		s.Require().NotNil(at)
		s.Require().False(at.Before(prev), "entries must be chronological")
		prev = *at
	}
	s.Require().Equal(loan.expectedClosingBalance(), running)
	s.Require().Equal("Loan disbursement", entries[0].GetDescription())
}

func (s *statementSuite) TestStatementPeriodOpensWithBroughtForwardBalance() {
	e := s.newEnv()
	loan := s.seedLoan(e, "client-a", 60, 10, 6)

	// Repayments are 30 minutes apart from 2026-01-01 09:30; a window starting
	// on 2026-01-02 leaves the disbursement and the first ~29 repayments before it.
	resp, err := e.business.GetStatement(e.ctx, &loansv1.LoanStatementRequest{
		LoanAccountId: loan.id,
		FromDate:      "2026-01-02T00:00:00Z",
		ToDate:        "2026-01-03T00:00:00Z",
	})
	s.Require().NoError(err)
	entries := resp.GetEntries()
	s.Require().NotEmpty(entries)
	s.Require().Equal("Opening balance brought forward", entries[0].GetDescription())

	opening := minorUnits(entries[0].GetBalance().GetUnits(), entries[0].GetBalance().GetNanos())
	s.Require().Positive(opening, "the principal advanced before the window must be brought forward")
	for _, entry := range entries[1:] {
		at := models.StringToTime(entry.GetDate())
		s.Require().NotNil(at)
		s.Require().False(at.Before(time.Date(2026, 1, 2, 0, 0, 0, 0, time.UTC)))
		s.Require().False(at.After(time.Date(2026, 1, 3, 0, 0, 0, 0, time.UTC)))
	}
}

func (s *statementSuite) TestStatementRefusesMixedCurrencies() {
	e := s.newEnv()
	loan := s.seedLoan(e, "client-a", 5, 1, 2)

	foreign := &models.Repayment{
		LoanAccountID: loan.id, Amount: 700, CurrencyCode: "USD", Channel: "card",
		IdempotencyKey: util.IDString(),
		Status:         int32(loansv1.RepaymentStatus_REPAYMENT_STATUS_MATCHED),
	}
	foreign.GenID(e.ctx)
	s.Require().NoError(e.reps.Create(e.ctx, foreign))

	_, err := e.business.GetStatement(e.ctx, &loansv1.LoanStatementRequest{LoanAccountId: loan.id})
	s.Require().ErrorIs(err, business.ErrStatementCurrencyMismatch)
}

func (s *statementSuite) TestStatementFallsBackToAccountDisbursementWhenNoRowsExist() {
	e := s.newEnv()
	disbursedAt := time.Date(2026, 2, 1, 0, 0, 0, 0, time.UTC)
	la := &models.LoanAccount{
		ClientID: "client-a", OrganizationID: "org-1", ProductID: "product-1",
		LoanRequestID: util.IDString(), CurrencyCode: "KES", PrincipalAmount: 10_000,
		Status: int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE), DisbursedAt: &disbursedAt,
	}
	la.GenID(e.ctx)
	s.Require().NoError(e.accounts.Create(e.ctx, la))

	resp := s.statementFor(e, la.GetID())
	s.Require().Len(resp.GetEntries(), 1)
	s.Require().Equal(int64(100), resp.GetEntries()[0].GetBalance().GetUnits())
}
