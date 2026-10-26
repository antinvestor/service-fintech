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

	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect/v2"
	"google.golang.org/protobuf/types/known/structpb"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
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
	AccessScope(ctx context.Context, profileID string) (*fieldv1.ClientAccessScopeResponse, error)
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
	notifier           *ClientNotifier
	profiles           profilev1connect.ProfileServiceClient
	crRepo             repository.ClientRelationshipRepository
	consentRepo        repository.ClientConsentChallengeRepository
	kycPolicy          *KYCPolicy
}

func NewClientBusiness(_ context.Context, eventsMan fevents.Manager,
	clientRepo repository.ClientRepository,
	clientHistoryRepo repository.ClientResponsibilityHistoryRepository,
	clcrRepo repository.CreditLimitChangeRequestRepository,
	approvalCases ApprovalCaseBusiness,
	workforceRepo repository.WorkforceMemberRepository,
	internalTeamRepo repository.InternalTeamRepository,
	teamMembershipRepo repository.TeamMembershipRepository,
	opts ...Option,
) ClientBusiness {
	o := applyOptions(opts)
	return &clientBusiness{
		notifier:           o.clientNotifier,
		profiles:           o.profiles,
		crRepo:             o.relationshipRepo,
		consentRepo:        o.consentRepo,
		kycPolicy:          o.kycPolicy,
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
	// A contact (phone) in the payload is only ever handed to the profile
	// service to find or create the borrower's profile. It is never stored
	// on the client row: contacts belong to the profile.
	props := entityProperties(client.Properties)
	contact := takeClientContact(props)
	client.Properties = props

	// A field agent (member role) works inside their own teams: the client
	// they register is owned by one of those teams (their primary team when
	// none is named), and they become its primary relationship so they can
	// see it afterwards. Staff may place a client in any team.
	scope, err := b.scopeForSave(ctx, client, isNew)
	if err != nil {
		return nil, err
	}
	if isNew || scope == nil {
		if client.OwningTeamID == "" {
			return nil, ErrOwningTeamRequired
		}
		if errOwn := b.validateOwnership(ctx, client.OwningTeamID, ""); errOwn != nil {
			logger.WithError(errOwn).Warn("invalid client ownership")
			return nil, errOwn
		}
	}

	if isNew {
		// Every client starts CREATED; it becomes ACTIVE only through
		// activation, once its KYC is verified (see saveExisting).
		client.State = int32(commonv1.STATE_CREATED.Number())
	}

	if !isNew {
		if contact != "" || caseAction(client.Properties) != "" {
			// Contact changes are made, verified and approved on the
			// borrower's profile, never through the client row.
			return nil, ErrClientContactsOnProfile
		}
		return b.saveExisting(ctx, logger, client, scope)
	}

	return b.registerNew(ctx, logger, client, scope, contact)
}

// registerNew creates a client for a borrower: profile first, then the row,
// then the registering agent's relationship and the welcome message. No
// consent is asked for here: the client starts CREATED, its profile hidden
// from the agent, and the person consents when it is activated.
func (b *clientBusiness) registerNew(
	ctx context.Context,
	logger *util.LogEntry,
	client *models.Client,
	scope *callerScope,
	contact string,
) (*fieldv1.ClientObject, error) {
	// Profile first: a borrower is a person on the profile service, found by
	// the phone they gave or created from it. Only then does a client row
	// hang off that profile. A field agent cannot name a profile directly:
	// that would let them attach themselves to an arbitrary person.
	if scope != nil {
		client.ProfileID = ""
	}
	takeConsentProperties(client.Properties)
	if client.ProfileID == "" {
		profileID, consentContact, profileErr := b.ensureProfile(ctx, client, contact)
		if profileErr != nil {
			return nil, profileErr
		}
		client.ProfileID = profileID
		client.ConsentContactID = consentContact
	}

	stored, created, createErr := b.clientRepo.CreateIfAbsent(ctx, client)
	if createErr != nil {
		logger.WithError(createErr).Error("could not create client")
		return nil, createErr
	}
	if !created {
		// Already a client of this lender. An agent may only re-register a
		// borrower already in their scope; anyone else's client is refused
		// without revealing it, and staff reassign it if that is wanted.
		if !b.clientInScope(ctx, stored, scope) {
			return nil, ErrClientOutsideCallerScope
		}
		logger.WithField("client_id", stored.GetID()).Info("client already registered for this profile")
		return presentClient(stored, scope == nil), nil
	}

	b.attachCaller(ctx, logger, stored, scope)
	b.notifier.NotifyClientOnboarded(ctx, stored, "")
	return presentClient(stored, scope == nil), nil
}

// presentClient is the client as the caller may see it. Until a client is
// activated, which is when the person consents, a field agent does not see
// which profile it is bound to: typing a phone number must not reveal an
// existing person's profile.
func presentClient(client *models.Client, staff bool) *fieldv1.ClientObject {
	obj := client.ToAPI()
	if !staff && client.State != int32(commonv1.STATE_ACTIVE) {
		obj.ProfileId = ""
	}
	return obj
}

// relatedClientIDs lists the clients memberID holds a relationship with; a
// never-matching sentinel keeps "IN ?" valid when there are none.
func (b *clientBusiness) relatedClientIDs(ctx context.Context, memberID string) ([]string, error) {
	if b.crRepo == nil {
		return []string{""}, nil
	}
	ids, err := b.crRepo.ClientIDsForMember(ctx, memberID)
	if err != nil {
		return nil, err
	}
	if len(ids) == 0 {
		ids = []string{""}
	}
	return ids, nil
}

// scopedClientIDs lists every client a non-staff caller may see: those owned
// by their teams plus those they hold a relationship with. The sentinel keeps
// "IN ?" valid when there are none.
func (b *clientBusiness) scopedClientIDs(ctx context.Context) ([]string, error) {
	scope, err := resolveCallerScope(ctx, b.workforceRepo, b.teamMembershipRepo)
	if err != nil {
		return nil, err
	}
	return b.servedClientIDs(ctx, scope)
}

// servedClientIDs lists the clients scope's teams own plus those its member
// holds a relationship with. The sentinel keeps "IN ?" valid when there are
// none.
func (b *clientBusiness) servedClientIDs(ctx context.Context, scope *callerScope) ([]string, error) {
	owned, err := b.clientRepo.IDsOwnedByTeams(ctx, scope.teamIDs)
	if err != nil {
		return nil, err
	}
	related, err := b.relatedClientIDs(ctx, scope.member.GetID())
	if err != nil {
		return nil, err
	}
	seen := map[string]struct{}{}
	out := make([]string, 0, len(owned)+len(related))
	for _, id := range append(owned, related...) {
		if id == "" {
			continue
		}
		if _, dup := seen[id]; dup {
			continue
		}
		seen[id] = struct{}{}
		out = append(out, id)
	}
	if len(out) == 0 {
		out = []string{""}
	}
	return out, nil
}

func intersectIDs(a, b []string) []string {
	in := make(map[string]struct{}, len(b))
	for _, id := range b {
		in[id] = struct{}{}
	}
	out := []string{}
	for _, id := range a {
		if _, ok := in[id]; ok {
			out = append(out, id)
		}
	}
	if len(out) == 0 {
		out = []string{""}
	}
	return out
}

// scopeForSave resolves the field agent's scope for a registration and
// places the client in one of the agent's teams. Staff get no scope.
func (b *clientBusiness) scopeForSave(ctx context.Context, client *models.Client, isNew bool) (*callerScope, error) {
	if callerIsStaff(ctx) {
		return nil, nil //nolint:nilnil // staff are unscoped
	}
	scope, err := resolveCallerScope(ctx, b.workforceRepo, b.teamMembershipRepo)
	if err != nil {
		return nil, err
	}
	if !isNew {
		// An edit keeps the stored team (saveExisting enforces it); the
		// payload's team is not a decision the agent gets to make.
		return scope, nil
	}
	if client.OwningTeamID == "" && len(scope.teamIDs) > 0 {
		client.OwningTeamID = scope.teamIDs[0]
	}
	if !scope.inTeam(client.OwningTeamID) {
		return nil, ErrClientOutsideCallerScope
	}
	return scope, nil
}

// saveExisting applies an edit to a stored client synchronously, carrying
// the stored tenancy, limits and currency.
func (b *clientBusiness) saveExisting(
	ctx context.Context,
	logger *util.LogEntry,
	client *models.Client,
	scope *callerScope,
) (*fieldv1.ClientObject, error) {
	existing, getErr := b.clientRepo.GetByID(ctx, client.GetID())
	if getErr != nil {
		return nil, ErrClientNotFound
	}
	if scope != nil && !b.clientInScope(ctx, existing, scope) {
		return nil, ErrClientOutsideCallerScope
	}

	applyStoredTenancy(client, existing)
	consent := takeConsentProperties(client.Properties)
	activating := existing.State == int32(commonv1.STATE_CREATED) &&
		client.State == int32(commonv1.STATE_ACTIVE)
	// Acceptance of the terms is recorded by activation alone.
	delete(client.Properties, termsAcceptedAtKey)
	delete(client.Properties, termsKey)
	if activating {
		if pending, err := b.activate(ctx, existing, scope, consent); err != nil || pending != nil {
			return pending, err
		}
		if scope != nil {
			b.recordTermsAccepted(client)
		}
	} else if scope != nil {
		// A field agent changes a client's state only by activating it.
		client.State = existing.State
	}
	client.ConsentContactID = existing.ConsentContactID
	if client.AgentID == "" {
		client.AgentID = existing.AgentID
	}
	// Who the client is never changes on an edit; the profile is bound once,
	// at registration. Ownership moves only through TransferOwnership, which
	// is a staff act, so an agent's edit keeps the stored team.
	client.ProfileID = existing.ProfileID
	if scope != nil {
		client.OwningTeamID = existing.OwningTeamID
	}
	client.CurrencyCode = existing.CurrencyCode
	client.SystemCreditLimit = existing.SystemCreditLimit
	client.AgentCreditLimit = existing.AgentCreditLimit
	mergedProps := entityProperties(existing.Properties)
	for k, v := range client.Properties {
		mergedProps[k] = v
	}
	stripCaseCommand(mergedProps)
	// Rows written before contacts moved to the profile shed them here.
	takeClientContact(mergedProps)
	client.Properties = mergedProps
	client.Version = existing.Version

	rows, err := b.clientRepo.Update(ctx, client)
	if err != nil {
		logger.WithError(err).Error("could not update client")
		return nil, err
	}
	if rows == 0 {
		return nil, apperrors.NewError(apperrors.Conflict, "the client changed while being edited; reload and retry")
	}
	return presentClient(client, scope == nil), nil
}

// activate gates moving a CREATED client to ACTIVE: every KYC field the
// client's organization requires must be verified, and a field agent must
// also have the person's consent code (confirmActivation). It returns a
// pending response while a code is awaited.
func (b *clientBusiness) activate(
	ctx context.Context,
	client *models.Client,
	scope *callerScope,
	consent consentProperties,
) (*fieldv1.ClientObject, error) {
	if b.kycPolicy == nil {
		return nil, ErrClientKYCNotConfigured
	}
	reqs, err := b.kycPolicy.ForClient(ctx, client)
	if err != nil {
		return nil, err
	}
	if !reqs.Complete {
		return nil, ErrClientKYCIncomplete
	}
	if scope == nil {
		return nil, nil //nolint:nilnil // staff activate without a code
	}
	return b.confirmActivation(ctx, client, scope, consent)
}

// ensureProfile asks the profile service for the borrower's profile by the
// contact they gave, or has it create one. The contact is passed through,
// never inspected: the profile service validates and owns it. Without a
// contact there is nothing to find a person by.
// It also returns the contact the activation code will go to: an existing
// person's verified mobile contact, or the one a new profile was created
// with.
func (b *clientBusiness) ensureProfile(
	ctx context.Context,
	client *models.Client,
	phone string,
) (string, string, error) {
	if phone == "" {
		return "", "", ErrClientPhoneInvalid
	}
	if b.profiles == nil {
		return "", "", ErrClientProfileUnavailable
	}
	found, err := b.profiles.GetByContact(ctx, &profilev1.GetByContactRequest{Contact: phone})
	if err == nil && found.GetData().GetId() != "" {
		profileID := found.GetData().GetId()
		// A borrower is never a member of staff: a phone that resolves to a
		// workforce member's profile (the registering agent's own, say) is
		// refused rather than bound to a client.
		if profileID == actorFromClaims(ctx) {
			return "", "", ErrClientPhoneIsStaff
		}
		if b.workforceRepo != nil {
			if member, memberErr := b.workforceRepo.GetByProfileID(ctx, profileID); memberErr == nil && member != nil {
				return "", "", ErrClientPhoneIsStaff
			}
		}
		return profileID, consentContactID(found.GetData()), nil
	}
	if connect.CodeOf(err) == connect.CodeInvalidArgument {
		return "", "", ErrClientPhoneInvalid
	}
	if err != nil && connect.CodeOf(err) != connect.CodeNotFound {
		util.Log(ctx).WithError(err).Warn("could not look up the borrower's profile by contact")
		return "", "", ErrClientProfileUnavailable
	}
	props, propErr := structpb.NewStruct(map[string]any{"name": client.Name})
	if propErr != nil {
		return "", "", propErr
	}
	created, err := b.profiles.Create(ctx, &profilev1.CreateRequest{
		Type:       profilev1.ProfileType_PERSON,
		Contact:    phone,
		Properties: props,
	})
	if connect.CodeOf(err) == connect.CodeInvalidArgument {
		return "", "", ErrClientPhoneInvalid
	}
	if err != nil {
		util.Log(ctx).WithError(err).Error("could not create the borrower's profile")
		return "", "", ErrClientProfileUnavailable
	}
	return created.GetData().GetId(), registeredContactID(created.GetData()), nil
}

// attachCaller makes the registering field agent the client's primary
// relationship, so their own view of "my clients" includes the borrower they
// just brought in. Staff registrations attach nobody.
func (b *clientBusiness) attachCaller(
	ctx context.Context,
	logger *util.LogEntry,
	client *models.Client,
	scope *callerScope,
) {
	if scope == nil || scope.member == nil || b.crRepo == nil {
		return
	}
	if existing, err := b.crRepo.GetByClientAndMember(ctx, client.GetID(), scope.member.GetID()); err == nil &&
		existing != nil {
		return
	}
	primary, primaryErr := b.crRepo.GetPrimaryForClient(ctx, client.GetID())
	rel := &models.ClientRelationship{
		ClientID:  client.GetID(),
		MemberID:  scope.member.GetID(),
		Name:      "field_agent",
		IsPrimary: primaryErr != nil || primary == nil,
		State:     int32(commonv1.STATE_ACTIVE),
	}
	rel.GenID(ctx)
	rel.CopyPartitionInfo(&client.BaseModel)
	if err := b.crRepo.Create(ctx, rel); err != nil {
		logger.WithError(err).WithField("client_id", client.GetID()).
			Warn("could not attach the registering agent to the client")
	}
}

// clientInScope reports whether a non-staff caller may act on the client.
func (b *clientBusiness) clientInScope(ctx context.Context, client *models.Client, scope *callerScope) bool {
	return clientInCallerScope(ctx, client, scope, b.crRepo)
}

func (b *clientBusiness) Get(ctx context.Context, id string) (*fieldv1.ClientObject, error) {
	client, err := b.clientRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if !callerIsStaff(ctx) {
		scope, scopeErr := resolveCallerScope(ctx, b.workforceRepo, b.teamMembershipRepo)
		if scopeErr != nil {
			return nil, scopeErr
		}
		if !b.clientInScope(ctx, client, scope) {
			return nil, ErrClientOutsideCallerScope
		}
	}
	return presentClient(client, callerIsStaff(ctx)), nil
}

func (b *clientBusiness) Search(
	ctx context.Context,
	req *fieldv1.ClientSearchRequest,
	consumer func(ctx context.Context, batch []*fieldv1.ClientObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "ClientBusiness.Search")

	var searchOpts []data.SearchOption

	cursorOpts, cursorErr := cursorSearchOptions(req.GetCursor())
	if cursorErr != nil {
		return cursorErr
	}
	searchOpts = append(searchOpts, cursorOpts...)

	andQueryVal := map[string]any{}
	if req.GetAgentId() != "" {
		andQueryVal["agent_id = ?"] = req.GetAgentId()
	}
	if req.GetOwningTeamId() != "" {
		andQueryVal["owning_team_id = ?"] = req.GetOwningTeamId()
	}
	if req.GetProfileId() != "" {
		andQueryVal["profile_id = ?"] = req.GetProfileId()
	}
	if req.GetMemberId() != "" {
		// Relationships live in their own table, so a member filter is
		// resolved to client ids first.
		ids, idsErr := b.relatedClientIDs(ctx, req.GetMemberId())
		if idsErr != nil {
			return idsErr
		}
		andQueryVal["id IN ?"] = ids
	}

	// A field agent sees the clients their teams own or they are related to.
	// The scope is resolved to client ids and AND-ed with every other filter,
	// so a text query can never widen it.
	if !callerIsStaff(ctx) {
		scoped, scopeErr := b.scopedClientIDs(ctx)
		if scopeErr != nil {
			return scopeErr
		}
		if existing, ok := andQueryVal["id IN ?"].([]string); ok {
			scoped = intersectIDs(scoped, existing)
		}
		andQueryVal["id IN ?"] = scoped
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
		staff := callerIsStaff(ctx)
		var apiResults []*fieldv1.ClientObject
		for _, client := range res {
			apiResults = append(apiResults, presentClient(client, staff))
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
	// Moving a borrower between teams is a staff decision, not a field
	// agent's: an agent could otherwise pull any client into their own team.
	if !callerIsStaff(ctx) {
		return nil, ErrClientOutsideCallerScope
	}
	client, err := b.clientRepo.GetByID(ctx, req.GetClientId())
	if err != nil {
		return nil, ErrClientNotFound
	}
	if errOwn := b.validateOwnership(ctx, req.GetNewOwningTeamId(), ""); errOwn != nil {
		return nil, errOwn
	}
	// Ownership moves within one lender: the new team must belong to the
	// organization the current team does. A team that cannot be loaded
	// refuses the transfer rather than letting it through.
	if client.OwningTeamID != "" {
		current, curErr := b.internalTeamRepo.GetByID(ctx, client.OwningTeamID)
		if curErr != nil {
			return nil, ErrInternalTeamNotFound
		}
		next, nextErr := b.internalTeamRepo.GetByID(ctx, req.GetNewOwningTeamId())
		if nextErr != nil {
			return nil, ErrInternalTeamNotFound
		}
		if current.OrganizationID != next.OrganizationID {
			return nil, ErrTeamOutsideOrganization
		}
	}

	previousTeamID := client.OwningTeamID
	client.OwningTeamID = req.GetNewOwningTeamId()

	rows, updErr := b.clientRepo.Update(ctx, client, "owning_team_id")
	if updErr != nil {
		return nil, updErr
	}
	if rows == 0 {
		return nil, apperrors.NewError(apperrors.Conflict, "the client changed while ownership was being transferred")
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

// recordTermsAccepted notes on the client that the person accepted the
// lending terms by giving their activation code: once, for every loan after.
func (b *clientBusiness) recordTermsAccepted(client *models.Client) {
	if client.Properties == nil {
		client.Properties = data.JSONMap{}
	}
	client.Properties[termsAcceptedAtKey] = time.Now().UTC().Format(time.RFC3339)
	client.Properties[termsKey] = b.notifier.TermsReference()
}
