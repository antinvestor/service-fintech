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
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/types/known/structpb"
)

// AgentNotifier wraps the notification and profile service clients for
// agent onboarding workflows. If either client is nil the corresponding
// methods degrade gracefully -- they log a warning and return.
type AgentNotifier struct {
	client        notificationv1connect.NotificationServiceClient
	profileClient profilev1connect.ProfileServiceClient
	templateName  string
}

// NewAgentNotifier creates an AgentNotifier. Nil clients are tolerated;
// the corresponding methods become no-ops that log a warning.
func NewAgentNotifier(
	client notificationv1connect.NotificationServiceClient,
	profileClient profilev1connect.ProfileServiceClient,
	templateName string,
) *AgentNotifier {
	if templateName == "" {
		templateName = "template.fintech.agent.onboarding"
	}
	return &AgentNotifier{
		client:        client,
		profileClient: profileClient,
		templateName:  templateName,
	}
}

func (n *AgentNotifier) Client() notificationv1connect.NotificationServiceClient {
	if n == nil {
		return nil
	}
	return n.client
}

func (n *AgentNotifier) ProfileClient() profilev1connect.ProfileServiceClient {
	if n == nil {
		return nil
	}
	return n.profileClient
}

// NotifyAgentOnboarded sends a high-priority T&C acceptance invitation to a
// newly registered agent. The call is fire-and-forget: errors are logged but
// never propagated to the caller.
func (n *AgentNotifier) NotifyAgentOnboarded(ctx context.Context, contactDetail, agentName, agentID string) {
	if n == nil || n.client == nil {
		util.Log(ctx).Warn("notification client is nil, skipping agent onboarding notification")
		return
	}

	logger := util.Log(ctx).WithFields(map[string]any{
		logKeyComponent: "AgentNotifier",
		logKeyTemplate:  n.templateName,
	})

	data := map[string]string{
		"agent_name": agentName,
		"agent_id":   agentID,
	}

	dataJSON := ""
	raw, err := json.Marshal(data)
	if err != nil {
		logger.WithError(err).Warn("could not marshal notification data")
	} else {
		dataJSON = string(raw)
	}

	notification := notificationv1.Notification_builder{
		Type:     "agent_onboarding",
		Template: n.templateName,
		Data:     dataJSON,
		Recipient: commonv1.ContactLink_builder{
			Detail:      contactDetail,
			ProfileName: agentName,
		}.Build(),
		OutBound:    true,
		AutoRelease: true,
		Priority:    notificationv1.PRIORITY_HIGH,
	}.Build()

	stream, err := n.client.Send(ctx, connect.NewRequest(&notificationv1.SendRequest{
		Data: []*notificationv1.Notification{notification},
	}))
	if err != nil {
		logger.WithError(err).Error("could not send agent onboarding notification")
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

// CreateOrLinkProfile creates a new profile via the Profile service when
// profileID is empty. If profileID is already provided, it is returned as-is
// (trust the caller). Returns the profile ID and any error.
func (n *AgentNotifier) CreateOrLinkProfile(ctx context.Context, name, contactDetail string) (string, error) {
	if n == nil || n.profileClient == nil {
		util.Log(ctx).Warn("profile client is nil, skipping profile creation")
		return "", nil
	}

	logger := util.Log(ctx).WithFields(map[string]any{
		logKeyComponent: "AgentNotifier",
		"method":        "CreateOrLinkProfile",
	})

	props, err := structpb.NewStruct(map[string]any{
		"name": name,
		"role": "agent",
	})
	if err != nil {
		logger.WithError(err).Error("could not build profile properties")
		return "", err
	}

	resp, err := n.profileClient.Create(ctx, connect.NewRequest(&profilev1.CreateRequest{
		Type:       profilev1.ProfileType_PERSON,
		Contact:    contactDetail,
		Properties: props,
	}))
	if err != nil {
		logger.WithError(err).Error("could not create profile")
		return "", err
	}

	profileID := resp.Msg.GetData().GetId()
	logger.WithField("profile_id", profileID).Info("created profile for agent")
	return profileID, nil
}
