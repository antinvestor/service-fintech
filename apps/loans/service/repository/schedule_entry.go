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

// scheduleEntryStatusPaid corresponds to ScheduleEntryStatus_SCHEDULE_ENTRY_STATUS_PAID.
const scheduleEntryStatusPaid = 3

type ScheduleEntryRepository interface {
	datastore.BaseRepository[*models.ScheduleEntry]
	GetByScheduleID(ctx context.Context, scheduleID string) ([]*models.ScheduleEntry, error)
	GetByLoanAccountID(ctx context.Context, loanAccountID string) ([]*models.ScheduleEntry, error)
	GetOverdueEntries(ctx context.Context, loanAccountID string, asOf time.Time) ([]*models.ScheduleEntry, error)
	// MarkPenaltyApplied records on the entry that a late penalty has already
	// been charged for it, conditionally, so a repeated delinquency scan
	// cannot charge the same installment twice. It reports whether this call
	// was the one that marked it.
	MarkPenaltyApplied(ctx context.Context, entryID string) (bool, error)
	// ClearPenaltyApplied undoes MarkPenaltyApplied when the penalty could not
	// be saved, so the installment is penalised on a later scan instead of
	// never.
	ClearPenaltyApplied(ctx context.Context, entryID string) error
	// ListDueBetween pages unpaid installments of active schedules whose due
	// date falls in [from, to), ordered by id after afterID.
	ListDueBetween(ctx context.Context, from, to time.Time, afterID string, limit int) ([]*models.ScheduleEntry, error)
	// MarkReminded records on the entry that the reminder named by key was
	// sent, conditionally, so a repeated reminder run does not message the
	// borrower twice. It reports whether this call was the one that marked it.
	MarkReminded(ctx context.Context, entryID, key string) (bool, error)
	// CountActiveEntries counts the installments on the loan's active schedule.
	CountActiveEntries(ctx context.Context, loanAccountID string) (int64, error)
}

const colProperties = "properties"

type scheduleEntryRepository struct {
	datastore.BaseRepository[*models.ScheduleEntry]
}

func NewScheduleEntryRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) ScheduleEntryRepository {
	return &scheduleEntryRepository{
		BaseRepository: datastore.NewBaseRepository[*models.ScheduleEntry](
			ctx, dbPool, workMan, func() *models.ScheduleEntry { return &models.ScheduleEntry{} },
		),
	}
}

func (repo *scheduleEntryRepository) GetByScheduleID(
	ctx context.Context,
	scheduleID string,
) ([]*models.ScheduleEntry, error) {
	var entries []*models.ScheduleEntry
	err := repo.Pool().DB(ctx, true).
		Where("schedule_id = ?", scheduleID).
		Order("installment_number ASC").
		Find(&entries).Error
	if err != nil {
		return nil, err
	}
	return entries, nil
}

func (repo *scheduleEntryRepository) GetOverdueEntries(
	ctx context.Context,
	loanAccountID string,
	asOf time.Time,
) ([]*models.ScheduleEntry, error) {
	var entries []*models.ScheduleEntry
	// Only the active schedule counts: entries of a superseded (restructured)
	// schedule must not drive arrears or penalties.
	err := repo.Pool().DB(ctx, true).
		Table("schedule_entries").
		Joins("JOIN repayment_schedules rs ON rs.id = schedule_entries.schedule_id AND rs.is_active = true AND rs.deleted_at IS NULL").
		Where("schedule_entries.loan_account_id = ? AND schedule_entries.due_date < ? AND schedule_entries.status != ? "+
			"AND schedule_entries.outstanding > 0 AND schedule_entries.deleted_at IS NULL",
			loanAccountID, asOf, int32(scheduleEntryStatusPaid)).
		Order("schedule_entries.due_date ASC").
		Find(&entries).Error
	if err != nil {
		return nil, err
	}
	return entries, nil
}

func (repo *scheduleEntryRepository) GetByLoanAccountID(
	ctx context.Context,
	loanAccountID string,
) ([]*models.ScheduleEntry, error) {
	var entries []*models.ScheduleEntry
	err := repo.Pool().DB(ctx, true).
		Where("loan_account_id = ?", loanAccountID).
		Order("installment_number ASC").
		Find(&entries).Error
	if err != nil {
		return nil, err
	}
	return entries, nil
}

func (repo *scheduleEntryRepository) MarkPenaltyApplied(
	ctx context.Context,
	entryID string,
) (bool, error) {
	result := repo.Pool().DB(ctx, false).
		Table("schedule_entries").
		Where("id = ? AND COALESCE((properties ->> 'penalty_applied')::boolean, false) = false AND deleted_at IS NULL", entryID).
		Updates(map[string]any{
			colProperties: gorm.Expr(
				`COALESCE(properties, '{}'::jsonb) || jsonb_build_object('penalty_applied', true)`,
			),
			colModifiedAt: time.Now().UTC(),
			colVersion:    gorm.Expr(colVersion + " + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (repo *scheduleEntryRepository) ClearPenaltyApplied(ctx context.Context, entryID string) error {
	return repo.Pool().DB(ctx, false).
		Table("schedule_entries").
		Where("id = ? AND deleted_at IS NULL", entryID).
		Updates(map[string]any{
			colProperties: gorm.Expr(`COALESCE(properties, '{}'::jsonb) - 'penalty_applied'`),
			colModifiedAt: time.Now().UTC(),
			colVersion:    gorm.Expr(colVersion + " + 1"),
		}).Error
}

func (repo *scheduleEntryRepository) ListDueBetween(
	ctx context.Context,
	from, to time.Time,
	afterID string,
	limit int,
) ([]*models.ScheduleEntry, error) {
	var entries []*models.ScheduleEntry
	q := repo.Pool().DB(ctx, true).
		Table("schedule_entries").
		Joins("JOIN repayment_schedules rs ON rs.id = schedule_entries.schedule_id AND rs.is_active = true AND rs.deleted_at IS NULL").
		Where("schedule_entries.due_date >= ? AND schedule_entries.due_date < ? AND schedule_entries.status != ? "+
			"AND schedule_entries.outstanding > 0 AND schedule_entries.deleted_at IS NULL",
			from, to, int32(scheduleEntryStatusPaid))
	if afterID != "" {
		q = q.Where("schedule_entries.id > ?", afterID)
	}
	err := q.Order("schedule_entries.id ASC").Limit(limit).Find(&entries).Error
	if err != nil {
		return nil, err
	}
	return entries, nil
}

func (repo *scheduleEntryRepository) MarkReminded(ctx context.Context, entryID, key string) (bool, error) {
	result := repo.Pool().DB(ctx, false).
		Table("schedule_entries").
		Where("id = ? AND deleted_at IS NULL AND NOT jsonb_exists(COALESCE(properties, '{}'::jsonb), ?)", entryID, key).
		Updates(map[string]any{
			colProperties: gorm.Expr(
				`COALESCE(properties, '{}'::jsonb) || jsonb_build_object(?::text, ?::text)`,
				key,
				time.Now().UTC().Format(time.RFC3339),
			),
			colModifiedAt: time.Now().UTC(),
			colVersion:    gorm.Expr(colVersion + " + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (repo *scheduleEntryRepository) CountActiveEntries(ctx context.Context, loanAccountID string) (int64, error) {
	var count int64
	err := repo.Pool().DB(ctx, true).
		Table("schedule_entries").
		Joins("JOIN repayment_schedules rs ON rs.id = schedule_entries.schedule_id AND rs.is_active = true AND rs.deleted_at IS NULL").
		Where("schedule_entries.loan_account_id = ? AND schedule_entries.deleted_at IS NULL", loanAccountID).
		Count(&count).Error
	return count, err
}
