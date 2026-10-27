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
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"connectrpc.com/connect/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/frametests"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/frame/v3/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-fintech/apps/savings/service/business"
	"github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

// errOperationsDown stands in for the operations service being unreachable.
var errOperationsDown = errors.New("operations unavailable")

// recordingOperationsClient captures every transfer order the savings service
// posts, so tests can assert on the money that actually reached the ledger
// rather than on what the caller asked for.
type recordingOperationsClient struct {
	mu     sync.Mutex
	orders []*operationsv1.TransferOrderObject
	fail   error
	// emptyTxnID reproduces an operations reply that carries no transaction
	// id, which callers must treat as a posting that did not happen.
	emptyTxnID bool
}

func (c *recordingOperationsClient) TransferOrderExecute(
	_ context.Context,
	req *operationsv1.TransferOrderExecuteRequest,
) (*operationsv1.TransferOrderExecuteResponse, error) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.fail != nil {
		return nil, c.fail
	}
	c.orders = append(c.orders, req.GetData())
	txnID := "ledger-txn-1"
	if c.emptyTxnID {
		txnID = ""
	}
	return &operationsv1.TransferOrderExecuteResponse{
		Data: &operationsv1.TransferOrderObject{Id: txnID},
	}, nil
}

func (c *recordingOperationsClient) TransferOrderSearch(
	_ context.Context,
	_ *operationsv1.TransferOrderSearchRequest,
) (operationsv1connect.OperationsServiceTransferOrderSearchClientStream, error) {
	panic("not used")
}

func (c *recordingOperationsClient) IncomingPaymentNotify(
	_ context.Context,
	_ *operationsv1.IncomingPaymentNotifyRequest,
) (*operationsv1.IncomingPaymentNotifyResponse, error) {
	panic("not used")
}

func (c *recordingOperationsClient) PaymentAllocate(
	_ context.Context,
	_ *operationsv1.PaymentAllocateRequest,
) (*operationsv1.PaymentAllocateResponse, error) {
	panic("not used")
}

func (c *recordingOperationsClient) IncomingPaymentSearch(
	_ context.Context,
	_ *operationsv1.IncomingPaymentSearchRequest,
) (operationsv1connect.OperationsServiceIncomingPaymentSearchClientStream, error) {
	panic("stub: IncomingPaymentSearch not expected")
}

func (c *recordingOperationsClient) IncomingPaymentAssign(
	_ context.Context,
	_ *operationsv1.IncomingPaymentAssignRequest,
) (*operationsv1.IncomingPaymentAssignResponse, error) {
	panic("stub: IncomingPaymentAssign not expected")
}

func (c *recordingOperationsClient) OperationsJobRun(
	_ context.Context,
	_ *operationsv1.OperationsJobRunRequest,
) (*operationsv1.OperationsJobRunResponse, error) {
	panic("stub: OperationsJobRun not expected")
}

func (c *recordingOperationsClient) GroupObligationsRaise(
	_ context.Context,
	_ *operationsv1.GroupObligationsRaiseRequest,
) (*operationsv1.GroupObligationsRaiseResponse, error) {
	panic("stub: GroupObligationsRaise not expected")
}

func (c *recordingOperationsClient) GroupPeriodClose(
	_ context.Context,
	_ *operationsv1.GroupPeriodCloseRequest,
) (*operationsv1.GroupPeriodCloseResponse, error) {
	panic("stub: GroupPeriodClose not expected")
}

func (c *recordingOperationsClient) GroupMemberStanding(
	_ context.Context,
	_ *operationsv1.GroupMemberStandingRequest,
) (*operationsv1.GroupMemberStandingResponse, error) {
	panic("stub: GroupMemberStanding not expected")
}

func (c *recordingOperationsClient) count() int {
	c.mu.Lock()
	defer c.mu.Unlock()
	return len(c.orders)
}

func (c *recordingOperationsClient) last() *operationsv1.TransferOrderObject {
	c.mu.Lock()
	defer c.mu.Unlock()
	if len(c.orders) == 0 {
		return nil
	}
	return c.orders[len(c.orders)-1]
}

type savingsSuite struct {
	frametests.FrameBaseTestSuite
}

func TestSavingsSuite(t *testing.T) {
	suite.Run(t, new(savingsSuite))
}

func (s *savingsSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts(
				"savings_business",
				definition.WithUserName("ant"),
				definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false),
			),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

type savingsEnv struct {
	ctx     context.Context
	ops     *recordingOperationsClient
	deposit business.DepositBusiness
	wdr     business.WithdrawalBusiness
	account business.SavingsAccountBusiness
	accrual business.InterestAccrualBusiness
	saRepo  repository.SavingsAccountRepository
	spRepo  repository.SavingsProductRepository
	depRepo repository.DepositRepository
	wdrRepo repository.WithdrawalRepository
	sbRepo  repository.SavingsBalanceRepository
	iaRepo  repository.InterestAccrualRepository
}

// railCtx is the payment rail (operations' service account) acting in the
// env's partition: the only caller that may record a deposit.
func (e *savingsEnv) railCtx() context.Context {
	return (&security.AuthenticationClaims{
		TenantID:         "tenant-savings",
		PartitionID:      "partition-savings",
		Roles:            []string{security.ConstantSystemInternalRole},
		RegisteredClaims: jwt.RegisteredClaims{Subject: "service_operations"},
	}).ClaimsToContext(e.ctx, security.WithoutInternalTenancySkip())
}

func (s *savingsSuite) newEnv() *savingsEnv {
	s.T().Helper()

	ctx := (&security.AuthenticationClaims{
		TenantID:         "tenant-savings",
		PartitionID:      "partition-savings",
		RegisteredClaims: jwt.RegisteredClaims{Subject: "profile-savings"},
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
		frame.WithName("savings-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)
	s.Require().NoError(dbPool.DB(ctx, false).AutoMigrate(
		&models.SavingsProduct{}, &models.SavingsAccount{}, &models.Deposit{},
		&models.Withdrawal{}, &models.InterestAccrual{}, &models.SavingsBalance{},
	))
	// The partial unique indexes live in SQL migrations; recreate the two the
	// idempotency guarantees depend on so the tests exercise the real
	// constraint rather than an unconstrained table.
	s.Require().NoError(dbPool.DB(ctx, false).Exec(
		`CREATE UNIQUE INDEX uq_dep_idempotency ON deposits (idempotency_key)
		 WHERE idempotency_key <> '' AND deleted_at IS NULL`).Error)
	s.Require().NoError(dbPool.DB(ctx, false).Exec(
		`CREATE UNIQUE INDEX uq_wdr_idempotency ON withdrawals (idempotency_key)
		 WHERE idempotency_key <> '' AND deleted_at IS NULL`).Error)

	workMan := svc.WorkManager()
	spRepo := repository.NewSavingsProductRepository(ctx, dbPool, workMan)
	saRepo := repository.NewSavingsAccountRepository(ctx, dbPool, workMan)
	depRepo := repository.NewDepositRepository(ctx, dbPool, workMan)
	wdrRepo := repository.NewWithdrawalRepository(ctx, dbPool, workMan)
	iaRepo := repository.NewInterestAccrualRepository(ctx, dbPool, workMan)
	sbRepo := repository.NewSavingsBalanceRepository(ctx, dbPool, workMan)

	ops := &recordingOperationsClient{}
	writer := audit.NewWriter(svc.EventsManager())

	return &savingsEnv{
		ctx:     ctx,
		ops:     ops,
		deposit: business.NewDepositBusiness(ctx, depRepo, saRepo, ops, writer),
		wdr:     business.NewWithdrawalBusiness(ctx, wdrRepo, saRepo, ops, writer, nil, false, "off"),
		account: business.NewSavingsAccountBusiness(
			ctx, svc.EventsManager(), saRepo, spRepo, depRepo, wdrRepo, iaRepo, sbRepo),
		accrual: business.NewInterestAccrualBusiness(
			ctx, iaRepo, saRepo, spRepo, sbRepo, svc.EventsManager(), ops, writer),
		saRepo:  saRepo,
		spRepo:  spRepo,
		depRepo: depRepo,
		wdrRepo: wdrRepo,
		sbRepo:  sbRepo,
		iaRepo:  iaRepo,
	}
}

// seedAccount provisions a product, an active account and its balance row
// directly through the repositories, so the money-movement tests start from a
// known state without depending on the event pipeline.
func (e *savingsEnv) seedAccount(s *savingsSuite, currency string) *models.SavingsAccount {
	s.T().Helper()

	product := &models.SavingsProduct{
		BankID:       "bank-1",
		Name:         "Ordinary savings",
		Code:         "SAV-" + util.RandomAlphaNumericString(6),
		CurrencyCode: currency,
		InterestRate: 1200,
	}
	product.GenID(e.ctx)
	s.Require().NoError(e.spRepo.Create(e.ctx, product))

	account := &models.SavingsAccount{
		ProductID:    product.GetID(),
		OwnerID:      "owner-1",
		BankID:       "bank-1",
		CurrencyCode: currency,
		Status:       int32(savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_ACTIVE),
	}
	account.GenID(e.ctx)
	account.LedgerAccountID = business.LedgerAccountRef(account)
	account.PaymentAccountRef = business.PaymentAccountRef(account)
	s.Require().NoError(e.saRepo.Create(e.ctx, account))

	_, err := e.sbRepo.Ensure(e.ctx, account.GetID(), currency, &account.BaseModel)
	s.Require().NoError(err)

	return account
}

func money(currency, units string) *commonv1.Money {
	return &commonv1.Money{CurrencyCode: currency, Units: mustUnits(units)}
}

func mustUnits(units string) int64 {
	var v int64
	for _, r := range units {
		v = v*10 + int64(r-'0')
	}
	return v
}

func (s *savingsSuite) TestDepositCreditsBalanceAndCompletesRow() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")

	result, err := e.deposit.Record(e.railCtx(), &savingsv1.DepositRecordRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "500"),
		IdempotencyKey:   "dep-1",
		Channel:          "MOBILE",
	})
	s.Require().NoError(err)
	s.Equal(savingsv1.DepositStatus_DEPOSIT_STATUS_COMPLETED, result.GetStatus())
	s.Equal("ledger-txn-1", result.GetLedgerTransactionId())

	stored, err := e.depRepo.GetByID(e.ctx, result.GetId())
	s.Require().NoError(err)
	s.Equal(int32(savingsv1.DepositStatus_DEPOSIT_STATUS_COMPLETED), stored.Status)
	s.Equal("ledger-txn-1", stored.LedgerTransactionID)

	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(50000), balance.Balance)
	s.Equal(int64(50000), balance.TotalDeposits)
}

func (s *savingsSuite) TestDepositIsIdempotentOnTheKey() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")

	req := &savingsv1.DepositRecordRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "500"),
		IdempotencyKey:   "dep-retry",
	}

	first, err := e.deposit.Record(e.railCtx(), req)
	s.Require().NoError(err)
	second, err := e.deposit.Record(e.railCtx(), req)
	s.Require().NoError(err)

	s.Equal(first.GetId(), second.GetId(), "a retry must resolve to the original deposit")
	s.Equal(1, e.ops.count(), "a retry must not post to the ledger twice")

	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(50000), balance.Balance)
}

// TestDepositRetryFinishesAnUnsettledClaim covers the window between the
// idempotency claim and the ledger posting: a retry must drive that same
// deposit to completion, and credit the member exactly once.
func (s *savingsSuite) TestDepositRetryFinishesAnUnsettledClaim() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")

	req := &savingsv1.DepositRecordRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "700"),
		IdempotencyKey:   "dep-resume",
	}

	e.ops.fail = errOperationsDown
	_, err := e.deposit.Record(e.railCtx(), req)
	s.Require().Error(err)

	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Zero(balance.Balance, "a failed posting must credit nothing")

	e.ops.fail = nil
	result, err := e.deposit.Record(e.railCtx(), req)
	s.Require().NoError(err)
	s.Equal(savingsv1.DepositStatus_DEPOSIT_STATUS_COMPLETED, result.GetStatus())

	balance, err = e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(70000), balance.Balance, "the resumed deposit must credit once")
	s.Equal(1, e.ops.count())
}

func (s *savingsSuite) TestDepositRequiresIdempotencyKeyWithTheGateOff() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")

	_, err := e.deposit.Record(e.railCtx(), &savingsv1.DepositRecordRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "500"),
	})
	s.Require().ErrorIs(err, business.ErrIdempotencyKeyRequired)
	s.Equal(0, e.ops.count())
}

func (s *savingsSuite) TestDepositRejectsAForeignCurrency() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")

	_, err := e.deposit.Record(e.railCtx(), &savingsv1.DepositRecordRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("USD", "100"),
		IdempotencyKey:   "dep-usd",
	})
	s.Require().ErrorIs(err, business.ErrCurrencyMismatch)

	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Zero(balance.Balance)
}

// TestDepositPostsZeroDecimalCurrencyAtFaceValue pins the ISO 4217 handling:
// a JPY deposit has no minor unit, so the ledger must see the same number the
// caller sent, not a hundredth of it.
func (s *savingsSuite) TestDepositPostsZeroDecimalCurrencyAtFaceValue() {
	e := s.newEnv()
	account := e.seedAccount(s, "JPY")

	_, err := e.deposit.Record(e.railCtx(), &savingsv1.DepositRecordRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("JPY", "100000"),
		IdempotencyKey:   "dep-jpy",
	})
	s.Require().NoError(err)

	posted := e.ops.last()
	s.Require().NotNil(posted)
	s.Equal(int64(100000), posted.GetAmount().GetUnits())
	s.Equal("JPY", posted.GetAmount().GetCurrencyCode())

	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(100000), balance.Balance)
}

// TestDepositRoutesThroughServerDerivedLedgerRefs proves a caller cannot aim
// a posting at an account of their choosing.
func (s *savingsSuite) TestDepositRoutesThroughServerDerivedLedgerRefs() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")

	_, err := e.deposit.Record(e.railCtx(), &savingsv1.DepositRecordRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "100"),
		IdempotencyKey:   "dep-route",
	})
	s.Require().NoError(err)

	posted := e.ops.last()
	s.Require().NotNil(posted)
	s.Equal(business.PaymentAccountRef(account), posted.GetDebitAccountRef())
	s.Equal(business.LedgerAccountRef(account), posted.GetCreditAccountRef())
}

func (s *savingsSuite) TestWithdrawalHoldsThenSettles() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")
	s.fund(e, account, "1000", "dep-fund")

	requested, err := e.wdr.Request(e.ctx, &savingsv1.WithdrawalRequestRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "400"),
		IdempotencyKey:   "wdr-1",
	})
	s.Require().NoError(err)
	s.Equal(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_PENDING, requested.GetStatus())

	held, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(100000), held.Balance)
	s.Equal(int64(40000), held.ReservedBalance)

	approved, err := e.wdr.Approve(e.ctx, requested.GetId())
	s.Require().NoError(err)
	s.Equal(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_COMPLETED, approved.GetStatus())

	// The money leaves through the payment rail, addressed to the owner.
	order := e.ops.last()
	s.Equal(operationsv1.TransferOrderType_TRANSFER_ORDER_TYPE_DISBURSEMENT, order.GetTransferType())
	s.Equal(account.OwnerID, order.GetExtraData().GetFields()["recipient_client_id"].GetStringValue())

	settled, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(60000), settled.Balance)
	s.Zero(settled.ReservedBalance)
	s.Equal(int64(40000), settled.TotalWithdrawals)
}

func (s *savingsSuite) TestWithdrawalRequestRefusesToOverdraw() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")
	s.fund(e, account, "100", "dep-small")

	_, err := e.wdr.Request(e.ctx, &savingsv1.WithdrawalRequestRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "500"),
		IdempotencyKey:   "wdr-over",
	})
	s.Require().ErrorIs(err, business.ErrInsufficientBalance)

	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Zero(balance.ReservedBalance, "a rejected request must leave no hold behind")
}

func (s *savingsSuite) TestWithdrawalRequestIsIdempotentOnTheKey() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")
	s.fund(e, account, "1000", "dep-fund")

	req := &savingsv1.WithdrawalRequestRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "300"),
		IdempotencyKey:   "wdr-retry",
	}
	first, err := e.wdr.Request(e.ctx, req)
	s.Require().NoError(err)
	second, err := e.wdr.Request(e.ctx, req)
	s.Require().NoError(err)

	s.Equal(first.GetId(), second.GetId())

	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(30000), balance.ReservedBalance, "a retry must not place a second hold")
}

// TestWithdrawalApproveKeepsTheHoldWhenTheLedgerRefuses is the regression that
// matters most: money must never leave the balance when the posting failed.
func (s *savingsSuite) TestWithdrawalApproveKeepsTheHoldWhenTheLedgerRefuses() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")
	s.fund(e, account, "1000", "dep-fund")

	requested, err := e.wdr.Request(e.ctx, &savingsv1.WithdrawalRequestRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "400"),
		IdempotencyKey:   "wdr-fail",
	})
	s.Require().NoError(err)

	e.ops.fail = errOperationsDown
	_, err = e.wdr.Approve(e.ctx, requested.GetId())
	s.Require().Error(err)

	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(100000), balance.Balance, "the balance must be untouched")
	s.Equal(int64(40000), balance.ReservedBalance, "the hold must survive so a retry can settle")

	stored, err := e.wdrRepo.GetByID(e.ctx, requested.GetId())
	s.Require().NoError(err)
	s.Equal(int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_PENDING), stored.Status)

	// The retry succeeds once operations recovers.
	e.ops.fail = nil
	approved, err := e.wdr.Approve(e.ctx, requested.GetId())
	s.Require().NoError(err)
	s.Equal(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_COMPLETED, approved.GetStatus())
}

// A payout the rail or operations refuses for good rejects the withdrawal
// and gives the member back the held amount.
func (s *savingsSuite) TestWithdrawalRejectedPayoutReleasesTheHold() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")
	s.fund(e, account, "1000", "dep-fund")

	requested, err := e.wdr.Request(e.ctx, &savingsv1.WithdrawalRequestRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "400"),
		IdempotencyKey:   "wdr-rejected",
	})
	s.Require().NoError(err)

	e.ops.fail = connect.NewError(connect.CodeFailedPrecondition,
		"payout destination is not a contact of the recipient")
	_, err = e.wdr.Approve(e.ctx, requested.GetId())
	s.Require().ErrorIs(err, business.ErrWithdrawalPayoutRejected)
	e.ops.fail = nil

	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(100000), balance.Balance)
	s.Zero(balance.ReservedBalance, "the hold is released")

	stored, err := e.wdrRepo.GetByID(e.ctx, requested.GetId())
	s.Require().NoError(err)
	s.Equal(int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_REJECTED), stored.Status)
}

func (s *savingsSuite) TestWithdrawalCancelReleasesTheHold() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")
	s.fund(e, account, "1000", "dep-fund")

	requested, err := e.wdr.Request(e.ctx, &savingsv1.WithdrawalRequestRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "400"),
		IdempotencyKey:   "wdr-cancel",
	})
	s.Require().NoError(err)

	cancelled, err := e.wdr.Cancel(e.ctx, requested.GetId(), "member changed their mind")
	s.Require().NoError(err)
	s.Equal(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_REJECTED, cancelled.GetStatus())

	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Zero(balance.ReservedBalance)
	s.Equal(int64(100000), balance.Balance)

	_, err = e.wdr.Cancel(e.ctx, requested.GetId(), "again")
	s.Require().ErrorIs(err, business.ErrInvalidStatusTransition)
}

func (s *savingsSuite) TestCloseRefusesAnAccountThatStillHoldsFunds() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")
	s.fund(e, account, "250", "dep-close")

	_, err := e.account.Close(e.ctx, account.GetID(), "member left")
	s.Require().ErrorIs(err, business.ErrAccountHasBalance)
}

// TestStatementDefaultsOrdersAndCarriesARunningBalance covers the whole
// statement contract in one pass: an omitted to_date must not empty the
// statement, entries must arrive oldest-first, and each row must carry the
// balance the account held after it.
func (s *savingsSuite) TestStatementDefaultsOrdersAndCarriesARunningBalance() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")

	s.fund(e, account, "1000", "stmt-1")
	s.fund(e, account, "500", "stmt-2")

	requested, err := e.wdr.Request(e.ctx, &savingsv1.WithdrawalRequestRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "200"),
		IdempotencyKey:   "stmt-wdr",
	})
	s.Require().NoError(err)
	_, err = e.wdr.Approve(e.ctx, requested.GetId())
	s.Require().NoError(err)

	statement, err := e.account.GetStatement(e.ctx, account.GetID(), time.Time{}, time.Time{})
	s.Require().NoError(err)
	s.Require().Len(statement.GetEntries(), 3)

	entries := statement.GetEntries()
	for i := 1; i < len(entries); i++ {
		s.LessOrEqual(entries[i-1].GetDate(), entries[i].GetDate(), "entries must be oldest first")
	}

	last := entries[len(entries)-1]
	s.Equal(int64(1300), last.GetBalance().GetUnits(), "the running balance must close on the real balance")
}

// fund puts settled money into an account through the real deposit path.
func (s *savingsSuite) fund(e *savingsEnv, account *models.SavingsAccount, units, key string) {
	s.T().Helper()
	_, err := e.deposit.Record(e.railCtx(), &savingsv1.DepositRecordRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money(account.CurrencyCode, units),
		IdempotencyKey:   key,
	})
	s.Require().NoError(err)
}

// TestAccrualWithoutALedgerTransactionIsNotSettled is the regression for a
// settlement guard that keyed on the ledger transaction id: storing an empty
// id left the guard satisfied, so the next run credited the interest again.
func (s *savingsSuite) TestAccrualWithoutALedgerTransactionIsNotSettled() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")
	s.fund(e, account, "1000", "dep-accrual")

	e.ops.emptyTxnID = true
	periodStart := time.Now().UTC().AddDate(0, -1, 0)
	periodEnd := time.Now().UTC()

	_, err := e.accrual.Accrue(e.ctx, account.GetID(), periodStart, periodEnd)
	s.Require().Error(err, "a posting with no transaction id must not be treated as settled")

	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(100000), balance.Balance, "no interest may be credited without a ledger transaction")
	s.Zero(balance.TotalInterest)
}

// TestSettleRejectsAnEmptyLedgerTransaction pins the repository half of the
// same guard.
func (s *savingsSuite) TestSettleRejectsAnEmptyLedgerTransaction() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")
	s.fund(e, account, "1000", "dep-settle")

	periodStart := time.Now().UTC().AddDate(0, -1, 0)
	periodEnd := time.Now().UTC()
	accrual := &models.InterestAccrual{
		SavingsAccountID: account.GetID(),
		Amount:           500,
		CurrencyCode:     "KES",
		PeriodStart:      &periodStart,
		PeriodEnd:        &periodEnd,
	}
	accrual.GenID(e.ctx)
	accrual.CopyPartitionInfo(&account.BaseModel)
	s.Require().NoError(e.iaRepo.Create(e.ctx, accrual))

	err := e.iaRepo.Settle(e.ctx, accrual)
	s.Require().ErrorIs(err, repository.ErrLedgerTransactionIDRequired)

	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(100000), balance.Balance)
}

// TestReleaseHoldReportsThatItReleasedNothing is the regression for a cancel
// that audited a release which never happened: a withdrawal that has already
// left PENDING must report the transition as refused.
func (s *savingsSuite) TestReleaseHoldReportsThatItReleasedNothing() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")
	s.fund(e, account, "1000", "dep-release")

	requested, err := e.wdr.Request(e.ctx, &savingsv1.WithdrawalRequestRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "400"),
		IdempotencyKey:   "wdr-release-twice",
	})
	s.Require().NoError(err)

	stored, err := e.wdrRepo.GetByID(e.ctx, requested.GetId())
	s.Require().NoError(err)

	released, err := e.wdrRepo.ReleaseHold(e.ctx, stored, "first cancel")
	s.Require().NoError(err)
	s.True(released)

	released, err = e.wdrRepo.ReleaseHold(e.ctx, stored, "second cancel")
	s.Require().NoError(err)
	s.False(released, "a withdrawal that already left PENDING releases nothing")

	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Zero(balance.ReservedBalance, "the hold must be returned exactly once")
	s.Equal(int64(100000), balance.Balance)
}

// TestWithdrawalOnAnUnprovisionedAccountIsNotReportedAsPoverty separates a
// setup fault from a genuine shortfall: an account with no balance row has
// not been provisioned, which is not the same as being out of money.
func (s *savingsSuite) TestWithdrawalOnAnUnprovisionedAccountIsNotReportedAsPoverty() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")
	s.Require().NoError(e.sbRepo.Delete(e.ctx, balanceIDFor(s, e, account.GetID())))

	_, err := e.wdr.Request(e.ctx, &savingsv1.WithdrawalRequestRequest{
		SavingsAccountId: account.GetID(),
		Amount:           money("KES", "10"),
		IdempotencyKey:   "wdr-unprovisioned",
	})
	s.Require().ErrorIs(err, business.ErrBalanceNotProvisioned)
	s.NotErrorIs(err, business.ErrInsufficientBalance)
}

func balanceIDFor(s *savingsSuite, e *savingsEnv, accountID string) string {
	s.T().Helper()
	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, accountID)
	s.Require().NoError(err)
	return balance.GetID()
}

func (s *savingsSuite) TestDepositsComeOnlyFromThePaymentRail() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")

	_, err := e.deposit.Record(e.ctx, &savingsv1.DepositRecordRequest{
		SavingsAccountId: account.GetID(),
		Amount:           models.MinorUnitsToMoney(10_000, "KES"),
		Channel:          "mobile_money",
		IdempotencyKey:   "by-hand",
	})
	s.Require().ErrorIs(err, business.ErrDepositRecordInternalOnly, "a person never types a deposit")

	_, err = e.deposit.Record(e.railCtx(), &savingsv1.DepositRecordRequest{
		SavingsAccountId: account.GetID(),
		Amount:           models.MinorUnitsToMoney(10_000, "KES"),
		Channel:          "cash",
		IdempotencyKey:   "cash",
	})
	s.Require().ErrorIs(err, business.ErrCashDepositRefused)
}

// A withdrawal the rail fails after it completed gives the member their
// money back, once, and only the payment rail can say so.
func (s *savingsSuite) TestWithdrawalFailedAtTheRailIsReversedOnce() {
	e := s.newEnv()
	account := e.seedAccount(s, "KES")
	s.fund(e, account, "1000", "dep-late")
	requested, err := e.wdr.Request(e.ctx, &savingsv1.WithdrawalRequestRequest{
		SavingsAccountId: account.GetID(), Amount: money("KES", "400"), IdempotencyKey: "wdr-late",
	})
	s.Require().NoError(err)
	_, err = e.wdr.Approve(e.ctx, requested.GetId())
	s.Require().NoError(err)

	_, err = e.wdr.PayoutFailed(e.ctx, "withdrawal:"+requested.GetId(), "rail failed")
	s.Require().ErrorIs(err, business.ErrPayoutOutcomeInternalOnly)

	reversed, err := e.wdr.PayoutFailed(e.railCtx(), "withdrawal:"+requested.GetId(), "rail failed")
	s.Require().NoError(err)
	s.True(reversed)
	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, account.GetID())
	s.Require().NoError(err)
	s.Equal(int64(100000), balance.Balance, "the member's money is back")
	s.Zero(balance.TotalWithdrawals)
	got, err := e.wdr.Get(e.ctx, requested.GetId())
	s.Require().NoError(err)
	s.Equal(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_REVERSED, got.GetStatus())

	again, err := e.wdr.PayoutFailed(e.railCtx(), "withdrawal:"+requested.GetId(), "rail failed")
	s.Require().NoError(err)
	s.False(again, "never reversed twice")
}

// The scheduled job accrues the last closed day once per account, and an
// account with nothing to accrue is settled too rather than retried forever.
func (s *savingsSuite) TestInterestJobAccruesEachDayOnce() {
	e := s.newEnv()
	funded := e.seedAccount(s, "KES")
	s.fund(e, funded, "1000", "dep-interest")
	e.seedAccount(s, "KES") // nothing to accrue
	jobs := business.NewSavingsJobs(e.saRepo, e.accrual, "service_savings")

	_, _, err := jobs.Run(e.ctx, savingsv1.SavingsJob_SAVINGS_JOB_ACCRUE_INTEREST, 10)
	s.Require().ErrorIs(err, business.ErrJobCallerNotInternal)

	processed, more, err := jobs.Run(e.railCtx(), savingsv1.SavingsJob_SAVINGS_JOB_ACCRUE_INTEREST, 10)
	s.Require().NoError(err)
	s.Equal(2, processed)
	s.False(more)
	balance, err := e.sbRepo.GetBySavingsAccountID(e.ctx, funded.GetID())
	s.Require().NoError(err)
	s.Positive(balance.TotalInterest, "a day's interest is credited")

	again, _, err := jobs.Run(e.railCtx(), savingsv1.SavingsJob_SAVINGS_JOB_ACCRUE_INTEREST, 10)
	s.Require().NoError(err)
	s.Zero(again, "both accounts are settled for the day, the empty one included")
	still, err := e.sbRepo.GetBySavingsAccountID(e.ctx, funded.GetID())
	s.Require().NoError(err)
	s.Equal(balance.TotalInterest, still.TotalInterest)
}
