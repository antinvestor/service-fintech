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

package business

import (
	"context"
	"fmt"
	"time"

	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/stawi/service/events"
	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

const (
	// daysPerWeek is the number of days in a weekly period.
	daysPerWeek = 7
	// daysPerBiweek is the number of days in a biweekly period.
	daysPerBiweek = 14
)

type periodBusiness struct {
	eventsMan fevents.Manager
	tenRepo   repository.TenureRepository
	perRepo   repository.PeriodRepository
}

func NewPeriodBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	tenRepo repository.TenureRepository,
	perRepo repository.PeriodRepository,
) PeriodBusiness {
	return &periodBusiness{eventsMan: eventsMan, tenRepo: tenRepo, perRepo: perRepo}
}

// Open creates a new period within the active tenure for the given group.
// It determines the next position from the latest period, and calculates
// start/end dates based on the period type (WEEKLY=7d, BIWEEKLY=14d, MONTHLY=1mo).
// The first period starts at the tenure start date; subsequent periods start
// where the previous period ended.
func (b *periodBusiness) Open(ctx context.Context, groupID string) (*models.Period, error) {
	logger := util.Log(ctx).WithField("method", "PeriodBusiness.Open").
		WithField("group_id", groupID)

	tenure, err := b.tenRepo.GetActiveByGroupID(ctx, groupID)
	if err != nil {
		return nil, fmt.Errorf("no active tenure for group: %w", err)
	}

	if tenure.State != int32(constants.StateActive) {
		return nil, fmt.Errorf("tenure is not active (state=%d)", tenure.State)
	}

	periodType := tenurePeriodType(tenure)
	nextPosition, startDate, parentPeriodID, err := b.resolveNextPeriod(ctx, tenure)
	if err != nil {
		return nil, err
	}

	if nextPosition > tenure.Duration {
		return nil, fmt.Errorf(
			"tenure duration of %d periods exhausted, close tenure and open a new one",
			tenure.Duration,
		)
	}

	endDate := calculatePeriodEndDate(startDate, periodType)

	period := &models.Period{
		GroupID:        groupID,
		TenureID:       tenure.GetID(),
		StartDate:      &startDate,
		EndDate:        &endDate,
		PeriodType:     int32(periodType),
		Position:       nextPosition,
		ParentPeriodID: parentPeriodID,
		State:          int32(constants.StateActive),
	}
	period.GenID(ctx)
	period.CopyPartitionInfo(&tenure.BaseModel)

	err = b.eventsMan.Emit(ctx, events.PeriodSaveEvent, period)
	if err != nil {
		logger.WithError(err).Error("could not emit period save event")
		return nil, err
	}

	logger.WithField("period_id", period.GetID()).
		WithField("position", nextPosition).
		WithField("start_date", startDate.Format(time.RFC3339)).
		WithField("end_date", endDate.Format(time.RFC3339)).
		Info("new period opened")

	return period, nil
}

// tenurePeriodType extracts the period type from tenure properties, defaulting to weekly.
func tenurePeriodType(tenure *models.Tenure) models.PeriodType {
	if tenure.Properties == nil {
		return models.PeriodTypeWeekly
	}
	v, ok := tenure.Properties["period_type"]
	if !ok {
		return models.PeriodTypeWeekly
	}
	pt, isFloat := v.(float64)
	if !isFloat || pt <= 0 {
		return models.PeriodTypeWeekly
	}
	return models.PeriodType(int32(pt))
}

// resolveNextPeriod determines the next position, start date, and parent period
// from the latest period in a tenure.
func (b *periodBusiness) resolveNextPeriod(
	ctx context.Context,
	tenure *models.Tenure,
) (int32, time.Time, string, error) {
	latestPeriod, err := b.perRepo.GetLastestBy(ctx, map[string]any{
		"tenure_id": tenure.GetID(),
	})
	if err != nil || latestPeriod == nil || latestPeriod.GetID() == "" {
		startDate := time.Now().UTC()
		if tenure.StartDate != nil {
			startDate = *tenure.StartDate
		}
		return 1, startDate, "", nil
	}

	if latestPeriod.State == int32(constants.StateActive) {
		return 0, time.Time{}, "", fmt.Errorf(
			"previous period (id=%s) is still active, close it first", latestPeriod.GetID())
	}

	startDate := time.Now().UTC()
	if latestPeriod.EndDate != nil {
		startDate = *latestPeriod.EndDate
	}

	return latestPeriod.Position + 1, startDate, latestPeriod.GetID(), nil
}

// Close marks a period as shutdown, setting its end date to now if it
// extends beyond the current time.
func (b *periodBusiness) Close(ctx context.Context, periodID string) error {
	logger := util.Log(ctx).WithField("method", "PeriodBusiness.Close").
		WithField("period_id", periodID)

	period, err := b.perRepo.GetByID(ctx, periodID)
	if err != nil {
		return fmt.Errorf("period not found: %w", err)
	}

	if period.State == int32(constants.StateShutdown) || period.State == int32(constants.StateDeleted) {
		return fmt.Errorf("period is already closed (state=%d)", period.State)
	}

	now := time.Now().UTC()
	period.EndDate = &now
	period.State = int32(constants.StateShutdown)

	err = b.eventsMan.Emit(ctx, events.PeriodSaveEvent, period)
	if err != nil {
		logger.WithError(err).Error("could not emit period save event")
		return err
	}

	logger.Info("period closed")
	return nil
}

func (b *periodBusiness) GetCurrent(ctx context.Context, groupID string) (*models.Period, error) {
	return b.perRepo.GetCurrentByGroupID(ctx, groupID)
}

// calculatePeriodEndDate computes the end date for a single period.
func calculatePeriodEndDate(start time.Time, periodType models.PeriodType) time.Time {
	switch periodType {
	case models.PeriodTypeBiweekly:
		return start.AddDate(0, 0, daysPerBiweek)
	case models.PeriodTypeMonthly:
		return start.AddDate(0, 1, 0)
	case models.PeriodTypeUnspecified, models.PeriodTypeWeekly:
		return start.AddDate(0, 0, daysPerWeek)
	default:
		return start.AddDate(0, 0, daysPerWeek)
	}
}
