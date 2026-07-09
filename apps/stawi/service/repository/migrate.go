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

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
)

// Migrate runs database migrations for all group models.
func Migrate(ctx context.Context, dbManager datastore.Manager, migrationsDirPath string) error {
	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	return migratePool(ctx, dbPool, migrationsDirPath)
}

func migratePool(ctx context.Context, dbPool pool.Pool, migrationsDirPath string) error {
	return dbPool.Migrate(ctx, migrationsDirPath,
		&models.Tenure{},
		&models.Period{},
		&models.Motion{},
		&models.MotionVote{},
		&models.Infraction{},
		&models.GroupWarning{},
		&models.MemberScore{},
		&models.Occurrence{},
		&models.RequestLog{},
		&models.LoanWindow{},
		&models.LoanOffer{},
	)
}
