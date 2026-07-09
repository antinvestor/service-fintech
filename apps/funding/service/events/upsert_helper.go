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
	"errors"
	"fmt"

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/util"
	"gorm.io/gorm"
)

// upsertByID is a generic helper that executes the common GetByID-based upsert
// logic shared by all funding event handlers, eliminating duplicated Execute() methods.
func upsertByID[T data.BaseModelI](
	ctx context.Context,
	repo datastore.BaseRepository[T],
	entity T,
	eventName string,
) error {
	log := util.Log(ctx)

	existing, err := repo.GetByID(ctx, entity.GetID())
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		log.WithError(err).Error(fmt.Sprintf("%s -- failed to check existing record", eventName))
		return err
	}

	if err == nil && existing.GetID() != "" {
		_, err = repo.Update(ctx, entity)
		if err != nil {
			log.WithError(err).Error(fmt.Sprintf("%s -- failed to update record", eventName))
			return err
		}
		return nil
	}

	err = repo.Create(ctx, entity)
	if err != nil {
		log.WithError(err).Error(fmt.Sprintf("%s -- failed to create record", eventName))
		return err
	}
	return nil
}

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
	return upsertByID(ctx, e.repo, entity, e.name)
}
