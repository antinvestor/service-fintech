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

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
)

type SavingsAccountRepository interface {
	datastore.BaseRepository[*models.SavingsAccount]
}

type savingsAccountRepository struct {
	datastore.BaseRepository[*models.SavingsAccount]
}

func NewSavingsAccountRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) SavingsAccountRepository {
	return &savingsAccountRepository{
		BaseRepository: datastore.NewBaseRepository[*models.SavingsAccount](
			ctx, dbPool, workMan, func() *models.SavingsAccount { return &models.SavingsAccount{} },
		),
	}
}
