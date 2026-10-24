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

	"github.com/antinvestor/service-fintech/pkg/upsert"
)

// eventHandler is a generic event handler that implements events.EventI for any
// model type, eliminating boilerplate duplication across individual event files.
type eventHandler[T data.BaseModelI] struct {
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
	return upsert.ByID(ctx, e.repo, entity)
}
