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
	"errors"
	"fmt"
	"io"
	"slices"
	"strings"
	"time"

	"github.com/pitabwire/frame/v3/security"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"

	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"google.golang.org/protobuf/types/known/structpb"

	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	ledgerv1 "buf.build/gen/go/antinvestor/ledger/protocolbuffers/go/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"
	"github.com/pitabwire/util/decimalx"
	"github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/stawi/service/events"
	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	"github.com/antinvestor/service-fintech/pkg/calculation"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/payout"
	stawiproduct "github.com/antinvestor/service-fintech/products/stawi"

	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

const (
	// offerExpiryHours is the number of hours before a loan offer expires.
	offerExpiryHours = 72
	// membershipTypeMember is the membership type value for regular members.
	membershipTypeMember = int32(3)
	// statementPageLimit keeps the balance lookup to a single small page: only
	// the closing balance is read, never the entries.
	statementPageLimit = 1
)

// minorUnitsToMoney converts minor units and a currency code to a
// *commonv1.Money using the currency's ISO-4217 exponent.
func minorUnitsToMoney(v int64, currencyCode string) *commonv1.Money {
	return moneyx.FromMinorUnitsByCurrency(currencyCode, v)
}

type loanOfferBusiness struct {
	product     stawiproduct.ProductConfig
	eventsMan   fevents.Manager
	loRepo      repository.LoanOfferRepository
	lwRepo      repository.LoanWindowRepository
	identityCli identityv1connect.IdentityServiceClient
	clients     *clients.PlatformClients
}

func NewLoanOfferBusiness(
	_ context.Context,
	product stawiproduct.ProductConfig,
	eventsMan fevents.Manager,
	loRepo repository.LoanOfferRepository,
	lwRepo repository.LoanWindowRepository,
	identityCli identityv1connect.IdentityServiceClient,
	pc *clients.PlatformClients,
) LoanOfferBusiness {
	return &loanOfferBusiness{
		product:     product,
		eventsMan:   eventsMan,
		loRepo:      loRepo,
		lwRepo:      lwRepo,
		identityCli: identityCli,
		clients:     pc,
	}
}

func (b *loanOfferBusiness) GenerateForWindow(ctx context.Context, windowID string) (interface{}, error) {
	logger := util.Log(ctx).WithField("method", "LoanOfferBusiness.GenerateForWindow")

	// Load loan window
	window, err := b.lwRepo.GetByID(ctx, windowID)
	if err != nil {
		return nil, fmt.Errorf("loan window not found: %w", err)
	}

	if window.State != int32(constants.StateActive) {
		return nil, fmt.Errorf("loan window is not active (state=%d)", window.State)
	}

	// Get all active members in the window's group via identity SDK
	members, err := b.getMembersByGroupID(ctx, window.GroupID)
	if err != nil {
		return nil, fmt.Errorf("could not load memberships for group %s: %w", window.GroupID, err)
	}

	// Check for existing offers in this window to avoid duplicates
	existingOffers, err := b.loRepo.GetByLoanWindowID(ctx, windowID)
	if err != nil {
		logger.WithError(err).Warn("could not check existing offers, proceeding")
	}
	existingByMember := make(map[string]bool)
	for _, offer := range existingOffers {
		existingByMember[offer.MembershipID] = true
	}

	if b.clients == nil || b.clients.LedgerClient == nil {
		return nil, apperrors.NewError(apperrors.ServiceUnavailable,
			"ledger service is required to price loan offers from member savings")
	}

	leverage := b.clampLeverage(ctx, window.LeverageHundredths)
	decimals := moneyx.Decimals(window.Currency)

	var offersGenerated int
	var maxOfferAmount int64
	expiryTime := time.Now().Add(offerExpiryHours * time.Hour)

	for _, mem := range members {
		memberID := mem.GetId()

		// Skip non-regular members (agents, registrars)
		if mem.GetMembershipType() != membershipTypeMember {
			continue
		}

		// Skip if offer already exists for this member in this window
		if existingByMember[memberID] {
			logger.WithField("member_id", memberID).Debug("offer already exists, skipping")
			continue
		}

		// Price the offer off the member's own accumulated savings balance.
		// Leveraging a single period's contribution would offer every member
		// in the group the same loan regardless of what they have saved.
		savings, balErr := b.memberSavingsBalance(ctx, memberID, window.Currency)
		if balErr != nil {
			return nil, fmt.Errorf("could not read savings balance for member %s: %w", memberID, balErr)
		}

		savingsDec := decimalx.FromMinorUnits(savings, decimals)
		maxLoanDec := calculation.CalculateMaxLoanAmount(savingsDec, leverage)
		maxLoan := maxLoanDec.ToMinorUnits(decimals)
		if maxLoan <= 0 {
			logger.WithField("member_id", memberID).Debug("max loan is zero, skipping")
			continue
		}

		offer := &models.LoanOffer{
			MembershipID: memberID,
			LoanWindowID: windowID,
			PeriodID:     window.PeriodID,
			Amount:       maxLoan,
			Currency:     window.Currency,
			OfferType:    int32(models.LoanOfferTypeOffered),
			Response:     int32(models.LoanOfferResponseNone),
			ExpiryDate:   &expiryTime,
			Description:  fmt.Sprintf("Loan offer for window %s, max amount %d", windowID, maxLoan),
			State:        int32(constants.StateActive),
		}
		offer.GenID(ctx)

		if emitErr := b.eventsMan.Emit(ctx, events.LoanOfferSaveEvent, offer); emitErr != nil {
			logger.WithError(emitErr).WithField("member_id", memberID).
				Error("could not create loan offer")
			continue
		}

		offersGenerated++
		if maxLoan > maxOfferAmount {
			maxOfferAmount = maxLoan
		}
	}

	logger.WithField("window_id", windowID).
		WithField("offers_generated", offersGenerated).
		WithField("members_processed", len(members)).
		Info("loan offer generation completed")

	// offer_count and max_amount are what the origination workflow tells the
	// member; window_id and offers_generated are kept for operators.
	return map[string]interface{}{
		"window_id":        windowID,
		"offers_generated": offersGenerated,
		"offer_count":      offersGenerated,
		"max_amount":       maxOfferAmount,
		fieldCurrency:      window.Currency,
	}, nil
}

// Respond records the answer to an offer of the group's. A member answers
// only their own offer; staff (owner, admin, operator) and internal
// services may answer any.
func (b *loanOfferBusiness) Respond(ctx context.Context, groupID, offerID string, response int32) error {
	logger := util.Log(ctx).WithField("method", "LoanOfferBusiness.Respond")

	if response <= int32(models.LoanOfferResponseNone) || response > int32(models.LoanOfferResponseCustom) {
		return apperrors.NewError(apperrors.BadRequest, "loan offer response is out of range")
	}

	offer, err := b.loRepo.GetByID(ctx, offerID)
	if err != nil {
		return apperrors.ErrDataNotFound.Extend("loan offer")
	}
	if err = b.authorizeOfferResponse(ctx, groupID, offer); err != nil {
		return err
	}

	if offer.State != int32(constants.StateActive) {
		return apperrors.NewError(apperrors.Unprocessable, "loan offer is no longer active")
	}

	if offer.ExpiryDate != nil && time.Now().After(*offer.ExpiryDate) {
		offer.State = int32(constants.StateInactive)
		if emitErr := b.eventsMan.Emit(ctx, events.LoanOfferSaveEvent, offer); emitErr != nil {
			logger.WithError(emitErr).Warn("could not retire expired loan offer")
		}
		return apperrors.NewError(apperrors.Gone, "loan offer has expired")
	}

	offer.Response = response

	// If accepted, keep active for funding. If rejected/expired/blocked, mark inactive
	if response != int32(models.LoanOfferResponseAccept) {
		offer.State = int32(constants.StateInactive)
	}

	logger.WithField("offer_id", offerID).
		WithField("response", response).
		Info("loan offer response recorded")

	return b.eventsMan.Emit(ctx, events.LoanOfferSaveEvent, offer)
}

// offerResponderRoles may answer any member's offer.
//
//nolint:gochecknoglobals // immutable role list
var offerResponderRoles = []string{"owner", "admin", "operator"}

// authorizeOfferResponse checks the offer belongs to the group and that the
// caller is its member, staff or an internal service. An offer of another
// group is reported as not found, without revealing it.
func (b *loanOfferBusiness) authorizeOfferResponse(ctx context.Context, groupID string, offer *models.LoanOffer) error {
	if b.identityCli == nil {
		return apperrors.NewError(apperrors.ServiceUnavailable, "the identity service is required to answer an offer")
	}
	resp, err := b.identityCli.MembershipGet(ctx, &identityv1.MembershipGetRequest{Id: offer.MembershipID})
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

// ExpireStale retires every active offer for a member whose expiry date has
// passed, returning how many were retired. Offers carry an expiry but nothing
// enforced it, so a member could accept a months-old, mispriced offer.
func (b *loanOfferBusiness) ExpireStale(ctx context.Context, membershipID string) (int, error) {
	offers, err := b.loRepo.GetByMembershipID(ctx, membershipID)
	if err != nil {
		return 0, err
	}

	now := time.Now()
	expired := 0
	for _, offer := range offers {
		if offer.State != int32(constants.StateActive) {
			continue
		}
		if offer.ExpiryDate == nil || now.Before(*offer.ExpiryDate) {
			continue
		}
		offer.State = int32(constants.StateInactive)
		if emitErr := b.eventsMan.Emit(ctx, events.LoanOfferSaveEvent, offer); emitErr != nil {
			return expired, emitErr
		}
		expired++
	}

	return expired, nil
}

// CreateLoanAccount turns an accepted offer into a loan request with the
// loans service and approves it. Transaction limits are enforced there: the
// loans service gates the approval and the disbursement of the same loan in
// the partition that owns it, so this step does not reserve against the
// limits service a second time (that would count every stawi loan twice
// against tenant and partition caps).
func (b *loanOfferBusiness) CreateLoanAccount(ctx context.Context, offerID string) (map[string]interface{}, error) {
	return b.createLoanAccountInner(ctx, offerID)
}

// createLoanAccountInner runs the core loan account creation logic after any
// gate check.
func (b *loanOfferBusiness) createLoanAccountInner(
	ctx context.Context,
	offerID string,
) (map[string]interface{}, error) {
	logger := util.Log(ctx).WithField("method", "LoanOfferBusiness.CreateLoanAccount")

	offer, err := b.loRepo.GetByID(ctx, offerID)
	if err != nil {
		return nil, apperrors.ErrDataNotFound.Extend("loan offer")
	}

	if offer.Response != int32(models.LoanOfferResponseAccept) {
		return nil, apperrors.NewError(apperrors.Unprocessable, "loan offer has not been accepted")
	}

	// Build the result with info needed for loan creation
	result := map[string]interface{}{
		"offer_id":        offerID,
		"amount":          offer.Amount,
		"currency":        offer.Currency,
		fieldMembershipID: offer.MembershipID,
	}

	// The workflow retries this step. A loan account already recorded on the
	// offer means the previous attempt got through; originating a second loan
	// would disburse the same offer twice.
	if offer.LoanAccountID != "" {
		result["loan_request_id"] = offer.ApplicationID
		result["loan_account_id"] = offer.LoanAccountID
		result["idempotent"] = true
		return result, nil
	}

	logger.WithField("offer_id", offerID).
		WithField("amount", offer.Amount).
		WithField("membership_id", offer.MembershipID).
		Info("creating loan account for accepted offer")

	// Create loan application and account via platform services
	if createErr := b.createLoanFromOffer(ctx, offer, offerID, result); createErr != nil {
		return nil, createErr
	}

	// Persist the loan links back onto the offer.
	if emitErr := b.eventsMan.Emit(ctx, events.LoanOfferSaveEvent, offer); emitErr != nil {
		return nil, fmt.Errorf("could not update offer with loan account details: %w", emitErr)
	}

	return result, nil
}

// createLoanFromOffer creates a loan request and account via the loan
// management service, updating the offer and result map with the IDs.
func (b *loanOfferBusiness) createLoanFromOffer(
	ctx context.Context,
	offer *models.LoanOffer,
	offerID string,
	result map[string]interface{},
) error {
	if b.clients == nil || b.clients.LenderLoanMgmt == nil {
		return apperrors.NewError(apperrors.ServiceUnavailable,
			"loan management service is required to originate a loan")
	}

	// The loans service needs the whole application: who the borrower is,
	// the currency, the term and rate, and where the money goes. A request
	// missing any of them is refused there, and the group's loan never exists.
	clientID, payoutContactID, err := b.borrowerForOffer(ctx, offer)
	if err != nil {
		return err
	}
	// Stawi does not verify KYC itself, so it does not assert it: the loans
	// service keeps its own verification gate for products that require it.
	props, propErr := structpb.NewStruct(map[string]any{
		"payment_account_ref": payoutContactID,
		"payment_channel":     "mobile_money",
		"group_offer_id":      offerID,
	})
	if propErr != nil {
		return fmt.Errorf("loan request properties: %w", propErr)
	}
	offerMoney := minorUnitsToMoney(offer.Amount, offer.Currency)
	lrObj := &loansv1.LoanRequestObject{
		ClientId:          clientID,
		ProductId:         b.product.LoanProductID,
		RequestedAmount:   offerMoney,
		ApprovedAmount:    offerMoney,
		RequestedTermDays: b.product.LoanTermDays(),
		ApprovedTermDays:  b.product.LoanTermDays(),
		InterestRate:      basisPointsToPercent(b.product.LoanInterestRatePA),
		CurrencyCode:      offer.Currency,
		Purpose:           fmt.Sprintf("Group loan offer %s", offerID),
		SourceService:     "stawi",
		SourceRequestId:   offerID,
		IdempotencyKey:    "stawi:" + offerID,
		Status:            loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED,
		Properties:        props,
	}
	lrResp, lrErr := b.clients.LenderLoanMgmt.LoanRequestSave(ctx, &loansv1.LoanRequestSaveRequest{Data: lrObj})
	if lrErr != nil {
		return fmt.Errorf("could not create loan request: %w", lrErr)
	}
	if lrResp.GetData() == nil {
		return errors.New("loan management returned no loan request")
	}

	loanRequestID := lrResp.GetData().GetId()
	offer.ApplicationID = loanRequestID
	result["loan_request_id"] = loanRequestID

	// Approve the loan request to create the loan account
	if _, approveErr := b.clients.LenderLoanMgmt.LoanRequestApprove(
		ctx,
		&loansv1.LoanRequestApproveRequest{Id: loanRequestID},
	); approveErr != nil {
		return fmt.Errorf("could not approve loan request: %w", approveErr)
	}

	loanResp, loanErr := b.clients.LenderLoanMgmt.LoanAccountCreate(
		ctx,
		&loansv1.LoanAccountCreateRequest{LoanRequestId: loanRequestID},
	)
	if loanErr != nil {
		return fmt.Errorf("could not create loan account: %w", loanErr)
	}
	if loanResp.GetData() == nil {
		return errors.New("loan management returned no loan account")
	}

	offer.LoanAccountID = loanResp.GetData().GetId()
	result["loan_account_id"] = offer.LoanAccountID
	return nil
}

// clampLeverage keeps a window's leverage inside the product's configured
// band. Leverage is stored in hundredths (190 = 1.90x); a value supplied in
// true basis points would otherwise offer members 190x their savings.
func (b *loanOfferBusiness) clampLeverage(ctx context.Context, leverage int64) int64 {
	minLeverage, maxLeverage := b.product.MinLeverage, b.product.MaxLeverage
	if minLeverage <= 0 || maxLeverage < minLeverage {
		return leverage
	}
	clamped := leverage
	switch {
	case clamped < minLeverage:
		clamped = minLeverage
	case clamped > maxLeverage:
		clamped = maxLeverage
	}
	if clamped != leverage {
		util.Log(ctx).WithField("configured", leverage).WithField("applied", clamped).
			Warn("loan window leverage clamped to product bounds")
	}
	return clamped
}

// memberSavingsBalance reads the closing balance of a member's periodic
// savings ledger account, in minor units of the window currency.
func (b *loanOfferBusiness) memberSavingsBalance(
	ctx context.Context,
	membershipID, currency string,
) (int64, error) {
	resp, err := b.clients.LedgerClient.GetAccountStatement(ctx, &ledgerv1.GetAccountStatementRequest{
		AccountId: constants.MemberPeriodicSavingsAccount(membershipID),
		Limit:     statementPageLimit,
	})
	if err != nil {
		return 0, err
	}

	balance := resp.GetClosingBalance()
	if balance == nil {
		return 0, nil
	}
	if currency != "" && balance.GetCurrencyCode() != "" && balance.GetCurrencyCode() != currency {
		return 0, fmt.Errorf(
			"savings balance currency %s does not match window currency %s",
			balance.GetCurrencyCode(), currency,
		)
	}
	return moneyx.ToSmallestUnit(balance, moneyx.Decimals(currency)), nil
}

// getMembersByGroupID fetches group memberships via the identity SDK.
func (b *loanOfferBusiness) getMembersByGroupID(
	ctx context.Context,
	groupID string,
) ([]*identityv1.MembershipObject, error) {
	if b.identityCli == nil {
		return nil, errors.New("identity client not available")
	}

	stream, err := b.identityCli.MembershipSearch(ctx, &identityv1.MembershipSearchRequest{GroupId: groupID})
	if err != nil {
		return nil, err
	}

	var members []*identityv1.MembershipObject
	for {
		msg2, streamErr := stream.Receive()
		if streamErr != nil {
			if errors.Is(streamErr, io.EOF) {
				break
			}
			return nil, streamErr
		}
		msg := msg2
		members = append(members, msg.GetData()...)
	}

	return members, nil
}

// borrowerForOffer resolves the member behind an offer to the lender's client
// id and the contact id of the member's payout phone.
func (b *loanOfferBusiness) borrowerForOffer(ctx context.Context, offer *models.LoanOffer) (string, string, error) {
	if b.identityCli == nil || b.clients == nil || b.clients.ProfileClient == nil || b.clients.LenderIdentity == nil {
		return "", "", apperrors.NewError(apperrors.ServiceUnavailable,
			"identity, lender identity and profile services are required to originate a loan")
	}
	resp, err := b.identityCli.MembershipGet(ctx,
		&identityv1.MembershipGetRequest{Id: offer.MembershipID})
	if err != nil {
		return "", "", fmt.Errorf("membership get: %w", err)
	}
	membership := resp.GetData()
	clientID := ""
	if props := membership.GetProperties(); props != nil {
		if v, ok := props.AsMap()["client_id"].(string); ok {
			clientID = v
		}
	}
	if clientID == "" {
		return "", "", apperrors.NewError(apperrors.Unprocessable,
			"member is not registered as a client with the lender; run group registration first")
	}
	// The membership property is a hint, not an identity: the lender's client
	// row must belong to this member's profile before money is lent on it.
	client, err := b.clients.LenderIdentity.ClientGet(ctx, &fieldv1.ClientGetRequest{Id: clientID})
	if err != nil {
		return "", "", fmt.Errorf("client get: %w", err)
	}
	if client.GetData().GetProfileId() == "" || client.GetData().GetProfileId() != membership.GetProfileId() {
		return "", "", apperrors.NewError(apperrors.Unprocessable,
			"the client recorded on the membership belongs to a different person")
	}
	profile, err := b.clients.ProfileClient.GetById(ctx,
		&profilev1.GetByIdRequest{Id: membership.GetProfileId()})
	if err != nil {
		return "", "", fmt.Errorf("profile get: %w", err)
	}
	// The payout destination is the id of the member's verified mobile
	// contact; stawi never handles the number itself.
	payoutContactID := payout.DefaultPayoutContactID(profile.GetData())
	if payoutContactID == "" {
		return "", "", apperrors.NewError(apperrors.Unprocessable,
			"member has no verified phone number to disburse to")
	}
	return clientID, payoutContactID, nil
}

// basisPointsPerPercent is how many basis points make one percent.
const basisPointsPerPercent = 100

// basisPointsToPercent renders 2400 basis points as "24.00".
func basisPointsToPercent(bp int64) string {
	return fmt.Sprintf("%d.%02d", bp/basisPointsPerPercent, bp%basisPointsPerPercent)
}
