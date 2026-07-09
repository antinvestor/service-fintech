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
	"sort"
	"strings"
	"time"

	"go.opentelemetry.io/otel/attribute"

	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/operations/service/events"
	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

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
		extractString(paymentData, "payer_reference"),
		payment.Properties.GetString("payer_reference"),
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
			if saveErr := b.applyIdentificationResult(ctx, payment, result); saveErr != nil {
				return nil, saveErr
			}
			logger.WithField("membership_id", result.MembershipID).
				Info(fmt.Sprintf("payment identified via strategy %d: %s", i+1, s.name))
			recordPaymentIdentified(ctx, payment)
			return b.buildIdentificationResult(payment, result), nil
		}
	}

	logger.Warn("payment could not be identified, routing to unidentified account")
	recordPaymentUnmatched(ctx)
	unidentified := map[string]interface{}{
		fieldPaymentID: payment.GetID(),
		"strategy":     "unidentified",
		"reason":       "no matching member found across all identification strategies",
	}
	if productID != "" {
		unidentified["unidentified_account"] = constants.ProductUnidentifiedAccount(productID)
	}
	return unidentified, nil
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

	if emitErr := b.eventsMan.Emit(ctx, events.IncomingPaymentSaveEvent, payment); emitErr != nil {
		return nil, fmt.Errorf("create incoming payment: %w", emitErr)
	}

	return payment, nil
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
	resp, err := b.identityCli.MembershipGet(ctx, connect.NewRequest(
		&identityv1.MembershipGetRequest{Id: ref},
	))
	if err != nil {
		return nil, err
	}
	mem := resp.Msg.GetData()
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
		"strategy":        r.Strategy,
		fieldMembershipID: r.MembershipID,
		fieldGroupID:      r.GroupID,
		fieldProfileID:    r.ProfileID,
	}
}

func (b *paymentRoutingBusiness) buildStoredPaymentResult(payment *models.IncomingPayment) map[string]interface{} {
	result := map[string]interface{}{
		fieldPaymentID:    payment.GetID(),
		fieldMembershipID: payment.OwnerID,
	}
	if payment.Properties != nil {
		if strategy := payment.Properties.GetString("identification_strategy"); strategy != "" {
			result["strategy"] = strategy
		}
		if groupID := payment.Properties.GetString("group_id"); groupID != "" {
			result["group_id"] = groupID
		}
		if profileID := payment.Properties.GetString("profile_id"); profileID != "" {
			result["profile_id"] = profileID
		}
	}
	if _, ok := result["strategy"]; !ok {
		result["strategy"] = "persisted"
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
	payment.Properties = mergeJSONMaps(payment.Properties, data.JSONMap{
		"identification_strategy": result.Strategy,
		fieldGroupID:              result.GroupID,
		fieldProfileID:            result.ProfileID,
	})

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

	// Idempotency + concurrency guard: only allocate payments in initial state.
	if payment.State != int32(constants.StateJustCreated) && payment.State != int32(constants.StateCheckCreated) {
		return map[string]interface{}{
			fieldPaymentID: paymentID,
			"status":       "already_processed",
			fieldState:     payment.State,
		}, nil
	}

	// Claim the payment for processing to prevent concurrent allocation.
	payment.State = int32(constants.StateCheckCreated)
	if err = b.eventsMan.Emit(ctx, events.IncomingPaymentSaveEvent, payment); err != nil {
		return nil, fmt.Errorf("could not claim payment for allocation: %w", err)
	}

	if payment.Amount <= 0 {
		return nil, fmt.Errorf("payment %s has non-positive amount %d", paymentID, payment.Amount)
	}

	membershipID := payment.OwnerID
	if membershipID == "" {
		return nil, fmt.Errorf("payment %s has no owner (membership) assigned -- run identification first", paymentID)
	}

	// Retrieve all obligations for this member.
	obligations, err := b.obRepo.GetByMembershipID(ctx, membershipID)
	if err != nil {
		logger.WithError(err).Warn("could not retrieve obligations for member")
		obligations = nil
	}

	// Sort obligations by deadline (oldest first)
	sort.Slice(obligations, func(i, j int) bool {
		di := obligationDeadline(obligations[i])
		dj := obligationDeadline(obligations[j])
		return di.Before(dj)
	})

	buckets := buildAllocationBuckets()
	remainingAmount, allocations := b.runAllocationBuckets(
		ctx, logger, buckets, obligations, payment, paymentID, membershipID,
	)

	allocatedAmount := payment.Amount - remainingAmount
	paymentState := resolvePaymentState(remainingAmount, allocatedAmount)

	// Update the incoming payment state.
	payment.State = paymentState
	if emitErr := b.eventsMan.Emit(ctx, events.IncomingPaymentSaveEvent, payment); emitErr != nil {
		logger.WithError(emitErr).Error("failed to update payment state after allocation")
	}

	if allocatedAmount > 0 {
		OpsPaymentsAllocated.Add(ctx, 1, attribute.String("currency", payment.Currency))
	}

	return map[string]interface{}{
		fieldPaymentID:     paymentID,
		fieldMembershipID:  membershipID,
		"total_amount":     payment.Amount,
		"allocated_amount": allocatedAmount,
		"remaining_amount": remainingAmount,
		"allocations":      allocations,
		"payment_state":    paymentState,
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
					o.CauseType == "saving"
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
) (int64, []map[string]interface{}) {
	remainingAmount := payment.Amount
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

		allocAmount := obl.Amount
		if allocAmount > remainingAmount {
			allocAmount = remainingAmount
		}

		debitAccount := constants.MemberSuspenseAccount(membershipID)
		creditAccount := b.creditAccountForBucket(bkt.name, membershipID, obl)

		to := &models.TransferOrder{
			DebitAccountRef:  debitAccount,
			CreditAccountRef: creditAccount,
			Amount:           allocAmount,
			Currency:         payment.Currency,
			OrderType:        constants.SafeInt32FromInt(bkt.orderType),
			Reference:        fmt.Sprintf("payment:%s:obligation:%s", paymentID, obl.GetID()),
			Description:      fmt.Sprintf("Auto-allocation of %s from payment %s", bkt.name, paymentID),
			State:            int32(constants.StateJustCreated),
		}
		to.GenID(ctx)

		if emitErr := b.eventsMan.Emit(ctx, events.TransferOrderSaveEvent, to); emitErr != nil {
			logger.WithError(emitErr).WithField("bucket", bkt.name).
				Error("failed to create transfer order for allocation")
			continue
		}

		if allocAmount < obl.Amount {
			obl.Amount -= allocAmount
			if emitErr := b.eventsMan.Emit(ctx, events.ObligationSaveEvent, obl); emitErr != nil {
				logger.WithError(emitErr).WithField("obligation_id", obl.GetID()).
					Error("could not update partial obligation")
			}
		} else {
			obl.State = int32(constants.StateInactive)
			if emitErr := b.eventsMan.Emit(ctx, events.ObligationSaveEvent, obl); emitErr != nil {
				logger.WithError(emitErr).WithField("obligation_id", obl.GetID()).
					Error("could not deactivate obligation")
			}
		}

		remainingAmount -= allocAmount
		totalAllocated += allocAmount
		allocations = append(allocations, map[string]interface{}{
			"bucket":            bkt.name,
			"obligation_id":     obl.GetID(),
			"transfer_order_id": to.GetID(),
			fieldAmount:         allocAmount,
			"partial":           allocAmount < obl.Amount,
		})

		logger.WithField("bucket", bkt.name).
			WithField("obligation_id", obl.GetID()).
			WithField("amount", allocAmount).
			Info("allocated payment to obligation")
	}

	return totalAllocated, allocations
}

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
		strings.TrimSpace(extractString(paymentData, "payer_reference")),
		strings.TrimSpace(payment.Properties.GetString("payer_reference")),
	)
}

func incomingPaymentProperties(paymentData map[string]interface{}) data.JSONMap {
	properties := jsonMapFromValue(paymentData["properties"])
	for _, key := range []string{"payer_reference", fieldPayerName, fieldProductID, fieldGroupID, "reference"} {
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

// getMembersByProfileID fetches memberships for a profile via the identity SDK.
func (b *paymentRoutingBusiness) getMembersByProfileID(
	ctx context.Context,
	profileID string,
) ([]*identityv1.MembershipObject, error) {
	if b.identityCli == nil {
		return nil, errors.New("identity client not available")
	}

	stream, err := b.identityCli.MembershipSearch(ctx, connect.NewRequest(
		&identityv1.MembershipSearchRequest{ProfileId: profileID},
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
