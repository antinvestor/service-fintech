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
	"errors"
	"sync"
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/frame/v3/frametests"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/frame/v3/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/v3/queue"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/workerpool"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-fintech/apps/funding/service/business"
	"github.com/antinvestor/service-fintech/apps/funding/service/events"
	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/transferorder"
)

// countingOperationsClient records every transfer order posted so tests can
// assert on how many times money actually reached the ledger.
type countingOperationsClient struct {
	mu     sync.Mutex
	orders []*operationsv1.TransferOrderObject
}

func (c *countingOperationsClient) TransferOrderExecute(
	_ context.Context,
	req *operationsv1.TransferOrderExecuteRequest,
) (*operationsv1.TransferOrderExecuteResponse, error) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.orders = append(c.orders, req.GetData())
	return &operationsv1.TransferOrderExecuteResponse{
		Data: &operationsv1.TransferOrderObject{Id: "ledger-txn"},
	}, nil
}

func (c *countingOperationsClient) TransferOrderSearch(
	_ context.Context,
	_ *operationsv1.TransferOrderSearchRequest,
) (operationsv1connect.OperationsServiceTransferOrderSearchClientStream, error) {
	panic("not used")
}

func (c *countingOperationsClient) IncomingPaymentNotify(
	_ context.Context,
	_ *operationsv1.IncomingPaymentNotifyRequest,
) (*operationsv1.IncomingPaymentNotifyResponse, error) {
	panic("not used")
}

func (c *countingOperationsClient) PaymentAllocate(
	_ context.Context,
	_ *operationsv1.PaymentAllocateRequest,
) (*operationsv1.PaymentAllocateResponse, error) {
	panic("not used")
}

func (c *countingOperationsClient) IncomingPaymentSearch(
	_ context.Context,
	_ *operationsv1.IncomingPaymentSearchRequest,
) (operationsv1connect.OperationsServiceIncomingPaymentSearchClientStream, error) {
	panic("stub: IncomingPaymentSearch not expected")
}

func (c *countingOperationsClient) IncomingPaymentAssign(
	_ context.Context,
	_ *operationsv1.IncomingPaymentAssignRequest,
) (*operationsv1.IncomingPaymentAssignResponse, error) {
	panic("stub: IncomingPaymentAssign not expected")
}

func (c *countingOperationsClient) OperationsJobRun(
	_ context.Context,
	_ *operationsv1.OperationsJobRunRequest,
) (*operationsv1.OperationsJobRunResponse, error) {
	panic("stub: OperationsJobRun not expected")
}

func (c *countingOperationsClient) snapshot() []*operationsv1.TransferOrderObject {
	c.mu.Lock()
	defer c.mu.Unlock()
	return append([]*operationsv1.TransferOrderObject(nil), c.orders...)
}

// syncEventsManager runs registered handlers inline. Emitting through it
// means a test asserts on what the handler actually wrote, and an unregistered
// event is a silent no-op exactly as the audit writer expects.
type syncEventsManager struct {
	handlers map[string]fevents.EventI
}

func (m *syncEventsManager) Add(handler fevents.EventI) { m.handlers[handler.Name()] = handler }

func (m *syncEventsManager) Get(name string) (fevents.EventI, error) {
	handler, ok := m.handlers[name]
	if !ok {
		return nil, errNoHandler
	}
	return handler, nil
}

func (m *syncEventsManager) Emit(ctx context.Context, name string, payload any) error {
	handler, ok := m.handlers[name]
	if !ok {
		return nil
	}
	if err := handler.Validate(ctx, payload); err != nil {
		return err
	}
	return handler.Execute(ctx, payload)
}

func (m *syncEventsManager) Handler() queue.SubscribeWorker { return nil }
func (m *syncEventsManager) Strict() bool                   { return true }
func (m *syncEventsManager) SetStrict(bool)                 {}

var errNoHandler = errors.New("no handler registered")

type fundingSuite struct {
	frametests.FrameBaseTestSuite
}

func TestFundingSuite(t *testing.T) {
	suite.Run(t, new(fundingSuite))
}

func (s *fundingSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts(
				"funding_business",
				definition.WithUserName("ant"),
				definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false),
			),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

type fundingEnv struct {
	ctx     context.Context
	ops     *countingOperationsClient
	iaBiz   business.InvestorAccountBusiness
	iaRepo  repository.InvestorAccountRepository
	icmRepo repository.InvestorCapitalMovementRepository
	dbPool  pool.Pool
	workMan workerpool.Manager
}

func (s *fundingSuite) newEnv() *fundingEnv {
	s.T().Helper()

	ctx := (&security.AuthenticationClaims{
		TenantID:         "tenant-funding",
		PartitionID:      "partition-funding",
		RegisteredClaims: jwt.RegisteredClaims{Subject: "profile-funding"},
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
		frame.WithName("funding-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)
	s.Require().NoError(dbPool.DB(ctx, false).AutoMigrate(
		&models.LoanFunding{}, &models.InvestorAccount{}, &models.FundingTranche{},
		&models.InvestorCapitalMovement{}, &models.LoanFundingClaim{}, &models.LossAbsorption{},
		&models.RepaymentDistribution{},
	))
	s.Require().NoError(dbPool.DB(ctx, false).Exec(
		`CREATE UNIQUE INDEX uq_rd_reference ON repayment_distributions (reference) WHERE deleted_at IS NULL`).Error)
	s.Require().NoError(dbPool.DB(ctx, false).Exec(
		`CREATE UNIQUE INDEX uq_loss_reference ON loss_absorptions (reference)
		 WHERE reference <> '' AND deleted_at IS NULL`).Error)
	// The idempotency constraint lives in a SQL migration; recreate it so the
	// tests exercise the real guard.
	s.Require().NoError(dbPool.DB(ctx, false).Exec(
		`CREATE UNIQUE INDEX uq_icm_account_idempotency
		 ON investor_capital_movements (investor_account_id, idempotency_key)
		 WHERE idempotency_key <> '' AND deleted_at IS NULL`).Error)

	workMan := svc.WorkManager()
	iaRepo := repository.NewInvestorAccountRepository(ctx, dbPool, workMan)
	icmRepo := repository.NewInvestorCapitalMovementRepository(ctx, dbPool, workMan)
	ops := &countingOperationsClient{}

	// Dispatch save events straight into the real handler, so the tests
	// observe the persisted row without waiting on a queue.
	evtsMan := &syncEventsManager{handlers: map[string]fevents.EventI{}}
	evtsMan.Add(events.NewInvestorAccountSave(ctx, iaRepo))

	return &fundingEnv{
		ctx:     ctx,
		ops:     ops,
		iaRepo:  iaRepo,
		icmRepo: icmRepo,
		dbPool:  dbPool,
		workMan: workMan,
		iaBiz: business.NewInvestorAccountBusiness(
			ctx, evtsMan, iaRepo, icmRepo, ops,
			audit.NewWriter(evtsMan), nil, false, "off",
			business.WithInvestorPayouts(fixedPayout{})),
	}
}

// seedInvestor writes an investor account straight through the repository so
// the balance-movement tests start from a known, honestly-obtained balance.
func (e *fundingEnv) seedInvestor(s *fundingSuite, currency string, available int64) *models.InvestorAccount {
	s.T().Helper()
	account := &models.InvestorAccount{
		InvestorID:       "investor-1",
		AccountName:      "Growth fund",
		Currency:         currency,
		AvailableBalance: available,
		State:            int32(constants.StateActive),
	}
	account.GenID(e.ctx)
	s.Require().NoError(e.iaRepo.Create(e.ctx, account))
	return account
}

func fundingMoney(currency string, units int64) *commonv1.Money {
	return &commonv1.Money{CurrencyCode: currency, Units: units}
}

func (s *fundingSuite) TestDepositIsIdempotentOnTheKey() {
	e := s.newEnv()
	account := e.seedInvestor(s, "KES", 0)

	s.Require().NoError(e.iaBiz.Deposit(e.ctx, account.GetID(), fundingMoney("KES", 500), "dep-1"))
	s.Require().NoError(e.iaBiz.Deposit(e.ctx, account.GetID(), fundingMoney("KES", 500), "dep-1"))

	s.Len(e.ops.snapshot(), 1, "a retry must not post a second ledger transfer")

	fresh, err := e.iaRepo.GetByID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(50000), fresh.AvailableBalance, "a retry must not credit twice")
}

// TestDepositReferenceIsDerivedFromTheMovement pins the ledger idempotency
// key to a row that only one caller can own, rather than to a balance version
// two concurrent callers can both observe.
func (s *fundingSuite) TestDepositReferenceIsDerivedFromTheMovement() {
	e := s.newEnv()
	account := e.seedInvestor(s, "KES", 0)

	s.Require().NoError(e.iaBiz.Deposit(e.ctx, account.GetID(), fundingMoney("KES", 100), "dep-ref"))

	movement, err := e.icmRepo.GetByIdempotencyKey(e.ctx, account.GetID(), "dep-ref")
	s.Require().NoError(err)
	s.Equal(models.CapitalMovementCompleted, movement.Status)

	orders := e.ops.snapshot()
	s.Require().Len(orders, 1)
	s.Equal("investor_capital_movement:"+movement.GetID(), orders[0].GetReference())
}

func (s *fundingSuite) TestDepositRequiresAnIdempotencyKey() {
	e := s.newEnv()
	account := e.seedInvestor(s, "KES", 0)

	err := e.iaBiz.Deposit(e.ctx, account.GetID(), fundingMoney("KES", 100), "")
	s.Require().ErrorIs(err, business.ErrIdempotencyKeyRequired)
	s.Empty(e.ops.snapshot())
}

func (s *fundingSuite) TestDepositRejectsAForeignCurrency() {
	e := s.newEnv()
	account := e.seedInvestor(s, "KES", 0)

	err := e.iaBiz.Deposit(e.ctx, account.GetID(), fundingMoney("USD", 100), "dep-usd")
	s.Require().ErrorIs(err, business.ErrCurrencyMismatch)
}

// TestDepositPostsZeroDecimalCurrencyAtFaceValue pins ISO 4217 handling on the
// funding side: JPY has no minor unit.
func (s *fundingSuite) TestDepositPostsZeroDecimalCurrencyAtFaceValue() {
	e := s.newEnv()
	account := e.seedInvestor(s, "JPY", 0)

	s.Require().NoError(e.iaBiz.Deposit(e.ctx, account.GetID(), fundingMoney("JPY", 100000), "dep-jpy"))

	orders := e.ops.snapshot()
	s.Require().Len(orders, 1)
	s.Equal(int64(100000), orders[0].GetAmount().GetUnits())

	fresh, err := e.iaRepo.GetByID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(100000), fresh.AvailableBalance)
}

func (s *fundingSuite) TestWithdrawIsIdempotentAndGuardsTheBalance() {
	e := s.newEnv()
	account := e.seedInvestor(s, "KES", 100000)

	s.Require().NoError(e.iaBiz.Withdraw(e.ctx, account.GetID(), fundingMoney("KES", 400), "wdr-1"))
	s.Require().NoError(e.iaBiz.Withdraw(e.ctx, account.GetID(), fundingMoney("KES", 400), "wdr-1"))

	fresh, err := e.iaRepo.GetByID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(60000), fresh.AvailableBalance)
	s.Len(e.ops.snapshot(), 1)

	err = e.iaBiz.Withdraw(e.ctx, account.GetID(), fundingMoney("KES", 5000), "wdr-over")
	s.Require().Error(err)

	// The withdrawal is a payout to the investor's own verified contact.
	order := e.ops.snapshot()[0]
	s.Equal(int32(constants.TransferTypeInvestorWithdrawal), transferorder.TypeOf(order))
	extra := order.GetExtraData().AsMap()
	s.Equal("profile-investor", extra["recipient_profile_id"])
	s.Equal("contact-investor", extra["payment_account_ref"])
}

// fixedPayout pays every investor to one known profile and contact.
type fixedPayout struct{ err error }

func (f fixedPayout) InvestorPayout(context.Context, string) (business.InvestorPayout, error) {
	if f.err != nil {
		return business.InvestorPayout{}, f.err
	}
	return business.InvestorPayout{ProfileID: "profile-investor", ContactID: "contact-investor"}, nil
}

// A withdrawal with nowhere checked to pay is refused before anything moves.
func (s *fundingSuite) TestWithdrawWithoutAPayoutContactMovesNothing() {
	e := s.newEnv()
	account := e.seedInvestor(s, "KES", 100000)
	biz := business.NewInvestorAccountBusiness(e.ctx, nil, e.iaRepo, e.icmRepo, e.ops,
		audit.NewWriter(nil), nil, false, "off",
		business.WithInvestorPayouts(fixedPayout{err: business.ErrInvestorNoPayoutContact}))

	err := biz.Withdraw(e.ctx, account.GetID(), fundingMoney("KES", 400), "wdr-nowhere")
	s.Require().ErrorIs(err, business.ErrInvestorNoPayoutContact)
	fresh, getErr := e.iaRepo.GetByID(e.ctx, account.GetID())
	s.Require().NoError(getErr)
	s.Equal(account.AvailableBalance, fresh.AvailableBalance)
	s.Empty(e.ops.snapshot())
}

// TestSaveCannotMintCapital is the regression for the balance-write endpoint:
// whatever balance a caller sends must be ignored, on create and on update.
func (s *fundingSuite) TestSaveCannotMintCapital() {
	e := s.newEnv()

	created, err := e.iaBiz.Save(e.ctx, &models.InvestorAccount{
		InvestorID:       "investor-mint",
		AccountName:      "Wishful thinking",
		Currency:         "KES",
		AvailableBalance: 999_999_00,
		MaxExposure:      500000,
	})
	s.Require().NoError(err)
	s.Zero(created.AvailableBalance, "a create must not carry a caller-supplied balance")

	s.Require().NoError(e.iaBiz.Deposit(e.ctx, created.GetID(), fundingMoney("KES", 100), "dep-real"))

	updated := &models.InvestorAccount{
		InvestorID:       "investor-mint",
		AccountName:      "Renamed",
		Currency:         "KES",
		AvailableBalance: 777_777_00,
		MaxExposure:      900000,
	}
	updated.ID = created.GetID()

	merged, err := e.iaBiz.Save(e.ctx, updated)
	s.Require().NoError(err)
	s.Equal(int64(10000), merged.AvailableBalance, "an update must keep the stored balance")
	s.Equal("Renamed", merged.AccountName, "an update must apply the caller's mandate fields")
	s.Equal(int64(900000), merged.MaxExposure)
}

func (s *fundingSuite) TestSearchDoesNotRequireAnInvestorID() {
	e := s.newEnv()
	e.seedInvestor(s, "KES", 100)
	e.seedInvestor(s, "USD", 200)

	all, err := e.iaBiz.Search(e.ctx, &fundingv1.InvestorAccountSearchRequest{})
	s.Require().NoError(err)
	s.Len(all, 2)

	kes, err := e.iaBiz.Search(e.ctx, &fundingv1.InvestorAccountSearchRequest{CurrencyCode: "KES"})
	s.Require().NoError(err)
	s.Len(kes, 1)
	s.Equal("KES", kes[0].Currency)
}

func (s *fundingSuite) TestSearchPagesThroughTheCursor() {
	e := s.newEnv()
	for range 3 {
		e.seedInvestor(s, "KES", 100)
	}

	first, err := e.iaBiz.Search(e.ctx, &fundingv1.InvestorAccountSearchRequest{
		Cursor: &commonv1.PageCursor{Limit: 2, Page: "0"},
	})
	s.Require().NoError(err)
	s.Len(first, 2)

	second, err := e.iaBiz.Search(e.ctx, &fundingv1.InvestorAccountSearchRequest{
		Cursor: &commonv1.PageCursor{Limit: 2, Page: "1"},
	})
	s.Require().NoError(err)
	s.Len(second, 1)
	s.NotEqual(first[0].GetID(), second[0].GetID())
}

// TestDepositResumesAnUnfinishedMovement is the regression for a retry that
// reported success while nothing moved: a movement left PENDING by a crashed
// attempt must be finished, not treated as an answered call.
func (s *fundingSuite) TestDepositResumesAnUnfinishedMovement() {
	e := s.newEnv()
	account := e.seedInvestor(s, "KES", 0)

	stranded := &models.InvestorCapitalMovement{
		InvestorAccountID: account.GetID(),
		Direction:         int32(models.CapitalMovementDeposit),
		Amount:            50000,
		Currency:          "KES",
		IdempotencyKey:    "dep-stranded",
		Status:            models.CapitalMovementPending,
	}
	stranded.GenID(e.ctx)
	stranded.CopyPartitionInfo(&account.BaseModel)
	s.Require().NoError(e.icmRepo.Create(e.ctx, stranded))

	s.Require().NoError(e.iaBiz.Deposit(e.ctx, account.GetID(), fundingMoney("KES", 500), "dep-stranded"))

	fresh, err := e.iaRepo.GetByID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(50000), fresh.AvailableBalance, "the resumed deposit must actually credit the account")

	movement, err := e.icmRepo.GetByIdempotencyKey(e.ctx, account.GetID(), "dep-stranded")
	s.Require().NoError(err)
	s.Equal(models.CapitalMovementCompleted, movement.Status)
	s.Len(e.ops.snapshot(), 1)

	// Once completed, a further retry is a no-op again.
	s.Require().NoError(e.iaBiz.Deposit(e.ctx, account.GetID(), fundingMoney("KES", 500), "dep-stranded"))
	fresh, err = e.iaRepo.GetByID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(50000), fresh.AvailableBalance)
}

// TestWithdrawResumesWithoutDebitingTwice covers the other crash window: the
// funds have already left the balance, so the resumed attempt must only
// finish the ledger posting.
func (s *fundingSuite) TestWithdrawResumesWithoutDebitingTwice() {
	e := s.newEnv()
	account := e.seedInvestor(s, "KES", 100000)

	debited := &models.InvestorCapitalMovement{
		InvestorAccountID: account.GetID(),
		Direction:         int32(models.CapitalMovementWithdraw),
		Amount:            30000,
		Currency:          "KES",
		IdempotencyKey:    "wdr-debited",
		Status:            models.CapitalMovementDebited,
	}
	debited.GenID(e.ctx)
	debited.CopyPartitionInfo(&account.BaseModel)
	s.Require().NoError(e.icmRepo.Create(e.ctx, debited))
	// The debit already landed on the balance before the attempt died.
	_, err := e.iaRepo.AtomicWithdraw(e.ctx, account.GetID(), 30000)
	s.Require().NoError(err)

	s.Require().NoError(e.iaBiz.Withdraw(e.ctx, account.GetID(), fundingMoney("KES", 300), "wdr-debited"))

	fresh, err := e.iaRepo.GetByID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(70000), fresh.AvailableBalance, "a resumed withdrawal must not debit a second time")

	movement, err := e.icmRepo.GetByIdempotencyKey(e.ctx, account.GetID(), "wdr-debited")
	s.Require().NoError(err)
	s.Equal(models.CapitalMovementCompleted, movement.Status)
	s.Len(e.ops.snapshot(), 1)
}

// TestAbsorbLossRemovesTheCapitalNotOnlyTheReservation is the regression for
// a write-off that handed the investor their lost money back as free capital.
func (s *fundingSuite) TestAbsorbLossRemovesTheCapitalNotOnlyTheReservation() {
	e := s.newEnv()
	account := e.seedInvestor(s, "KES", 100000)
	_, err := e.iaRepo.AtomicReserve(e.ctx, account.GetID(), 40000)
	s.Require().NoError(err)
	freeBefore := int64(60000)

	after, err := e.iaRepo.AtomicAbsorbLoss(e.ctx, account.GetID(), 25000)
	s.Require().NoError(err)
	s.Equal(int64(75000), after.AvailableBalance, "written-off capital must leave the balance")
	s.Equal(int64(15000), after.ReservedBalance)
	s.Equal(int64(25000), after.TotalLost)
	s.Equal(freeBefore, after.AvailableBalance-after.ReservedBalance,
		"absorbing a loss must never grow free capital")

	// A loss beyond what was reserved eats into free capital.
	after, err = e.iaRepo.AtomicAbsorbLoss(e.ctx, account.GetID(), 30000)
	s.Require().NoError(err)
	s.Equal(int64(45000), after.AvailableBalance)
	s.Zero(after.ReservedBalance)
	s.Less(after.AvailableBalance-after.ReservedBalance, freeBefore, "free capital must fall")
	s.Equal(int64(55000), after.TotalLost)
}

// TestReleaseWithReturnCreditsInterestOnly pins the reservation accounting:
// principal was never taken out of available, so returning it must not be
// added back on top of releasing the reservation.
func (s *fundingSuite) TestReleaseWithReturnCreditsInterestOnly() {
	e := s.newEnv()
	account := e.seedInvestor(s, "KES", 100000)
	_, err := e.iaRepo.AtomicReserve(e.ctx, account.GetID(), 40000)
	s.Require().NoError(err)

	after, err := e.iaRepo.AtomicReleaseWithReturn(e.ctx, account.GetID(), 40000, 5000)
	s.Require().NoError(err)
	s.Equal(int64(105000), after.AvailableBalance, "only the interest is new money")
	s.Zero(after.ReservedBalance)
	s.Equal(int64(45000), after.TotalReturned)
}

// seedInvestorWithMinRate writes an active investor account carrying a
// minimum-rate mandate expressed in basis points, the unit the row stores.
func (e *fundingEnv) seedInvestorWithMinRate(
	s *fundingSuite,
	investorID string,
	minRateBasisPoints int64,
) *models.InvestorAccount {
	s.T().Helper()
	account := &models.InvestorAccount{
		InvestorID:       investorID,
		AccountName:      "Mandate " + investorID,
		Currency:         "KES",
		AvailableBalance: 1_000_000,
		MinInterestRate:  minRateBasisPoints,
		State:            int32(constants.StateActive),
	}
	account.GenID(e.ctx)
	s.Require().NoError(e.iaRepo.Create(e.ctx, account))
	return account
}

// TestEligibleForLoanComparesRatesInBasisPoints pins the unit on both sides
// of the eligibility filter: the loan's rate arrives on the wire as "12.50",
// the mandate is stored as 1250, and the query must compare like with like.
// Before the parser fix a "12.50" loan read as 0 and excluded every investor
// with a non-zero minimum.
func (s *fundingSuite) TestEligibleForLoanComparesRatesInBasisPoints() {
	e := s.newEnv()
	noMinimum := e.seedInvestorWithMinRate(s, "inv-any", 0)
	tenPercent := e.seedInvestorWithMinRate(s, "inv-10", 1000)
	exactlyTwelveAndAHalf := e.seedInvestorWithMinRate(s, "inv-12-50", 1250)
	fifteenPercent := e.seedInvestorWithMinRate(s, "inv-15", 1500)

	loanRate := models.StringToBasisPoints("12.50")
	s.Require().Equal(int64(1250), loanRate)

	eligible, err := e.iaRepo.GetEligibleForLoan(e.ctx, "KES", loanRate, 100, "", "")
	s.Require().NoError(err)

	ids := make(map[string]bool, len(eligible))
	for _, account := range eligible {
		ids[account.GetID()] = true
	}
	s.True(ids[noMinimum.GetID()], "an account with no minimum accepts any rate")
	s.True(ids[tenPercent.GetID()], "a 10%% minimum accepts a 12.50%% loan")
	s.True(ids[exactlyTwelveAndAHalf.GetID()], "a minimum equal to the loan rate is eligible")
	s.False(ids[fifteenPercent.GetID()], "a 15%% minimum must exclude a 12.50%% loan")
	s.Len(eligible, 3)
}

// failingOperations fails each transfer with the next queued error, then
// succeeds.
type failingOperations struct {
	countingOperationsClient
	errs []error
}

func (f *failingOperations) TransferOrderExecute(
	ctx context.Context,
	req *operationsv1.TransferOrderExecuteRequest,
) (*operationsv1.TransferOrderExecuteResponse, error) {
	if len(f.errs) > 0 {
		err := f.errs[0]
		f.errs = f.errs[1:]
		return nil, err
	}
	return f.countingOperationsClient.TransferOrderExecute(ctx, req)
}

// A payout whose outcome is unknown may have paid the investor: the funds
// stay debited, so they can never be withdrawn twice, and a retry under the
// same key completes it once. A payout refused outright gives them back.
func (s *fundingSuite) TestWithdrawKeepsFundsDebitedUntilThePayoutIsKnown() {
	e := s.newEnv()
	account := e.seedInvestor(s, "KES", 100000)
	ops := &failingOperations{errs: []error{connect.NewError(connect.CodeUnavailable, "rail timeout")}}
	biz := business.NewInvestorAccountBusiness(e.ctx, nil, e.iaRepo, e.icmRepo, ops,
		audit.NewWriter(nil), nil, false, "off", business.WithInvestorPayouts(fixedPayout{}))

	s.Require().Error(biz.Withdraw(e.ctx, account.GetID(), fundingMoney("KES", 400), "wdr-unknown"))
	held, err := e.iaRepo.GetByID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(60000), held.AvailableBalance, "an unknown outcome keeps the funds out of reach")

	s.Require().NoError(biz.Withdraw(e.ctx, account.GetID(), fundingMoney("KES", 400), "wdr-unknown"))
	done, err := e.iaRepo.GetByID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(60000), done.AvailableBalance, "the retry completes the same withdrawal, debiting once")

	refused := &failingOperations{errs: []error{connect.NewError(connect.CodeFailedPrecondition, "rail rejected")}}
	biz = business.NewInvestorAccountBusiness(e.ctx, nil, e.iaRepo, e.icmRepo, refused,
		audit.NewWriter(nil), nil, false, "off", business.WithInvestorPayouts(fixedPayout{}))
	s.Require().Error(biz.Withdraw(e.ctx, account.GetID(), fundingMoney("KES", 400), "wdr-refused"))
	back, err := e.iaRepo.GetByID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(60000), back.AvailableBalance, "a refused payout gives the funds back")
}
