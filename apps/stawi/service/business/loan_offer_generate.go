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
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
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
	skipInArrears     = "in_arrears"
	skipNoSavings     = "no_savings"
)

// MemberSavingsReader is the part of operations that says where members
// stand on a group's savings. Operations owns the obligations and the money
// paid against them.
type MemberSavingsReader interface {
	GroupMemberStanding(
		ctx context.Context,
		req *operationsv1.GroupMemberStandingRequest,
	) (*operationsv1.GroupMemberStandingResponse, error)
}

// memberSavings is a member's standing in minor units of the window's
// currency.
type memberSavings struct {
	saved   int64
	arrears int64
}

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
//   - the member has no offer still open or originating in another window;
//   - operations holds the member in no arrears: nothing overdue on their
//     savings and no unpaid penalty.
//
// An eligible member is offered what they have actually saved in the group
// times the window's leverage, capped at what the saving policy allows by
// now: the window's periodic amount for each completed period of the
// tenure, times the leverage. A member who has saved nothing is not offered.
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
	limit := policyOfferAmount(window, period.Position-1)
	if limit <= 0 {
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
	savings, err := b.memberSavings(ctx, window, memberships, offered)
	if err != nil {
		return 0, err
	}

	terms := windowTerms{group: group, window: window, limit: limit, expiry: expiry}
	made := 0
	skipped := map[string]int{}
	for _, membership := range memberships {
		if offered[membership.GetId()] {
			skipped[skipAlreadyOffers]++
			continue
		}
		reason, offerErr := b.offerMember(ctx, terms, membership, savings[membership.GetId()])
		if offerErr != nil {
			return made, offerErr
		}
		if reason != "" {
			skipped[reason]++
			continue
		}
		made++
	}

	logger.WithField("offers_made", made).WithField("skipped", skipped).
		WithField("members", len(memberships)).Info("loan window offers made")
	return made, nil
}

// windowTerms are what every offer in a window shares.
type windowTerms struct {
	group  *identityv1.ClientGroupObject
	window *models.LoanWindow
	limit  int64
	expiry time.Time
}

// offerMember offers the member a loan sized off their savings and tells
// them, returning why they were passed over instead, or "" when offered.
func (b *loanOfferBusiness) offerMember(
	ctx context.Context,
	terms windowTerms,
	membership *identityv1.MembershipObject,
	standing memberSavings,
) (string, error) {
	reason, err := b.ineligibility(ctx, terms.window, membership)
	if err != nil || reason != "" {
		return reason, err
	}
	amount, reason := savingsOfferAmount(terms.window, standing, terms.limit)
	if reason != "" {
		return reason, nil
	}

	offer := newWindowOffer(ctx, terms.group, terms.window, membership, amount, terms.expiry)
	created, err := b.createOffer(ctx, offer)
	if err != nil {
		return "", err
	}
	if !created {
		return skipAlreadyOffers, nil
	}
	b.notifyMember(ctx, offer, messages.GroupLoanOffered, map[string]any{
		messages.VarGroupName: terms.group.GetName(),
		messages.VarAmount:    messages.FormatAmount(offer.Currency, offer.Amount),
		messages.VarCurrency:  offer.Currency,
		messages.VarExpiresOn: messages.FormatDate(offer.ExpiryDate),
	})
	return "", nil
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

// savingsOfferAmount sizes a member's offer: what they saved times the
// window's leverage, never above the policy limit. It returns why the member
// gets no offer instead when they are in arrears or saved nothing.
func savingsOfferAmount(window *models.LoanWindow, standing memberSavings, limit int64) (int64, string) {
	if standing.arrears > 0 {
		return 0, skipInArrears
	}
	if standing.saved <= 0 {
		return 0, skipNoSavings
	}
	decimals := moneyx.Decimals(window.Currency)
	saved := decimalx.FromMinorUnits(standing.saved, decimals)
	amount := calculation.CalculateMaxLoanAmount(saved, window.LeverageHundredths).ToMinorUnits(decimals)
	if amount <= 0 {
		return 0, skipNoSavings
	}
	return min(amount, limit), ""
}

// memberSavings asks operations, in one call, where the group's regular
// members not yet offered in the window stand. A member operations does not
// report has saved nothing.
func (b *loanOfferBusiness) memberSavings(
	ctx context.Context,
	window *models.LoanWindow,
	memberships []*identityv1.MembershipObject,
	offered map[string]bool,
) (map[string]memberSavings, error) {
	ids := make([]string, 0, len(memberships))
	for _, m := range memberships {
		if m.GetMembershipType() == membershipTypeMember && !offered[m.GetId()] {
			ids = append(ids, m.GetId())
		}
	}
	standings := make(map[string]memberSavings, len(ids))
	if len(ids) == 0 {
		return standings, nil
	}
	if b.savings == nil {
		return nil, apperrors.NewError(apperrors.ServiceUnavailable,
			"members' savings are required to size offers")
	}

	resp, err := b.savings.GroupMemberStanding(ctx, &operationsv1.GroupMemberStandingRequest{
		GroupId:       window.GroupID,
		MembershipIds: ids,
		CurrencyCode:  window.Currency,
	})
	if err != nil {
		return nil, fmt.Errorf("read members' savings: %w", err)
	}
	decimals := moneyx.Decimals(window.Currency)
	for _, row := range resp.GetMembers() {
		saved, arrears := row.GetSaved(), row.GetArrears()
		for _, amount := range []*commonv1.Money{saved, arrears} {
			if code := amount.GetCurrencyCode(); code != "" && !strings.EqualFold(code, window.Currency) {
				return nil, apperrors.NewError(apperrors.Unprocessable,
					"operations reported savings in another currency")
			}
		}
		standings[row.GetMembershipId()] = memberSavings{
			saved:   moneyx.ToSmallestUnit(saved, decimals),
			arrears: moneyx.ToSmallestUnit(arrears, decimals),
		}
	}
	return standings, nil
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
