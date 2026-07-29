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
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
)

// Migrate runs database migrations for all funding models.
func Migrate(ctx context.Context, dbManager datastore.Manager, migrationsDirPath string) error {
	dbPool, err := dbmigrate.Pool(ctx, dbManager)
	if err != nil {
		return err
	}
	return migratePool(ctx, dbPool, migrationsDirPath)
}

func migratePool(ctx context.Context, dbPool pool.Pool, migrationsDirPath string) error {
	if db := dbPool.DB(ctx, false); db != nil {
		migrator := db.Migrator()
		if migrator.HasTable("loan_fundings") && migrator.HasColumn(&models.LoanFunding{}, "loan_offer_id") &&
			!migrator.HasColumn(&models.LoanFunding{}, "loan_request_id") {
			util.Log(ctx).Info("preMigrate -- renaming loan_fundings.loan_offer_id to loan_request_id")
			if err := db.Exec(
				"ALTER TABLE loan_fundings RENAME COLUMN loan_offer_id TO loan_request_id",
			).Error; err != nil {
				return err
			}
		}
	}

	return dbPool.Migrate(ctx, migrationsDirPath,
		&models.LoanFunding{},
		&models.FundingAllocation{},
		&models.InvestorAccount{},
		&models.FundingTranche{},
		&audit.Event{},
	)
}
