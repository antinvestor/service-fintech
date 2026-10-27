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
	"fmt"

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// FundingTrancheRepository provides data access for funding tranches.
type FundingTrancheRepository interface {
	datastore.BaseRepository[*models.FundingTranche]
	GetByLoanFundingID(ctx context.Context, loanFundingID string) ([]*models.FundingTranche, error)
	GetByLoanRequestID(ctx context.Context, loanRequestID string) ([]*models.FundingTranche, error)
	// ReserveAndActivate reserves a pending tranche's capital on its investor
	// account and marks the tranche active, in one transaction: an active
	// investor tranche always holds its reservation and a pending one never
	// does. It returns ErrInvestorInsufficientFunds when the account cannot
	// cover the amount, and changes nothing then.
	ReserveAndActivate(ctx context.Context, tranche *models.FundingTranche) error
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

func (r *fundingTrancheRepository) ReserveAndActivate(ctx context.Context, tranche *models.FundingTranche) error {
	return r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		activated := tx.Exec(`UPDATE funding_tranches SET state = ?, modified_at = now(), version = version + 1
WHERE id = ? AND state = ? AND deleted_at IS NULL`,
			int32(constants.StateActive), tranche.GetID(), int32(constants.StateJustCreated))
		if activated.Error != nil {
			return activated.Error
		}
		if activated.RowsAffected == 0 {
			return fmt.Errorf("tranche %s is no longer pending", tranche.GetID())
		}
		reserved := tx.Exec(`UPDATE investor_accounts
SET reserved_balance = reserved_balance + ?, total_deployed = total_deployed + ?,
    last_deployed_at = now(), modified_at = now(), version = version + 1
WHERE id = ? AND deleted_at IS NULL AND (available_balance - reserved_balance) >= ?`,
			tranche.Amount, tranche.Amount, tranche.InvestorAccountID, tranche.Amount)
		if reserved.Error != nil {
			return reserved.Error
		}
		if reserved.RowsAffected == 0 {
			return ErrInvestorInsufficientFunds
		}
		tranche.State = int32(constants.StateActive)
		return nil
	})
}
