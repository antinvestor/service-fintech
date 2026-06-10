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

// Focused unit tests for the stawi loan_offer limits Gate routing
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

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

// ---------------------------------------------------------------------------
// Stubs
// ---------------------------------------------------------------------------

// noopStawiEventsManager drops all emissions silently.
type noopStawiEventsManager struct{}

func (n *noopStawiEventsManager) Add(_ fevents.EventI)                          {}
func (n *noopStawiEventsManager) Get(_ string) (fevents.EventI, error)          { return nil, nil }
func (n *noopStawiEventsManager) Emit(_ context.Context, _ string, _ any) error { return nil }
func (n *noopStawiEventsManager) Handler() queue.SubscribeWorker                { return nil }

// Strict / SetStrict satisfy events.Manager (frame >=v1.98.2); the noop
// manager never consumes from a queue, so strict mode is irrelevant here.
func (n *noopStawiEventsManager) Strict() bool   { return true }
func (n *noopStawiEventsManager) SetStrict(bool) {}

var _ fevents.Manager = (*noopStawiEventsManager)(nil)

// stubLoanOfferRepo implements repository.LoanOfferRepository.
type stubLoanOfferRepo struct {
	offer   *models.LoanOffer
	findErr error
}

func (r *stubLoanOfferRepo) Pool() pool.Pool                 { return nil }
func (r *stubLoanOfferRepo) WorkManager() workerpool.Manager { return nil }

func (r *stubLoanOfferRepo) GetByID(_ context.Context, _ string) (*models.LoanOffer, error) {
	if r.findErr != nil {
		return nil, r.findErr
	}
	clone := *r.offer
	return &clone, nil
}

func (r *stubLoanOfferRepo) GetLastestBy(_ context.Context, _ map[string]any) (*models.LoanOffer, error) {
	return nil, errors.New("stub: not implemented")
}

func (r *stubLoanOfferRepo) GetAllBy(_ context.Context, _ map[string]any, _, _ int) ([]*models.LoanOffer, error) {
	return nil, nil
}

func (r *stubLoanOfferRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*models.LoanOffer], error) {
	return nil, errors.New("stub: not implemented")
}

func (r *stubLoanOfferRepo) Count(_ context.Context) (int64, error) { return 0, nil }
func (r *stubLoanOfferRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}

func (r *stubLoanOfferRepo) Create(_ context.Context, _ *models.LoanOffer) error { return nil }
func (r *stubLoanOfferRepo) BatchSize() int                                      { return 100 }
func (r *stubLoanOfferRepo) BulkCreate(_ context.Context, _ []*models.LoanOffer) error {
	return nil
}

func (r *stubLoanOfferRepo) FieldsImmutable() []string          { return nil }
func (r *stubLoanOfferRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubLoanOfferRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubLoanOfferRepo) IsFieldAllowed(_ string) error      { return nil }

func (r *stubLoanOfferRepo) Update(_ context.Context, _ *models.LoanOffer, _ ...string) (int64, error) {
	return 1, nil
}

func (r *stubLoanOfferRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}

func (r *stubLoanOfferRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubLoanOfferRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }

func (r *stubLoanOfferRepo) GetByMembershipID(_ context.Context, _ string) ([]*models.LoanOffer, error) {
	return nil, nil
}

func (r *stubLoanOfferRepo) GetByLoanWindowID(_ context.Context, _ string) ([]*models.LoanOffer, error) {
	return nil, nil
}

var _ repository.LoanOfferRepository = (*stubLoanOfferRepo)(nil)

// stubStawiLimitsClient implements limitsv1connect.LimitsServiceClient.
type stubStawiLimitsClient struct {
	reserveResp  *limitsv1.ReserveResponse
	reserveErr   error
	commitCalls  int
	releaseCalls int
	reserveCalls int
}

func (s *stubStawiLimitsClient) Check(
	_ context.Context,
	_ *connect.Request[limitsv1.CheckRequest],
) (*connect.Response[limitsv1.CheckResponse], error) {
	return connect.NewResponse(&limitsv1.CheckResponse{}), nil
}

func (s *stubStawiLimitsClient) Reserve(
	_ context.Context,
	_ *connect.Request[limitsv1.ReserveRequest],
) (*connect.Response[limitsv1.ReserveResponse], error) {
	s.reserveCalls++
	if s.reserveErr != nil {
		return nil, s.reserveErr
	}
	return connect.NewResponse(s.reserveResp), nil
}

func (s *stubStawiLimitsClient) Commit(
	_ context.Context,
	_ *connect.Request[limitsv1.CommitRequest],
) (*connect.Response[limitsv1.CommitResponse], error) {
	s.commitCalls++
	return connect.NewResponse(&limitsv1.CommitResponse{}), nil
}

func (s *stubStawiLimitsClient) Release(
	_ context.Context,
	_ *connect.Request[limitsv1.ReleaseRequest],
) (*connect.Response[limitsv1.ReleaseResponse], error) {
	s.releaseCalls++
	return connect.NewResponse(&limitsv1.ReleaseResponse{}), nil
}

func (s *stubStawiLimitsClient) Reverse(
	_ context.Context,
	_ *connect.Request[limitsv1.ReverseRequest],
) (*connect.Response[limitsv1.ReverseResponse], error) {
	return connect.NewResponse(&limitsv1.ReverseResponse{}), nil
}

var _ limitsv1connect.LimitsServiceClient = (*stubStawiLimitsClient)(nil)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// acceptedLoanOffer returns a LoanOffer with all required fields set and
// response = LoanOfferResponseAccept so createLoanAccountInner proceeds.
func acceptedLoanOffer() *models.LoanOffer {
	offer := &models.LoanOffer{
		MembershipID: "membership-1",
		LoanWindowID: "window-1",
		PeriodID:     "period-1",
		Amount:       500_000,
		Currency:     "KES",
		Response:     int32(models.LoanOfferResponseAccept),
		State:        1,
	}
	offer.GenID(context.Background())
	offer.TenantID = "tenant-1"
	return offer
}

func buildLoanOfferBusiness(
	loRepo repository.LoanOfferRepository,
	limitsCli limitsv1connect.LimitsServiceClient,
	gateEnabled bool,
) *loanOfferBusiness {
	return &loanOfferBusiness{
		eventsMan:         &noopStawiEventsManager{},
		loRepo:            loRepo,
		lwRepo:            nil,
		identityCli:       nil,
		clients:           nil, // no platform clients — createLoanFromOffer will be a no-op
		limitsCli:         limitsCli,
		limitsGateEnabled: gateEnabled,
	}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

// TestCreateLoanAccount_GateDisabled verifies that when limitsGateEnabled=false
// CreateLoanAccount runs without touching the limits client.
func TestCreateLoanAccount_GateDisabled(t *testing.T) {
	offer := acceptedLoanOffer()
	loRepo := &stubLoanOfferRepo{offer: offer}
	limitsCli := &stubStawiLimitsClient{}

	b := buildLoanOfferBusiness(loRepo, limitsCli, false)

	// Inner succeeds (no platform clients → createLoanFromOffer is a no-op).
	_, err := b.CreateLoanAccount(context.Background(), offer.GetID())
	require.NoError(t, err)
	assert.Equal(t, 0, limitsCli.reserveCalls, "gate must not be called when disabled")
}

// TestCreateLoanAccount_GateAllowed verifies that when Reserve returns ACTIVE,
// Commit is called and the inner function is invoked.
func TestCreateLoanAccount_GateAllowed(t *testing.T) {
	offer := acceptedLoanOffer()
	loRepo := &stubLoanOfferRepo{offer: offer}
	limitsCli := &stubStawiLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-loan-disburse-allowed",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
			},
		},
	}

	b := buildLoanOfferBusiness(loRepo, limitsCli, true)

	result, err := b.CreateLoanAccount(context.Background(), offer.GetID())
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, 1, limitsCli.reserveCalls)
	// Inner succeeds → Commit is called.
	assert.Equal(t, 1, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}

// TestCreateLoanAccount_GateDenied verifies that when Reserve returns a deny
// error, CreateLoanAccount returns an error and the inner logic does not proceed.
func TestCreateLoanAccount_GateDenied(t *testing.T) {
	offer := acceptedLoanOffer()
	loRepo := &stubLoanOfferRepo{offer: offer}
	limitsCli := &stubStawiLimitsClient{
		reserveErr: connect.NewError(connect.CodeFailedPrecondition, errors.New("loan disbursement limit breached")),
	}

	b := buildLoanOfferBusiness(loRepo, limitsCli, true)

	_, err := b.CreateLoanAccount(context.Background(), offer.GetID())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "loan disbursement limit breached")
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}

// TestCreateLoanAccount_GatePending verifies that when Reserve returns
// PENDING_APPROVAL, CreateLoanAccount returns a PendingApprovalError and the
// inner logic does not proceed.
func TestCreateLoanAccount_GatePending(t *testing.T) {
	offer := acceptedLoanOffer()
	loRepo := &stubLoanOfferRepo{offer: offer}
	limitsCli := &stubStawiLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-loan-disburse-pending",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
			},
		},
	}

	b := buildLoanOfferBusiness(loRepo, limitsCli, true)

	_, err := b.CreateLoanAccount(context.Background(), offer.GetID())
	require.Error(t, err)

	var pendingErr *limits.PendingApprovalError
	require.ErrorAs(t, err, &pendingErr)
	assert.Equal(t, "res-loan-disburse-pending", pendingErr.ReservationID)

	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}
