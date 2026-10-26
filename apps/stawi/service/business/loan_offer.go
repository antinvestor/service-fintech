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
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"
	"github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/stawi/service/events"
	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/payout"
	stawiproduct "github.com/antinvestor/service-fintech/products/stawi"

	"github.com/antinvestor/service-fintech/pkg/apperrors"
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
	identityCli identityv1connect.IdentityServiceClient
	clients     *clients.PlatformClients
}

func NewLoanOfferBusiness(
	_ context.Context,
	product stawiproduct.ProductConfig,
	eventsMan fevents.Manager,
	loRepo repository.LoanOfferRepository,
	identityCli identityv1connect.IdentityServiceClient,
	pc *clients.PlatformClients,
) LoanOfferBusiness {
	return &loanOfferBusiness{
		product:     product,
		eventsMan:   eventsMan,
		loRepo:      loRepo,
		identityCli: identityCli,
		clients:     pc,
	}
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
