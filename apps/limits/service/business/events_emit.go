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

// Package business holds the limits service domain logic.
//
// events_emit.go provides a nil-safe helper used by all businesses to
// emit Frame events without duplicating the nil-check and error-log pattern.
package business

import (
	"context"

	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
)

// emitEvent emits a named event via the Frame events manager. If em is nil
// (e.g. in tests that do not wire an events manager) the call is a no-op.
// Emission errors are logged at Warn level and never propagated to callers —
// failing to emit a cache-invalidation or approval-lifecycle event must not
// roll back the business transaction that already committed.
func emitEvent(ctx context.Context, em fevents.Manager, name string, payload any) {
	if em == nil {
		return
	}
	if err := em.Emit(ctx, name, payload); err != nil {
		util.Log(ctx).WithError(err).With("event", name).
			Warn("limits: event emit failed")
	}
}
