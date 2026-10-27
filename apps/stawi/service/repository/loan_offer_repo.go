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

package repository

import (
	"context"
	"time"

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// LoanOfferRepository provides data access for loan offers.
type LoanOfferRepository interface {
	datastore.BaseRepository[*models.LoanOffer]
	// GetByLoanWindowID lists the offers made in a window.
	GetByLoanWindowID(ctx context.Context, loanWindowID string) ([]*models.LoanOffer, error)
	// CountOpenElsewhere counts a member's offers that are still open or
	// originating in windows other than exceptWindowID.
	CountOpenElsewhere(ctx context.Context, membershipID, exceptWindowID string) (int64, error)
	// ListPendingOrigination returns up to limit accepted offers whose loan
	// is not yet disbursed and that are not held off after a failure.
	ListPendingOrigination(ctx context.Context, now time.Time, limit int) ([]*models.LoanOffer, error)
	// ListUncancelledLoans returns up to limit failed offers whose unpaid
	// loan could not be cancelled and that are not held off after a failure.
	ListUncancelledLoans(ctx context.Context, now time.Time, limit int) ([]*models.LoanOffer, error)
	// ListExpired returns up to limit unanswered open offers whose expiry
	// is at or before now.
	ListExpired(ctx context.Context, now time.Time, limit int) ([]*models.LoanOffer, error)
}

// NewLoanOfferRepository creates a new LoanOfferRepository.
func NewLoanOfferRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) LoanOfferRepository {
	return &loanOfferRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.LoanOffer {
			return &models.LoanOffer{}
		}),
	}
}

type loanOfferRepository struct {
	datastore.BaseRepository[*models.LoanOffer]
}

func (r *loanOfferRepository) GetByLoanWindowID(
	ctx context.Context,
	loanWindowID string,
) ([]*models.LoanOffer, error) {
	var offers []*models.LoanOffer
	err := r.Pool().DB(ctx, true).Where("loan_window_id = ?", loanWindowID).Find(&offers).Error
	return offers, err
}

func (r *loanOfferRepository) CountOpenElsewhere(
	ctx context.Context,
	membershipID, exceptWindowID string,
) (int64, error) {
	var count int64
	err := r.Pool().DB(ctx, true).Model(&models.LoanOffer{}).
		Where("membership_id = ? AND loan_window_id <> ? AND state = ?",
			membershipID, exceptWindowID, constants.StateActive).
		Count(&count).Error
	return count, err
}

func (r *loanOfferRepository) ListPendingOrigination(
	ctx context.Context,
	now time.Time,
	limit int,
) ([]*models.LoanOffer, error) {
	var offers []*models.LoanOffer
	err := r.Pool().DB(ctx, true).
		Where("origination_status = ? AND (retry_at IS NULL OR retry_at <= ?)", models.OriginationPending, now).
		Order("created_at ASC").Limit(limit).Find(&offers).Error
	return offers, err
}

func (r *loanOfferRepository) ListUncancelledLoans(
	ctx context.Context,
	now time.Time,
	limit int,
) ([]*models.LoanOffer, error) {
	var offers []*models.LoanOffer
	err := r.Pool().DB(ctx, true).
		Where("origination_status = ? AND loan_account_id <> '' AND properties->>'loan_cancelled' = 'false'"+
			" AND (retry_at IS NULL OR retry_at <= ?)", models.OriginationFailed, now).
		Order("created_at ASC").Limit(limit).Find(&offers).Error
	return offers, err
}

func (r *loanOfferRepository) ListExpired(
	ctx context.Context,
	now time.Time,
	limit int,
) ([]*models.LoanOffer, error) {
	var offers []*models.LoanOffer
	err := r.Pool().DB(ctx, true).
		Where("state = ? AND response = ? AND expiry_date IS NOT NULL AND expiry_date <= ?",
			constants.StateActive, int32(models.LoanOfferResponseNone), now).
		Order("expiry_date ASC").Limit(limit).Find(&offers).Error
	return offers, err
}
