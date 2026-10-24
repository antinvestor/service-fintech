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
	"strings"
	"time"

	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
)

// notificationKindLoan labels every borrower- and agent-facing loan message.
const notificationKindLoan = "loan"

// ErrClientProfileUnknown is returned when a client cannot be mapped to a
// profile, so there is no one to address a message to.
var ErrClientProfileUnknown = errors.New("loans: client has no profile to notify")

// ClientProfileResolver maps a loans client id onto the profile that owns it.
// Loans are keyed by client id; the notification service delivers to a
// profile's reachable contacts, so every message crosses this bridge once.
type ClientProfileResolver interface {
	ProfileIDForClient(ctx context.Context, clientID string) (string, error)
}

// fieldClientProfileResolver asks the field service (served by the identity
// binary) for the client's profile.
type fieldClientProfileResolver struct {
	fieldCli fieldv1connect.FieldServiceClient
}

// NewFieldClientProfileResolver builds the production resolver.
func NewFieldClientProfileResolver(fieldCli fieldv1connect.FieldServiceClient) ClientProfileResolver {
	return &fieldClientProfileResolver{fieldCli: fieldCli}
}

func (r *fieldClientProfileResolver) ProfileIDForClient(ctx context.Context, clientID string) (string, error) {
	clientID = strings.TrimSpace(clientID)
	if clientID == "" || r == nil || r.fieldCli == nil {
		return "", ErrClientProfileUnknown
	}
	resp, err := r.fieldCli.ClientGet(ctx, &fieldv1.ClientGetRequest{Id: clientID})
	if err != nil {
		return "", fmt.Errorf("client get %s: %w", clientID, err)
	}
	profileID := strings.TrimSpace(resp.GetData().GetProfileId())
	if profileID == "" {
		return "", ErrClientProfileUnknown
	}
	return profileID, nil
}

// AgentProfileResolver maps a loan's agent id (a workforce member on the
// identity service) onto the profile that member signs in with, so the agent
// can be messaged.
type AgentProfileResolver interface {
	ProfileIDForAgent(ctx context.Context, agentID string) (string, error)
}

// ErrAgentProfileUnknown is returned when an agent cannot be mapped to a profile.
var ErrAgentProfileUnknown = errors.New("loans: agent has no profile to notify")

// identityAgentProfileResolver asks the identity service for the workforce member.
type identityAgentProfileResolver struct {
	identityCli identityv1connect.IdentityServiceClient
}

// NewIdentityAgentProfileResolver builds the production agent resolver.
func NewIdentityAgentProfileResolver(identityCli identityv1connect.IdentityServiceClient) AgentProfileResolver {
	return &identityAgentProfileResolver{identityCli: identityCli}
}

func (r *identityAgentProfileResolver) ProfileIDForAgent(ctx context.Context, agentID string) (string, error) {
	agentID = strings.TrimSpace(agentID)
	if agentID == "" || r == nil || r.identityCli == nil {
		return "", ErrAgentProfileUnknown
	}
	resp, err := r.identityCli.WorkforceMemberGet(
		ctx,
		&identityv1.WorkforceMemberGetRequest{Id: agentID},
	)
	if err != nil {
		return "", fmt.Errorf("workforce member get %s: %w", agentID, err)
	}
	profileID := strings.TrimSpace(resp.GetData().GetProfileId())
	if profileID == "" {
		return "", ErrAgentProfileUnknown
	}
	return profileID, nil
}

// LoanNotifier sends the borrower- and agent-facing messages of the loan
// lifecycle. Every method is fire-and-forget: the state change or money
// movement that triggered it has already happened and is never undone
// because a message could not be sent; failures are logged and counted.
//
// A nil *LoanNotifier is safe to call and sends nothing.
type LoanNotifier struct {
	notifier   *notify.Notifier
	resolver   ClientProfileResolver
	lenderName string
}

// NewLoanNotifier builds a LoanNotifier. lenderName is the name borrowers
// know the lender by; it opens every message.
func NewLoanNotifier(notifier *notify.Notifier, resolver ClientProfileResolver, lenderName string) *LoanNotifier {
	if strings.TrimSpace(lenderName) == "" {
		lenderName = "Your lender"
	}
	return &LoanNotifier{notifier: notifier, resolver: resolver, lenderName: lenderName}
}

// Enabled reports whether messages can reach a notification service.
func (n *LoanNotifier) Enabled() bool {
	return n != nil && n.notifier.Enabled()
}

// --- application lifecycle ---

// NotifyApplicationSubmitted tells the borrower their application is in.
func (n *LoanNotifier) NotifyApplicationSubmitted(ctx context.Context, lr *models.LoanRequest) {
	if !n.Enabled() || lr == nil {
		return
	}
	vars := n.requestVars(lr)
	vars[messages.VarAmount] = messages.FormatAmount(lr.CurrencyCode, lr.RequestedAmount)
	n.toClient(ctx, lr.ClientID, messages.LoanApplicationSubmitted, vars, notificationv1.PRIORITY_LOW)
}

// NotifyApplicationApproved tells the borrower the approved terms.
func (n *LoanNotifier) NotifyApplicationApproved(ctx context.Context, lr *models.LoanRequest) {
	if !n.Enabled() || lr == nil {
		return
	}
	vars := n.requestVars(lr)
	vars[messages.VarAmount] = messages.FormatAmount(lr.CurrencyCode, lr.ApprovedAmount)
	vars[messages.VarTermDays] = lr.ApprovedTermDays
	n.toClient(ctx, lr.ClientID, messages.LoanApplicationApproved, vars, notificationv1.PRIORITY_HIGH)
}

// NotifyApplicationRejected tells the borrower, with the reason recorded.
func (n *LoanNotifier) NotifyApplicationRejected(ctx context.Context, lr *models.LoanRequest) {
	if !n.Enabled() || lr == nil {
		return
	}
	vars := n.requestVars(lr)
	vars[messages.VarReason] = orDefault(lr.RejectionReason, "Please contact your field officer for details.")
	n.toClient(ctx, lr.ClientID, messages.LoanApplicationRejected, vars, notificationv1.PRIORITY_HIGH)
}

// NotifyApplicationCancelled tells the borrower the application was withdrawn.
func (n *LoanNotifier) NotifyApplicationCancelled(ctx context.Context, lr *models.LoanRequest) {
	if !n.Enabled() || lr == nil {
		return
	}
	vars := n.requestVars(lr)
	vars[messages.VarReason] = orDefault(lr.RejectionReason, "")
	n.toClient(ctx, lr.ClientID, messages.LoanApplicationCancelled, vars, notificationv1.PRIORITY_LOW)
}

// --- money movements ---

// NotifyLoanDisbursed tells the borrower the principal has left and when the
// first repayment is due.
func (n *LoanNotifier) NotifyLoanDisbursed(ctx context.Context, la *models.LoanAccount, channel string) {
	if !n.Enabled() || la == nil {
		return
	}
	vars := n.loanVars(la)
	vars[messages.VarAmount] = messages.FormatAmount(la.CurrencyCode, la.PrincipalAmount)
	vars[messages.VarChannel] = orDefault(channel, "your registered account")
	vars[messages.VarDueDate] = messages.FormatDate(la.FirstRepaymentDate)
	n.toClient(ctx, la.ClientID, messages.LoanDisbursed, vars, notificationv1.PRIORITY_HIGH)
}

// NotifyRepaymentReceived confirms a repayment and the balance after it.
func (n *LoanNotifier) NotifyRepaymentReceived(
	ctx context.Context,
	la *models.LoanAccount,
	amountMinor, balanceMinor int64,
	channel, reference string,
) {
	if !n.Enabled() || la == nil {
		return
	}
	vars := n.loanVars(la)
	vars[messages.VarAmount] = messages.FormatAmount(la.CurrencyCode, amountMinor)
	vars[messages.VarBalance] = messages.FormatAmount(la.CurrencyCode, balanceMinor)
	vars[messages.VarChannel] = orDefault(channel, "payment")
	vars[messages.VarReference] = orDefault(reference, "-")
	n.toClient(ctx, la.ClientID, messages.LoanRepaymentReceived, vars, notificationv1.PRIORITY_LOW)
}

// NotifyLoanFullyPaid closes the conversation on a settled loan.
func (n *LoanNotifier) NotifyLoanFullyPaid(ctx context.Context, la *models.LoanAccount) {
	if !n.Enabled() || la == nil {
		return
	}
	n.toClient(ctx, la.ClientID, messages.LoanPaidOff, n.loanVars(la), notificationv1.PRIORITY_LOW)
}

// NotifyCollectionRequested asks the borrower to pay an amount now. When a
// contact is supplied it is addressed directly (a phone number is a contact
// detail the notification service resolves); otherwise the client's profile.
func (n *LoanNotifier) NotifyCollectionRequested(
	ctx context.Context,
	la *models.LoanAccount,
	amountMinor int64,
	contact, reference string,
) {
	if !n.Enabled() || la == nil {
		return
	}
	vars := n.loanVars(la)
	vars[messages.VarAmount] = messages.FormatAmount(la.CurrencyCode, amountMinor)
	vars[messages.VarReference] = reference
	if strings.TrimSpace(contact) != "" {
		n.send(ctx, notify.ToContact(contact), messages.LoanCollectionRequested, vars, notificationv1.PRIORITY_HIGH)
		return
	}
	n.toClient(ctx, la.ClientID, messages.LoanCollectionRequested, vars, notificationv1.PRIORITY_HIGH)
}

// NotifyPaymentDue reminds the borrower of an installment falling due.
func (n *LoanNotifier) NotifyPaymentDue(
	ctx context.Context,
	la *models.LoanAccount,
	amountMinor int64,
	due *time.Time,
) {
	if !n.Enabled() || la == nil {
		return
	}
	vars := n.loanVars(la)
	vars[messages.VarAmount] = messages.FormatAmount(la.CurrencyCode, amountMinor)
	vars[messages.VarDueDate] = messages.FormatDate(due)
	n.toClient(ctx, la.ClientID, messages.LoanPaymentDue, vars, notificationv1.PRIORITY_LOW)
}

// NotifyPaymentOverdue tells the borrower an installment was missed.
func (n *LoanNotifier) NotifyPaymentOverdue(
	ctx context.Context,
	la *models.LoanAccount,
	amountMinor int64,
	due *time.Time,
	daysOverdue int,
) {
	if !n.Enabled() || la == nil {
		return
	}
	vars := n.loanVars(la)
	vars[messages.VarAmount] = messages.FormatAmount(la.CurrencyCode, amountMinor)
	vars[messages.VarDueDate] = messages.FormatDate(due)
	vars[messages.VarDaysOverdue] = daysOverdue
	n.toClient(ctx, la.ClientID, messages.LoanPaymentOverdue, vars, notificationv1.PRIORITY_HIGH)
}

// --- arrears and servicing ---

// NotifyLoanDelinquent tells the borrower the loan is in arrears.
func (n *LoanNotifier) NotifyLoanDelinquent(
	ctx context.Context,
	la *models.LoanAccount,
	daysOverdue int,
	balanceMinor int64,
) {
	if !n.Enabled() || la == nil {
		return
	}
	vars := n.loanVars(la)
	vars[messages.VarDaysOverdue] = daysOverdue
	vars[messages.VarBalance] = messages.FormatAmount(la.CurrencyCode, balanceMinor)
	n.toClient(ctx, la.ClientID, messages.LoanDelinquent, vars, notificationv1.PRIORITY_HIGH)
}

// NotifyAgentClientDelinquent tells the field agent one of their clients is
// in arrears so they can follow up in person.
func (n *LoanNotifier) NotifyAgentClientDelinquent(
	ctx context.Context,
	la *models.LoanAccount,
	agentProfileID string,
	daysOverdue int,
	balanceMinor int64,
) {
	if !n.Enabled() || la == nil || strings.TrimSpace(agentProfileID) == "" {
		return
	}
	vars := n.loanVars(la)
	vars[messages.VarAgentName] = "field officer"
	vars[messages.VarDaysOverdue] = daysOverdue
	vars[messages.VarBalance] = messages.FormatAmount(la.CurrencyCode, balanceMinor)
	n.send(ctx, notify.ToProfile(agentProfileID), messages.AgentClientDelinquent, vars, notificationv1.PRIORITY_HIGH)
}

// NotifyAgentCollectionRecorded confirms to the field agent what they just
// recorded, and reminds them cash must be remitted.
func (n *LoanNotifier) NotifyAgentCollectionRecorded(
	ctx context.Context,
	la *models.LoanAccount,
	agentProfileID string,
	amountMinor int64,
	channel, reference string,
) {
	if !n.Enabled() || la == nil || strings.TrimSpace(agentProfileID) == "" {
		return
	}
	vars := n.loanVars(la)
	vars[messages.VarAgentName] = "field officer"
	vars[messages.VarAmount] = messages.FormatAmount(la.CurrencyCode, amountMinor)
	vars[messages.VarChannel] = orDefault(channel, "payment")
	vars[messages.VarReference] = orDefault(reference, "-")
	n.send(ctx, notify.ToProfile(agentProfileID), messages.AgentCollectionRecorded, vars, notificationv1.PRIORITY_LOW)
}

// NotifyPenaltyApplied tells the borrower a penalty was charged.
func (n *LoanNotifier) NotifyPenaltyApplied(
	ctx context.Context,
	la *models.LoanAccount,
	amountMinor int64,
	reason string,
) {
	if !n.Enabled() || la == nil {
		return
	}
	vars := n.loanVars(la)
	vars[messages.VarAmount] = messages.FormatAmount(la.CurrencyCode, amountMinor)
	vars[messages.VarReason] = orDefault(reason, "Late repayment.")
	n.toClient(ctx, la.ClientID, messages.LoanPenaltyApplied, vars, notificationv1.PRIORITY_HIGH)
}

// NotifyPenaltyWaived tells the borrower a penalty was removed.
func (n *LoanNotifier) NotifyPenaltyWaived(ctx context.Context, la *models.LoanAccount, amountMinor int64) {
	if !n.Enabled() || la == nil {
		return
	}
	vars := n.loanVars(la)
	vars[messages.VarAmount] = messages.FormatAmount(la.CurrencyCode, amountMinor)
	n.toClient(ctx, la.ClientID, messages.LoanPenaltyWaived, vars, notificationv1.PRIORITY_LOW)
}

// NotifyLoanRestructured tells the borrower the new balance and next due date.
func (n *LoanNotifier) NotifyLoanRestructured(
	ctx context.Context,
	la *models.LoanAccount,
	balanceMinor int64,
	nextDue *time.Time,
) {
	if !n.Enabled() || la == nil {
		return
	}
	vars := n.loanVars(la)
	vars[messages.VarBalance] = messages.FormatAmount(la.CurrencyCode, balanceMinor)
	vars[messages.VarDueDate] = messages.FormatDate(nextDue)
	n.toClient(ctx, la.ClientID, messages.LoanRestructured, vars, notificationv1.PRIORITY_HIGH)
}

// NotifyLoanWrittenOff tells the borrower the loan has been closed.
func (n *LoanNotifier) NotifyLoanWrittenOff(ctx context.Context, la *models.LoanAccount, balanceMinor int64) {
	if !n.Enabled() || la == nil {
		return
	}
	vars := n.loanVars(la)
	vars[messages.VarBalance] = messages.FormatAmount(la.CurrencyCode, balanceMinor)
	n.toClient(ctx, la.ClientID, messages.LoanWrittenOff, vars, notificationv1.PRIORITY_HIGH)
}

// --- plumbing ---

func (n *LoanNotifier) requestVars(lr *models.LoanRequest) map[string]any {
	return map[string]any{
		messages.VarLenderName: n.lenderName,
		messages.VarClientName: "customer",
		messages.VarLoanRef:    shortRef(lr.GetID()),
		messages.VarCurrency:   lr.CurrencyCode,
		messages.VarTermDays:   lr.RequestedTermDays,
	}
}

func (n *LoanNotifier) loanVars(la *models.LoanAccount) map[string]any {
	return map[string]any{
		messages.VarLenderName: n.lenderName,
		messages.VarClientName: "customer",
		messages.VarLoanRef:    shortRef(la.GetID()),
		messages.VarCurrency:   la.CurrencyCode,
	}
}

// toClient resolves the client's profile and sends. A client with no profile
// is logged and counted as dropped; it is a data problem to fix in identity,
// not a reason to fail the business operation.
func (n *LoanNotifier) toClient(
	ctx context.Context,
	clientID, template string,
	vars map[string]any,
	priority notificationv1.PRIORITY,
) {
	if !n.Enabled() {
		return
	}
	if n.resolver == nil {
		util.Log(ctx).WithField("template", template).Warn("loan notification skipped: no client profile resolver")
		return
	}
	profileID, err := n.resolver.ProfileIDForClient(ctx, clientID)
	if err != nil {
		util.Log(ctx).WithError(err).WithFields(map[string]any{
			"template":  template,
			"client_id": clientID,
		}).Error("loan notification not sent: client profile could not be resolved")
		return
	}
	n.send(ctx, notify.ToProfile(profileID), template, vars, priority)
}

func (n *LoanNotifier) send(
	ctx context.Context,
	recipient notifyRecipient,
	template string,
	vars map[string]any,
	priority notificationv1.PRIORITY,
) {
	if !n.Enabled() {
		return
	}
	n.notifier.SendOrLog(ctx, notify.Message{
		Template:  template,
		Kind:      notificationKindLoan,
		Recipient: recipient,
		Vars:      vars,
		Priority:  priority,
	})
}

// notifyRecipient is the ContactLink type, named so the signatures above
// read as what they are.
type notifyRecipient = notify.Recipient

// shortRefLen is how many trailing characters of an id a borrower sees.
const shortRefLen = 8

// shortRef renders an id the way a borrower sees it on an SMS: the last
// eight characters, upper-cased.
func shortRef(id string) string {
	id = strings.TrimSpace(id)
	if len(id) > shortRefLen {
		id = id[len(id)-shortRefLen:]
	}
	return strings.ToUpper(id)
}

func orDefault(value, fallback string) string {
	if strings.TrimSpace(value) == "" {
		return fallback
	}
	return value
}
