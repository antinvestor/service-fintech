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
	"slices"
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/notify"
	stawiproduct "github.com/antinvestor/service-fintech/products/stawi"
)

// minorUnitsToMoney converts minor units and a currency code to a
// *commonv1.Money using the currency's ISO-4217 exponent.
func minorUnitsToMoney(v int64, currencyCode string) *commonv1.Money {
	return moneyx.FromMinorUnitsByCurrency(currencyCode, v)
}

// Offer properties stawi keeps beside the columns.
const (
	propGroupID       = "group_id"
	propGroupName     = "group_name"
	propProfileID     = "profile_id"
	propAcceptedAt    = "accepted_at"
	propLastError     = "origination_error"
	propFailureReason = "failure_reason"
	propClosedReason  = "closed_reason"
	propLoanCancelled = "loan_cancelled"
	propAttemptUntil  = "origination_attempt_until"
)

// LoanOfferDeps are the collaborators of the loan offer business.
type LoanOfferDeps struct {
	Product  stawiproduct.ProductConfig
	Offers   repository.LoanOfferRepository
	Periods  PeriodReader
	Members  MemberLister
	Identity identityv1connect.IdentityServiceClient
	// Clients is the lender's client registry (field service); a member's
	// client row is checked against their profile before money is lent.
	Clients  fieldv1connect.FieldServiceClient
	Profiles profilev1connect.ProfileServiceClient
	Lender   GroupLender
	Notifier *notify.Notifier
}

type loanOfferBusiness struct {
	product  stawiproduct.ProductConfig
	offers   repository.LoanOfferRepository
	periods  PeriodReader
	members  MemberLister
	identity identityv1connect.IdentityServiceClient
	clients  fieldv1connect.FieldServiceClient
	profiles profilev1connect.ProfileServiceClient
	lender   GroupLender
	notifier *notify.Notifier
	now      func() time.Time
}

// NewLoanOfferBusiness builds the business that offers group loans, and
// originates and disburses accepted ones through the loans service.
func NewLoanOfferBusiness(_ context.Context, deps LoanOfferDeps) LoanOfferBusiness {
	return &loanOfferBusiness{
		product:  deps.Product,
		offers:   deps.Offers,
		periods:  deps.Periods,
		members:  deps.Members,
		identity: deps.Identity,
		clients:  deps.Clients,
		profiles: deps.Profiles,
		lender:   deps.Lender,
		notifier: deps.Notifier,
		now:      time.Now,
	}
}

// Respond records a member's answer to an offer of the group's. A member
// answers only their own offer; staff (owner, admin, operator) and internal
// services may answer any.
//
// Accepting starts origination at once. A loans service that is briefly
// unavailable leaves the offer accepted with origination pending, which a
// later Respond, CreateLoanAccount or ResumePendingOrigination finishes; a
// refusal marks the offer failed and is returned. Answering an accepted
// offer with accept again resumes it rather than starting a second loan.
func (b *loanOfferBusiness) Respond(
	ctx context.Context,
	groupID, offerID string,
	response int32,
) (*models.LoanOffer, error) {
	logger := util.Log(ctx).WithField("method", "LoanOfferBusiness.Respond").WithField("offer_id", offerID)

	if response <= int32(models.LoanOfferResponseNone) || response > int32(models.LoanOfferResponseCustom) {
		return nil, apperrors.NewError(apperrors.BadRequest, "loan offer response is out of range")
	}

	offer, err := b.offers.GetByID(ctx, offerID)
	if err != nil {
		return nil, apperrors.ErrDataNotFound.Extend("loan offer")
	}
	if err = b.authorizeOfferResponse(ctx, groupID, offer); err != nil {
		return nil, err
	}

	if offer.Response == int32(models.LoanOfferResponseAccept) {
		if response != int32(models.LoanOfferResponseAccept) {
			return nil, apperrors.NewError(apperrors.Unprocessable, "loan offer has already been accepted")
		}
		return b.settleAcceptance(ctx, offer)
	}
	if offer.Response != int32(models.LoanOfferResponseNone) || offer.State != int32(constants.StateActive) {
		return nil, apperrors.NewError(apperrors.Unprocessable, "loan offer is no longer open")
	}
	// Expiry is enforced here; ExpireStale only tidies offers nobody answered.
	if offer.ExpiryDate != nil && !b.now().Before(*offer.ExpiryDate) {
		return nil, apperrors.NewError(apperrors.Gone, "loan offer has expired")
	}

	offer.Response = response
	if response != int32(models.LoanOfferResponseAccept) {
		offer.State = int32(constants.StateInactive)
		setProp(offer, propClosedReason, "declined")
		if err = b.save(ctx, offer); err != nil {
			return nil, err
		}
		logger.WithField("response", response).Info("loan offer declined")
		return offer, nil
	}

	offer.OriginationStatus = models.OriginationPending
	setProp(offer, propAcceptedAt, b.now().UTC().Format(time.RFC3339))
	if err = b.save(ctx, offer); err != nil {
		return nil, err
	}
	logger.Info("loan offer accepted")
	return b.settleAcceptance(ctx, offer)
}

// settleAcceptance drives an accepted offer's origination. A transient
// failure is not the member's problem: the acceptance stands and the offer
// is returned pending.
func (b *loanOfferBusiness) settleAcceptance(ctx context.Context, offer *models.LoanOffer) (*models.LoanOffer, error) {
	err := b.advance(ctx, offer)
	switch {
	case offer.OriginationStatus == models.OriginationFailed:
		return offer, failedOfferError(offer)
	case err != nil:
		util.Log(ctx).WithError(err).WithField("offer_id", offer.GetID()).
			Warn("loan offer accepted; origination pending")
	}
	return offer, nil
}

// offerResponderRoles may answer any member's offer.
//
//nolint:gochecknoglobals // immutable role list
var offerResponderRoles = []string{"owner", "admin", "operator"}

// authorizeOfferResponse checks the offer belongs to the group and that the
// caller is its member, staff or an internal service. An offer of another
// group is reported as not found, without revealing it.
func (b *loanOfferBusiness) authorizeOfferResponse(ctx context.Context, groupID string, offer *models.LoanOffer) error {
	if b.identity == nil {
		return apperrors.NewError(apperrors.ServiceUnavailable, "the identity service is required to answer an offer")
	}
	resp, err := b.identity.MembershipGet(ctx, &identityv1.MembershipGetRequest{Id: offer.MembershipID})
	if err != nil {
		return fmt.Errorf("membership get: %w", err)
	}
	membership := resp.GetData()
	if membership.GetGroupId() != groupID {
		return apperrors.ErrDataNotFound.Extend("loan offer")
	}
	claims := security.ClaimsFromContext(ctx)
	if claims == nil || claims.IsInternalSystem() {
		return nil
	}
	for _, role := range claims.GetRoles() {
		if slices.ContainsFunc(offerResponderRoles, func(r string) bool { return strings.EqualFold(r, role) }) {
			return nil
		}
	}
	if claims.GetProfileID() == "" || membership.GetProfileId() != claims.GetProfileID() {
		return apperrors.NewError(apperrors.Forbidden, "a member may only answer their own loan offer")
	}
	return nil
}

// CreateLoanAccount drives an accepted offer's origination as far as it can
// go and reports where it stands. It is the staff and workflow entry to the
// same idempotent steps Respond runs, so calling it on an offer that already
// has its loan or its disbursement repeats nothing.
func (b *loanOfferBusiness) CreateLoanAccount(ctx context.Context, groupID, offerID string) (map[string]any, error) {
	offer, err := b.offers.GetByID(ctx, offerID)
	if err != nil {
		return nil, apperrors.ErrDataNotFound.Extend("loan offer")
	}
	// The route names a group: an offer of another group's member is not
	// found there.
	membership, err := b.identity.MembershipGet(ctx, &identityv1.MembershipGetRequest{Id: offer.MembershipID})
	if err != nil || membership.GetData().GetGroupId() != groupID {
		return nil, apperrors.ErrDataNotFound.Extend("loan offer")
	}
	if offer.Response != int32(models.LoanOfferResponseAccept) {
		return nil, apperrors.NewError(apperrors.Unprocessable, "loan offer has not been accepted")
	}
	if offer.OriginationStatus == "" {
		// Accepted before origination was tracked on the offer.
		offer.OriginationStatus = models.OriginationPending
	}
	err = b.advance(ctx, offer)
	if offer.OriginationStatus == models.OriginationFailed {
		return nil, failedOfferError(offer)
	}
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"offer_id":           offer.GetID(),
		"amount":             offer.Amount,
		"currency":           offer.Currency,
		fieldMembershipID:    offer.MembershipID,
		"loan_request_id":    offer.ApplicationID,
		"loan_account_id":    offer.LoanAccountID,
		"disbursement_id":    offer.DisbursementID,
		"origination_status": offer.OriginationStatus,
	}, nil
}

// errOfferChanged reports a write that lost to a concurrent one; the caller
// retries and resumes from what the winner recorded.
var errOfferChanged = apperrors.NewError(apperrors.Conflict, "the loan offer was changed by another request")

// save writes the offer under its version, so two requests racing on one
// offer cannot both record a step.
func (b *loanOfferBusiness) save(ctx context.Context, offer *models.LoanOffer) error {
	rows, err := b.offers.Update(ctx, offer)
	if err != nil {
		return fmt.Errorf("save loan offer: %w", err)
	}
	if rows == 0 {
		return errOfferChanged
	}
	return nil
}

func setProp(offer *models.LoanOffer, key string, value any) {
	if offer.Properties == nil {
		offer.Properties = data.JSONMap{}
	}
	offer.Properties[key] = value
}

func propString(offer *models.LoanOffer, key string) string {
	if offer.Properties == nil {
		return ""
	}
	v, _ := offer.Properties[key].(string)
	return v
}

// failedOfferError is what a caller is told about an offer whose loan could
// not be made.
func failedOfferError(offer *models.LoanOffer) error {
	reason := propString(offer, propFailureReason)
	if reason == "" {
		reason = "the loan could not be made"
	}
	return apperrors.NewError(apperrors.Unprocessable, "loan offer origination failed: "+reason)
}
