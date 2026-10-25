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

package repository

import (
	"context"
	"errors"
	"time"

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

// ErrClientDataEntryRevisionConflict reports that another submission for the
// same (client_id, field_key) landed between the read and the write. The
// caller's submission was not applied and can be retried on the new revision.
var ErrClientDataEntryRevisionConflict = errors.New("client data entry revision changed concurrently")

// ErrClientDataEntryReviewConflict reports that the conditional review update
// matched no row: another decision landed first, or the entry is gone.
var ErrClientDataEntryReviewConflict = errors.New("client data entry is no longer in the expected status")

// ClientDataEntryRepository manages persistence for client KYC data entries.
type ClientDataEntryRepository interface {
	datastore.BaseRepository[*models.ClientDataEntry]
	GetByClientAndKey(ctx context.Context, clientID, fieldKey string) (*models.ClientDataEntry, error)
	// SaveRevision persists incoming as the next revision of its
	// (client_id, field_key) row inside one transaction. The stored row is
	// read FOR UPDATE so concurrent submissions queue behind each other,
	// merge applies incoming onto it, and the write is conditional on the
	// revision that was read. A missing row is inserted as revision 1.
	SaveRevision(
		ctx context.Context,
		incoming *models.ClientDataEntry,
		merge func(existing, incoming *models.ClientDataEntry),
	) (*models.ClientDataEntry, error)
	// Review persists a reviewer decision with
	// `UPDATE ... WHERE id = ? AND verification_status = ?`, so of two
	// concurrent decisions on the same entry exactly one lands.
	//
	// An entry under review is decided only by the reviewer holding it, and
	// an expired entry is not decided at all.
	Review(ctx context.Context, entry *models.ClientDataEntry, fromStatus int32, fromReviewer string) error
	// StartReview hands the entry to reviewerID as UNDER_REVIEW. It takes a
	// collected entry, one waiting on more information, or one under review
	// whose claim was last touched before staleBefore; it reports
	// ErrClientDataEntryReviewConflict when the entry is in none of those.
	StartReview(ctx context.Context, entryID, reviewerID string, staleBefore time.Time) (*models.ClientDataEntry, error)
	GetByClientID(
		ctx context.Context,
		clientID string,
		verificationStatus int32,
		offset, limit int,
	) ([]*models.ClientDataEntry, error)
}

type clientDataEntryRepository struct {
	datastore.BaseRepository[*models.ClientDataEntry]
}

func NewClientDataEntryRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) ClientDataEntryRepository {
	return &clientDataEntryRepository{
		BaseRepository: datastore.NewBaseRepository[*models.ClientDataEntry](
			ctx, dbPool, workMan, func() *models.ClientDataEntry { return &models.ClientDataEntry{} },
		),
	}
}

func (repo *clientDataEntryRepository) GetByClientAndKey(
	ctx context.Context,
	clientID, fieldKey string,
) (*models.ClientDataEntry, error) {
	entry := models.ClientDataEntry{}
	err := repo.Pool().DB(ctx, true).
		First(&entry, "client_id = ? AND field_key = ?", clientID, fieldKey).Error
	if err != nil {
		return nil, err
	}
	return &entry, nil
}

func (repo *clientDataEntryRepository) SaveRevision(
	ctx context.Context,
	incoming *models.ClientDataEntry,
	merge func(existing, incoming *models.ClientDataEntry),
) (*models.ClientDataEntry, error) {
	var saved *models.ClientDataEntry
	err := repo.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		existing := &models.ClientDataEntry{}
		lockErr := tx.WithContext(ctx).
			Clauses(clause.Locking{Strength: "UPDATE"}).
			Where("client_id = ? AND field_key = ?", incoming.ClientID, incoming.FieldKey).
			First(existing).Error
		switch {
		case lockErr == nil:
			merged, updateErr := updateLockedRevision(ctx, tx, existing, incoming, merge)
			if updateErr != nil {
				return updateErr
			}
			saved = merged
			return nil
		case errors.Is(lockErr, gorm.ErrRecordNotFound):
			if createErr := tx.WithContext(ctx).Create(incoming).Error; createErr != nil {
				// Two first submissions raced on the (client_id, field_key)
				// unique index; the loser is told rather than silently dropped.
				if data.ErrorIsDuplicateKey(createErr) {
					return ErrClientDataEntryRevisionConflict
				}
				return createErr
			}
			saved = incoming
			return nil
		default:
			return lockErr
		}
	})
	if err != nil {
		return nil, err
	}
	return saved, nil
}

// updateLockedRevision writes the merged entry over the row that is locked in
// tx. The revision predicate is redundant under FOR UPDATE but keeps the write
// safe should the lock ever be dropped.
func updateLockedRevision(
	ctx context.Context,
	tx *gorm.DB,
	existing, incoming *models.ClientDataEntry,
	merge func(existing, incoming *models.ClientDataEntry),
) (*models.ClientDataEntry, error) {
	previousRevision := existing.Revision
	merge(existing, incoming)
	existing.Revision = previousRevision + 1

	now := time.Now().UTC()
	result := tx.WithContext(ctx).
		Table((&models.ClientDataEntry{}).TableName()).
		Where("id = ? AND revision = ? AND deleted_at IS NULL", existing.GetID(), previousRevision).
		Updates(map[string]any{
			"value":               existing.Value,
			"value_type":          existing.ValueType,
			"source_entity_id":    existing.SourceEntityID,
			"revision":            existing.Revision,
			colVerificationStatus: existing.VerificationStatus,
			colReviewerID:         existing.ReviewerID,
			"reviewer_comment":    existing.ReviewerComment,
			colVerifiedAt:         existing.VerifiedAt,
			"expires_at":          existing.ExpiresAt,
			"properties":          &existing.Properties,
			colModifiedAt:         now,
			colModifiedBy:         existing.ModifiedBy,
			colVersion:            gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, ErrClientDataEntryRevisionConflict
	}
	existing.ModifiedAt = now
	existing.Version++
	return existing, nil
}

func (repo *clientDataEntryRepository) Review(
	ctx context.Context,
	entry *models.ClientDataEntry,
	fromStatus int32,
	fromReviewer string,
) error {
	now := time.Now().UTC()
	return repo.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		q := tx.WithContext(ctx).
			Table((&models.ClientDataEntry{}).TableName()).
			Where("id = ? AND verification_status = ? AND deleted_at IS NULL", entry.GetID(), fromStatus).
			Where(notExpiredClause, now)
		if fromStatus == statusUnderReview {
			q = q.Where("reviewer_id = ?", fromReviewer)
		}
		result := q.Updates(map[string]any{
			colVerificationStatus: entry.VerificationStatus,
			colReviewerID:         entry.ReviewerID,
			"reviewer_comment":    entry.ReviewerComment,
			colVerifiedAt:         entry.VerifiedAt,
			colModifiedAt:         now,
			colModifiedBy:         entry.ReviewerID,
			colVersion:            gorm.Expr("version + 1"),
		})
		if result.Error != nil {
			return result.Error
		}
		if result.RowsAffected == 0 {
			return ErrClientDataEntryReviewConflict
		}
		entry.ModifiedAt = now
		entry.ModifiedBy = entry.ReviewerID
		entry.Version++
		return nil
	})
}

// Verification status codes the queries below filter on; they mirror
// identityv1.DataVerificationStatus.
const (
	statusCollected      = 1
	statusUnderReview    = 2
	statusRejected       = 4
	statusMoreInfoNeeded = 5
	statusExpired        = 6
)

// notExpiredClause holds for an entry whose document has not passed its
// expiry date at the bound time.
const notExpiredClause = "(expires_at IS NULL OR expires_at > ?)"

func (repo *clientDataEntryRepository) StartReview(
	ctx context.Context,
	entryID, reviewerID string,
	staleBefore time.Time,
) (*models.ClientDataEntry, error) {
	now := time.Now().UTC()
	result := repo.Pool().DB(ctx, false).
		Table((&models.ClientDataEntry{}).TableName()).
		Where("id = ? AND deleted_at IS NULL", entryID).
		Where(notExpiredClause, now).
		Where("(verification_status IN (?, ?) OR (verification_status = ? AND (reviewer_id = ? OR modified_at < ?)))",
			statusCollected, statusMoreInfoNeeded, statusUnderReview, reviewerID, staleBefore).
		Updates(map[string]any{
			colVerificationStatus: statusUnderReview,
			colReviewerID:         reviewerID,
			colModifiedAt:         now,
			// modified_by stays the submitter's: the reviewer is recorded
			// in reviewer_id, and the separation-of-duties check reads
			// modified_by as who last submitted the value.
			colVersion: gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, ErrClientDataEntryReviewConflict
	}
	return repo.GetByID(ctx, entryID)
}

// GetByClientID lists a client's entries, filtered by the status each holds
// now: an entry past its expiry date is listed as EXPIRED, not as what it
// was reviewed as.
func (repo *clientDataEntryRepository) GetByClientID(
	ctx context.Context,
	clientID string,
	verificationStatus int32,
	offset, limit int,
) ([]*models.ClientDataEntry, error) {
	var entries []*models.ClientDataEntry
	now := time.Now().UTC()
	q := repo.Pool().DB(ctx, true).Where("client_id = ?", clientID)
	switch {
	case verificationStatus == statusExpired:
		q = q.Where("(verification_status = ? OR (verification_status <> ? AND expires_at <= ?))",
			statusExpired, statusRejected, now)
	case verificationStatus == statusRejected:
		q = q.Where("verification_status = ?", verificationStatus)
	case verificationStatus > 0:
		q = q.Where("verification_status = ?", verificationStatus).Where(notExpiredClause, now)
	}
	err := q.Order("field_key ASC, id ASC").Offset(offset).Limit(limit).Find(&entries).Error
	if err != nil {
		return nil, err
	}
	return entries, nil
}

// ClientDataEntryHistoryRepository manages persistence for data entry revision history.
type ClientDataEntryHistoryRepository interface {
	datastore.BaseRepository[*models.ClientDataEntryHistory]
	GetByEntryID(ctx context.Context, entryID string) ([]*models.ClientDataEntryHistory, error)
}

type clientDataEntryHistoryRepository struct {
	datastore.BaseRepository[*models.ClientDataEntryHistory]
}

func NewClientDataEntryHistoryRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) ClientDataEntryHistoryRepository {
	return &clientDataEntryHistoryRepository{
		BaseRepository: datastore.NewBaseRepository[*models.ClientDataEntryHistory](
			ctx, dbPool, workMan, func() *models.ClientDataEntryHistory { return &models.ClientDataEntryHistory{} },
		),
	}
}

func (repo *clientDataEntryHistoryRepository) GetByEntryID(
	ctx context.Context,
	entryID string,
) ([]*models.ClientDataEntryHistory, error) {
	var history []*models.ClientDataEntryHistory
	err := repo.Pool().DB(ctx, true).
		Where("entry_id = ?", entryID).
		Order("revision ASC").
		Find(&history).Error
	if err != nil {
		return nil, err
	}
	return history, nil
}
