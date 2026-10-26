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

// TrancheMovement is one tranche's part of a repayment or a loss, applied to
// the tranche and, for an investor tranche, to the investor's account.
type TrancheMovement struct {
	TrancheID         string
	InvestorAccountID string
	Principal         int64 // principal repaid, or loss absorbed
	InterestGross     int64 // interest earned by the tranche, before fee and tax
	InterestNet       int64 // what the investor keeps
}

// RepaymentDistributionRepository records repayment distributions and moves
// the counters behind them in one transaction.
type RepaymentDistributionRepository interface {
	datastore.BaseRepository[*models.RepaymentDistribution]

	// Apply writes the distribution and moves every tranche and investor
	// counter in one transaction. created=false means the reference was
	// already applied: nothing moved and the stored row is returned.
	Apply(
		ctx context.Context,
		dist *models.RepaymentDistribution,
		movements []TrancheMovement,
	) (row *models.RepaymentDistribution, created bool, err error)

	GetByReference(ctx context.Context, reference string) (*models.RepaymentDistribution, error)

	// MarkSettled records that every ledger posting of the distribution is done.
	MarkSettled(ctx context.Context, id string) error

	// ListUnsettled returns up to limit distributions still owing a posting,
	// oldest first, created before the cutoff given in seconds of age.
	ListUnsettled(ctx context.Context, olderThanSeconds int, limit int) ([]*models.RepaymentDistribution, error)
}

type repaymentDistributionRepository struct {
	datastore.BaseRepository[*models.RepaymentDistribution]
}

// NewRepaymentDistributionRepository creates a RepaymentDistributionRepository.
func NewRepaymentDistributionRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) RepaymentDistributionRepository {
	return &repaymentDistributionRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.RepaymentDistribution {
			return &models.RepaymentDistribution{}
		}),
	}
}

func (r *repaymentDistributionRepository) GetByReference(
	ctx context.Context,
	reference string,
) (*models.RepaymentDistribution, error) {
	dist := &models.RepaymentDistribution{}
	if err := r.Pool().DB(ctx, true).First(dist, "reference = ? AND deleted_at IS NULL", reference).Error; err != nil {
		return nil, err
	}
	return dist, nil
}

func (r *repaymentDistributionRepository) Apply(
	ctx context.Context,
	dist *models.RepaymentDistribution,
	movements []TrancheMovement,
) (*models.RepaymentDistribution, bool, error) {
	err := r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		if createErr := tx.Create(dist).Error; createErr != nil {
			return createErr
		}
		for _, m := range movements {
			if moveErr := applyRepaymentMovement(tx, m); moveErr != nil {
				return moveErr
			}
		}
		return nil
	})
	if err == nil {
		return dist, true, nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return nil, false, err
	}
	existing, rereadErr := r.GetByReference(ctx, dist.Reference)
	if rereadErr != nil {
		return nil, false, err
	}
	return existing, false, nil
}

// applyRepaymentMovement moves one tranche's counters, and its investor's
// balances, by deltas: concurrent repayments on different loans of the same
// investor never overwrite each other.
func applyRepaymentMovement(tx *gorm.DB, m TrancheMovement) error {
	if m.Principal == 0 && m.InterestGross == 0 {
		return nil
	}
	if err := tx.Table("funding_tranches").
		Where("id = ? AND deleted_at IS NULL", m.TrancheID).
		Updates(map[string]any{
			"principal_repaid": gorm.Expr("principal_repaid + ?", m.Principal),
			"interest_earned":  gorm.Expr("interest_earned + ?", m.InterestGross),
			colModifiedAt:      gormNow(),
			colVersion:         gormVersionIncrement(),
		}).Error; err != nil {
		return err
	}
	if m.InvestorAccountID == "" {
		return nil
	}
	// Available is the investor's whole capital and reserved the part lent
	// out, so returned principal only stops being reserved; net interest
	// grows the capital.
	result := tx.Table("investor_accounts").
		Where("id = ? AND deleted_at IS NULL", m.InvestorAccountID).
		Updates(map[string]any{
			colReservedBalance:  gorm.Expr("GREATEST(reserved_balance - ?, 0)", m.Principal),
			colAvailableBalance: gorm.Expr("available_balance + ?", m.InterestNet),
			"total_returned":    gorm.Expr("total_returned + ?", m.Principal+m.InterestNet),
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

func (r *repaymentDistributionRepository) MarkSettled(ctx context.Context, id string) error {
	return r.Pool().DB(ctx, false).
		Table("repayment_distributions").
		Where("id = ? AND settled_at IS NULL AND deleted_at IS NULL", id).
		Updates(map[string]any{
			colSettledAt:  gormNow(),
			colModifiedAt: gormNow(),
			colVersion:    gormVersionIncrement(),
		}).Error
}

func (r *repaymentDistributionRepository) ListUnsettled(
	ctx context.Context,
	olderThanSeconds int,
	limit int,
) ([]*models.RepaymentDistribution, error) {
	if limit <= 0 {
		return nil, errors.New("limit must be positive")
	}
	var rows []*models.RepaymentDistribution
	err := r.Pool().DB(ctx, true).
		Where("settled_at IS NULL AND deleted_at IS NULL AND created_at < now() - make_interval(secs => ?)",
			olderThanSeconds).
		Order("created_at ASC").
		Limit(limit).
		Find(&rows).Error
	return rows, err
}
