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

package dbmigrate

import (
	"context"
	"errors"
	"fmt"
	"hash/fnv"

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/util"
)

// lockKeyPrefix namespaces the advisory key so it cannot collide with other
// advisory locks a service takes (for example the limits reapers).
const lockKeyPrefix = "service-fintech:migrate:"

// LockKey derives the fixed 64-bit advisory lock key for a service. Two
// migrate Jobs of the same service always compute the same key; distinct
// services sharing one database do not block each other.
func LockKey(serviceName string) int64 {
	h := fnv.New64a()
	_, _ = h.Write([]byte(lockKeyPrefix + serviceName))
	return int64(h.Sum64()) //nolint:gosec // wraparound into the signed range is intended; pg keys are bigint
}

// WithLock runs fn while holding the service's Postgres session advisory
// lock. The lock lives on a connection pinned for the duration of fn, so
// DDL executed by fn on other pool connections is serialised against every
// other holder: a second migrate Job blocks until the first releases.
func WithLock(ctx context.Context, dbPool pool.Pool, serviceName string, fn func(context.Context) error) (err error) {
	if dbPool == nil {
		return ErrPoolNotInitialised
	}
	sqlDB, err := dbPool.DB(ctx, false).DB()
	if err != nil {
		return fmt.Errorf("migration lock: acquire sql db: %w", err)
	}
	conn, err := sqlDB.Conn(ctx)
	if err != nil {
		return fmt.Errorf("migration lock: pin connection: %w", err)
	}
	defer util.CloseAndLogOnError(ctx, conn, "migration lock: release connection")

	key := LockKey(serviceName)
	log := util.Log(ctx).With("service", serviceName, "lock_key", key)
	log.Info("migration lock: waiting")
	if _, err = conn.ExecContext(ctx, "SELECT pg_advisory_lock($1)", key); err != nil {
		return fmt.Errorf("migration lock: acquire: %w", err)
	}
	log.Info("migration lock: acquired")
	defer func() {
		// Unlock on a background-derived context: a cancelled ctx must not
		// leave the lock held until the connection is torn down.
		_, unlockErr := conn.ExecContext(context.WithoutCancel(ctx), "SELECT pg_advisory_unlock($1)", key)
		if unlockErr != nil {
			err = errors.Join(err, fmt.Errorf("migration lock: release: %w", unlockErr))
		}
	}()

	return fn(ctx)
}

// Locked resolves the migration pool the way Pool does and runs fn under
// WithLock. It is the one call a setup plan wraps around its migrate step:
//
//	svc.Setup().RegisterFunc(setup.NameMigrate, func(ctx context.Context) error {
//		return dbmigrate.Locked(ctx, svc.DatastoreManager(), cfg.Name(), func(ctx context.Context) error {
//			return repository.Migrate(ctx, svc.DatastoreManager(), cfg.GetDatabaseMigrationPath())
//		})
//	})
func Locked(
	ctx context.Context, dbManager datastore.Manager, serviceName string, fn func(context.Context) error,
) error {
	dbPool, err := Pool(ctx, dbManager)
	if err != nil {
		return err
	}
	return WithLock(ctx, dbPool, serviceName, fn)
}
