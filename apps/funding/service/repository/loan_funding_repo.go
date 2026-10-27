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
	"errors"
	"fmt"

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// ErrReservationMissing is returned when a funding's tranche records more
// capital reserved than its investor account holds: giving it back would
// free capital committed to another loan, so the void is refused for review.
var ErrReservationMissing = errors.New("investor account holds less reserved capital than the tranche records")

// LoanFundingRepository provides data access for loan fundings.
type LoanFundingRepository interface {
	datastore.BaseRepository[*models.LoanFunding]
	GetByLoanRequestID(ctx context.Context, loanRequestID string) ([]*models.LoanFunding, error)
	// VoidAndRelease voids an active funding record and, in the same
	// transaction, gives back the capital its reserved tranches hold and
	// voids the tranches. It reports whether this call voided it: a funding
	// someone else voided first is left alone, so each reservation is given
	// back once, and a crash leaves either all of it done or none of it.
	VoidAndRelease(ctx context.Context, fundingID string) (bool, error)
}

// NewLoanFundingRepository creates a new LoanFundingRepository.
func NewLoanFundingRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) LoanFundingRepository {
	return &loanFundingRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.LoanFunding {
			return &models.LoanFunding{}
		}),
	}
}

type loanFundingRepository struct {
	datastore.BaseRepository[*models.LoanFunding]
}

func (r *loanFundingRepository) GetByLoanRequestID(
	ctx context.Context,
	loanRequestID string,
) ([]*models.LoanFunding, error) {
	var fundings []*models.LoanFunding
	err := r.Pool().DB(ctx, true).Where("loan_request_id = ?", loanRequestID).Find(&fundings).Error
	return fundings, err
}

func (r *loanFundingRepository) VoidAndRelease(ctx context.Context, fundingID string) (bool, error) {
	won := false
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		voided := tx.Exec(`UPDATE loan_fundings SET state = ?, modified_at = now(), version = version + 1
WHERE id = ? AND state = ? AND deleted_at IS NULL`,
			int32(constants.StateInactive), fundingID, int32(constants.StateActive))
		if voided.Error != nil || voided.RowsAffected == 0 {
			return voided.Error
		}
		won = true

		// A tranche is active only once its capital is reserved (see
		// FundingTrancheRepository.ReserveAndActivate), so exactly the
		// active investor tranches hold a reservation to give back.
		var reserved []*models.FundingTranche
		if err := tx.Where("loan_funding_id = ? AND state = ? AND investor_account_id <> ''",
			fundingID, int32(constants.StateActive)).Find(&reserved).Error; err != nil {
			return err
		}
		for _, t := range reserved {
			released := tx.Exec(`UPDATE investor_accounts
SET reserved_balance = reserved_balance - ?, modified_at = now(), version = version + 1
WHERE id = ? AND deleted_at IS NULL AND reserved_balance >= ?`, t.Amount, t.InvestorAccountID, t.Amount)
			if released.Error != nil {
				return released.Error
			}
			if released.RowsAffected == 0 {
				return fmt.Errorf("release %d reserved on investor account %s: %w",
					t.Amount, t.InvestorAccountID, ErrReservationMissing)
			}
		}
		return tx.Exec(`UPDATE funding_tranches SET state = ?, modified_at = now(), version = version + 1
WHERE loan_funding_id = ? AND deleted_at IS NULL`, int32(constants.StateInactive), fundingID).Error
	})
	if err != nil {
		return false, err
	}
	return won, nil
}
