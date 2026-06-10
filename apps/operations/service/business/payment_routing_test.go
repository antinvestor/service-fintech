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
	"testing"

	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/frame/datastore/pool"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/frame/queue"
	"github.com/pitabwire/frame/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/operations/service/events"
	"github.com/antinvestor/service-fintech/apps/operations/service/models"
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
		},
	}
	payment.GenID(context.Background())
	paymentRepo.store(payment)

	business := &paymentRoutingBusiness{
		eventsMan: &paymentEventsManagerStub{paymentRepo: paymentRepo},
		ipRepo:    paymentRepo,
		obRepo:    &obligationRepoStub{},
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
}

type paymentEventsManagerStub struct {
	paymentRepo *incomingPaymentRepoStub
}

func (e *paymentEventsManagerStub) Add(fevents.EventI) {}

func (e *paymentEventsManagerStub) Get(string) (fevents.EventI, error) {
	return nil, errUnexpectedStubCall
}

func (e *paymentEventsManagerStub) Emit(_ context.Context, name string, payload any) error {
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
