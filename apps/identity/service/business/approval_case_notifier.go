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
	"fmt"
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"buf.build/gen/go/antinvestor/notification/connectrpc/go/notification/v1/notificationv1connect"
	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

const (
	approvalCaseVerificationRequiredTemplate = "template.fintech.case.verification_required"
	approvalCaseApprovalRequiredTemplate     = "template.fintech.case.approval_required"
	approvalCaseApprovedTemplate             = "template.fintech.case.approved"
	approvalCaseRejectedTemplate             = "template.fintech.case.rejected"

	caseNotificationType = "approval_case"
	maxCaseRecipients    = 500
)

type approvalScope struct {
	scopeType identityv1.AccessScopeType
	scopeIDs  []string
}

// ApprovalCaseNotifier dispatches workflow notifications for reusable approval cases.
// Delivery is best effort and never blocks the underlying business transition.
type ApprovalCaseNotifier struct {
	client           notificationv1connect.NotificationServiceClient
	profileClient    profilev1connect.ProfileServiceClient
	workforceRepo    repository.WorkforceMemberRepository
	orgUnitRepo      repository.OrgUnitRepository
	clientRepo       repository.ClientRepository
	internalTeamRepo repository.InternalTeamRepository
	accessRoleRepo   repository.AccessRoleAssignmentRepository
}

func NewApprovalCaseNotifier(
	client notificationv1connect.NotificationServiceClient,
	profileClient profilev1connect.ProfileServiceClient,
	workforceRepo repository.WorkforceMemberRepository,
	orgUnitRepo repository.OrgUnitRepository,
	clientRepo repository.ClientRepository,
	internalTeamRepo repository.InternalTeamRepository,
	accessRoleRepo repository.AccessRoleAssignmentRepository,
) *ApprovalCaseNotifier {
	return &ApprovalCaseNotifier{
		client:           client,
		profileClient:    profileClient,
		workforceRepo:    workforceRepo,
		orgUnitRepo:      orgUnitRepo,
		clientRepo:       clientRepo,
		internalTeamRepo: internalTeamRepo,
		accessRoleRepo:   accessRoleRepo,
	}
}

func (n *ApprovalCaseNotifier) NotifySubmitted(ctx context.Context, approvalCase *models.ApprovalCase) {
	if approvalCase == nil {
		return
	}

	switch approvalCase.Status {
	case approvalCaseStatusPendingVerification:
		n.notifyRole(ctx,
			approvalCase,
			AccessRoleKeyApprovalVerifier,
			approvalCaseVerificationRequiredTemplate,
			notificationv1.PRIORITY_HIGH,
		)
	case approvalCaseStatusPendingApproval:
		n.notifyRole(ctx,
			approvalCase,
			AccessRoleKeyApprovalApprover,
			approvalCaseApprovalRequiredTemplate,
			notificationv1.PRIORITY_HIGH,
		)
	}
}

func (n *ApprovalCaseNotifier) NotifyVerified(ctx context.Context, approvalCase *models.ApprovalCase) {
	if approvalCase == nil {
		return
	}
	n.notifyRole(ctx,
		approvalCase,
		AccessRoleKeyApprovalApprover,
		approvalCaseApprovalRequiredTemplate,
		notificationv1.PRIORITY_HIGH,
	)
}

func (n *ApprovalCaseNotifier) NotifyApproved(ctx context.Context, approvalCase *models.ApprovalCase) {
	n.notifyRequester(ctx, approvalCase, approvalCaseApprovedTemplate, notificationv1.PRIORITY_HIGH)
}

func (n *ApprovalCaseNotifier) NotifyRejected(ctx context.Context, approvalCase *models.ApprovalCase) {
	n.notifyRequester(ctx, approvalCase, approvalCaseRejectedTemplate, notificationv1.PRIORITY_HIGH)
}

func (n *ApprovalCaseNotifier) notifyRole(
	ctx context.Context,
	approvalCase *models.ApprovalCase,
	roleKey string,
	template string,
	priority notificationv1.PRIORITY,
) {
	logger := util.Log(ctx).WithFields(map[string]any{
		logKeyComponent: componentApprovalCaseNotifier,
		logKeyCaseID:    approvalCase.GetID(),
		logKeyTemplate:  template,
		"role_key":      roleKey,
	})

	profileIDs, err := n.caseProfileRecipients(ctx, approvalCase, roleKey)
	if err != nil {
		logger.WithError(err).Warn("could not resolve approval case recipients")
		return
	}
	if len(profileIDs) == 0 {
		logger.Warn("no approval case recipients resolved")
		return
	}

	n.sendToProfiles(ctx, template, approvalCase, profileIDs, priority)
}

func (n *ApprovalCaseNotifier) notifyRequester(
	ctx context.Context,
	approvalCase *models.ApprovalCase,
	template string,
	priority notificationv1.PRIORITY,
) {
	if approvalCase == nil || approvalCase.RequestedBy == "" {
		return
	}

	n.sendToProfiles(ctx, template, approvalCase, []string{approvalCase.RequestedBy}, priority)
}

func (n *ApprovalCaseNotifier) caseProfileRecipients(
	ctx context.Context,
	approvalCase *models.ApprovalCase,
	roleKey string,
) ([]string, error) {
	if approvalCase == nil || n.accessRoleRepo == nil || n.workforceRepo == nil {
		return nil, nil
	}

	var scopes []approvalScope
	switch approvalCase.SubjectType {
	case approvalCaseSubjectBranch:
		scopes = n.orgUnitCaseScopes(ctx, approvalCase)
	case approvalCaseSubjectClient:
		scopes = n.clientCaseScopes(ctx, approvalCase.SubjectID)
	default:
		scopes = []approvalScope{{scopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_GLOBAL}}
	}

	return n.profileIDsForRoleAcrossScopes(ctx, roleKey, scopes)
}

func (n *ApprovalCaseNotifier) orgUnitCaseScopes(
	ctx context.Context,
	approvalCase *models.ApprovalCase,
) []approvalScope {
	if n.orgUnitRepo == nil {
		return []approvalScope{{scopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_GLOBAL}}
	}

	orgUnit, err := n.orgUnitRepo.GetByID(ctx, approvalCase.SubjectID)
	if err != nil {
		// Cannot resolve org unit; fall back to global scope.
		return []approvalScope{{scopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_GLOBAL}}
	}

	scopes := []approvalScope{
		{scopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_ORG_UNIT, scopeIDs: []string{orgUnit.GetID()}},
	}
	if orgUnit.OrganizationID != "" {
		scopes = append(scopes, approvalScope{
			scopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_ORGANIZATION,
			scopeIDs:  []string{orgUnit.OrganizationID},
		})
	}
	scopes = append(scopes, approvalScope{scopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_GLOBAL})
	return scopes
}

const maxClientCaseScopes = 4

//nolint:nestif // scope resolution inherently requires nested team lookups
func (n *ApprovalCaseNotifier) clientCaseScopes(ctx context.Context, clientID string) []approvalScope {
	if n.clientRepo == nil {
		return []approvalScope{{scopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_GLOBAL}}
	}

	client, err := n.clientRepo.GetByID(ctx, clientID)
	if err != nil {
		// Cannot resolve client; fall back to global scope.
		return []approvalScope{{scopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_GLOBAL}}
	}

	scopes := make([]approvalScope, 0, maxClientCaseScopes)
	if client.OwningTeamID != "" {
		scopes = append(scopes, approvalScope{
			scopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_TEAM,
			scopeIDs:  []string{client.OwningTeamID},
		})
		if n.internalTeamRepo != nil {
			team, teamErr := n.internalTeamRepo.GetByID(ctx, client.OwningTeamID)
			if teamErr == nil {
				if team.HomeOrgUnitID != "" {
					scopes = append(scopes, approvalScope{
						scopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_ORG_UNIT,
						scopeIDs:  []string{team.HomeOrgUnitID},
					})
				}
				if team.OrganizationID != "" {
					scopes = append(scopes, approvalScope{
						scopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_ORGANIZATION,
						scopeIDs:  []string{team.OrganizationID},
					})
				}
			}
		}
	}
	scopes = append(scopes, approvalScope{scopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_GLOBAL})
	return scopes
}

func (n *ApprovalCaseNotifier) profileIDsForRoleAcrossScopes(
	ctx context.Context,
	roleKey string,
	scopes []approvalScope,
) ([]string, error) {
	assignments, err := n.resolveAssignments(ctx, roleKey, scopes)
	if err != nil {
		return nil, err
	}
	if len(assignments) == 0 && roleKey != AccessRoleKeyIdentityAdministrator {
		assignments, err = n.resolveAssignments(ctx, AccessRoleKeyIdentityAdministrator, scopes)
		if err != nil {
			return nil, err
		}
	}
	if len(assignments) == 0 {
		return nil, nil
	}

	memberIDs := make([]string, 0, len(assignments))
	seenMembers := make(map[string]struct{}, len(assignments))
	for _, assignment := range assignments {
		if assignment == nil || assignment.MemberID == "" {
			continue
		}
		if _, exists := seenMembers[assignment.MemberID]; exists {
			continue
		}
		seenMembers[assignment.MemberID] = struct{}{}
		memberIDs = append(memberIDs, assignment.MemberID)
	}

	members, err := n.workforceRepo.GetByIDs(ctx, memberIDs)
	if err != nil {
		return nil, err
	}

	profileIDs := make([]string, 0, len(members))
	seenProfiles := make(map[string]struct{}, len(members))
	for _, member := range members {
		if member == nil || member.ProfileID == "" {
			continue
		}
		if _, exists := seenProfiles[member.ProfileID]; exists {
			continue
		}
		seenProfiles[member.ProfileID] = struct{}{}
		profileIDs = append(profileIDs, member.ProfileID)
	}
	return profileIDs, nil
}

func (n *ApprovalCaseNotifier) resolveAssignments(
	ctx context.Context,
	roleKey string,
	scopes []approvalScope,
) ([]*models.AccessRoleAssignment, error) {
	seen := map[string]struct{}{}
	assignments := make([]*models.AccessRoleAssignment, 0, maxCaseRecipients)

	for _, scope := range scopes {
		items, err := n.accessRoleRepo.GetActiveByRoleAndScopes(
			ctx,
			roleKey,
			scope.scopeType,
			scope.scopeIDs,
			maxCaseRecipients,
		)
		if err != nil {
			return nil, err
		}
		for _, item := range items {
			if item == nil || item.GetID() == "" {
				continue
			}
			if _, exists := seen[item.GetID()]; exists {
				continue
			}
			seen[item.GetID()] = struct{}{}
			assignments = append(assignments, item)
		}
	}

	return assignments, nil
}

func (n *ApprovalCaseNotifier) sendToProfiles(
	ctx context.Context,
	template string,
	approvalCase *models.ApprovalCase,
	profileIDs []string,
	priority notificationv1.PRIORITY,
) {
	logger := util.Log(ctx).WithFields(map[string]any{
		logKeyComponent: componentApprovalCaseNotifier,
		logKeyCaseID:    approvalCase.GetID(),
		logKeyTemplate:  template,
	})

	if n == nil || n.client == nil {
		logger.Warn("notification client is nil, skipping approval case notification")
		return
	}
	if n.profileClient == nil {
		logger.Warn("profile client is nil, skipping approval case notification")
		return
	}

	dataJSON := ""
	if raw, err := json.Marshal(approvalCaseNotificationData(approvalCase)); err != nil {
		logger.WithError(err).Warn("could not marshal approval case notification data")
	} else {
		dataJSON = string(raw)
	}

	sentTo := map[string]struct{}{}
	for _, profileID := range profileIDs {
		contactDetail, profileName, err := n.resolveProfileContact(ctx, profileID)
		if err != nil {
			logger.WithError(err).WithField("profile_id", profileID).
				Warn("could not resolve approval case notification recipient")
			continue
		}
		if contactDetail == "" {
			continue
		}
		if _, found := sentTo[contactDetail]; found {
			continue
		}
		sentTo[contactDetail] = struct{}{}

		n.send(ctx, template, contactDetail, profileName, dataJSON, priority)
	}
}

func (n *ApprovalCaseNotifier) resolveProfileContact(
	ctx context.Context,
	profileID string,
) (string, string, error) {
	resp, err := n.profileClient.GetById(ctx, connect.NewRequest(&profilev1.GetByIdRequest{Id: profileID}))
	if err != nil {
		return "", "", err
	}
	profile := resp.Msg.GetData()
	if profile == nil {
		return "", "", fmt.Errorf("profile %s not found", profileID)
	}

	name := profileID
	if props := profile.GetProperties(); props != nil {
		if value, ok := props.AsMap()["name"].(string); ok && strings.TrimSpace(value) != "" {
			name = value
		}
	}

	fallbackDetail := ""
	for _, contact := range profile.GetContacts() {
		if contact == nil || strings.TrimSpace(contact.GetDetail()) == "" {
			continue
		}
		if fallbackDetail == "" {
			fallbackDetail = contact.GetDetail()
		}
		if contact.GetState() == commonv1.STATE_INACTIVE || contact.GetState() == commonv1.STATE_DELETED {
			continue
		}
		if contact.GetVerified() {
			return contact.GetDetail(), name, nil
		}
	}

	return fallbackDetail, name, nil
}

func (n *ApprovalCaseNotifier) send(
	ctx context.Context,
	template, contactDetail, profileName, dataJSON string,
	priority notificationv1.PRIORITY,
) {
	logger := util.Log(ctx).WithFields(map[string]any{
		logKeyComponent: componentApprovalCaseNotifier,
		logKeyTemplate:  template,
		"recipient":     contactDetail,
	})

	stream, err := n.client.Send(ctx, connect.NewRequest(&notificationv1.SendRequest{
		Data: []*notificationv1.Notification{
			notificationv1.Notification_builder{
				Type:     caseNotificationType,
				Template: template,
				Data:     dataJSON,
				Recipient: commonv1.ContactLink_builder{
					Detail:      contactDetail,
					ProfileName: profileName,
				}.Build(),
				OutBound:    true,
				AutoRelease: true,
				Priority:    priority,
			}.Build(),
		},
	}))
	if err != nil {
		logger.WithError(err).Error("could not send approval case notification")
		return
	}

	for stream.Receive() {
	}
	if closeErr := stream.Close(); closeErr != nil {
		logger.WithError(closeErr).Warn("error closing approval case notification stream")
	}
}

func approvalCaseNotificationData(approvalCase *models.ApprovalCase) map[string]string {
	if approvalCase == nil {
		return map[string]string{}
	}

	return map[string]string{
		logKeyCaseID:        approvalCase.GetID(),
		"case_type":         approvalCase.CaseType,
		"case_type_label":   humanizeCaseValue(approvalCase.CaseType),
		"case_status":       approvalCase.Status,
		"case_status_label": humanizeCaseValue(approvalCase.Status),
		"subject_type":      approvalCase.SubjectType,
		"subject_id":        approvalCase.SubjectID,
		"summary":           approvalCase.Summary,
		"requested_by":      approvalCase.RequestedBy,
		"requested_value":   stringValue(approvalCase.Payload[approvalCaseRequestedValueKey]),
		"comment":           approvalCase.Comment,
	}
}

func humanizeCaseValue(value string) string {
	value = strings.TrimSpace(value)
	if value == "" {
		return ""
	}
	parts := strings.Fields(strings.NewReplacer("-", " ", "_", " ").Replace(value))
	for i, part := range parts {
		if part == "" {
			continue
		}
		parts[i] = strings.ToUpper(part[:1]) + strings.ToLower(part[1:])
	}
	return strings.Join(parts, " ")
}
