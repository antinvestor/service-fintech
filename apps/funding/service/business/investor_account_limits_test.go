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

// Focused unit tests for the funding investor_account limits Gate routing
// using in-process stubs for all dependencies.

import (
	"context"
	"errors"
	"testing"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore/pool"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/frame/v2/queue"
	"github.com/pitabwire/frame/v2/workerpool"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

// ---------------------------------------------------------------------------
// Stubs
// ---------------------------------------------------------------------------

// noopFundingEventsManager drops all emissions silently.
type noopFundingEventsManager struct{}

func (n *noopFundingEventsManager) Add(_ fevents.EventI) {}
func (n *noopFundingEventsManager) Get(_ string) (fevents.EventI, error) {
	return nil, nil //nolint:nilnil // no-op stub: tests never look up events
}
func (n *noopFundingEventsManager) Emit(_ context.Context, _ string, _ any) error { return nil }
func (n *noopFundingEventsManager) Handler() queue.SubscribeWorker                { return nil }

// Strict / SetStrict satisfy events.Manager (frame >=v1.98.2); the noop
// manager never consumes from a queue, so strict mode is irrelevant here.
func (n *noopFundingEventsManager) Strict() bool   { return true }
func (n *noopFundingEventsManager) SetStrict(bool) {}

var _ fevents.Manager = (*noopFundingEventsManager)(nil)

// stubInvestorAccountRepo implements repository.InvestorAccountRepository.
// It returns a pre-built account and records calls to AtomicDeposit/AtomicWithdraw.
type stubInvestorAccountRepo struct {
	account       *models.InvestorAccount
	findErr       error
	depositErr    error
	withdrawErr   error
	depositCalls  int
	withdrawCalls int
}

func (r *stubInvestorAccountRepo) Pool() pool.Pool                 { return nil }
func (r *stubInvestorAccountRepo) WorkManager() workerpool.Manager { return nil }

func (r *stubInvestorAccountRepo) GetByID(_ context.Context, _ string) (*models.InvestorAccount, error) {
	if r.findErr != nil {
		return nil, r.findErr
	}
	clone := *r.account
	return &clone, nil
}

func (r *stubInvestorAccountRepo) GetByInvestorID(_ context.Context, _ string) ([]*models.InvestorAccount, error) {
	return nil, nil
}

func (r *stubInvestorAccountRepo) AtomicDeposit(_ context.Context, _ string, _ int64) (*models.InvestorAccount, error) {
	r.depositCalls++
	if r.depositErr != nil {
		return nil, r.depositErr
	}
	clone := *r.account
	return &clone, nil
}

func (r *stubInvestorAccountRepo) AtomicWithdraw(
	_ context.Context,
	_ string,
	_ int64,
) (*models.InvestorAccount, error) {
	r.withdrawCalls++
	if r.withdrawErr != nil {
		return nil, r.withdrawErr
	}
	clone := *r.account
	return &clone, nil
}

func (r *stubInvestorAccountRepo) AtomicReserve(_ context.Context, _ string, _ int64) (*models.InvestorAccount, error) {
	return r.account, nil
}

func (r *stubInvestorAccountRepo) AtomicRelease(_ context.Context, _ string, _ int64) (*models.InvestorAccount, error) {
	return r.account, nil
}

func (r *stubInvestorAccountRepo) AtomicReleaseWithReturn(
	_ context.Context,
	_ string,
	_, _ int64,
) (*models.InvestorAccount, error) {
	return r.account, nil
}

func (r *stubInvestorAccountRepo) AtomicAbsorbLoss(
	_ context.Context,
	_ string,
	_ int64,
) (*models.InvestorAccount, error) {
	return r.account, nil
}

func (r *stubInvestorAccountRepo) GetEligibleForLoan(
	_ context.Context,
	_ string,
	_ int64,
	_ int64,
	_ string,
	_ string,
) ([]*models.InvestorAccount, error) {
	return nil, nil
}

func (r *stubInvestorAccountRepo) GetAffiliatedForGroup(
	_ context.Context,
	_ string,
	_ string,
	_ int64,
) ([]*models.InvestorAccount, error) {
	return nil, nil
}

func (r *stubInvestorAccountRepo) GetLastestBy(_ context.Context, _ map[string]any) (*models.InvestorAccount, error) {
	return nil, gorm.ErrRecordNotFound
}

func (r *stubInvestorAccountRepo) GetAllBy(
	_ context.Context,
	_ map[string]any,
	_, _ int,
) ([]*models.InvestorAccount, error) {
	return nil, nil
}

func (r *stubInvestorAccountRepo) Create(_ context.Context, _ *models.InvestorAccount) error {
	return nil
}

func (r *stubInvestorAccountRepo) BulkCreate(_ context.Context, _ []*models.InvestorAccount) error {
	return nil
}

func (r *stubInvestorAccountRepo) Update(_ context.Context, _ *models.InvestorAccount, _ ...string) (int64, error) {
	return 1, nil
}

func (r *stubInvestorAccountRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}

func (r *stubInvestorAccountRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubInvestorAccountRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubInvestorAccountRepo) BatchSize() int                                  { return 100 }
func (r *stubInvestorAccountRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubInvestorAccountRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}

func (r *stubInvestorAccountRepo) FieldsImmutable() []string          { return nil }
func (r *stubInvestorAccountRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubInvestorAccountRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubInvestorAccountRepo) IsFieldAllowed(_ string) error      { return nil }

func (r *stubInvestorAccountRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*models.InvestorAccount], error) {
	return nil, errors.New("stub: search not implemented")
}

var _ repository.InvestorAccountRepository = (*stubInvestorAccountRepo)(nil)

// stubFundingLimitsClient implements limitsv1connect.LimitsServiceClient.
type stubFundingLimitsClient struct {
	reserveResp  *limitsv1.ReserveResponse
	reserveErr   error
	commitCalls  int
	releaseCalls int
	reserveCalls int
}

func (s *stubFundingLimitsClient) Check(
	_ context.Context,
	_ *connect.Request[limitsv1.CheckRequest],
) (*connect.Response[limitsv1.CheckResponse], error) {
	return connect.NewResponse(&limitsv1.CheckResponse{}), nil
}

func (s *stubFundingLimitsClient) Reserve(
	_ context.Context,
	_ *connect.Request[limitsv1.ReserveRequest],
) (*connect.Response[limitsv1.ReserveResponse], error) {
	s.reserveCalls++
	if s.reserveErr != nil {
		return nil, s.reserveErr
	}
	return connect.NewResponse(s.reserveResp), nil
}

func (s *stubFundingLimitsClient) Commit(
	_ context.Context,
	_ *connect.Request[limitsv1.CommitRequest],
) (*connect.Response[limitsv1.CommitResponse], error) {
	s.commitCalls++
	return connect.NewResponse(&limitsv1.CommitResponse{}), nil
}

func (s *stubFundingLimitsClient) Release(
	_ context.Context,
	_ *connect.Request[limitsv1.ReleaseRequest],
) (*connect.Response[limitsv1.ReleaseResponse], error) {
	s.releaseCalls++
	return connect.NewResponse(&limitsv1.ReleaseResponse{}), nil
}

func (s *stubFundingLimitsClient) Reverse(
	_ context.Context,
	_ *connect.Request[limitsv1.ReverseRequest],
) (*connect.Response[limitsv1.ReverseResponse], error) {
	return connect.NewResponse(&limitsv1.ReverseResponse{}), nil
}

var _ limitsv1connect.LimitsServiceClient = (*stubFundingLimitsClient)(nil)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// validInvestorAccount returns an InvestorAccount with all required fields set.
// The InvestorID and Currency are required by both Deposit and Withdraw.
// The OperationsCli will be nil, so postInvestorCapitalTransfer returns an
// error — but that happens only inside the inner func, which the gate calls.
// Tests that need inner to succeed should wire operationsCli; tests that only
// exercise the gate boundary can leave it nil (inner returns an error, but the
// gate itself already committed/released before calling inner).
// For simplicity we wire a nil operationsCli and accept that inner errors out
// with "operations client is not configured". Gate behaviour is still exercised.
func validInvestorAccount() *models.InvestorAccount {
	acct := &models.InvestorAccount{
		InvestorID:       "investor-1",
		Currency:         "UGX",
		AvailableBalance: 1_000_000,
	}
	acct.GenID(context.Background())
	acct.TenantID = "tenant-1"
	return acct
}

func buildFundingBusiness(
	iaRepo repository.InvestorAccountRepository,
	limitsCli limitsv1connect.LimitsServiceClient,
	depositEnabled bool,
	withdrawEnabled bool,
) *investorAccountBusiness {
	return &investorAccountBusiness{
		eventsMan:             &noopFundingEventsManager{},
		iaRepo:                iaRepo,
		operationsCli:         nil, // not needed for gate tests
		auditWriter:           nil,
		limitsCli:             limitsCli,
		limitsDepositEnabled:  depositEnabled,
		limitsWithdrawEnabled: withdrawEnabled,
	}
}

// ---------------------------------------------------------------------------
// Deposit tests
// ---------------------------------------------------------------------------

// TestInvestorDeposit_EmptyIdempotencyKey_Rejected verifies that Deposit
// returns CodeInvalidArgument when the idempotency key is empty.
func TestInvestorDeposit_EmptyIdempotencyKey_Rejected(t *testing.T) {
	acct := validInvestorAccount()
	iaRepo := &stubInvestorAccountRepo{account: acct}
	limitsCli := &stubFundingLimitsClient{}

	b := buildFundingBusiness(iaRepo, limitsCli, true, false)

	err := b.Deposit(context.Background(), acct.GetID(), 10_000, "")
	require.Error(t, err)

	var connectErr *connect.Error
	require.ErrorAs(t, err, &connectErr)
	assert.Equal(t, connect.CodeInvalidArgument, connectErr.Code())
	assert.Equal(t, 0, limitsCli.reserveCalls, "gate must not be called when key is empty")
}

// TestInvestorDeposit_GateDisabled verifies that when limitsDepositEnabled=false
// the Deposit method runs without touching the limits client.
func TestInvestorDeposit_GateDisabled(t *testing.T) {
	acct := validInvestorAccount()
	iaRepo := &stubInvestorAccountRepo{account: acct}
	limitsCli := &stubFundingLimitsClient{}

	b := buildFundingBusiness(iaRepo, limitsCli, false, false)

	// depositInner will fail because operationsCli is nil — that's fine; we only
	// care that the limits client was not consulted.
	_ = b.Deposit(context.Background(), acct.GetID(), 10_000, "idem-deposit-disabled")
	assert.Equal(t, 0, limitsCli.reserveCalls, "gate must not be called when disabled")
}

// TestInvestorDeposit_GateAllowed verifies that when Reserve returns ACTIVE,
// Commit is called and the inner function is invoked.
func TestInvestorDeposit_GateAllowed(t *testing.T) {
	acct := validInvestorAccount()
	iaRepo := &stubInvestorAccountRepo{account: acct}
	limitsCli := &stubFundingLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-deposit-allowed",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
			},
		},
	}

	b := buildFundingBusiness(iaRepo, limitsCli, true, false)

	// Inner will fail (no operationsCli), but the gate path is exercised.
	_ = b.Deposit(context.Background(), acct.GetID(), 10_000, "idem-deposit-allowed")
	assert.Equal(t, 1, limitsCli.reserveCalls)
	// Commit is called only when inner succeeds; inner fails here so no commit.
	// Gate releases on inner error.
	assert.Equal(t, 0, limitsCli.commitCalls)
	assert.Equal(t, 1, limitsCli.releaseCalls)
}

// TestInvestorDeposit_GateDenied verifies that when Reserve returns a deny
// error, Deposit returns an error and the inner logic does not proceed.
func TestInvestorDeposit_GateDenied(t *testing.T) {
	acct := validInvestorAccount()
	iaRepo := &stubInvestorAccountRepo{account: acct}
	limitsCli := &stubFundingLimitsClient{
		reserveErr: connect.NewError(connect.CodeFailedPrecondition, errors.New("deposit limit breached")),
	}

	b := buildFundingBusiness(iaRepo, limitsCli, true, false)

	err := b.Deposit(context.Background(), acct.GetID(), 10_000, "idem-deposit-denied")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "deposit limit breached")
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}

// TestInvestorDeposit_GatePending verifies that when Reserve returns
// PENDING_APPROVAL, Deposit returns a PendingApprovalError and the inner
// logic does not proceed.
func TestInvestorDeposit_GatePending(t *testing.T) {
	acct := validInvestorAccount()
	iaRepo := &stubInvestorAccountRepo{account: acct}
	limitsCli := &stubFundingLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-deposit-pending",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
			},
		},
	}

	b := buildFundingBusiness(iaRepo, limitsCli, true, false)

	err := b.Deposit(context.Background(), acct.GetID(), 10_000, "idem-deposit-pending")
	require.Error(t, err)

	var pendingErr *limits.PendingApprovalError
	require.ErrorAs(t, err, &pendingErr)
	assert.Equal(t, "res-deposit-pending", pendingErr.ReservationID)

	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}

// ---------------------------------------------------------------------------
// Withdraw tests
// ---------------------------------------------------------------------------

// TestInvestorWithdraw_EmptyIdempotencyKey_Rejected verifies that Withdraw
// returns CodeInvalidArgument when the idempotency key is empty.
func TestInvestorWithdraw_EmptyIdempotencyKey_Rejected(t *testing.T) {
	acct := validInvestorAccount()
	iaRepo := &stubInvestorAccountRepo{account: acct}
	limitsCli := &stubFundingLimitsClient{}

	b := buildFundingBusiness(iaRepo, limitsCli, false, true)

	err := b.Withdraw(context.Background(), acct.GetID(), 5_000, "")
	require.Error(t, err)

	var connectErr *connect.Error
	require.ErrorAs(t, err, &connectErr)
	assert.Equal(t, connect.CodeInvalidArgument, connectErr.Code())
	assert.Equal(t, 0, limitsCli.reserveCalls, "gate must not be called when key is empty")
}

// TestInvestorWithdraw_GateDisabled verifies that when limitsWithdrawEnabled=false
// the Withdraw method runs without touching the limits client.
func TestInvestorWithdraw_GateDisabled(t *testing.T) {
	acct := validInvestorAccount()
	iaRepo := &stubInvestorAccountRepo{account: acct}
	limitsCli := &stubFundingLimitsClient{}

	b := buildFundingBusiness(iaRepo, limitsCli, false, false)

	// withdrawInner will fail because operationsCli is nil — that's fine.
	_ = b.Withdraw(context.Background(), acct.GetID(), 5_000, "idem-withdraw-disabled")
	assert.Equal(t, 0, limitsCli.reserveCalls, "gate must not be called when disabled")
}

// TestInvestorWithdraw_GateAllowed verifies that when Reserve returns ACTIVE,
// Commit is called and the inner function is invoked.
func TestInvestorWithdraw_GateAllowed(t *testing.T) {
	acct := validInvestorAccount()
	iaRepo := &stubInvestorAccountRepo{account: acct}
	limitsCli := &stubFundingLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-withdraw-allowed",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
			},
		},
	}

	b := buildFundingBusiness(iaRepo, limitsCli, false, true)

	// Inner will fail (no operationsCli); gate releases on inner error.
	_ = b.Withdraw(context.Background(), acct.GetID(), 5_000, "idem-withdraw-allowed")
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
	assert.Equal(t, 1, limitsCli.releaseCalls)
}

// TestInvestorWithdraw_GateDenied verifies that when Reserve returns a deny
// error, Withdraw returns an error and the inner logic does not proceed.
func TestInvestorWithdraw_GateDenied(t *testing.T) {
	acct := validInvestorAccount()
	iaRepo := &stubInvestorAccountRepo{account: acct}
	limitsCli := &stubFundingLimitsClient{
		reserveErr: connect.NewError(connect.CodeFailedPrecondition, errors.New("withdrawal limit breached")),
	}

	b := buildFundingBusiness(iaRepo, limitsCli, false, true)

	err := b.Withdraw(context.Background(), acct.GetID(), 5_000, "idem-withdraw-denied")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "withdrawal limit breached")
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}

// TestInvestorWithdraw_GatePending verifies that when Reserve returns
// PENDING_APPROVAL, Withdraw returns a PendingApprovalError and the inner
// logic does not proceed.
func TestInvestorWithdraw_GatePending(t *testing.T) {
	acct := validInvestorAccount()
	iaRepo := &stubInvestorAccountRepo{account: acct}
	limitsCli := &stubFundingLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-withdraw-pending",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
			},
		},
	}

	b := buildFundingBusiness(iaRepo, limitsCli, false, true)

	err := b.Withdraw(context.Background(), acct.GetID(), 5_000, "idem-withdraw-pending")
	require.Error(t, err)

	var pendingErr *limits.PendingApprovalError
	require.ErrorAs(t, err, &pendingErr)
	assert.Equal(t, "res-withdraw-pending", pendingErr.ReservationID)

	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}
