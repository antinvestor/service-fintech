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
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"connectrpc.com/connect"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
	"github.com/pitabwire/util/decimalx"

	"github.com/antinvestor/service-fintech/apps/stawi/service/events"
	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	"github.com/antinvestor/service-fintech/pkg/calculation"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

const (
	// offerExpiryHours is the number of hours before a loan offer expires.
	offerExpiryHours = 72
	// decimalPrecisionOffer is the number of decimal places for minor unit conversions.
	decimalPrecisionOffer = 2
	// membershipTypeMember is the membership type value for regular members.
	membershipTypeMember = int32(3)
	// percentageDivisor is the number of minor units per major currency unit.
	percentageDivisor = 100
	// moneyNanosFactor converts minor-unit remainders to protobuf nanos (1e9 / 100).
	moneyNanosFactor = 10_000_000
)

// minorUnitsToMoney converts minor units and a currency code to a *commonv1.Money.
func minorUnitsToMoney(v int64, currencyCode string) *commonv1.Money {
	units := v / percentageDivisor
	nanos := (v % percentageDivisor) * moneyNanosFactor
	return &commonv1.Money{
		CurrencyCode: currencyCode,
		Units:        units,
		Nanos:        int32(nanos),
	}
}

type loanOfferBusiness struct {
	eventsMan         fevents.Manager
	loRepo            repository.LoanOfferRepository
	lwRepo            repository.LoanWindowRepository
	identityCli       identityv1connect.IdentityServiceClient
	clients           *clients.PlatformClients
	limitsCli         limitsv1connect.LimitsServiceClient
	limitsGateEnabled bool
	limitsGateMode    string
}

func NewLoanOfferBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	loRepo repository.LoanOfferRepository,
	lwRepo repository.LoanWindowRepository,
	identityCli identityv1connect.IdentityServiceClient,
	pc *clients.PlatformClients,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsGateEnabled bool,
	limitsGateMode string,
) LoanOfferBusiness {
	return &loanOfferBusiness{
		eventsMan:         eventsMan,
		loRepo:            loRepo,
		lwRepo:            lwRepo,
		identityCli:       identityCli,
		clients:           pc,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsGateEnabled,
		limitsGateMode:    limitsGateMode,
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

	var offersGenerated int
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

		// Calculate max loan amount using the window's leverage and periodic amount
		periodicDec := decimalx.FromMinorUnits(window.PeriodicAmount, decimalPrecisionOffer)
		maxLoanDec := calculation.CalculateMaxLoanAmount(periodicDec, window.Leverage)
		maxLoan := maxLoanDec.ToMinorUnits(decimalPrecisionOffer)
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
	}

	logger.WithField("window_id", windowID).
		WithField("offers_generated", offersGenerated).
		WithField("members_processed", len(members)).
		Info("loan offer generation completed")

	return map[string]interface{}{
		"window_id":        windowID,
		"offers_generated": offersGenerated,
	}, nil
}

func (b *loanOfferBusiness) Respond(ctx context.Context, offerID string, response int32) error {
	logger := util.Log(ctx).WithField("method", "LoanOfferBusiness.Respond")

	offer, err := b.loRepo.GetByID(ctx, offerID)
	if err != nil {
		return fmt.Errorf("offer not found: %w", err)
	}

	if offer.State != int32(constants.StateActive) {
		return fmt.Errorf("offer is not active (state=%d)", offer.State)
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

// CreateLoanAccount gates the loan account creation through the limits service
// when the gate is enabled, then delegates to createLoanAccountInner.
//
// When the limits gate is enabled, a reservation is obtained from the limits
// service before execution proceeds. DENY returns an error; PENDING_APPROVAL
// returns PendingApprovalError.
func (b *loanOfferBusiness) CreateLoanAccount(ctx context.Context, offerID string) (map[string]interface{}, error) {
	if !b.limitsGateEnabled || b.limitsCli == nil || b.limitsGateMode == "off" {
		return b.createLoanAccountInner(ctx, offerID)
	}

	offer, err := b.loRepo.GetByID(ctx, offerID)
	if err != nil {
		return nil, fmt.Errorf("offer not found: %w", err)
	}

	intent := &limitsv1.LimitIntent{
		Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		TenantId: offer.TenantID,
		Amount:   minorUnitsToMoney(offer.Amount, offer.Currency),
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: offer.MembershipID},
		},
	}
	idemKey := "stawi_loan_disbursement:" + offerID

	var result map[string]interface{}
	gateErr := limits.Gate(ctx, b.limitsCli, intent, idemKey, limits.ParseMode(b.limitsGateMode),
		func(innerCtx context.Context, reservationID string) error {
			util.Log(innerCtx).With("limits_reservation_id", reservationID).
				Info("stawi loan disbursement gated by limits")
			inner, innerErr := b.createLoanAccountInner(innerCtx, offerID)
			if innerErr != nil {
				return innerErr
			}
			result = inner
			return nil
		})
	if gateErr != nil {
		return nil, gateErr
	}
	return result, nil
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
		return nil, fmt.Errorf("offer not found: %w", err)
	}

	if offer.Response != int32(models.LoanOfferResponseAccept) {
		return nil, fmt.Errorf("offer not accepted (response=%d)", offer.Response)
	}

	logger.WithField("offer_id", offerID).
		WithField("amount", offer.Amount).
		WithField("membership_id", offer.MembershipID).
		Info("creating loan account for accepted offer")

	// Build the result with info needed for loan creation
	result := map[string]interface{}{
		"offer_id":      offerID,
		"amount":        offer.Amount,
		"currency":      offer.Currency,
		"membership_id": offer.MembershipID,
	}

	// Create loan application and account via platform services
	b.createLoanFromOffer(ctx, logger, offer, offerID, result)

	// Persist any updates to the offer
	if emitErr := b.eventsMan.Emit(ctx, events.LoanOfferSaveEvent, offer); emitErr != nil {
		logger.WithError(emitErr).Warn("could not update offer with loan account details")
	}

	return result, nil
}

// createLoanFromOffer creates a loan request and account via the loan
// management service, updating the offer and result map with the IDs.
func (b *loanOfferBusiness) createLoanFromOffer(
	ctx context.Context,
	logger *util.LogEntry,
	offer *models.LoanOffer,
	offerID string,
	result map[string]interface{},
) {
	if b.clients == nil || b.clients.LenderLoanMgmt == nil {
		logger.Warn("loan management client not available, skipping loan account creation")
		return
	}

	offerMoney := minorUnitsToMoney(offer.Amount, offer.Currency)
	lrObj := &loansv1.LoanRequestObject{
		RequestedAmount: offerMoney,
		ApprovedAmount:  offerMoney,
		Purpose:         fmt.Sprintf("Group loan offer %s", offerID),
		SourceService:   "stawi",
		SourceRequestId: offerID,
		Status:          loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED,
	}
	lrResp, lrErr := b.clients.LenderLoanMgmt.LoanRequestSave(ctx, connect.NewRequest(
		&loansv1.LoanRequestSaveRequest{Data: lrObj},
	))
	if lrErr != nil {
		logger.WithError(lrErr).Warn("could not create loan request via loan management")
		return
	}
	if lrResp.Msg.GetData() == nil {
		return
	}

	loanRequestID := lrResp.Msg.GetData().GetId()
	offer.ApplicationID = loanRequestID
	result["loan_request_id"] = loanRequestID

	// Approve the loan request to create the loan account
	approveResp, approveErr := b.clients.LenderLoanMgmt.LoanRequestApprove(ctx, connect.NewRequest(
		&loansv1.LoanRequestApproveRequest{Id: loanRequestID},
	))
	if approveErr != nil {
		logger.WithError(approveErr).Warn("could not approve loan request")
		return
	}
	_ = approveResp

	loanResp, loanErr := b.clients.LenderLoanMgmt.LoanAccountCreate(ctx, connect.NewRequest(
		&loansv1.LoanAccountCreateRequest{LoanRequestId: loanRequestID},
	))
	if loanErr != nil {
		logger.WithError(loanErr).Warn("could not create loan account via loan management")
		return
	}
	if loanResp.Msg.GetData() != nil {
		offer.LoanAccountID = loanResp.Msg.GetData().GetId()
		result["loan_account_id"] = offer.LoanAccountID
	}
}

// getMembersByGroupID fetches group memberships via the identity SDK.
func (b *loanOfferBusiness) getMembersByGroupID(
	ctx context.Context,
	groupID string,
) ([]*identityv1.MembershipObject, error) {
	if b.identityCli == nil {
		return nil, errors.New("identity client not available")
	}

	stream, err := b.identityCli.MembershipSearch(ctx, connect.NewRequest(
		&identityv1.MembershipSearchRequest{GroupId: groupID},
	))
	if err != nil {
		return nil, err
	}

	var members []*identityv1.MembershipObject
	for stream.Receive() {
		msg := stream.Msg()
		members = append(members, msg.GetData()...)
	}
	if streamErr := stream.Err(); streamErr != nil {
		return nil, streamErr
	}

	return members, nil
}
