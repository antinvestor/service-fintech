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

	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"connectrpc.com/connect"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/stawi/service/events"
	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

const (
	defaultTenureDuration = int32(52)
	tenureDaysPerWeek     = 7
	tenureDaysPerBiweek   = 14
)

type tenureBusiness struct {
	eventsMan   fevents.Manager
	identityCli identityv1connect.IdentityServiceClient
	tenRepo     repository.TenureRepository
	perRepo     repository.PeriodRepository
}

func NewTenureBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	identityCli identityv1connect.IdentityServiceClient,
	tenRepo repository.TenureRepository,
	perRepo repository.PeriodRepository,
) TenureBusiness {
	return &tenureBusiness{eventsMan: eventsMan, identityCli: identityCli, tenRepo: tenRepo, perRepo: perRepo}
}

// Open creates a new tenure for the given group.
// It determines the next position by looking up the latest tenure,
// computes duration from group properties (default 52), and calculates
// the end date based on period type and duration.
func (b *tenureBusiness) Open(ctx context.Context, groupID string) (*models.Tenure, error) {
	logger := util.Log(ctx).WithField("method", "TenureBusiness.Open").
		WithField("group_id", groupID)

	// Get the group to read properties
	grpResp, err := b.identityCli.ClientGroupGet(ctx, connect.NewRequest(
		&identityv1.ClientGroupGetRequest{Id: groupID},
	))
	if err != nil {
		return nil, fmt.Errorf("group not found: %w", err)
	}
	group := grpResp.Msg.GetData()

	// Ensure no active tenure already exists
	existing, err := b.tenRepo.GetActiveByGroupID(ctx, groupID)
	if err == nil && existing != nil && existing.State == int32(constants.StateActive) {
		return nil, fmt.Errorf("group already has an active tenure (id=%s)", existing.GetID())
	}

	// Determine next position from latest tenure
	var nextPosition int32 = 1
	latestTenure, err := b.tenRepo.GetLastestBy(ctx, map[string]any{fieldGroupID: groupID})
	if err == nil && latestTenure != nil {
		nextPosition = latestTenure.Position + 1
	}

	// Duration defaults to 52 periods, overridable from group properties
	duration := defaultTenureDuration
	if props := group.GetProperties(); props != nil {
		if v, ok := props.GetFields()["tenure_duration"]; ok && v.GetNumberValue() > 0 {
			duration = int32(v.GetNumberValue())
		}
	}

	// Determine period type for end date calculation (default WEEKLY)
	periodType := models.PeriodTypeWeekly
	if props := group.GetProperties(); props != nil {
		if v, ok := props.GetFields()["period_type"]; ok && v.GetNumberValue() > 0 {
			periodType = models.PeriodType(int32(v.GetNumberValue()))
		}
	}

	// Calculate start and end dates
	now := time.Now().UTC()
	endDate := calculateTenureEndDate(now, periodType, duration)

	tenure := &models.Tenure{
		GroupID:   groupID,
		StartDate: &now,
		EndDate:   &endDate,
		Duration:  duration,
		Position:  nextPosition,
		Welcomed:  false,
		State:     int32(constants.StateActive),
	}
	tenure.GenID(ctx)

	err = b.eventsMan.Emit(ctx, events.TenureSaveEvent, tenure)
	if err != nil {
		logger.WithError(err).Error("could not emit tenure save event")
		return nil, err
	}

	logger.WithField("tenure_id", tenure.GetID()).
		WithField("position", nextPosition).
		WithField("duration", duration).
		Info("new tenure opened")

	return tenure, nil
}

// Close marks a tenure as shutdown. It also closes any active period
// within the tenure.
func (b *tenureBusiness) Close(ctx context.Context, tenureID string) error {
	logger := util.Log(ctx).WithField("method", "TenureBusiness.Close").
		WithField("tenure_id", tenureID)

	tenure, err := b.tenRepo.GetByID(ctx, tenureID)
	if err != nil {
		return fmt.Errorf("tenure not found: %w", err)
	}

	if tenure.State == int32(constants.StateShutdown) || tenure.State == int32(constants.StateDeleted) {
		return fmt.Errorf("tenure is already closed (state=%d)", tenure.State)
	}

	// Close any active period in this tenure
	currentPeriod, perErr := b.perRepo.GetCurrentByGroupID(ctx, tenure.GroupID)
	if perErr == nil && currentPeriod != nil && currentPeriod.TenureID == tenureID {
		if currentPeriod.State == int32(constants.StateActive) {
			now := time.Now().UTC()
			currentPeriod.EndDate = &now
			currentPeriod.State = int32(constants.StateShutdown)
			if emitErr := b.eventsMan.Emit(ctx, events.PeriodSaveEvent, currentPeriod); emitErr != nil {
				logger.WithError(emitErr).Warn("could not close active period during tenure close")
			}
		}
	}

	now := time.Now().UTC()
	tenure.EndDate = &now
	tenure.State = int32(constants.StateShutdown)

	err = b.eventsMan.Emit(ctx, events.TenureSaveEvent, tenure)
	if err != nil {
		logger.WithError(err).Error("could not emit tenure save event")
		return err
	}

	logger.Info("tenure closed")
	return nil
}

func (b *tenureBusiness) GetActive(ctx context.Context, groupID string) (*models.Tenure, error) {
	return b.tenRepo.GetActiveByGroupID(ctx, groupID)
}

// calculateTenureEndDate computes the end date for a tenure based on
// the period type and number of periods (duration).
func calculateTenureEndDate(start time.Time, periodType models.PeriodType, duration int32) time.Time {
	switch periodType {
	case models.PeriodTypeBiweekly:
		return start.AddDate(0, 0, int(duration)*tenureDaysPerBiweek)
	case models.PeriodTypeMonthly:
		return start.AddDate(0, int(duration), 0)
	case models.PeriodTypeUnspecified, models.PeriodTypeWeekly:
		return start.AddDate(0, 0, int(duration)*tenureDaysPerWeek)
	default:
		return start.AddDate(0, 0, int(duration)*tenureDaysPerWeek)
	}
}
