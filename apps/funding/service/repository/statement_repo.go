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
	"encoding/json"
	"fmt"
	"time"

	"github.com/pitabwire/frame/v3/datastore/pool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// StatementTranche is a tranche an investor funded, with the loan request it
// funded.
type StatementTranche struct {
	models.FundingTranche
	LoanRequestID string
}

// StatementWindow is an investor account and a period, from inclusive, to
// exclusive. Limit bounds each kind of record read.
type StatementWindow struct {
	InvestorAccountID string
	From, To          time.Time
	Limit             int
}

// StatementRepository reads the records that moved an investor's capital
// over a period. Every read is bounded by the window's limit.
type StatementRepository interface {
	// Movements are the account's settled deposits and withdrawals, and
	// withdrawals whose payout is not yet confirmed.
	Movements(ctx context.Context, w StatementWindow) ([]*models.InvestorCapitalMovement, error)
	// Tranches are those the account funded within the period, or whose
	// commitment was released within it.
	Tranches(ctx context.Context, w StatementWindow) ([]*StatementTranche, error)
	// Distributions are repayments shared out with a share for the account.
	Distributions(ctx context.Context, w StatementWindow) ([]*models.RepaymentDistribution, error)
	// Losses are write-offs the account absorbed part of.
	Losses(ctx context.Context, w StatementWindow) ([]*models.LossAbsorption, error)
	// Recoveries are recoveries that returned part of a loss to the account.
	Recoveries(ctx context.Context, w StatementWindow) ([]*models.LossRecovery, error)
}

type statementRepository struct {
	dbPool pool.Pool
}

// NewStatementRepository builds the statement reads.
func NewStatementRepository(dbPool pool.Pool) StatementRepository {
	return &statementRepository{dbPool: dbPool}
}

func (r *statementRepository) Movements(
	ctx context.Context,
	w StatementWindow,
) ([]*models.InvestorCapitalMovement, error) {
	var out []*models.InvestorCapitalMovement
	err := r.dbPool.DB(ctx, true).
		Where("investor_account_id = ? AND created_at >= ? AND created_at < ? AND deleted_at IS NULL",
			w.InvestorAccountID, w.From, w.To).
		Where("status = ? OR (status = ? AND direction = ?)",
			models.CapitalMovementCompleted, models.CapitalMovementDebited, int32(models.CapitalMovementWithdraw)).
		Order("created_at").Limit(w.Limit).Find(&out).Error
	return out, err
}

func (r *statementRepository) Tranches(ctx context.Context, w StatementWindow) ([]*StatementTranche, error) {
	var out []*StatementTranche
	err := r.dbPool.DB(ctx, true).
		Table("funding_tranches AS ft").
		Select("ft.*, lf.loan_request_id").
		Joins("JOIN loan_fundings lf ON lf.id = ft.loan_funding_id").
		Where("ft.investor_account_id = ? AND ft.deleted_at IS NULL", w.InvestorAccountID).
		Where("(ft.created_at >= ? AND ft.created_at < ?) OR (ft.state = ? AND ft.modified_at >= ? AND ft.modified_at < ?)",
			w.From, w.To, int32(constants.StateInactive), w.From, w.To).
		Order("ft.created_at").Limit(w.Limit).Scan(&out).Error
	return out, err
}

func (r *statementRepository) Distributions(
	ctx context.Context,
	w StatementWindow,
) ([]*models.RepaymentDistribution, error) {
	var out []*models.RepaymentDistribution
	err := r.withShare(ctx, w, "shares").Order("created_at").Limit(w.Limit).Find(&out).Error
	return out, err
}

func (r *statementRepository) Losses(ctx context.Context, w StatementWindow) ([]*models.LossAbsorption, error) {
	var out []*models.LossAbsorption
	err := r.withShare(ctx, w, "properties").Order("created_at").Limit(w.Limit).Find(&out).Error
	return out, err
}

func (r *statementRepository) Recoveries(ctx context.Context, w StatementWindow) ([]*models.LossRecovery, error) {
	var out []*models.LossRecovery
	err := r.withShare(ctx, w, "properties").Order("created_at").Limit(w.Limit).Find(&out).Error
	return out, err
}

// withShare selects the rows of the period whose shares list, held under
// "shares" in column, has an entry for the account.
func (r *statementRepository) withShare(ctx context.Context, w StatementWindow, column string) *gorm.DB {
	match, _ := json.Marshal([]map[string]string{{"investor_account_id": w.InvestorAccountID}})
	return r.dbPool.DB(ctx, true).
		Where("created_at >= ? AND created_at < ? AND deleted_at IS NULL", w.From, w.To).
		Where(fmt.Sprintf("%s->'shares' @> ?::jsonb", column), string(match))
}
