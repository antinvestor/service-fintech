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

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

const (
	tableTeamCommissions         = "team_commissions"
	tableTeamCommissionMovements = "team_commission_movements"
)

// ErrCommissionInsufficient is returned when a payout would take more than
// the team has left to be paid.
var ErrCommissionInsufficient = errors.New("the team's commission balance does not cover the payout")

// errCommissionGuard rolls back a transaction whose guarded update matched
// no row.
var errCommissionGuard = errors.New("team commission guard rejected the change")

// TeamCommissionRepository keeps each team's commission balance and the
// accruals and payouts that move it. Every change to a balance happens in
// the same transaction as the movement that causes it.
type TeamCommissionRepository interface {
	// Accrue records an accrual once under its reference and adds it to the
	// team's balance; it reports whether this call recorded it.
	Accrue(ctx context.Context, m *models.TeamCommissionMovement) (bool, error)
	// ClaimPayout inserts a pending payout, or hands back the payout that
	// already holds its reference.
	ClaimPayout(ctx context.Context, m *models.TeamCommissionMovement) (*models.TeamCommissionMovement, bool, error)
	// PayoutByReference returns the payout recorded under a reference.
	PayoutByReference(ctx context.Context, reference string) (*models.TeamCommissionMovement, error)
	// DebitPayout moves a pending payout to processing and takes it from the
	// balance, or returns ErrCommissionInsufficient and changes nothing.
	DebitPayout(ctx context.Context, m *models.TeamCommissionMovement) error
	// RevertPayout returns a processing payout that was refused to pending
	// and gives its amount back to the balance.
	RevertPayout(ctx context.Context, m *models.TeamCommissionMovement, reason string) error
	// CompletePayout marks a processing payout paid.
	CompletePayout(ctx context.Context, id string) error
	// Search lists balances, all teams' when teamID is empty.
	Search(ctx context.Context, teamID string, offset, limit int) ([]*models.TeamCommission, error)
	// SearchPayouts lists a team's payouts, newest first.
	SearchPayouts(ctx context.Context, teamID string, offset, limit int) ([]*models.TeamCommissionMovement, error)
}

type teamCommissionRepository struct {
	dbPool pool.Pool
}

// NewTeamCommissionRepository builds the repository.
func NewTeamCommissionRepository(dbPool pool.Pool) TeamCommissionRepository {
	return &teamCommissionRepository{dbPool: dbPool}
}

func (r *teamCommissionRepository) Accrue(ctx context.Context, m *models.TeamCommissionMovement) (bool, error) {
	var recorded bool
	err := r.dbPool.DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		// A duplicate would abort the transaction, so a movement already
		// recorded is skipped by the insert itself.
		res := tx.Clauses(clause.OnConflict{
			Columns:     []clause.Column{{Name: "partition_id"}, {Name: "reference"}},
			TargetWhere: liveRows(),
			DoNothing:   true,
		}).Create(m)
		if res.Error != nil || res.RowsAffected == 0 {
			return res.Error
		}
		recorded = true
		balance := &models.TeamCommission{TeamID: m.TeamID, CurrencyCode: m.CurrencyCode, Accrued: m.Amount}
		balance.CopyPartitionInfo(&m.BaseModel)
		return tx.Clauses(clause.OnConflict{
			Columns:     []clause.Column{{Name: "partition_id"}, {Name: "team_id"}, {Name: "currency_code"}},
			TargetWhere: liveRows(),
			DoUpdates: clause.Assignments(map[string]any{
				"accrued":     gorm.Expr(tableTeamCommissions + ".accrued + EXCLUDED.accrued"),
				colModifiedAt: time.Now().UTC(),
				colVersion:    gorm.Expr(tableTeamCommissions + ".version + 1"),
			}),
		}).Create(balance).Error
	})
	return recorded, err
}

func (r *teamCommissionRepository) ClaimPayout(
	ctx context.Context,
	m *models.TeamCommissionMovement,
) (*models.TeamCommissionMovement, bool, error) {
	err := r.dbPool.DB(ctx, false).Create(m).Error
	if err == nil {
		return m, true, nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return nil, false, err
	}
	stored := &models.TeamCommissionMovement{}
	if readErr := r.dbPool.DB(ctx, false).
		Where("reference = ? AND deleted_at IS NULL", m.Reference).
		First(stored).Error; readErr != nil {
		return nil, false, readErr
	}
	return stored, false, nil
}

func (r *teamCommissionRepository) PayoutByReference(
	ctx context.Context,
	reference string,
) (*models.TeamCommissionMovement, error) {
	stored := &models.TeamCommissionMovement{}
	err := r.dbPool.DB(ctx, false).
		Where("reference = ? AND kind = ? AND deleted_at IS NULL", reference, int32(models.TeamCommissionPayout)).
		First(stored).Error
	if err != nil {
		return nil, err
	}
	return stored, nil
}

func (r *teamCommissionRepository) DebitPayout(ctx context.Context, m *models.TeamCommissionMovement) error {
	err := r.dbPool.DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		moved, err := moveCommissionStatus(tx, m.GetID(),
			loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_PENDING,
			loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_PROCESSING, "")
		if err != nil || !moved {
			return err
		}
		return updateCommissionBalance(tx, m, " AND accrued - paid_out >= ?", []any{m.Amount},
			gorm.Expr("paid_out + ?", m.Amount))
	})
	if errors.Is(err, errCommissionGuard) {
		return ErrCommissionInsufficient
	}
	return err
}

func (r *teamCommissionRepository) RevertPayout(
	ctx context.Context,
	m *models.TeamCommissionMovement,
	reason string,
) error {
	return r.dbPool.DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		moved, err := moveCommissionStatus(tx, m.GetID(),
			loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_PROCESSING,
			loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_PENDING, reason)
		if err != nil || !moved {
			return err
		}
		return updateCommissionBalance(tx, m, "", nil, gorm.Expr("paid_out - ?", m.Amount))
	})
}

func (r *teamCommissionRepository) CompletePayout(ctx context.Context, id string) error {
	_, err := moveCommissionStatus(r.dbPool.DB(ctx, false), id,
		loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_PROCESSING,
		loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_COMPLETED, "")
	return err
}

func (r *teamCommissionRepository) Search(
	ctx context.Context,
	teamID string,
	offset, limit int,
) ([]*models.TeamCommission, error) {
	q := r.dbPool.DB(ctx, true).Where("deleted_at IS NULL")
	if teamID != "" {
		q = q.Where("team_id = ?", teamID)
	}
	var out []*models.TeamCommission
	err := q.Order("team_id, currency_code").Offset(offset).Limit(limit).Find(&out).Error
	return out, err
}

func (r *teamCommissionRepository) SearchPayouts(
	ctx context.Context,
	teamID string,
	offset, limit int,
) ([]*models.TeamCommissionMovement, error) {
	var out []*models.TeamCommissionMovement
	err := r.dbPool.DB(ctx, true).
		Where("team_id = ? AND kind = ? AND deleted_at IS NULL", teamID, int32(models.TeamCommissionPayout)).
		Order("created_at DESC").Offset(offset).Limit(limit).Find(&out).Error
	return out, err
}

// liveRows is the predicate of the partial unique indexes an upsert targets.
func liveRows() clause.Where {
	return clause.Where{Exprs: []clause.Expression{clause.Expr{SQL: "deleted_at IS NULL"}}}
}

// moveCommissionStatus moves one movement between statuses and reports
// whether this call made the move.
func moveCommissionStatus(
	tx *gorm.DB,
	id string,
	from, to loansv1.TeamCommissionPayoutStatus,
	failureReason string,
) (bool, error) {
	res := tx.Table(tableTeamCommissionMovements).
		Where("id = ? AND deleted_at IS NULL AND status = ?", id, int32(from)).
		Updates(map[string]any{
			colStatus:        int32(to),
			"failure_reason": failureReason,
			colModifiedAt:    time.Now().UTC(),
			colVersion:       gorm.Expr(colVersion + " + 1"),
		})
	return res.RowsAffected > 0, res.Error
}

// updateCommissionBalance sets a team's paid_out inside the caller's
// transaction, failing with errCommissionGuard when no row matches.
func updateCommissionBalance(
	tx *gorm.DB,
	m *models.TeamCommissionMovement,
	guard string,
	guardArgs []any,
	paidOut any,
) error {
	args := append([]any{m.PartitionID, m.TeamID, m.CurrencyCode}, guardArgs...)
	res := tx.Table(tableTeamCommissions).
		Where("partition_id = ? AND team_id = ? AND currency_code = ? AND deleted_at IS NULL"+guard, args...).
		Updates(map[string]any{
			"paid_out":    paidOut,
			colModifiedAt: time.Now().UTC(),
			colVersion:    gorm.Expr(colVersion + " + 1"),
		})
	if res.Error != nil {
		return res.Error
	}
	if res.RowsAffected == 0 {
		return errCommissionGuard
	}
	return nil
}
