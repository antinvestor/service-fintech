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

	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/tenancy"
	"gorm.io/gorm"
)

// ReaperOption tunes a reaper at construction time.
type ReaperOption func(*reaperConfig)

type reaperConfig struct {
	dbPool pool.Pool
}

// WithReaperPool gives the reaper a transaction source so each row's state
// change, the release of any linked reservation, and the audit record commit
// together. Without a pool the reaper falls back to per-statement writes.
func WithReaperPool(p pool.Pool) ReaperOption {
	return func(c *reaperConfig) { c.dbPool = p }
}

func applyReaperOptions(opts []ReaperOption) reaperConfig {
	var c reaperConfig
	for _, o := range opts {
		if o != nil {
			o(&c)
		}
	}
	return c
}

// runInTx executes fn in one transaction. Reapers act across every tenant, so
// tenancy enforcement is skipped on the transaction: the rows they touch were
// selected cross-tenant and the audit records carry tenancy from their parent.
func (c reaperConfig) runInTx(ctx context.Context, fn func(tx *gorm.DB) error) error {
	if c.dbPool == nil {
		return fn(nil)
	}
	return c.dbPool.DB(tenancy.WithSkipEnforcement(ctx), false).Transaction(fn)
}
