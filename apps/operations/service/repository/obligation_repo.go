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

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
)

// ObligationRepository provides data access for obligations.
type ObligationRepository interface {
	datastore.BaseRepository[*models.Obligation]
	GetByMembershipID(ctx context.Context, membershipID string) ([]*models.Obligation, error)
	GetByPeriodID(ctx context.Context, periodID string) ([]*models.Obligation, error)
	GetByCauseID(ctx context.Context, causeID string) ([]*models.Obligation, error)

	// ConsumeAmount deducts amount from an active obligation in a single
	// conditional UPDATE and deactivates it once nothing is left. It reports
	// whether the deduction landed, so two concurrent allocations of the same
	// obligation cannot both succeed against the same balance.
	ConsumeAmount(ctx context.Context, obligationID string, amount int64) (bool, error)
}

// NewObligationRepository creates a new ObligationRepository.
func NewObligationRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) ObligationRepository {
	return &obligationRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.Obligation {
			return &models.Obligation{}
		}),
	}
}

// stateActive and stateInactive are the numeric state values used in queries,
// and colState/colModifiedAt/colVersion are the columns the conditional
// claim updates write.
const (
	stateActive   = 3
	stateInactive = 4

	colState              = "state"
	colModifiedAt         = "modified_at"
	colVersion            = "version"
	colFailureReason      = "failure_reason"
	colLedgerTxnID        = "ledger_transaction_id"
	colPaymentInitiatedAt = "payment_initiated_at"
	colPaymentID          = "payment_id"
	colPayoutStatus       = "payout_status"
)

type obligationRepository struct {
	datastore.BaseRepository[*models.Obligation]
}

func (r *obligationRepository) ConsumeAmount(
	ctx context.Context,
	obligationID string,
	amount int64,
) (bool, error) {
	if amount <= 0 {
		return false, nil
	}
	// Table, not Model: an empty model instance has its primary key filled in
	// by the frame BaseModel hooks, which would add a bogus id to the WHERE.
	result := r.Pool().DB(ctx, false).
		Table("obligations").
		Where("deleted_at IS NULL AND id = ? AND state = ? AND amount >= ?",
			obligationID, stateActive, amount).
		Updates(map[string]any{
			"amount":      gorm.Expr("amount - ?", amount),
			colState:      gorm.Expr("CASE WHEN amount - ? <= 0 THEN ? ELSE state END", amount, stateInactive),
			colModifiedAt: time.Now().UTC(),
			colVersion:    gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (r *obligationRepository) GetByMembershipID(
	ctx context.Context,
	membershipID string,
) ([]*models.Obligation, error) {
	var obligations []*models.Obligation
	err := r.Pool().DB(ctx, true).
		Where("membership_id = ? AND state = ?", membershipID, stateActive).
		Order("deadline ASC").
		Find(&obligations).Error
	return obligations, err
}

func (r *obligationRepository) GetByPeriodID(ctx context.Context, periodID string) ([]*models.Obligation, error) {
	var obligations []*models.Obligation
	err := r.Pool().DB(ctx, true).Where("period_id = ?", periodID).Find(&obligations).Error
	return obligations, err
}

func (r *obligationRepository) GetByCauseID(ctx context.Context, causeID string) ([]*models.Obligation, error) {
	var obligations []*models.Obligation
	err := r.Pool().DB(ctx, true).Where("cause_id = ?", causeID).Find(&obligations).Error
	return obligations, err
}
