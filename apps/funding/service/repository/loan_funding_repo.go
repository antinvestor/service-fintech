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

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// LoanFundingRepository provides data access for loan fundings.
type LoanFundingRepository interface {
	datastore.BaseRepository[*models.LoanFunding]
	GetByLoanRequestID(ctx context.Context, loanRequestID string) ([]*models.LoanFunding, error)
	// VoidAndRelease voids an active funding record and, in the same
	// transaction, gives back the capital its reserved tranches hold and
	// voids those tranches and any still pending. It reports whether this
	// call voided it: a funding someone else voided first is left alone, so
	// each reservation is given back once, and a crash leaves either all of
	// it done or none of it. A tranche whose reservation the investor account
	// no longer holds is voided without a release and flagged for
	// reconciliation; its id is returned in unreleased, so one bad tranche
	// never blocks the rest.
	VoidAndRelease(ctx context.Context, fundingID string) (won bool, unreleased []string, err error)
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

// TrancheReconcileReservationMissing flags, in a voided tranche's
// properties, a reservation its investor account no longer held when the
// tranche was voided: an operator reconciles the account.
const TrancheReconcileReservationMissing = "reservation_missing"

func (r *loanFundingRepository) VoidAndRelease(
	ctx context.Context,
	fundingID string,
) (bool, []string, error) {
	won := false
	var unreleased []string
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		won, unreleased = false, nil
		// The update holds the funding's row lock to commit, so a concurrent
		// ReserveAndActivate (which locks the same row) either finished
		// first, and its tranche is active and released here, or finds the
		// funding void and reserves nothing.
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
		if err := tx.Raw(`SELECT * FROM funding_tranches
WHERE loan_funding_id = ? AND state = ? AND investor_account_id <> '' AND deleted_at IS NULL
FOR UPDATE`, fundingID, int32(constants.StateActive)).Scan(&reserved).Error; err != nil {
			return err
		}
		for _, t := range reserved {
			given, err := releaseTranche(tx, t)
			if err != nil {
				return err
			}
			if !given {
				unreleased = append(unreleased, t.GetID())
			}
		}
		// Tranches never reserved, and active tranches with no investor
		// (group and platform sources), hold nothing to give back.
		return tx.Exec(`UPDATE funding_tranches SET state = ?, modified_at = now(), version = version + 1
WHERE loan_funding_id = ? AND deleted_at IS NULL
  AND (state = ? OR (state = ? AND investor_account_id = ''))`,
			int32(constants.StateInactive), fundingID,
			int32(constants.StateJustCreated), int32(constants.StateActive)).Error
	})
	if err != nil {
		return false, nil, err
	}
	return won, unreleased, nil
}

// releaseTranche gives back a reserved tranche's capital and voids the
// tranche, inside tx. When the investor account no longer holds the
// reservation, the tranche is voided and flagged for reconciliation instead,
// and false is returned.
func releaseTranche(tx *gorm.DB, t *models.FundingTranche) (bool, error) {
	released := tx.Exec(`UPDATE investor_accounts
SET reserved_balance = reserved_balance - ?, modified_at = now(), version = version + 1
WHERE id = ? AND deleted_at IS NULL AND reserved_balance >= ?`, t.Amount, t.InvestorAccountID, t.Amount)
	if released.Error != nil {
		return false, released.Error
	}
	if released.RowsAffected == 0 {
		return false, tx.Exec(`UPDATE funding_tranches SET state = ?, modified_at = now(), version = version + 1,
    properties = COALESCE(properties, '{}'::jsonb) || jsonb_build_object('reconcile', ?::text)
WHERE id = ? AND state = ?`, int32(constants.StateInactive), TrancheReconcileReservationMissing,
			t.GetID(), int32(constants.StateActive)).Error
	}
	return true, tx.Exec(`UPDATE funding_tranches SET state = ?, modified_at = now(), version = version + 1
WHERE id = ? AND state = ?`, int32(constants.StateInactive), t.GetID(), int32(constants.StateActive)).Error
}
