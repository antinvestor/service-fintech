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

// Focused unit tests for the operations transfer_order limits Gate routing
// using in-process stubs for all dependencies.

import (
	"context"
	"errors"
	"testing"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/frame/datastore/pool"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/frame/queue"
	"github.com/pitabwire/frame/workerpool"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

// ---------------------------------------------------------------------------
// Stubs
// ---------------------------------------------------------------------------

// noopTransferEventsManager drops all emissions silently.
type noopTransferEventsManager struct{}

func (n *noopTransferEventsManager) Add(_ fevents.EventI)                          {}
func (n *noopTransferEventsManager) Get(_ string) (fevents.EventI, error)          { return nil, nil }
func (n *noopTransferEventsManager) Emit(_ context.Context, _ string, _ any) error { return nil }
func (n *noopTransferEventsManager) Handler() queue.SubscribeWorker                { return nil }

// Strict / SetStrict satisfy events.Manager (frame >=v1.98.2); the noop
// manager never consumes from a queue, so strict mode is irrelevant here.
func (n *noopTransferEventsManager) Strict() bool   { return true }
func (n *noopTransferEventsManager) SetStrict(bool) {}

var _ fevents.Manager = (*noopTransferEventsManager)(nil)

// stubTransferOrderRepo implements repository.TransferOrderRepository.
type stubTransferOrderRepo struct {
	order   *models.TransferOrder
	findErr error
}

func (r *stubTransferOrderRepo) Pool() pool.Pool                 { return nil }
func (r *stubTransferOrderRepo) WorkManager() workerpool.Manager { return nil }
func (r *stubTransferOrderRepo) GetByID(_ context.Context, _ string) (*models.TransferOrder, error) {
	if r.findErr != nil {
		return nil, r.findErr
	}
	clone := *r.order
	return &clone, nil
}
func (r *stubTransferOrderRepo) GetLastestBy(_ context.Context, _ map[string]any) (*models.TransferOrder, error) {
	return nil, gorm.ErrRecordNotFound
}

func (r *stubTransferOrderRepo) GetAllBy(
	_ context.Context,
	_ map[string]any,
	_, _ int,
) ([]*models.TransferOrder, error) {
	return nil, nil
}
func (r *stubTransferOrderRepo) Create(_ context.Context, _ *models.TransferOrder) error { return nil }
func (r *stubTransferOrderRepo) BulkCreate(_ context.Context, _ []*models.TransferOrder) error {
	return nil
}
func (r *stubTransferOrderRepo) Update(_ context.Context, _ *models.TransferOrder, _ ...string) (int64, error) {
	return 1, nil
}
func (r *stubTransferOrderRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubTransferOrderRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubTransferOrderRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubTransferOrderRepo) BatchSize() int                                  { return 100 }
func (r *stubTransferOrderRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubTransferOrderRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubTransferOrderRepo) FieldsImmutable() []string          { return nil }
func (r *stubTransferOrderRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubTransferOrderRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubTransferOrderRepo) IsFieldAllowed(_ string) error      { return nil }
func (r *stubTransferOrderRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*models.TransferOrder], error) {
	return nil, errors.New("stub: search not implemented")
}
func (r *stubTransferOrderRepo) GetByReference(_ context.Context, _ string) (*models.TransferOrder, error) {
	return nil, gorm.ErrRecordNotFound
}

var _ repository.TransferOrderRepository = (*stubTransferOrderRepo)(nil)

// stubTransferLimitsClient implements limitsv1connect.LimitsServiceClient.
type stubTransferLimitsClient struct {
	reserveResp  *limitsv1.ReserveResponse
	reserveErr   error
	commitCalls  int
	releaseCalls int
	reserveCalls int
}

func (s *stubTransferLimitsClient) Check(
	_ context.Context,
	_ *connect.Request[limitsv1.CheckRequest],
) (*connect.Response[limitsv1.CheckResponse], error) {
	return connect.NewResponse(&limitsv1.CheckResponse{}), nil
}

func (s *stubTransferLimitsClient) Reserve(
	_ context.Context,
	_ *connect.Request[limitsv1.ReserveRequest],
) (*connect.Response[limitsv1.ReserveResponse], error) {
	s.reserveCalls++
	if s.reserveErr != nil {
		return nil, s.reserveErr
	}
	return connect.NewResponse(s.reserveResp), nil
}

func (s *stubTransferLimitsClient) Commit(
	_ context.Context,
	_ *connect.Request[limitsv1.CommitRequest],
) (*connect.Response[limitsv1.CommitResponse], error) {
	s.commitCalls++
	return connect.NewResponse(&limitsv1.CommitResponse{}), nil
}

func (s *stubTransferLimitsClient) Release(
	_ context.Context,
	_ *connect.Request[limitsv1.ReleaseRequest],
) (*connect.Response[limitsv1.ReleaseResponse], error) {
	s.releaseCalls++
	return connect.NewResponse(&limitsv1.ReleaseResponse{}), nil
}

func (s *stubTransferLimitsClient) Reverse(
	_ context.Context,
	_ *connect.Request[limitsv1.ReverseRequest],
) (*connect.Response[limitsv1.ReverseResponse], error) {
	return connect.NewResponse(&limitsv1.ReverseResponse{}), nil
}

var _ limitsv1connect.LimitsServiceClient = (*stubTransferLimitsClient)(nil)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// inactiveTransferOrder returns a TransferOrder already in StateInactive so
// executeInner returns nil immediately (order already completed guard). This
// allows the gate tests to succeed without needing a real ledger client.
func inactiveTransferOrder(currency string, amount int64) *models.TransferOrder {
	o := &models.TransferOrder{
		DebitAccountRef:  "debit-account-ref",
		CreditAccountRef: "credit-account-ref",
		Amount:           amount,
		Currency:         currency,
		OrderType:        constants.SafeInt32FromInt(constants.TransferTypeLoan),
		State:            int32(constants.StateInactive),
	}
	o.GenID(context.Background())
	o.TenantID = "tenant-1"
	return o
}

func buildTransferOrderBusiness(
	toRepo repository.TransferOrderRepository,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsEnabled bool,
) *transferOrderBusiness {
	return &transferOrderBusiness{
		eventsMan:         &noopTransferEventsManager{},
		toRepo:            toRepo,
		csRepo:            nil,
		arRepo:            nil,
		lfRepo:            nil,
		ftRepo:            nil,
		iaRepo:            nil,
		clients:           nil,
		auditWriter:       nil,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsEnabled,
	}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

// TestTransferOrderExecute_GateDisabled verifies that when limitsGateEnabled=false
// the Execute method runs without touching the limits client.
func TestTransferOrderExecute_GateDisabled(t *testing.T) {
	order := inactiveTransferOrder("UGX", 10_000)
	toRepo := &stubTransferOrderRepo{order: order}
	limitsCli := &stubTransferLimitsClient{}

	b := buildTransferOrderBusiness(toRepo, limitsCli, false)

	err := b.Execute(context.Background(), order.GetID())
	require.NoError(t, err)
	assert.Equal(t, 0, limitsCli.reserveCalls, "gate must not be called when disabled")
}

// TestTransferOrderExecute_GateAllowed verifies that when Reserve returns ACTIVE,
// the inner execution succeeds and Commit is called.
func TestTransferOrderExecute_GateAllowed(t *testing.T) {
	order := inactiveTransferOrder("UGX", 10_000)
	toRepo := &stubTransferOrderRepo{order: order}
	limitsCli := &stubTransferLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-transfer-allowed",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
			},
		},
	}

	b := buildTransferOrderBusiness(toRepo, limitsCli, true)

	err := b.Execute(context.Background(), order.GetID())
	require.NoError(t, err)
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 1, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}

// TestTransferOrderExecute_GateDenied verifies that when Reserve returns a deny
// error, Execute returns an error and the inner logic does not proceed.
func TestTransferOrderExecute_GateDenied(t *testing.T) {
	order := inactiveTransferOrder("UGX", 10_000)
	toRepo := &stubTransferOrderRepo{order: order}
	limitsCli := &stubTransferLimitsClient{
		reserveErr: connect.NewError(connect.CodeFailedPrecondition, errors.New("transfer limit breached")),
	}

	b := buildTransferOrderBusiness(toRepo, limitsCli, true)

	err := b.Execute(context.Background(), order.GetID())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "transfer limit breached")
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
}

// TestTransferOrderExecute_GatePending verifies that when Reserve returns
// PENDING_APPROVAL, Execute returns a PendingApprovalError and the inner
// logic does not proceed.
func TestTransferOrderExecute_GatePending(t *testing.T) {
	order := inactiveTransferOrder("UGX", 10_000)
	toRepo := &stubTransferOrderRepo{order: order}
	limitsCli := &stubTransferLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-transfer-pending",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
			},
		},
	}

	b := buildTransferOrderBusiness(toRepo, limitsCli, true)

	err := b.Execute(context.Background(), order.GetID())
	require.Error(t, err)

	var pendingErr *limits.PendingApprovalError
	require.ErrorAs(t, err, &pendingErr)
	assert.Equal(t, "res-transfer-pending", pendingErr.ReservationID)

	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}
