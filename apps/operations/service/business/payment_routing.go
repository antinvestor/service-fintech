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
	"sort"
	"strings"
	"time"

	"go.opentelemetry.io/otel/attribute"

	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/operations/service/events"
	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// extraKeySource and allocationSourceMarker mark orders this service raised
// from a payment allocation; downstream trusts the marker, not the caller.
const (
	extraKeySource         = "source"
	allocationSourceMarker = "payment_allocation"
)

// allocationLeaseStaleAfter is how long an allocation run may hold a payment
// before another run treats it as crashed and takes over.
const allocationLeaseStaleAfter = 2 * time.Minute

// ErrAllocationInProgress is returned while another run holds the payment's
// allocation lease; the caller retries later.
var ErrAllocationInProgress = apperrors.NewError(apperrors.ServiceUnavailable,
	"payment allocation is in progress elsewhere; retry later")

func allocationAlreadyProcessed(paymentID string, state int32) map[string]interface{} {
	return map[string]interface{}{
		fieldPaymentID:      paymentID,
		fieldStatus:         "already_processed",
		fieldState:          state,
		fieldTransferOrders: []map[string]interface{}{},
	}
}

type paymentRoutingBusiness struct {
	eventsMan   fevents.Manager
	ipRepo      repository.IncomingPaymentRepository
	toRepo      repository.TransferOrderRepository
	obRepo      repository.ObligationRepository
	arRepo      repository.AccountRefRepository
	identityCli identityv1connect.IdentityServiceClient
	clients     *clients.PlatformClients
}

func NewPaymentRoutingBusiness(_ context.Context, eventsMan fevents.Manager,
	ipRepo repository.IncomingPaymentRepository,
	toRepo repository.TransferOrderRepository,
	obRepo repository.ObligationRepository,
	arRepo repository.AccountRefRepository,
	identityCli identityv1connect.IdentityServiceClient,
	pc *clients.PlatformClients,
) PaymentRoutingBusiness {
	return &paymentRoutingBusiness{
		eventsMan:   eventsMan,
		ipRepo:      ipRepo,
		toRepo:      toRepo,
		obRepo:      obRepo,
		arRepo:      arRepo,
		identityCli: identityCli,
		clients:     pc,
	}
}

// identificationResult holds the outcome of a successful payment identification.
type identificationResult struct {
	Strategy     string
	MembershipID string
	GroupID      string
	ProfileID    string
	// ClientID, LoanID and ProductID are set when an individual borrower's
	// payment was matched straight to their loan.
	ClientID  string
	LoanID    string
	ProductID string
	// SavingsAccountID is set when an individual's payment was matched to
	// their own savings account.
	SavingsAccountID string
}

// identificationStrategy defines one step in the payment identification pipeline.
type identificationStrategy struct {
	name    string
	enabled bool
	run     func(ctx context.Context) (*identificationResult, error)
}

type incomingPaymentMetadata struct {
	transactionID string
	amount        int64
	currency      string
	productID     string
	properties    data.JSONMap
}

func (b *paymentRoutingBusiness) IdentifyPayment(
	ctx context.Context,
	paymentData map[string]interface{},
) (map[string]interface{}, error) {
	logger := util.Log(ctx).WithField("method", "PaymentRoutingBusiness.IdentifyPayment")

	payment, err := b.loadOrCreateIncomingPayment(ctx, paymentData)
	if err != nil {
		return nil, err
	}
	if payment.OwnerID != "" {
		logger.WithField("payment_id", payment.GetID()).Info("payment already identified, reusing persisted routing")
		return b.buildStoredPaymentResult(payment), nil
	}

	paymentRef := extractPaymentReference(paymentData, payment)
	payerRef := firstNonEmptyString(
		extractString(paymentData, fieldPayerReference),
		payment.Properties.GetString(fieldPayerReference),
	)
	payerName := firstNonEmptyString(
		extractString(paymentData, "payer_name"),
		payment.Properties.GetString("payer_name"),
	)
	productID := firstNonEmptyString(
		extractString(paymentData, fieldProductID),
		payment.Properties.GetString(fieldProductID),
	)
	groupID := firstNonEmptyString(extractString(paymentData, "group_id"), payment.Properties.GetString("group_id"))

	paymentRef = strings.TrimSpace(paymentRef)
	payerRef = strings.TrimSpace(payerRef)
	payerName = strings.TrimSpace(payerName)

	// An individual borrower's payment (no group) is matched to their loan
	// first; group payments keep the membership strategies.
	if groupID == "" {
		if result := b.identifyIndividual(ctx, productID, paymentRef, payerRef); result != nil {
			if saveErr := b.applyIdentificationResult(ctx, payment, result); saveErr != nil {
				return nil, saveErr
			}
			recordPaymentIdentified(ctx, payment)
			return b.buildIdentificationResult(payment, result), nil
		}
	}

	if result := b.runIdentificationStrategies(ctx, logger, paymentRef, payerRef, payerName, groupID); result != nil {
		if saveErr := b.applyIdentificationResult(ctx, payment, result); saveErr != nil {
			return nil, saveErr
		}
		recordPaymentIdentified(ctx, payment)
		return b.buildIdentificationResult(payment, result), nil
	}

	logger.Warn("payment could not be identified, routing to unidentified account")
	recordPaymentUnmatched(ctx)
	unidentified := map[string]interface{}{
		fieldPaymentID: payment.GetID(),
		fieldStrategy:  "unidentified",
		"reason":       "no matching member found across all identification strategies",
	}
	if productID != "" {
		unidentified["unidentified_account"] = constants.ProductUnidentifiedAccount(productID)
	}
	return unidentified, nil
}

// identifyIndividual matches a payment with no group to the payer's own loan
// or, failing that, their own savings account, of the product the rail
// credited. It returns nil when neither matches.
func (b *paymentRoutingBusiness) identifyIndividual(
	ctx context.Context,
	productID, paymentRef, payerRef string,
) *identificationResult {
	if b.borrowerLoanMatching() {
		if result, err := b.identifyBorrowerLoan(ctx, productID, paymentRef, payerRef); err == nil {
			return result
		}
	}
	if b.borrowerSavingsMatching() {
		if result, err := b.identifySaverAccount(ctx, productID, paymentRef, payerRef); err == nil {
			return result
		}
	}
	return nil
}

// runIdentificationStrategies walks the identification pipeline and returns the
// first match, or nil when no strategy resolves a member.
func (b *paymentRoutingBusiness) runIdentificationStrategies(
	ctx context.Context,
	logger *util.LogEntry,
	paymentRef, payerRef, payerName, groupID string,
) *identificationResult {
	strategies := []identificationStrategy{
		{
			"direct membership ID",
			paymentRef != "" && b.identityCli != nil,
			func(ctx context.Context) (*identificationResult, error) {
				return b.identifyByMembershipID(ctx, paymentRef)
			},
		},
		{
			"profile ID single match",
			payerRef != "" && b.identityCli != nil,
			func(ctx context.Context) (*identificationResult, error) {
				return b.identifyByProfileID(ctx, payerRef)
			},
		},
		{
			"filtered membership type",
			payerRef != "" && b.identityCli != nil,
			func(ctx context.Context) (*identificationResult, error) {
				return b.identifyByFilteredMembership(ctx, payerRef, groupID)
			},
		},
		{
			"contact ID match",
			payerRef != "" && b.identityCli != nil,
			func(ctx context.Context) (*identificationResult, error) {
				return b.identifyByContactID(ctx, payerRef, groupID)
			},
		},
		{
			"payer name match",
			payerName != "" && groupID != "" && b.identityCli != nil,
			func(ctx context.Context) (*identificationResult, error) {
				return b.identifyByPayerName(ctx, payerName, groupID)
			},
		},
	}

	for i, s := range strategies {
		if !s.enabled {
			continue
		}
		result, strategyErr := s.run(ctx)
		if strategyErr == nil && result != nil {
			logger.WithField(fieldMembershipID, result.MembershipID).
				Info(fmt.Sprintf("payer identified via strategy %d: %s", i+1, s.name))
			return result
		}
	}
	return nil
}

// IdentifySender resolves a payer to a group member without recording a
// payment. It is the lookup half of IdentifyPayment, used by routing
// workflows that need to know who is paying before the money is booked.
func (b *paymentRoutingBusiness) IdentifySender(
	ctx context.Context,
	senderIdentifier, groupID, reference string,
) (map[string]interface{}, error) {
	logger := util.Log(ctx).WithField("method", "PaymentRoutingBusiness.IdentifySender")

	senderIdentifier = strings.TrimSpace(senderIdentifier)
	reference = strings.TrimSpace(reference)
	if senderIdentifier == "" && reference == "" {
		return nil, apperrors.NewError(apperrors.BadRequest,
			"a sender identifier or payment reference is required")
	}

	result := b.runIdentificationStrategies(ctx, logger, reference, senderIdentifier, "", groupID)
	if result == nil {
		return map[string]interface{}{
			"identified":  false,
			fieldStrategy: "unidentified",
		}, nil
	}

	return map[string]interface{}{
		"identified":      true,
		fieldStrategy:     result.Strategy,
		fieldMembershipID: result.MembershipID,
		"member_id":       result.MembershipID,
		fieldGroupID:      result.GroupID,
	}, nil
}

// AllocatePaymentByTransactionID resolves a provider transaction id to the
// recorded payment and allocates it.
func (b *paymentRoutingBusiness) AllocatePaymentByTransactionID(
	ctx context.Context,
	transactionID string,
) (map[string]interface{}, error) {
	payment, err := b.ipRepo.GetByTransactionID(ctx, strings.TrimSpace(transactionID))
	if err != nil {
		return nil, apperrors.ErrDataNotFound.Extend("incoming payment")
	}
	return b.AllocatePayment(ctx, payment.GetID())
}

// recordPaymentIdentified emits OTel counters for a successfully identified payment.
// Tenant attribution is attached automatically from the context's claims.
func recordPaymentIdentified(ctx context.Context, payment *models.IncomingPayment) {
	currencyAttr := attribute.String("currency", payment.Currency)
	OpsPaymentsReceived.Add(ctx, 1, currencyAttr)
	OpsPaymentsAmount.Add(ctx, float64(payment.Amount)/minorUnitsPerMajor, currencyAttr)
}

// recordPaymentUnmatched emits OTel counter for a payment that could not be identified.
// Tenant attribution is attached automatically from the context's claims.
func recordPaymentUnmatched(ctx context.Context) {
	OpsPaymentsUnmatched.Add(ctx, 1)
}

func (b *paymentRoutingBusiness) loadOrCreateIncomingPayment(
	ctx context.Context,
	paymentData map[string]interface{},
) (*models.IncomingPayment, error) {
	metadata := parseIncomingPaymentMetadata(paymentData)
	if metadata.transactionID == "" {
		return nil, errors.New("transaction_id is required")
	}

	existing, err := b.ipRepo.GetByTransactionID(ctx, metadata.transactionID)
	if err == nil && existing != nil {
		return b.refreshExistingIncomingPayment(ctx, existing, metadata)
	}
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, fmt.Errorf("lookup incoming payment by transaction_id %s: %w", metadata.transactionID, err)
	}

	return b.createIncomingPayment(ctx, metadata)
}

func (b *paymentRoutingBusiness) refreshExistingIncomingPayment(
	ctx context.Context,
	existing *models.IncomingPayment,
	metadata incomingPaymentMetadata,
) (*models.IncomingPayment, error) {
	if amountMismatch(existing.Amount, metadata.amount) {
		return nil, fmt.Errorf(
			"transaction %s already recorded with amount %d, received %d",
			metadata.transactionID, existing.Amount, metadata.amount,
		)
	}
	if currencyMismatch(existing.Currency, metadata.currency) {
		return nil, fmt.Errorf(
			"transaction %s already recorded with currency %s, received %s",
			metadata.transactionID, existing.Currency, metadata.currency,
		)
	}

	if !applyIncomingPaymentMetadata(existing, metadata) {
		return existing, nil
	}

	if emitErr := b.eventsMan.Emit(ctx, events.IncomingPaymentSaveEvent, existing); emitErr != nil {
		return nil, fmt.Errorf("update incoming payment: %w", emitErr)
	}

	return existing, nil
}

func (b *paymentRoutingBusiness) createIncomingPayment(
	ctx context.Context,
	metadata incomingPaymentMetadata,
) (*models.IncomingPayment, error) {
	payment := &models.IncomingPayment{
		Amount:        metadata.amount,
		Currency:      metadata.currency,
		Description:   fmt.Sprintf("incoming payment %s", metadata.transactionID),
		TransactionID: metadata.transactionID,
		State:         int32(constants.StateJustCreated),
		Properties:    metadata.properties,
	}
	if metadata.productID != "" {
		payment.PayableID = metadata.productID
		payment.PayableType = "product"
	}
	payment.GenID(ctx)

	// Synchronous insert. The partial unique index on transaction_id makes the
	// dedupe real: a concurrent notification for the same transaction loses the
	// insert and reads the winner's row back instead of creating a second one.
	stored, createErr := b.ipRepo.CreateIfAbsent(ctx, payment)
	if createErr != nil {
		return nil, fmt.Errorf("create incoming payment: %w", createErr)
	}

	return stored, nil
}

func parseIncomingPaymentMetadata(paymentData map[string]interface{}) incomingPaymentMetadata {
	amount, _ := paymentData["amount"].(int64)

	return incomingPaymentMetadata{
		transactionID: strings.TrimSpace(extractString(paymentData, "transaction_id")),
		amount:        amount,
		currency:      strings.TrimSpace(extractString(paymentData, "currency")),
		productID:     strings.TrimSpace(extractString(paymentData, fieldProductID)),
		properties:    incomingPaymentProperties(paymentData),
	}
}

func amountMismatch(existingAmount, receivedAmount int64) bool {
	return receivedAmount > 0 && existingAmount > 0 && existingAmount != receivedAmount
}

func currencyMismatch(existingCurrency, receivedCurrency string) bool {
	return receivedCurrency != "" && existingCurrency != "" && existingCurrency != receivedCurrency
}

func applyIncomingPaymentMetadata(
	payment *models.IncomingPayment,
	metadata incomingPaymentMetadata,
) bool {
	updated := false
	if metadata.amount > 0 && payment.Amount == 0 {
		payment.Amount = metadata.amount
		updated = true
	}
	if metadata.currency != "" && payment.Currency == "" {
		payment.Currency = metadata.currency
		updated = true
	}
	if metadata.productID != "" && payment.PayableID == "" {
		payment.PayableID = metadata.productID
		payment.PayableType = "product"
		updated = true
	}

	mergedProperties := mergeJSONMaps(payment.Properties, metadata.properties)
	if !jsonMapsEqual(payment.Properties, mergedProperties) {
		payment.Properties = mergedProperties
		updated = true
	}

	return updated
}

// identifyByMembershipID implements Strategy 1.
func (b *paymentRoutingBusiness) identifyByMembershipID(
	ctx context.Context,
	ref string,
) (*identificationResult, error) {
	resp, err := b.identityCli.MembershipGet(ctx, &identityv1.MembershipGetRequest{Id: ref})
	if err != nil {
		return nil, err
	}
	mem := resp.GetData()
	if mem == nil || mem.GetId() == "" {
		return nil, fmt.Errorf("membership not found for reference %s", ref)
	}
	state := int32(mem.GetState())
	if state == GroupStateDeleted || state == GroupStateShutdown {
		return nil, fmt.Errorf("membership %s is not active", ref)
	}
	return &identificationResult{
		Strategy:     "direct_membership_id",
		MembershipID: mem.GetId(),
		GroupID:      mem.GetGroupId(),
		ProfileID:    mem.GetProfileId(),
	}, nil
}

// identifyByProfileID implements Strategy 2.
func (b *paymentRoutingBusiness) identifyByProfileID(
	ctx context.Context,
	profileID string,
) (*identificationResult, error) {
	members, err := b.getMembersByProfileID(ctx, profileID)
	if err != nil {
		return nil, err
	}

	active := filterActiveProtoMemberships(members)
	if len(active) != 1 {
		return nil, fmt.Errorf("expected exactly 1 active membership for profile %s, got %d", profileID, len(active))
	}

	mem := active[0]
	return &identificationResult{
		Strategy:     fieldProfileID,
		MembershipID: mem.GetId(),
		GroupID:      mem.GetGroupId(),
		ProfileID:    mem.GetProfileId(),
	}, nil
}

// identifyByFilteredMembership implements Strategy 3.
func (b *paymentRoutingBusiness) identifyByFilteredMembership(
	ctx context.Context,
	profileID, scopeGroupID string,
) (*identificationResult, error) {
	members, err := b.getMembersByProfileID(ctx, profileID)
	if err != nil {
		return nil, err
	}

	// Filter to MembershipTypeMember only (type 3), excluding registra, agent, funder.
	var filtered []*identityv1.MembershipObject
	for _, m := range members {
		if m.GetMembershipType() != MembershipTypeMember {
			continue
		}
		state := int32(m.GetState())
		if state == GroupStateDeleted || state == GroupStateShutdown {
			continue
		}
		// If a group scope is provided, further restrict to that group.
		if scopeGroupID != "" && m.GetGroupId() != scopeGroupID {
			continue
		}
		filtered = append(filtered, m)
	}

	if len(filtered) != 1 {
		return nil, fmt.Errorf(
			"filtered membership count for profile %s is %d, need exactly 1",
			profileID,
			len(filtered),
		)
	}

	mem := filtered[0]
	return &identificationResult{
		Strategy:     "filtered_membership_type",
		MembershipID: mem.GetId(),
		GroupID:      mem.GetGroupId(),
		ProfileID:    mem.GetProfileId(),
	}, nil
}

// identifyByContactID implements Strategy 4.
func (b *paymentRoutingBusiness) identifyByContactID(
	ctx context.Context,
	contactRef, scopeGroupID string,
) (*identificationResult, error) {
	// When a group_id scope is available, search within the group's memberships for a
	// contact_id match.
	if scopeGroupID != "" {
		groupMembers, err := b.getMembersByGroupID(ctx, scopeGroupID)
		if err != nil {
			return nil, fmt.Errorf("failed to get group members: %w", err)
		}

		var matched []*identityv1.MembershipObject
		for _, m := range groupMembers {
			if m.GetContactId() == contactRef && int32(m.GetState()) != GroupStateDeleted {
				matched = append(matched, m)
			}
		}

		if len(matched) == 1 {
			mem := matched[0]
			return &identificationResult{
				Strategy:     "contact_id",
				MembershipID: mem.GetId(),
				GroupID:      mem.GetGroupId(),
				ProfileID:    mem.GetProfileId(),
			}, nil
		}
	}

	// Without a group scope, fall back to a profile-based contact lookup.
	members, err := b.getMembersByProfileID(ctx, contactRef)
	if err != nil {
		return nil, err
	}

	active := filterActiveProtoMemberships(members)
	if len(active) == 1 {
		mem := active[0]
		return &identificationResult{
			Strategy:     "contact_id",
			MembershipID: mem.GetId(),
			GroupID:      mem.GetGroupId(),
			ProfileID:    mem.GetProfileId(),
		}, nil
	}

	return nil, fmt.Errorf("contact ID match failed for ref %s", contactRef)
}

// identifyByPayerName implements Strategy 5.
func (b *paymentRoutingBusiness) identifyByPayerName(
	ctx context.Context,
	payerName, groupID string,
) (*identificationResult, error) {
	groupMembers, err := b.getMembersByGroupID(ctx, groupID)
	if err != nil {
		return nil, fmt.Errorf("failed to get group members for name match: %w", err)
	}

	normalizedPayer := normalizeNameForComparison(payerName)
	if normalizedPayer == "" {
		return nil, errors.New("payer name is empty after normalization")
	}

	var matched []*identityv1.MembershipObject
	for _, m := range groupMembers {
		state := int32(m.GetState())
		if state == GroupStateDeleted || state == GroupStateShutdown {
			continue
		}
		normalizedMember := normalizeNameForComparison(m.GetName())
		if normalizedMember == "" {
			continue
		}
		// Check for exact normalized match or containment in either direction.
		if normalizedMember == normalizedPayer ||
			strings.Contains(normalizedMember, normalizedPayer) ||
			strings.Contains(normalizedPayer, normalizedMember) {
			matched = append(matched, m)
		}
	}

	if len(matched) != 1 {
		return nil, fmt.Errorf("payer name match yielded %d results for '%s', need exactly 1", len(matched), payerName)
	}

	mem := matched[0]
	return &identificationResult{
		Strategy:     fieldPayerName,
		MembershipID: mem.GetId(),
		GroupID:      mem.GetGroupId(),
		ProfileID:    mem.GetProfileId(),
	}, nil
}

// buildIdentificationResult converts an identificationResult into the map returned by the interface.
func (b *paymentRoutingBusiness) buildIdentificationResult(
	payment *models.IncomingPayment,
	r *identificationResult,
) map[string]interface{} {
	return map[string]interface{}{
		fieldPaymentID:    payment.GetID(),
		fieldStrategy:     r.Strategy,
		fieldMembershipID: r.MembershipID,
		fieldGroupID:      r.GroupID,
		fieldProfileID:    r.ProfileID,
		fieldClientID:     r.ClientID,
		fieldLoanID:       r.LoanID,
	}
}

func (b *paymentRoutingBusiness) buildStoredPaymentResult(payment *models.IncomingPayment) map[string]interface{} {
	result := map[string]interface{}{
		fieldPaymentID:    payment.GetID(),
		fieldMembershipID: payment.OwnerID,
	}
	if payment.Properties != nil {
		if strategy := payment.Properties.GetString("identification_strategy"); strategy != "" {
			result[fieldStrategy] = strategy
		}
		if groupID := payment.Properties.GetString("group_id"); groupID != "" {
			result["group_id"] = groupID
		}
		if profileID := payment.Properties.GetString("profile_id"); profileID != "" {
			result["profile_id"] = profileID
		}
	}
	if _, ok := result[fieldStrategy]; !ok {
		result[fieldStrategy] = "persisted"
	}

	return result
}

func (b *paymentRoutingBusiness) applyIdentificationResult(
	ctx context.Context,
	payment *models.IncomingPayment,
	result *identificationResult,
) error {
	payment.OwnerID = result.MembershipID
	payment.OwnerType = "membership"
	if result.GroupID != "" {
		payment.PayableID = result.GroupID
		payment.PayableType = "group"
	}
	extra := data.JSONMap{
		"identification_strategy": result.Strategy,
		fieldGroupID:              result.GroupID,
		fieldProfileID:            result.ProfileID,
	}
	if result.LoanID != "" {
		payment.OwnerID = result.ClientID
		payment.OwnerType = ownerTypeClientLoan
		payment.PayableID = result.LoanID
		payment.PayableType = "loan"
		extra[fieldClientID] = result.ClientID
		extra[fieldLoanID] = result.LoanID
		extra[fieldProductID] = result.ProductID
	}
	if result.SavingsAccountID != "" {
		payment.OwnerID = result.ClientID
		payment.OwnerType = ownerTypeClientSavings
		payment.PayableID = result.SavingsAccountID
		payment.PayableType = payableTypeSavings
		extra[fieldClientID] = result.ClientID
		extra[fieldSavingsAccountID] = result.SavingsAccountID
		extra[fieldProductID] = result.ProductID
	}
	payment.Properties = mergeJSONMaps(payment.Properties, extra)

	if emitErr := b.eventsMan.Emit(ctx, events.IncomingPaymentSaveEvent, payment); emitErr != nil {
		return fmt.Errorf("persist payment identification: %w", emitErr)
	}

	return nil
}

// allocationBucket defines a priority bucket for payment allocation.
type allocationBucket struct {
	name      string
	orderType int
	filter    func(o *models.Obligation) bool
}

// AllocatePayment allocates an identified payment to obligations in priority order.
func (b *paymentRoutingBusiness) AllocatePayment(
	ctx context.Context,
	paymentID string,
) (map[string]interface{}, error) {
	logger := util.Log(ctx).WithField("method", "PaymentRoutingBusiness.AllocatePayment")

	// Retrieve the incoming payment.
	payment, err := b.ipRepo.GetByID(ctx, paymentID)
	if err != nil {
		return nil, fmt.Errorf("payment %s not found: %w", paymentID, err)
	}

	if payment.State == int32(constants.StateInactive) || payment.State == int32(constants.StateDeleted) {
		return allocationAlreadyProcessed(paymentID, payment.State), nil
	}

	// One allocation run at a time. The lease, not the state, is the mutual
	// exclusion: the outcome states (unallocated, partial, full) are what a
	// finished run leaves behind and must never double as a lock, or a replay
	// re-allocates the remainder and inflates suspense.
	fresh, claimed, claimErr := b.ipRepo.ClaimAllocation(ctx, paymentID, time.Now().Add(-allocationLeaseStaleAfter))
	if claimErr != nil {
		return nil, fmt.Errorf("could not claim payment for allocation: %w", claimErr)
	}
	if !claimed {
		return nil, ErrAllocationInProgress
	}
	// Everything below works from the row as it is under our lease, never
	// from what was read before the claim.
	payment = fresh
	lease := leaseOf(payment)

	// Allocate only what an earlier run left: the persisted remainder, or the
	// whole amount for a payment never allocated before. A payment past its
	// initial state with no recorded remainder is not guessed at.
	startAmount, known := allocatableRemainder(payment)
	if !known || startAmount <= 0 || payment.State == int32(constants.StateInactive) {
		if !known {
			logger.WithField(fieldPaymentID, paymentID).WithField(fieldState, payment.State).
				Warn("payment has no recorded remainder in a non-initial state; refusing to guess")
		}
		b.releaseAllocationLease(ctx, logger, paymentID, lease)
		return allocationAlreadyProcessed(paymentID, payment.State), nil
	}
	if payment.Amount <= 0 {
		b.releaseAllocationLease(ctx, logger, paymentID, lease)
		return nil, fmt.Errorf("payment %s has non-positive amount %d", paymentID, payment.Amount)
	}

	if isBorrowerLoanPayment(payment) {
		return b.allocateToBorrowerLoan(ctx, logger, payment, lease)
	}
	if isBorrowerSavingsPayment(payment) {
		return b.allocateToSavings(ctx, logger, payment, lease)
	}

	membershipID := payment.OwnerID
	if membershipID == "" {
		b.releaseAllocationLease(ctx, logger, paymentID, lease)
		return nil, fmt.Errorf("payment %s has no owner (membership) assigned -- run identification first", paymentID)
	}

	// Retrieve all obligations for this member.
	obligations, err := b.obRepo.GetByMembershipID(ctx, membershipID)
	if err != nil {
		// Treating a load failure as "no obligations" would allocate nothing and
		// mark the payment processed. Drop the lease and surface the error.
		b.releaseAllocationLease(ctx, logger, paymentID, lease)
		return nil, fmt.Errorf("could not retrieve obligations for member: %w", err)
	}

	// Sort obligations by deadline (oldest first)
	sort.Slice(obligations, func(i, j int) bool {
		di := obligationDeadline(obligations[i])
		dj := obligationDeadline(obligations[j])
		return di.Before(dj)
	})

	buckets := buildAllocationBuckets()
	remainingAmount, allocations := b.runAllocationBuckets(
		ctx, logger, buckets, obligations, payment, paymentID, membershipID, startAmount,
	)

	allocatedAmount := payment.Amount - remainingAmount
	paymentState := resolvePaymentState(remainingAmount, allocatedAmount)

	// Update the incoming payment state and record what is left unallocated:
	// the remainder is the member's suspense balance and the apply-suspense
	// path reads it back rather than re-deriving it from the ledger.
	payment.State = paymentState
	landed, stateErr := b.ipRepo.SetAllocationOutcome(ctx, paymentID, lease, paymentState, remainingAmount)
	if stateErr != nil {
		logger.WithError(stateErr).Error("failed to update payment state after allocation")
	} else if !landed {
		// Our lease was taken over as stale while we ran. The orders this
		// run wrote are keyed on (payment, obligation) and the obligations
		// were consumed conditionally, so nothing is double-counted; the
		// newer holder recomputes the remainder from the persisted orders.
		logger.Warn("allocation outcome not recorded: lease was taken over by another run")
	}

	if allocatedAmount > 0 {
		OpsPaymentsAllocated.Add(ctx, 1, attribute.String("currency", payment.Currency))
	}

	return map[string]interface{}{
		fieldPaymentID:       paymentID,
		fieldMembershipID:    membershipID,
		fieldMemberID:        membershipID,
		fieldCurrency:        payment.Currency,
		"total_amount":       payment.Amount,
		"allocated_amount":   allocatedAmount,
		fieldRemainingAmount: remainingAmount,
		// transfer_orders carries one entry per posting, each with the
		// reference the operations service already used as its idempotency
		// key, so a workflow replaying them converges on the same rows.
		fieldTransferOrders: allocations,
		"payment_state":     paymentState,
	}, nil
}

// buildAllocationBuckets returns the priority-ordered allocation buckets.
func buildAllocationBuckets() []allocationBucket {
	active := int32(constants.StateActive)
	return []allocationBucket{
		{name: "overdue_loan_interest", orderType: constants.TransferTypeLoanInterestRepayment,
			filter: obligationMatcher(active, "loan_interest", true, 0)},
		{name: "overdue_loan_fees", orderType: constants.TransferTypeLoanInsuranceRepayment,
			filter: obligationMatcher(active, "loan_fees", true, 0)},
		{name: "overdue_loan_principal", orderType: constants.TransferTypeLoanRepayment,
			filter: obligationMatcher(active, "loan_principal", true, 0)},
		{name: "loan_interest_repayment", orderType: constants.TransferTypeLoanInterestRepayment,
			filter: obligationMatcherCurrent(active, "loan_interest")},
		{name: "loan_fees_repayment", orderType: constants.TransferTypeLoanInsuranceRepayment,
			filter: obligationMatcherCurrent(active, "loan_fees")},
		{name: "loan_principal_repayment", orderType: constants.TransferTypeLoanRepayment,
			filter: obligationMatcherCurrent(active, "loan_principal")},
		{name: obligationPenalty, orderType: constants.TransferTypePenalty,
			filter: func(o *models.Obligation) bool {
				return o.State == active && o.CauseType == obligationPenalty
			}},
		{name: obligationPeriodicSaving, orderType: constants.TransferTypePeriodicSaving,
			filter: func(o *models.Obligation) bool {
				return o.State == active && o.ObligationType == int32(models.ObligationTypePeriodic) &&
					o.CauseType == obligationSaving
			}},
		{name: obligationRegistrationFee, orderType: constants.TransferTypeRegistrationFee,
			filter: func(o *models.Obligation) bool {
				return o.State == active && o.ObligationType == int32(models.ObligationTypeOneTime) &&
					o.CauseType == obligationRegistrationFee
			}},
		{name: obligationServiceFee, orderType: constants.TransferTypeServiceFee,
			filter: func(o *models.Obligation) bool {
				return o.State == active && o.CauseType == obligationServiceFee
			}},
	}
}

// obligationMatcher returns a filter for active obligations of a given cause type that are overdue.
func obligationMatcher(activeState int32, causeType string, overdue bool, _ int) func(*models.Obligation) bool {
	return func(o *models.Obligation) bool {
		return o.State == activeState && o.CauseType == causeType && isOverdue(o) == overdue
	}
}

// obligationMatcherCurrent returns a filter for active, non-overdue obligations of a given cause type.
func obligationMatcherCurrent(activeState int32, causeType string) func(*models.Obligation) bool {
	return func(o *models.Obligation) bool {
		return o.State == activeState && o.CauseType == causeType && !isOverdue(o)
	}
}

// runAllocationBuckets walks priority buckets and allocates funds from the payment.
func (b *paymentRoutingBusiness) runAllocationBuckets(
	ctx context.Context,
	logger *util.LogEntry,
	buckets []allocationBucket,
	obligations []*models.Obligation,
	payment *models.IncomingPayment,
	paymentID, membershipID string,
	startAmount int64,
) (int64, []map[string]interface{}) {
	remainingAmount := startAmount
	var allocations []map[string]interface{}

	for _, bkt := range buckets {
		if remainingAmount <= 0 {
			break
		}
		var allocated int64
		allocated, allocations = b.allocateBucket(
			ctx, logger, bkt, obligations, payment,
			paymentID, membershipID, remainingAmount, allocations,
		)
		remainingAmount -= allocated
	}

	return remainingAmount, allocations
}

// resolvePaymentState determines the final payment state based on allocation outcome.
func resolvePaymentState(remaining, allocated int64) int32 {
	switch {
	case remaining == 0:
		return int32(constants.StateInactive)
	case allocated > 0:
		return int32(constants.StateActive)
	default:
		return int32(constants.StateCheckCreated)
	}
}

// allocateBucket processes a single priority bucket against obligations.
func (b *paymentRoutingBusiness) allocateBucket(
	ctx context.Context,
	logger *util.LogEntry,
	bkt allocationBucket,
	obligations []*models.Obligation,
	payment *models.IncomingPayment,
	paymentID, membershipID string,
	remainingAmount int64,
	allocations []map[string]interface{},
) (int64, []map[string]interface{}) {
	var totalAllocated int64

	for _, obl := range obligations {
		if remainingAmount <= 0 {
			break
		}
		if !bkt.filter(obl) || obl.Amount <= 0 {
			continue
		}

		originalAmount := obl.Amount
		allocAmount := min(originalAmount, remainingAmount)

		to, outcome := b.allocateObligation(ctx, logger, bkt, obl, payment, paymentID, membershipID, allocAmount)
		switch outcome {
		case allocationSkipped:
			continue
		case allocationRecordedEarlier:
			// An earlier run wrote this order and consumed the obligation
			// but did not get to record its outcome. The money is spoken
			// for: count it toward this payment, do not consume again.
			allocAmount = to.Amount
		case allocationDone:
			obl.Amount = originalAmount - allocAmount
			if obl.Amount <= 0 {
				obl.State = int32(constants.StateInactive)
			}
		}

		remainingAmount -= allocAmount
		totalAllocated += allocAmount
		allocations = append(allocations, map[string]interface{}{
			"bucket":             bkt.name,
			"obligation_id":      obl.GetID(),
			fieldTransferOrderID: to.GetID(),
			fieldAmount:          allocAmount,
			"partial":            allocAmount < originalAmount,
			"from_account":       to.DebitAccountRef,
			"to_account":         to.CreditAccountRef,
			fieldCurrency:        to.Currency,
			"type":               to.OrderType,
			fieldReference:       to.Reference,
		})

		logger.WithField("bucket", bkt.name).
			WithField("obligation_id", obl.GetID()).
			WithField("amount", allocAmount).
			Info("allocated payment to obligation")
	}

	return totalAllocated, allocations
}

// allocateObligation writes the transfer order for one (payment, obligation)
// pair and consumes the obligation. The order is written first and
// synchronously, keyed on the pair: a row that already exists means an
// earlier run allocated this pair and consumed the obligation, so this run
// must not count it again. Only a freshly written order goes on to consume
// the obligation; one that loses that race is parked so it never executes.
// It reports whether this run allocated the amount, an earlier run did, or
// nothing was allocated.
func (b *paymentRoutingBusiness) allocateObligation(
	ctx context.Context,
	logger *util.LogEntry,
	bkt allocationBucket,
	obl *models.Obligation,
	payment *models.IncomingPayment,
	paymentID, membershipID string,
	allocAmount int64,
) (*models.TransferOrder, allocationOutcome) {
	// ExtraData is written by this allocation path only: the loans feedback
	// in the transfer-order side effect trusts the server-set source marker,
	// never a loan id a caller put on an order.
	extra := data.JSONMap{
		extraKeySource:     allocationSourceMarker,
		"payment_id":       paymentID,
		"obligation_id":    obl.GetID(),
		"membership_id":    membershipID,
		"obligation_cause": obl.CauseType,
	}
	// A loan obligation's cause id is the schedule entry, not the loan; the
	// loan account id was recorded on the obligation when it was raised.
	if loanID := obligationLoanAccountID(obl); loanID != "" {
		extra[fieldLoanID] = loanID
	}
	to := &models.TransferOrder{
		DebitAccountRef:  constants.MemberSuspenseAccount(membershipID),
		CreditAccountRef: b.creditAccountForBucket(bkt.name, membershipID, obl),
		Amount:           allocAmount,
		Currency:         payment.Currency,
		OrderType:        constants.SafeInt32FromInt(bkt.orderType),
		Reference:        fmt.Sprintf("payment:%s:obligation:%s", paymentID, obl.GetID()),
		Description:      fmt.Sprintf("Auto-allocation of %s from payment %s", bkt.name, paymentID),
		State:            int32(constants.StateJustCreated),
		ExtraData:        extra,
	}
	to.GenID(ctx)
	to.CopyPartitionInfo(&payment.BaseModel)
	freshID := to.GetID()

	if createErr := b.toRepo.CreateIfAbsent(ctx, to); createErr != nil {
		logger.WithError(createErr).WithField("bucket", bkt.name).
			Error("failed to create transfer order for allocation")
		return nil, allocationSkipped
	}
	if to.GetID() != freshID {
		switch {
		case to.State == int32(constants.StateShutdown):
			// Parked by an earlier run whose obligation consumption failed:
			// nothing was allocated for this pair.
			return nil, allocationSkipped
		case to.ObligationConsumed:
			// An earlier run completed this pair but did not get to record
			// its outcome. The money is spoken for; count the stored amount.
			logger.WithField("transfer_order_id", to.GetID()).WithField("obligation_id", obl.GetID()).
				Info("allocation already recorded by an earlier run; counting it, not consuming again")
			return to, allocationRecordedEarlier
		default:
			// Written but never completed: finish what the earlier run
			// started, with its stored amount, under the same rules.
			allocAmount = to.Amount
		}
	}

	// Consuming the obligation and marking the order are one transaction:
	// either both land or neither does.
	consumed, consumeErr := b.toRepo.ConsumeObligationForOrder(ctx, to.GetID(), obl.GetID(), allocAmount)
	if consumeErr != nil {
		logger.WithError(consumeErr).WithField("obligation_id", obl.GetID()).Error("could not consume obligation")
	}
	if consumeErr != nil || !consumed {
		if _, parkErr := b.toRepo.MarkFailedIfUnposted(ctx, to.GetID()); parkErr != nil {
			logger.WithError(parkErr).WithField("transfer_order_id", to.GetID()).
				Error("could not park the transfer order of an unconsumed obligation")
		}
		return nil, allocationSkipped
	}
	to.ObligationConsumed = true
	return to, allocationDone
}

// allocatableRemainder is the amount an allocation run may still allocate.
// A payment never allocated (still JustCreated) has its whole amount; any
// other state must carry the remainder an earlier run recorded, otherwise
// the answer is unknown and the caller refuses rather than guesses.
func allocatableRemainder(payment *models.IncomingPayment) (int64, bool) {
	if payment.Properties != nil {
		if raw, ok := payment.Properties[fieldRemainingAmount]; ok {
			switch typed := raw.(type) {
			case float64:
				return int64(typed), true
			case int64:
				return typed, true
			}
		}
	}
	if payment.State == int32(constants.StateJustCreated) {
		return payment.Amount, true
	}
	return 0, false
}

// allocationOutcome says what allocateObligation did for one pair.
type allocationOutcome int

const (
	allocationSkipped allocationOutcome = iota
	allocationDone
	allocationRecordedEarlier
)

// creditAccountForBucket returns the appropriate credit account reference for a given
// allocation bucket and obligation.
func (b *paymentRoutingBusiness) creditAccountForBucket(bucket, membershipID string, obl *models.Obligation) string {
	groupID := ""
	if obl.Properties != nil {
		if gid, ok := obl.Properties["group_id"]; ok {
			groupID, _ = gid.(string)
		}
	}

	switch bucket {
	case "overdue_loan_interest", "loan_interest_repayment":
		return constants.GroupInterestIncomeAccount(groupID)
	case "overdue_loan_fees", "loan_fees_repayment":
		return constants.GroupServiceFeeAccount(groupID)
	case obligationPenalty:
		return constants.GroupPenaltyIncomeAccount(groupID)
	case "overdue_loan_principal", "loan_principal_repayment":
		return constants.MemberLoansAccount(membershipID)
	case obligationPeriodicSaving:
		return constants.MemberPeriodicSavingsAccount(membershipID)
	case obligationRegistrationFee:
		return constants.GroupJoiningFeeAccount(groupID)
	case obligationServiceFee:
		return constants.GroupServiceFeeAccount(groupID)
	default:
		return constants.MemberSuspenseAccount(membershipID)
	}
}

// filterActiveProtoMemberships returns only memberships that are not deleted or shut down.
func filterActiveProtoMemberships(members []*identityv1.MembershipObject) []*identityv1.MembershipObject {
	var active []*identityv1.MembershipObject
	for _, m := range members {
		state := int32(m.GetState())
		if state == GroupStateDeleted || state == GroupStateShutdown {
			continue
		}
		active = append(active, m)
	}
	return active
}

// isOverdue returns true when an obligation's deadline has passed.
func isOverdue(o *models.Obligation) bool {
	if o.Deadline == nil {
		return false
	}
	return o.Deadline.Before(time.Now())
}

// obligationDeadline returns the obligation's deadline or a far-future sentinel.
func obligationDeadline(o *models.Obligation) time.Time {
	if o.Deadline != nil {
		return *o.Deadline
	}
	return time.Date(9999, 12, 31, 23, 59, 59, 0, time.UTC)
}

// normalizeNameForComparison lowercases and collapses whitespace for fuzzy name matching.
func normalizeNameForComparison(name string) string {
	name = strings.ToLower(strings.TrimSpace(name))
	parts := strings.Fields(name)
	return strings.Join(parts, " ")
}

func extractPaymentReference(paymentData map[string]interface{}, payment *models.IncomingPayment) string {
	reference := strings.TrimSpace(extractString(paymentData, "reference"))
	if reference != "" {
		return reference
	}
	if payment != nil && payment.Properties != nil {
		reference = strings.TrimSpace(payment.Properties.GetString("reference"))
		if reference != "" {
			return reference
		}
	}

	return firstNonEmptyString(
		strings.TrimSpace(extractString(paymentData, fieldPayerReference)),
		strings.TrimSpace(payment.Properties.GetString(fieldPayerReference)),
	)
}

func incomingPaymentProperties(paymentData map[string]interface{}) data.JSONMap {
	properties := jsonMapFromValue(paymentData["properties"])
	for _, key := range []string{fieldPayerReference, fieldPayerName, fieldProductID, fieldGroupID, fieldReference} {
		if value := strings.TrimSpace(extractString(paymentData, key)); value != "" {
			properties[key] = value
		}
	}

	return properties
}

func jsonMapFromValue(value interface{}) data.JSONMap {
	switch typed := value.(type) {
	case nil:
		return data.JSONMap{}
	case data.JSONMap:
		return typed.Copy()
	case map[string]interface{}:
		result := data.JSONMap{}
		for key, item := range typed {
			result[key] = item
		}
		return result
	default:
		return data.JSONMap{}
	}
}

func mergeJSONMaps(base, updates data.JSONMap) data.JSONMap {
	merged := data.JSONMap{}
	for key, value := range base {
		merged[key] = value
	}
	for key, value := range updates {
		merged[key] = value
	}

	return merged
}

func jsonMapsEqual(left, right data.JSONMap) bool {
	if len(left) != len(right) {
		return false
	}
	for key, value := range left {
		if right[key] != value {
			return false
		}
	}

	return true
}

func extractString(values map[string]interface{}, key string) string {
	raw, ok := values[key]
	if !ok || raw == nil {
		return ""
	}

	switch typed := raw.(type) {
	case string:
		return typed
	default:
		return fmt.Sprintf("%v", typed)
	}
}

func firstNonEmptyString(values ...string) string {
	for _, value := range values {
		if strings.TrimSpace(value) != "" {
			return value
		}
	}

	return ""
}

// getMembersByGroupID fetches group memberships via the identity SDK.
func (b *paymentRoutingBusiness) getMembersByGroupID(
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

// getMembersByProfileID fetches memberships for a profile via the identity SDK.
func (b *paymentRoutingBusiness) getMembersByProfileID(
	ctx context.Context,
	profileID string,
) ([]*identityv1.MembershipObject, error) {
	if b.identityCli == nil {
		return nil, errors.New("identity client not available")
	}

	stream, err := b.identityCli.MembershipSearch(ctx, &identityv1.MembershipSearchRequest{ProfileId: profileID})
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

// releaseAllocationLease drops the lease of a run that did no work.
func (b *paymentRoutingBusiness) releaseAllocationLease(
	ctx context.Context,
	logger *util.LogEntry,
	paymentID string,
	lease time.Time,
) {
	if err := b.ipRepo.ReleaseAllocation(ctx, paymentID, lease); err != nil {
		logger.WithError(err).WithField(fieldPaymentID, paymentID).Warn("could not release allocation lease")
	}
}

// leaseOf returns the lease a claimed payment row carries.
func leaseOf(payment *models.IncomingPayment) time.Time {
	if payment == nil || payment.AllocatingAt == nil {
		return time.Time{}
	}
	return *payment.AllocatingAt
}

// obligationLoanAccountID returns the loan account a loan obligation belongs
// to, or "" for obligations that are not loan obligations or predate the
// loan_account_id property (those are not fed back to the lender).
func obligationLoanAccountID(obl *models.Obligation) string {
	if obl == nil || !strings.HasPrefix(obl.CauseType, "loan_") || obl.Properties == nil {
		return ""
	}
	loanID, _ := obl.Properties[fieldLoanAccountID].(string)
	return strings.TrimSpace(loanID)
}
