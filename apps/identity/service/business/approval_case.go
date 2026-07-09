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

	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

const (
	caseActionKey  = "case_action"
	caseActorIDKey = "case_actor_id"
	caseCommentKey = "case_comment"

	approvalCaseIDKey             = "approval_case_id"
	approvalCaseTypeKey           = "approval_case_type"
	approvalCaseStatusKey         = "approval_case_status"
	approvalCaseSummaryKey        = "approval_case_summary"
	approvalCaseRequestedByKey    = "approval_case_requested_by"
	approvalCaseRequestedAtKey    = "approval_case_requested_at"
	approvalCaseVerifiedByKey     = "approval_case_verified_by"
	approvalCaseVerifiedAtKey     = "approval_case_verified_at"
	approvalCaseApprovedByKey     = "approval_case_approved_by"
	approvalCaseApprovedAtKey     = "approval_case_approved_at"
	approvalCaseRejectedByKey     = "approval_case_rejected_by"
	approvalCaseRejectedAtKey     = "approval_case_rejected_at"
	approvalCaseCommentMetaKey    = "approval_case_comment"
	approvalCaseRequestedValueKey = "approval_case_requested_value"

	approvalCaseSubjectBranch = "branch"
	approvalCaseSubjectClient = "client"

	approvalCaseTypeBranchCreate      = "branch_create"
	approvalCaseTypeClientPhoneChange = "client_phone_change"

	approvalCaseActionVerify  = "verify"
	approvalCaseActionApprove = "approve"
	approvalCaseActionReject  = "reject"

	approvalCaseStatusPendingVerification = "pending_verification"
	approvalCaseStatusPendingApproval     = "pending_approval"
	approvalCaseStatusApproved            = "approved"
	approvalCaseStatusRejected            = "rejected"

	clientPhoneNumberKey        = "phone_number"
	clientLegacyPhoneNumberKey  = "phone"
	clientPendingPhoneNumberKey = "pending_phone_number"
)

type ApprovalCaseSubmission struct {
	SubjectType         string
	SubjectID           string
	CaseType            string
	Summary             string
	RequestedBy         string
	Comment             string
	Payload             map[string]any
	RequireVerification bool
}

type ApprovalCaseBusiness interface {
	Submit(ctx context.Context, submission ApprovalCaseSubmission) (*models.ApprovalCase, error)
	Verify(ctx context.Context, caseID, actorID, comment string) (*models.ApprovalCase, error)
	Approve(ctx context.Context, caseID, actorID, comment string) (*models.ApprovalCase, error)
	Reject(ctx context.Context, caseID, actorID, comment string) (*models.ApprovalCase, error)
	GetOpenBySubject(ctx context.Context, subjectType, subjectID, caseType string) (*models.ApprovalCase, error)
}

type approvalCaseBusiness struct {
	eventsMan fevents.Manager
	repo      repository.ApprovalCaseRepository
	notifier  *ApprovalCaseNotifier
}

func NewApprovalCaseBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	repo repository.ApprovalCaseRepository,
	notifier *ApprovalCaseNotifier,
) ApprovalCaseBusiness {
	return &approvalCaseBusiness{
		eventsMan: eventsMan,
		repo:      repo,
		notifier:  notifier,
	}
}

func (b *approvalCaseBusiness) Submit(
	ctx context.Context,
	submission ApprovalCaseSubmission,
) (*models.ApprovalCase, error) {
	submission.RequestedBy = resolveCaseActorID(ctx, submission.RequestedBy, "")

	if submission.SubjectType == "" || submission.SubjectID == "" || submission.CaseType == "" {
		return nil, ErrApprovalCaseSubjectRequired
	}
	if submission.RequestedBy == "" {
		return nil, ErrApprovalCaseActorRequired
	}

	existing, err := b.GetOpenBySubject(ctx, submission.SubjectType, submission.SubjectID, submission.CaseType)
	if err == nil && existing != nil {
		return nil, ErrApprovalCaseAlreadyPending
	}
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, fmt.Errorf("get open approval case: %w", err)
	}

	status := approvalCaseStatusPendingApproval
	if submission.RequireVerification {
		status = approvalCaseStatusPendingVerification
	}

	approvalCase := &models.ApprovalCase{
		SubjectType: submission.SubjectType,
		SubjectID:   submission.SubjectID,
		CaseType:    submission.CaseType,
		Status:      status,
		Summary:     submission.Summary,
		RequestedBy: submission.RequestedBy,
		Comment:     submission.Comment,
		Payload:     copyJSONMap(submission.Payload),
	}
	approvalCase.GenID(ctx)

	if err = b.eventsMan.Emit(ctx, events.ApprovalCaseSaveEvent, approvalCase); err != nil {
		return nil, fmt.Errorf("emit approval case save: %w", err)
	}
	if b.notifier != nil {
		b.notifier.NotifySubmitted(ctx, approvalCase)
	}

	return approvalCase, nil
}

//nolint:dupl // similar transition logic for different approval states
func (b *approvalCaseBusiness) Verify(
	ctx context.Context,
	caseID, actorID, comment string,
) (*models.ApprovalCase, error) {
	actorID = resolveCaseActorID(ctx, actorID, "")
	if actorID == "" {
		return nil, ErrApprovalCaseActorRequired
	}

	approvalCase, err := b.repo.GetByID(ctx, caseID)
	if err != nil {
		return nil, ErrApprovalCaseNotFound
	}
	if approvalCase.Status != approvalCaseStatusPendingVerification {
		return nil, ErrApprovalCaseNotPendingVerification
	}

	now := time.Now().UTC()
	approvalCase.VerifiedBy = actorID
	approvalCase.VerifiedAt = &now
	approvalCase.Status = approvalCaseStatusPendingApproval
	if comment != "" {
		approvalCase.Comment = comment
	}

	if err = b.eventsMan.Emit(ctx, events.ApprovalCaseSaveEvent, approvalCase); err != nil {
		return nil, fmt.Errorf("emit approval case verify: %w", err)
	}
	if b.notifier != nil {
		b.notifier.NotifyVerified(ctx, approvalCase)
	}
	return approvalCase, nil
}

//nolint:dupl // similar transition logic for different approval states
func (b *approvalCaseBusiness) Approve(
	ctx context.Context,
	caseID, actorID, comment string,
) (*models.ApprovalCase, error) {
	actorID = resolveCaseActorID(ctx, actorID, "")
	if actorID == "" {
		return nil, ErrApprovalCaseActorRequired
	}

	approvalCase, err := b.repo.GetByID(ctx, caseID)
	if err != nil {
		return nil, ErrApprovalCaseNotFound
	}
	if approvalCase.Status != approvalCaseStatusPendingApproval {
		return nil, ErrApprovalCaseNotPendingApproval
	}

	now := time.Now().UTC()
	approvalCase.ApprovedBy = actorID
	approvalCase.ApprovedAt = &now
	approvalCase.Status = approvalCaseStatusApproved
	if comment != "" {
		approvalCase.Comment = comment
	}

	if err = b.eventsMan.Emit(ctx, events.ApprovalCaseSaveEvent, approvalCase); err != nil {
		return nil, fmt.Errorf("emit approval case approve: %w", err)
	}
	if b.notifier != nil {
		b.notifier.NotifyApproved(ctx, approvalCase)
	}
	return approvalCase, nil
}

func (b *approvalCaseBusiness) Reject(
	ctx context.Context,
	caseID, actorID, comment string,
) (*models.ApprovalCase, error) {
	actorID = resolveCaseActorID(ctx, actorID, "")
	if actorID == "" {
		return nil, ErrApprovalCaseActorRequired
	}

	approvalCase, err := b.repo.GetByID(ctx, caseID)
	if err != nil {
		return nil, ErrApprovalCaseNotFound
	}
	if approvalCase.Status != approvalCaseStatusPendingVerification &&
		approvalCase.Status != approvalCaseStatusPendingApproval {
		return nil, ErrApprovalCaseNotPending
	}

	now := time.Now().UTC()
	approvalCase.RejectedBy = actorID
	approvalCase.RejectedAt = &now
	approvalCase.Status = approvalCaseStatusRejected
	if comment != "" {
		approvalCase.Comment = comment
	}

	if err = b.eventsMan.Emit(ctx, events.ApprovalCaseSaveEvent, approvalCase); err != nil {
		return nil, fmt.Errorf("emit approval case reject: %w", err)
	}
	if b.notifier != nil {
		b.notifier.NotifyRejected(ctx, approvalCase)
	}
	return approvalCase, nil
}

func (b *approvalCaseBusiness) GetOpenBySubject(
	ctx context.Context,
	subjectType, subjectID, caseType string,
) (*models.ApprovalCase, error) {
	return b.repo.GetOpenBySubject(ctx, subjectType, subjectID, caseType)
}

func copyJSONMap(in map[string]any) map[string]any {
	if len(in) == 0 {
		return map[string]any{}
	}
	out := make(map[string]any, len(in))
	for k, v := range in {
		out[k] = v
	}
	return out
}

func entityProperties(props map[string]any) map[string]any {
	if props == nil {
		return map[string]any{}
	}
	return copyJSONMap(props)
}

func caseAction(props map[string]any) string {
	return strings.ToLower(strings.TrimSpace(stringValue(props[caseActionKey])))
}

func caseActorID(props map[string]any) string {
	return strings.TrimSpace(stringValue(props[caseActorIDKey]))
}

func resolveCaseActorID(ctx context.Context, actorID, createdBy string) string {
	if actorID = strings.TrimSpace(actorID); actorID != "" {
		return actorID
	}
	if createdBy = strings.TrimSpace(createdBy); createdBy != "" {
		return createdBy
	}
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return ""
	}
	return strings.TrimSpace(claims.GetProfileID())
}

func caseComment(props map[string]any) string {
	return strings.TrimSpace(stringValue(props[caseCommentKey]))
}

func stripCaseCommand(props map[string]any) {
	delete(props, caseActionKey)
	delete(props, caseActorIDKey)
	delete(props, caseCommentKey)
}

func stringValue(v any) string {
	switch typed := v.(type) {
	case string:
		return typed
	case fmt.Stringer:
		return typed.String()
	default:
		return ""
	}
}

func int32Value(v any) int32 {
	switch typed := v.(type) {
	case int32:
		return typed
	case int:
		if typed < -2147483648 || typed > 2147483647 {
			return 0
		}
		return int32(typed)
	case int64:
		if typed < -2147483648 || typed > 2147483647 {
			return 0
		}
		return int32(typed)
	case float64:
		if typed < -2147483648 || typed > 2147483647 {
			return 0
		}
		return int32(typed)
	case float32:
		if typed < -2147483648 || typed > 2147483647 {
			return 0
		}
		return int32(typed)
	default:
		return 0
	}
}

func normalizeClientPhoneProperties(props map[string]any) map[string]any {
	out := entityProperties(props)
	phone := clientPhoneNumber(out)
	if phone == "" {
		delete(out, clientPhoneNumberKey)
		delete(out, clientLegacyPhoneNumberKey)
		return out
	}
	out[clientPhoneNumberKey] = phone
	delete(out, clientLegacyPhoneNumberKey)
	return out
}

func clientPhoneNumber(props map[string]any) string {
	if phone := strings.TrimSpace(stringValue(props[clientPhoneNumberKey])); phone != "" {
		return phone
	}
	return strings.TrimSpace(stringValue(props[clientLegacyPhoneNumberKey]))
}

func setClientPhoneNumber(props map[string]any, phone string) {
	if phone == "" {
		delete(props, clientPhoneNumberKey)
		delete(props, clientLegacyPhoneNumberKey)
		return
	}
	props[clientPhoneNumberKey] = phone
	delete(props, clientLegacyPhoneNumberKey)
}

func applyApprovalCaseSnapshot(props map[string]any, approvalCase *models.ApprovalCase) map[string]any {
	out := entityProperties(props)
	out[approvalCaseIDKey] = approvalCase.GetID()
	out[approvalCaseTypeKey] = approvalCase.CaseType
	out[approvalCaseStatusKey] = approvalCase.Status
	out[approvalCaseSummaryKey] = approvalCase.Summary
	out[approvalCaseRequestedByKey] = approvalCase.RequestedBy
	if !approvalCase.CreatedAt.IsZero() {
		out[approvalCaseRequestedAtKey] = approvalCase.CreatedAt.UTC().Format(time.RFC3339)
	}
	if approvalCase.VerifiedBy != "" {
		out[approvalCaseVerifiedByKey] = approvalCase.VerifiedBy
	}
	if approvalCase.VerifiedAt != nil {
		out[approvalCaseVerifiedAtKey] = approvalCase.VerifiedAt.UTC().Format(time.RFC3339)
	}
	if approvalCase.ApprovedBy != "" {
		out[approvalCaseApprovedByKey] = approvalCase.ApprovedBy
	}
	if approvalCase.ApprovedAt != nil {
		out[approvalCaseApprovedAtKey] = approvalCase.ApprovedAt.UTC().Format(time.RFC3339)
	}
	if approvalCase.RejectedBy != "" {
		out[approvalCaseRejectedByKey] = approvalCase.RejectedBy
	}
	if approvalCase.RejectedAt != nil {
		out[approvalCaseRejectedAtKey] = approvalCase.RejectedAt.UTC().Format(time.RFC3339)
	}
	if approvalCase.Comment != "" {
		out[approvalCaseCommentMetaKey] = approvalCase.Comment
	}
	if requestedValue := stringValue(approvalCase.Payload[approvalCaseRequestedValueKey]); requestedValue != "" {
		out[approvalCaseRequestedValueKey] = requestedValue
	}
	return out
}

func openApprovalCaseID(subjectProps map[string]any) string {
	return strings.TrimSpace(stringValue(subjectProps[approvalCaseIDKey]))
}

func logApprovalCaseTransition(ctx context.Context, action string, approvalCase *models.ApprovalCase) {
	util.Log(ctx).WithFields(map[string]any{
		"action":       action,
		"approval_id":  approvalCase.GetID(),
		"subject_type": approvalCase.SubjectType,
		"subject_id":   approvalCase.SubjectID,
		"case_type":    approvalCase.CaseType,
		"status":       approvalCase.Status,
	}).Info("approval case transition completed")
}
