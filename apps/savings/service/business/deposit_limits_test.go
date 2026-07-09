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

// Note: focused unit tests for the savings deposit limits Gate routing using
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
// Shared stubs (deposit + withdrawal tests)
// ---------------------------------------------------------------------------

// noopDepositEventsManager implements fevents.Manager and silently drops all emissions.
type noopDepositEventsManager struct{}

func (n *noopDepositEventsManager) Add(_ fevents.EventI) {}
func (n *noopDepositEventsManager) Get(_ string) (fevents.EventI, error) {
	return nil, nil //nolint:nilnil // no-op stub: tests never look up events
}
func (n *noopDepositEventsManager) Emit(_ context.Context, _ string, _ any) error { return nil }
func (n *noopDepositEventsManager) Handler() queue.SubscribeWorker                { return nil }

// Strict / SetStrict satisfy events.Manager (frame >=v1.98.2); the noop
// manager never consumes from a queue, so strict mode is irrelevant here.
func (n *noopDepositEventsManager) Strict() bool   { return true }
func (n *noopDepositEventsManager) SetStrict(bool) {}

var _ fevents.Manager = (*noopDepositEventsManager)(nil)

// stubDepositRepo implements repository.DepositRepository.
type stubDepositRepo struct {
	findResp *savingsmodels.Deposit
	findErr  error
	stored   []*savingsmodels.Deposit
}

func (r *stubDepositRepo) Pool() pool.Pool                 { return nil }
func (r *stubDepositRepo) WorkManager() workerpool.Manager { return nil }
func (r *stubDepositRepo) GetByID(_ context.Context, _ string) (*savingsmodels.Deposit, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubDepositRepo) GetLastestBy(_ context.Context, _ map[string]any) (*savingsmodels.Deposit, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubDepositRepo) GetAllBy(_ context.Context, _ map[string]any, _, _ int) ([]*savingsmodels.Deposit, error) {
	return nil, nil
}
func (r *stubDepositRepo) Create(_ context.Context, entity *savingsmodels.Deposit) error {
	r.stored = append(r.stored, entity)
	return nil
}
func (r *stubDepositRepo) BulkCreate(_ context.Context, _ []*savingsmodels.Deposit) error {
	return nil
}
func (r *stubDepositRepo) Update(_ context.Context, _ *savingsmodels.Deposit, _ ...string) (int64, error) {
	return 1, nil
}
func (r *stubDepositRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubDepositRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubDepositRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubDepositRepo) BatchSize() int                                  { return 100 }
func (r *stubDepositRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubDepositRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubDepositRepo) FieldsImmutable() []string          { return nil }
func (r *stubDepositRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubDepositRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubDepositRepo) IsFieldAllowed(_ string) error      { return nil }
func (r *stubDepositRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*savingsmodels.Deposit], error) {
	return nil, errors.New("stub: search not implemented")
}
func (r *stubDepositRepo) GetByIdempotencyKey(_ context.Context, _ string) (*savingsmodels.Deposit, error) {
	return r.findResp, r.findErr
}

var _ repository.DepositRepository = (*stubDepositRepo)(nil)
var _ datastore.BaseRepository[*savingsmodels.Deposit] = (*stubDepositRepo)(nil)

// stubSavingsAccountRepo implements repository.SavingsAccountRepository.
type stubSavingsAccountRepo struct {
	account *savingsmodels.SavingsAccount
	err     error
}

func (r *stubSavingsAccountRepo) Pool() pool.Pool                 { return nil }
func (r *stubSavingsAccountRepo) WorkManager() workerpool.Manager { return nil }
func (r *stubSavingsAccountRepo) GetByID(_ context.Context, _ string) (*savingsmodels.SavingsAccount, error) {
	return r.account, r.err
}

func (r *stubSavingsAccountRepo) GetLastestBy(
	_ context.Context,
	_ map[string]any,
) (*savingsmodels.SavingsAccount, error) {
	return nil, errors.New("stub: not found")
}

func (r *stubSavingsAccountRepo) GetAllBy(
	_ context.Context,
	_ map[string]any,
	_, _ int,
) ([]*savingsmodels.SavingsAccount, error) {
	return nil, nil
}
func (r *stubSavingsAccountRepo) Create(_ context.Context, _ *savingsmodels.SavingsAccount) error {
	return nil
}
func (r *stubSavingsAccountRepo) BulkCreate(_ context.Context, _ []*savingsmodels.SavingsAccount) error {
	return nil
}

func (r *stubSavingsAccountRepo) Update(
	_ context.Context,
	_ *savingsmodels.SavingsAccount,
	_ ...string,
) (int64, error) {
	return 1, nil
}
func (r *stubSavingsAccountRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubSavingsAccountRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubSavingsAccountRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubSavingsAccountRepo) BatchSize() int                                  { return 100 }
func (r *stubSavingsAccountRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubSavingsAccountRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubSavingsAccountRepo) FieldsImmutable() []string          { return nil }
func (r *stubSavingsAccountRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubSavingsAccountRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubSavingsAccountRepo) IsFieldAllowed(_ string) error      { return nil }
func (r *stubSavingsAccountRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*savingsmodels.SavingsAccount], error) {
	return nil, errors.New("stub: search not implemented")
}

var _ repository.SavingsAccountRepository = (*stubSavingsAccountRepo)(nil)
var _ datastore.BaseRepository[*savingsmodels.SavingsAccount] = (*stubSavingsAccountRepo)(nil)

// stubSavingsBalanceRepo implements repository.SavingsBalanceRepository.
type stubSavingsBalanceRepo struct {
	creditErr error
}

func (r *stubSavingsBalanceRepo) Pool() pool.Pool                 { return nil }
func (r *stubSavingsBalanceRepo) WorkManager() workerpool.Manager { return nil }
func (r *stubSavingsBalanceRepo) GetByID(_ context.Context, _ string) (*savingsmodels.SavingsBalance, error) {
	return nil, errors.New("stub: not found")
}

func (r *stubSavingsBalanceRepo) GetLastestBy(
	_ context.Context,
	_ map[string]any,
) (*savingsmodels.SavingsBalance, error) {
	return nil, errors.New("stub: not found")
}

func (r *stubSavingsBalanceRepo) GetAllBy(
	_ context.Context,
	_ map[string]any,
	_, _ int,
) ([]*savingsmodels.SavingsBalance, error) {
	return nil, nil
}
func (r *stubSavingsBalanceRepo) Create(_ context.Context, _ *savingsmodels.SavingsBalance) error {
	return nil
}
func (r *stubSavingsBalanceRepo) BulkCreate(_ context.Context, _ []*savingsmodels.SavingsBalance) error {
	return nil
}

func (r *stubSavingsBalanceRepo) Update(
	_ context.Context,
	_ *savingsmodels.SavingsBalance,
	_ ...string,
) (int64, error) {
	return 1, nil
}
func (r *stubSavingsBalanceRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubSavingsBalanceRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubSavingsBalanceRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubSavingsBalanceRepo) BatchSize() int                                  { return 100 }
func (r *stubSavingsBalanceRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubSavingsBalanceRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubSavingsBalanceRepo) FieldsImmutable() []string          { return nil }
func (r *stubSavingsBalanceRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubSavingsBalanceRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubSavingsBalanceRepo) IsFieldAllowed(_ string) error      { return nil }
func (r *stubSavingsBalanceRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*savingsmodels.SavingsBalance], error) {
	return nil, errors.New("stub: search not implemented")
}

func (r *stubSavingsBalanceRepo) GetBySavingsAccountID(
	_ context.Context,
	_ string,
) (*savingsmodels.SavingsBalance, error) {
	return &savingsmodels.SavingsBalance{}, nil
}

func (r *stubSavingsBalanceRepo) Ensure(
	_ context.Context,
	_, _ string,
	_ *data.BaseModel,
) (*savingsmodels.SavingsBalance, error) {
	return &savingsmodels.SavingsBalance{}, nil
}
func (r *stubSavingsBalanceRepo) Credit(_ context.Context, _ string, _ int64) (*savingsmodels.SavingsBalance, error) {
	if r.creditErr != nil {
		return nil, r.creditErr
	}
	return &savingsmodels.SavingsBalance{}, nil
}

func (r *stubSavingsBalanceRepo) CreditInterest(
	_ context.Context,
	_ string,
	_ int64,
) (*savingsmodels.SavingsBalance, error) {
	return &savingsmodels.SavingsBalance{}, nil
}
func (r *stubSavingsBalanceRepo) Reserve(_ context.Context, _ string, _ int64) (*savingsmodels.SavingsBalance, error) {
	return &savingsmodels.SavingsBalance{}, nil
}

func (r *stubSavingsBalanceRepo) DebitReserved(
	_ context.Context,
	_ string,
	_ int64,
) (*savingsmodels.SavingsBalance, error) {
	return &savingsmodels.SavingsBalance{}, nil
}

func (r *stubSavingsBalanceRepo) ReleaseReserved(
	_ context.Context,
	_ string,
	_ int64,
) (*savingsmodels.SavingsBalance, error) {
	return &savingsmodels.SavingsBalance{}, nil
}

var _ repository.SavingsBalanceRepository = (*stubSavingsBalanceRepo)(nil)
var _ datastore.BaseRepository[*savingsmodels.SavingsBalance] = (*stubSavingsBalanceRepo)(nil)

// stubDepositOperationsClient implements operationsv1connect.OperationsServiceClient.
type stubDepositOperationsClient struct {
	transferResp *operationsv1.TransferOrderExecuteResponse
	transferErr  error
}

func (s *stubDepositOperationsClient) TransferOrderExecute(
	_ context.Context,
	_ *connect.Request[operationsv1.TransferOrderExecuteRequest],
) (*connect.Response[operationsv1.TransferOrderExecuteResponse], error) {
	if s.transferErr != nil {
		return nil, s.transferErr
	}
	return connect.NewResponse(s.transferResp), nil
}

func (s *stubDepositOperationsClient) TransferOrderSearch(
	_ context.Context,
	_ *connect.Request[operationsv1.TransferOrderSearchRequest],
) (*connect.ServerStreamForClient[operationsv1.TransferOrderSearchResponse], error) {
	panic("stub: TransferOrderSearch not expected")
}

func (s *stubDepositOperationsClient) IncomingPaymentNotify(
	_ context.Context,
	_ *connect.Request[operationsv1.IncomingPaymentNotifyRequest],
) (*connect.Response[operationsv1.IncomingPaymentNotifyResponse], error) {
	panic("stub: IncomingPaymentNotify not expected")
}

func (s *stubDepositOperationsClient) PaymentAllocate(
	_ context.Context,
	_ *connect.Request[operationsv1.PaymentAllocateRequest],
) (*connect.Response[operationsv1.PaymentAllocateResponse], error) {
	panic("stub: PaymentAllocate not expected")
}

var _ operationsv1connect.OperationsServiceClient = (*stubDepositOperationsClient)(nil)

// stubDepositLimitsClient implements limitsv1connect.LimitsServiceClient.
type stubDepositLimitsClient struct {
	reserveResp  *limitsv1.ReserveResponse
	reserveErr   error
	commitCalls  int
	releaseCalls int
	reserveCalls int
}

func (s *stubDepositLimitsClient) Check(
	_ context.Context,
	_ *connect.Request[limitsv1.CheckRequest],
) (*connect.Response[limitsv1.CheckResponse], error) {
	return connect.NewResponse(&limitsv1.CheckResponse{}), nil
}

func (s *stubDepositLimitsClient) Reserve(
	_ context.Context,
	_ *connect.Request[limitsv1.ReserveRequest],
) (*connect.Response[limitsv1.ReserveResponse], error) {
	s.reserveCalls++
	if s.reserveErr != nil {
		return nil, s.reserveErr
	}
	return connect.NewResponse(s.reserveResp), nil
}

func (s *stubDepositLimitsClient) Commit(
	_ context.Context,
	_ *connect.Request[limitsv1.CommitRequest],
) (*connect.Response[limitsv1.CommitResponse], error) {
	s.commitCalls++
	return connect.NewResponse(&limitsv1.CommitResponse{}), nil
}

func (s *stubDepositLimitsClient) Release(
	_ context.Context,
	_ *connect.Request[limitsv1.ReleaseRequest],
) (*connect.Response[limitsv1.ReleaseResponse], error) {
	s.releaseCalls++
	return connect.NewResponse(&limitsv1.ReleaseResponse{}), nil
}

func (s *stubDepositLimitsClient) Reverse(
	_ context.Context,
	_ *connect.Request[limitsv1.ReverseRequest],
) (*connect.Response[limitsv1.ReverseResponse], error) {
	return connect.NewResponse(&limitsv1.ReverseResponse{}), nil
}

var _ limitsv1connect.LimitsServiceClient = (*stubDepositLimitsClient)(nil)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// activeSavingsAccount returns a minimal SavingsAccount with all required fields.
func activeSavingsAccount() *savingsmodels.SavingsAccount {
	sa := &savingsmodels.SavingsAccount{
		BankID:            "bank-1",
		OwnerID:           "owner-1",
		CurrencyCode:      "KES",
		Status:            int32(savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_ACTIVE),
		LedgerAccountID:   "ledger-acct-1",
		PaymentAccountRef: "pay-ref-1",
	}
	sa.GenID(context.Background())
	return sa
}

func buildDepositBusiness(
	depRepo repository.DepositRepository,
	saRepo repository.SavingsAccountRepository,
	sbRepo repository.SavingsBalanceRepository,
	opsCli operationsv1connect.OperationsServiceClient,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsEnabled bool,
) *depositBusiness {
	return &depositBusiness{
		eventsMan:         &noopDepositEventsManager{},
		depRepo:           depRepo,
		saRepo:            saRepo,
		sbRepo:            sbRepo,
		operationsCli:     opsCli,
		auditWriter:       nil,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsEnabled,
	}
}

func defaultTransferOpsClient() *stubDepositOperationsClient {
	return &stubDepositOperationsClient{
		transferResp: &operationsv1.TransferOrderExecuteResponse{
			Data: &operationsv1.TransferOrderObject{Id: "txn-deposit-1"},
		},
	}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

// TestDepositRecord_EmptyIdempotencyKey_Rejected verifies that Record returns
// CodeInvalidArgument when the idempotency key is empty and the gate is enabled.
func TestDepositRecord_EmptyIdempotencyKey_Rejected(t *testing.T) {
	sa := activeSavingsAccount()
	depRepo := &stubDepositRepo{findErr: errors.New("not found")}
	saRepo := &stubSavingsAccountRepo{account: sa}
	sbRepo := &stubSavingsBalanceRepo{}
	limitsCli := &stubDepositLimitsClient{}

	b := buildDepositBusiness(depRepo, saRepo, sbRepo, nil, limitsCli, true)

	result, err := b.Record(context.Background(),
		sa.GetID(), "100", "pay-ref", "MOBILE", "payer-ref", "")
	require.Error(t, err)
	assert.Nil(t, result)

	var connectErr *connect.Error
	require.ErrorAs(t, err, &connectErr)
	assert.Equal(t, connect.CodeInvalidArgument, connectErr.Code())
	assert.Equal(t, 0, limitsCli.reserveCalls, "gate must not be reached when key is empty")
}

// TestDepositRecord_GateDisabled verifies that when limitsGateEnabled=false
// the Record method runs without touching the limits client.
func TestDepositRecord_GateDisabled(t *testing.T) {
	sa := activeSavingsAccount()
	depRepo := &stubDepositRepo{findErr: errors.New("not found")}
	saRepo := &stubSavingsAccountRepo{account: sa}
	sbRepo := &stubSavingsBalanceRepo{}
	limitsCli := &stubDepositLimitsClient{}

	b := buildDepositBusiness(depRepo, saRepo, sbRepo, defaultTransferOpsClient(), limitsCli, false)

	result, err := b.Record(context.Background(),
		sa.GetID(), "100", "pay-ref", "MOBILE", "payer-ref", "idem-disabled")
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, 0, limitsCli.reserveCalls, "gate must not be called when disabled")
}

// TestDepositRecord_GateAllowed verifies that when Reserve returns ACTIVE
// the deposit is created and Commit is called.
func TestDepositRecord_GateAllowed(t *testing.T) {
	sa := activeSavingsAccount()
	depRepo := &stubDepositRepo{findErr: errors.New("not found")}
	saRepo := &stubSavingsAccountRepo{account: sa}
	sbRepo := &stubSavingsBalanceRepo{}
	limitsCli := &stubDepositLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-deposit-allowed",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
			},
		},
	}

	b := buildDepositBusiness(depRepo, saRepo, sbRepo, defaultTransferOpsClient(), limitsCli, true)

	result, err := b.Record(context.Background(),
		sa.GetID(), "100", "pay-ref", "MOBILE", "payer-ref", "idem-allowed")
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 1, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}

// TestDepositRecord_GateDenied verifies that when Reserve returns an error
// (DENY path), Record returns an error and the deposit is not executed.
func TestDepositRecord_GateDenied(t *testing.T) {
	sa := activeSavingsAccount()
	depRepo := &stubDepositRepo{findErr: errors.New("not found")}
	saRepo := &stubSavingsAccountRepo{account: sa}
	sbRepo := &stubSavingsBalanceRepo{}
	limitsCli := &stubDepositLimitsClient{
		reserveErr: connect.NewError(connect.CodeFailedPrecondition, errors.New("limit breached")),
	}
	opsCli := &stubDepositOperationsClient{} // must not be called

	b := buildDepositBusiness(depRepo, saRepo, sbRepo, opsCli, limitsCli, true)

	result, err := b.Record(context.Background(),
		sa.GetID(), "100", "pay-ref", "MOBILE", "payer-ref", "idem-denied")
	require.Error(t, err)
	assert.Nil(t, result)
	assert.Contains(t, err.Error(), "limit breached")
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
}

// TestDepositRecord_GatePending verifies that when Reserve returns PENDING_APPROVAL,
// Record returns a PendingApprovalError and the deposit is not executed.
func TestDepositRecord_GatePending(t *testing.T) {
	sa := activeSavingsAccount()
	depRepo := &stubDepositRepo{findErr: errors.New("not found")}
	saRepo := &stubSavingsAccountRepo{account: sa}
	sbRepo := &stubSavingsBalanceRepo{}
	limitsCli := &stubDepositLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-deposit-pending",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
			},
		},
	}
	opsCli := &stubDepositOperationsClient{} // must not be called

	b := buildDepositBusiness(depRepo, saRepo, sbRepo, opsCli, limitsCli, true)

	result, err := b.Record(context.Background(),
		sa.GetID(), "100", "pay-ref", "MOBILE", "payer-ref", "idem-pending")
	require.Error(t, err)
	assert.Nil(t, result)

	var pendingErr *limits.PendingApprovalError
	require.ErrorAs(t, err, &pendingErr)
	assert.Equal(t, "res-deposit-pending", pendingErr.ReservationID)

	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}
