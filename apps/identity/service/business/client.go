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
	"strconv"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"github.com/pitabwire/frame/data"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

type ClientBusiness interface {
	Save(ctx context.Context, obj *fieldv1.ClientObject) (*fieldv1.ClientObject, error)
	Get(ctx context.Context, id string) (*fieldv1.ClientObject, error)
	Search(
		ctx context.Context,
		req *fieldv1.ClientSearchRequest,
		consumer func(ctx context.Context, batch []*fieldv1.ClientObject) error,
	) error
	Reassign(ctx context.Context, req *fieldv1.ClientReassignRequest) (*fieldv1.ClientObject, error)
	TransferOwnership(
		ctx context.Context,
		req *fieldv1.ClientOwnershipTransferRequest,
	) (*fieldv1.ClientObject, error)
	SetAgentCreditLimit(ctx context.Context, clientID string, amount int64) error
	RequestSystemCreditLimitChange(
		ctx context.Context,
		clientID string,
		newLimit int64,
		reason, requestedBy string,
	) (*models.CreditLimitChangeRequest, error)
	ApproveSystemCreditLimitChange(ctx context.Context, requestID string, reviewedBy, notes string) error
	RejectSystemCreditLimitChange(ctx context.Context, requestID string, reviewedBy, notes string) error
	GetEffectiveCreditLimit(ctx context.Context, clientID string) (int64, string, error)
}

type clientBusiness struct {
	eventsMan          fevents.Manager
	clientRepo         repository.ClientRepository
	clientHistoryRepo  repository.ClientResponsibilityHistoryRepository
	clcrRepo           repository.CreditLimitChangeRequestRepository
	approvalCases      ApprovalCaseBusiness
	workforceRepo      repository.WorkforceMemberRepository
	internalTeamRepo   repository.InternalTeamRepository
	teamMembershipRepo repository.TeamMembershipRepository
}

func NewClientBusiness(_ context.Context, eventsMan fevents.Manager,
	clientRepo repository.ClientRepository,
	clientHistoryRepo repository.ClientResponsibilityHistoryRepository,
	clcrRepo repository.CreditLimitChangeRequestRepository,
	approvalCases ApprovalCaseBusiness,
	workforceRepo repository.WorkforceMemberRepository,
	internalTeamRepo repository.InternalTeamRepository,
	teamMembershipRepo repository.TeamMembershipRepository,
) ClientBusiness {
	return &clientBusiness{
		eventsMan:          eventsMan,
		clientRepo:         clientRepo,
		clientHistoryRepo:  clientHistoryRepo,
		clcrRepo:           clcrRepo,
		approvalCases:      approvalCases,
		workforceRepo:      workforceRepo,
		internalTeamRepo:   internalTeamRepo,
		teamMembershipRepo: teamMembershipRepo,
	}
}

func (b *clientBusiness) Save(ctx context.Context, obj *fieldv1.ClientObject) (*fieldv1.ClientObject, error) {
	logger := util.Log(ctx).WithField("method", "ClientBusiness.Save")
	var err error

	isNew := obj.GetId() == ""
	client := models.ClientFromAPI(ctx, obj)
	client.Properties = normalizeClientPhoneProperties(entityProperties(client.Properties))
	if client.OwningTeamID == "" {
		return nil, ErrOwningTeamRequired
	}
	if errOwn := b.validateOwnership(ctx, client.OwningTeamID, ""); errOwn != nil {
		logger.WithError(errOwn).Warn("invalid client ownership")
		return nil, errOwn
	}

	if isNew && client.State == 0 {
		client.State = int32(commonv1.STATE_CREATED.Number())
	}

	if action := caseAction(client.Properties); action != "" {
		return b.handleApprovalAction(ctx, logger, client, action)
	}

	if !isNew {
		existing, getErr := b.clientRepo.GetByID(ctx, client.GetID())
		if getErr != nil {
			return nil, ErrClientNotFound
		}

		if desiredPhone, currentPhone := clientPhoneNumber(
			client.Properties,
		), clientPhoneNumber(
			existing.Properties,
		); desiredPhone != currentPhone {
			return b.submitPhoneChangeCase(ctx, logger, existing, client, desiredPhone)
		}

		client.TenantID = existing.TenantID
		client.PartitionID = existing.PartitionID
		if client.AgentID == "" {
			client.AgentID = existing.AgentID
		}
		client.CurrencyCode = existing.CurrencyCode
		client.SystemCreditLimit = existing.SystemCreditLimit
		client.AgentCreditLimit = existing.AgentCreditLimit
		mergedProps := entityProperties(existing.Properties)
		for k, v := range client.Properties {
			mergedProps[k] = v
		}
		stripCaseCommand(mergedProps)
		client.Properties = normalizeClientPhoneProperties(mergedProps)
	}

	if err = b.eventsMan.Emit(ctx, events.ClientSaveEvent, client); err != nil {
		logger.WithError(err).Error("could not emit client save event")
		return nil, err
	}

	return client.ToAPI(), nil
}

func (b *clientBusiness) submitPhoneChangeCase(
	ctx context.Context,
	logger *util.LogEntry,
	existing *models.Client,
	incoming *models.Client,
	requestedPhone string,
) (*fieldv1.ClientObject, error) {
	if _, err := b.approvalCases.GetOpenBySubject(
		ctx, approvalCaseSubjectClient, existing.GetID(), approvalCaseTypeClientPhoneChange,
	); err == nil {
		return nil, ErrClientPhoneChangePending
	}

	approvalCase, err := b.approvalCases.Submit(ctx, ApprovalCaseSubmission{
		SubjectType: approvalCaseSubjectClient,
		SubjectID:   existing.GetID(),
		CaseType:    approvalCaseTypeClientPhoneChange,
		Summary: fmt.Sprintf(
			"Client %s phone number change requires verification and approval",
			existing.Name,
		),
		RequestedBy:         caseActorID(incoming.Properties),
		Comment:             caseComment(incoming.Properties),
		RequireVerification: true,
		Payload: map[string]any{
			approvalCaseRequestedValueKey: requestedPhone,
		},
	})
	if err != nil {
		logger.WithError(err).Error("could not create phone change approval case")
		return nil, err
	}

	mergedProps := entityProperties(existing.Properties)
	for k, v := range incoming.Properties {
		mergedProps[k] = v
	}
	setClientPhoneNumber(mergedProps, clientPhoneNumber(existing.Properties))
	if requestedPhone != "" {
		mergedProps[clientPendingPhoneNumberKey] = requestedPhone
	} else {
		delete(mergedProps, clientPendingPhoneNumberKey)
	}
	stripCaseCommand(mergedProps)
	existing.Name = incoming.Name
	existing.Properties = applyApprovalCaseSnapshot(normalizeClientPhoneProperties(mergedProps), approvalCase)

	if err = b.eventsMan.Emit(ctx, events.ClientSaveEvent, existing); err != nil {
		logger.WithError(err).Error("could not persist phone change request")
		return nil, err
	}

	return existing.ToAPI(), nil
}

func (b *clientBusiness) handleApprovalAction(
	ctx context.Context,
	logger *util.LogEntry,
	client *models.Client,
	action string,
) (*fieldv1.ClientObject, error) {
	if client.GetID() == "" {
		return nil, ErrClientNotFound
	}

	existing, err := b.clientRepo.GetByID(ctx, client.GetID())
	if err != nil {
		return nil, ErrClientNotFound
	}

	props := entityProperties(existing.Properties)
	approvalCase, err := b.approvalCases.GetOpenBySubject(
		ctx, approvalCaseSubjectClient, existing.GetID(), approvalCaseTypeClientPhoneChange,
	)
	if err != nil {
		return nil, ErrApprovalCaseNotFound
	}

	actorID := caseActorID(client.Properties)
	comment := caseComment(client.Properties)

	switch action {
	case approvalCaseActionVerify:
		approvalCase, err = b.approvalCases.Verify(ctx, approvalCase.GetID(), actorID, comment)
	case approvalCaseActionApprove:
		approvalCase, err = b.approvalCases.Approve(ctx, approvalCase.GetID(), actorID, comment)
		if err == nil {
			setClientPhoneNumber(props, stringValue(approvalCase.Payload[approvalCaseRequestedValueKey]))
			delete(props, clientPendingPhoneNumberKey)
		}
	case approvalCaseActionReject:
		approvalCase, err = b.approvalCases.Reject(ctx, approvalCase.GetID(), actorID, comment)
		if err == nil {
			delete(props, clientPendingPhoneNumberKey)
		}
	default:
		return nil, ErrApprovalCaseNotPending.Extend("unsupported case action")
	}
	if err != nil {
		return nil, err
	}

	stripCaseCommand(props)
	existing.Properties = applyApprovalCaseSnapshot(normalizeClientPhoneProperties(props), approvalCase)
	if err = b.eventsMan.Emit(ctx, events.ClientSaveEvent, existing); err != nil {
		logger.WithError(err).Error("could not persist client approval action")
		return nil, err
	}

	logApprovalCaseTransition(ctx, action, approvalCase)
	return existing.ToAPI(), nil
}

func (b *clientBusiness) Get(ctx context.Context, id string) (*fieldv1.ClientObject, error) {
	client, err := b.clientRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	return client.ToAPI(), nil
}

func (b *clientBusiness) Search(
	ctx context.Context,
	req *fieldv1.ClientSearchRequest,
	consumer func(ctx context.Context, batch []*fieldv1.ClientObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "ClientBusiness.Search")

	var searchOpts []data.SearchOption

	cursor := req.GetCursor()
	if cursor != nil {
		offset, offsetErr := strconv.Atoi(cursor.GetPage())
		if offsetErr != nil {
			offset = 0
		}
		searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(int(cursor.GetLimit())))
	}

	andQueryVal := map[string]any{}
	if req.GetAgentId() != "" {
		andQueryVal["agent_id = ?"] = req.GetAgentId()
	}
	if req.GetOwningTeamId() != "" {
		andQueryVal["owning_team_id = ?"] = req.GetOwningTeamId()
	}
	if req.GetMemberId() != "" {
		andQueryVal["member_id = ?"] = req.GetMemberId()
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	if req.GetQuery() != "" {
		searchOpts = append(searchOpts,
			data.WithSearchFiltersOrByValue(
				map[string]any{searchableTSQuery: req.GetQuery()},
			),
		)
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.clientRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search clients")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.Client) error {
		var apiResults []*fieldv1.ClientObject
		for _, client := range res {
			apiResults = append(apiResults, client.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}

func (b *clientBusiness) Reassign(
	_ context.Context,
	_ *fieldv1.ClientReassignRequest,
) (*fieldv1.ClientObject, error) {
	return nil, ErrDeprecatedClientAgentReassignment
}

func (b *clientBusiness) TransferOwnership(
	ctx context.Context,
	req *fieldv1.ClientOwnershipTransferRequest,
) (*fieldv1.ClientObject, error) {
	client, err := b.clientRepo.GetByID(ctx, req.GetClientId())
	if err != nil {
		return nil, ErrClientNotFound
	}
	if errOwn := b.validateOwnership(ctx, req.GetNewOwningTeamId(), ""); errOwn != nil {
		return nil, errOwn
	}

	previousTeamID := client.OwningTeamID
	client.OwningTeamID = req.GetNewOwningTeamId()

	if errEmit := b.eventsMan.Emit(ctx, events.ClientSaveEvent, client); errEmit != nil {
		return nil, errEmit
	}
	b.recordResponsibilityHistory(
		ctx,
		client.GetID(),
		previousTeamID,
		client.OwningTeamID,
		"",
		"",
		req.GetReason(),
		"ownership_transfer",
	)
	return client.ToAPI(), nil
}

func (b *clientBusiness) validateOwnership(ctx context.Context, teamID, memberID string) error {
	if teamID == "" {
		return ErrOwningTeamRequired
	}
	if _, err := b.internalTeamRepo.GetByID(ctx, teamID); err != nil {
		return ErrInternalTeamNotFound
	}
	if memberID == "" {
		return nil
	}
	if _, err := b.workforceRepo.GetByID(ctx, memberID); err != nil {
		return ErrWorkforceMemberNotFound
	}
	if _, err := b.teamMembershipRepo.GetActiveMembership(ctx, teamID, memberID); err != nil {
		return ErrMemberNotInTeam
	}
	return nil
}

func (b *clientBusiness) recordResponsibilityHistory(
	ctx context.Context,
	clientID, previousTeamID, newTeamID, previousMemberID, newMemberID, reason, kind string,
) {
	if b.clientHistoryRepo == nil {
		return
	}
	history := &models.ClientResponsibilityHistory{
		ClientID:               clientID,
		PreviousOwningTeamID:   previousTeamID,
		NewOwningTeamID:        newTeamID,
		PreviousRelationshipID: previousMemberID,
		NewRelationshipID:      newMemberID,
		Reason:                 reason,
		AssignmentKind:         kind,
	}
	history.GenID(ctx)
	if err := b.clientHistoryRepo.Create(ctx, history); err != nil {
		util.Log(ctx).WithError(err).WithField("client_id", clientID).
			Warn("could not persist client responsibility history")
	}
}

// SetAgentCreditLimit allows the responsible agent to set the client's
// agent-controlled credit limit. Must be between 0 and the system limit.
func (b *clientBusiness) SetAgentCreditLimit(ctx context.Context, clientID string, amount int64) error {
	logger := util.Log(ctx).WithField("method", "ClientBusiness.SetAgentCreditLimit")

	client, err := b.clientRepo.GetByID(ctx, clientID)
	if err != nil {
		return ErrClientNotFound
	}

	if amount < 0 {
		return ErrCreditLimitNegative
	}

	if client.SystemCreditLimit > 0 && amount > client.SystemCreditLimit {
		return ErrAgentLimitExceedsSystem
	}

	client.AgentCreditLimit = amount

	if err = b.eventsMan.Emit(ctx, events.ClientSaveEvent, client); err != nil {
		logger.WithError(err).Error("could not update agent credit limit")
		return err
	}

	logger.WithField("client_id", clientID).
		WithField("agent_limit", amount).
		Info("agent credit limit updated")

	return nil
}

// RequestSystemCreditLimitChange creates a case to change the system credit limit.
// This initiates a verification and approval process.
func (b *clientBusiness) RequestSystemCreditLimitChange(
	ctx context.Context,
	clientID string,
	newLimit int64,
	reason, requestedBy string,
) (*models.CreditLimitChangeRequest, error) {
	logger := util.Log(ctx).WithField("method", "ClientBusiness.RequestSystemCreditLimitChange")

	client, err := b.clientRepo.GetByID(ctx, clientID)
	if err != nil {
		return nil, ErrClientNotFound
	}

	if newLimit < 0 {
		return nil, ErrCreditLimitNegative
	}

	// Check for existing pending requests
	pending, err := b.clcrRepo.GetPendingByClientID(ctx, clientID)
	if err == nil && len(pending) > 0 {
		return nil, ErrCreditLimitChangePending
	}

	req := &models.CreditLimitChangeRequest{
		ClientID:       clientID,
		CurrentLimit:   client.SystemCreditLimit,
		RequestedLimit: newLimit,
		CurrencyCode:   client.CurrencyCode,
		Reason:         reason,
		RequestedBy:    requestedBy,
		Status:         1, // pending
	}
	req.GenID(ctx)

	if err = b.eventsMan.Emit(ctx, events.CreditLimitChangeRequestSaveEvent, req); err != nil {
		logger.WithError(err).Error("could not create credit limit change request")
		return nil, err
	}

	logger.WithField("client_id", clientID).
		WithField("current", client.SystemCreditLimit).
		WithField("requested", newLimit).
		Info("credit limit change request created")

	return req, nil
}

// ApproveSystemCreditLimitChange approves a pending request and applies the
// new system credit limit to the client. If the agent limit exceeds the new
// system limit, the agent limit is clamped down.
func (b *clientBusiness) ApproveSystemCreditLimitChange(
	ctx context.Context,
	requestID string,
	reviewedBy, notes string,
) error {
	logger := util.Log(ctx).WithField("method", "ClientBusiness.ApproveSystemCreditLimitChange")

	req, err := b.clcrRepo.GetByID(ctx, requestID)
	if err != nil {
		return ErrCreditLimitChangeNotFound
	}

	if req.Status != 1 { // not pending
		return ErrCreditLimitChangeNotPending
	}

	// Apply the new system limit
	client, err := b.clientRepo.GetByID(ctx, req.ClientID)
	if err != nil {
		return ErrClientNotFound
	}

	client.SystemCreditLimit = req.RequestedLimit

	// Clamp agent limit if it exceeds the new system limit
	if client.AgentCreditLimit > client.SystemCreditLimit {
		client.AgentCreditLimit = client.SystemCreditLimit
	}

	if err = b.eventsMan.Emit(ctx, events.ClientSaveEvent, client); err != nil {
		logger.WithError(err).Error("could not update client system credit limit")
		return err
	}

	// Mark the request as approved
	req.Status = 3 // approved
	req.ReviewedBy = reviewedBy
	req.ReviewNotes = notes

	if err = b.eventsMan.Emit(ctx, events.CreditLimitChangeRequestSaveEvent, req); err != nil {
		logger.WithError(err).Error("could not update credit limit change request")
		return err
	}

	logger.WithField("client_id", req.ClientID).
		WithField("new_limit", req.RequestedLimit).
		Info("system credit limit change approved and applied")

	return nil
}

// RejectSystemCreditLimitChange rejects a pending request.
func (b *clientBusiness) RejectSystemCreditLimitChange(
	ctx context.Context,
	requestID string,
	reviewedBy, notes string,
) error {
	logger := util.Log(ctx).WithField("method", "ClientBusiness.RejectSystemCreditLimitChange")

	req, err := b.clcrRepo.GetByID(ctx, requestID)
	if err != nil {
		return ErrCreditLimitChangeNotFound
	}

	if req.Status != 1 { // not pending
		return ErrCreditLimitChangeNotPending
	}

	req.Status = 5 // rejected
	req.ReviewedBy = reviewedBy
	req.ReviewNotes = notes

	if err = b.eventsMan.Emit(ctx, events.CreditLimitChangeRequestSaveEvent, req); err != nil {
		logger.WithError(err).Error("could not update credit limit change request")
		return err
	}

	logger.WithField("client_id", req.ClientID).
		Info("system credit limit change rejected")

	return nil
}

// GetEffectiveCreditLimit returns the effective credit limit and currency
// for a client. This is the lower of their system and agent limits.
func (b *clientBusiness) GetEffectiveCreditLimit(ctx context.Context, clientID string) (int64, string, error) {
	client, err := b.clientRepo.GetByID(ctx, clientID)
	if err != nil {
		return 0, "", ErrClientNotFound
	}
	return client.EffectiveCreditLimit(), client.CurrencyCode, nil
}
