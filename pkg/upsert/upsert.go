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

// Package upsert persists event payloads that may describe either a new row
// or a changed existing one.
//
// Frame's repository Update runs `WHERE id = ? AND version = ?` using the
// version carried by the entity. Payloads built from API objects carry
// version 0, so a bare Update silently matches nothing. ByID resolves the
// stored version first, so the write lands, and it reports when it did not.
package upsert

import (
	"context"
	"errors"
	"fmt"
	"reflect"

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/util"
)

// ErrNoRowsAffected is returned when an update matched no row even after
// the stored version was applied. The row was deleted or changed between
// the read and the write; the event is safe to retry.
var ErrNoRowsAffected = errors.New("upsert: update affected no rows")

// ByID inserts entity when no row with its ID exists, otherwise updates the
// existing row. The stored version always wins over the payload version, so
// the caller's fields overwrite what is in the database (last writer wins).
//
// A duplicate-key failure on insert (a concurrent insert of the same ID, or
// a unique index other than the primary key) is resolved by re-reading and
// updating; it is never swallowed.
func ByID[T data.BaseModelI](ctx context.Context, repo datastore.BaseRepository[T], entity T) error {
	if entity.GetID() == "" {
		return errors.New("upsert: entity ID is required")
	}

	existing, err := repo.GetByID(ctx, entity.GetID())
	switch {
	case err == nil:
		return update(ctx, repo, entity, existing.GetVersion())
	case data.ErrorIsNoRows(err):
		// fall through to insert
	default:
		return fmt.Errorf("upsert: load %s: %w", entity.GetID(), err)
	}

	if err = repo.Create(ctx, entity); err == nil {
		return nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return fmt.Errorf("upsert: create %s: %w", entity.GetID(), err)
	}

	// Lost a race with a concurrent insert of the same row.
	existing, getErr := repo.GetByID(ctx, entity.GetID())
	if getErr != nil {
		// The duplicate is on a secondary unique index, not the primary key.
		// Nothing to update: surface the constraint violation.
		return fmt.Errorf("upsert: create %s: %w", entity.GetID(), err)
	}
	return update(ctx, repo, entity, existing.GetVersion())
}

func update[T data.BaseModelI](
	ctx context.Context,
	repo datastore.BaseRepository[T],
	entity T,
	storedVersion uint,
) error {
	if v := entity.GetVersion(); v != 0 && v != storedVersion {
		util.Log(ctx).
			WithField("id", entity.GetID()).
			WithField("payload_version", v).
			WithField("stored_version", storedVersion).
			Warn("upsert: payload version is stale, applying on top of stored row")
	}
	if err := setVersion(entity, storedVersion); err != nil {
		return err
	}

	rows, err := repo.Update(ctx, entity)
	if err != nil {
		return fmt.Errorf("upsert: update %s: %w", entity.GetID(), err)
	}
	if rows == 0 {
		return fmt.Errorf("%w: %s", ErrNoRowsAffected, entity.GetID())
	}
	return nil
}

type versionSetter interface {
	SetVersion(v uint)
}

// setVersion writes v into the entity's version field, through SetVersion
// when the model provides it and otherwise through the embedded BaseModel.
func setVersion(entity any, v uint) error {
	if s, ok := entity.(versionSetter); ok {
		s.SetVersion(v)
		return nil
	}

	rv := reflect.ValueOf(entity)
	if rv.Kind() != reflect.Pointer || rv.IsNil() {
		return fmt.Errorf("upsert: entity %T must be a non-nil pointer", entity)
	}
	base := rv.Elem().FieldByName("BaseModel")
	if !base.IsValid() || base.Type() != reflect.TypeFor[data.BaseModel]() {
		return fmt.Errorf("upsert: entity %T does not embed data.BaseModel", entity)
	}
	base.FieldByName("Version").SetUint(uint64(v))
	return nil
}
