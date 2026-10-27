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

// Note: these are focused unit tests that exercise Record/Gate routing using
// in-process stubs for all dependencies.

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3/security"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	moneyx "github.com/pitabwire/util/moneyx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// ---------------------------------------------------------------------------
// Stubs
// ---------------------------------------------------------------------------

// stubRepaymentRepo implements repository.RepaymentRepository.
type stubRepaymentRepo struct {
	findResp *loansmodels.Repayment
	findErr  error
}

func (r *stubRepaymentRepo) Pool() pool.Pool                 { return nil }
func (r *stubRepaymentRepo) WorkManager() workerpool.Manager { return nil }
func (r *stubRepaymentRepo) GetByID(_ context.Context, _ string) (*loansmodels.Repayment, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubRepaymentRepo) GetLastestBy(_ context.Context, _ map[string]any) (*loansmodels.Repayment, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubRepaymentRepo) GetAllBy(
	_ context.Context,
	_ map[string]any,
	_, _ int,
) ([]*loansmodels.Repayment, error) {
	return nil, nil
}
func (r *stubRepaymentRepo) Create(_ context.Context, _ *loansmodels.Repayment) error { return nil }
func (r *stubRepaymentRepo) BulkCreate(_ context.Context, _ []*loansmodels.Repayment) error {
	return nil
}
func (r *stubRepaymentRepo) Update(_ context.Context, _ *loansmodels.Repayment, _ ...string) (int64, error) {
	return 1, nil
}
func (r *stubRepaymentRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubRepaymentRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubRepaymentRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubRepaymentRepo) BatchSize() int                                  { return 100 }
func (r *stubRepaymentRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubRepaymentRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubRepaymentRepo) FieldsImmutable() []string          { return nil }
func (r *stubRepaymentRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubRepaymentRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubRepaymentRepo) IsFieldAllowed(_ string) error      { return nil }
func (r *stubRepaymentRepo) GetByIdempotencyKey(_ context.Context, _ string) (*loansmodels.Repayment, error) {
	return r.findResp, r.findErr
}
func (r *stubRepaymentRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*loansmodels.Repayment], error) {
	return nil, errors.New("stub: search not implemented")
}

// Compile-time checks.
func (r *stubRepaymentRepo) ClaimIdempotencyKey(
	ctx context.Context,
	rep *loansmodels.Repayment,
) (*loansmodels.Repayment, bool, error) {
	if err := r.Create(ctx, rep); err != nil {
		return nil, false, err
	}
	return rep, true, nil
}

func (r *stubRepaymentRepo) UpdateColumns(_ context.Context, _ string, _ map[string]any) (int64, error) {
	return 1, nil
}

func (r *stubRepaymentRepo) ListByLoanAccountID(
	_ context.Context,
	_ string,
	_ int,
) ([]*loansmodels.Repayment, error) {
	return nil, nil
}

var _ repository.RepaymentRepository = (*stubRepaymentRepo)(nil)
var _ datastore.BaseRepository[*loansmodels.Repayment] = (*stubRepaymentRepo)(nil)

// stubRepaymentScheduleRepo implements repository.RepaymentScheduleRepository.
type stubRepaymentScheduleRepo struct{}

func (r *stubRepaymentScheduleRepo) Pool() pool.Pool                 { return nil }
func (r *stubRepaymentScheduleRepo) WorkManager() workerpool.Manager { return nil }
func (r *stubRepaymentScheduleRepo) GetByID(_ context.Context, _ string) (*loansmodels.RepaymentSchedule, error) {
	return nil, errors.New("stub: not found")
}

func (r *stubRepaymentScheduleRepo) GetLastestBy(
	_ context.Context,
	_ map[string]any,
) (*loansmodels.RepaymentSchedule, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubRepaymentScheduleRepo) GetAllBy(
	_ context.Context,
	_ map[string]any,
	_, _ int,
) ([]*loansmodels.RepaymentSchedule, error) {
	return nil, nil
}
func (r *stubRepaymentScheduleRepo) Create(_ context.Context, _ *loansmodels.RepaymentSchedule) error {
	return nil
}
func (r *stubRepaymentScheduleRepo) BulkCreate(_ context.Context, _ []*loansmodels.RepaymentSchedule) error {
	return nil
}

func (r *stubRepaymentScheduleRepo) Update(
	_ context.Context,
	_ *loansmodels.RepaymentSchedule,
	_ ...string,
) (int64, error) {
	return 1, nil
}
func (r *stubRepaymentScheduleRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubRepaymentScheduleRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubRepaymentScheduleRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubRepaymentScheduleRepo) BatchSize() int                                  { return 100 }
func (r *stubRepaymentScheduleRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubRepaymentScheduleRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubRepaymentScheduleRepo) FieldsImmutable() []string          { return nil }
func (r *stubRepaymentScheduleRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubRepaymentScheduleRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubRepaymentScheduleRepo) IsFieldAllowed(_ string) error      { return nil }

func (r *stubRepaymentScheduleRepo) KeepLatestActive(context.Context, string) error { return nil }

func (r *stubRepaymentScheduleRepo) GetActivByLoanAccountID(
	_ context.Context,
	_ string,
) (*loansmodels.RepaymentSchedule, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubRepaymentScheduleRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*loansmodels.RepaymentSchedule], error) {
	return nil, errors.New("stub: search not implemented")
}

// Compile-time check.
var _ repository.RepaymentScheduleRepository = (*stubRepaymentScheduleRepo)(nil)
var _ datastore.BaseRepository[*loansmodels.RepaymentSchedule] = (*stubRepaymentScheduleRepo)(nil)

// stubScheduleEntryRepo implements repository.ScheduleEntryRepository.
type stubScheduleEntryRepo struct{}

func (r *stubScheduleEntryRepo) Pool() pool.Pool                 { return nil }
func (r *stubScheduleEntryRepo) WorkManager() workerpool.Manager { return nil }
func (r *stubScheduleEntryRepo) GetByID(_ context.Context, _ string) (*loansmodels.ScheduleEntry, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubScheduleEntryRepo) GetLastestBy(_ context.Context, _ map[string]any) (*loansmodels.ScheduleEntry, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubScheduleEntryRepo) GetAllBy(
	_ context.Context,
	_ map[string]any,
	_, _ int,
) ([]*loansmodels.ScheduleEntry, error) {
	return nil, nil
}
func (r *stubScheduleEntryRepo) Create(_ context.Context, _ *loansmodels.ScheduleEntry) error {
	return nil
}
func (r *stubScheduleEntryRepo) BulkCreate(_ context.Context, _ []*loansmodels.ScheduleEntry) error {
	return nil
}
func (r *stubScheduleEntryRepo) Update(_ context.Context, _ *loansmodels.ScheduleEntry, _ ...string) (int64, error) {
	return 1, nil
}
func (r *stubScheduleEntryRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubScheduleEntryRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubScheduleEntryRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubScheduleEntryRepo) BatchSize() int                                  { return 100 }
func (r *stubScheduleEntryRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubScheduleEntryRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubScheduleEntryRepo) FieldsImmutable() []string          { return nil }
func (r *stubScheduleEntryRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubScheduleEntryRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubScheduleEntryRepo) IsFieldAllowed(_ string) error      { return nil }
func (r *stubScheduleEntryRepo) GetByScheduleID(_ context.Context, _ string) ([]*loansmodels.ScheduleEntry, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubScheduleEntryRepo) GetByLoanAccountID(_ context.Context, _ string) ([]*loansmodels.ScheduleEntry, error) {
	return nil, errors.New("stub: not found")
}

func (r *stubScheduleEntryRepo) GetOverdueEntries(
	_ context.Context,
	_ string,
	_ time.Time,
) ([]*loansmodels.ScheduleEntry, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubScheduleEntryRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*loansmodels.ScheduleEntry], error) {
	return nil, errors.New("stub: search not implemented")
}

// Compile-time check.
func (r *stubScheduleEntryRepo) MarkPenaltyApplied(_ context.Context, _ string) (bool, error) {
	return true, nil
}

func (r *stubScheduleEntryRepo) ClearPenaltyApplied(_ context.Context, _ string) error { return nil }

func (r *stubScheduleEntryRepo) ListDueBetween(
	_ context.Context,
	_, _ time.Time,
	_ string,
	_ int,
) ([]*loansmodels.ScheduleEntry, error) {
	return nil, nil
}

func (r *stubScheduleEntryRepo) MarkReminded(_ context.Context, _, _ string) (bool, error) {
	return true, nil
}

func (r *stubScheduleEntryRepo) CountActiveEntries(_ context.Context, _ string) (int64, error) {
	return 1, nil
}

var _ repository.ScheduleEntryRepository = (*stubScheduleEntryRepo)(nil)
var _ datastore.BaseRepository[*loansmodels.ScheduleEntry] = (*stubScheduleEntryRepo)(nil)

// stubLoanBalanceRepo implements repository.LoanBalanceRepository.
type stubLoanBalanceRepo struct{}

func (r *stubLoanBalanceRepo) Pool() pool.Pool                 { return nil }
func (r *stubLoanBalanceRepo) WorkManager() workerpool.Manager { return nil }
func (r *stubLoanBalanceRepo) GetByID(_ context.Context, _ string) (*loansmodels.LoanBalance, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubLoanBalanceRepo) GetLastestBy(_ context.Context, _ map[string]any) (*loansmodels.LoanBalance, error) {
	return nil, errors.New("stub: not found")
}
func (r *stubLoanBalanceRepo) GetAllBy(
	_ context.Context,
	_ map[string]any,
	_, _ int,
) ([]*loansmodels.LoanBalance, error) {
	return nil, nil
}
func (r *stubLoanBalanceRepo) Create(_ context.Context, _ *loansmodels.LoanBalance) error { return nil }
func (r *stubLoanBalanceRepo) BulkCreate(_ context.Context, _ []*loansmodels.LoanBalance) error {
	return nil
}
func (r *stubLoanBalanceRepo) Update(_ context.Context, _ *loansmodels.LoanBalance, _ ...string) (int64, error) {
	return 1, nil
}
func (r *stubLoanBalanceRepo) BulkUpdate(_ context.Context, _ []string, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubLoanBalanceRepo) Delete(_ context.Context, _ string) error        { return nil }
func (r *stubLoanBalanceRepo) DeleteBatch(_ context.Context, _ []string) error { return nil }
func (r *stubLoanBalanceRepo) BatchSize() int                                  { return 100 }
func (r *stubLoanBalanceRepo) Count(_ context.Context) (int64, error)          { return 0, nil }
func (r *stubLoanBalanceRepo) CountBy(_ context.Context, _ map[string]any) (int64, error) {
	return 0, nil
}
func (r *stubLoanBalanceRepo) FieldsImmutable() []string          { return nil }
func (r *stubLoanBalanceRepo) FieldsAllowed() map[string]struct{} { return nil }
func (r *stubLoanBalanceRepo) ExtendFieldsAllowed(_ ...string)    {}
func (r *stubLoanBalanceRepo) IsFieldAllowed(_ string) error      { return nil }
func (r *stubLoanBalanceRepo) GetByLoanAccountID(
	_ context.Context,
	loanAccountID string,
) (*loansmodels.LoanBalance, error) {
	return &loansmodels.LoanBalance{
		LoanAccountID:        loanAccountID,
		CurrencyCode:         "KES",
		PrincipalOutstanding: 100000,
		TotalOutstanding:     100000,
	}, nil
}

func (r *stubLoanBalanceRepo) ApplyRepaymentDelta(
	ctx context.Context,
	loanAccountID string,
	delta repository.LoanBalanceDelta,
) (*loansmodels.LoanBalance, error) {
	balance, err := r.GetByLoanAccountID(ctx, loanAccountID)
	if err != nil {
		return nil, err
	}
	balance.PrincipalOutstanding -= delta.PrincipalApplied
	balance.TotalPaid += delta.Total()
	balance.TotalOutstanding -= delta.Total()
	return balance, nil
}
func (r *stubLoanBalanceRepo) Search(
	_ context.Context,
	_ *data.SearchQuery,
) (workerpool.JobResultPipe[[]*loansmodels.LoanBalance], error) {
	return nil, errors.New("stub: search not implemented")
}

// Compile-time check.
func (r *stubLoanBalanceRepo) ApplyPenaltyDelta(
	ctx context.Context,
	loanAccountID string,
	_ int64,
) (*loansmodels.LoanBalance, error) {
	return r.GetByLoanAccountID(ctx, loanAccountID)
}

var _ repository.LoanBalanceRepository = (*stubLoanBalanceRepo)(nil)
var _ datastore.BaseRepository[*loansmodels.LoanBalance] = (*stubLoanBalanceRepo)(nil)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// activeLoanAccountForRepayment returns a minimal LoanAccount in ACTIVE state.
func activeLoanAccountForRepayment() *loansmodels.LoanAccount {
	la := &loansmodels.LoanAccount{
		ClientID:       "client-rep-1",
		OrganizationID: "org-rep-1",
		CurrencyCode:   "KES",
		Status:         int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE),
	}
	la.GenID(context.Background())
	return la
}

// buildRepBusiness constructs a repaymentBusiness with the supplied stubs.
func buildRepBusiness(
	laRepo repository.LoanAccountRepository,
	repRepo repository.RepaymentRepository,
	opsCli operationsv1connect.OperationsServiceClient,
) *repaymentBusiness {
	b := &repaymentBusiness{
		eventsMan:         &noopEventsManager{},
		loanAccountRepo:   laRepo,
		repaymentRepo:     repRepo,
		scheduleRepo:      &stubRepaymentScheduleRepo{},
		scheduleEntryRepo: &stubScheduleEntryRepo{},
		loanBalanceRepo:   &stubLoanBalanceRepo{},
		notifier:          nil,
		operationsCli:     opsCli,
		auditWriter:       nil,
		paidOffHook:       nil,
	}
	b.applier = &stubRepaymentApplier{b: b}
	return b
}

// stubRepaymentApplier applies a repayment once per id through whatever
// balance repository the business holds when it is called.
type stubRepaymentApplier struct {
	b       *repaymentBusiness
	applied map[string]bool
}

func (a *stubRepaymentApplier) Apply(
	ctx context.Context,
	repaymentID, loanAccountID string,
	_ []repository.EntryAllocation,
	delta repository.LoanBalanceDelta,
) (bool, *loansmodels.LoanBalance, error) {
	if a.applied == nil {
		a.applied = map[string]bool{}
	}
	if a.applied[repaymentID] {
		balance, err := a.b.loanBalanceRepo.GetByLoanAccountID(ctx, loanAccountID)
		return false, balance, err
	}
	a.applied[repaymentID] = true
	balance, err := a.b.loanBalanceRepo.ApplyRepaymentDelta(ctx, loanAccountID, delta)
	return true, balance, err
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

// TestRecord_EmptyIdempotencyKey_Rejected verifies that Record returns
// CodeInvalidArgument when the idempotency key is absent.
func TestRecord_EmptyIdempotencyKey_Rejected(t *testing.T) {
	la := activeLoanAccountForRepayment()
	laRepo := &stubLoanAccountRepo{account: la}
	repRepo := &stubRepaymentRepo{findErr: errors.New("not found")}

	b := buildRepBusiness(laRepo, repRepo, nil)

	result, err := b.Record(paymentRailContext(), &loansv1.RepaymentRecordRequest{
		LoanAccountId: la.GetID(),
		Amount:        moneyx.FromMinorUnitsByCurrency("KES", 5000),
		// IdempotencyKey intentionally omitted
	})
	require.Error(t, err)
	assert.Nil(t, result)

	assert.Equal(t, connect.CodeInvalidArgument, apperrors.CleanErr(err).Code())
}

// TestRecord_AppliesReceivedMoneyWithoutALimitsCheck verifies that a
// repayment is applied with no transaction-limit reservation: the money has
// already arrived on the rail, and refusing it would only strand it.
func TestRecord_AppliesReceivedMoneyWithoutALimitsCheck(t *testing.T) {
	la := activeLoanAccountForRepayment()
	laRepo := &stubLoanAccountRepo{account: la}
	repRepo := &stubRepaymentRepo{findErr: errors.New("not found")}
	opsCli := &stubOperationsClient{
		transferResp: &operationsv1.TransferOrderExecuteResponse{
			Data: &operationsv1.TransferOrderObject{Id: "txn-rep-1"},
		},
	}

	b := buildRepBusiness(laRepo, repRepo, opsCli)

	result, err := b.Record(paymentRailContext(), &loansv1.RepaymentRecordRequest{
		LoanAccountId:  la.GetID(),
		IdempotencyKey: "idem-rep-received",
		Amount:         moneyx.FromMinorUnitsByCurrency("KES", 5000),
	})
	require.NoError(t, err)
	assert.NotNil(t, result)
}

func (r *stubRepaymentRepo) ClaimFundingUnsettled(context.Context, int, int) ([]*loansmodels.Repayment, error) {
	return nil, nil
}

func (r *stubRepaymentRepo) MarkFundingSettled(context.Context, string, string) error { return nil }

func (r *stubScheduleEntryRepo) ClaimReminders(
	context.Context, repository.ReminderKind, time.Time, time.Time, int,
) ([]*loansmodels.ScheduleEntry, error) {
	return nil, nil
}

// paymentRailContext is the payment rail calling RepaymentRecord: an internal
// service account, the only caller that may apply a repayment.
func paymentRailContext() context.Context {
	return (&security.AuthenticationClaims{
		Roles:            []string{security.ConstantSystemInternalRole},
		RegisteredClaims: jwt.RegisteredClaims{Subject: "service-operations"},
	}).ClaimsToContext(context.Background())
}
