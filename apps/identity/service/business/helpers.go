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
	"reflect"
	"strconv"
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/frame/v2/workerpool"
)

// workerpoolConsumeStream wraps workerpool.ConsumeResultStream for use in business methods.
func workerpoolConsumeStream[T any](
	ctx context.Context,
	pipe workerpool.JobResultPipe[[]T],
	consumer func(batch []T) error,
) error {
	return workerpool.ConsumeResultStream(ctx, pipe, func(res []T) error {
		return consumer(res)
	})
}

// searchableTSQuery is the GORM map-key predicate used for full-text search
// against the generated "searchable" tsvector column.
const searchableTSQuery = "searchable @@ websearch_to_tsquery( 'english', ?) "

const (
	// defaultSearchLimit is applied when a cursor omits a limit.
	defaultSearchLimit = 50
	// maxSearchLimit bounds how many rows a single search may stream so a
	// caller cannot ask for the whole table.
	maxSearchLimit = 200
)

// cursorSearchOptions turns a page cursor into search options. The limit is
// clamped to [1, maxSearchLimit] and a non-numeric page token is rejected
// rather than silently resolving to page one.
func cursorSearchOptions(cursor *commonv1.PageCursor) ([]data.SearchOption, error) {
	if cursor == nil {
		return nil, nil
	}

	offset := 0
	if page := strings.TrimSpace(cursor.GetPage()); page != "" {
		parsed, err := strconv.Atoi(page)
		if err != nil || parsed < 0 {
			return nil, ErrInvalidPageToken
		}
		offset = parsed
	}

	return []data.SearchOption{
		data.WithSearchOffset(offset),
		data.WithSearchLimit(clampSearchLimit(cursor.GetLimit())),
	}, nil
}

// clampSearchLimit bounds a caller supplied page limit. Zero or negative means
// "unset" and falls back to the default.
func clampSearchLimit(limit int32) int {
	if limit <= 0 {
		return defaultSearchLimit
	}
	if limit > maxSearchLimit {
		return maxSearchLimit
	}
	return int(limit)
}

// actorFromClaims resolves the identity of the caller from the request claims.
// Every maker/checker attribution must come from here, never from a request
// field a caller controls.
func actorFromClaims(ctx context.Context) string {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return ""
	}
	if profileID := claims.GetProfileID(); profileID != "" {
		return profileID
	}
	return claims.Subject
}

// carryStoredTenancy keeps an edit from rewriting the row's tenancy and
// creation attribution.
//
// Save paths rebuild the model from the API object, and the FromAPI
// constructors call GenID, which stamps tenant, partition, access and
// created_by from the *editor's* claims rather than the row's owner. Frame's
// repository omits the tenancy columns on update, so the row does not move
// partition, but created_by is not immutable and was being overwritten with
// whoever last edited the row — and the payload's wrong tenancy was one missed
// Omit away from re-homing it. Loading the stored row and carrying its values
// forward makes an edit attribution-neutral, and keeps the payload honest for
// any write path that does not omit those columns.
//
// A model whose ID has no stored row is a create and is left untouched, so the
// same call is safe on both branches of a save.
func carryStoredTenancy[T data.BaseModelI](
	ctx context.Context,
	repo datastore.BaseRepository[T],
	model T,
) error {
	target := embeddedBaseModel(model)
	if repo == nil || target == nil || target.ID == "" {
		return nil
	}

	stored, err := repo.GetByID(ctx, target.ID)
	if err != nil {
		if data.ErrorIsNoRows(err) {
			return nil
		}
		return err
	}

	applyStoredTenancy(model, stored)
	return nil
}

// applyStoredTenancy copies tenancy and creation attribution from an already
// loaded stored row onto the model rebuilt from the API. Save paths that load
// the row for other reasons use this directly rather than reading it twice.
func applyStoredTenancy(target, stored any) {
	dst := embeddedBaseModel(target)
	src := embeddedBaseModel(stored)
	if dst == nil || src == nil {
		return
	}
	dst.TenantID = src.TenantID
	dst.PartitionID = src.PartitionID
	dst.AccessID = src.AccessID
	dst.CreatedBy = src.CreatedBy
	dst.CreatedAt = src.CreatedAt
}

// embeddedBaseModel reaches the data.BaseModel every identity model embeds.
// The models share no interface exposing it, and adding setters to each of the
// twenty of them buys nothing over one reflective accessor.
func embeddedBaseModel(entity any) *data.BaseModel {
	value := reflect.ValueOf(entity)
	if value.Kind() != reflect.Pointer || value.IsNil() {
		return nil
	}
	field := value.Elem().FieldByName("BaseModel")
	if !field.IsValid() || !field.CanAddr() {
		return nil
	}
	base, _ := field.Addr().Interface().(*data.BaseModel)
	return base
}
