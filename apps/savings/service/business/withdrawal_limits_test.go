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

// Note: focused unit tests for the savings withdrawal limits Gate routing using
// in-process stubs for all dependencies.

import (
	"context"
	"errors"
	"testing"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/frame/v2/queue"
	"github.com/pitabwire/frame/v2/workerpool"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	savingsmodels "github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

// ---------------------------------------------------------------------------
// Stubs (withdrawal-specific)
// ---------------------------------------------------------------------------

// noopWithdrawalEventsManager implements fevents.Manager and silently drops all emissions.
type noopWithdrawalEventsManager struct{}

func (n *noopWithdrawalEventsManager) Add(_ fevents.EventI) {}
func (n *noopWithdrawalEventsManager) Get(_ string) (fevents.EventI, error) {
	return nil, nil //nolint:nilnil // no-op stub: tests never look up events
}
func (n *noopWithdrawalEventsManager) Emit(_ context.Context, _ string, _ any) error { return nil }
func (n *noopWithdrawalEventsManager) Handler() queue.SubscribeWorker                { return nil }

// Strict / SetStrict satisfy events.Manager (frame >=v1.98.2); the noop
// manager never consumes from a queue, so strict mode is irrelevant here.
func (n *noopWithdrawalEventsManager) Strict() bool   { return true }
func (n *noopWithdrawalEventsManager) SetStrict(bool) {}

var _ fevents.Manager = (*noopWithdrawalEventsManager)(nil)

// stubWithdrawalRepo implements repository.WithdrawalRepository.
type stubWithdrawalRepo struct {
	findResp *savingsmodels.Withdrawal
	findErr  error
}

func (r *stubWithdrawalRepo) Pool() pool.Pool                 { return nil }
func (r *stubWithdrawalRepo) WorkManager() workerpool.Manager { return nil }
func (r *stubWithdrawalRepo) GetByID(_ context.Context, _ string) (*savingsmodels.Withdrawal, error) {
	return r.findResp, r.findErr
}
func (r *stubWithdrawalRepo) GetLastestBy(_ context.Context, _ map[string]any) (*savingsmodels.Withdrawal, error) {
	return nil, errors.New("stub: not found")
}

func (r *stubWithdrawalRepo) GetAllBy(
	_ context.Context,
	_ map[string]any,
	_, _ int,
) ([]*savingsmodels.Withdrawal, error) {
	return nil, nil
}
func (r *stubWithdrawalRepo) Create(_ context.Context, _ *savingsmodels.Withdrawal) error {
	return nil
}
func (r *stubWithdrawalRepo) BulkCreate(_ context.Context, _ []*savingsmodels.Withdrawal) error {
	return nil
}
func (r *stubWithdrawalRepo) Update(_ context.Context, _ *savingsmodels.Withdrawal, _ ...string) (int64, error) {
	return 1, nil
}
func (r *stubWithdrawalRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubWithdrawalRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubWithdrawalRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubWithdrawalRepo) BatchSize() int                                  { return 100 }
func (r *stubWithdrawalRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubWithdrawalRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubWithdrawalRepo) FieldsImmutable() []string          { return nil }
func (r *stubWithdrawalRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubWithdrawalRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubWithdrawalRepo) IsFieldAllowed(_ string) error      { return nil }
func (r *stubWithdrawalRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*savingsmodels.Withdrawal], error) {
	return nil, errors.New("stub: search not implemented")
}
func (r *stubWithdrawalRepo) GetByIdempotencyKey(_ context.Context, _ string) (*savingsmodels.Withdrawal, error) {
	return nil, errors.New("stub: not found")
}

var _ repository.WithdrawalRepository = (*stubWithdrawalRepo)(nil)
var _ datastore.BaseRepository[*savingsmodels.Withdrawal] = (*stubWithdrawalRepo)(nil)

// stubWithdrawalLimitsClient implements limitsv1connect.LimitsServiceClient.
type stubWithdrawalLimitsClient struct {
	reserveResp  *limitsv1.ReserveResponse
	reserveErr   error
	commitCalls  int
	releaseCalls int
	reserveCalls int
}

func (s *stubWithdrawalLimitsClient) Check(
	_ context.Context,
	_ *connect.Request[limitsv1.CheckRequest],
) (*connect.Response[limitsv1.CheckResponse], error) {
	return connect.NewResponse(&limitsv1.CheckResponse{}), nil
}

func (s *stubWithdrawalLimitsClient) Reserve(
	_ context.Context,
	_ *connect.Request[limitsv1.ReserveRequest],
) (*connect.Response[limitsv1.ReserveResponse], error) {
	s.reserveCalls++
	if s.reserveErr != nil {
		return nil, s.reserveErr
	}
	return connect.NewResponse(s.reserveResp), nil
}

func (s *stubWithdrawalLimitsClient) Commit(
	_ context.Context,
	_ *connect.Request[limitsv1.CommitRequest],
) (*connect.Response[limitsv1.CommitResponse], error) {
	s.commitCalls++
	return connect.NewResponse(&limitsv1.CommitResponse{}), nil
}

func (s *stubWithdrawalLimitsClient) Release(
	_ context.Context,
	_ *connect.Request[limitsv1.ReleaseRequest],
) (*connect.Response[limitsv1.ReleaseResponse], error) {
	s.releaseCalls++
	return connect.NewResponse(&limitsv1.ReleaseResponse{}), nil
}

func (s *stubWithdrawalLimitsClient) Reverse(
	_ context.Context,
	_ *connect.Request[limitsv1.ReverseRequest],
) (*connect.Response[limitsv1.ReverseResponse], error) {
	return connect.NewResponse(&limitsv1.ReverseResponse{}), nil
}

var _ limitsv1connect.LimitsServiceClient = (*stubWithdrawalLimitsClient)(nil)

// stubWithdrawalOperationsClient implements operationsv1connect.OperationsServiceClient.
type stubWithdrawalOperationsClient struct {
	transferResp *operationsv1.TransferOrderExecuteResponse
	transferErr  error
}

func (s *stubWithdrawalOperationsClient) TransferOrderExecute(
	_ context.Context,
	_ *connect.Request[operationsv1.TransferOrderExecuteRequest],
) (*connect.Response[operationsv1.TransferOrderExecuteResponse], error) {
	if s.transferErr != nil {
		return nil, s.transferErr
	}
	return connect.NewResponse(s.transferResp), nil
}

func (s *stubWithdrawalOperationsClient) TransferOrderSearch(
	_ context.Context,
	_ *connect.Request[operationsv1.TransferOrderSearchRequest],
) (*connect.ServerStreamForClient[operationsv1.TransferOrderSearchResponse], error) {
	panic("stub: TransferOrderSearch not expected")
}

func (s *stubWithdrawalOperationsClient) IncomingPaymentNotify(
	_ context.Context,
	_ *connect.Request[operationsv1.IncomingPaymentNotifyRequest],
) (*connect.Response[operationsv1.IncomingPaymentNotifyResponse], error) {
	panic("stub: IncomingPaymentNotify not expected")
}

func (s *stubWithdrawalOperationsClient) PaymentAllocate(
	_ context.Context,
	_ *connect.Request[operationsv1.PaymentAllocateRequest],
) (*connect.Response[operationsv1.PaymentAllocateResponse], error) {
	panic("stub: PaymentAllocate not expected")
}

var _ operationsv1connect.OperationsServiceClient = (*stubWithdrawalOperationsClient)(nil)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// pendingWithdrawal returns a minimal Withdrawal in PENDING state with all
// required fields populated.
func pendingWithdrawal(accountID string, amount int64, currency string) *savingsmodels.Withdrawal {
	w := &savingsmodels.Withdrawal{
		SavingsAccountID: accountID,
		Amount:           amount,
		CurrencyCode:     currency,
		Status:           int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_PENDING),
		Channel:          "MOBILE",
	}
	w.GenID(context.Background())
	return w
}

func buildWithdrawalBusiness(
	wdrRepo repository.WithdrawalRepository,
	saRepo repository.SavingsAccountRepository,
	sbRepo repository.SavingsBalanceRepository,
	opsCli operationsv1connect.OperationsServiceClient,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsEnabled bool,
) *withdrawalBusiness {
	return &withdrawalBusiness{
		eventsMan:         &noopWithdrawalEventsManager{},
		wdrRepo:           wdrRepo,
		saRepo:            saRepo,
		sbRepo:            sbRepo,
		saBusiness:        nil,
		operationsCli:     opsCli,
		auditWriter:       nil,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsEnabled,
	}
}

func defaultWithdrawalOpsClient() *stubWithdrawalOperationsClient {
	return &stubWithdrawalOperationsClient{
		transferResp: &operationsv1.TransferOrderExecuteResponse{
			Data: &operationsv1.TransferOrderObject{Id: "txn-withdrawal-1"},
		},
	}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

// TestWithdrawalApprove_GateDisabled verifies that when limitsGateEnabled=false
// the Approve method runs without touching the limits client.
func TestWithdrawalApprove_GateDisabled(t *testing.T) {
	sa := activeSavingsAccount()
	wdr := pendingWithdrawal(sa.GetID(), 5000, sa.CurrencyCode)

	wdrRepo := &stubWithdrawalRepo{findResp: wdr, findErr: nil}
	saRepo := &stubSavingsAccountRepo{account: sa}
	sbRepo := &stubSavingsBalanceRepo{}
	limitsCli := &stubWithdrawalLimitsClient{}

	b := buildWithdrawalBusiness(wdrRepo, saRepo, sbRepo, defaultWithdrawalOpsClient(), limitsCli, false)

	result, err := b.Approve(context.Background(), wdr.GetID())
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, 0, limitsCli.reserveCalls, "gate must not be called when disabled")
}

// TestWithdrawalApprove_GateAllowed verifies that when Reserve returns ACTIVE,
// the withdrawal is settled and Commit is called.
func TestWithdrawalApprove_GateAllowed(t *testing.T) {
	sa := activeSavingsAccount()
	wdr := pendingWithdrawal(sa.GetID(), 5000, sa.CurrencyCode)

	wdrRepo := &stubWithdrawalRepo{findResp: wdr, findErr: nil}
	saRepo := &stubSavingsAccountRepo{account: sa}
	sbRepo := &stubSavingsBalanceRepo{}
	limitsCli := &stubWithdrawalLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-wdr-allowed",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
			},
		},
	}

	b := buildWithdrawalBusiness(wdrRepo, saRepo, sbRepo, defaultWithdrawalOpsClient(), limitsCli, true)

	result, err := b.Approve(context.Background(), wdr.GetID())
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 1, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}

// TestWithdrawalApprove_GateDenied verifies that when Reserve returns a deny
// error, Approve returns an error and the settlement does not proceed.
func TestWithdrawalApprove_GateDenied(t *testing.T) {
	sa := activeSavingsAccount()
	wdr := pendingWithdrawal(sa.GetID(), 5000, sa.CurrencyCode)

	wdrRepo := &stubWithdrawalRepo{findResp: wdr, findErr: nil}
	saRepo := &stubSavingsAccountRepo{account: sa}
	sbRepo := &stubSavingsBalanceRepo{}
	limitsCli := &stubWithdrawalLimitsClient{
		reserveErr: connect.NewError(connect.CodeFailedPrecondition, errors.New("withdrawal limit breached")),
	}
	opsCli := &stubWithdrawalOperationsClient{} // must not be called

	b := buildWithdrawalBusiness(wdrRepo, saRepo, sbRepo, opsCli, limitsCli, true)

	result, err := b.Approve(context.Background(), wdr.GetID())
	require.Error(t, err)
	assert.Nil(t, result)
	assert.Contains(t, err.Error(), "withdrawal limit breached")
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
}

// TestWithdrawalApprove_GatePending verifies that when Reserve returns
// PENDING_APPROVAL, Approve returns a PendingApprovalError and the
// settlement does not proceed.
func TestWithdrawalApprove_GatePending(t *testing.T) {
	sa := activeSavingsAccount()
	wdr := pendingWithdrawal(sa.GetID(), 5000, sa.CurrencyCode)

	wdrRepo := &stubWithdrawalRepo{findResp: wdr, findErr: nil}
	saRepo := &stubSavingsAccountRepo{account: sa}
	sbRepo := &stubSavingsBalanceRepo{}
	limitsCli := &stubWithdrawalLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-wdr-pending",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
			},
		},
	}
	opsCli := &stubWithdrawalOperationsClient{} // must not be called

	b := buildWithdrawalBusiness(wdrRepo, saRepo, sbRepo, opsCli, limitsCli, true)

	result, err := b.Approve(context.Background(), wdr.GetID())
	require.Error(t, err)
	assert.Nil(t, result)

	var pendingErr *limits.PendingApprovalError
	require.ErrorAs(t, err, &pendingErr)
	assert.Equal(t, "res-wdr-pending", pendingErr.ReservationID)

	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}
