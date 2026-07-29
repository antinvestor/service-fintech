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

	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
)

// Migrate runs GORM auto-migration for every seed model plus the shared
// audit_events table. Seed shares the platform postgres instance with
// the other fintech services, so the migration is additive and cannot
// conflict with existing tables.
func Migrate(ctx context.Context, dbManager datastore.Manager, migrationPath string) error {
	dbPool, err := dbmigrate.Pool(ctx, dbManager)
	if err != nil {
		return err
	}

	return dbManager.Migrate(ctx, dbPool, migrationPath,
		&models.CreditProfile{},
		&models.CreditTierConfig{},
		&models.LoanRequest{},
		&audit.Event{},
	)
}
