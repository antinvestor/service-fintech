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

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

type RepaymentScheduleRepository interface {
	datastore.BaseRepository[*models.RepaymentSchedule]
	GetActivByLoanAccountID(ctx context.Context, loanAccountID string) (*models.RepaymentSchedule, error)
	KeepLatestActive(ctx context.Context, loanAccountID string) error
}

type repaymentScheduleRepository struct {
	datastore.BaseRepository[*models.RepaymentSchedule]
}

func NewRepaymentScheduleRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) RepaymentScheduleRepository {
	return &repaymentScheduleRepository{
		BaseRepository: datastore.NewBaseRepository[*models.RepaymentSchedule](
			ctx, dbPool, workMan, func() *models.RepaymentSchedule { return &models.RepaymentSchedule{} },
		),
	}
}

func (repo *repaymentScheduleRepository) GetActivByLoanAccountID(
	ctx context.Context,
	loanAccountID string,
) (*models.RepaymentSchedule, error) {
	schedule := models.RepaymentSchedule{}
	// Schedules and their entries are read from the primary: repayments
	// allocate against them, and a lagging replica could hide an installment
	// that was just paid.
	err := repo.Pool().DB(ctx, false).
		Where("loan_account_id = ? AND is_active = ?", loanAccountID, true).
		Order("generated_at DESC NULLS LAST, schedule_version DESC, id DESC").
		First(&schedule).Error
	if err != nil {
		return nil, err
	}
	return &schedule, nil
}

// KeepLatestActive leaves only the loan's newest schedule active. Schedules
// are written through events whose order is not guaranteed, so the opening
// schedule may land after the one re-anchored at disbursement; whichever
// arrives last, the newest by generation wins.
func (repo *repaymentScheduleRepository) KeepLatestActive(ctx context.Context, loanAccountID string) error {
	return repo.Pool().DB(ctx, false).Exec(`
UPDATE repayment_schedules rs
SET is_active = (rs.id = latest.id), modified_at = CURRENT_TIMESTAMP, version = rs.version + 1
FROM (
    SELECT id FROM repayment_schedules
    WHERE loan_account_id = ? AND deleted_at IS NULL
    ORDER BY generated_at DESC NULLS LAST, schedule_version DESC, id DESC
    LIMIT 1
) latest
WHERE rs.loan_account_id = ? AND rs.deleted_at IS NULL AND rs.is_active IS DISTINCT FROM (rs.id = latest.id)`,
		loanAccountID, loanAccountID).Error
}
