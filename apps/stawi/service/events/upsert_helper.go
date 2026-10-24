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

package events

import (
	"context"
	"fmt"

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/pkg/upsert"
)

// versionedModel extends data.BaseModelI with a settable Version field.
type versionedModel interface {
	data.BaseModelI
	SetVersion(v uint)
}

// upsertEntity delegates to the shared versioned upsert. It copies the stored
// version so updates land, fails when no row was affected, and never swallows
// a duplicate-key error.
func upsertEntity[T data.BaseModelI](
	ctx context.Context,
	repo datastore.BaseRepository[T],
	entity T,
	eventName string,
) error {
	if err := upsert.ByID(ctx, repo, entity); err != nil {
		util.Log(ctx).WithError(err).Error(fmt.Sprintf("%s -- could not persist record", eventName))
		return err
	}
	return nil
}

// eventHandler is a generic event handler that implements events.EventI for any
// versioned model type, eliminating boilerplate duplication across individual event files.
type eventHandler[T versionedModel] struct {
	name     string
	factory  func() T
	validate func(context.Context, T) error
	repo     datastore.BaseRepository[T]
}

func (e *eventHandler[T]) Name() string {
	return e.name
}

func (e *eventHandler[T]) PayloadType() any {
	return e.factory()
}

func (e *eventHandler[T]) Validate(ctx context.Context, payload any) error {
	entity, ok := payload.(T)
	if !ok {
		return fmt.Errorf("invalid payload type for %s", e.name)
	}
	return e.validate(ctx, entity)
}

func (e *eventHandler[T]) Execute(ctx context.Context, payload any) error {
	entity, ok := payload.(T)
	if !ok {
		return fmt.Errorf("invalid payload type for %s", e.name)
	}
	return upsertEntity(ctx, e.repo, entity, e.name)
}

// baseEventHandler is a generic event handler for models that use
// data.BaseModelI without a settable Version.
type baseEventHandler[T data.BaseModelI] struct {
	name     string
	factory  func() T
	validate func(context.Context, T) error
	repo     datastore.BaseRepository[T]
}

func (e *baseEventHandler[T]) Name() string {
	return e.name
}

func (e *baseEventHandler[T]) PayloadType() any {
	return e.factory()
}

func (e *baseEventHandler[T]) Validate(ctx context.Context, payload any) error {
	entity, ok := payload.(T)
	if !ok {
		return fmt.Errorf("invalid payload type for %s", e.name)
	}
	return e.validate(ctx, entity)
}

func (e *baseEventHandler[T]) Execute(ctx context.Context, payload any) error {
	entity, ok := payload.(T)
	if !ok {
		return fmt.Errorf("invalid payload type for %s", e.name)
	}
	return upsertEntity(ctx, e.repo, entity, e.name)
}
