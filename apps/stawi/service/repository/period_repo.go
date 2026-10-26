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

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// PeriodRepository provides data access for periods.
type PeriodRepository interface {
	datastore.BaseRepository[*models.Period]
	GetCurrentByGroupID(ctx context.Context, groupID string) (*models.Period, error)
	// GetByParentID returns the period opened after parentID.
	GetByParentID(ctx context.Context, parentID string) (*models.Period, error)
	// ListDueToClose returns up to limit open periods whose end date has
	// passed and that are not held off after a failed close.
	ListDueToClose(ctx context.Context, now time.Time, limit int) ([]*models.Period, error)
	// ListDueForReminder returns up to limit open, still running periods
	// whose next reminder is due.
	ListDueForReminder(ctx context.Context, now time.Time, limit int) ([]*models.Period, error)
}

// NewPeriodRepository creates a new PeriodRepository.
func NewPeriodRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) PeriodRepository {
	return &periodRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.Period {
			return &models.Period{}
		}),
	}
}

type periodRepository struct {
	datastore.BaseRepository[*models.Period]
}

func (r *periodRepository) GetCurrentByGroupID(ctx context.Context, groupID string) (*models.Period, error) {
	var period models.Period
	err := r.Pool().
		DB(ctx, true).
		Where("group_id = ? AND state != ?", groupID, constants.StateDeleted).
		Order("created_at DESC").
		First(&period).
		Error
	return &period, err
}

func (r *periodRepository) GetByParentID(ctx context.Context, parentID string) (*models.Period, error) {
	var period models.Period
	err := r.Pool().DB(ctx, true).Where("parent_period_id = ?", parentID).First(&period).Error
	return &period, err
}

func (r *periodRepository) ListDueToClose(ctx context.Context, now time.Time, limit int) ([]*models.Period, error) {
	var periods []*models.Period
	err := r.Pool().DB(ctx, true).
		Where("state = ? AND end_date IS NOT NULL AND end_date <= ? AND (close_retry_at IS NULL OR close_retry_at <= ?)",
			constants.StateActive, now, now).
		Order("end_date ASC").Limit(limit).Find(&periods).Error
	return periods, err
}

func (r *periodRepository) ListDueForReminder(ctx context.Context, now time.Time, limit int) ([]*models.Period, error) {
	var periods []*models.Period
	err := r.Pool().DB(ctx, true).
		Where("state = ? AND end_date > ? AND next_reminder_at IS NOT NULL AND next_reminder_at <= ?",
			constants.StateActive, now, now).
		Order("next_reminder_at ASC").Limit(limit).Find(&periods).Error
	return periods, err
}
