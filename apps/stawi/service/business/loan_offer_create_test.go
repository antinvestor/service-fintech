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

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore/pool"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/frame/v2/queue"
	"github.com/pitabwire/frame/v2/workerpool"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
)

// ---------------------------------------------------------------------------
// Stubs
// ---------------------------------------------------------------------------

// noopStawiEventsManager drops all emissions silently.
type noopStawiEventsManager struct{}

func (n *noopStawiEventsManager) Add(_ fevents.EventI) {}
func (n *noopStawiEventsManager) Get(_ string) (fevents.EventI, error) {
	return nil, nil //nolint:nilnil // no-op stub: tests never look up events
}
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

// originatedLoanOffer is an accepted offer whose loan account already exists.
// CreateLoanAccount short-circuits on it without a loan management client.
func originatedLoanOffer() *models.LoanOffer {
	offer := acceptedLoanOffer()
	offer.ApplicationID = "loan-request-1"
	offer.LoanAccountID = "loan-account-1"
	return offer
}

func buildLoanOfferBusiness(loRepo repository.LoanOfferRepository) *loanOfferBusiness {
	return &loanOfferBusiness{
		eventsMan: &noopStawiEventsManager{},
		loRepo:    loRepo,
	}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

// TestCreateLoanAccount_IsIdempotentOnLoanAccount verifies that a retry of the
// workflow step returns the existing loan instead of originating a second one.
func TestCreateLoanAccount_IsIdempotentOnLoanAccount(t *testing.T) {
	offer := originatedLoanOffer()
	loRepo := &stubLoanOfferRepo{offer: offer}

	b := buildLoanOfferBusiness(loRepo)

	result, err := b.CreateLoanAccount(context.Background(), offer.GetID())
	require.NoError(t, err)
	assert.Equal(t, "loan-account-1", result["loan_account_id"])
	assert.Equal(t, "loan-request-1", result["loan_request_id"])
	assert.Equal(t, true, result["idempotent"])
}

// TestCreateLoanAccount_RequiresLoanManagement verifies that a missing loans
// peer fails the step instead of reporting a loan that was never created.
func TestCreateLoanAccount_RequiresLoanManagement(t *testing.T) {
	offer := acceptedLoanOffer()
	loRepo := &stubLoanOfferRepo{offer: offer}

	b := buildLoanOfferBusiness(loRepo)

	_, err := b.CreateLoanAccount(context.Background(), offer.GetID())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "loan management service is required")
}
