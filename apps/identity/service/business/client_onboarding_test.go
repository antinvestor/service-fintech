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
	"sync"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3/security"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

// fakeProfileService stands in for the profile service: it knows profiles by
// contact and mints one on Create.
type fakeProfileService struct {
	profilev1connect.ProfileServiceClient
	mu        sync.Mutex
	byContact map[string]string
	created   int
	// sentCodes maps verification id -> code the person received.
	sentCodes map[string]string
	sentTo    map[string]string // verification id -> contact id
}

func (f *fakeProfileService) CreateContactVerification(
	_ context.Context,
	req *profilev1.CreateContactVerificationRequest,
) (*profilev1.CreateContactVerificationResponse, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.sentCodes == nil {
		f.sentCodes, f.sentTo = map[string]string{}, map[string]string{}
	}
	f.sentCodes[req.GetId()] = "123456"
	f.sentTo[req.GetId()] = req.GetContactId()
	return &profilev1.CreateContactVerificationResponse{Id: req.GetId(), Success: true}, nil
}

func (f *fakeProfileService) CheckVerification(
	_ context.Context,
	req *profilev1.CheckVerificationRequest,
) (*profilev1.CheckVerificationResponse, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	code, ok := f.sentCodes[req.GetId()]
	return &profilev1.CheckVerificationResponse{Id: req.GetId(), Success: ok && code == req.GetCode()}, nil
}

func (f *fakeProfileService) GetByContact(
	_ context.Context,
	req *profilev1.GetByContactRequest,
) (*profilev1.GetByContactResponse, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	// The profile service validates contacts; fintech only passes them on.
	if len(req.GetContact()) < 5 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "contact is not a valid phone or email")
	}
	id, ok := f.byContact[req.GetContact()]
	if !ok {
		return nil, connect.NewError(connect.CodeNotFound, "no profile for contact")
	}
	return &profilev1.GetByContactResponse{Data: &profilev1.ProfileObject{Id: id, Contacts: []*profilev1.ContactObject{
		{Id: "contact-of-" + id, Type: profilev1.ContactType_MSISDN, Verified: true},
	}}}, nil
}

func (f *fakeProfileService) Create(
	_ context.Context,
	req *profilev1.CreateRequest,
) (*profilev1.CreateResponse, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.byContact == nil {
		f.byContact = map[string]string{}
	}
	f.created++
	id := fmt.Sprintf("profile-created-%d", f.created)
	f.byContact[req.GetContact()] = id
	return &profilev1.CreateResponse{Data: &profilev1.ProfileObject{Id: id}}, nil
}

// asRole builds claims for profileID holding one platform role.
func (e *approvalWorkflowEnv) asRole(profileID, role string) context.Context {
	claims := security.ClaimsFromContext(e.ctx)
	return (&security.AuthenticationClaims{
		TenantID:         claims.GetTenantID(),
		PartitionID:      claims.GetPartitionID(),
		Roles:            []string{role},
		RegisteredClaims: jwt.RegisteredClaims{Subject: profileID},
	}).ClaimsToContext(e.ctx)
}

// fieldAgent registers a workforce member for profileID and places them in
// a fresh team of org; it returns the member and team.
func (e *approvalWorkflowEnv) fieldAgent(
	org *models.Organization,
	profileID, teamName string,
) (*models.WorkforceMember, *models.InternalTeam) {
	claims := security.ClaimsFromContext(e.ctx)
	team := &models.InternalTeam{
		OrganizationID: org.GetID(),
		Name:           teamName,
		Code:           teamName,
		State:          int32(commonv1.STATE_ACTIVE),
	}
	team.GenID(e.ctx)
	team.TenantID, team.PartitionID = claims.GetTenantID(), claims.GetPartitionID()
	e.t.Helper()
	if err := e.internalTeamRepo.Create(e.ctx, team); err != nil {
		e.t.Fatalf("create team: %v", err)
	}
	member := &models.WorkforceMember{OrganizationID: org.GetID(), ProfileID: profileID,
		EngagementType: "agent", State: int32(commonv1.STATE_ACTIVE)}
	member.GenID(e.ctx)
	member.TenantID, member.PartitionID = claims.GetTenantID(), claims.GetPartitionID()
	if err := e.workforceMemberRepo.Create(e.ctx, member); err != nil {
		e.t.Fatalf("create member: %v", err)
	}
	membership := &models.TeamMembership{TeamID: team.GetID(), MemberID: member.GetID(),
		IsPrimaryTeam: true, State: int32(commonv1.STATE_ACTIVE)}
	membership.GenID(e.ctx)
	membership.TenantID, membership.PartitionID = claims.GetTenantID(), claims.GetPartitionID()
	if err := e.teamMembershipRepo.Create(e.ctx, membership); err != nil {
		e.t.Fatalf("create membership: %v", err)
	}
	return member, team
}

func (e *approvalWorkflowEnv) searchClients(
	ctx context.Context,
	req *fieldv1.ClientSearchRequest,
) []*fieldv1.ClientObject {
	var out []*fieldv1.ClientObject
	err := e.clientBusiness.Search(ctx, req, func(_ context.Context, batch []*fieldv1.ClientObject) error {
		out = append(out, batch...)
		return nil
	})
	if err != nil {
		e.t.Fatalf("search clients: %v", err)
	}
	return out
}

// A field agent registers a borrower: the profile is created from the phone,
// the client row exists as soon as the call returns, the agent is attached,
// a second registration of the same phone converges on the same client, and
// another agent cannot see or edit it.
func (s *approvalWorkflowSuite) TestFieldAgentRegistersClientInOwnScope() {
	env := s.newEnv()
	org := env.createOrganization("Harvest SACCO", "harvest")
	agent, team := env.fieldAgent(org, "agent-amina", "north-team")
	other, _ := env.fieldAgent(org, "agent-bosco", "south-team")
	asAmina := env.asRole("agent-amina", "member")
	asBosco := env.asRole("agent-bosco", "member")

	payload := &fieldv1.ClientObject{
		Name:       "Grace Borrower",
		Properties: propertiesStruct(map[string]any{clientPhoneNumberKey: "+256701000111"}),
	}
	created, err := env.clientBusiness.Save(asAmina, payload)
	s.Require().NoError(err)
	s.Require().Equal(team.GetID(), created.GetOwningTeamId(), "the client lands in the agent's own team")
	s.Require().Equal("profile-created-1", created.GetProfileId(), "a profile was created from the phone")

	stored, err := env.clientRepo.GetByID(env.ctx, created.GetId())
	s.Require().NoError(err, "the row exists synchronously")
	s.Require().Equal("Grace Borrower", stored.Name)

	rel, err := env.crRepo.GetByClientAndMember(env.ctx, created.GetId(), agent.GetID())
	s.Require().NoError(err)
	s.Require().True(rel.IsPrimary, "the registering agent is the client's primary relationship")

	again, err := env.clientBusiness.Save(asAmina, payload)
	s.Require().NoError(err)
	s.Require().Equal(created.GetId(), again.GetId(), "the same phone converges on the same client")
	s.Require().Equal(1, env.profiles.created, "no second profile is minted")

	s.Require().Len(env.searchClients(asAmina, &fieldv1.ClientSearchRequest{}), 1)
	s.Require().Empty(env.searchClients(asBosco, &fieldv1.ClientSearchRequest{}), "another agent sees nothing")
	s.Require().Len(env.searchClients(env.ctx, &fieldv1.ClientSearchRequest{MemberId: agent.GetID()}), 1,
		"staff can filter by the responsible member")

	_, err = env.clientBusiness.Get(asBosco, created.GetId())
	s.Require().ErrorIs(err, ErrClientOutsideCallerScope)
	_, err = env.clientBusiness.Save(asBosco, &fieldv1.ClientObject{
		Id: created.GetId(), OwningTeamId: team.GetID(), Name: "Hijacked",
	})
	s.Require().ErrorIs(err, ErrClientOutsideCallerScope)
	_ = other

	// Another agent re-registering the same borrower is refused, not attached.
	_, err = env.clientBusiness.Save(asBosco, payload)
	s.Require().ErrorIs(err, ErrClientOutsideCallerScope)
	_, err = env.crRepo.GetByClientAndMember(env.ctx, created.GetId(), other.GetID())
	s.Require().Error(err, "no relationship was attached for the refused agent")

	// Moving a client between teams is a staff decision.
	_, err = env.clientBusiness.TransferOwnership(asBosco, &fieldv1.ClientOwnershipTransferRequest{
		ClientId: created.GetId(), NewOwningTeamId: team.GetID(), Reason: "mine now",
	})
	s.Require().ErrorIs(err, ErrClientOutsideCallerScope)

	// Relationships of a client outside the agent's scope are not visible.
	_, err = env.relationshipBusiness.Get(asBosco, rel.GetID())
	s.Require().ErrorIs(err, ErrClientOutsideCallerScope)
	_, err = env.relationshipBusiness.Save(asBosco, &fieldv1.ClientRelationshipObject{
		ClientId: created.GetId(), MemberId: other.GetID(), Name: "takeover",
	})
	s.Require().Error(err)

	// An agent cannot move a client to another team through an edit.
	edited, err := env.clientBusiness.Save(asAmina, &fieldv1.ClientObject{
		Id: created.GetId(), OwningTeamId: "some-other-team", Name: "Grace Borrower",
	})
	s.Require().NoError(err)
	s.Require().Equal(team.GetID(), edited.GetOwningTeamId(), "ownership moves only through TransferOwnership")

	// A phone that belongs to a staff member is never bound to a client.
	env.profiles.byContact["+256701000999"] = "agent-bosco"
	_, err = env.clientBusiness.Save(asAmina, &fieldv1.ClientObject{Name: "Not A Borrower",
		Properties: propertiesStruct(map[string]any{clientPhoneNumberKey: "+256701000999"})})
	s.Require().ErrorIs(err, ErrClientPhoneIsStaff)

	// A borrower with no phone cannot be registered: there is nobody to find.
	// A malformed one is refused by the profile service and reported as such.
	_, err = env.clientBusiness.Save(asAmina, &fieldv1.ClientObject{Name: "No Phone"})
	s.Require().ErrorIs(err, ErrClientPhoneInvalid)
	_, err = env.clientBusiness.Save(asAmina, &fieldv1.ClientObject{Name: "Bad Phone",
		Properties: propertiesStruct(map[string]any{clientPhoneNumberKey: "12"})})
	s.Require().ErrorIs(err, ErrClientPhoneInvalid)
}

// A relationship names a real client and a member of the client's team.
func (s *approvalWorkflowSuite) TestRelationshipSaveValidatesMembership() {
	env := s.newEnv()
	org := env.createOrganization("Harvest SACCO", "harvest-rel")
	agent, team := env.fieldAgent(org, "agent-rel-1", "rel-team")
	outsider, _ := env.fieldAgent(org, "agent-rel-2", "rel-other-team")

	created, err := env.clientBusiness.Save(env.asRole("agent-rel-1", "member"), &fieldv1.ClientObject{
		Name:       "Rel Borrower",
		Properties: propertiesStruct(map[string]any{clientPhoneNumberKey: "+256701000222"}),
	})
	s.Require().NoError(err)
	s.Require().Equal(team.GetID(), created.GetOwningTeamId())

	_, err = env.relationshipBusiness.Save(env.ctx, &fieldv1.ClientRelationshipObject{
		ClientId: created.GetId(), MemberId: outsider.GetID(), Name: "backup",
	})
	s.Require().ErrorIs(err, ErrMemberNotInTeam)

	_, err = env.relationshipBusiness.Save(env.ctx, &fieldv1.ClientRelationshipObject{
		ClientId: "no-such-client", MemberId: agent.GetID(), Name: "backup",
	})
	s.Require().ErrorIs(err, ErrClientNotFound)

	_, err = env.relationshipBusiness.Save(env.ctx, &fieldv1.ClientRelationshipObject{
		ClientId: created.GetId(), MemberId: agent.GetID(), Name: "duplicate of the auto-attached one",
	})
	s.Require().Error(err, "the (client, member) pair already exists")
}

// ClientAccessScope tells a peer service what a profile may act for: its own
// client as a borrower, the clients it serves as a field agent. Only an
// internal caller may name another profile.
func (s *approvalWorkflowSuite) TestClientAccessScopeResolvesBorrowerAndAgent() {
	env := s.newEnv()
	org := env.createOrganization("Scope SACCO", "scope-sacco")
	agent, _ := env.fieldAgent(org, "agent-scope", "scope-team")
	_, _ = env.fieldAgent(org, "agent-other", "other-team")
	asAgent := env.asRole("agent-scope", "member")
	asOther := env.asRole("agent-other", "member")
	asService := env.asRole("service-loans", security.ConstantSystemInternalRole)

	created, err := env.clientBusiness.Save(asAgent, &fieldv1.ClientObject{
		Name:       "Scoped Borrower",
		Properties: propertiesStruct(map[string]any{clientPhoneNumberKey: "+256701000222"}),
	})
	s.Require().NoError(err)

	got, err := env.clientBusiness.AccessScope(asService, "agent-scope")
	s.Require().NoError(err)
	s.Require().Equal(agent.GetID(), got.GetMemberId())
	s.Require().Equal([]string{created.GetId()}, got.GetServedClientIds())
	s.Require().Empty(got.GetClientId())

	got, err = env.clientBusiness.AccessScope(asService, created.GetProfileId())
	s.Require().NoError(err)
	s.Require().Equal(created.GetId(), got.GetClientId(), "the borrower resolves to their own client")
	s.Require().Empty(got.GetMemberId())
	s.Require().Empty(got.GetServedClientIds())

	// A non-internal caller cannot read someone else's scope by naming them.
	got, err = env.clientBusiness.AccessScope(asOther, "agent-scope")
	s.Require().NoError(err)
	s.Require().Empty(got.GetServedClientIds(), "the other agent gets only their own (empty) scope")
	s.Require().NotEqual(agent.GetID(), got.GetMemberId())

	// The exact profile filter finds the borrower's client for staff.
	s.Require().Len(env.searchClients(env.ctx, &fieldv1.ClientSearchRequest{ProfileId: created.GetProfileId()}), 1)
	s.Require().Empty(env.searchClients(env.ctx, &fieldv1.ClientSearchRequest{ProfileId: "nobody"}))
}

// A field agent binding someone who already has a profile needs that
// person's consent code; a wrong code or a verification of another person
// binds nobody.
func (s *approvalWorkflowSuite) TestAgentBindingAnExistingPersonNeedsTheirConsent() {
	env := s.newEnv()
	org := env.createOrganization("Consent SACCO", "consent-sacco")
	agent, _ := env.fieldAgent(org, "agent-consent", "consent-team")
	asAgent := env.asRole("agent-consent", "member")
	env.profiles.byContact = map[string]string{"+256701000555": "profile-existing"}

	register := func(props map[string]any) (*fieldv1.ClientObject, error) {
		props[clientPhoneNumberKey] = "+256701000555"
		return env.clientBusiness.Save(
			asAgent,
			&fieldv1.ClientObject{Name: "Esther", Properties: propertiesStruct(props)},
		)
	}

	pending, err := register(map[string]any{})
	s.Require().NoError(err)
	s.Require().Empty(pending.GetId(), "nothing is bound before consent")
	vid := pending.GetProperties().AsMap()[consentVerificationIDKey].(string)
	s.Require().NotEmpty(vid)
	s.Equal("contact-of-profile-existing", env.profiles.sentTo[vid], "the code goes to the person's own contact")

	_, err = register(map[string]any{consentVerificationIDKey: vid, consentCodeKey: "000000"})
	s.Require().ErrorIs(err, ErrClientConsentFailed)
	_, err = register(
		map[string]any{consentVerificationIDKey: "client-consent-someone-else-x", consentCodeKey: "123456"},
	)
	s.Require().ErrorIs(err, ErrClientConsentFailed)

	bound, err := register(map[string]any{consentVerificationIDKey: vid, consentCodeKey: "123456"})
	s.Require().NoError(err)
	s.Require().NotEmpty(bound.GetId())
	s.Equal("profile-existing", bound.GetProfileId())
	s.NotContains(bound.GetProperties().AsMap(), consentCodeKey, "the code is never stored")
	_ = agent
}
