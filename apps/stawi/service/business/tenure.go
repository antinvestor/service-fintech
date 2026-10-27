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

	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
	stawiproduct "github.com/antinvestor/service-fintech/products/stawi"
)

const (
	tenureDaysPerWeek   = 7
	tenureDaysPerBiweek = 14
)

type tenureBusiness struct {
	product     stawiproduct.ProductConfig
	identityCli identityv1connect.IdentityServiceClient
	tenRepo     repository.TenureRepository
	perRepo     repository.PeriodRepository
}

func NewTenureBusiness(
	_ context.Context,
	product stawiproduct.ProductConfig,
	identityCli identityv1connect.IdentityServiceClient,
	tenRepo repository.TenureRepository,
	perRepo repository.PeriodRepository,
) TenureBusiness {
	return &tenureBusiness{product: product, identityCli: identityCli, tenRepo: tenRepo, perRepo: perRepo}
}

// Open creates a new tenure for the given group.
// It determines the next position by looking up the latest tenure,
// computes duration from group properties (default 52), and calculates
// the end date based on period type and duration.
func (b *tenureBusiness) Open(ctx context.Context, groupID string) (*models.Tenure, error) {
	logger := util.Log(ctx).WithField("method", "TenureBusiness.Open").
		WithField("group_id", groupID)

	// Get the group to read properties
	grpResp, err := b.identityCli.ClientGroupGet(ctx, &identityv1.ClientGroupGetRequest{Id: groupID})
	if err != nil {
		return nil, apperrors.ErrDataNotFound.Extend("client group")
	}
	group := grpResp.GetData()

	// Ensure no active tenure already exists
	existing, err := b.tenRepo.GetActiveByGroupID(ctx, groupID)
	if err == nil && existing != nil && existing.State == int32(constants.StateActive) {
		return nil, apperrors.NewError(apperrors.Conflict, "group already has an active tenure")
	}

	// Determine next position from latest tenure
	var nextPosition int32 = 1
	latestTenure, err := b.tenRepo.GetLastestBy(ctx, map[string]any{fieldGroupID: groupID})
	if err == nil && latestTenure != nil {
		nextPosition = latestTenure.Position + 1
	}

	// Duration defaults to the product's group life, overridable per group.
	duration := b.product.GroupLifeDuration
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

	// Synchronous insert. The partial unique index on group_id for active
	// tenures is what makes "one active tenure per group" hold under
	// concurrency; the guard above only narrows the common case.
	if err = b.tenRepo.Create(ctx, tenure); err != nil {
		if data.ErrorIsDuplicateKey(err) {
			return nil, apperrors.NewError(apperrors.Conflict, "group already has an active tenure")
		}
		logger.WithError(err).Error("could not persist new tenure")
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
		return apperrors.ErrDataNotFound.Extend("tenure")
	}

	if tenure.State == int32(constants.StateShutdown) || tenure.State == int32(constants.StateDeleted) {
		return apperrors.NewError(apperrors.Unprocessable, "tenure is already closed")
	}

	now := time.Now().UTC()
	tenure.EndDate = &now
	tenure.State = int32(constants.StateShutdown)

	// The tenure is closed before its period: a period left open by a
	// failed write is still due, and closing it again finishes the job,
	// whereas a closed period under an open tenure would be stranded.
	rows, err := b.tenRepo.Update(ctx, tenure)
	if err != nil {
		logger.WithError(err).Error("could not close tenure")
		return err
	}
	if rows == 0 {
		return apperrors.NewError(apperrors.Conflict, "tenure changed while it was being closed")
	}

	currentPeriod, perErr := b.perRepo.GetCurrentByGroupID(ctx, tenure.GroupID)
	if perErr == nil && currentPeriod != nil && currentPeriod.TenureID == tenureID &&
		currentPeriod.State == int32(constants.StateActive) {
		if currentPeriod.EndDate == nil || currentPeriod.EndDate.After(now) {
			currentPeriod.EndDate = &now
		}
		currentPeriod.State = int32(constants.StateShutdown)
		if _, perErr = b.perRepo.Update(ctx, currentPeriod); perErr != nil {
			return fmt.Errorf("could not close active period during tenure close: %w", perErr)
		}
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
