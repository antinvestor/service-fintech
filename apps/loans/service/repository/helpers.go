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

package repository

import (
	"context"

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
)

type entityRepository[P data.BaseModelI] struct {
	datastore.BaseRepository[P]
	newEntity func() P
}

func newEntityRepository[P data.BaseModelI](
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
	newEntity func() P,
) entityRepository[P] {
	return entityRepository[P]{
		BaseRepository: datastore.NewBaseRepository[P](ctx, dbPool, workMan, newEntity),
		newEntity:      newEntity,
	}
}

func (repo entityRepository[P]) findOneByField(
	ctx context.Context,
	filter string,
	value any,
) (P, error) {
	entity := repo.newEntity()
	if err := repo.Pool().DB(ctx, true).First(entity, filter, value).Error; err != nil {
		var zero P
		return zero, err
	}

	return entity, nil
}
