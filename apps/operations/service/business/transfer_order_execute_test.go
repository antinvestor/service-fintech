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

package business

import (
	"context"
	"errors"
	"sync"
	"testing"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/ledger/connectrpc/go/v1/ledgerv1connect"
	ledgerv1 "buf.build/gen/go/antinvestor/ledger/protocolbuffers/go/v1"
	"buf.build/gen/go/antinvestor/payment/connectrpc/go/v1/paymentv1connect"
	paymentv1 "buf.build/gen/go/antinvestor/payment/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// memOrderRepo mirrors the conditional-update semantics of the Postgres
// repository on a single in-memory row, so execution can be driven through
// every failure branch without a database.
type memOrderRepo struct {
	stubTransferOrderRepo
	mu    sync.Mutex
	order *models.TransferOrder
}

func newMemOrderRepo(order *models.TransferOrder) *memOrderRepo {
	return &memOrderRepo{order: order}
}

func (r *memOrderRepo) GetByID(_ context.Context, id string) (*models.TransferOrder, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.order == nil || r.order.GetID() != id {
		return nil, gorm.ErrRecordNotFound
	}
	cp := *r.order
	return &cp, nil
}

func (r *memOrderRepo) GetByReference(_ context.Context, ref string) (*models.TransferOrder, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.order == nil || r.order.Reference != ref {
		return nil, gorm.ErrRecordNotFound
	}
	cp := *r.order
	return &cp, nil
}

func (r *memOrderRepo) ClaimState(_ context.Context, id string, from []int32, to int32) (bool, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.order.GetID() != id {
		return false, nil
	}
	for _, f := range from {
		if r.order.State == f {
			r.order.State = to
			r.order.ModifiedAt = time.Now().UTC()
			r.order.Version++
			return true, nil
		}
	}
	return false, nil
}

func (r *memOrderRepo) ClaimStaleExecution(_ context.Context, id string, before time.Time) (bool, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.order.GetID() != id || r.order.State != int32(constants.StateCheckCreated) ||
		!r.order.ModifiedAt.Before(before) {
		return false, nil
	}
	r.order.ModifiedAt = time.Now().UTC()
	r.order.Version++
	return true, nil
}

func (r *memOrderRepo) ReleaseExecution(_ context.Context, id, reason string) (bool, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.order.GetID() != id || r.order.State != int32(constants.StateCheckCreated) {
		return false, nil
	}
	r.order.State = int32(constants.StateJustCreated)
	r.order.FailureReason = reason
	r.order.ModifiedAt = time.Now().UTC()
	return true, nil
}

func (r *memOrderRepo) MarkLedgerPosted(_ context.Context, _ string, txnID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.order.LedgerTransactionID = txnID
	return nil
}

func (r *memOrderRepo) ClaimPaymentInitiation(_ context.Context, _ string) (bool, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.order.PaymentInitiatedAt != nil {
		return false, nil
	}
	now := time.Now().UTC()
	r.order.PaymentInitiatedAt = &now
	return true, nil
}

func (r *memOrderRepo) RecordPaymentID(_ context.Context, _ string, paymentID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.order.PaymentID = paymentID
	return nil
}

func (r *memOrderRepo) MarkPayoutFailed(_ context.Context, _ string, paymentID, reason string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.order.PayoutStatus = models.PayoutStatusFailed
	r.order.PaymentID = paymentID
	r.order.FailureReason = reason
	return nil
}

func (r *memOrderRepo) RetakePaymentInitiation(_ context.Context, _ string, observed time.Time) (bool, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.order.PaymentInitiatedAt == nil || r.order.PaymentID != "" || !r.order.PaymentInitiatedAt.Equal(observed) {
		return false, nil
	}
	now := time.Now().UTC()
	r.order.PaymentInitiatedAt = &now
	return true, nil
}

func (r *memOrderRepo) MarkFailedIfUnposted(_ context.Context, _ string) (bool, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.order.LedgerTransactionID != "" || r.order.PaymentInitiatedAt != nil {
		return false, nil
	}
	r.order.State = int32(constants.StateShutdown)
	return true, nil
}

func (r *memOrderRepo) snapshot() models.TransferOrder {
	r.mu.Lock()
	defer r.mu.Unlock()
	return *r.order
}

var _ repository.TransferOrderRepository = (*memOrderRepo)(nil)

// memAccountRefRepo resolves nothing, so every ref is treated as a ledger
// account name; the embedded nil interface panics on any other call, which
// is the point: execution must not need more than GetByID here.
type memAccountRefRepo struct {
	repository.AccountRefRepository
}

func (memAccountRefRepo) GetByID(_ context.Context, _ string) (*models.AccountRef, error) {
	return nil, gorm.ErrRecordNotFound
}

type fakeLedger struct {
	ledgerv1connect.LedgerServiceClient
	mu    sync.Mutex
	calls int
	fail  error
}

func (f *fakeLedger) CreateTransaction(
	_ context.Context,
	req *connect.Request[ledgerv1.CreateTransactionRequest],
) (*connect.Response[ledgerv1.CreateTransactionResponse], error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.calls++
	if f.fail != nil {
		return nil, f.fail
	}
	txn := (&ledgerv1.Transaction_builder{Id: "ledger-" + req.Msg.GetId()}).Build()
	return connect.NewResponse((&ledgerv1.CreateTransactionResponse_builder{Data: txn}).Build()), nil
}

type fakePayment struct {
	paymentv1connect.PaymentServiceClient
	mu     sync.Mutex
	sends  int
	fail   error
	reject bool
}

func (f *fakePayment) Send(
	_ context.Context,
	_ *connect.Request[paymentv1.SendRequest],
) (*connect.Response[paymentv1.SendResponse], error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.sends++
	if f.fail != nil {
		return nil, f.fail
	}
	st := commonv1.STATUS_QUEUED
	if f.reject {
		st = commonv1.STATUS_FAILED
	}
	status := (&commonv1.StatusResponse_builder{Id: "pay-1", Status: st}).Build()
	return connect.NewResponse((&paymentv1.SendResponse_builder{Data: status}).Build()), nil
}

// fakeLocator stands in for the payment-service search by reference.
type fakeLocator struct {
	found *paymentv1.Payment
	err   error
	calls int
}

func (f *fakeLocator) FindByReference(_ context.Context, _ string) (*paymentv1.Payment, error) {
	f.calls++
	return f.found, f.err
}

type executeFixture struct {
	repo    *memOrderRepo
	ledger  *fakeLedger
	payment *fakePayment
	locator *fakeLocator
	biz     *transferOrderBusiness
}

func newExecuteFixture(t *testing.T, state int32) *executeFixture {
	t.Helper()
	order := &models.TransferOrder{
		DebitAccountRef:  "product:p1:unallocated",
		CreditAccountRef: "member:m1:wallet",
		Amount:           250_000,
		Currency:         "KES",
		OrderType:        constants.SafeInt32FromInt(constants.TransferTypeLoan),
		Reference:        "disbursement:key-1",
		State:            state,
		ExtraData:        data.JSONMap{"member_id": "profile-m1", "loan_id": "loan-1"},
	}
	order.GenID(context.Background())
	order.TenantID = "tenant-1"
	order.PartitionID = "partition-1"
	order.ModifiedAt = time.Now().UTC()

	repo := newMemOrderRepo(order)
	ledger := &fakeLedger{}
	payment := &fakePayment{}
	locator := &fakeLocator{}
	biz := &transferOrderBusiness{
		eventsMan: &noopTransferEventsManager{},
		toRepo:    repo,
		arRepo:    memAccountRefRepo{},
		clients:   &clients.PlatformClients{LedgerClient: ledger, PaymentClient: payment},
		locator:   locator,
	}
	return &executeFixture{repo: repo, ledger: ledger, payment: payment, locator: locator, biz: biz}
}

func TestExecute_LedgerFailureReleasesOrderAndRetryConverges(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	f.ledger.fail = errors.New("ledger unavailable")

	err := f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.Error(t, err, "a failed ledger posting must surface to the caller")

	got := f.repo.snapshot()
	assert.Equal(t, int32(constants.StateJustCreated), got.State, "failed attempt must release the claim")
	assert.Contains(t, got.FailureReason, "ledger unavailable")
	assert.Empty(t, got.LedgerTransactionID)
	assert.Equal(t, 0, f.payment.sends, "no payout may leave before the ledger posts")

	f.ledger.fail = nil
	require.NoError(t, f.biz.Execute(context.Background(), f.repo.order.GetID()))

	got = f.repo.snapshot()
	assert.Equal(t, int32(constants.StateInactive), got.State)
	assert.Equal(t, "ledger-"+got.GetID(), got.LedgerTransactionID)
	assert.Equal(t, "pay-1", got.PaymentID)
	assert.Equal(t, 2, f.ledger.calls)
	assert.Equal(t, 1, f.payment.sends)
}

func TestExecute_PayoutFailureKeepsLedgerAndIsConfirmedNotResent(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	f.payment.fail = errors.New("rail timeout")

	err := f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.Error(t, err)

	got := f.repo.snapshot()
	assert.Equal(t, int32(constants.StateJustCreated), got.State)
	assert.NotEmpty(t, got.LedgerTransactionID, "ledger id is kept so the retry does not post twice")
	require.NotNil(t, got.PaymentInitiatedAt, "the payout claim must survive an ambiguous rail error")

	// Retry while the payment service shows nothing yet: not settled, not resent.
	f.payment.fail = nil
	err = f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.ErrorIs(t, err, ErrPayoutPendingConfirmation)
	assert.Equal(t, 1, f.payment.sends, "an unconfirmed payout must not be sent a second time")
	assert.Equal(t, int32(constants.StateJustCreated), f.repo.snapshot().State, "order stays unsettled")

	// The payment service now shows the payout: it is recorded and the order completes.
	f.locator.found = (&paymentv1.Payment_builder{Id: "pay-found", ReferenceId: f.repo.order.Reference}).Build()
	require.NoError(t, f.biz.Execute(context.Background(), f.repo.order.GetID()))
	got = f.repo.snapshot()
	assert.Equal(t, int32(constants.StateInactive), got.State)
	assert.Equal(t, "pay-found", got.PaymentID)
	assert.Equal(t, 1, f.ledger.calls)
	assert.Equal(t, 1, f.payment.sends)
}

// A payout claim the payment service has never seen, once older than the
// confirmation grace, is treated as a Send that never landed: it is cleared
// and the payout sent exactly once.
func TestExecute_StalePayoutClaimWithNoPaymentIsResent(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	f.repo.order.LedgerTransactionID = "ledger-earlier"
	stale := time.Now().Add(-payoutConfirmationGrace - time.Minute)
	f.repo.order.PaymentInitiatedAt = &stale

	require.NoError(t, f.biz.Execute(context.Background(), f.repo.order.GetID()))
	got := f.repo.snapshot()
	assert.Equal(t, int32(constants.StateInactive), got.State)
	assert.Equal(t, 1, f.payment.sends)
	assert.Equal(t, "pay-1", got.PaymentID)
	assert.Equal(t, 1, f.locator.calls)
}

// RecordFailure must not declare an order failed once money has moved.
func TestRecordFailure_RefusesProgressedOrder(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	f.repo.order.LedgerTransactionID = "ledger-posted"

	_, err := f.biz.RecordFailure(context.Background(), f.repo.order.Reference, "engine gave up")
	require.ErrorIs(t, err, ErrTransferOrderProgressed)
	assert.NotEqual(t, int32(constants.StateShutdown), f.repo.snapshot().State)

	fresh := newExecuteFixture(t, int32(constants.StateJustCreated))
	out, err := fresh.biz.RecordFailure(context.Background(), fresh.repo.order.Reference, "engine gave up")
	require.NoError(t, err)
	assert.Equal(t, true, out["newly_failed"])
	assert.Equal(t, int32(constants.StateShutdown), fresh.repo.snapshot().State)
}

func TestExecute_FreshInProgressClaimIsRejectedNotSucceeded(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateCheckCreated))

	err := f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.ErrorIs(t, err, ErrTransferOrderInProgress)
	assert.Equal(t, 0, f.ledger.calls)
	assert.Equal(t, 0, f.payment.sends)
	assert.Equal(t, int32(constants.StateCheckCreated), f.repo.snapshot().State)
}

func TestExecute_StaleClaimIsResumedToCompletion(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateCheckCreated))
	f.repo.order.ModifiedAt = time.Now().Add(-staleExecutionAfter - time.Minute)
	f.repo.order.LedgerTransactionID = "ledger-earlier"

	require.NoError(t, f.biz.Execute(context.Background(), f.repo.order.GetID()))

	got := f.repo.snapshot()
	assert.Equal(t, int32(constants.StateInactive), got.State)
	assert.Equal(t, "ledger-earlier", got.LedgerTransactionID)
	assert.Equal(t, 0, f.ledger.calls, "a resumed order with a ledger id must not re-post")
	assert.Equal(t, 1, f.payment.sends)
}

func TestExecute_FailedOrderIsNotExecuted(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateShutdown))

	err := f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.ErrorIs(t, err, ErrTransferOrderFailed)
	assert.Equal(t, 0, f.ledger.calls)
}

func TestExecute_PayoutOrderWithoutPaymentClientFails(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	f.biz.clients.PaymentClient = nil

	err := f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.ErrorIs(t, err, errPaymentClientUnavailable)
	got := f.repo.snapshot()
	assert.Equal(t, int32(constants.StateJustCreated), got.State, "order stays executable once a rail is configured")
	assert.NotEmpty(t, got.LedgerTransactionID)
}

// A payout the rail reports as failed is neither settled nor resent, and a
// later retry that can no longer see the payment still refuses to complete.
func TestExecute_FailedPayoutAtRailIsNotSettledNorResent(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	f.repo.order.LedgerTransactionID = "ledger-earlier"
	stale := time.Now().Add(-time.Minute)
	f.repo.order.PaymentInitiatedAt = &stale
	f.locator.found = (&paymentv1.Payment_builder{
		Id: "pay-failed", ReferenceId: f.repo.order.Reference, Status: commonv1.STATUS_FAILED,
	}).Build()

	err := f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.ErrorIs(t, err, ErrPayoutFailed)
	got := f.repo.snapshot()
	assert.Equal(t, int32(constants.StateJustCreated), got.State)
	assert.Equal(t, "pay-failed", got.PaymentID)
	assert.True(t, got.PayoutFailed())
	assert.Equal(t, 0, f.payment.sends)

	// The marker outlives the lookup: even with the payment gone from the
	// service's answer, the order does not complete and nothing is resent.
	f.locator.found = nil
	err = f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.ErrorIs(t, err, ErrPayoutFailed)
	assert.NotEqual(t, int32(constants.StateInactive), f.repo.snapshot().State)
	assert.Equal(t, 0, f.payment.sends)
}

// A recorded payment id is re-checked, not trusted: if the service now says
// the payout failed, the order does not complete.
func TestExecute_RecordedPaymentIDIsRecheckedBeforeCompleting(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	f.repo.order.LedgerTransactionID = "ledger-earlier"
	stale := time.Now().Add(-time.Minute)
	f.repo.order.PaymentInitiatedAt = &stale
	f.repo.order.PaymentID = "pay-1"
	f.locator.found = (&paymentv1.Payment_builder{
		Id: "pay-1", ReferenceId: f.repo.order.Reference, Status: commonv1.STATUS_FAILED,
	}).Build()

	err := f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.ErrorIs(t, err, ErrPayoutFailed)
	assert.NotEqual(t, int32(constants.StateInactive), f.repo.snapshot().State)

	// With the service confirming success the order completes without a resend.
	g := newExecuteFixture(t, int32(constants.StateJustCreated))
	g.repo.order.LedgerTransactionID = "ledger-earlier"
	g.repo.order.PaymentInitiatedAt = &stale
	g.repo.order.PaymentID = "pay-1"
	g.locator.found = (&paymentv1.Payment_builder{
		Id: "pay-1", ReferenceId: g.repo.order.Reference, Status: commonv1.STATUS_SUCCESSFUL,
	}).Build()
	require.NoError(t, g.biz.Execute(context.Background(), g.repo.order.GetID()))
	assert.Equal(t, int32(constants.StateInactive), g.repo.snapshot().State)
	assert.Equal(t, 0, g.payment.sends)
}

// An inconclusive lookup never licenses a resend.
func TestExecute_InconclusivePayoutLookupKeepsWaiting(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	f.repo.order.LedgerTransactionID = "ledger-earlier"
	stale := time.Now().Add(-payoutConfirmationGrace - time.Minute)
	f.repo.order.PaymentInitiatedAt = &stale
	f.locator.err = ErrPayoutLookupInconclusive

	err := f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.ErrorIs(t, err, ErrPayoutPendingConfirmation)
	assert.Equal(t, 0, f.payment.sends)
}

// A payout the rail rejects in the Send response is recorded as failed at
// once and the order never completes nor resends.
func TestExecute_SynchronousRailRejectionMarksPayoutFailed(t *testing.T) {
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	f.payment.reject = true

	err := f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.ErrorIs(t, err, ErrPayoutFailed)
	got := f.repo.snapshot()
	assert.True(t, got.PayoutFailed())
	assert.NotEqual(t, int32(constants.StateInactive), got.State)

	err = f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.ErrorIs(t, err, ErrPayoutFailed)
	assert.Equal(t, 1, f.payment.sends)
}
