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

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"

	"github.com/antinvestor/service-fintech/apps/seed/service/models"
)

// UssdPinRepository keeps borrowers' USSD PINs.
type UssdPinRepository interface {
	datastore.BaseRepository[*models.UssdPin]
	// GetByProfile returns the borrower's row, or nil when they have none.
	GetByProfile(ctx context.Context, profileID string) (*models.UssdPin, error)
	// Ensure returns the borrower's row, creating an empty one if needed.
	Ensure(ctx context.Context, profileID string) (*models.UssdPin, error)
	// RecordVerification notes the one-time code just sent to contactID.
	RecordVerification(ctx context.Context, id, verificationID, contactID string, at time.Time) error
	// SetPin stores a new hash and consumes the code. A set or change also
	// clears failures; a reset (forgotten PIN) keeps any running lock and
	// records when it happened.
	SetPin(ctx context.Context, id, hash string, reset bool) error
	// RecordFailure counts a wrong PIN in one statement, locking the PIN
	// until lockUntil once maxAttempts is reached, and returns the count.
	RecordFailure(ctx context.Context, id string, maxAttempts int32, lockUntil time.Time) (int32, error)
	// ClearFailures resets the count after a good PIN.
	ClearFailures(ctx context.Context, id string) error
}

type ussdPinRepository struct {
	datastore.BaseRepository[*models.UssdPin]
}

// NewUssdPinRepository creates a UssdPinRepository.
func NewUssdPinRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) UssdPinRepository {
	return &ussdPinRepository{
		BaseRepository: datastore.NewBaseRepository[*models.UssdPin](
			ctx, dbPool, workMan, func() *models.UssdPin { return &models.UssdPin{} },
		),
	}
}

const tableUssdPins = "seed_ussd_pins"

func (r *ussdPinRepository) GetByProfile(ctx context.Context, profileID string) (*models.UssdPin, error) {
	pin := &models.UssdPin{}
	err := r.Pool().DB(ctx, true).Where("profile_id = ? AND deleted_at IS NULL", profileID).First(pin).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil //nolint:nilnil // no PIN is an answer, not an error
	}
	if err != nil {
		return nil, err
	}
	return pin, nil
}

func (r *ussdPinRepository) Ensure(ctx context.Context, profileID string) (*models.UssdPin, error) {
	pin := &models.UssdPin{ProfileID: profileID}
	pin.GenID(ctx)
	// The partial unique index on (partition_id, profile_id) makes a racing
	// second insert a no-op; both callers then read the one row.
	if err := r.Pool().DB(ctx, false).Clauses(clause.OnConflict{DoNothing: true}).Create(pin).Error; err != nil {
		return nil, err
	}
	stored, err := r.GetByProfile(ctx, profileID)
	if err != nil {
		return nil, err
	}
	if stored == nil {
		return nil, errors.New("ussd pin row missing after ensure")
	}
	return stored, nil
}

func (r *ussdPinRepository) RecordVerification(
	ctx context.Context,
	id, verificationID, contactID string,
	at time.Time,
) error {
	return r.Pool().DB(ctx, false).Table(tableUssdPins).Where("id = ?", id).Updates(map[string]any{
		"verification_id":           verificationID,
		"verification_contact_id":   contactID,
		"verification_requested_at": at.UTC(),
		colModifiedAt:               time.Now().UTC(),
		colVersion:                  gorm.Expr("version + 1"),
	}).Error
}

func (r *ussdPinRepository) SetPin(ctx context.Context, id, hash string, reset bool) error {
	updates := map[string]any{
		"pin_hash":                  hash,
		"verification_id":           "",
		"verification_contact_id":   "",
		"verification_requested_at": nil,
		colModifiedAt:               time.Now().UTC(),
		colVersion:                  gorm.Expr("version + 1"),
	}
	if reset {
		updates["reset_at"] = time.Now().UTC()
	} else {
		updates["failed_attempts"] = 0
		updates["locked_until"] = nil
	}
	return r.Pool().DB(ctx, false).Table(tableUssdPins).Where("id = ?", id).Updates(updates).Error
}

func (r *ussdPinRepository) RecordFailure(
	ctx context.Context,
	id string,
	maxAttempts int32,
	lockUntil time.Time,
) (int32, error) {
	var attempts int32
	err := r.Pool().DB(ctx, false).Raw(
		`UPDATE seed_ussd_pins
		    SET failed_attempts = failed_attempts + 1,
		        locked_until = CASE WHEN failed_attempts + 1 >= ? THEN ?::timestamptz ELSE locked_until END,
		        modified_at = now(),
		        version = version + 1
		  WHERE id = ?
		RETURNING failed_attempts`, maxAttempts, lockUntil.UTC(), id,
	).Scan(&attempts).Error
	return attempts, err
}

func (r *ussdPinRepository) ClearFailures(ctx context.Context, id string) error {
	return r.Pool().DB(ctx, false).Table(tableUssdPins).
		Where("id = ? AND (failed_attempts <> 0 OR locked_until IS NOT NULL)", id).
		Updates(map[string]any{
			"failed_attempts": 0,
			"locked_until":    nil,
			colModifiedAt:     time.Now().UTC(),
			colVersion:        gorm.Expr("version + 1"),
		}).Error
}
