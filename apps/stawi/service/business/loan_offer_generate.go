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

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"
	"github.com/pitabwire/util/decimalx"
	"github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/calculation"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/messages"
)

// offerExpiryHours is how long an offer stays open when the window's period
// has no end date to close it.
const offerExpiryHours = 72

// Reasons a member is passed over when a window's offers are made.
const (
	skipNotMember     = "not_a_regular_member"
	skipInactive      = "membership_not_active"
	skipNoClient      = "not_registered_with_lender"
	skipOpenLoan      = "has_open_loan"
	skipOpenOffer     = "has_open_offer"
	skipAlreadyOffers = "already_offered"
)

// GenerateForWindow offers a loan to every eligible member of the window's
// group and returns how many offers it made. It is idempotent per (window,
// member): a member already offered in the window is skipped, and a unique
// index refuses a second offer made concurrently. A retried window open
// therefore completes the offers rather than repeating them.
//
// The eligibility rule uses only facts stawi owns or reads through APIs:
//
//   - the membership is a regular member (not an agent or registrar) and is
//     active in identity;
//   - group registration recorded the member's lender client id;
//   - the loans service holds no open loan for that client (pending
//     disbursement, active, delinquent, in default or restructured);
//   - the member has no offer still open or originating in another window.
//
// Every eligible member is offered the same amount: what the group's saving
// policy says a member has saved by now — the window's periodic amount for
// each completed period of the tenure — times the window's leverage. Members'
// actual savings balances live in operations, which has no read API for them
// yet, so the offer cannot be priced off what each member really paid.
func (b *loanOfferBusiness) GenerateForWindow(
	ctx context.Context,
	group *identityv1.ClientGroupObject,
	window *models.LoanWindow,
) (int, error) {
	logger := util.Log(ctx).WithField("method", "LoanOfferBusiness.GenerateForWindow").
		WithField("window_id", window.GetID())

	if window.State != int32(constants.StateActive) {
		return 0, apperrors.NewError(apperrors.Unprocessable, "the loan window is not open")
	}
	if b.members == nil || b.periods == nil {
		return 0, apperrors.NewError(
			apperrors.ServiceUnavailable,
			"group members and periods are required to make offers",
		)
	}
	if b.lender == nil {
		return 0, apperrors.NewError(apperrors.ServiceUnavailable, "the loans service is required to make offers")
	}

	period, err := b.periods.GetByID(ctx, window.PeriodID)
	if err != nil {
		return 0, apperrors.ErrDataNotFound.Extend("loan window period")
	}
	amount := policyOfferAmount(window, period.Position-1)
	if amount <= 0 {
		logger.Info("no savings to lend against yet; no offers made")
		return 0, nil
	}
	expiry := b.offerExpiry(period)

	existing, err := b.offers.GetByLoanWindowID(ctx, window.GetID())
	if err != nil {
		return 0, fmt.Errorf("list window offers: %w", err)
	}
	offered := make(map[string]bool, len(existing))
	for _, offer := range existing {
		offered[offer.MembershipID] = true
	}

	memberships, err := b.members.GetByGroupID(ctx, window.GroupID)
	if err != nil {
		return 0, fmt.Errorf("list group members: %w", err)
	}

	made := 0
	skipped := map[string]int{}
	for _, membership := range memberships {
		if offered[membership.GetId()] {
			skipped[skipAlreadyOffers]++
			continue
		}
		reason, eligErr := b.ineligibility(ctx, window, membership)
		if eligErr != nil {
			return made, eligErr
		}
		if reason != "" {
			skipped[reason]++
			continue
		}

		offer := newWindowOffer(ctx, group, window, membership, amount, expiry)
		created, createErr := b.createOffer(ctx, offer)
		if createErr != nil {
			return made, createErr
		}
		if !created {
			skipped[skipAlreadyOffers]++
			continue
		}
		made++
		b.notifyMember(ctx, offer, messages.GroupLoanOffered, map[string]any{
			messages.VarGroupName: group.GetName(),
			messages.VarAmount:    messages.FormatAmount(offer.Currency, offer.Amount),
			messages.VarCurrency:  offer.Currency,
			messages.VarExpiresOn: messages.FormatDate(offer.ExpiryDate),
		})
	}

	logger.WithField("offers_made", made).WithField("skipped", skipped).
		WithField("members", len(memberships)).Info("loan window offers made")
	return made, nil
}

// policyOfferAmount prices an offer from the group's saving policy:
// periodic amount × completed periods × leverage (hundredths, 190 = 1.90x).
func policyOfferAmount(window *models.LoanWindow, completedPeriods int32) int64 {
	if completedPeriods <= 0 || window.PeriodicAmount <= 0 {
		return 0
	}
	decimals := moneyx.Decimals(window.Currency)
	saved := decimalx.FromMinorUnits(window.PeriodicAmount*int64(completedPeriods), decimals)
	return calculation.CalculateMaxLoanAmount(saved, window.LeverageHundredths).ToMinorUnits(decimals)
}

// offerExpiry closes an offer when the window's period ends, which is the
// deadline members are told about; without an end date it gets a fixed span.
func (b *loanOfferBusiness) offerExpiry(period *models.Period) time.Time {
	now := b.now().UTC()
	if period.EndDate != nil && period.EndDate.After(now) {
		return period.EndDate.UTC()
	}
	return now.Add(offerExpiryHours * time.Hour)
}

// ineligibility returns why a member may not be offered a loan in the
// window, or "" when they may. An error means the answer could not be read
// and generation should be retried.
func (b *loanOfferBusiness) ineligibility(
	ctx context.Context,
	window *models.LoanWindow,
	membership *identityv1.MembershipObject,
) (string, error) {
	if membership.GetMembershipType() != membershipTypeMember {
		return skipNotMember, nil
	}
	if !liveState(membership.GetState()) {
		return skipInactive, nil
	}
	clientID := membershipClientID(membership)
	if clientID == "" {
		return skipNoClient, nil
	}

	open, err := b.offers.CountOpenElsewhere(ctx, membership.GetId(), window.GetID())
	if err != nil {
		return "", fmt.Errorf("count open offers: %w", err)
	}
	if open > 0 {
		return skipOpenOffer, nil
	}

	hasLoan, err := b.lender.HasOpenLoan(ctx, clientID)
	if err != nil {
		return "", err
	}
	if hasLoan {
		return skipOpenLoan, nil
	}
	return "", nil
}

func newWindowOffer(
	ctx context.Context,
	group *identityv1.ClientGroupObject,
	window *models.LoanWindow,
	membership *identityv1.MembershipObject,
	amount int64,
	expiry time.Time,
) *models.LoanOffer {
	offer := &models.LoanOffer{
		MembershipID: membership.GetId(),
		LoanWindowID: window.GetID(),
		PeriodID:     window.PeriodID,
		Amount:       amount,
		Currency:     window.Currency,
		OfferType:    int32(models.LoanOfferTypeOffered),
		Response:     int32(models.LoanOfferResponseNone),
		ExpiryDate:   &expiry,
		Description:  "Loan offer of loan window " + window.GetID(),
		State:        int32(constants.StateActive),
		Properties: data.JSONMap{
			propGroupID:   window.GroupID,
			propGroupName: group.GetName(),
			propProfileID: membership.GetProfileId(),
		},
	}
	offer.GenID(ctx)
	offer.CopyPartitionInfo(&window.BaseModel)
	return offer
}

// createOffer inserts an offer, reporting false when the member already has
// one in the window (a concurrent generation got there first).
func (b *loanOfferBusiness) createOffer(ctx context.Context, offer *models.LoanOffer) (bool, error) {
	err := b.offers.Create(ctx, offer)
	switch {
	case err == nil:
		return true, nil
	case data.ErrorIsDuplicateKey(err):
		return false, nil
	default:
		return false, fmt.Errorf("create loan offer: %w", err)
	}
}
