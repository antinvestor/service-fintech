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

	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/calculation"
	"github.com/antinvestor/service-fintech/pkg/constants"
	stawiproduct "github.com/antinvestor/service-fintech/products/stawi"
)

type loanWindowBusiness struct {
	product     stawiproduct.ProductConfig
	identityCli identityv1connect.IdentityServiceClient
	lwRepo      repository.LoanWindowRepository
	perRepo     repository.PeriodRepository
	tenRepo     repository.TenureRepository
	offers      OfferGenerator
}

func NewLoanWindowBusiness(
	_ context.Context,
	product stawiproduct.ProductConfig,
	identityCli identityv1connect.IdentityServiceClient,
	lwRepo repository.LoanWindowRepository,
	perRepo repository.PeriodRepository,
	tenRepo repository.TenureRepository,
	offers OfferGenerator,
) LoanWindowBusiness {
	return &loanWindowBusiness{
		product:     product,
		identityCli: identityCli,
		lwRepo:      lwRepo,
		perRepo:     perRepo,
		tenRepo:     tenRepo,
		offers:      offers,
	}
}

// Evaluate reports whether the group's cycle position allows a new loan window
// to open. The cycle parameters come from product configuration, overridable
// per group through group properties.
func (b *loanWindowBusiness) Evaluate(ctx context.Context, groupID string) (map[string]interface{}, error) {
	logger := util.Log(ctx).WithField("method", "LoanWindowBusiness.Evaluate")

	group, err := b.getGroup(ctx, groupID)
	if err != nil {
		return nil, err
	}

	completedPeriods := b.completedPeriods(ctx, groupID)

	maturityPeriod := groupInt32Property(group, "loan_maturity_periods", b.product.LoanMaturityPeriods)
	gracePeriod := groupInt32Property(group, "loan_grace_period", b.product.LoanGracePeriod)
	loanTenure := groupInt32Property(group, "loan_tenure_periods", b.product.LoanTenurePeriods)
	coolOff := groupInt32Property(group, "loan_cool_off_periods", 0)

	shouldOpen := calculation.ShouldOpenLoanWindow(completedPeriods, maturityPeriod, gracePeriod, loanTenure, coolOff)
	cycle := calculation.ActiveLoanWindowCycle(completedPeriods, maturityPeriod, gracePeriod, loanTenure, coolOff)

	logger.WithField(fieldGroupID, groupID).
		WithField("completed_periods", completedPeriods).
		WithField("eligible", shouldOpen).
		WithField("cycle_position", cycle).
		Info("loan window evaluation completed")

	// The workflow reads `eligible`, `window_duration` and `window_closes_at`;
	// `should_open` and `cycle_position` are kept for operators reading the raw
	// response. The window closes when the group's current period ends, which
	// is the deadline members are told about.
	return map[string]interface{}{
		fieldGroupID:        groupID,
		fieldEligible:       shouldOpen,
		"should_open":       shouldOpen,
		"window_duration":   loanTenure,
		"window_closes_at":  b.currentPeriodEnd(ctx, groupID),
		"cycle_position":    cycle,
		"completed_periods": completedPeriods,
	}, nil
}

// completedPeriods counts the periods of the group's tenure that came before
// its current one, which is what the loan cycle is measured in. A group with
// no open period has completed none that count.
func (b *loanWindowBusiness) completedPeriods(ctx context.Context, groupID string) int32 {
	period, err := b.perRepo.GetCurrentByGroupID(ctx, groupID)
	if err != nil || period == nil || period.GetID() == "" || period.State != int32(constants.StateActive) {
		return 0
	}
	return period.Position - 1
}

// currentPeriodEnd renders the group's current period end date, or an empty
// string when the group has no open period.
func (b *loanWindowBusiness) currentPeriodEnd(ctx context.Context, groupID string) string {
	period, err := b.perRepo.GetCurrentByGroupID(ctx, groupID)
	if err != nil || period == nil || period.EndDate == nil {
		return ""
	}
	return period.EndDate.UTC().Format(time.RFC3339)
}

// Open creates the group-scoped loan window and makes its members' offers.
// It is idempotent: an active window for the group's current period is
// returned rather than duplicated, and its offers are completed, never
// repeated, so a retry after a failed offer run finishes the job.
func (b *loanWindowBusiness) Open(ctx context.Context, groupID string) (*models.LoanWindow, error) {
	logger := util.Log(ctx).WithField("method", "LoanWindowBusiness.Open").WithField(fieldGroupID, groupID)

	group, err := b.getGroup(ctx, groupID)
	if err != nil {
		return nil, err
	}

	period, err := b.perRepo.GetCurrentByGroupID(ctx, groupID)
	if err != nil || period == nil || period.GetID() == "" {
		return nil, apperrors.ErrDataNotFound.Extend("current period for group")
	}
	if period.State != int32(constants.StateActive) {
		return nil, apperrors.NewError(apperrors.Unprocessable, "the group's current period is not active")
	}

	existing, err := b.lwRepo.GetByGroupID(ctx, groupID)
	if err != nil {
		return nil, err
	}
	var maxPosition int32
	for _, w := range existing {
		if w.PeriodID == period.GetID() && w.State == int32(constants.StateActive) {
			return w, b.makeOffers(ctx, group, w)
		}
		if w.Position > maxPosition {
			maxPosition = w.Position
		}
	}

	// The window lends against the members' periodic savings: a group
	// property can set it, otherwise it is the group's saving amount.
	periodicAmount := groupInt64Property(group, "periodic_amount", group.GetSavingAmount())
	if periodicAmount <= 0 {
		return nil, apperrors.NewError(apperrors.Unprocessable,
			"group has no periodic savings amount configured")
	}

	leverage := groupInt64Property(group, "leverage", b.product.MinLeverage)
	if leverage < b.product.MinLeverage {
		leverage = b.product.MinLeverage
	}
	if b.product.MaxLeverage >= b.product.MinLeverage && leverage > b.product.MaxLeverage {
		leverage = b.product.MaxLeverage
	}

	window := &models.LoanWindow{
		GroupID:            groupID,
		TenureID:           period.TenureID,
		PeriodID:           period.GetID(),
		GracePeriod:        groupInt32Property(group, "loan_grace_period", b.product.LoanGracePeriod),
		LoanTenure:         groupInt32Property(group, "loan_tenure_periods", b.product.LoanTenurePeriods),
		Position:           maxPosition + 1,
		PeriodicAmount:     periodicAmount,
		LeverageHundredths: leverage,
		Currency:           group.GetCurrencyCode(),
		State:              int32(constants.StateActive),
	}
	window.GenID(ctx)
	window.CopyPartitionInfo(&period.BaseModel)

	if createErr := b.lwRepo.Create(ctx, window); createErr != nil {
		return nil, createErr
	}

	logger.WithField("window_id", window.GetID()).Info("loan window opened")
	return window, b.makeOffers(ctx, group, window)
}

// makeOffers offers the window's eligible members a loan.
func (b *loanWindowBusiness) makeOffers(
	ctx context.Context,
	group *identityv1.ClientGroupObject,
	window *models.LoanWindow,
) error {
	if b.offers == nil {
		return apperrors.NewError(apperrors.ServiceUnavailable, "loan offers cannot be made")
	}
	_, err := b.offers.GenerateForWindow(ctx, group, window)
	return err
}

func (b *loanWindowBusiness) getGroup(
	ctx context.Context,
	groupID string,
) (*identityv1.ClientGroupObject, error) {
	if b.identityCli == nil {
		return nil, apperrors.NewError(apperrors.ServiceUnavailable, "identity service is not available")
	}
	resp, err := b.identityCli.ClientGroupGet(ctx, &identityv1.ClientGroupGetRequest{Id: groupID})
	if err != nil {
		return nil, apperrors.ErrDataNotFound.Extend("client group")
	}
	return resp.GetData(), nil
}

// groupInt32Property reads a numeric group property, falling back to the
// product default when it is absent or non-positive.
func groupInt32Property(group *identityv1.ClientGroupObject, key string, fallback int32) int32 {
	if v, ok := groupNumberProperty(group, key); ok {
		return int32(v)
	}
	return fallback
}

func groupInt64Property(group *identityv1.ClientGroupObject, key string, fallback int64) int64 {
	if v, ok := groupNumberProperty(group, key); ok {
		return int64(v)
	}
	return fallback
}

func groupNumberProperty(group *identityv1.ClientGroupObject, key string) (float64, bool) {
	props := group.GetProperties()
	if props == nil {
		return 0, false
	}
	v, ok := props.GetFields()[key]
	if !ok || v.GetNumberValue() <= 0 {
		return 0, false
	}
	return v.GetNumberValue(), true
}
