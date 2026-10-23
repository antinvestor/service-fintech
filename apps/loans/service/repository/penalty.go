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
	"time"

	"github.com/pitabwire/frame/v2/data"

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

type PenaltyRepository interface {
	datastore.BaseRepository[*models.Penalty]
	UpdateColumns(ctx context.Context, id string, values map[string]any) (int64, error)
	// ClaimWaiver marks a penalty waived only if it is not already waived,
	// so the balance reversal that follows can happen exactly once.
	ClaimWaiver(ctx context.Context, id, waivedBy, reason string) (bool, error)
	// ListByLoanAccountID returns up to limit penalties of a loan in the
	// order they were charged.
	ListByLoanAccountID(ctx context.Context, loanAccountID string, limit int) ([]*models.Penalty, error)
	// ClaimForEntry inserts the penalty, or hands back the row that already
	// owns its (installment, type) slot. Reserving the slot with the insert
	// is what keeps two delinquency scans from charging one installment twice.
	ClaimForEntry(ctx context.Context, penalty *models.Penalty) (stored *models.Penalty, created bool, err error)
	// ChargeBalanceOnce charges the penalty to the loan balance and marks the
	// penalty as charged in one transaction, so a retry after a crash between
	// the two can neither charge twice nor forget the charge. It reports
	// false when the penalty was already charged.
	ChargeBalanceOnce(ctx context.Context, penalty *models.Penalty) (bool, error)
}

type penaltyRepository struct {
	datastore.BaseRepository[*models.Penalty]
}

func NewPenaltyRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) PenaltyRepository {
	return &penaltyRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Penalty](
			ctx, dbPool, workMan, func() *models.Penalty { return &models.Penalty{} },
		),
	}
}

func (repo *penaltyRepository) UpdateColumns(
	ctx context.Context,
	id string,
	values map[string]any,
) (int64, error) {
	return applyColumnUpdate(repo.Pool().DB(ctx, false), "penalties", id, values)
}

func (repo *penaltyRepository) ClaimWaiver(
	ctx context.Context,
	id, waivedBy, reason string,
) (bool, error) {
	result := repo.Pool().DB(ctx, false).
		Table("penalties").
		Where("id = ? AND is_waived = ? AND deleted_at IS NULL", id, false).
		Updates(map[string]any{
			"is_waived":     true,
			"waived_by":     waivedBy,
			"waived_reason": reason,
			colModifiedAt:   time.Now().UTC(),
			colVersion:      gorm.Expr(colVersion + " + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

// ListByLoanAccountID is served from idx_pen_loan_created.
func (repo *penaltyRepository) ListByLoanAccountID(
	ctx context.Context,
	loanAccountID string,
	limit int,
) ([]*models.Penalty, error) {
	var rows []*models.Penalty
	err := repo.Pool().DB(ctx, true).
		Where("loan_account_id = ?", loanAccountID).
		Order("created_at ASC, id ASC").
		Limit(limit).
		Find(&rows).Error
	if err != nil {
		return nil, err
	}
	return rows, nil
}

func (repo *penaltyRepository) ClaimForEntry(
	ctx context.Context,
	penalty *models.Penalty,
) (*models.Penalty, bool, error) {
	err := repo.Create(ctx, penalty)
	if err == nil {
		return penalty, true, nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return nil, false, err
	}
	var existing models.Penalty
	getErr := repo.Pool().DB(ctx, false).
		Where("schedule_entry_id = ? AND penalty_type = ? AND loan_account_id = ? AND partition_id = ? AND deleted_at IS NULL",
			penalty.ScheduleEntryID, penalty.PenaltyType, penalty.LoanAccountID, penalty.PartitionID).
		First(&existing).Error
	if getErr != nil {
		return nil, false, err
	}
	return &existing, false, nil
}

// penaltyBalanceAppliedKey mirrors the business-layer marker on the row.
const penaltyBalanceAppliedKey = "balance_applied"

func (repo *penaltyRepository) ChargeBalanceOnce(ctx context.Context, penalty *models.Penalty) (bool, error) {
	if penalty == nil || penalty.Amount <= 0 || penalty.LoanAccountID == "" {
		return false, errors.New("penalty with a loan account and positive amount is required")
	}
	charged := false
	err := repo.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		now := time.Now().UTC()
		mark := tx.Table("penalties").
			Where("id = ? AND deleted_at IS NULL AND is_waived = false "+
				"AND NOT jsonb_exists(COALESCE(properties, '{}'::jsonb), ?)",
				penalty.GetID(), penaltyBalanceAppliedKey).
			Updates(map[string]any{
				"properties": gorm.Expr(
					`COALESCE(properties, '{}'::jsonb) || jsonb_build_object(?::text, true)`, penaltyBalanceAppliedKey),
				colModifiedAt: now,
				colVersion:    gorm.Expr(colVersion + " + 1"),
			})
		if mark.Error != nil {
			return mark.Error
		}
		if mark.RowsAffected == 0 {
			return nil
		}
		delta := tx.Table("loan_balances").
			Where("loan_account_id = ? AND deleted_at IS NULL", penalty.LoanAccountID).
			Updates(map[string]any{
				colPenaltiesOutstanding: gorm.Expr("GREATEST(penalties_outstanding + ?, 0)", penalty.Amount),
				colTotalOutstanding:     gorm.Expr("GREATEST(total_outstanding + ?, 0)", penalty.Amount),
				colLastCalculatedAt:     &now,
				colModifiedAt:           now,
				colVersion:              gorm.Expr(colVersion + " + 1"),
			})
		if delta.Error != nil {
			return delta.Error
		}
		if delta.RowsAffected == 0 {
			return errPenaltyBalanceMissing
		}
		charged = true
		return nil
	})
	if err != nil {
		return false, err
	}
	return charged, nil
}

// errPenaltyBalanceMissing aborts the charge when the loan has no balance row;
// the marker set above rolls back with it.
var errPenaltyBalanceMissing = errors.New("loan balance not found for penalty charge")
