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
	"testing"

	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"github.com/pitabwire/frame/v2/data"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
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

func newCaptureNotifier() (*notify.Notifier, *captureSender) {
	s := &captureSender{}
	return notify.NewWithSender(s, messages.Registry()), s
}

func TestClientNotifier_AddressesProfileThenPhone(t *testing.T) {
	n, sender := newCaptureNotifier()
	cn := NewClientNotifier(n, "Harvest Finance")

	withProfile := &models.Client{ProfileID: "profile-9", Name: "Amina"}
	cn.NotifyClientOnboarded(context.Background(), withProfile, "")

	phoneOnly := &models.Client{Name: "Bosco", Properties: data.JSONMap{clientPhoneNumberKey: "+256701000000"}}
	cn.NotifyKYCRejected(context.Background(), phoneOnly, "national_id", "Image unreadable")

	require.Len(t, sender.got, 2)

	onboarded := sender.got[0]
	assert.Equal(t, messages.ClientOnboarded, onboarded.GetTemplate())
	assert.Equal(t, "profile-9", onboarded.GetRecipient().GetProfileId())
	assert.Empty(t, onboarded.GetData())
	payload := onboarded.GetPayload().AsMap()
	assert.Equal(t, "Harvest Finance", payload[messages.VarLenderName])
	assert.Equal(t, "Amina", payload[messages.VarClientName])
	assert.Equal(t, defaultAgentLabel, payload[messages.VarAgentName])

	rejected := sender.got[1]
	assert.Equal(t, messages.ClientKYCRejected, rejected.GetTemplate())
	assert.Equal(
		t,
		"+256701000000",
		rejected.GetRecipient().GetContactId(),
		"no profile: the captured phone is the address",
	)
	assert.Equal(t, "National Id", rejected.GetPayload().AsMap()[messages.VarFieldLabel])
	assert.Equal(t, "Image unreadable", rejected.GetPayload().AsMap()[messages.VarReason])
	assert.Equal(t, notificationv1.PRIORITY_HIGH, rejected.GetPriority())
}

func TestClientNotifier_EveryMessageRendersFromTheCatalogue(t *testing.T) {
	n, sender := newCaptureNotifier()
	cn := NewClientNotifier(n, "")
	client := &models.Client{ProfileID: "p", Name: "Chao"}
	ctx := context.Background()

	cn.NotifyClientOnboarded(ctx, client, "Dan")
	cn.NotifyKYCVerified(ctx, client, "proof_of_address")
	cn.NotifyKYCRejected(ctx, client, "selfie", "")
	cn.NotifyKYCInfoRequested(ctx, client, "income", "Send three months of statements")

	require.Len(t, sender.got, 4)
	for _, got := range sender.got {
		tpl, ok := messages.Registry().Lookup(got.GetTemplate())
		require.True(t, ok, got.GetTemplate())
		body, err := tpl.Render("sms", got.GetPayload().AsMap())
		require.NoError(t, err)
		assert.NotContains(t, body, "<no value>")
		assert.Contains(t, body, "Your lender")
	}
}

func TestWorkforceNotifier_InvitesByProfileOnly(t *testing.T) {
	n, sender := newCaptureNotifier()
	wn := NewWorkforceNotifier(n)

	wn.NotifyMemberOnboarded(context.Background(), &models.WorkforceMember{}, "No Profile", "Org")
	assert.Empty(t, sender.got, "a member with no profile cannot be addressed")

	wn.NotifyMemberOnboarded(
		context.Background(),
		&models.WorkforceMember{ProfileID: "staff-1"},
		"Eve",
		"Harvest SACCO",
	)
	require.Len(t, sender.got, 1)
	assert.Equal(t, messages.WorkforceMemberOnboarded, sender.got[0].GetTemplate())
	assert.Equal(t, "staff-1", sender.got[0].GetRecipient().GetProfileId())
	assert.Equal(t, "Harvest SACCO", sender.got[0].GetPayload().AsMap()[messages.VarOrganization])
}

func TestNotifiersAreSafeWhenDisabled(t *testing.T) {
	var cn *ClientNotifier
	var wn *WorkforceNotifier
	assert.False(t, cn.Enabled())
	assert.False(t, wn.Enabled())
	cn.NotifyClientOnboarded(context.Background(), &models.Client{ProfileID: "p"}, "")
	wn.NotifyMemberOnboarded(context.Background(), &models.WorkforceMember{ProfileID: "p"}, "", "")

	disabled := NewClientNotifier(notify.New(nil, messages.Registry()), "")
	assert.False(t, disabled.Enabled())
	disabled.NotifyKYCVerified(context.Background(), &models.Client{ProfileID: "p"}, "x")
}

func TestApprovalCaseNotifier_SendsPayloadToEachProfileOnce(t *testing.T) {
	n, sender := newCaptureNotifier()
	acn := &ApprovalCaseNotifier{notifier: n}
	approvalCase := &models.ApprovalCase{
		CaseType:    "client_phone_change",
		Status:      approvalCaseStatusPendingApproval,
		SubjectType: approvalCaseSubjectClient,
		SubjectID:   "client-1",
		Summary:     "Change phone to +2567...",
		RequestedBy: "requester-profile",
	}
	approvalCase.GenID(context.Background())

	acn.sendToProfiles(context.Background(), messages.CaseApprovalRequired, approvalCase,
		[]string{"approver-1", "approver-1", "", "approver-2"}, notificationv1.PRIORITY_HIGH)

	require.Len(t, sender.got, 2, "duplicates and blanks are dropped")
	for _, got := range sender.got {
		assert.Equal(t, messages.CaseApprovalRequired, got.GetTemplate())
		assert.Empty(t, got.GetData())
		payload := got.GetPayload().AsMap()
		assert.Equal(t, "Client Phone Change", payload["case_type_label"])
		assert.Equal(t, approvalCase.GetID(), payload[logKeyCaseID])
	}
	assert.Equal(t, "approver-1", sender.got[0].GetRecipient().GetProfileId())
	assert.Equal(t, "approver-2", sender.got[1].GetRecipient().GetProfileId())
}
