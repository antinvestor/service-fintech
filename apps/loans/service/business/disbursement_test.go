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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/frame/v3/queue"
	"github.com/pitabwire/frame/v3/workerpool"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
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
	claimErr error
	updates  []map[string]any
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

func (r *stubDisbursementRepo) ClaimIdempotencyKey(
	ctx context.Context,
	disb *loansmodels.Disbursement,
) (*loansmodels.Disbursement, bool, error) {
	if r.claimErr != nil {
		return r.findResp, false, r.claimErr
	}
	if r.findResp != nil && r.findErr == nil {
		return r.findResp, false, nil
	}
	if err := r.Create(ctx, disb); err != nil {
		return nil, false, err
	}
	return disb, true, nil
}

func (r *stubDisbursementRepo) UpdateColumns(_ context.Context, _ string, values map[string]any) (int64, error) {
	r.updates = append(r.updates, values)
	for _, d := range r.stored {
		if st, ok := values[fieldStatus].(int32); ok {
			d.Status = st
		}
	}
	return 1, nil
}

func (r *stubDisbursementRepo) ListByLoanAccountID(
	_ context.Context,
	_ string,
	_ int,
) ([]*loansmodels.Disbursement, error) {
	return r.stored, nil
}

func (r *stubDisbursementRepo) GetLiveByLoanAccountID(
	_ context.Context,
	_ string,
) (*loansmodels.Disbursement, error) {
	return nil, errors.New("stub: not found")
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

func (r *stubLoanAccountRepo) GetByLoanRequestID(
	_ context.Context,
	_ string,
) (*loansmodels.LoanAccount, error) {
	return nil, errors.New("stub: not found")
}

func (r *stubLoanAccountRepo) UpdateColumns(_ context.Context, _ string, _ map[string]any) (int64, error) {
	return 1, nil
}

func (r *stubLoanAccountRepo) ClaimStatus(_ context.Context, _ string, _, _ int32) (bool, error) {
	return true, nil
}

func (r *stubLoanAccountRepo) PageByStatus(
	_ context.Context,
	_ int32,
	_ string,
	_ int,
) ([]*loansmodels.LoanAccount, error) {
	return nil, nil
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
	_ *operationsv1.TransferOrderExecuteRequest,
) (*operationsv1.TransferOrderExecuteResponse, error) {
	if s.transferErr != nil {
		return nil, s.transferErr
	}
	return s.transferResp, nil
}

func (s *stubOperationsClient) TransferOrderSearch(
	_ context.Context,
	_ *operationsv1.TransferOrderSearchRequest,
) (operationsv1connect.OperationsServiceTransferOrderSearchClientStream, error) {
	panic("stub: TransferOrderSearch not expected")
}

func (s *stubOperationsClient) IncomingPaymentNotify(
	_ context.Context,
	_ *operationsv1.IncomingPaymentNotifyRequest,
) (*operationsv1.IncomingPaymentNotifyResponse, error) {
	panic("stub: IncomingPaymentNotify not expected")
}

func (s *stubOperationsClient) PaymentAllocate(
	_ context.Context,
	_ *operationsv1.PaymentAllocateRequest,
) (*operationsv1.PaymentAllocateResponse, error) {
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
	_ *limitsv1.CheckRequest,
) (*limitsv1.CheckResponse, error) {
	return &limitsv1.CheckResponse{}, nil
}

func (s *stubLimitsClient) Reserve(
	_ context.Context,
	_ *limitsv1.ReserveRequest,
) (*limitsv1.ReserveResponse, error) {
	s.reserveCalls++
	if s.reserveErr != nil {
		return nil, s.reserveErr
	}
	return s.reserveResp, nil
}

func (s *stubLimitsClient) Commit(
	_ context.Context,
	_ *limitsv1.CommitRequest,
) (*limitsv1.CommitResponse, error) {
	s.commitCalls++
	if s.commitErr != nil {
		return nil, s.commitErr
	}
	resp := s.commitResp
	if resp == nil {
		resp = &limitsv1.CommitResponse{}
	}
	return resp, nil
}

func (s *stubLimitsClient) Release(
	_ context.Context,
	_ *limitsv1.ReleaseRequest,
) (*limitsv1.ReleaseResponse, error) {
	s.releaseCalls++
	if s.releaseErr != nil {
		return nil, s.releaseErr
	}
	resp := s.releaseResp
	if resp == nil {
		resp = &limitsv1.ReleaseResponse{}
	}
	return resp, nil
}

func (s *stubLimitsClient) Reverse(
	_ context.Context,
	_ *limitsv1.ReverseRequest,
) (*limitsv1.ReverseResponse, error) {
	return &limitsv1.ReverseResponse{}, nil
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

	assert.Equal(t, connect.CodeInvalidArgument, apperrors.CleanErr(err).Code())
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
			Data: &operationsv1.TransferOrderObject{Id: "txn-1", State: commonv1.STATE_INACTIVE},
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
			Data: &operationsv1.TransferOrderObject{Id: "txn-gate-allowed", State: commonv1.STATE_INACTIVE},
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
		reserveErr: connect.NewError(connect.CodeFailedPrecondition, "limit breached"),
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
	existingDisb := &loansmodels.Disbursement{
		LoanAccountID: "loan-1",
		Status:        int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_COMPLETED),
	}
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

// A rail error that may clear on retry leaves the row PROCESSING under its
// own key; the retry with that key resumes the same order and completes.
func TestCreate_TransientFailureKeepsProcessingAndSameKeyResumes(t *testing.T) {
	la := pendingDisbursementLA()
	disbRepo := &stubDisbursementRepo{findErr: errors.New("not found")}
	laRepo := &stubLoanAccountRepo{account: la}
	opsCli := &stubOperationsClient{
		transferErr: connect.NewError(connect.CodeUnavailable, "ledger down"),
	}
	b := buildDisbBusiness(disbRepo, laRepo, opsCli, nil, false)

	req := &loansv1.DisbursementCreateRequest{LoanAccountId: la.GetID(), IdempotencyKey: "idem-resume", Channel: "BANK"}
	_, err := b.Create(context.Background(), req)
	require.ErrorIs(t, err, ErrDisbursementNotSettled)
	require.Len(t, disbRepo.stored, 1)
	stored := disbRepo.stored[0]
	assert.Equal(t, int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_PROCESSING), stored.Status,
		"a transient failure must not mark the disbursement failed")
	assert.Equal(t, "idem-resume", stored.IdempotencyKey, "the idempotency key must never be rewritten")
	require.NotEmpty(t, disbRepo.updates)
	assert.Contains(t, disbRepo.updates[len(disbRepo.updates)-1]["failure_reason"], "ledger down")

	// Retry with the same key: the stored row is found and resumed.
	disbRepo.findResp, disbRepo.findErr = stored, nil
	opsCli.transferErr = nil
	opsCli.transferResp = &operationsv1.TransferOrderExecuteResponse{
		Data: &operationsv1.TransferOrderObject{Id: "txn-resumed", State: commonv1.STATE_INACTIVE},
	}
	result, err := b.Create(context.Background(), req)
	require.NoError(t, err)
	assert.Equal(t, loansv1.DisbursementStatus_DISBURSEMENT_STATUS_COMPLETED, result.GetStatus())
	assert.Len(t, disbRepo.stored, 1, "the resume must not create a second disbursement row")
}

// A rejection the payment path will never accept marks the row FAILED and
// keeps its key, so the same key is answered with the failure.
func TestCreate_PermanentRejectionMarksFailed(t *testing.T) {
	la := pendingDisbursementLA()
	disbRepo := &stubDisbursementRepo{findErr: errors.New("not found")}
	laRepo := &stubLoanAccountRepo{account: la}
	opsCli := &stubOperationsClient{
		transferErr: connect.NewError(connect.CodeFailedPrecondition, "order marked failed"),
	}
	b := buildDisbBusiness(disbRepo, laRepo, opsCli, nil, false)

	_, err := b.Create(context.Background(), &loansv1.DisbursementCreateRequest{
		LoanAccountId: la.GetID(), IdempotencyKey: "idem-reject", Channel: "BANK",
	})
	require.ErrorIs(t, err, ErrDisbursementRejected)
	require.Len(t, disbRepo.stored, 1)
	assert.Equal(t, int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_FAILED), disbRepo.stored[0].Status)
	assert.Equal(t, "idem-reject", disbRepo.stored[0].IdempotencyKey)
}

// An order the operations service returns in any state other than inactive
// has not moved money; it must not be recorded as completed.
func TestCreate_UnsettledOrderStateIsNotCompleted(t *testing.T) {
	la := pendingDisbursementLA()
	disbRepo := &stubDisbursementRepo{findErr: errors.New("not found")}
	laRepo := &stubLoanAccountRepo{account: la}
	opsCli := &stubOperationsClient{
		transferResp: &operationsv1.TransferOrderExecuteResponse{
			Data: &operationsv1.TransferOrderObject{Id: "txn-open", State: commonv1.STATE_CREATED},
		},
	}
	b := buildDisbBusiness(disbRepo, laRepo, opsCli, nil, false)

	_, err := b.Create(context.Background(), &loansv1.DisbursementCreateRequest{
		LoanAccountId: la.GetID(), IdempotencyKey: "idem-open", Channel: "BANK",
	})
	require.ErrorIs(t, err, ErrDisbursementNotSettled)
	assert.Equal(t, int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_PROCESSING), disbRepo.stored[0].Status)
}

// A second request with a different key for a loan that already has a live
// disbursement is refused before it reaches the payment rail.
func TestCreate_SecondKeyForLiveLoanIsRefused(t *testing.T) {
	la := pendingDisbursementLA()
	live := &loansmodels.Disbursement{LoanAccountID: la.GetID(), IdempotencyKey: "idem-first",
		Status: int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_PROCESSING)}
	live.GenID(context.Background())
	disbRepo := &stubDisbursementRepo{findErr: errors.New("not found"), findResp: live,
		claimErr: repository.ErrLiveDisbursementExists}
	laRepo := &stubLoanAccountRepo{account: la}
	opsCli := &stubOperationsClient{}
	b := buildDisbBusiness(disbRepo, laRepo, opsCli, nil, false)

	_, err := b.Create(context.Background(), &loansv1.DisbursementCreateRequest{
		LoanAccountId: la.GetID(), IdempotencyKey: "idem-second", Channel: "BANK",
	})
	require.ErrorIs(t, err, ErrDisbursementInFlight)
	assert.Empty(t, disbRepo.stored)
}

// An idempotency key already used for another loan is refused rather than
// answered with that loan's disbursement.
func TestCreate_KeyBoundToAnotherLoanIsRefused(t *testing.T) {
	la := pendingDisbursementLA()
	other := &loansmodels.Disbursement{LoanAccountID: "some-other-loan", IdempotencyKey: "idem-shared",
		Status: int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_COMPLETED)}
	other.GenID(context.Background())
	disbRepo := &stubDisbursementRepo{findResp: other}
	laRepo := &stubLoanAccountRepo{account: la}
	b := buildDisbBusiness(disbRepo, laRepo, &stubOperationsClient{}, nil, false)

	_, err := b.Create(context.Background(), &loansv1.DisbursementCreateRequest{
		LoanAccountId: la.GetID(), IdempotencyKey: "idem-shared", Channel: "BANK",
	})
	require.ErrorIs(t, err, ErrDuplicateIdempotencyKey)
}

func (r *stubLoanAccountRepo) ClaimForAssessment(context.Context, int) ([]*loansmodels.LoanAccount, error) {
	return nil, nil
}

func (r *stubLoanAccountRepo) AssessSoon(context.Context, string) error { return nil }

func (r *stubLoanAccountRepo) ClaimRepaymentLock(context.Context, string) (bool, error) {
	return true, nil
}

func (r *stubLoanAccountRepo) ReleaseRepaymentLock(context.Context, string) error { return nil }
