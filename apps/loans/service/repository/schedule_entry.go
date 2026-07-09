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

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

// scheduleEntryStatusPaid corresponds to ScheduleEntryStatus_SCHEDULE_ENTRY_STATUS_PAID.
const scheduleEntryStatusPaid = 3

type ScheduleEntryRepository interface {
	datastore.BaseRepository[*models.ScheduleEntry]
	GetByScheduleID(ctx context.Context, scheduleID string) ([]*models.ScheduleEntry, error)
	GetByLoanAccountID(ctx context.Context, loanAccountID string) ([]*models.ScheduleEntry, error)
	GetOverdueEntries(ctx context.Context, loanAccountID string, asOf time.Time) ([]*models.ScheduleEntry, error)
}

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
	err := repo.Pool().DB(ctx, true).
		Where("loan_account_id = ? AND due_date < ? AND status != ? AND outstanding > 0",
			loanAccountID, asOf, int32(scheduleEntryStatusPaid)).
		Order("due_date ASC").
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
