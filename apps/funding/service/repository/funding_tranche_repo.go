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

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
)

// FundingTrancheRepository provides data access for funding tranches.
type FundingTrancheRepository interface {
	datastore.BaseRepository[*models.FundingTranche]
	GetByLoanFundingID(ctx context.Context, loanFundingID string) ([]*models.FundingTranche, error)
	GetByLoanRequestID(ctx context.Context, loanRequestID string) ([]*models.FundingTranche, error)
}

// NewFundingTrancheRepository creates a new FundingTrancheRepository.
func NewFundingTrancheRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) FundingTrancheRepository {
	return &fundingTrancheRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.FundingTranche {
			return &models.FundingTranche{}
		}),
	}
}

type fundingTrancheRepository struct {
	datastore.BaseRepository[*models.FundingTranche]
}

func (r *fundingTrancheRepository) GetByLoanFundingID(
	ctx context.Context,
	loanFundingID string,
) ([]*models.FundingTranche, error) {
	var tranches []*models.FundingTranche
	err := r.Pool().DB(ctx, true).
		Where("loan_funding_id = ?", loanFundingID).
		Order("tranche_level ASC").
		Find(&tranches).Error
	return tranches, err
}

// GetByLoanRequestID returns all tranches for a loan request by joining through loan fundings.
func (r *fundingTrancheRepository) GetByLoanRequestID(
	ctx context.Context,
	loanRequestID string,
) ([]*models.FundingTranche, error) {
	var tranches []*models.FundingTranche
	err := r.Pool().DB(ctx, true).
		Where("loan_funding_id IN (SELECT id FROM loan_fundings WHERE loan_request_id = ?)", loanRequestID).
		Order("tranche_level ASC").
		Find(&tranches).Error
	return tranches, err
}
