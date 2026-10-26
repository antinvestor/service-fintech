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
	"slices"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore/pool"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/frame/v3/queue"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/operations/service/events"
	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

var errUnexpectedStubCall = errors.New("unexpected stub call")

func TestIdentifyPaymentPersistsIncomingPayment(t *testing.T) {
	t.Parallel()

	paymentRepo := newIncomingPaymentRepoStub()
	business := &paymentRoutingBusiness{
		eventsMan: &paymentEventsManagerStub{paymentRepo: paymentRepo},
		ipRepo:    paymentRepo,
		obRepo:    &obligationRepoStub{},
	}

	result, err := business.IdentifyPayment(context.Background(), map[string]interface{}{
		"transaction_id":  "txn-1",
		"amount":          int64(250_000),
		"currency":        "UGX",
		"payer_reference": "256700000000",
		"payer_name":      "Jane Doe",
		"product_id":      "prod-1",
		"group_id":        "group-1",
		"properties": data.JSONMap{
			"channel": "mobile_money",
		},
	})
	if err != nil {
		t.Fatalf("IdentifyPayment returned error: %v", err)
	}

	paymentID, _ := result["payment_id"].(string)
	if paymentID == "" {
		t.Fatal("expected persisted payment_id in identification result")
	}
	if got := result["strategy"]; got != "unidentified" {
		t.Fatalf("expected unidentified strategy without identity client, got %v", got)
	}

	payment, err := paymentRepo.GetByID(context.Background(), paymentID)
	if err != nil {
		t.Fatalf("GetByID returned error: %v", err)
	}
	if payment.TransactionID != "txn-1" {
		t.Fatalf("expected transaction_id txn-1, got %q", payment.TransactionID)
	}
	if payment.Amount != 250_000 {
		t.Fatalf("expected amount 250000, got %d", payment.Amount)
	}
	if payment.Currency != "UGX" {
		t.Fatalf("expected currency UGX, got %q", payment.Currency)
	}
	if payment.Properties.GetString("channel") != "mobile_money" {
		t.Fatalf("expected channel property to persist, got %#v", payment.Properties)
	}
}

func TestIdentifyPaymentIsIdempotentByTransactionID(t *testing.T) {
	t.Parallel()

	paymentRepo := newIncomingPaymentRepoStub()
	business := &paymentRoutingBusiness{
		eventsMan: &paymentEventsManagerStub{paymentRepo: paymentRepo},
		ipRepo:    paymentRepo,
		obRepo:    &obligationRepoStub{},
	}

	first, err := business.IdentifyPayment(context.Background(), map[string]interface{}{
		"transaction_id": "txn-repeat",
		"amount":         int64(10_000),
		"currency":       "UGX",
		"product_id":     "prod-1",
	})
	if err != nil {
		t.Fatalf("first IdentifyPayment returned error: %v", err)
	}

	second, err := business.IdentifyPayment(context.Background(), map[string]interface{}{
		"transaction_id": "txn-repeat",
		"amount":         int64(10_000),
		"currency":       "UGX",
		"product_id":     "prod-1",
	})
	if err != nil {
		t.Fatalf("second IdentifyPayment returned error: %v", err)
	}

	if first["payment_id"] != second["payment_id"] {
		t.Fatalf(
			"expected same payment_id on repeated notify, got %v and %v",
			first["payment_id"],
			second["payment_id"],
		)
	}
	if len(paymentRepo.byID) != 1 {
		t.Fatalf("expected a single persisted payment record, got %d", len(paymentRepo.byID))
	}
}

func TestAllocatePaymentUsesPersistedPayment(t *testing.T) {
	t.Parallel()

	paymentRepo := newIncomingPaymentRepoStub()
	payment := &models.IncomingPayment{
		TransactionID: "txn-alloc",
		Amount:        75_000,
		Currency:      "UGX",
		OwnerID:       "member-1",
		OwnerType:     "membership",
		State:         int32(constants.StateJustCreated),
		Properties: data.JSONMap{
			"identification_strategy": "persisted",
			"product_id":              "prod-1",
		},
	}
	payment.GenID(context.Background())
	paymentRepo.store(payment)

	orders := &allocOrderRepoStub{}
	business := &paymentRoutingBusiness{
		eventsMan: &paymentEventsManagerStub{paymentRepo: paymentRepo},
		ipRepo:    paymentRepo,
		obRepo:    &obligationRepoStub{},
		toRepo:    orders,
	}

	result, err := business.AllocatePayment(context.Background(), payment.GetID())
	if err != nil {
		t.Fatalf("AllocatePayment returned error: %v", err)
	}
	if got := result["payment_id"]; got != payment.GetID() {
		t.Fatalf("expected payment_id %s, got %v", payment.GetID(), got)
	}
	if got := result["membership_id"]; got != "member-1" {
		t.Fatalf("expected membership_id member-1, got %v", got)
	}

	stored, err := paymentRepo.GetByID(context.Background(), payment.GetID())
	if err != nil {
		t.Fatalf("GetByID returned error: %v", err)
	}
	if stored.State != int32(constants.StateCheckCreated) {
		t.Fatalf("expected payment state %d, got %d", int32(constants.StateCheckCreated), stored.State)
	}

	// With nothing owed, the whole payment still moves into the member's
	// suspense, out of the account the rail credited.
	funding := orders.byReference["payment:"+payment.GetID()+":member:member-1"]
	if funding == nil {
		t.Fatal("expected the member suspense order to be raised")
	}
	if funding.DebitAccountRef != constants.ProductExternalCashAccount("prod-1") ||
		funding.CreditAccountRef != constants.MemberSuspenseAccount("member-1") || funding.Amount != 75_000 {
		t.Fatalf("unexpected member suspense order %+v", funding)
	}
}

// A member's payment that does not name the product the rail credited has
// no account to move out of, so it is not allocated.
func TestAllocatePayment_MemberPaymentWithoutProductIsRefused(t *testing.T) {
	t.Parallel()

	paymentRepo := newIncomingPaymentRepoStub()
	payment := &models.IncomingPayment{
		TransactionID: "txn-noproduct", Amount: 10_000, Currency: "UGX",
		OwnerID: "member-1", OwnerType: "membership", State: int32(constants.StateJustCreated),
	}
	payment.GenID(context.Background())
	paymentRepo.store(payment)
	business := &paymentRoutingBusiness{
		eventsMan: &paymentEventsManagerStub{paymentRepo: paymentRepo},
		ipRepo:    paymentRepo,
		obRepo:    &obligationRepoStub{},
		toRepo:    &allocOrderRepoStub{},
	}

	_, err := business.AllocatePayment(context.Background(), payment.GetID())
	require.ErrorIs(t, err, ErrMemberPaymentNoProduct)
	stored, _ := paymentRepo.GetByID(context.Background(), payment.GetID())
	assert.Nil(t, stored.AllocatingAt, "the lease is released for a later run")
	assert.Equal(t, int32(constants.StateJustCreated), stored.State)
}

// emittedEvent is one recorded Emit call, so a test can assert what a business
// method published rather than only what it returned.
type emittedEvent struct {
	name    string
	payload any
}

type paymentEventsManagerStub struct {
	paymentRepo *incomingPaymentRepoStub
	emitted     []emittedEvent
}

func (e *paymentEventsManagerStub) Add(fevents.EventI) {}

func (e *paymentEventsManagerStub) Get(string) (fevents.EventI, error) {
	return nil, errUnexpectedStubCall
}

func (e *paymentEventsManagerStub) Emit(_ context.Context, name string, payload any) error {
	e.emitted = append(e.emitted, emittedEvent{name: name, payload: payload})

	switch name {
	case events.IncomingPaymentSaveEvent:
		payment, ok := payload.(*models.IncomingPayment)
		if !ok {
			return errUnexpectedStubCall
		}
		e.paymentRepo.store(payment)
		return nil
	default:
		return nil
	}
}

func (e *paymentEventsManagerStub) Handler() queue.SubscribeWorker { return nil }

// Strict / SetStrict satisfy events.Manager (frame >=v1.98.2); the stub
// never consumes from a queue, so strict mode is irrelevant here.
func (e *paymentEventsManagerStub) Strict() bool   { return true }
func (e *paymentEventsManagerStub) SetStrict(bool) {}

type incomingPaymentRepoStub struct {
	baseRepositoryStub[*models.IncomingPayment]
	byID            map[string]*models.IncomingPayment
	byTransactionID map[string]*models.IncomingPayment
}

func newIncomingPaymentRepoStub() *incomingPaymentRepoStub {
	return &incomingPaymentRepoStub{
		byID:            map[string]*models.IncomingPayment{},
		byTransactionID: map[string]*models.IncomingPayment{},
	}
}

func (r *incomingPaymentRepoStub) GetByID(_ context.Context, id string) (*models.IncomingPayment, error) {
	payment, ok := r.byID[id]
	if !ok {
		return nil, gorm.ErrRecordNotFound
	}

	return cloneIncomingPayment(payment), nil
}

func (r *incomingPaymentRepoStub) GetByTransactionID(
	_ context.Context,
	transactionID string,
) (*models.IncomingPayment, error) {
	payment, ok := r.byTransactionID[transactionID]
	if !ok {
		return nil, gorm.ErrRecordNotFound
	}

	return cloneIncomingPayment(payment), nil
}

func (r *incomingPaymentRepoStub) CreateIfAbsent(
	_ context.Context,
	payment *models.IncomingPayment,
) (*models.IncomingPayment, error) {
	if existing, ok := r.byTransactionID[payment.TransactionID]; ok {
		return cloneIncomingPayment(existing), nil
	}
	r.store(payment)

	return cloneIncomingPayment(payment), nil
}

func (r *incomingPaymentRepoStub) ClaimState(
	_ context.Context,
	paymentID string,
	fromStates []int32,
	toState int32,
) (bool, error) {
	payment, ok := r.byID[paymentID]
	if !ok {
		return false, nil
	}
	if !slices.Contains(fromStates, payment.State) {
		return false, nil
	}
	payment.State = toState

	return true, nil
}

func (r *incomingPaymentRepoStub) ClaimAllocation(
	_ context.Context,
	paymentID string,
	staleBefore time.Time,
) (*models.IncomingPayment, bool, error) {
	payment, ok := r.byID[paymentID]
	if !ok {
		return nil, false, nil
	}
	if payment.AllocatingAt != nil && payment.AllocatingAt.After(staleBefore) {
		return nil, false, nil
	}
	now := time.Now()
	payment.AllocatingAt = &now
	return cloneIncomingPayment(payment), true, nil
}

func (r *incomingPaymentRepoStub) ReleaseAllocation(_ context.Context, paymentID string, lease time.Time) error {
	if payment, ok := r.byID[paymentID]; ok && payment.AllocatingAt != nil && payment.AllocatingAt.Equal(lease) {
		payment.AllocatingAt = nil
	}
	return nil
}

func (r *incomingPaymentRepoStub) SetAllocationOutcome(
	_ context.Context,
	paymentID string,
	lease time.Time,
	state int32,
	remaining int64,
) (bool, error) {
	payment, ok := r.byID[paymentID]
	if !ok {
		return false, gorm.ErrRecordNotFound
	}
	if payment.AllocatingAt == nil || !payment.AllocatingAt.Equal(lease) {
		return false, nil
	}
	payment.State = state
	payment.AllocatingAt = nil
	if payment.Properties == nil {
		payment.Properties = data.JSONMap{}
	}
	payment.Properties["remaining_amount"] = remaining

	return true, nil
}

func (r *incomingPaymentRepoStub) GetWithSuspenseByOwnerID(
	_ context.Context,
	ownerID string,
) ([]*models.IncomingPayment, error) {
	var found []*models.IncomingPayment
	for _, payment := range r.byID {
		if payment.OwnerID == ownerID && paymentRemainder(payment) > 0 {
			found = append(found, payment)
		}
	}
	return found, nil
}

func (r *incomingPaymentRepoStub) GetUnallocatedByOwnerID(
	_ context.Context,
	ownerType, ownerID string,
) ([]*models.IncomingPayment, error) {
	var found []*models.IncomingPayment
	for _, payment := range r.byID {
		if payment.OwnerType == ownerType && payment.OwnerID == ownerID &&
			payment.State == int32(constants.StateJustCreated) {
			found = append(found, cloneIncomingPayment(payment))
		}
	}
	return found, nil
}

func (r *incomingPaymentRepoStub) MarkConfirmed(
	_ context.Context,
	paymentID string,
	at time.Time,
) (bool, error) {
	payment, ok := r.byID[paymentID]
	if !ok {
		return false, gorm.ErrRecordNotFound
	}
	if payment.Properties == nil {
		payment.Properties = data.JSONMap{}
	}
	if _, already := payment.Properties["confirmed_at"]; already {
		return false, nil
	}
	payment.Properties["confirmed_at"] = at.Format(time.RFC3339)

	return true, nil
}

func (r *incomingPaymentRepoStub) AssignOwner(
	_ context.Context,
	paymentID string,
	assignment repository.PaymentAssignment,
) (bool, error) {
	payment, ok := r.byID[paymentID]
	if !ok || payment.OwnerID != "" || payment.AllocatingAt != nil ||
		payment.State != int32(constants.StateJustCreated) {
		return false, nil
	}
	payment.OwnerID = assignment.OwnerID
	payment.OwnerType = assignment.OwnerType
	payment.PayableID = assignment.PayableID
	payment.PayableType = assignment.PayableType
	payment.Properties = mergeJSONMaps(payment.Properties, assignment.Properties)
	return true, nil
}

func (r *incomingPaymentRepoStub) store(payment *models.IncomingPayment) {
	clone := cloneIncomingPayment(payment)
	r.byID[clone.GetID()] = clone
	r.byTransactionID[clone.TransactionID] = clone
}

type obligationRepoStub struct {
	baseRepositoryStub[*models.Obligation]
}

func (r *obligationRepoStub) GetByMembershipID(context.Context, string) ([]*models.Obligation, error) {
	return []*models.Obligation{}, nil
}

func (r *obligationRepoStub) GetByPeriodID(context.Context, string) ([]*models.Obligation, error) {
	return nil, errUnexpectedStubCall
}

func (r *obligationRepoStub) GetByCauseID(context.Context, string) ([]*models.Obligation, error) {
	return nil, errUnexpectedStubCall
}

func (r *obligationRepoStub) CreateIfAbsent(context.Context, *models.Obligation) (bool, error) {
	return false, errUnexpectedStubCall
}

func (r *obligationRepoStub) ConsumeAmount(context.Context, string, int64) (bool, error) {
	return false, errUnexpectedStubCall
}

type baseRepositoryStub[T any] struct{}

func (b *baseRepositoryStub[T]) Pool() pool.Pool { return nil }

func (b *baseRepositoryStub[T]) WorkManager() workerpool.Manager { return nil }

func (b *baseRepositoryStub[T]) GetByID(context.Context, string) (T, error) {
	var zero T
	return zero, errUnexpectedStubCall
}

func (b *baseRepositoryStub[T]) GetLastestBy(context.Context, map[string]any) (T, error) {
	var zero T
	return zero, errUnexpectedStubCall
}

func (b *baseRepositoryStub[T]) GetAllBy(context.Context, map[string]any, int, int) ([]T, error) {
	return nil, errUnexpectedStubCall
}

func (b *baseRepositoryStub[T]) Search(context.Context, *data.SearchQuery) (workerpool.JobResultPipe[[]T], error) {
	return nil, errUnexpectedStubCall
}

func (b *baseRepositoryStub[T]) Count(context.Context) (int64, error) {
	return 0, errUnexpectedStubCall
}

func (b *baseRepositoryStub[T]) CountBy(context.Context, map[string]any) (int64, error) {
	return 0, errUnexpectedStubCall
}

func (b *baseRepositoryStub[T]) Create(context.Context, T) error { return errUnexpectedStubCall }

func (b *baseRepositoryStub[T]) BatchSize() int { return 0 }

func (b *baseRepositoryStub[T]) BulkCreate(context.Context, []T) error { return errUnexpectedStubCall }

func (b *baseRepositoryStub[T]) FieldsImmutable() []string { return nil }

func (b *baseRepositoryStub[T]) FieldsAllowed() map[string]struct{} { return nil }

func (b *baseRepositoryStub[T]) ExtendFieldsAllowed(...string) {}

func (b *baseRepositoryStub[T]) IsFieldAllowed(string) error { return errUnexpectedStubCall }

func (b *baseRepositoryStub[T]) Update(context.Context, T, ...string) (int64, error) {
	return 0, errUnexpectedStubCall
}

func (b *baseRepositoryStub[T]) BulkUpdate(context.Context, []string, map[string]any) (int64, error) {
	return 0, errUnexpectedStubCall
}

func (b *baseRepositoryStub[T]) Delete(context.Context, string) error { return errUnexpectedStubCall }

func (b *baseRepositoryStub[T]) DeleteBatch(context.Context, []string) error {
	return errUnexpectedStubCall
}

func cloneIncomingPayment(payment *models.IncomingPayment) *models.IncomingPayment {
	clone := *payment
	if payment.Properties != nil {
		clone.Properties = payment.Properties.Copy()
	}

	return &clone
}

// allocObligationRepoStub serves configured obligations and records consumption.
type allocObligationRepoStub struct {
	obligationRepoStub
	obligations []*models.Obligation
	consumed    map[string]int64
}

func (r *allocObligationRepoStub) GetByMembershipID(context.Context, string) ([]*models.Obligation, error) {
	return r.obligations, nil
}

func (r *allocObligationRepoStub) ConsumeAmount(_ context.Context, id string, amount int64) (bool, error) {
	if r.consumed == nil {
		r.consumed = map[string]int64{}
	}
	for _, o := range r.obligations {
		if o.GetID() == id && o.Amount >= amount && o.State == int32(constants.StateActive) {
			r.consumed[id] += amount
			return true, nil
		}
	}
	return false, nil
}

// allocOrderRepoStub records synchronously written orders by reference.
type allocOrderRepoStub struct {
	stubTransferOrderRepo
	byReference map[string]*models.TransferOrder
	parked      []string
	obligations *allocObligationRepoStub
}

func (r *allocOrderRepoStub) ConsumeObligationForOrder(
	ctx context.Context,
	orderID, obligationID string,
	amount int64,
) (bool, error) {
	if r.obligations == nil {
		return false, nil
	}
	consumed, err := r.obligations.ConsumeAmount(ctx, obligationID, amount)
	if err != nil || !consumed {
		return consumed, err
	}
	for _, o := range r.byReference {
		if o.GetID() == orderID {
			o.ObligationConsumed = true
		}
	}
	return true, nil
}

func (r *allocOrderRepoStub) CreateIfAbsent(_ context.Context, order *models.TransferOrder) error {
	if r.byReference == nil {
		r.byReference = map[string]*models.TransferOrder{}
	}
	if existing, ok := r.byReference[order.Reference]; ok {
		order.ID = existing.ID
		order.State = existing.State
		order.Amount = existing.Amount
		order.ObligationConsumed = existing.ObligationConsumed
		return nil
	}
	cp := *order
	r.byReference[order.Reference] = &cp
	return nil
}

func (r *allocOrderRepoStub) GetByReference(_ context.Context, ref string) (*models.TransferOrder, error) {
	if o, ok := r.byReference[ref]; ok {
		return o, nil
	}
	return nil, gorm.ErrRecordNotFound
}

func (r *allocOrderRepoStub) MarkFailedIfUnposted(_ context.Context, id string) (bool, error) {
	r.parked = append(r.parked, id)
	return true, nil
}

// newSavingsObligation is a current (not overdue) loan principal obligation,
// which the allocation buckets match without any ledger account lookup.
func newSavingsObligation(id string, amount int64) *models.Obligation {
	o := &models.Obligation{
		MembershipID: "member-1",
		CauseType:    "loan_principal",
		Amount:       amount,
		State:        int32(constants.StateActive),
	}
	o.ID = id
	return o
}

func TestAllocatePayment_ReplayNeverReallocatesAndLeaseIsExclusive(t *testing.T) {
	t.Parallel()

	paymentRepo := newIncomingPaymentRepoStub()
	payment := &models.IncomingPayment{
		TransactionID: "txn-replay", Amount: 75_000, Currency: "UGX",
		OwnerID: "member-1", OwnerType: "membership", State: int32(constants.StateJustCreated),
		Properties: data.JSONMap{"product_id": "prod-1"},
	}
	payment.GenID(context.Background())
	paymentRepo.store(payment)

	obligations := &allocObligationRepoStub{obligations: []*models.Obligation{
		newSavingsObligation("ob-1", 50_000),
		newSavingsObligation("ob-2", 50_000),
	}}
	orders := &allocOrderRepoStub{obligations: obligations}
	business := &paymentRoutingBusiness{
		eventsMan: &paymentEventsManagerStub{paymentRepo: paymentRepo},
		ipRepo:    paymentRepo,
		obRepo:    obligations,
		toRepo:    orders,
	}

	first, err := business.AllocatePayment(context.Background(), payment.GetID())
	require.NoError(t, err)
	require.Len(t, first["transfer_orders"], 2)
	assert.Equal(t, int64(50_000), obligations.consumed["ob-1"])
	assert.Equal(t, int64(25_000), obligations.consumed["ob-2"])
	stored, _ := paymentRepo.GetByID(context.Background(), payment.GetID())
	assert.Equal(t, int32(constants.StateInactive), stored.State, "fully allocated")
	assert.Nil(t, stored.AllocatingAt, "lease released with the outcome")
	assert.Len(t, orders.byReference, 3, "the suspense order and both obligation orders are written synchronously")

	// Replay: nothing left to allocate, nothing consumed again.
	second, err := business.AllocatePayment(context.Background(), payment.GetID())
	require.NoError(t, err)
	assert.Equal(t, "already_processed", second["status"])
	assert.Equal(t, int64(50_000), obligations.consumed["ob-1"])
	assert.Equal(t, int64(25_000), obligations.consumed["ob-2"])

	// A payment another run holds is refused, not allocated twice.
	held := &models.IncomingPayment{
		TransactionID: "txn-held", Amount: 10_000, Currency: "UGX",
		OwnerID: "member-1", OwnerType: "membership", State: int32(constants.StateJustCreated),
	}
	held.GenID(context.Background())
	now := time.Now()
	held.AllocatingAt = &now
	paymentRepo.store(held)
	_, err = business.AllocatePayment(context.Background(), held.GetID())
	require.ErrorIs(t, err, ErrAllocationInProgress)
}

func TestAllocatePayment_StartsFromThePersistedRemainder(t *testing.T) {
	t.Parallel()

	paymentRepo := newIncomingPaymentRepoStub()
	payment := &models.IncomingPayment{
		TransactionID: "txn-remainder", Amount: 75_000, Currency: "UGX",
		OwnerID: "member-1", OwnerType: "membership", State: int32(constants.StateActive),
		Properties: data.JSONMap{"remaining_amount": float64(20_000), "product_id": "prod-1"},
	}
	payment.GenID(context.Background())
	paymentRepo.store(payment)

	obligations := &allocObligationRepoStub{obligations: []*models.Obligation{newSavingsObligation("ob-9", 50_000)}}
	orders := &allocOrderRepoStub{obligations: obligations}
	business := &paymentRoutingBusiness{
		eventsMan: &paymentEventsManagerStub{paymentRepo: paymentRepo},
		ipRepo:    paymentRepo,
		obRepo:    obligations,
		toRepo:    orders,
	}

	_, err := business.AllocatePayment(context.Background(), payment.GetID())
	require.NoError(t, err)
	assert.Equal(
		t,
		int64(20_000),
		obligations.consumed["ob-9"],
		"only the remainder may be allocated, never the full amount again",
	)
	stored, _ := paymentRepo.GetByID(context.Background(), payment.GetID())
	assert.Equal(t, int32(constants.StateInactive), stored.State)
	assert.EqualValues(t, int64(0), stored.Properties["remaining_amount"])
}

// An order that already exists for the (payment, obligation) pair and is
// marked consumed means an earlier run allocated it; this run counts it and
// must not consume the obligation again. One not marked consumed is finished.
func TestAllocatePayment_ExistingOrderIsNotCountedTwice(t *testing.T) {
	t.Parallel()

	paymentRepo := newIncomingPaymentRepoStub()
	payment := &models.IncomingPayment{
		TransactionID: "txn-existing", Amount: 30_000, Currency: "UGX",
		OwnerID: "member-1", OwnerType: "membership", State: int32(constants.StateJustCreated),
		Properties: data.JSONMap{"product_id": "prod-1"},
	}
	payment.GenID(context.Background())
	paymentRepo.store(payment)

	obligations := &allocObligationRepoStub{obligations: []*models.Obligation{newSavingsObligation("ob-5", 30_000)}}
	prior := &models.TransferOrder{Reference: "payment:" + payment.GetID() + ":obligation:ob-5",
		Amount: 30_000, Currency: "UGX", ObligationConsumed: true}
	prior.GenID(context.Background())
	orders := &allocOrderRepoStub{
		byReference: map[string]*models.TransferOrder{prior.Reference: prior},
		obligations: obligations,
	}
	business := &paymentRoutingBusiness{
		eventsMan: &paymentEventsManagerStub{paymentRepo: paymentRepo},
		ipRepo:    paymentRepo,
		obRepo:    obligations,
		toRepo:    orders,
	}

	result, err := business.AllocatePayment(context.Background(), payment.GetID())
	require.NoError(t, err)
	assert.Empty(t, obligations.consumed, "a consumed pair is not consumed again")
	assert.Empty(t, orders.parked)
	assert.EqualValues(t, 30_000, result["allocated_amount"], "the earlier run's amount counts toward this payment")
	stored, _ := paymentRepo.GetByID(context.Background(), payment.GetID())
	assert.Equal(t, int32(constants.StateInactive), stored.State)

	// An unfinished prior order (written, obligation not consumed) is completed now.
	payment2 := &models.IncomingPayment{
		TransactionID: "txn-unfinished", Amount: 30_000, Currency: "UGX",
		OwnerID: "member-1", OwnerType: "membership", State: int32(constants.StateJustCreated),
		Properties: data.JSONMap{"product_id": "prod-1"},
	}
	payment2.GenID(context.Background())
	paymentRepo.store(payment2)
	obligations2 := &allocObligationRepoStub{obligations: []*models.Obligation{newSavingsObligation("ob-6", 30_000)}}
	unfinished := &models.TransferOrder{Reference: "payment:" + payment2.GetID() + ":obligation:ob-6",
		Amount: 30_000, Currency: "UGX"}
	unfinished.GenID(context.Background())
	orders2 := &allocOrderRepoStub{
		byReference: map[string]*models.TransferOrder{unfinished.Reference: unfinished},
		obligations: obligations2,
	}
	business2 := &paymentRoutingBusiness{
		eventsMan: &paymentEventsManagerStub{paymentRepo: paymentRepo},
		ipRepo:    paymentRepo,
		obRepo:    obligations2,
		toRepo:    orders2,
	}
	_, err = business2.AllocatePayment(context.Background(), payment2.GetID())
	require.NoError(t, err)
	assert.Equal(t, int64(30_000), obligations2.consumed["ob-6"], "the unfinished pair is completed exactly once")
	assert.True(t, orders2.byReference[unfinished.Reference].ObligationConsumed)
}

// A payment past its initial state with no recorded remainder is never
// guessed at: it is treated as processed and left for reconciliation.
func TestAllocatePayment_UnknownRemainderFailsClosed(t *testing.T) {
	t.Parallel()

	paymentRepo := newIncomingPaymentRepoStub()
	payment := &models.IncomingPayment{
		TransactionID: "txn-unknown", Amount: 30_000, Currency: "UGX",
		OwnerID: "member-1", OwnerType: "membership", State: int32(constants.StateActive),
	}
	payment.GenID(context.Background())
	paymentRepo.store(payment)
	obligations := &allocObligationRepoStub{obligations: []*models.Obligation{newSavingsObligation("ob-7", 30_000)}}
	business := &paymentRoutingBusiness{
		eventsMan: &paymentEventsManagerStub{paymentRepo: paymentRepo},
		ipRepo:    paymentRepo,
		obRepo:    obligations,
		toRepo:    &allocOrderRepoStub{obligations: obligations},
	}

	result, err := business.AllocatePayment(context.Background(), payment.GetID())
	require.NoError(t, err)
	assert.Equal(t, "already_processed", result["status"])
	assert.Empty(t, obligations.consumed)
}

// ListUnexecutedAllocations lists the raised, unposted allocation orders;
// the stub ignores the age cut-off.
func (r *allocOrderRepoStub) ListUnexecutedAllocations(
	_ context.Context,
	_ time.Time,
	limit int,
) ([]*models.TransferOrder, error) {
	var out []*models.TransferOrder
	for _, o := range r.byReference {
		allocation := strings.Contains(o.Reference, ":loan:") || strings.Contains(o.Reference, ":member:") ||
			(strings.Contains(o.Reference, ":obligation:") && o.ExtraData[extraKeySuspenseFunded] == true)
		if o.State == int32(constants.StateJustCreated) && allocation && len(out) < limit {
			out = append(out, o)
		}
	}
	return out, nil
}

// ListAwaitingAllocation lists matched, unallocated payments; the stub
// ignores the age cut-off.
func (r *incomingPaymentRepoStub) ListAwaitingAllocation(
	_ context.Context,
	_, _ time.Time,
	limit int,
) ([]*models.IncomingPayment, error) {
	var out []*models.IncomingPayment
	for _, p := range r.byID {
		allocatable := p.OwnerType == ownerTypeClientLoan || p.OwnerType == ownerTypeClientSavings ||
			p.OwnerType == ownerTypeInvestorAccount || p.OwnerType == ownerTypeMembership
		if allocatable && p.OwnerID != "" && p.State == int32(constants.StateJustCreated) &&
			p.AllocatingAt == nil && len(out) < limit {
			out = append(out, p)
		}
	}
	return out, nil
}

// A notifier names the payment; it never sets what identification and
// allocation decide.
func TestNotifiedPropertiesCannotPreDecideThePayment(t *testing.T) {
	props := incomingPaymentProperties(map[string]interface{}{
		"properties": data.JSONMap{
			"reference":               "loan-1",
			fieldRemainingAmount:      int64(1),
			fieldClientID:             "client-x",
			"identification_strategy": "forged",
		},
	})
	assert.Equal(t, "loan-1", props.GetString("reference"))
	for _, key := range decidedPaymentProperties() {
		assert.NotContains(t, props, key)
	}
}
