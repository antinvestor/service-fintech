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
