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

// Note: these are focused unit tests that exercise Create/Gate routing using
// in-process stubs for all dependencies. Full integration tests against real
// DB + operations service are planned for Task 9.

import (
	"context"
	"errors"
	"testing"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/frame/v2/queue"
	"github.com/pitabwire/frame/v2/workerpool"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

// ---------------------------------------------------------------------------
// Stubs
// ---------------------------------------------------------------------------

// noopEventsManager implements fevents.Manager and silently drops all emissions.
type noopEventsManager struct{}

func (n *noopEventsManager) Add(_ fevents.EventI) {}
func (n *noopEventsManager) Get(_ string) (fevents.EventI, error) {
	return nil, nil //nolint:nilnil // no-op stub: tests never look up events
}
func (n *noopEventsManager) Emit(_ context.Context, _ string, _ any) error { return nil }
func (n *noopEventsManager) Handler() queue.SubscribeWorker                { return nil }

// Strict / SetStrict satisfy events.Manager (frame >=v1.98.2); the noop
// manager never consumes from a queue, so strict mode is irrelevant here.
func (n *noopEventsManager) Strict() bool   { return true }
func (n *noopEventsManager) SetStrict(bool) {}

// Compile-time check.
var _ fevents.Manager = (*noopEventsManager)(nil)

// stubDisbursementRepo implements repository.DisbursementRepository.
// It records the last created disbursement for assertion.
type stubDisbursementRepo struct {
	stored   []*loansmodels.Disbursement
	findResp *loansmodels.Disbursement
	findErr  error
}

func (r *stubDisbursementRepo) Pool() pool.Pool                 { return nil }
func (r *stubDisbursementRepo) WorkManager() workerpool.Manager { return nil }
func (r *stubDisbursementRepo) GetByID(_ context.Context, _ string) (*loansmodels.Disbursement, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubDisbursementRepo) GetLastestBy(_ context.Context, _ map[string]any) (*loansmodels.Disbursement, error) {
	return nil, errors.New("stub: not found")
}

func (r *stubDisbursementRepo) GetAllBy(
	_ context.Context,
	_ map[string]any,
	_, _ int,
) ([]*loansmodels.Disbursement, error) {
	return nil, nil
}
func (r *stubDisbursementRepo) Create(_ context.Context, entity *loansmodels.Disbursement) error {
	r.stored = append(r.stored, entity)
	return nil
}
func (r *stubDisbursementRepo) BulkCreate(_ context.Context, _ []*loansmodels.Disbursement) error {
	return nil
}
func (r *stubDisbursementRepo) Update(_ context.Context, _ *loansmodels.Disbursement, _ ...string) (int64, error) {
	return 1, nil
}
func (r *stubDisbursementRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubDisbursementRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubDisbursementRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubDisbursementRepo) BatchSize() int                                  { return 100 }
func (r *stubDisbursementRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubDisbursementRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubDisbursementRepo) FieldsImmutable() []string          { return nil }
func (r *stubDisbursementRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubDisbursementRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubDisbursementRepo) IsFieldAllowed(_ string) error      { return nil }

func (r *stubDisbursementRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*loansmodels.Disbursement], error) {
	return nil, errors.New("stub: search not implemented")
}
func (r *stubDisbursementRepo) GetByIdempotencyKey(_ context.Context, _ string) (*loansmodels.Disbursement, error) {
	return r.findResp, r.findErr
}

// Compile-time checks.
var _ repository.DisbursementRepository = (*stubDisbursementRepo)(nil)
var _ datastore.BaseRepository[*loansmodels.Disbursement] = (*stubDisbursementRepo)(nil)

// stubLoanAccountRepo implements repository.LoanAccountRepository.
type stubLoanAccountRepo struct {
	account *loansmodels.LoanAccount
	err     error
}

func (r *stubLoanAccountRepo) Pool() pool.Pool                 { return nil }
func (r *stubLoanAccountRepo) WorkManager() workerpool.Manager { return nil }
func (r *stubLoanAccountRepo) GetByID(_ context.Context, _ string) (*loansmodels.LoanAccount, error) {
	return r.account, r.err
}
func (r *stubLoanAccountRepo) GetLastestBy(_ context.Context, _ map[string]any) (*loansmodels.LoanAccount, error) {
	return nil, errors.New("stub: not found")
}

func (r *stubLoanAccountRepo) GetAllBy(
	_ context.Context,
	_ map[string]any,
	_, _ int,
) ([]*loansmodels.LoanAccount, error) {
	return nil, nil
}
func (r *stubLoanAccountRepo) Create(_ context.Context, _ *loansmodels.LoanAccount) error {
	return nil
}
func (r *stubLoanAccountRepo) BulkCreate(_ context.Context, _ []*loansmodels.LoanAccount) error {
	return nil
}
func (r *stubLoanAccountRepo) Update(_ context.Context, _ *loansmodels.LoanAccount, _ ...string) (int64, error) {
	return 1, nil
}
func (r *stubLoanAccountRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubLoanAccountRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubLoanAccountRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubLoanAccountRepo) BatchSize() int                                  { return 100 }
func (r *stubLoanAccountRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubLoanAccountRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubLoanAccountRepo) FieldsImmutable() []string          { return nil }
func (r *stubLoanAccountRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubLoanAccountRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubLoanAccountRepo) IsFieldAllowed(_ string) error      { return nil }

func (r *stubLoanAccountRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*loansmodels.LoanAccount], error) {
	return nil, errors.New("stub: search not implemented")
}

// Compile-time checks.
var _ repository.LoanAccountRepository = (*stubLoanAccountRepo)(nil)
var _ datastore.BaseRepository[*loansmodels.LoanAccount] = (*stubLoanAccountRepo)(nil)

// stubLoanAccountBusiness implements LoanAccountBusiness.
type stubLoanAccountBusiness struct{}

func (s *stubLoanAccountBusiness) Create(_ context.Context, _ string) (*loansv1.LoanAccountObject, error) {
	return nil, nil //nolint:nilnil // no-op stub: disbursement tests never call this
}
func (s *stubLoanAccountBusiness) Get(_ context.Context, _ string) (*loansv1.LoanAccountObject, error) {
	return nil, nil //nolint:nilnil // no-op stub: disbursement tests never call this
}
func (s *stubLoanAccountBusiness) Search(
	_ context.Context,
	_ *loansv1.LoanAccountSearchRequest,
	_ func(context.Context, []*loansv1.LoanAccountObject) error,
) error {
	return nil
}
func (s *stubLoanAccountBusiness) GetBalance(_ context.Context, _ string) (*loansv1.LoanBalanceObject, error) {
	return nil, nil //nolint:nilnil // no-op stub: disbursement tests never call this
}

func (s *stubLoanAccountBusiness) GetStatement(
	_ context.Context,
	_ *loansv1.LoanStatementRequest,
) (*loansv1.LoanStatementResponse, error) {
	return nil, nil //nolint:nilnil // no-op stub: disbursement tests never call this
}
func (s *stubLoanAccountBusiness) TransitionStatus(
	_ context.Context, _ string, _ loansv1.LoanStatus, _, _ string,
) (*loansv1.LoanAccountObject, error) {
	return &loansv1.LoanAccountObject{}, nil
}

// Compile-time check.
var _ LoanAccountBusiness = (*stubLoanAccountBusiness)(nil)

// stubOperationsClient implements operationsv1connect.OperationsServiceClient.
// Only TransferOrderExecute is called by disbursement.go.
type stubOperationsClient struct {
	transferResp *operationsv1.TransferOrderExecuteResponse
	transferErr  error
}

func (s *stubOperationsClient) TransferOrderExecute(
	_ context.Context,
	_ *connect.Request[operationsv1.TransferOrderExecuteRequest],
) (*connect.Response[operationsv1.TransferOrderExecuteResponse], error) {
	if s.transferErr != nil {
		return nil, s.transferErr
	}
	return connect.NewResponse(s.transferResp), nil
}

func (s *stubOperationsClient) TransferOrderSearch(
	_ context.Context,
	_ *connect.Request[operationsv1.TransferOrderSearchRequest],
) (*connect.ServerStreamForClient[operationsv1.TransferOrderSearchResponse], error) {
	panic("stub: TransferOrderSearch not expected")
}

func (s *stubOperationsClient) IncomingPaymentNotify(
	_ context.Context,
	_ *connect.Request[operationsv1.IncomingPaymentNotifyRequest],
) (*connect.Response[operationsv1.IncomingPaymentNotifyResponse], error) {
	panic("stub: IncomingPaymentNotify not expected")
}

func (s *stubOperationsClient) PaymentAllocate(
	_ context.Context,
	_ *connect.Request[operationsv1.PaymentAllocateRequest],
) (*connect.Response[operationsv1.PaymentAllocateResponse], error) {
	panic("stub: PaymentAllocate not expected")
}

// Compile-time check.
var _ operationsv1connect.OperationsServiceClient = (*stubOperationsClient)(nil)

// stubLimitsClient implements limitsv1connect.LimitsServiceClient.
type stubLimitsClient struct {
	reserveResp  *limitsv1.ReserveResponse
	reserveErr   error
	commitResp   *limitsv1.CommitResponse
	commitErr    error
	releaseResp  *limitsv1.ReleaseResponse
	releaseErr   error
	reserveCalls int
	commitCalls  int
	releaseCalls int
}

func (s *stubLimitsClient) Check(
	_ context.Context,
	_ *connect.Request[limitsv1.CheckRequest],
) (*connect.Response[limitsv1.CheckResponse], error) {
	return connect.NewResponse(&limitsv1.CheckResponse{}), nil
}

func (s *stubLimitsClient) Reserve(
	_ context.Context,
	_ *connect.Request[limitsv1.ReserveRequest],
) (*connect.Response[limitsv1.ReserveResponse], error) {
	s.reserveCalls++
	if s.reserveErr != nil {
		return nil, s.reserveErr
	}
	return connect.NewResponse(s.reserveResp), nil
}

func (s *stubLimitsClient) Commit(
	_ context.Context,
	_ *connect.Request[limitsv1.CommitRequest],
) (*connect.Response[limitsv1.CommitResponse], error) {
	s.commitCalls++
	if s.commitErr != nil {
		return nil, s.commitErr
	}
	resp := s.commitResp
	if resp == nil {
		resp = &limitsv1.CommitResponse{}
	}
	return connect.NewResponse(resp), nil
}

func (s *stubLimitsClient) Release(
	_ context.Context,
	_ *connect.Request[limitsv1.ReleaseRequest],
) (*connect.Response[limitsv1.ReleaseResponse], error) {
	s.releaseCalls++
	if s.releaseErr != nil {
		return nil, s.releaseErr
	}
	resp := s.releaseResp
	if resp == nil {
		resp = &limitsv1.ReleaseResponse{}
	}
	return connect.NewResponse(resp), nil
}

func (s *stubLimitsClient) Reverse(
	_ context.Context,
	_ *connect.Request[limitsv1.ReverseRequest],
) (*connect.Response[limitsv1.ReverseResponse], error) {
	return connect.NewResponse(&limitsv1.ReverseResponse{}), nil
}

// Compile-time check.
var _ limitsv1connect.LimitsServiceClient = (*stubLimitsClient)(nil)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// pendingDisbursementLA returns a minimal LoanAccount in PENDING_DISBURSEMENT
// state with all required fields populated.
func pendingDisbursementLA() *loansmodels.LoanAccount {
	la := &loansmodels.LoanAccount{
		ClientID:             "client-1",
		OrganizationID:       "org-1",
		CurrencyCode:         "KES",
		PrincipalAmount:      100000,
		Status:               int32(loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT),
		PaymentAccountRef:    "account-ref",
		LedgerAssetAccountID: "ledger-asset-1",
		Properties: data.JSONMap{
			"funding_fully_funded": true,
		},
	}
	la.GenID(context.Background())
	return la
}

// buildDisbBusiness constructs a disbursementBusiness with the supplied stubs.
func buildDisbBusiness(
	disbRepo repository.DisbursementRepository,
	laRepo repository.LoanAccountRepository,
	opsCli operationsv1connect.OperationsServiceClient,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsEnabled bool,
) *disbursementBusiness {
	return &disbursementBusiness{
		eventsMan:         &noopEventsManager{},
		disbRepo:          disbRepo,
		loanAccountRepo:   laRepo,
		laBusiness:        &stubLoanAccountBusiness{},
		operationsCli:     opsCli,
		auditWriter:       nil,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsEnabled,
	}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

// TestCreate_EmptyIdempotencyKey_Rejected verifies that Create returns
// CodeInvalidArgument when the idempotency key is absent.
func TestCreate_EmptyIdempotencyKey_Rejected(t *testing.T) {
	la := pendingDisbursementLA()
	disbRepo := &stubDisbursementRepo{findErr: errors.New("not found")}
	laRepo := &stubLoanAccountRepo{account: la}
	limitsCli := &stubLimitsClient{}

	b := buildDisbBusiness(disbRepo, laRepo, nil, limitsCli, true)

	result, err := b.Create(context.Background(), &loansv1.DisbursementCreateRequest{
		LoanAccountId: la.GetID(),
		Channel:       "BANK",
		// IdempotencyKey intentionally omitted
	})
	require.Error(t, err)
	assert.Nil(t, result)

	var connectErr *connect.Error
	require.ErrorAs(t, err, &connectErr)
	assert.Equal(t, connect.CodeInvalidArgument, connectErr.Code())
	assert.Equal(t, 0, limitsCli.reserveCalls, "gate must not be reached when key is empty")
}

// TestCreate_GateDisabled_BehavesAsBefore verifies that when
// limitsGateEnabled=false the Create method calls createInner directly
// (bypasses Gate entirely) and returns a disbursement object.
func TestCreate_GateDisabled_BehavesAsBefore(t *testing.T) {
	la := pendingDisbursementLA()
	disbRepo := &stubDisbursementRepo{findErr: errors.New("not found")}
	laRepo := &stubLoanAccountRepo{account: la}
	opsCli := &stubOperationsClient{
		transferResp: &operationsv1.TransferOrderExecuteResponse{
			Data: &operationsv1.TransferOrderObject{Id: "txn-1"},
		},
	}

	b := buildDisbBusiness(disbRepo, laRepo, opsCli, nil, false)

	result, err := b.Create(context.Background(), &loansv1.DisbursementCreateRequest{
		LoanAccountId:  la.GetID(),
		IdempotencyKey: "idem-disabled",
		Channel:        "BANK",
	})
	require.NoError(t, err)
	assert.NotNil(t, result)
}

// TestCreate_GateAllowed verifies that when the limits stub returns ACTIVE,
// createInner is executed and the disbursement is created + committed.
func TestCreate_GateAllowed(t *testing.T) {
	la := pendingDisbursementLA()
	disbRepo := &stubDisbursementRepo{findErr: errors.New("not found")}
	laRepo := &stubLoanAccountRepo{account: la}
	opsCli := &stubOperationsClient{
		transferResp: &operationsv1.TransferOrderExecuteResponse{
			Data: &operationsv1.TransferOrderObject{Id: "txn-gate-allowed"},
		},
	}
	limitsCli := &stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-allowed",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
			},
		},
	}

	b := buildDisbBusiness(disbRepo, laRepo, opsCli, limitsCli, true)

	result, err := b.Create(context.Background(), &loansv1.DisbursementCreateRequest{
		LoanAccountId:  la.GetID(),
		IdempotencyKey: "idem-gate-allowed",
		Channel:        "BANK",
	})
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 1, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}

// TestCreate_GateDenied verifies that when Reserve returns an error
// (e.g. FailedPrecondition), Create returns an error and no disbursement
// record is created (handler not called → ops client untouched).
func TestCreate_GateDenied(t *testing.T) {
	la := pendingDisbursementLA()
	disbRepo := &stubDisbursementRepo{findErr: errors.New("not found")}
	laRepo := &stubLoanAccountRepo{account: la}
	opsCli := &stubOperationsClient{} // Should not be called.

	limitsCli := &stubLimitsClient{
		reserveErr: connect.NewError(connect.CodeFailedPrecondition, errors.New("limit breached")),
	}

	b := buildDisbBusiness(disbRepo, laRepo, opsCli, limitsCli, true)

	result, err := b.Create(context.Background(), &loansv1.DisbursementCreateRequest{
		LoanAccountId:  la.GetID(),
		IdempotencyKey: "idem-gate-denied",
		Channel:        "BANK",
	})
	require.Error(t, err)
	assert.Nil(t, result)
	assert.Contains(t, err.Error(), "limit breached")
	// Verify no disbursement row was persisted.
	assert.Empty(t, disbRepo.stored)
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
}

// TestCreate_GatePending verifies that when Reserve returns PENDING_APPROVAL,
// Create returns a wrapped PendingApprovalError and the handler is not called.
func TestCreate_GatePending(t *testing.T) {
	la := pendingDisbursementLA()
	disbRepo := &stubDisbursementRepo{findErr: errors.New("not found")}
	laRepo := &stubLoanAccountRepo{account: la}
	opsCli := &stubOperationsClient{} // Should not be called.

	limitsCli := &stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-pending",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
			},
		},
	}

	b := buildDisbBusiness(disbRepo, laRepo, opsCli, limitsCli, true)

	result, err := b.Create(context.Background(), &loansv1.DisbursementCreateRequest{
		LoanAccountId:  la.GetID(),
		IdempotencyKey: "idem-gate-pending",
		Channel:        "BANK",
	})
	require.Error(t, err)
	assert.Nil(t, result)

	// The wrapped error must contain a PendingApprovalError.
	var pendingErr *limits.PendingApprovalError
	require.ErrorAs(t, err, &pendingErr)
	assert.Equal(t, "res-pending", pendingErr.ReservationID)

	// Handler was not called so no disbursement rows persisted.
	assert.Empty(t, disbRepo.stored)
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}

// TestCreate_IdempotencyShortCircuit verifies that when the disbursement is
// already persisted (idempotency match), Create returns early without hitting
// the Gate or ops client.
func TestCreate_IdempotencyShortCircuit(t *testing.T) {
	existingDisb := &loansmodels.Disbursement{}
	existingDisb.GenID(context.Background())

	disbRepo := &stubDisbursementRepo{findResp: existingDisb, findErr: nil}
	laRepo := &stubLoanAccountRepo{}
	limitsCli := &stubLimitsClient{} // Must not be called.

	b := buildDisbBusiness(disbRepo, laRepo, nil, limitsCli, true)

	result, err := b.Create(context.Background(), &loansv1.DisbursementCreateRequest{
		LoanAccountId:  "loan-1",
		IdempotencyKey: "idem-existing",
	})
	require.NoError(t, err)
	assert.NotNil(t, result)
	// Gate not called because we short-circuited on idempotency.
	assert.Equal(t, 0, limitsCli.reserveCalls)
}
