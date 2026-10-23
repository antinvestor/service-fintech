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

// Package notify is the one way a fintech service sends a notification.
//
// It builds the message the notification service actually renders: the
// template is named from the catalogue in pkg/messages, the variables travel
// in Payload (Data is the raw body and would be sent verbatim), and the
// recipient is addressed by profile id or contact id (Detail is ignored by
// the service). Every send is counted so a dropped message shows up on a
// dashboard instead of only in a log line.
package notify

import (
	"context"
	"errors"
	"fmt"
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/notification/connectrpc/go/notification/v1/notificationv1connect"
	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"github.com/antinvestor/common/notification"
	"github.com/pitabwire/frame/v2/telemetry"
	"github.com/pitabwire/util"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"
	"google.golang.org/protobuf/types/known/structpb"
)

var (
	// ErrDisabled is returned when no notification client is configured.
	ErrDisabled = errors.New("notify: no notification client configured")
	// ErrUnknownTemplate is returned for a template the catalogue does not
	// declare, so a typo fails in tests rather than at the first send.
	ErrUnknownTemplate = errors.New("notify: template is not in the catalogue")
	// ErrNoRecipient is returned when the recipient names neither a profile
	// nor a contact; the notification service would drop such a message.
	ErrNoRecipient = errors.New("notify: recipient has no profile id or contact id")
)

//nolint:gochecknoglobals // metrics are process-wide instruments
var (
	notifyMetrics = telemetry.NewBusinessMetrics("service-fintech-notify")

	sent = notifyMetrics.Counter("notifications_sent_total",
		"Notifications accepted by the notification service",
		metric.WithUnit("{notification}"))
	dropped = notifyMetrics.Counter("notifications_dropped_total",
		"Notifications that could not be sent",
		metric.WithUnit("{notification}"))
)

// Message is one notification to one recipient.
type Message struct {
	// Template is a name from pkg/messages.
	Template string
	// Kind labels the business event (e.g. "loan", "kyc"); it is recorded on
	// the notification and used to group delivery metrics.
	Kind string
	// Recipient is addressed by ProfileId (preferred) or ContactId. Build it
	// with ToProfile or ToContact.
	Recipient *commonv1.ContactLink
	// Vars are the template variables. Amounts must already be formatted.
	Vars map[string]any
	// Priority defaults to PRIORITY_LOW.
	Priority notificationv1.PRIORITY
	// Language defaults to the catalogue default.
	Language string
}

// Recipient is the address of a message: a ContactLink naming a profile or a
// contact, as built by ToProfile or ToContact.
type Recipient = *commonv1.ContactLink

// ToProfile addresses a message to a profile; the notification service
// picks the profile's reachable contact.
func ToProfile(profileID string) *commonv1.ContactLink {
	profileID = strings.TrimSpace(profileID)
	if profileID == "" {
		return nil
	}
	return commonv1.ContactLink_builder{ProfileId: profileID}.Build()
}

// ToContact addresses a message to a contact id or a raw contact detail
// (phone number, email); the notification service resolves either.
func ToContact(contact string) *commonv1.ContactLink {
	contact = strings.TrimSpace(contact)
	if contact == "" {
		return nil
	}
	return commonv1.ContactLink_builder{ContactId: contact}.Build()
}

// Notifier sends catalogue messages. A nil *Notifier or one built without a
// client is safe to call: every send returns ErrDisabled and is counted as
// dropped.
type Notifier struct {
	sender   notification.Sender
	registry *notification.Registry
}

// New builds a Notifier over a notification client. cli may be nil.
func New(cli notificationv1connect.NotificationServiceClient, registry *notification.Registry) *Notifier {
	n := &Notifier{registry: registry}
	if cli != nil {
		n.sender = notification.NewSender(cli)
	}
	return n
}

// NewWithSender builds a Notifier over any Sender; for tests.
func NewWithSender(sender notification.Sender, registry *notification.Registry) *Notifier {
	return &Notifier{sender: sender, registry: registry}
}

// Enabled reports whether sends can reach a notification service.
func (n *Notifier) Enabled() bool { return n != nil && n.sender != nil }

// Send validates and sends one message, returning the error to a caller
// that wants to react (for instance, to record it on the entity).
func (n *Notifier) Send(ctx context.Context, msg Message) error {
	attrs := []attribute.KeyValue{
		attribute.String("template", msg.Template),
		attribute.String("kind", msg.Kind),
	}
	if err := n.send(ctx, msg); err != nil {
		dropped.Add(ctx, 1, attrs...)
		return err
	}
	sent.Add(ctx, 1, attrs...)
	return nil
}

// SendOrLog sends and logs a failure at ERROR. It is the fire-and-forget
// form for business flows where the money or state change has already
// happened and must not be undone because a message could not be sent.
func (n *Notifier) SendOrLog(ctx context.Context, msg Message) {
	if err := n.Send(ctx, msg); err != nil {
		level := util.Log(ctx).WithError(err).WithFields(map[string]any{
			"template": msg.Template,
			"kind":     msg.Kind,
		})
		if errors.Is(err, ErrDisabled) {
			level.Warn("notification not sent: notifications are disabled")
			return
		}
		level.Error("notification not sent")
	}
}

func (n *Notifier) send(ctx context.Context, msg Message) error {
	if !n.Enabled() {
		return ErrDisabled
	}
	if n.registry != nil && !n.registry.Has(msg.Template) {
		return fmt.Errorf("%w: %s", ErrUnknownTemplate, msg.Template)
	}
	if msg.Recipient == nil || (msg.Recipient.GetProfileId() == "" && msg.Recipient.GetContactId() == "") {
		return ErrNoRecipient
	}

	payload, err := structpb.NewStruct(stringify(msg.Vars))
	if err != nil {
		return fmt.Errorf("notify: payload: %w", err)
	}

	language := msg.Language
	if language == "" {
		language = notification.DefaultLanguage
	}

	built := notificationv1.Notification_builder{
		Type:        msg.Kind,
		Template:    msg.Template,
		Payload:     payload,
		Recipient:   msg.Recipient,
		Language:    language,
		OutBound:    true,
		AutoRelease: true,
		Priority:    msg.Priority,
	}.Build()

	if err = n.sender.Send(ctx, built); err != nil {
		return fmt.Errorf("notify: send %s: %w", msg.Template, err)
	}
	return nil
}

// stringify makes every variable a string so templates render consistently
// and structpb never sees a type it cannot carry.
func stringify(vars map[string]any) map[string]any {
	out := make(map[string]any, len(vars))
	for k, v := range vars {
		switch t := v.(type) {
		case nil:
			out[k] = ""
		case string:
			out[k] = t
		case fmt.Stringer:
			out[k] = t.String()
		default:
			out[k] = fmt.Sprint(t)
		}
	}
	return out
}
