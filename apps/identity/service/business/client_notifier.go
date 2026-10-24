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
	"strings"

	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
)

const (
	notificationKindClient    = "client"
	notificationKindWorkforce = "workforce"
	defaultAgentLabel         = "your field officer"
)

// Option configures optional collaborators of the identity
// businesses: notifiers and look-ups that production wires and tests omit.
type Option func(*options)

type options struct {
	clientNotifier     *ClientNotifier
	workforceNotifier  *WorkforceNotifier
	clientLookup       clientLookup
	profiles           profilev1connect.ProfileServiceClient
	relationshipRepo   repository.ClientRelationshipRepository
	consentRepo        repository.ClientConsentChallengeRepository
	clientRepo         repository.ClientRepository
	workforceRepo      repository.WorkforceMemberRepository
	teamMembershipRepo repository.TeamMembershipRepository
}

// WithProfiles lets client registration find or create the borrower's
// profile from the captured phone number.
func WithProfiles(cli profilev1connect.ProfileServiceClient) Option {
	return func(o *options) { o.profiles = cli }
}

// WithConsentChallenges stores the consent codes field agents ask for.
func WithConsentChallenges(repo repository.ClientConsentChallengeRepository) Option {
	return func(o *options) { o.consentRepo = repo }
}

// WithRelationships lets client registration attach the registering agent
// and scope a field agent's view to their relationships.
func WithRelationships(repo repository.ClientRelationshipRepository) Option {
	return func(o *options) { o.relationshipRepo = repo }
}

// WithRelationshipValidation gives the relationship flow the look-ups it
// needs to check the client, the member and the member's team membership.
func WithRelationshipValidation(
	clientRepo repository.ClientRepository,
	workforceRepo repository.WorkforceMemberRepository,
	teamMembershipRepo repository.TeamMembershipRepository,
) Option {
	return func(o *options) {
		o.clientRepo = clientRepo
		o.workforceRepo = workforceRepo
		o.teamMembershipRepo = teamMembershipRepo
	}
}

// clientLookup is the slice of the client repository the KYC flow needs to
// find the profile a message goes to.
type clientLookup interface {
	GetByID(ctx context.Context, id string) (*models.Client, error)
}

// WithClientNotifier installs the borrower-facing notifier.
func WithClientNotifier(n *ClientNotifier) Option {
	return func(o *options) { o.clientNotifier = n }
}

// WithWorkforceNotifier installs the staff-facing notifier.
func WithWorkforceNotifier(n *WorkforceNotifier) Option {
	return func(o *options) { o.workforceNotifier = n }
}

// WithClientLookup lets the KYC flow resolve the client a data entry belongs
// to, so review outcomes reach the borrower.
func WithClientLookup(lookup clientLookup) Option {
	return func(o *options) { o.clientLookup = lookup }
}

func applyOptions(opts []Option) options {
	var o options
	for _, opt := range opts {
		if opt != nil {
			opt(&o)
		}
	}
	return o
}

// ClientNotifier sends the borrower-facing messages of onboarding and KYC.
// Every method is fire-and-forget and safe on a nil receiver.
type ClientNotifier struct {
	notifier   *notify.Notifier
	lenderName string
}

// NewClientNotifier builds a ClientNotifier. lenderName opens every message.
func NewClientNotifier(notifier *notify.Notifier, lenderName string) *ClientNotifier {
	if strings.TrimSpace(lenderName) == "" {
		lenderName = "Your lender"
	}
	return &ClientNotifier{notifier: notifier, lenderName: lenderName}
}

// Enabled reports whether messages can reach a notification service.
func (n *ClientNotifier) Enabled() bool { return n != nil && n.notifier.Enabled() }

// NotifyClientOnboarded welcomes a newly registered borrower.
func (n *ClientNotifier) NotifyClientOnboarded(ctx context.Context, client *models.Client, agentName string) {
	if !n.Enabled() || client == nil {
		return
	}
	vars := n.clientVars(client)
	vars[messages.VarAgentName] = orDefault(agentName, defaultAgentLabel)
	n.send(ctx, client, messages.ClientOnboarded, vars, notificationv1.PRIORITY_LOW)
}

// NotifyKYCVerified tells the borrower a submitted field was accepted.
func (n *ClientNotifier) NotifyKYCVerified(ctx context.Context, client *models.Client, fieldKey string) {
	if !n.Enabled() || client == nil {
		return
	}
	vars := n.clientVars(client)
	vars[messages.VarFieldLabel] = humanizeCaseValue(fieldKey)
	n.send(ctx, client, messages.ClientKYCVerified, vars, notificationv1.PRIORITY_LOW)
}

// NotifyKYCRejected tells the borrower a field was rejected and why.
func (n *ClientNotifier) NotifyKYCRejected(ctx context.Context, client *models.Client, fieldKey, reason string) {
	if !n.Enabled() || client == nil {
		return
	}
	vars := n.clientVars(client)
	vars[messages.VarFieldLabel] = humanizeCaseValue(fieldKey)
	vars[messages.VarReason] = orDefault(reason, "")
	n.send(ctx, client, messages.ClientKYCRejected, vars, notificationv1.PRIORITY_HIGH)
}

// NotifyKYCInfoRequested asks the borrower for more on a field.
func (n *ClientNotifier) NotifyKYCInfoRequested(ctx context.Context, client *models.Client, fieldKey, reason string) {
	if !n.Enabled() || client == nil {
		return
	}
	vars := n.clientVars(client)
	vars[messages.VarFieldLabel] = humanizeCaseValue(fieldKey)
	vars[messages.VarReason] = orDefault(reason, "")
	n.send(ctx, client, messages.ClientKYCInfoRequested, vars, notificationv1.PRIORITY_HIGH)
}

func (n *ClientNotifier) clientVars(client *models.Client) map[string]any {
	return map[string]any{
		messages.VarLenderName: n.lenderName,
		messages.VarClientName: orDefault(client.Name, "customer"),
	}
}

// send addresses the client's profile; contacts are resolved by the
// profile and notification services. A client without a profile is logged
// and counted as dropped.
func (n *ClientNotifier) send(
	ctx context.Context,
	client *models.Client,
	template string,
	vars map[string]any,
	priority notificationv1.PRIORITY,
) {
	recipient := notify.ToProfile(client.ProfileID)
	n.notifier.SendOrLog(ctx, notify.Message{
		Template:  template,
		Kind:      notificationKindClient,
		Recipient: recipient,
		Vars:      vars,
		Priority:  priority,
	})
}

// WorkforceNotifier sends the staff-facing messages of workforce onboarding.
type WorkforceNotifier struct {
	notifier *notify.Notifier
}

// NewWorkforceNotifier builds a WorkforceNotifier.
func NewWorkforceNotifier(notifier *notify.Notifier) *WorkforceNotifier {
	return &WorkforceNotifier{notifier: notifier}
}

// Enabled reports whether messages can reach a notification service.
func (n *WorkforceNotifier) Enabled() bool { return n != nil && n.notifier.Enabled() }

// NotifyMemberOnboarded invites a newly created staff member to sign in.
func (n *WorkforceNotifier) NotifyMemberOnboarded(
	ctx context.Context,
	member *models.WorkforceMember,
	memberName, organizationName string,
) {
	if !n.Enabled() || member == nil || strings.TrimSpace(member.ProfileID) == "" {
		return
	}
	n.notifier.SendOrLog(ctx, notify.Message{
		Template:  messages.WorkforceMemberOnboarded,
		Kind:      notificationKindWorkforce,
		Recipient: notify.ToProfile(member.ProfileID),
		Vars: map[string]any{
			messages.VarMemberName:   orDefault(memberName, "colleague"),
			messages.VarOrganization: orDefault(organizationName, "your organization"),
		},
		Priority: notificationv1.PRIORITY_HIGH,
	})
}

func orDefault(value, fallback string) string {
	if strings.TrimSpace(value) == "" {
		return fallback
	}
	return value
}
