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

import "github.com/antinvestor/service-fintech/pkg/apperrors"

var (
	ErrOrganizationNotFound         = apperrors.NewError(apperrors.NotFound, "organization not found")
	ErrOrgUnitNotFound              = apperrors.NewError(apperrors.NotFound, "org unit not found")
	ErrBranchNotFound               = apperrors.NewError(apperrors.NotFound, "branch not found")
	ErrAgentNotFound                = apperrors.NewError(apperrors.NotFound, "agent not found")
	ErrClientNotFound               = apperrors.NewError(apperrors.NotFound, "client not found")
	ErrGroupNotFound                = apperrors.NewError(apperrors.NotFound, "group not found")
	ErrMembershipNotFound           = apperrors.NewError(apperrors.NotFound, "membership not found")
	ErrInvestorNotFound             = apperrors.NewError(apperrors.NotFound, "investor not found")
	ErrSystemUserNotFound           = apperrors.NewError(apperrors.NotFound, "system user not found")
	ErrWorkforceMemberNotFound      = apperrors.NewError(apperrors.NotFound, "workforce member not found")
	ErrDepartmentNotFound           = apperrors.NewError(apperrors.NotFound, "department not found")
	ErrPositionNotFound             = apperrors.NewError(apperrors.NotFound, "position not found")
	ErrPositionAssignmentNotFound   = apperrors.NewError(apperrors.NotFound, "position assignment not found")
	ErrInternalTeamNotFound         = apperrors.NewError(apperrors.NotFound, "internal team not found")
	ErrTeamMembershipNotFound       = apperrors.NewError(apperrors.NotFound, "team membership not found")
	ErrAccessRoleAssignmentNotFound = apperrors.NewError(apperrors.NotFound, "access role assignment not found")

	ErrAgentDepthExceeded       = apperrors.NewError(apperrors.Unprocessable, "agent hierarchy depth limit exceeded")
	ErrAgentBranchNotInParent   = apperrors.NewError(apperrors.BadRequest, "branch is not assigned to parent agent")
	ErrOrgUnitNotInOrganization = apperrors.NewError(
		apperrors.BadRequest,
		"org unit does not belong to the specified organization",
	)
	ErrBranchNotInOrganization = apperrors.NewError(
		apperrors.BadRequest,
		"branch does not belong to agent's organization",
	)
	ErrAgentInactive       = apperrors.NewError(apperrors.Unprocessable, "agent is not active")
	ErrClientAlreadyExists = apperrors.NewError(
		apperrors.Conflict,
		"client with this profile already exists",
	)
	ErrReassignSameAgent = apperrors.NewError(
		apperrors.BadRequest,
		"client is already assigned to this agent",
	)
	ErrCoverageAreaRequired = apperrors.NewError(apperrors.BadRequest, "coverage area is required")
	ErrOwningTeamRequired   = apperrors.NewError(apperrors.BadRequest, "owning team is required")
	ErrMemberNotInTeam      = apperrors.NewError(
		apperrors.BadRequest,
		"member is not assigned to the owning team",
	)
	ErrInvalidReportingLine = apperrors.NewError(apperrors.BadRequest, "invalid reporting line")
	ErrCircularParentChain  = apperrors.NewError(apperrors.BadRequest, "circular parent chain detected")
	ErrDeprecatedAgentModel = apperrors.NewError(
		apperrors.Gone,
		"agent model has been retired; use workforce members and teams",
	)
	ErrDeprecatedSystemUserModel = apperrors.NewError(
		apperrors.Gone,
		"system user model has been retired; use access role assignments",
	)
	ErrDeprecatedClientAgentReassignment = apperrors.NewError(
		apperrors.Gone,
		"client agent reassignment has been retired; transfer team ownership or assign a relationship member",
	)
	ErrReassignCrossOrganization = apperrors.NewError(
		apperrors.BadRequest,
		"cannot reassign client to agent in different organization",
	)
	ErrPrimaryPositionAssignmentExists = apperrors.NewError(
		apperrors.Conflict,
		"member already has an active primary position assignment",
	)
	ErrPrimaryTeamMembershipExists = apperrors.NewError(
		apperrors.Conflict,
		"member already has an active primary team membership",
	)
	ErrInvalidAccessScope = apperrors.NewError(apperrors.BadRequest, "invalid access scope")
	ErrInvalidRoleKey     = apperrors.NewError(apperrors.BadRequest, "role key is required")

	ErrCreditLimitNegative     = apperrors.NewError(apperrors.BadRequest, "credit limit cannot be negative")
	ErrAgentLimitExceedsSystem = apperrors.NewError(
		apperrors.BadRequest,
		"agent credit limit cannot exceed system credit limit",
	)
	ErrCreditLimitChangePending = apperrors.NewError(
		apperrors.Conflict,
		"a credit limit change request is already pending for this client",
	)
	ErrCreditLimitChangeNotFound   = apperrors.NewError(apperrors.NotFound, "credit limit change request not found")
	ErrCreditLimitChangeNotPending = apperrors.NewError(
		apperrors.Unprocessable,
		"credit limit change request is not in pending status",
	)

	ErrApprovalCaseSubjectRequired = apperrors.NewError(
		apperrors.BadRequest,
		"approval case subject and type are required",
	)
	ErrApprovalCaseActorRequired = apperrors.NewError(
		apperrors.BadRequest,
		"approval case actor is required",
	)
	ErrApprovalCaseAlreadyPending = apperrors.NewError(
		apperrors.Conflict,
		"an approval case is already pending for this subject",
	)
	ErrApprovalCaseNotFound   = apperrors.NewError(apperrors.NotFound, "approval case not found")
	ErrApprovalCaseNotPending = apperrors.NewError(
		apperrors.Unprocessable,
		"approval case is not pending",
	)
	ErrApprovalCaseNotPendingVerification = apperrors.NewError(
		apperrors.Unprocessable,
		"approval case is not pending verification",
	)
	ErrApprovalCaseNotPendingApproval = apperrors.NewError(
		apperrors.Unprocessable,
		"approval case is not pending approval",
	)
	ErrClientPhoneChangePending = apperrors.NewError(
		apperrors.Conflict,
		"a phone number change case is already pending for this client",
	)

	ErrPlatformAccessFailed = apperrors.NewError(
		apperrors.Unprocessable,
		"failed to grant platform access for workforce member",
	)

	ErrLoginClientCreationFailed = apperrors.NewError(
		apperrors.Unprocessable,
		"failed to create login client for partition",
	)

	ErrClientDataEntryNotFound  = apperrors.NewError(apperrors.NotFound, "client data entry not found")
	ErrFormTemplateNotFound     = apperrors.NewError(apperrors.NotFound, "form template not found")
	ErrFormTemplateNotDraft     = apperrors.NewError(apperrors.Unprocessable, "form template is not in draft status")
	ErrFormTemplateNotPublished = apperrors.NewError(
		apperrors.Unprocessable,
		"form template must be published to accept submissions",
	)
	ErrFormSubmissionNotFound      = apperrors.NewError(apperrors.NotFound, "form submission not found")
	ErrFormSubmissionMissingFields = apperrors.NewError(
		apperrors.BadRequest,
		"form submission is missing required fields defined in the template",
	)
	ErrFormSubmissionInlineFileData = apperrors.NewError(
		apperrors.BadRequest,
		"file fields must contain content URIs from the files service, not inline base64 or data URI data; upload files directly to the files service first",
	)
	ErrClientRelationshipNotFound = apperrors.NewError(apperrors.NotFound, "client relationship not found")
)
