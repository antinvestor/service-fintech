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
	"encoding/json"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/notification/connectrpc/go/notification/v1/notificationv1connect"
	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/util"
)

// LoanNotifier wraps the notification service client for sending
// loan-related notifications to clients.
type LoanNotifier struct {
	client notificationv1connect.NotificationServiceClient
}

// NewLoanNotifier creates a LoanNotifier. If client is nil the notifier
// degrades gracefully — all methods become no-ops that log a warning.
func NewLoanNotifier(client notificationv1connect.NotificationServiceClient) *LoanNotifier {
	return &LoanNotifier{client: client}
}

// NotifyLoanApproved sends a high-priority notification when a loan is approved.
func (n *LoanNotifier) NotifyLoanApproved(ctx context.Context, clientContact, clientName, loanAmount, currency string) {
	data := map[string]string{
		"loan_amount": loanAmount,
		fieldCurrency: currency,
	}
	n.send(ctx, "loan_approved", clientContact, clientName, data, notificationv1.PRIORITY_HIGH)
}

// NotifyRepaymentReceived sends a notification when a repayment is received.
func (n *LoanNotifier) NotifyRepaymentReceived(
	ctx context.Context,
	clientContact, clientName, amount, currency, remainingBalance string,
) {
	data := map[string]string{
		fieldAmount:         amount,
		fieldCurrency:       currency,
		"remaining_balance": remainingBalance,
	}
	n.send(ctx, "repayment_received", clientContact, clientName, data, notificationv1.PRIORITY_LOW)
}

// NotifyLoanFullyPaid sends a notification when a loan is fully paid off.
func (n *LoanNotifier) NotifyLoanFullyPaid(ctx context.Context, clientContact, clientName string) {
	n.send(ctx, "loan_fully_paid", clientContact, clientName, nil, notificationv1.PRIORITY_LOW)
}

// NotifyApplicationUnderReview sends a notification when an application is under review.
func (n *LoanNotifier) NotifyApplicationUnderReview(ctx context.Context, clientContact, clientName string) {
	n.send(ctx, "application_under_review", clientContact, clientName, nil, notificationv1.PRIORITY_LOW)
}

// send builds a Notification, calls Send on the notification service client,
// and closes the resulting stream. Errors are logged but never propagated
// (fire-and-forget).
func (n *LoanNotifier) send(
	ctx context.Context,
	template, contact, name string,
	data map[string]string,
	priority notificationv1.PRIORITY,
) {
	logger := util.Log(ctx).WithFields(map[string]any{"component": "LoanNotifier", "template": template})

	if n == nil || n.client == nil {
		logger.Warn("notification client is nil, skipping notification")
		return
	}

	dataJSON := ""
	if data != nil {
		raw, err := json.Marshal(data)
		if err != nil {
			logger.WithError(err).Warn("could not marshal notification data")
		} else {
			dataJSON = string(raw)
		}
	}

	notification := notificationv1.Notification_builder{
		Type:     "loan",
		Template: template,
		Data:     dataJSON,
		Recipient: commonv1.ContactLink_builder{
			Detail:      contact,
			ProfileName: name,
		}.Build(),
		OutBound:    true,
		AutoRelease: true,
		Priority:    priority,
	}.Build()

	stream, err := n.client.Send(ctx, connect.NewRequest(&notificationv1.SendRequest{
		Data: []*notificationv1.Notification{notification},
	}))
	if err != nil {
		logger.WithError(err).Error("could not send notification")
		return
	}
	// Drain and close the stream (fire-and-forget).
	for stream.Receive() {
		// discard responses
	}
	if closeErr := stream.Close(); closeErr != nil {
		logger.WithError(closeErr).Warn("error closing notification stream")
	}
}
