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
	"time"

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

// Actions recorded on the client data entry audit trail.
const (
	actionSubmitted = "submitted"
	actionVerified  = "verified"
	actionRejected  = "rejected"
	actionMoreInfo  = "more_info"
	actionReview    = "review_started"
)

// reviewClaimTTL is how long a reviewer's hold on an entry under review
// lasts without activity before another reviewer may take it over.
const reviewClaimTTL = 24 * time.Hour

// ClientDataBusiness defines the operations for managing client KYC data entries.
type ClientDataBusiness interface {
	Save(ctx context.Context, entry *models.ClientDataEntry) (*models.ClientDataEntry, error)
	// UploadDocument stores a KYC photo, document or signature and records
	// it as the client's entry for the field.
	UploadDocument(
		ctx context.Context,
		req *identityv1.ClientDocumentUploadRequest,
	) (*models.ClientDataEntry, error)
	// DocumentLink returns a short-lived link to a document entry.
	DocumentLink(ctx context.Context, entryID string) (string, time.Time, error)
	Get(ctx context.Context, clientID, fieldKey string) (*models.ClientDataEntry, error)
	List(ctx context.Context, clientID string, status int32, offset, limit int) ([]*models.ClientDataEntry, error)
	Verify(ctx context.Context, entryID, comment string) (*models.ClientDataEntry, error)
	Reject(ctx context.Context, entryID, reason string) (*models.ClientDataEntry, error)
	RequestInfo(ctx context.Context, entryID, comment string) (*models.ClientDataEntry, error)
	// StartReview takes an entry for review by the caller.
	StartReview(ctx context.Context, entryID string) (*models.ClientDataEntry, error)
	History(ctx context.Context, entryID string) ([]*models.ClientDataEntryHistory, error)
	// Requirements reports what the client's organization requires; with no
	// client, what a borrower registered into teamID will need.
	Requirements(ctx context.Context, clientID, teamID string) (*KYCRequirements, error)
}

type clientDataBusiness struct {
	eventsMan   fevents.Manager
	entryRepo   repository.ClientDataEntryRepository
	historyRepo repository.ClientDataEntryHistoryRepository
	notifier    *ClientNotifier
	clients     clientLookup
	guard       *clientGuard
	kycPolicy   *KYCPolicy
	documents   DocumentStore
}

func NewClientDataBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	entryRepo repository.ClientDataEntryRepository,
	historyRepo repository.ClientDataEntryHistoryRepository,
	opts ...Option,
) ClientDataBusiness {
	o := applyOptions(opts)
	return &clientDataBusiness{
		eventsMan:   eventsMan,
		entryRepo:   entryRepo,
		historyRepo: historyRepo,
		notifier:    o.clientNotifier,
		clients:     o.clientLookup,
		guard:       o.clientGuard,
		kycPolicy:   o.kycPolicy,
		documents:   o.documents,
	}
}

func (b *clientDataBusiness) Save(ctx context.Context, entry *models.ClientDataEntry) (*models.ClientDataEntry, error) {
	client, err := b.guard.authorize(ctx, entry.ClientID)
	if err != nil {
		return nil, err
	}
	entry.ValueType = normalizeValueType(entry.ValueType)
	// A document is recognised by what is sent and by what the client's
	// form declares the field to be, so neither can be used to slip a value
	// past the upload.
	if isDocumentValueType(entry.ValueType) || b.fieldIsDocument(ctx, client, entry.FieldKey) == fieldDocument {
		return nil, ErrDocumentNeedsUpload
	}
	return b.save(ctx, entry)
}

// save records a new revision of the entry for a caller already authorized
// to capture the client's data.
func (b *clientDataBusiness) save(ctx context.Context, entry *models.ClientDataEntry) (*models.ClientDataEntry, error) {
	logger := util.Log(ctx).WithField("method", "ClientDataBusiness.Save")

	if entry.GetID() == "" {
		entry.GenID(ctx)
	}
	entry.Revision = 1
	entry.VerificationStatus = int32(identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_COLLECTED)

	// The write is synchronous and row-locked: a read-then-emit sequence let
	// two concurrent submissions both read revision N and both land as N+1.
	saved, err := b.entryRepo.SaveRevision(ctx, entry, func(existing, incoming *models.ClientDataEntry) {
		applyResubmission(ctx, existing, incoming)
	})
	switch {
	case err == nil:
	case errors.Is(err, repository.ErrClientDataEntryRevisionConflict):
		return nil, ErrClientDataEntryConflict
	default:
		logger.WithError(err).Error("could not save client data entry")
		return nil, fmt.Errorf("save client data entry: %w", err)
	}

	if historyErr := b.recordHistory(ctx, saved, actionSubmitted, saved.ModifiedBy, ""); historyErr != nil {
		logger.WithError(historyErr).Error("could not record history for save")
		return nil, historyErr
	}

	return saved, nil
}

// applyResubmission copies a new submission onto the stored entry. The value
// has been re-collected, so any earlier review decision no longer applies.
func applyResubmission(ctx context.Context, existing, incoming *models.ClientDataEntry) {
	existing.Value = incoming.Value
	existing.ValueType = incoming.ValueType
	existing.SourceEntityID = incoming.SourceEntityID
	existing.VerificationStatus = int32(identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_COLLECTED)
	existing.ReviewerID = ""
	existing.ReviewerComment = ""
	existing.VerifiedAt = nil
	if incoming.Properties != nil {
		existing.Properties = incoming.Properties
	}
	if incoming.ExpiresAt != nil {
		existing.ExpiresAt = incoming.ExpiresAt
	}
	// Stamps ModifiedBy from the submitter's claims.
	existing.GenID(ctx)
}

func (b *clientDataBusiness) Get(ctx context.Context, clientID, fieldKey string) (*models.ClientDataEntry, error) {
	if _, err := b.guard.authorize(ctx, clientID); err != nil {
		return nil, err
	}
	entry, err := b.entryRepo.GetByClientAndKey(ctx, clientID, fieldKey)
	if err != nil {
		return nil, ErrClientDataEntryNotFound
	}
	return entry, nil
}

func (b *clientDataBusiness) List(
	ctx context.Context,
	clientID string,
	status int32,
	offset, limit int,
) ([]*models.ClientDataEntry, error) {
	if offset < 0 {
		return nil, ErrInvalidPageToken
	}
	if _, err := b.guard.authorize(ctx, clientID); err != nil {
		return nil, err
	}
	if limit <= 0 || limit > maxSearchLimit {
		limit = defaultSearchLimit
	}
	return b.entryRepo.GetByClientID(ctx, clientID, status, offset, limit)
}

// Verify marks an entry as verified by the calling reviewer.
func (b *clientDataBusiness) Verify(
	ctx context.Context,
	entryID, comment string,
) (*models.ClientDataEntry, error) {
	return b.review(
		ctx,
		entryID,
		comment,
		identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_VERIFIED,
		actionVerified,
	)
}

// Reject marks an entry as rejected by the calling reviewer.
func (b *clientDataBusiness) Reject(
	ctx context.Context,
	entryID, reason string,
) (*models.ClientDataEntry, error) {
	return b.review(
		ctx,
		entryID,
		reason,
		identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_REJECTED,
		actionRejected,
	)
}

// RequestInfo sends an entry back to the submitter for more information.
func (b *clientDataBusiness) RequestInfo(
	ctx context.Context,
	entryID, comment string,
) (*models.ClientDataEntry, error) {
	return b.review(
		ctx,
		entryID,
		comment,
		identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_MORE_INFO_NEEDED,
		actionMoreInfo,
	)
}

// StartReview moves an entry to UNDER_REVIEW, held by the calling reviewer,
// so two reviewers never work the same entry. A reviewer who already holds
// it gets it back unchanged; one whose hold has lapsed loses it.
func (b *clientDataBusiness) StartReview(ctx context.Context, entryID string) (*models.ClientDataEntry, error) {
	logger := util.Log(ctx).WithField("method", "ClientDataBusiness.StartReview")

	reviewerID := actorFromClaims(ctx)
	if reviewerID == "" {
		return nil, ErrReviewerUnidentified
	}
	entry, err := b.entryRepo.GetByID(ctx, entryID)
	if err != nil {
		return nil, ErrClientDataEntryNotFound
	}
	if _, err = b.guard.authorize(ctx, entry.ClientID); err != nil {
		return nil, err
	}
	if checkErr := reviewable(entry, reviewerID, time.Now().UTC()); checkErr != nil &&
		!errors.Is(checkErr, ErrClientDataEntryHeldByAnotherReviewer) {
		return nil, checkErr
	}

	claimed, err := b.entryRepo.StartReview(ctx, entryID, reviewerID, time.Now().UTC().Add(-reviewClaimTTL))
	switch {
	case err == nil:
	case errors.Is(err, repository.ErrClientDataEntryReviewConflict):
		return nil, ErrClientDataEntryHeldByAnotherReviewer
	default:
		logger.WithError(err).Error("could not start the client data review")
		return nil, fmt.Errorf("start client data review: %w", err)
	}

	if historyErr := b.recordHistory(ctx, claimed, actionReview, reviewerID, ""); historyErr != nil {
		logger.WithError(historyErr).Error("could not record client data review history")
		return nil, historyErr
	}
	return claimed, nil
}

// reviewable reports why reviewerID may not act on the entry now, or nil.
func reviewable(entry *models.ClientDataEntry, reviewerID string, now time.Time) error {
	status := entry.EffectiveStatus(now)
	if status == identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_EXPIRED {
		return ErrClientDataEntryExpired
	}
	if !isReviewableStatus(int32(status)) {
		return ErrClientDataEntryNotReviewable
	}
	if reviewerID == entry.CreatedBy || reviewerID == entry.ModifiedBy {
		return ErrReviewerIsSubmitter
	}
	if status == identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_UNDER_REVIEW &&
		entry.ReviewerID != reviewerID {
		return ErrClientDataEntryHeldByAnotherReviewer
	}
	return nil
}

// review applies a reviewer decision to an entry. The reviewer is always the
// caller in the request claims, never a value from the request body, and an
// entry that already reached a terminal status cannot be reviewed again.
func (b *clientDataBusiness) review(
	ctx context.Context,
	entryID, comment string,
	target identityv1.DataVerificationStatus,
	action string,
) (*models.ClientDataEntry, error) {
	logger := util.Log(ctx).WithField("method", "ClientDataBusiness.review").WithField("action", action)

	reviewerID := actorFromClaims(ctx)
	if reviewerID == "" {
		return nil, ErrReviewerUnidentified
	}

	entry, err := b.entryRepo.GetByID(ctx, entryID)
	if err != nil {
		return nil, ErrClientDataEntryNotFound
	}
	if _, err = b.guard.authorize(ctx, entry.ClientID); err != nil {
		return nil, err
	}

	if checkErr := reviewable(entry, reviewerID, time.Now().UTC()); checkErr != nil {
		return nil, checkErr
	}

	fromStatus := entry.VerificationStatus
	fromReviewer := entry.ReviewerID
	entry.VerificationStatus = int32(target)
	entry.ReviewerID = reviewerID
	entry.ReviewerComment = comment
	if target == identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_VERIFIED {
		now := time.Now().UTC()
		entry.VerifiedAt = &now
	}

	// The decision is a conditional write on the status (and, under review,
	// the reviewer) that was read, so a concurrent verify and reject converge
	// on exactly one outcome.
	err = b.entryRepo.Review(ctx, entry, fromStatus, fromReviewer)
	switch {
	case err == nil:
	case errors.Is(err, repository.ErrClientDataEntryReviewConflict):
		return nil, ErrClientDataEntryReviewConflict
	default:
		logger.WithError(err).Error("could not persist client data review")
		return nil, fmt.Errorf("review client data entry: %w", err)
	}

	if historyErr := b.recordHistory(ctx, entry, action, reviewerID, comment); historyErr != nil {
		logger.WithError(historyErr).Error("could not record client data review history")
		return nil, historyErr
	}

	b.notifyReviewOutcome(ctx, entry, target, comment)

	return entry, nil
}

// notifyReviewOutcome tells the borrower what the reviewer decided. The
// client row is looked up for its profile; a client that cannot be found is
// logged, never a reason to fail the review that already landed.
func (b *clientDataBusiness) notifyReviewOutcome(
	ctx context.Context,
	entry *models.ClientDataEntry,
	target identityv1.DataVerificationStatus,
	comment string,
) {
	if !b.notifier.Enabled() || b.clients == nil {
		return
	}
	client, err := b.clients.GetByID(ctx, entry.ClientID)
	if err != nil || client == nil {
		util.Log(ctx).WithError(err).WithField("client_id", entry.ClientID).
			Error("KYC review notification not sent: client could not be loaded")
		return
	}
	switch target {
	case identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_VERIFIED:
		b.notifier.NotifyKYCVerified(ctx, client, entry.FieldKey)
	case identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_REJECTED:
		b.notifier.NotifyKYCRejected(ctx, client, entry.FieldKey, comment)
	case identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_MORE_INFO_NEEDED:
		b.notifier.NotifyKYCInfoRequested(ctx, client, entry.FieldKey, comment)
	case identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_UNSPECIFIED,
		identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_COLLECTED,
		identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_UNDER_REVIEW,
		identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_EXPIRED:
	}
}

// isReviewableStatus reports whether an entry in this status may still be
// acted on by a reviewer. VERIFIED, REJECTED and EXPIRED are terminal.
func isReviewableStatus(status int32) bool {
	switch identityv1.DataVerificationStatus(status) {
	case identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_COLLECTED,
		identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_UNDER_REVIEW,
		identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_MORE_INFO_NEEDED:
		return true
	case identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_UNSPECIFIED,
		identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_VERIFIED,
		identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_REJECTED,
		identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_EXPIRED:
		return false
	default:
		return false
	}
}

func (b *clientDataBusiness) History(
	ctx context.Context,
	entryID string,
) ([]*models.ClientDataEntryHistory, error) {
	entry, err := b.entryRepo.GetByID(ctx, entryID)
	if err != nil {
		return nil, ErrClientDataEntryNotFound
	}
	if _, err = b.guard.authorize(ctx, entry.ClientID); err != nil {
		return nil, err
	}
	return b.historyRepo.GetByEntryID(ctx, entryID)
}

func (b *clientDataBusiness) Requirements(ctx context.Context, clientID, teamID string) (*KYCRequirements, error) {
	if b.kycPolicy == nil {
		return nil, ErrClientKYCNotConfigured
	}
	if clientID != "" {
		client, err := b.guard.authorize(ctx, clientID)
		if err != nil {
			return nil, err
		}
		return b.kycPolicy.ForClient(ctx, client)
	}
	team, err := b.guard.onboardingTeam(ctx, teamID)
	if err != nil {
		return nil, err
	}
	tmpl, err := b.kycPolicy.TemplateForTeam(ctx, team)
	if err != nil {
		return nil, err
	}
	return &KYCRequirements{Template: tmpl}, nil
}

// recordHistory emits a history save event for the given entry action.
func (b *clientDataBusiness) recordHistory(
	ctx context.Context,
	entry *models.ClientDataEntry,
	action, actorID, comment string,
) error {
	history := &models.ClientDataEntryHistory{
		EntryID:  entry.GetID(),
		Revision: entry.Revision,
		Value:    entry.Value,
		Action:   action,
		ActorID:  actorID,
		Comment:  comment,
	}
	history.GenID(ctx)

	return b.eventsMan.Emit(ctx, events.ClientDataEntryHistorySaveEvent, history)
}
