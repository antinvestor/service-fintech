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

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
	"github.com/pitabwire/util"
)

// Repository is the minimal persistence surface needed by the save-event
// handler. Each service constructs one via NewRepository and registers
// the EventSave handler below.
type Repository interface {
	datastore.BaseRepository[*Event]
}

// NewRepository builds a datastore.BaseRepository for the Event model.
// Call this from a service's main.go wiring and feed the result into
// NewEventSave.
func NewRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) Repository {
	return datastore.NewBaseRepository[*Event](
		ctx, dbPool, workMan, func() *Event { return &Event{} },
	)
}

// EventSave is the frame event handler that persists audit events. It is
// strictly append-only: a duplicate-key error is treated as idempotent
// success (the handler has already run this event) and there is no
// update path. Any other persistence error returns from Execute so the
// frame retry pipeline picks the event up again.
type EventSave struct {
	repo Repository
}

// NewEventSave wires a repository into a handler ready for registration
// via frame.WithRegisterEvents.
func NewEventSave(_ context.Context, repo Repository) *EventSave {
	return &EventSave{repo: repo}
}

// Name identifies the event topic. Must match the constant used by the
// Writer so the events pipeline lines up.
func (e *EventSave) Name() string { return EventSaveEvent }

// PayloadType lets the frame pipeline reflect on the concrete struct
// behind a generic payload.
func (e *EventSave) PayloadType() any { return &Event{} }

// Validate ensures the incoming payload has the fields required for
// append-only persistence. Validation errors are final — the event
// pipeline will not retry malformed payloads.
func (e *EventSave) Validate(_ context.Context, payload any) error {
	ev, ok := payload.(*Event)
	if !ok {
		return errors.New("payload is not of type audit.Event")
	}
	if ev.GetID() == "" {
		return errors.New("audit event id should already have been set")
	}
	if ev.EntityType == "" || ev.Action == "" {
		return errors.New("audit event requires entity_type and action")
	}
	return nil
}

// Execute persists the audit event. Append-only: on duplicate-key we
// return success (the handler has already run); on any other error we
// return so the pipeline retries.
func (e *EventSave) Execute(ctx context.Context, payload any) error {
	ev, ok := payload.(*Event)
	if !ok {
		return errors.New("payload is not of type audit.Event")
	}

	logger := util.Log(ctx).WithFields(map[string]any{
		"type":        e.Name(),
		"audit_id":    ev.GetID(),
		"entity_type": ev.EntityType,
		"entity_id":   ev.EntityID,
		"action":      ev.Action,
	})
	defer logger.Release()

	if err := e.repo.Create(ctx, ev); err != nil {
		if data.ErrorIsDuplicateKey(err) {
			return nil
		}
		logger.WithError(err).Error("could not persist audit event")
		return err
	}
	return nil
}
