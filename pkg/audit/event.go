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

// Package audit provides an append-only, per-service audit log for
// tracing every important state change in the fintech platform.
//
// The core idea is that anything that moves money, transitions a workflow
// state machine, or mutates a credit/limit boundary gets written to
// audit_events with enough context to reconstruct exactly what happened
// without having to replay the event bus or inspect git history:
//
//   - who did it (actor id, actor type)
//   - what entity it was done against (type, id, scope)
//   - what action was performed (domain verb: "disbursement.issued",
//     "repayment.applied", "savings.deposit.settled", etc.)
//   - what the state looked like before and after (optional JSON blobs)
//   - why it was done (human-readable reason)
//   - when it happened (CreatedAt)
//   - any metadata the caller thinks is useful later
//
// Rows are strictly append-only: there is no Update path and any caller
// that tries to mutate a row goes through Create with a new id. The
// event handler silently succeeds on duplicate-key so replays converge.
//
// Each service migrates its own audit_events table so the log is scoped
// to the service that wrote it; this keeps cross-service reads explicit
// rather than accidental, and it matches how the rest of the fintech
// platform partitions its storage.
package audit

import (
	"time"

	"github.com/pitabwire/frame/v2/data"
)

// Event is the append-only record written for every significant state
// transition. It embeds data.BaseModel so it picks up the usual
// tenancy/partition fields and timestamps.
type Event struct {
	data.BaseModel

	// EntityType identifies the kind of thing the event is about
	// ("loan_account", "transfer_order", "savings_deposit", etc.).
	EntityType string `gorm:"type:varchar(64);index:idx_ae_entity"`

	// EntityID is the id of the thing the event is about. For money
	// movements it is typically the TransferOrder id; for workflow
	// transitions it is the loan or savings account id.
	EntityID string `gorm:"type:varchar(64);index:idx_ae_entity"`

	// Action is the domain verb describing what happened. Conventionally
	// namespaced with the entity type, e.g. "loan.disbursed",
	// "repayment.applied", "savings.withdrawal.approved".
	Action string `gorm:"type:varchar(100);index:idx_ae_action"`

	// ActorID identifies the principal that caused the change. An empty
	// value means the platform itself (a scheduled job, a webhook, etc.).
	ActorID string `gorm:"type:varchar(64);index:idx_ae_actor"`

	// ActorType categorises the actor: "user", "agent", "system", "job".
	ActorType string `gorm:"type:varchar(32)"`

	// Reason is a short free-text description suitable for display to an
	// auditor. Required for anything that could surprise a reader later.
	Reason string `gorm:"type:text"`

	// Before and After are optional JSON snapshots captured at the moment
	// of the transition. Use them for state-machine changes (status
	// before → status after) or for balance mutations (prev balance →
	// new balance). Omit for simple creates.
	Before data.JSONMap
	After  data.JSONMap

	// Metadata is a flexible bag for correlation ids, request ids,
	// amounts, tranche numbers, etc. Anything that would help a future
	// reader understand context without needing to inspect the event
	// bus or external systems.
	Metadata data.JSONMap

	// OccurredAt captures the caller's notion of when the transition
	// happened, which is usually the same as CreatedAt but can differ
	// when events are replayed or back-dated from upstream systems.
	OccurredAt *time.Time `gorm:"index:idx_ae_occurred"`
}

// TableName is per-service. Services migrate their own audit_events
// table so the audit stream is scoped to the writer.
func (Event) TableName() string { return "audit_events" }
