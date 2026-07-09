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

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
)

// LoanOfferRepository provides data access for loan offers.
type LoanOfferRepository interface {
	datastore.BaseRepository[*models.LoanOffer]
	GetByMembershipID(ctx context.Context, membershipID string) ([]*models.LoanOffer, error)
	GetByLoanWindowID(ctx context.Context, loanWindowID string) ([]*models.LoanOffer, error)
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

func (r *loanOfferRepository) GetByMembershipID(ctx context.Context, membershipID string) ([]*models.LoanOffer, error) {
	var offers []*models.LoanOffer
	err := r.Pool().DB(ctx, true).Where("membership_id = ?", membershipID).Find(&offers).Error
	return offers, err
}

func (r *loanOfferRepository) GetByLoanWindowID(ctx context.Context, loanWindowID string) ([]*models.LoanOffer, error) {
	var offers []*models.LoanOffer
	err := r.Pool().DB(ctx, true).Where("loan_window_id = ?", loanWindowID).Find(&offers).Error
	return offers, err
}
