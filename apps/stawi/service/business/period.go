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
	"time"

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

const (
	// daysPerWeek is the number of days in a weekly period.
	daysPerWeek = 7
	// daysPerBiweek is the number of days in a biweekly period.
	daysPerBiweek = 14

	// propertyFrozenAt marks a period whose contributions are closed pending
	// reconciliation; propertyExtension* record why and how often a period's
	// end date was pushed out.
	propertyFrozenAt        = "frozen_at"
	propertyExtensionCount  = "extension_count"
	propertyExtensionReason = "extension_reason"
)

type periodBusiness struct {
	tenRepo repository.TenureRepository
	perRepo repository.PeriodRepository
}

func NewPeriodBusiness(
	_ context.Context,
	tenRepo repository.TenureRepository,
	perRepo repository.PeriodRepository,
) PeriodBusiness {
	return &periodBusiness{tenRepo: tenRepo, perRepo: perRepo}
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
		return nil, apperrors.ErrDataNotFound.Extend("active tenure for group")
	}

	if tenure.State != int32(constants.StateActive) {
		return nil, apperrors.NewError(apperrors.Unprocessable, "group tenure is not active")
	}

	periodType := tenurePeriodType(tenure)
	nextPosition, startDate, parentPeriodID, err := b.resolveNextPeriod(ctx, tenure)
	if err != nil {
		return nil, err
	}

	if nextPosition > tenure.Duration {
		return nil, apperrors.NewError(apperrors.Unprocessable,
			"tenure duration exhausted, close the tenure and open a new one")
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

	// Synchronous insert. The unique index on (tenure_id, position) is what
	// actually enforces "one period per position"; the read-then-emit version
	// let two concurrent opens both pass the guard above.
	if err = b.perRepo.Create(ctx, period); err != nil {
		if data.ErrorIsDuplicateKey(err) {
			return nil, apperrors.NewError(apperrors.Conflict,
				"a period is already open at this position for the tenure")
		}
		logger.WithError(err).Error("could not persist new period")
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
		return 0, time.Time{}, "", apperrors.NewError(apperrors.Unprocessable,
			"the previous period is still active, close it first")
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
		return apperrors.ErrDataNotFound.Extend("period")
	}

	if period.State == int32(constants.StateShutdown) || period.State == int32(constants.StateDeleted) {
		return apperrors.NewError(apperrors.Unprocessable, "period is already closed")
	}

	now := time.Now().UTC()
	period.EndDate = &now
	period.State = int32(constants.StateShutdown)

	// Versioned update: a concurrent close matches no row and is reported as a
	// conflict rather than silently closing the period twice.
	rows, err := b.perRepo.Update(ctx, period)
	if err != nil {
		logger.WithError(err).Error("could not close period")
		return err
	}
	if rows == 0 {
		return apperrors.NewError(apperrors.Conflict, "period changed while it was being closed")
	}

	logger.Info("period closed")
	return nil
}

// Freeze stops further contributions being counted against a period while it
// is being reconciled and closed. It is idempotent: a period that is already
// frozen is returned unchanged.
func (b *periodBusiness) Freeze(ctx context.Context, periodID string) (*models.Period, error) {
	period, err := b.perRepo.GetByID(ctx, periodID)
	if err != nil {
		return nil, apperrors.ErrDataNotFound.Extend("period")
	}
	if period.State != int32(constants.StateActive) {
		return nil, apperrors.NewError(apperrors.Unprocessable,
			"only an active period can be frozen")
	}
	if period.Properties.GetString(propertyFrozenAt) != "" {
		return period, nil
	}

	period.Properties = mergeProperties(period.Properties, map[string]any{
		propertyFrozenAt: time.Now().UTC().Format(time.RFC3339),
	})

	rows, err := b.perRepo.Update(ctx, period)
	if err != nil {
		return nil, err
	}
	if rows == 0 {
		return nil, apperrors.NewError(apperrors.Conflict, "period changed while it was being frozen")
	}
	return period, nil
}

// Extend pushes an open period's end date out by one more period length. The
// reason and the running count of extensions stay on the row so a period that
// keeps being extended is visible rather than silently drifting.
func (b *periodBusiness) Extend(ctx context.Context, periodID, reason string) (*models.Period, error) {
	period, err := b.perRepo.GetByID(ctx, periodID)
	if err != nil {
		return nil, apperrors.ErrDataNotFound.Extend("period")
	}
	if period.State != int32(constants.StateActive) {
		return nil, apperrors.NewError(apperrors.Unprocessable, "only an active period can be extended")
	}
	if period.Properties.GetString(propertyFrozenAt) != "" {
		return nil, apperrors.NewError(apperrors.Unprocessable, "a frozen period cannot be extended")
	}

	base := time.Now().UTC()
	if period.EndDate != nil && period.EndDate.After(base) {
		base = *period.EndDate
	}
	newEnd := calculatePeriodEndDate(base, models.PeriodType(period.PeriodType))
	period.EndDate = &newEnd
	period.Properties = mergeProperties(period.Properties, map[string]any{
		propertyExtensionCount:  periodExtensionCount(period) + 1,
		propertyExtensionReason: reason,
	})

	rows, err := b.perRepo.Update(ctx, period)
	if err != nil {
		return nil, err
	}
	if rows == 0 {
		return nil, apperrors.NewError(apperrors.Conflict, "period changed while it was being extended")
	}
	return period, nil
}

// periodExtensionCount reads how many times a period has already been extended.
func periodExtensionCount(period *models.Period) int64 {
	if period.Properties == nil {
		return 0
	}
	switch typed := period.Properties[propertyExtensionCount].(type) {
	case float64:
		return int64(typed)
	case int64:
		return typed
	default:
		return 0
	}
}

// mergeProperties returns a copy of base with overrides applied, so a caller
// never mutates the map still held by another reader.
func mergeProperties(base data.JSONMap, overrides map[string]any) data.JSONMap {
	merged := data.JSONMap{}
	for k, v := range base {
		merged[k] = v
	}
	for k, v := range overrides {
		merged[k] = v
	}
	return merged
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
