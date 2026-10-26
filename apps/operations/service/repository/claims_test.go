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

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

type claimsSuite struct {
	frametests.FrameBaseTestSuite
}

func TestClaimsSuite(t *testing.T) {
	suite.Run(t, new(claimsSuite))
}

func (s *claimsSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts(
				"operations_claims",
				definition.WithUserName("ant"),
				definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false),
			),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

type claimsEnv struct {
	ctx      context.Context
	orders   repository.TransferOrderRepository
	payments repository.IncomingPaymentRepository
	obs      repository.ObligationRepository
}

func (s *claimsSuite) newEnv() *claimsEnv {
	s.T().Helper()

	ctx := (&security.AuthenticationClaims{
		TenantID:         "tenant-ops",
		PartitionID:      "partition-ops",
		RegisteredClaims: jwt.RegisteredClaims{Subject: "profile-ops"},
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
		frame.WithName("operations-claims-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)
	s.Require().NoError(repository.MigrateForTest(ctx, dbPool))

	workMan := svc.WorkManager()
	return &claimsEnv{
		ctx:      ctx,
		orders:   repository.NewTransferOrderRepository(ctx, dbPool, workMan),
		payments: repository.NewIncomingPaymentRepository(ctx, dbPool, workMan),
		obs:      repository.NewObligationRepository(ctx, dbPool, workMan),
	}
}

func (s *claimsSuite) newOrder(ctx context.Context, reference string) *models.TransferOrder {
	s.T().Helper()
	order := &models.TransferOrder{
		DebitAccountRef:  "debit",
		CreditAccountRef: "credit",
		Amount:           1000,
		Currency:         "KES",
		OrderType:        constants.TransferTypeLoanRepayment,
		Reference:        reference,
		State:            int32(constants.StateJustCreated),
	}
	order.GenID(ctx)
	return order
}

// A retried Save with the same reference must converge on one row, not create
// a second ledger posting.
func (s *claimsSuite) TestCreateIfAbsentConvergesOnReference() {
	e := s.newEnv()

	first := s.newOrder(e.ctx, "repayment:1:principal")
	s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, first))

	second := s.newOrder(e.ctx, "repayment:1:principal")
	s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, second))

	s.Require().Equal(first.GetID(), second.GetID(),
		"a retry must resolve to the row that already owns the reference")

	count, err := e.orders.CountBy(e.ctx, map[string]any{"reference": "repayment:1:principal"})
	s.Require().NoError(err)
	s.Require().Equal(int64(1), count)
}

// An empty reference carries no idempotency, so those rows must still insert.
func (s *claimsSuite) TestCreateIfAbsentAllowsEmptyReferences() {
	e := s.newEnv()

	for range 3 {
		order := s.newOrder(e.ctx, "")
		s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, order))
	}

	count, err := e.orders.CountBy(e.ctx, map[string]any{"reference": ""})
	s.Require().NoError(err)
	s.Require().Equal(int64(3), count)
}

// Only one of two concurrent executions may claim an order.
func (s *claimsSuite) TestClaimStateIsExclusive() {
	e := s.newEnv()

	order := s.newOrder(e.ctx, "repayment:2:principal")
	s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, order))

	const racers = 8
	var (
		wg    sync.WaitGroup
		mu    sync.Mutex
		winst int
	)
	for range racers {
		wg.Add(1)
		go func() {
			defer wg.Done()
			claimed, err := e.orders.ClaimState(
				e.ctx,
				order.GetID(),
				[]int32{int32(constants.StateJustCreated)},
				int32(constants.StateCheckCreated),
			)
			if err == nil && claimed {
				mu.Lock()
				winst++
				mu.Unlock()
			}
		}()
	}
	wg.Wait()

	s.Require().Equal(1, winst, "exactly one caller may claim a transfer order")

	stored, err := e.orders.GetByID(e.ctx, order.GetID())
	s.Require().NoError(err)
	s.Require().Equal(int32(constants.StateCheckCreated), stored.State)
}

// The unique index on transaction_id is what makes payment dedupe real.
func (s *claimsSuite) TestIncomingPaymentDedupesOnTransactionID() {
	e := s.newEnv()

	first := &models.IncomingPayment{
		Amount:        5000,
		Currency:      "KES",
		TransactionID: "txn-dedupe",
		State:         int32(constants.StateJustCreated),
	}
	first.GenID(e.ctx)
	stored, err := e.payments.CreateIfAbsent(e.ctx, first)
	s.Require().NoError(err)
	s.Require().Equal(first.GetID(), stored.GetID())

	second := &models.IncomingPayment{
		Amount:        5000,
		Currency:      "KES",
		TransactionID: "txn-dedupe",
		State:         int32(constants.StateJustCreated),
	}
	second.GenID(e.ctx)
	stored, err = e.payments.CreateIfAbsent(e.ctx, second)
	s.Require().NoError(err)
	s.Require().Equal(first.GetID(), stored.GetID(),
		"a repeated notification must resolve to the first payment row")

	count, err := e.payments.CountBy(e.ctx, map[string]any{"transaction_id": "txn-dedupe"})
	s.Require().NoError(err)
	s.Require().Equal(int64(1), count)
}

// Two concurrent allocations of the same obligation must not both succeed
// against the same balance.
func (s *claimsSuite) TestConsumeAmountIsExclusive() {
	e := s.newEnv()

	obligation := &models.Obligation{
		MembershipID: "member-1",
		Amount:       1000,
		Currency:     "KES",
		State:        int32(constants.StateActive),
	}
	obligation.GenID(e.ctx)
	s.Require().NoError(e.obs.Create(e.ctx, obligation))

	const racers = 6
	var (
		wg    sync.WaitGroup
		mu    sync.Mutex
		wins  int
		total int64
	)
	for range racers {
		wg.Add(1)
		go func() {
			defer wg.Done()
			consumed, err := e.obs.ConsumeAmount(e.ctx, obligation.GetID(), 600)
			if err == nil && consumed {
				mu.Lock()
				wins++
				total += 600
				mu.Unlock()
			}
		}()
	}
	wg.Wait()

	s.Require().Equal(1, wins, "only one allocation may consume more than half the obligation")

	stored, err := e.obs.GetByID(e.ctx, obligation.GetID())
	s.Require().NoError(err)
	s.Require().Equal(int64(1000)-total, stored.Amount)
}

// Consuming the whole balance retires the obligation.
func (s *claimsSuite) TestConsumeAmountDeactivatesWhenFullyPaid() {
	e := s.newEnv()

	obligation := &models.Obligation{
		MembershipID: "member-2",
		Amount:       750,
		Currency:     "KES",
		State:        int32(constants.StateActive),
	}
	obligation.GenID(e.ctx)
	s.Require().NoError(e.obs.Create(e.ctx, obligation))

	consumed, err := e.obs.ConsumeAmount(e.ctx, obligation.GetID(), 750)
	s.Require().NoError(err)
	s.Require().True(consumed)

	stored, err := e.obs.GetByID(e.ctx, obligation.GetID())
	s.Require().NoError(err)
	s.Require().Equal(int64(0), stored.Amount)
	s.Require().Equal(int32(constants.StateInactive), stored.State)

	// A second allocation finds nothing left.
	consumed, err = e.obs.ConsumeAmount(e.ctx, obligation.GetID(), 1)
	s.Require().NoError(err)
	s.Require().False(consumed)
}

// A released order goes back to JustCreated with its failure reason, and only
// an order that is actually executing can be released.
func (s *claimsSuite) TestReleaseExecutionReturnsOrderToJustCreated() {
	e := s.newEnv()

	order := s.newOrder(e.ctx, "disbursement:release")
	s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, order))

	released, err := e.orders.ReleaseExecution(e.ctx, order.GetID(), "ledger down")
	s.Require().NoError(err)
	s.Require().False(released, "an unclaimed order has nothing to release")

	claimed, err := e.orders.ClaimState(e.ctx, order.GetID(),
		[]int32{int32(constants.StateJustCreated)}, int32(constants.StateCheckCreated))
	s.Require().NoError(err)
	s.Require().True(claimed)

	released, err = e.orders.ReleaseExecution(e.ctx, order.GetID(), "ledger down")
	s.Require().NoError(err)
	s.Require().True(released)

	stored, err := e.orders.GetByID(e.ctx, order.GetID())
	s.Require().NoError(err)
	s.Require().Equal(int32(constants.StateJustCreated), stored.State)
	s.Require().Equal("ledger down", stored.FailureReason)
}

// Only one of many resumers may take over a stale execution, and a fresh
// execution is never taken over.
func (s *claimsSuite) TestClaimStaleExecutionIsExclusiveAndRespectsFreshness() {
	e := s.newEnv()

	order := s.newOrder(e.ctx, "disbursement:stale")
	s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, order))
	claimed, err := e.orders.ClaimState(e.ctx, order.GetID(),
		[]int32{int32(constants.StateJustCreated)}, int32(constants.StateCheckCreated))
	s.Require().NoError(err)
	s.Require().True(claimed)

	resumed, err := e.orders.ClaimStaleExecution(e.ctx, order.GetID(), time.Now().Add(-time.Hour))
	s.Require().NoError(err)
	s.Require().False(resumed, "a fresh execution must not be resumed")

	// Age the execution the way a crashed replica would leave it.
	s.Require().NoError(e.orders.Pool().DB(e.ctx, false).
		Table("transfer_orders").
		Where("id = ?", order.GetID()).
		Update("modified_at", time.Now().Add(-time.Hour)).Error)
	staleBefore := time.Now().Add(-2 * time.Minute)

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
			ok, cErr := e.orders.ClaimStaleExecution(e.ctx, order.GetID(), staleBefore)
			if cErr == nil && ok {
				mu.Lock()
				wins++
				mu.Unlock()
			}
		}()
	}
	wg.Wait()
	s.Require().Equal(1, wins, "exactly one resumer may take over a stale execution")
}

// The payout claim is taken once for the life of the order.
func (s *claimsSuite) TestClaimPaymentInitiationIsOnce() {
	e := s.newEnv()

	order := s.newOrder(e.ctx, "disbursement:payout")
	s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, order))

	first, err := e.orders.ClaimPaymentInitiation(e.ctx, order.GetID())
	s.Require().NoError(err)
	s.Require().True(first)

	second, err := e.orders.ClaimPaymentInitiation(e.ctx, order.GetID())
	s.Require().NoError(err)
	s.Require().False(second, "a second attempt must not send another payout")

	s.Require().NoError(e.orders.MarkLedgerPosted(e.ctx, order.GetID(), "ledger-1"))
	s.Require().NoError(e.orders.RecordPaymentID(e.ctx, order.GetID(), "pay-1"))

	stored, err := e.orders.GetByID(e.ctx, order.GetID())
	s.Require().NoError(err)
	s.Require().NotNil(stored.PaymentInitiatedAt)
	s.Require().Equal("ledger-1", stored.LedgerTransactionID)
	s.Require().Equal("pay-1", stored.PaymentID)
}

// An order is only declared failed while nothing has moved; once the ledger
// posted or a payout was initiated the mark is refused.
func (s *claimsSuite) TestMarkFailedIfUnpostedGuardsProgressedOrders() {
	e := s.newEnv()

	fresh := s.newOrder(e.ctx, "disbursement:fail-fresh")
	s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, fresh))
	marked, err := e.orders.MarkFailedIfUnposted(e.ctx, fresh.GetID())
	s.Require().NoError(err)
	s.Require().True(marked)

	posted := s.newOrder(e.ctx, "disbursement:fail-posted")
	s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, posted))
	s.Require().NoError(e.orders.MarkLedgerPosted(e.ctx, posted.GetID(), "ledger-1"))
	marked, err = e.orders.MarkFailedIfUnposted(e.ctx, posted.GetID())
	s.Require().NoError(err)
	s.Require().False(marked, "a posted order cannot be declared failed")

	paid := s.newOrder(e.ctx, "disbursement:fail-paid")
	s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, paid))
	claimed, err := e.orders.ClaimPaymentInitiation(e.ctx, paid.GetID())
	s.Require().NoError(err)
	s.Require().True(claimed)
	marked, err = e.orders.MarkFailedIfUnposted(e.ctx, paid.GetID())
	s.Require().NoError(err)
	s.Require().False(marked, "an order whose payout reached the rail cannot be declared failed")
}

// A stale payout claim is retaken by exactly one of the resumers that
// observed it, and never once a payment id was recorded.
func (s *claimsSuite) TestRetakePaymentInitiationIsCompareAndSwap() {
	e := s.newEnv()

	order := s.newOrder(e.ctx, "disbursement:retake")
	s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, order))
	_, err := e.orders.ClaimPaymentInitiation(e.ctx, order.GetID())
	s.Require().NoError(err)

	stored, err := e.orders.GetByID(e.ctx, order.GetID())
	s.Require().NoError(err)
	s.Require().NotNil(stored.PaymentInitiatedAt)
	observed := *stored.PaymentInitiatedAt

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
			ok, rErr := e.orders.RetakePaymentInitiation(e.ctx, order.GetID(), observed)
			if rErr == nil && ok {
				mu.Lock()
				wins++
				mu.Unlock()
			}
		}()
	}
	wg.Wait()
	s.Require().Equal(1, wins, "exactly one resumer may retake a stale payout claim")

	stored, err = e.orders.GetByID(e.ctx, order.GetID())
	s.Require().NoError(err)
	s.Require().NoError(e.orders.RecordPaymentID(e.ctx, order.GetID(), "pay-9"))
	retaken, err := e.orders.RetakePaymentInitiation(e.ctx, order.GetID(), *stored.PaymentInitiatedAt)
	s.Require().NoError(err)
	s.Require().False(retaken, "a confirmed payout is never retaken")
}

// Exactly one allocation run may hold a payment's lease; a stale lease is
// taken over; the outcome releases it.
func (s *claimsSuite) TestClaimAllocationIsExclusiveAndStaleAware() {
	e := s.newEnv()

	payment := &models.IncomingPayment{
		TransactionID: "txn-lease", Amount: 1000, Currency: "KES",
		OwnerID: "member-lease", OwnerType: "membership", State: int32(constants.StateJustCreated),
	}
	payment.GenID(e.ctx)
	stored, err := e.payments.CreateIfAbsent(e.ctx, payment)
	s.Require().NoError(err)

	const racers = 8
	var (
		wg   sync.WaitGroup
		mu   sync.Mutex
		wins int
	)
	staleBefore := time.Now().Add(-2 * time.Minute)
	var winner *models.IncomingPayment
	for range racers {
		wg.Add(1)
		go func() {
			defer wg.Done()
			fresh, ok, cErr := e.payments.ClaimAllocation(e.ctx, stored.GetID(), staleBefore)
			if cErr == nil && ok {
				mu.Lock()
				wins++
				winner = fresh
				mu.Unlock()
			}
		}()
	}
	wg.Wait()
	s.Require().Equal(1, wins, "exactly one run may hold the allocation lease")
	s.Require().NotNil(winner)
	s.Require().NotNil(winner.AllocatingAt, "the winner receives the row carrying its lease")

	// A stranger's lease value cannot write the outcome.
	landed, err := e.payments.SetAllocationOutcome(e.ctx, stored.GetID(), time.Now().Add(time.Hour),
		int32(constants.StateActive), 400)
	s.Require().NoError(err)
	s.Require().False(landed, "the outcome is fenced by the lease")

	landed, err = e.payments.SetAllocationOutcome(e.ctx, stored.GetID(), *winner.AllocatingAt,
		int32(constants.StateActive), 400)
	s.Require().NoError(err)
	s.Require().True(landed)

	_, again, err := e.payments.ClaimAllocation(e.ctx, stored.GetID(), staleBefore)
	s.Require().NoError(err)
	s.Require().True(again, "the outcome releases the lease")

	s.Require().NoError(e.payments.Pool().DB(e.ctx, false).
		Table("incoming_payments").Where("id = ?", stored.GetID()).
		Update("allocating_at", time.Now().Add(-time.Hour)).Error)
	_, takeover, err := e.payments.ClaimAllocation(e.ctx, stored.GetID(), staleBefore)
	s.Require().NoError(err)
	s.Require().True(takeover, "a stale lease is taken over")
}

// Consuming an obligation and marking its allocation order are one
// transaction: a second attempt for the same order changes nothing, and an
// obligation too small for the amount leaves both rows untouched.
func (s *claimsSuite) TestConsumeObligationForOrderIsAtomic() {
	e := s.newEnv()

	obligation := &models.Obligation{
		MembershipID: "member-atomic", CauseType: "loan_principal", Amount: 50_000,
		State: int32(constants.StateActive),
	}
	obligation.GenID(e.ctx)
	s.Require().NoError(e.obs.Create(e.ctx, obligation))

	order := s.newOrder(e.ctx, "payment:p1:obligation:"+obligation.GetID())
	s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, order))

	consumed, err := e.orders.ConsumeObligationForOrder(e.ctx, order.GetID(), obligation.GetID(), 30_000)
	s.Require().NoError(err)
	s.Require().True(consumed)

	storedOrder, err := e.orders.GetByID(e.ctx, order.GetID())
	s.Require().NoError(err)
	s.Require().True(storedOrder.ObligationConsumed)
	storedObl, err := e.obs.GetByID(e.ctx, obligation.GetID())
	s.Require().NoError(err)
	s.Require().Equal(int64(20_000), storedObl.Amount)

	// Same order again: the mark refuses and the obligation debit rolls back.
	again, err := e.orders.ConsumeObligationForOrder(e.ctx, order.GetID(), obligation.GetID(), 20_000)
	s.Require().Error(err)
	s.Require().False(again)
	storedObl, err = e.obs.GetByID(e.ctx, obligation.GetID())
	s.Require().NoError(err)
	s.Require().Equal(int64(20_000), storedObl.Amount, "the rolled-back debit must not land")

	// A fresh order for more than remains: nothing consumed, nothing marked.
	other := s.newOrder(e.ctx, "payment:p2:obligation:"+obligation.GetID())
	s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, other))
	consumed, err = e.orders.ConsumeObligationForOrder(e.ctx, other.GetID(), obligation.GetID(), 25_000)
	s.Require().NoError(err)
	s.Require().False(consumed)
	storedOther, err := e.orders.GetByID(e.ctx, other.GetID())
	s.Require().NoError(err)
	s.Require().False(storedOther.ObligationConsumed)
}

// The settle job finds matched payments that were never allocated, and
// allocation orders that were raised but never posted; it leaves group
// obligation orders whose suspense it did not fund, and finished work, alone.
func (s *claimsSuite) TestSettleListingsFindOnlyUnfinishedAllocations() {
	e := s.newEnv()

	payment := func(txn, ownerType, ownerID string) *models.IncomingPayment {
		p := &models.IncomingPayment{
			Amount: 5000, Currency: "KES", TransactionID: txn,
			OwnerType: ownerType, OwnerID: ownerID, State: int32(constants.StateJustCreated),
		}
		p.GenID(e.ctx)
		_, err := e.payments.CreateIfAbsent(e.ctx, p)
		s.Require().NoError(err)
		return p
	}
	waiting := payment("txn-settle-loan", "client_loan", "client-1")
	saver := payment("txn-settle-savings", "client_savings", "client-2")
	payment("txn-settle-unmatched", "", "")
	member := payment("txn-settle-group", "membership", "member-1")
	leased := payment("txn-settle-leased", "client_loan", "client-3")
	_, claimed, err := e.payments.ClaimAllocation(e.ctx, leased.GetID(), time.Now().Add(-time.Hour))
	s.Require().NoError(err)
	s.Require().True(claimed)

	order := func(reference string, state int32) *models.TransferOrder {
		o := s.newOrder(e.ctx, reference)
		o.State = state
		o.ExtraData = data.JSONMap{"source": "payment_allocation"}
		s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, o))
		return o
	}
	raised := order("payment:p1:loan:loan-1", constants.StateJustCreated)
	order("payment:p2:obligation:ob-1", constants.StateJustCreated)
	order("payment:p3:loan:loan-1", constants.StateInactive)
	funding := order("payment:p4:member:member-1", constants.StateJustCreated)
	funded := s.newOrder(e.ctx, "payment:p4:obligation:ob-2")
	funded.ExtraData = data.JSONMap{"source": "payment_allocation", "suspense_funded": true}
	s.Require().NoError(e.orders.CreateIfAbsent(e.ctx, funded))

	later := time.Now().Add(time.Minute)
	payments, err := e.payments.ListAwaitingAllocation(e.ctx, later, time.Now().Add(-time.Minute), 10)
	s.Require().NoError(err)
	var paymentIDs []string
	for _, p := range payments {
		paymentIDs = append(paymentIDs, p.GetID())
	}
	s.ElementsMatch([]string{waiting.GetID(), saver.GetID(), member.GetID()}, paymentIDs,
		"a live allocation lease is left alone")

	orders, err := e.orders.ListUnexecutedAllocations(e.ctx, later, 10)
	s.Require().NoError(err)
	var orderIDs []string
	for _, o := range orders {
		orderIDs = append(orderIDs, o.GetID())
	}
	s.ElementsMatch([]string{raised.GetID(), funding.GetID(), funded.GetID()}, orderIDs,
		"an obligation order whose suspense was never funded here is left alone")

	earlier := time.Now().Add(-time.Hour)
	payments, err = e.payments.ListAwaitingAllocation(e.ctx, earlier, earlier, 10)
	s.Require().NoError(err)
	s.Empty(payments, "work touched since the cut-off is left to the run that raised it")
	orders, err = e.orders.ListUnexecutedAllocations(e.ctx, earlier, 10)
	s.Require().NoError(err)
	s.Empty(orders)
}

// A group member owes one savings and at most one penalty per period: a
// retried raise finds the row already there and writes nothing.
func (s *claimsSuite) TestObligationCreateIfAbsentHoldsOnePerMemberPeriodAndCause() {
	e := s.newEnv()

	obligation := func(member, cause string) *models.Obligation {
		o := &models.Obligation{
			MembershipID: member, CauseType: cause, CauseID: "group-1", PeriodID: "period-1",
			Amount: 1000, Currency: "KES", State: int32(constants.StateActive),
		}
		o.GenID(e.ctx)
		return o
	}

	created, err := e.obs.CreateIfAbsent(e.ctx, obligation("member-1", "periodic_saving"))
	s.Require().NoError(err)
	s.True(created)
	created, err = e.obs.CreateIfAbsent(e.ctx, obligation("member-1", "periodic_saving"))
	s.Require().NoError(err)
	s.False(created, "a retry raises nothing new")

	created, err = e.obs.CreateIfAbsent(e.ctx, obligation("member-1", "penalty"))
	s.Require().NoError(err)
	s.True(created, "the penalty is its own obligation")
	created, err = e.obs.CreateIfAbsent(e.ctx, obligation("member-1", "penalty"))
	s.Require().NoError(err)
	s.False(created, "one penalty per member per period")

	created, err = e.obs.CreateIfAbsent(e.ctx, obligation("member-2", "periodic_saving"))
	s.Require().NoError(err)
	s.True(created)

	// Loan obligations are keyed by their schedule entry, not this index.
	for range 2 {
		created, err = e.obs.CreateIfAbsent(e.ctx, obligation("member-1", "loan_principal"))
		s.Require().NoError(err)
		s.True(created)
	}

	period, err := e.obs.GetByPeriodID(e.ctx, "period-1")
	s.Require().NoError(err)
	s.Len(period, 5)
}
