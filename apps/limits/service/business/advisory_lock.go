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
	"hash/fnv"
	"sort"
	"strings"

	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// LockKeys derives stable int64 advisory-lock keys from a set of subject
// filters. Keys are sorted so concurrent transactions acquire them in the
// same order, eliminating deadlock potential.
func LockKeys(action models.Action, currency string, subjects []repository.SubjectFilter) []int64 {
	keys := make([]int64, 0, len(subjects))
	for _, s := range subjects {
		h := fnv.New64a()
		_, _ = h.Write([]byte(strings.Join([]string{string(s.Type), s.ID, string(action), currency}, "|")))
		//nolint:gosec // intentional wraparound: hash bits reused as advisory-lock key
		keys = append(keys, int64(h.Sum64()))
	}
	sort.Slice(keys, func(i, j int) bool { return keys[i] < keys[j] })
	return keys
}

// Reaper advisory-lock keys. Each periodic job takes its own session lock so
// only one replica runs a pass at a time; without this every replica emits a
// duplicate audit row and event for the same reaped entity.
const (
	// LockKeyReservationReaper guards the reservation TTL reaper.
	LockKeyReservationReaper int64 = 6_120_260_001
	// LockKeyApprovalReaper guards the approval expiry reaper.
	LockKeyApprovalReaper int64 = 6_120_260_002
)

// WithLeaderLock runs fn only if this process wins the named advisory lock.
// A replica that does not win returns nil without running fn — the winner's
// pass covers the work for the whole cluster.
func WithLeaderLock(ctx context.Context, p pool.Pool, key int64, fn func(context.Context) error) error {
	if p == nil {
		return fn(ctx)
	}
	db := p.DB(ctx, false)
	var acquired bool
	if err := db.Raw("SELECT pg_try_advisory_lock(?)", key).Scan(&acquired).Error; err != nil {
		return err
	}
	if !acquired {
		return nil
	}
	defer func() {
		if err := db.Exec("SELECT pg_advisory_unlock(?)", key).Error; err != nil {
			util.Log(ctx).WithError(err).With("lock_key", key).Error("could not release reaper advisory lock")
		}
	}()
	return fn(ctx)
}

// AcquireAdvisoryLocks calls pg_advisory_xact_lock for each key in order.
// Must be called inside a transaction; locks release automatically at
// COMMIT/ROLLBACK.
func AcquireAdvisoryLocks(ctx context.Context, p pool.Pool, keys []int64) error {
	db := p.DB(ctx, false)
	for _, k := range keys {
		if err := db.Exec("SELECT pg_advisory_xact_lock(?)", k).Error; err != nil {
			return err
		}
	}
	return nil
}
