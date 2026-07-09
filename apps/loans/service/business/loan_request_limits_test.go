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

// Note: these are focused unit tests that exercise Approve/Gate routing using
// in-process stubs for all dependencies.

import (
	"context"
	"errors"
	"testing"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
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

// stubLoanRequestRepo implements repository.LoanRequestRepository.
type stubLoanRequestRepo struct {
	request *loansmodels.LoanRequest
	err     error
}

func (r *stubLoanRequestRepo) Pool() pool.Pool                 { return nil }
func (r *stubLoanRequestRepo) WorkManager() workerpool.Manager { return nil }
func (r *stubLoanRequestRepo) GetByID(_ context.Context, _ string) (*loansmodels.LoanRequest, error) {
	return r.request, r.err
}
func (r *stubLoanRequestRepo) GetLastestBy(_ context.Context, _ map[string]any) (*loansmodels.LoanRequest, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubLoanRequestRepo) GetAllBy(
	_ context.Context,
	_ map[string]any,
	_, _ int,
) ([]*loansmodels.LoanRequest, error) {
	return nil, nil
}
func (r *stubLoanRequestRepo) Create(_ context.Context, _ *loansmodels.LoanRequest) error {
	return nil
}
func (r *stubLoanRequestRepo) BulkCreate(_ context.Context, _ []*loansmodels.LoanRequest) error {
	return nil
}
func (r *stubLoanRequestRepo) Update(_ context.Context, _ *loansmodels.LoanRequest, _ ...string) (int64, error) {
	return 1, nil
}
func (r *stubLoanRequestRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubLoanRequestRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubLoanRequestRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubLoanRequestRepo) BatchSize() int                                  { return 100 }
func (r *stubLoanRequestRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubLoanRequestRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubLoanRequestRepo) FieldsImmutable() []string          { return nil }
func (r *stubLoanRequestRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubLoanRequestRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubLoanRequestRepo) IsFieldAllowed(_ string) error      { return nil }
func (r *stubLoanRequestRepo) GetByIdempotencyKey(_ context.Context, _ string) (*loansmodels.LoanRequest, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubLoanRequestRepo) GetByLoanAccountID(_ context.Context, _ string) (*loansmodels.LoanRequest, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubLoanRequestRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*loansmodels.LoanRequest], error) {
	return nil, errors.New("stub: search not implemented")
}

// Compile-time checks.
var _ repository.LoanRequestRepository = (*stubLoanRequestRepo)(nil)
var _ datastore.BaseRepository[*loansmodels.LoanRequest] = (*stubLoanRequestRepo)(nil)

// stubLoanProductRepo implements repository.LoanProductRepository — returns not found.
type stubLoanProductRepo struct{}

func (r *stubLoanProductRepo) Pool() pool.Pool                 { return nil }
func (r *stubLoanProductRepo) WorkManager() workerpool.Manager { return nil }
func (r *stubLoanProductRepo) GetByCode(_ context.Context, _ string) (*loansmodels.LoanProduct, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubLoanProductRepo) GetByID(_ context.Context, _ string) (*loansmodels.LoanProduct, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubLoanProductRepo) GetLastestBy(_ context.Context, _ map[string]any) (*loansmodels.LoanProduct, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubLoanProductRepo) GetAllBy(
	_ context.Context,
	_ map[string]any,
	_, _ int,
) ([]*loansmodels.LoanProduct, error) {
	return nil, nil
}
func (r *stubLoanProductRepo) Create(_ context.Context, _ *loansmodels.LoanProduct) error {
	return nil
}
func (r *stubLoanProductRepo) BulkCreate(_ context.Context, _ []*loansmodels.LoanProduct) error {
	return nil
}
func (r *stubLoanProductRepo) Update(_ context.Context, _ *loansmodels.LoanProduct, _ ...string) (int64, error) {
	return 1, nil
}
func (r *stubLoanProductRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubLoanProductRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubLoanProductRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubLoanProductRepo) BatchSize() int                                  { return 100 }
func (r *stubLoanProductRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubLoanProductRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubLoanProductRepo) FieldsImmutable() []string          { return nil }
func (r *stubLoanProductRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubLoanProductRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubLoanProductRepo) IsFieldAllowed(_ string) error      { return nil }
func (r *stubLoanProductRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*loansmodels.LoanProduct], error) {
	return nil, errors.New("stub: search not implemented")
}

// Compile-time checks.
var _ repository.LoanProductRepository = (*stubLoanProductRepo)(nil)
var _ datastore.BaseRepository[*loansmodels.LoanProduct] = (*stubLoanProductRepo)(nil)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// submittedLoanRequest returns a minimal LoanRequest in SUBMITTED state.
func submittedLoanRequest() *loansmodels.LoanRequest {
	lr := &loansmodels.LoanRequest{
		ClientID:        "client-lr-1",
		OrganizationID:  "org-lr-1",
		CurrencyCode:    "KES",
		RequestedAmount: 50000,
		Status:          int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED),
	}
	lr.GenID(context.Background())
	return lr
}

// buildLRBusiness constructs a loanRequestBusiness with the supplied stubs.
func buildLRBusiness(
	lrRepo repository.LoanRequestRepository,
	lpRepo repository.LoanProductRepository,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsEnabled bool,
) *loanRequestBusiness {
	return &loanRequestBusiness{
		eventsMan:         &noopEventsManager{},
		loanRequestRepo:   lrRepo,
		loanProductRepo:   lpRepo,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsEnabled,
	}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

// TestApprove_GateDisabled_BehavesAsBefore verifies that when
// limitsGateEnabled=false the Approve method calls approveInner directly
// (bypasses Gate entirely) and returns an approved loan request.
func TestApprove_GateDisabled_BehavesAsBefore(t *testing.T) {
	lr := submittedLoanRequest()
	lrRepo := &stubLoanRequestRepo{request: lr}
	lpRepo := &stubLoanProductRepo{}

	b := buildLRBusiness(lrRepo, lpRepo, nil, false)

	result, err := b.Approve(context.Background(), lr.GetID())
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED, result.GetStatus())
}

// TestApprove_GateAllowed verifies that when the limits stub returns ACTIVE,
// approveInner is executed and the loan request is approved.
func TestApprove_GateAllowed(t *testing.T) {
	lr := submittedLoanRequest()
	lrRepo := &stubLoanRequestRepo{request: lr}
	lpRepo := &stubLoanProductRepo{}
	limitsCli := &stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-lr-allowed",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
			},
		},
	}

	b := buildLRBusiness(lrRepo, lpRepo, limitsCli, true)

	result, err := b.Approve(context.Background(), lr.GetID())
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED, result.GetStatus())
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 1, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}

// TestApprove_GateDenied verifies that when Reserve returns an error
// (e.g. FailedPrecondition), Approve returns an error and the loan request
// is not approved.
func TestApprove_GateDenied(t *testing.T) {
	lr := submittedLoanRequest()
	lrRepo := &stubLoanRequestRepo{request: lr}
	lpRepo := &stubLoanProductRepo{}
	limitsCli := &stubLimitsClient{
		reserveErr: connect.NewError(connect.CodeFailedPrecondition, errors.New("lr limit breached")),
	}

	b := buildLRBusiness(lrRepo, lpRepo, limitsCli, true)

	result, err := b.Approve(context.Background(), lr.GetID())
	require.Error(t, err)
	assert.Nil(t, result)
	assert.Contains(t, err.Error(), "lr limit breached")
	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
}

// TestApprove_GatePending verifies that when Reserve returns PENDING_APPROVAL,
// Approve returns a wrapped PendingApprovalError and the handler is not called.
func TestApprove_GatePending(t *testing.T) {
	lr := submittedLoanRequest()
	lrRepo := &stubLoanRequestRepo{request: lr}
	lpRepo := &stubLoanProductRepo{}
	limitsCli := &stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{
			Reservation: &limitsv1.ReservationObject{
				Id:     "res-lr-pending",
				Status: limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
			},
		},
	}

	b := buildLRBusiness(lrRepo, lpRepo, limitsCli, true)

	result, err := b.Approve(context.Background(), lr.GetID())
	require.Error(t, err)
	assert.Nil(t, result)

	var pendingErr *limits.PendingApprovalError
	require.ErrorAs(t, err, &pendingErr)
	assert.Equal(t, "res-lr-pending", pendingErr.ReservationID)

	assert.Equal(t, 1, limitsCli.reserveCalls)
	assert.Equal(t, 0, limitsCli.commitCalls)
	assert.Equal(t, 0, limitsCli.releaseCalls)
}
