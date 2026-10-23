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

package audit

import (
	"context"
	"errors"
	"time"

	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/pkg/constants"
)

// EventSaveEvent is the name of the frame event used to dispatch audit
// records to the per-service persistence handler. Services that use the
// audit package must register their own EventSave handler via
// RegisterSaveEvent below.
const EventSaveEvent = "audit_event.save"

// Writer is a small wrapper around the frame events manager that knows
// how to build and emit Event records. Every domain business layer that
// needs to record state transitions takes a *Writer instead of taking a
// raw events.Manager, so the call sites read declaratively:
//
//	writer.Record(ctx, audit.Record{
//	    EntityType: "loan_account",
//	    EntityID:   loan.GetID(),
//	    Action:     "loan.status_changed",
//	    Reason:     "disbursement completed",
//	    Before:     data.JSONMap{"status": oldStatus},
//	    After:      data.JSONMap{"status": newStatus},
//	})
//
// If the emit fails the error surfaces so callers can choose to retry,
// but in practice audit-recording errors should not block a money
// movement from completing: prefer logging-and-continuing over failing
// the user-visible action because the audit log is lagged.
type Writer struct {
	eventsMan fevents.Manager
}

// ErrAuditDisabled is returned when a Writer has no events manager. An
// audit trail that silently does nothing is indistinguishable from one
// that works, so a disabled writer reports failure rather than success.
var ErrAuditDisabled = errors.New("audit writer has no events manager")

// ErrAuditNoPartition is returned when a record cannot be attributed to a
// partition. Audit rows without tenancy scope are unreadable by the very
// queries (per-partition regulatory extracts) they exist to serve.
var ErrAuditNoPartition = errors.New("audit record requires a partition")

// NewWriter constructs a Writer that dispatches via the supplied frame
// events manager. A nil manager yields a writer whose Record calls fail
// with ErrAuditDisabled.
func NewWriter(eventsMan fevents.Manager) *Writer {
	return &Writer{eventsMan: eventsMan}
}

// Record is the shape callers build to describe a transition. All
// fields except EntityType, EntityID and Action are optional; the
// writer fills in ids, timestamps, and tenancy info.
type Record struct {
	EntityType string
	EntityID   string
	Action     string
	ActorID    string
	ActorType  string
	Reason     string
	Before     data.JSONMap
	After      data.JSONMap
	Metadata   data.JSONMap
	OccurredAt *time.Time
	// Parent is an optional reference to another model whose partition
	// info should propagate onto the audit row. Use this when the
	// transition happens "on behalf of" another entity so the audit
	// log inherits the same tenancy scope.
	Parent *data.BaseModel
}

// Record emits an audit event via the frame events pipeline. Callers
// that cannot reasonably retry on failure should log-and-continue; the
// returned error is advisory for callers that can.
func (w *Writer) Record(ctx context.Context, r Record) error {
	if w == nil || w.eventsMan == nil {
		return ErrAuditDisabled
	}

	ev, err := w.build(ctx, r)
	if err != nil {
		return err
	}

	return w.eventsMan.Emit(ctx, EventSaveEvent, ev)
}

// build validates a Record and materialises the Event that will be
// persisted, filling in the actor and tenancy scope that the call site
// did not supply. Both write paths go through it so an event emitted
// asynchronously and one written inside a transaction carry identical
// attribution.
func (w *Writer) build(ctx context.Context, r Record) (*Event, error) {
	if r.EntityType == "" || r.Action == "" {
		return nil, errors.New("audit record requires entity_type and action")
	}

	trail := constants.AuditTrailFromContext(ctx)

	actorID := r.ActorID
	actorType := r.ActorType
	if actorID == "" {
		actorID = trail.ProfileID
		if actorType == "" && actorID != "" {
			actorType = actorTypeFromTrail(trail)
		}
	}

	now := time.Now().UTC()
	occurred := r.OccurredAt
	if occurred == nil {
		occurred = &now
	}

	ev := &Event{
		EntityType: r.EntityType,
		EntityID:   r.EntityID,
		Action:     r.Action,
		ActorID:    actorID,
		ActorType:  actorType,
		Reason:     r.Reason,
		Before:     r.Before,
		After:      r.After,
		Metadata:   r.Metadata,
		OccurredAt: occurred,
	}

	// GenID copies partition/tenant from the request claims when present;
	// Parent supplies them for records written outside a request context.
	ev.GenID(ctx)
	if r.Parent != nil {
		ev.CopyPartitionInfo(r.Parent)
	}
	if ev.PartitionID == "" {
		return nil, ErrAuditNoPartition
	}

	return ev, nil
}

// actorTypeFromTrail labels the actor so downstream readers can tell a
// human action from a service-to-service one without joining to identity.
func actorTypeFromTrail(trail constants.AuditTrail) string {
	if trail.ServiceName != "" && trail.ContactID == "" {
		return "service"
	}
	return "user"
}

// RecordTx writes the audit row directly inside the caller's DB transaction.
// Unlike Record (which emits via the events bus post-commit), RecordTx
// persists the audit row in the same tx as the state change, so a process
// crash between tx.Commit and async emission can no longer drop the
// regulatory record. Use this for any audit verb that must not be lost.
func (w *Writer) RecordTx(ctx context.Context, tx *gorm.DB, r Record) error {
	if tx == nil {
		return errors.New("RecordTx requires non-nil tx")
	}

	ev, err := w.build(ctx, r)
	if err != nil {
		return err
	}

	return tx.Create(ev).Error
}

// RecordOrLog is the ergonomic helper for call sites that cannot fail
// the primary action on an audit write failure. The failure is always
// logged at Error level — a dropped audit row is a regulatory gap, not a
// warning — and then handed to logFailure for any call-site context.
// Use this at the end of a successful money movement where the write
// has already happened and we only want to capture the historical fact.
func (w *Writer) RecordOrLog(
	ctx context.Context,
	r Record,
	logFailure func(error),
) {
	err := w.Record(ctx, r)
	if err == nil {
		return
	}

	logger := util.Log(ctx).WithFields(map[string]any{
		"entity_type": r.EntityType,
		"entity_id":   r.EntityID,
		"action":      r.Action,
	})
	defer logger.Release()
	logger.WithError(err).Error("audit record dropped")

	if logFailure != nil {
		logFailure(err)
	}
}
