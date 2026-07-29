// Package dbmigrate provides shared helpers for Frame setup-plan migrations.
package dbmigrate

import (
	"context"
	"errors"

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
)

// ErrPoolNotInitialised is returned when neither the migration nor default
// datastore pool is available (usually missing DATABASE_URL).
var ErrPoolNotInitialised = errors.New("datastore pool is not initialised")

// Pool prefers Frame's migration pool (opened when DO_SETUP / setup mode is
// active) and falls back to the default pool. This matches Frame's setup-job
// contract: apps must not require DefaultMigrationPoolName exclusively.
func Pool(ctx context.Context, dbManager datastore.Manager) (pool.Pool, error) {
	if dbManager == nil {
		return nil, ErrPoolNotInitialised
	}
	dbPool := dbManager.GetPool(ctx, datastore.DefaultMigrationPoolName)
	if dbPool == nil {
		dbPool = dbManager.GetPool(ctx, datastore.DefaultPoolName)
	}
	if dbPool == nil {
		return nil, ErrPoolNotInitialised
	}
	return dbPool, nil
}
