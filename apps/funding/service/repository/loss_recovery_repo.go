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

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
)

// LossRecoveryRepository persists recoveries of written-off loans.
type LossRecoveryRepository interface {
	datastore.BaseRepository[*models.LossRecovery]

	// GetByReference returns the recovery recorded under a reference.
	GetByReference(ctx context.Context, reference string) (*models.LossRecovery, error)

	// ClaimAndApply writes the recovery and returns every tranche's and
	// investor's share in one transaction. created=false means the reference
	// was recovered before: nothing moved and the stored row is returned. A
	// tranche asked to recover more than it still has lost fails the whole
	// transaction, so the caller recomputes from fresh rows.
	ClaimAndApply(
		ctx context.Context,
		recovery *models.LossRecovery,
		movements []TrancheMovement,
	) (row *models.LossRecovery, created bool, err error)

	// MarkSettled records that the recovery's ledger postings are done.
	MarkSettled(ctx context.Context, id string) error
}

type lossRecoveryRepository struct {
	datastore.BaseRepository[*models.LossRecovery]
}

// NewLossRecoveryRepository creates a new LossRecoveryRepository.
func NewLossRecoveryRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) LossRecoveryRepository {
	return &lossRecoveryRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.LossRecovery {
			return &models.LossRecovery{}
		}),
	}
}

func (r *lossRecoveryRepository) GetByReference(ctx context.Context, reference string) (*models.LossRecovery, error) {
	recovery := &models.LossRecovery{}
	if err := r.Pool().DB(ctx, false).First(recovery, "reference = ?", reference).Error; err != nil {
		return nil, err
	}
	return recovery, nil
}

func (r *lossRecoveryRepository) ClaimAndApply(
	ctx context.Context,
	recovery *models.LossRecovery,
	movements []TrancheMovement,
) (*models.LossRecovery, bool, error) {
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		if createErr := tx.Create(recovery).Error; createErr != nil {
			return createErr
		}
		for _, m := range movements {
			if moveErr := applyRecoveryMovement(tx, m); moveErr != nil {
				return moveErr
			}
		}
		return nil
	})
	if err == nil {
		return recovery, true, nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return nil, false, err
	}
	existing, rereadErr := r.GetByReference(ctx, recovery.Reference)
	if rereadErr != nil {
		return nil, false, err
	}
	return existing, false, nil
}

// applyRecoveryMovement returns one tranche's part of a recovery: the
// tranche can only recover what it lost and has not yet recovered, and the
// investor gets the same amount back on their capital and off their losses.
func applyRecoveryMovement(tx *gorm.DB, m TrancheMovement) error {
	if m.Principal <= 0 {
		return nil
	}
	result := tx.Table("funding_tranches").
		Where("id = ? AND deleted_at IS NULL AND loss_absorbed - loss_recovered >= ?", m.TrancheID, m.Principal).
		Updates(map[string]any{
			"loss_recovered": gorm.Expr("loss_recovered + ?", m.Principal),
			colModifiedAt:    gormNow(),
			colVersion:       gormVersionIncrement(),
		})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return ErrTrancheExposureChanged
	}
	if m.InvestorAccountID == "" {
		return nil
	}
	result = tx.Table("investor_accounts").
		Where("id = ? AND deleted_at IS NULL", m.InvestorAccountID).
		Updates(map[string]any{
			colAvailableBalance: gorm.Expr("available_balance + ?", m.Principal),
			colTotalLost:        gorm.Expr("GREATEST(total_lost - ?, 0)", m.Principal),
			colModifiedAt:       gormNow(),
			colVersion:          gormVersionIncrement(),
		})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return ErrInvestorAccountNotFound
	}
	return nil
}

func (r *lossRecoveryRepository) MarkSettled(ctx context.Context, id string) error {
	return r.Pool().DB(ctx, false).
		Table("loss_recoveries").
		Where("id = ? AND settled_at IS NULL AND deleted_at IS NULL", id).
		Updates(map[string]any{
			colSettledAt:  gormNow(),
			colModifiedAt: gormNow(),
			colVersion:    gormVersionIncrement(),
		}).Error
}
