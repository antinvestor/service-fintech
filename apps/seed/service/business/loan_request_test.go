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

package business_test

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/seed/service/business"
	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/apps/seed/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

const (
	testClientID  = "client-1"
	testProfileID = "profile-1"
	testCurrency  = "KES"
	testProductID = "seed"
	testAmount    = int64(5000)
)

type fakeLoanRequestRepo struct {
	repository.LoanRequestRepository

	rows map[string]*models.LoanRequest
}

func newFakeLoanRequestRepo() *fakeLoanRequestRepo {
	return &fakeLoanRequestRepo{rows: map[string]*models.LoanRequest{}}
}

func (r *fakeLoanRequestRepo) GetByID(_ context.Context, id string) (*models.LoanRequest, error) {
	if row, ok := r.rows[id]; ok {
		return row, nil
	}
	return nil, gorm.ErrRecordNotFound
}

func (r *fakeLoanRequestRepo) Create(_ context.Context, entity *models.LoanRequest) error {
	r.rows[entity.GetID()] = entity
	return nil
}

func (r *fakeLoanRequestRepo) Update(
	_ context.Context,
	entity *models.LoanRequest,
	_ ...string,
) (int64, error) {
	r.rows[entity.GetID()] = entity
	return 1, nil
}

func (r *fakeLoanRequestRepo) GetByIdempotencyKey(
	_ context.Context,
	key string,
) (*models.LoanRequest, error) {
	for _, row := range r.rows {
		if row.IdempotencyKey == key && key != "" {
			return row, nil
		}
	}
	return nil, repository.ErrLoanRequestNotFound
}

func (r *fakeLoanRequestRepo) GetUnconfirmedDisbursement(
	_ context.Context,
	clientID, currencyCode string,
) (*models.LoanRequest, error) {
	for _, row := range r.rows {
		if row.ClientID == clientID && row.CurrencyCode == currencyCode &&
			row.Status == int32(models.LoanRequestStatusDisbursementUnconfirmed) {
			return row, nil
		}
	}
	return nil, repository.ErrLoanRequestNotFound
}

type fakeCreditProfileRepo struct {
	repository.CreditProfileRepository

	slotTaken bool
	released  int
	borrowed  int64
}

func (r *fakeCreditProfileRepo) AtomicReserveLoanSlot(_ context.Context, _ string) (bool, error) {
	if r.slotTaken {
		return false, nil
	}
	r.slotTaken = true
	return true, nil
}

func (r *fakeCreditProfileRepo) AtomicReleaseLoanSlot(_ context.Context, _ string) error {
	r.released++
	r.slotTaken = false
	return nil
}

func (r *fakeCreditProfileRepo) AtomicRecordBorrowedAmount(
	_ context.Context,
	_ string,
	amount int64,
) (*models.CreditProfile, error) {
	r.borrowed += amount
	return &models.CreditProfile{}, nil
}

// fakeCreditTierRepo stands in for the ladder repository, which RequestLoan
// never reaches: tier evaluation goes through the credit profile business.
type fakeCreditTierRepo struct {
	repository.CreditTierRepository
}

type fakeCreditProfileBusiness struct{}

func (fakeCreditProfileBusiness) EnsureProfile(
	_ context.Context,
	clientID, currencyCode, productID string,
) (*models.CreditProfile, error) {
	profile := &models.CreditProfile{
		ClientID:      clientID,
		CurrencyCode:  currencyCode,
		ProductID:     productID,
		Status:        int32(models.CreditProfileStatusActive),
		Tier:          1,
		MaxLoanAmount: 100000,
	}
	profile.ID = testProfileID
	return profile, nil
}

func (f fakeCreditProfileBusiness) GetProfile(
	ctx context.Context,
	clientID, currencyCode string,
) (*models.CreditProfile, error) {
	return f.EnsureProfile(ctx, clientID, currencyCode, testProductID)
}

func (fakeCreditProfileBusiness) EvaluateTier(
	_ context.Context,
	_ *models.CreditProfile,
) (*models.CreditTierConfig, error) {
	return &models.CreditTierConfig{Tier: 1, InterestRate: 1200, TermDays: 30}, nil
}

func (fakeCreditProfileBusiness) SetTempCap(
	_ context.Context,
	clientID, currencyCode string,
	_ int64,
	_ time.Time,
	_, _ string,
	_ bool,
) (*models.CreditProfile, error) {
	return &models.CreditProfile{ClientID: clientID, CurrencyCode: currencyCode}, nil
}

func (fakeCreditProfileBusiness) SetStatus(
	_ context.Context,
	clientID, currencyCode string,
	status models.CreditProfileStatus,
	_ string,
) (*models.CreditProfile, error) {
	return &models.CreditProfile{ClientID: clientID, CurrencyCode: currencyCode, Status: int32(status)}, nil
}

func (f fakeCreditProfileBusiness) RecordSuccessfulRepayment(
	ctx context.Context,
	clientID, currencyCode string,
	_ int64,
	_ string,
) (*models.CreditProfile, error) {
	return f.EnsureProfile(ctx, clientID, currencyCode, testProductID)
}

type fakeKYC struct {
	status business.KYCStatus
}

func (f *fakeKYC) VerifyClient(_ context.Context, _ string) (business.KYCStatus, error) {
	return f.status, nil
}

type fakeLoanCreator struct {
	foundID  string
	found    bool
	findErr  error
	findCall int
}

func (c *fakeLoanCreator) CreateApplication(
	_ context.Context,
	_ business.LoanCreationRequest,
) (string, error) {
	return "application-1", nil
}

func (c *fakeLoanCreator) CreateLoanAccount(_ context.Context, _ string) (string, error) {
	return "loan-account-1", nil
}

func (c *fakeLoanCreator) Disburse(_ context.Context, _ string, key string) (string, error) {
	return "disbursement-for-" + key, nil
}

func (c *fakeLoanCreator) FindDisbursement(
	_ context.Context,
	_ string,
	_ string,
) (string, bool, error) {
	c.findCall++
	return c.foundID, c.found, c.findErr
}

type testHarness struct {
	lrRepo   *fakeLoanRequestRepo
	cpRepo   *fakeCreditProfileRepo
	kyc      *fakeKYC
	creator  *fakeLoanCreator
	business business.LoanRequestBusiness
}

func newHarness(kycStatus business.KYCStatus, creator *fakeLoanCreator) *testHarness {
	h := &testHarness{
		lrRepo:  newFakeLoanRequestRepo(),
		cpRepo:  &fakeCreditProfileRepo{},
		kyc:     &fakeKYC{status: kycStatus},
		creator: creator,
	}
	h.business = business.NewLoanRequestBusiness(
		context.Background(),
		fakeCreditProfileBusiness{},
		h.cpRepo,
		h.lrRepo,
		&fakeCreditTierRepo{},
		h.kyc,
		h.creator,
		audit.NewWriter(nil),
	)
	return h
}

func stuckRequest() *models.LoanRequest {
	stuck := &models.LoanRequest{
		ClientID:        testClientID,
		CreditProfileID: testProfileID,
		ProductID:       testProductID,
		Amount:          testAmount,
		CurrencyCode:    testCurrency,
		Status:          int32(models.LoanRequestStatusDisbursementUnconfirmed),
		LoanAccountID:   "loan-account-1",
		IdempotencyKey:  "stuck-key",
	}
	stuck.ID = "lr-stuck"
	return stuck
}

func loanInput(key string) business.RequestLoanInput {
	return business.RequestLoanInput{
		ClientID:       testClientID,
		ProductID:      testProductID,
		Amount:         testAmount,
		CurrencyCode:   testCurrency,
		IdempotencyKey: key,
		ActorID:        "actor-1",
		ActorType:      "user",
	}
}

func TestRequestLoanReconcilesUnconfirmedDisbursement(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name         string
		creator      *fakeLoanCreator
		wantStatus   models.LoanRequestStatus
		wantReleased int
		wantBorrowed int64
	}{
		{
			name:         "disbursement exists so the slot stays reserved",
			creator:      &fakeLoanCreator{foundID: "disbursement-9", found: true},
			wantStatus:   models.LoanRequestStatusDisbursed,
			wantReleased: 0,
			wantBorrowed: testAmount,
		},
		{
			name:         "disbursement never happened so the slot is released",
			creator:      &fakeLoanCreator{},
			wantStatus:   models.LoanRequestStatusFailed,
			wantReleased: 1,
			wantBorrowed: 0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			ctx := context.Background()
			h := newHarness(business.KYCStatusPending, tt.creator)
			h.cpRepo.slotTaken = true
			stuck := stuckRequest()
			h.lrRepo.rows[stuck.GetID()] = stuck

			// KYC is pending, so the new request stops at eligibility; the
			// reconciliation of the prior request has already run by then.
			if _, err := h.business.RequestLoan(ctx, loanInput("new-key")); err == nil {
				t.Fatal("expected the pending-KYC request to be refused")
			}

			if h.creator.findCall != 1 {
				t.Fatalf("FindDisbursement called %d times, want 1", h.creator.findCall)
			}
			settled := h.lrRepo.rows[stuck.GetID()]
			if models.LoanRequestStatus(settled.Status) != tt.wantStatus {
				t.Errorf("stuck request status = %d, want %d", settled.Status, tt.wantStatus)
			}
			if h.cpRepo.released != tt.wantReleased {
				t.Errorf("slot released %d times, want %d", h.cpRepo.released, tt.wantReleased)
			}
			if h.cpRepo.borrowed != tt.wantBorrowed {
				t.Errorf("borrowed total = %d, want %d", h.cpRepo.borrowed, tt.wantBorrowed)
			}
		})
	}
}

func TestRequestLoanEligibilityFailureDoesNotConsumeTheKey(t *testing.T) {
	t.Parallel()

	ctx := context.Background()
	h := newHarness(business.KYCStatusPending, &fakeLoanCreator{})

	failed, err := h.business.RequestLoan(ctx, loanInput("retryable-key"))
	if !errors.Is(err, business.ErrClientNotKYCVerified) {
		t.Fatalf("first attempt error = %v, want ErrClientNotKYCVerified", err)
	}
	if !strings.HasPrefix(failed.IdempotencyKey, "failed:") {
		t.Fatalf("failure row parked under key %q, want a failed: prefix", failed.IdempotencyKey)
	}
	if _, lookupErr := h.lrRepo.GetByIdempotencyKey(ctx, "retryable-key"); lookupErr == nil {
		t.Fatal("the customer's idempotency key is still consumed after an eligibility failure")
	}

	h.kyc.status = business.KYCStatusVerified
	retried, retryErr := h.business.RequestLoan(ctx, loanInput("retryable-key"))
	if retryErr != nil {
		t.Fatalf("retry error = %v, want nil", retryErr)
	}
	if models.LoanRequestStatus(retried.Status) != models.LoanRequestStatusDisbursed {
		t.Errorf("retry status = %d, want disbursed", retried.Status)
	}
}

func TestRequestLoanStoredFailureIsNotASuccess(t *testing.T) {
	t.Parallel()

	ctx := context.Background()
	h := newHarness(business.KYCStatusVerified, &fakeLoanCreator{})
	stored := &models.LoanRequest{
		ClientID:       testClientID,
		CurrencyCode:   testCurrency,
		Status:         int32(models.LoanRequestStatusFailed),
		IdempotencyKey: "stored-key",
	}
	stored.ID = "lr-stored"
	h.lrRepo.rows[stored.GetID()] = stored

	row, err := h.business.RequestLoan(ctx, loanInput("stored-key"))
	if row == nil {
		t.Fatal("expected the stored row to be returned alongside the error")
	}
	var appErr *apperrors.Error
	if !errors.As(err, &appErr) {
		t.Fatalf("error = %v, want an *apperrors.Error", err)
	}
	if appErr.ErrorCode() != apperrors.Unprocessable {
		t.Errorf("error code = %d, want %d", appErr.ErrorCode(), apperrors.Unprocessable)
	}
}
