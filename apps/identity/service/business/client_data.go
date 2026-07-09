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
	"time"

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

// ClientDataBusiness defines the operations for managing client KYC data entries.
type ClientDataBusiness interface {
	Save(ctx context.Context, entry *models.ClientDataEntry) (*models.ClientDataEntry, error)
	Get(ctx context.Context, clientID, fieldKey string) (*models.ClientDataEntry, error)
	List(ctx context.Context, clientID string, status int32, offset, limit int) ([]*models.ClientDataEntry, error)
	Verify(ctx context.Context, entryID, reviewerID, comment string) (*models.ClientDataEntry, error)
	Reject(ctx context.Context, entryID, reviewerID, reason string) (*models.ClientDataEntry, error)
	RequestInfo(ctx context.Context, entryID, reviewerID, comment string) (*models.ClientDataEntry, error)
	History(ctx context.Context, entryID string) ([]*models.ClientDataEntryHistory, error)
}

type clientDataBusiness struct {
	eventsMan   fevents.Manager
	entryRepo   repository.ClientDataEntryRepository
	historyRepo repository.ClientDataEntryHistoryRepository
}

func NewClientDataBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	entryRepo repository.ClientDataEntryRepository,
	historyRepo repository.ClientDataEntryHistoryRepository,
) ClientDataBusiness {
	return &clientDataBusiness{
		eventsMan:   eventsMan,
		entryRepo:   entryRepo,
		historyRepo: historyRepo,
	}
}

func (b *clientDataBusiness) Save(ctx context.Context, entry *models.ClientDataEntry) (*models.ClientDataEntry, error) {
	logger := util.Log(ctx).WithField("method", "ClientDataBusiness.Save")

	// Check if an entry already exists for this client+key pair
	existing, err := b.entryRepo.GetByClientAndKey(ctx, entry.ClientID, entry.FieldKey)
	if err == nil && existing != nil {
		// Update existing entry: increment revision, update value, reset status to COLLECTED
		existing.Value = entry.Value
		existing.ValueType = entry.ValueType
		existing.SourceEntityID = entry.SourceEntityID
		existing.Revision++
		existing.VerificationStatus = int32(identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_COLLECTED)
		existing.ReviewerID = ""
		existing.ReviewerComment = ""
		existing.VerifiedAt = nil
		if entry.Properties != nil {
			existing.Properties = entry.Properties
		}
		if entry.ExpiresAt != nil {
			existing.ExpiresAt = entry.ExpiresAt
		}
		entry = existing
	} else {
		// New entry
		if entry.GetID() == "" {
			entry.GenID(ctx)
		}
		entry.Revision = 1
		entry.VerificationStatus = int32(identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_COLLECTED)
	}

	if emitErr := b.eventsMan.Emit(ctx, events.ClientDataEntrySaveEvent, entry); emitErr != nil {
		logger.WithError(emitErr).Error("could not emit client data entry save event")
		return nil, emitErr
	}

	// Record history
	if historyErr := b.recordHistory(ctx, entry, "submitted", "", ""); historyErr != nil {
		logger.WithError(historyErr).Warn("could not record history for save")
	}

	return entry, nil
}

func (b *clientDataBusiness) Get(ctx context.Context, clientID, fieldKey string) (*models.ClientDataEntry, error) {
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
	if limit <= 0 {
		limit = 50
	}
	return b.entryRepo.GetByClientID(ctx, clientID, status, offset, limit)
}

func (b *clientDataBusiness) Verify(
	ctx context.Context,
	entryID, reviewerID, comment string,
) (*models.ClientDataEntry, error) {
	logger := util.Log(ctx).WithField("method", "ClientDataBusiness.Verify")

	entry, err := b.entryRepo.GetByID(ctx, entryID)
	if err != nil {
		return nil, ErrClientDataEntryNotFound
	}

	now := time.Now().UTC()
	entry.VerificationStatus = int32(identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_VERIFIED)
	entry.ReviewerID = reviewerID
	entry.ReviewerComment = comment
	entry.VerifiedAt = &now

	if emitErr := b.eventsMan.Emit(ctx, events.ClientDataEntrySaveEvent, entry); emitErr != nil {
		logger.WithError(emitErr).Error("could not emit client data entry save event")
		return nil, emitErr
	}

	if historyErr := b.recordHistory(ctx, entry, "verified", reviewerID, comment); historyErr != nil {
		logger.WithError(historyErr).Warn("could not record history for verify")
	}

	return entry, nil
}

func (b *clientDataBusiness) Reject(
	ctx context.Context,
	entryID, reviewerID, reason string,
) (*models.ClientDataEntry, error) {
	logger := util.Log(ctx).WithField("method", "ClientDataBusiness.Reject")

	entry, err := b.entryRepo.GetByID(ctx, entryID)
	if err != nil {
		return nil, ErrClientDataEntryNotFound
	}

	entry.VerificationStatus = int32(identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_REJECTED)
	entry.ReviewerID = reviewerID
	entry.ReviewerComment = reason

	if emitErr := b.eventsMan.Emit(ctx, events.ClientDataEntrySaveEvent, entry); emitErr != nil {
		logger.WithError(emitErr).Error("could not emit client data entry save event")
		return nil, emitErr
	}

	if historyErr := b.recordHistory(ctx, entry, "rejected", reviewerID, reason); historyErr != nil {
		logger.WithError(historyErr).Warn("could not record history for reject")
	}

	return entry, nil
}

func (b *clientDataBusiness) RequestInfo(
	ctx context.Context,
	entryID, reviewerID, comment string,
) (*models.ClientDataEntry, error) {
	logger := util.Log(ctx).WithField("method", "ClientDataBusiness.RequestInfo")

	entry, err := b.entryRepo.GetByID(ctx, entryID)
	if err != nil {
		return nil, ErrClientDataEntryNotFound
	}

	entry.VerificationStatus = int32(identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_MORE_INFO_NEEDED)
	entry.ReviewerID = reviewerID
	entry.ReviewerComment = comment

	if emitErr := b.eventsMan.Emit(ctx, events.ClientDataEntrySaveEvent, entry); emitErr != nil {
		logger.WithError(emitErr).Error("could not emit client data entry save event")
		return nil, emitErr
	}

	if historyErr := b.recordHistory(ctx, entry, "more_info", reviewerID, comment); historyErr != nil {
		logger.WithError(historyErr).Warn("could not record history for request info")
	}

	return entry, nil
}

func (b *clientDataBusiness) History(
	ctx context.Context,
	entryID string,
) ([]*models.ClientDataEntryHistory, error) {
	// Verify entry exists
	if _, err := b.entryRepo.GetByID(ctx, entryID); err != nil {
		return nil, ErrClientDataEntryNotFound
	}
	return b.historyRepo.GetByEntryID(ctx, entryID)
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
