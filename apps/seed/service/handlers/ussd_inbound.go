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

package handlers

import (
	"context"
	"fmt"

	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/proto"

	"github.com/antinvestor/service-fintech/apps/seed/service/business"
)

// notificationTypeUSSD is the inbound notification type of a completed
// USSD session.
const notificationTypeUSSD = "ussd"

// UssdInbound consumes completed USSD sessions, delivered by the
// notification service's ussd receive route to Seed's own topic.
type UssdInbound struct {
	ussd      business.UssdBusiness
	serviceID string
}

// NewUssdInbound returns the consumer for serviceID's sessions.
func NewUssdInbound(ussd business.UssdBusiness, serviceID string) *UssdInbound {
	return &UssdInbound{ussd: ussd, serviceID: serviceID}
}

// Handle acts on one completed session. A message that is not a Seed USSD
// session is acknowledged and dropped; a failure to act is returned so the
// message is redelivered (the loan request is keyed by the session).
func (h *UssdInbound) Handle(ctx context.Context, _ map[string]string, message []byte) error {
	n := &notificationv1.Notification{}
	if err := proto.Unmarshal(message, n); err != nil {
		util.Log(ctx).WithError(err).Warn("ussd inbound message is not a notification; dropped")
		return nil
	}
	if n.GetOutBound() || n.GetType() != notificationTypeUSSD || n.GetData() != h.serviceID {
		return nil
	}

	data := map[string]string{}
	for key, value := range n.GetPayload().GetFields() {
		if s := value.GetStringValue(); s != "" {
			data[key] = s
		}
	}
	err := h.ussd.HandleSession(ctx, business.UssdSession{
		ID:        n.GetId(),
		ProfileID: n.GetSource().GetProfileId(),
		ContactID: n.GetSource().GetContactId(),
		Data:      data,
	})
	if err != nil {
		return fmt.Errorf("ussd session %s: %w", n.GetId(), err)
	}
	return nil
}
