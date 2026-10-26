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
	"testing"
	"time"

	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
)

type captureSender struct {
	got []*notificationv1.Notification
}

func (c *captureSender) Send(_ context.Context, n *notificationv1.Notification) error {
	c.got = append(c.got, n)
	return nil
}

type mapResolver struct {
	profiles map[string]string
	err      error
}

func (r mapResolver) ProfileIDForClient(_ context.Context, clientID string) (string, error) {
	if r.err != nil {
		return "", r.err
	}
	p, ok := r.profiles[clientID]
	if !ok {
		return "", ErrClientProfileUnknown
	}
	return p, nil
}

func newTestLoanNotifier(resolver ClientProfileResolver) (*LoanNotifier, *captureSender) {
	sender := &captureSender{}
	n := NewLoanNotifier(notify.NewWithSender(sender, messages.Registry()), resolver, "Harvest Finance")
	return n, sender
}

func testLoan() *models.LoanAccount {
	la := &models.LoanAccount{ClientID: "client-1", CurrencyCode: "KES", PrincipalAmount: 2_500_000}
	la.GenID(context.Background())
	first := time.Date(2026, 11, 15, 0, 0, 0, 0, time.UTC)
	la.FirstRepaymentDate = &first
	return la
}

func TestLoanNotifier_AddressesTheClientProfileWithFormattedVariables(t *testing.T) {
	n, sender := newTestLoanNotifier(mapResolver{profiles: map[string]string{"client-1": "profile-1"}})
	la := testLoan()

	n.NotifyLoanDisbursed(context.Background(), la, "M-PESA")
	n.NotifyRepaymentReceived(context.Background(), la, 150_000, 2_350_000, "mobile_money", "RCPT-9")

	require.Len(t, sender.got, 2)

	disbursed := sender.got[0]
	assert.Equal(t, messages.LoanDisbursed, disbursed.GetTemplate())
	assert.Equal(
		t,
		"profile-1",
		disbursed.GetRecipient().GetProfileId(),
		"loans are keyed by client; messages go to the profile",
	)
	assert.Empty(t, disbursed.GetData())
	payload := disbursed.GetPayload().AsMap()
	assert.Equal(t, "25,000.00", payload[messages.VarAmount])
	assert.Equal(t, "KES", payload[messages.VarCurrency])
	assert.Equal(t, "M-PESA", payload[messages.VarChannel])
	assert.Equal(t, "15 Nov 2026", payload[messages.VarDueDate])
	assert.Equal(t, "Harvest Finance", payload[messages.VarLenderName])
	assert.Equal(t, notificationv1.PRIORITY_HIGH, disbursed.GetPriority())

	received := sender.got[1].GetPayload().AsMap()
	assert.Equal(t, "1,500.00", received[messages.VarAmount])
	assert.Equal(t, "23,500.00", received[messages.VarBalance])
	assert.Equal(t, "mobile_money", received[messages.VarChannel])
	assert.Equal(t, "RCPT-9", received[messages.VarReference])
}

func TestLoanNotifier_EveryLifecycleMethodUsesARegisteredTemplate(t *testing.T) {
	n, sender := newTestLoanNotifier(mapResolver{profiles: map[string]string{"client-1": "profile-1"}})
	la := testLoan()
	lr := &models.LoanRequest{ClientID: "client-1", CurrencyCode: "KES", RequestedAmount: 100_000,
		ApprovedAmount: 90_000, RequestedTermDays: 30, ApprovedTermDays: 30, RejectionReason: "Income not verified"}
	lr.GenID(context.Background())
	due := time.Now().AddDate(0, 1, 0)

	ctx := context.Background()
	n.NotifyApplicationSubmitted(ctx, lr)
	n.NotifyApplicationApproved(ctx, lr)
	n.NotifyApplicationRejected(ctx, lr)
	n.NotifyApplicationCancelled(ctx, lr)
	n.NotifyLoanFullyPaid(ctx, la)
	n.NotifyLoanDelinquent(ctx, la, 12, 500_000)
	n.NotifyAgentClientDelinquent(ctx, la, "agent-profile", 12, 500_000)
	n.NotifyPenaltyApplied(ctx, la, 5_000, "")
	n.NotifyPenaltyWaived(ctx, la, 5_000)
	n.NotifyLoanRestructured(ctx, la, 400_000, &due)
	n.NotifyLoanWrittenOff(ctx, la, 400_000)
	n.NotifyCollectionRequested(ctx, la, 20_000, "", "collection:x")

	require.Len(t, sender.got, 12)
	for _, got := range sender.got {
		assert.True(t, messages.Registry().Has(got.GetTemplate()), "%s must be in the catalogue", got.GetTemplate())
		assert.NotEmpty(t, got.GetRecipient().GetProfileId())
		tpl, _ := messages.Registry().Lookup(got.GetTemplate())
		body, err := tpl.Render("sms", got.GetPayload().AsMap())
		require.NoError(t, err)
		assert.NotContains(t, body, "<no value>", "%s rendered with missing variables", got.GetTemplate())
	}
	// The agent message goes to the agent's profile, not the client's.
	assert.Equal(t, "agent-profile", sender.got[6].GetRecipient().GetProfileId())
	// A rejection carries its reason; a penalty without one gets a default.
	assert.Equal(t, "Income not verified", sender.got[2].GetPayload().AsMap()[messages.VarReason])
	assert.Equal(t, "Late repayment.", sender.got[7].GetPayload().AsMap()[messages.VarReason])
}

func TestLoanNotifier_CollectionWithContactGoesToThatContact(t *testing.T) {
	n, sender := newTestLoanNotifier(mapResolver{profiles: map[string]string{"client-1": "profile-1"}})

	n.NotifyCollectionRequested(context.Background(), testLoan(), 20_000, "+254700000001", "collection:y")

	require.Len(t, sender.got, 1)
	assert.Equal(t, "+254700000001", sender.got[0].GetRecipient().GetContactId())
	assert.Empty(t, sender.got[0].GetRecipient().GetProfileId())
}

func TestLoanNotifier_UnresolvableClientAndDisabledNotifierAreSafe(t *testing.T) {
	n, sender := newTestLoanNotifier(mapResolver{err: errors.New("field service down")})
	n.NotifyLoanFullyPaid(context.Background(), testLoan())
	assert.Empty(t, sender.got, "no recipient, nothing sent, no panic")

	var nilNotifier *LoanNotifier
	assert.False(t, nilNotifier.Enabled())
	nilNotifier.NotifyLoanFullyPaid(context.Background(), testLoan())
	nilNotifier.NotifyRepaymentReceived(context.Background(), nil, 0, 0, "", "")

	disabled := NewLoanNotifier(notify.New(nil, messages.Registry()), mapResolver{}, "")
	assert.False(t, disabled.Enabled())
	disabled.NotifyLoanDisbursed(context.Background(), testLoan(), "")
}
