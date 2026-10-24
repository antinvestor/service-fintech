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

package notify_test

import (
	"context"
	"errors"
	"testing"

	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
)

type captureSender struct {
	got []*notificationv1.Notification
	err error
}

func (c *captureSender) Send(_ context.Context, n *notificationv1.Notification) error {
	if c.err != nil {
		return c.err
	}
	c.got = append(c.got, n)
	return nil
}

func TestSendBuildsWhatTheNotificationServiceRenders(t *testing.T) {
	sender := &captureSender{}
	n := notify.NewWithSender(sender, messages.Registry())

	err := n.Send(context.Background(), notify.Message{
		Template:  messages.LoanRepaymentReceived,
		Kind:      "loan",
		Recipient: notify.ToProfile("profile-1"),
		Vars: map[string]any{
			messages.VarAmount:   "1,500.00",
			messages.VarCurrency: "KES",
			messages.VarBalance:  12_500,
		},
		Priority: notificationv1.PRIORITY_HIGH,
	})
	require.NoError(t, err)
	require.Len(t, sender.got, 1)

	got := sender.got[0]
	assert.Equal(t, messages.LoanRepaymentReceived, got.GetTemplate())
	assert.Equal(t, "profile-1", got.GetRecipient().GetProfileId())
	assert.Empty(t, got.GetData(), "variables must not travel in Data: the service sends Data verbatim as the body")
	require.NotNil(t, got.GetPayload())
	payload := got.GetPayload().AsMap()
	assert.Equal(t, "1,500.00", payload[messages.VarAmount])
	assert.Equal(t, "12500", payload[messages.VarBalance], "every variable is a string")
	assert.True(t, got.GetOutBound())
	assert.True(t, got.GetAutoRelease())
	assert.Equal(t, "en", got.GetLanguage())
	assert.Equal(t, notificationv1.PRIORITY_HIGH, got.GetPriority())
}

func TestSendRejectsWhatTheServiceWouldDrop(t *testing.T) {
	sender := &captureSender{}
	n := notify.NewWithSender(sender, messages.Registry())

	err := n.Send(context.Background(), notify.Message{
		Template:  "template.fintech.loan.does_not_exist",
		Recipient: notify.ToProfile("profile-1"),
	})
	require.ErrorIs(t, err, notify.ErrUnknownTemplate)

	err = n.Send(context.Background(), notify.Message{
		Template:  messages.LoanPaidOff,
		Recipient: notify.ToProfile(""),
	})
	require.ErrorIs(t, err, notify.ErrNoRecipient)

	assert.Empty(t, sender.got)
}

func TestContactRecipientAndDisabledNotifier(t *testing.T) {
	sender := &captureSender{}
	n := notify.NewWithSender(sender, messages.Registry())
	require.NoError(t, n.Send(context.Background(), notify.Message{
		Template:  messages.LoanCollectionRequested,
		Recipient: notify.ToContact("+256700000000"),
	}))
	assert.Equal(t, "+256700000000", sender.got[0].GetRecipient().GetContactId())

	var nilNotifier *notify.Notifier
	assert.False(t, nilNotifier.Enabled())
	require.ErrorIs(t, nilNotifier.Send(context.Background(), notify.Message{}), notify.ErrDisabled)

	disabled := notify.New(nil, messages.Registry())
	assert.False(t, disabled.Enabled())
	disabled.SendOrLog(context.Background(), notify.Message{Template: messages.LoanPaidOff})

	failing := notify.NewWithSender(&captureSender{err: errors.New("boom")}, messages.Registry())
	err := failing.Send(context.Background(), notify.Message{
		Template:  messages.LoanPaidOff,
		Recipient: notify.ToProfile("p"),
	})
	require.Error(t, err)
}
