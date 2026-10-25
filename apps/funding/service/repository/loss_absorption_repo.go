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

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
)

// LossAbsorptionRepository owns the durable record of absorbed losses.
type LossAbsorptionRepository interface {
	datastore.BaseRepository[*models.LossAbsorption]

	// Claim takes the absorption lock for a loss reference. created=false
	// returns the stored result of the call that won.
	Claim(
		ctx context.Context,
		absorption *models.LossAbsorption,
	) (row *models.LossAbsorption, created bool, err error)

	// GetByReference returns the absorption recorded under a reference.
	GetByReference(ctx context.Context, reference string) (*models.LossAbsorption, error)

	// Finalize records what the tranches actually covered once the walk is
	// done, so a later repeat of the same reference reports the same split.
	Finalize(ctx context.Context, id string, absorbed, unrecoverable int64) error

	// ClaimAndApply writes the absorption and charges every tranche and
	// investor in one transaction. created=false means the reference was
	// absorbed before: nothing moved and the stored row is returned. A
	// tranche that no longer has the outstanding principal to carry its part
	// fails the whole transaction, so the caller recomputes from fresh rows.
	ClaimAndApply(
		ctx context.Context,
		absorption *models.LossAbsorption,
		movements []TrancheMovement,
	) (row *models.LossAbsorption, created bool, err error)

	// MarkSettled records that the absorption's ledger postings are done.
	MarkSettled(ctx context.Context, id string) error
}

// ErrTrancheExposureChanged is returned when a tranche's outstanding
// principal moved between the read and the absorption.
var ErrTrancheExposureChanged = errors.New("funding tranche exposure changed during loss absorption")

type lossAbsorptionRepository struct {
	datastore.BaseRepository[*models.LossAbsorption]
}

// NewLossAbsorptionRepository creates a LossAbsorptionRepository.
func NewLossAbsorptionRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) LossAbsorptionRepository {
	return &lossAbsorptionRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.LossAbsorption {
			return &models.LossAbsorption{}
		}),
	}
}

func (r *lossAbsorptionRepository) GetByReference(
	ctx context.Context,
	reference string,
) (*models.LossAbsorption, error) {
	absorption := &models.LossAbsorption{}
	if err := r.Pool().DB(ctx, true).First(absorption, "reference = ?", reference).Error; err != nil {
		return nil, err
	}
	return absorption, nil
}

func (r *lossAbsorptionRepository) Claim(
	ctx context.Context,
	absorption *models.LossAbsorption,
) (*models.LossAbsorption, bool, error) {
	err := r.Pool().DB(ctx, false).Create(absorption).Error
	if err == nil {
		return absorption, true, nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return nil, false, err
	}
	existing, rereadErr := r.GetByReference(ctx, absorption.Reference)
	if rereadErr != nil {
		return nil, false, err
	}
	return existing, false, nil
}

func (r *lossAbsorptionRepository) Finalize(ctx context.Context, id string, absorbed, unrecoverable int64) error {
	return r.Pool().DB(ctx, false).
		Table("loss_absorptions").
		Where("id = ? AND deleted_at IS NULL", id).
		Updates(map[string]any{
			"absorbed":      absorbed,
			"unrecoverable": unrecoverable,
			colModifiedAt:   gormNow(),
			colVersion:      gormVersionIncrement(),
		}).Error
}

func (r *lossAbsorptionRepository) ClaimAndApply(
	ctx context.Context,
	absorption *models.LossAbsorption,
	movements []TrancheMovement,
) (*models.LossAbsorption, bool, error) {
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		if createErr := tx.Create(absorption).Error; createErr != nil {
			return createErr
		}
		for _, m := range movements {
			if moveErr := applyLossMovement(tx, m); moveErr != nil {
				return moveErr
			}
		}
		return nil
	})
	if err == nil {
		return absorption, true, nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return nil, false, err
	}
	existing, rereadErr := r.GetByReference(ctx, absorption.Reference)
	if rereadErr != nil {
		return nil, false, err
	}
	return existing, false, nil
}

// applyLossMovement charges one tranche's part of a loss. The tranche can
// only lose what it still has lent out; the investor loses the same amount
// from both their capital and the part of it that was lent.
func applyLossMovement(tx *gorm.DB, m TrancheMovement) error {
	if m.Principal <= 0 {
		return nil
	}
	result := tx.Table("funding_tranches").
		Where("id = ? AND deleted_at IS NULL AND amount - principal_repaid - loss_absorbed >= ?",
			m.TrancheID, m.Principal).
		Updates(map[string]any{
			"loss_absorbed": gorm.Expr("loss_absorbed + ?", m.Principal),
			colModifiedAt:   gormNow(),
			colVersion:      gormVersionIncrement(),
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
			colReservedBalance:  gorm.Expr("GREATEST(reserved_balance - ?, 0)", m.Principal),
			colAvailableBalance: gorm.Expr("GREATEST(available_balance - ?, 0)", m.Principal),
			"total_lost":        gorm.Expr("total_lost + ?", m.Principal),
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

func (r *lossAbsorptionRepository) MarkSettled(ctx context.Context, id string) error {
	return r.Pool().DB(ctx, false).
		Table("loss_absorptions").
		Where("id = ? AND settled_at IS NULL AND deleted_at IS NULL", id).
		Updates(map[string]any{
			"settled_at":  gormNow(),
			colModifiedAt: gormNow(),
			colVersion:    gormVersionIncrement(),
		}).Error
}
