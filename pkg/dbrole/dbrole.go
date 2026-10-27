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

// Package dbrole gives each service a runtime database role that row-level
// security applies to.
//
// Frame isolates tenants with Postgres row-level security alone. The database
// owner the setup Job migrates with bypasses it (Neon's owner role has
// BYPASSRLS), so a service connected as the owner reads every tenant's rows.
// The setup Job therefore keeps the owner and also maintains a runtime role
// without BYPASSRLS, which the running service connects as.
package dbrole

import (
	"context"
	"errors"
	"fmt"
	"os"
	"regexp"
	"strings"

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/util"
	"gorm.io/gorm"
	gormlogger "gorm.io/gorm/logger"

	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
)

// StepName is the setup step that maintains the runtime role.
const StepName = "runtime_role"

// Environment the setup Job and the running service read.
const (
	envRole        = "DATABASE_RUNTIME_ROLE"
	envPassword    = "DATABASE_RUNTIME_PASSWORD"
	envRequireRLS  = "DATABASE_REQUIRE_RLS"
	maxRoleNameLen = 63
)

var roleNamePattern = regexp.MustCompile(`^[a-z_][a-z0-9_]*$`)

// ErrRoleBypassesRLS is returned when the running service's database role
// would skip row-level security.
var ErrRoleBypassesRLS = errors.New("the service's database role bypasses row-level security")

// Ensure creates or updates the runtime role DATABASE_RUNTIME_ROLE with the
// password DATABASE_RUNTIME_PASSWORD: it can log in, is not a superuser,
// cannot bypass row-level security, and may read and write the service's
// tables and sequences, including those later migrations create. With no role
// configured it does nothing. It runs as the owner, after migrate.
func Ensure(ctx context.Context, dbManager datastore.Manager) error {
	role := strings.TrimSpace(os.Getenv(envRole))
	if role == "" {
		return nil
	}
	password := os.Getenv(envPassword)
	if err := validate(role, password); err != nil {
		return err
	}
	dbPool, err := dbmigrate.Pool(ctx, dbManager)
	if err != nil {
		return err
	}
	return ensure(ctx, dbPool, role, password)
}

func validate(role, password string) error {
	if len(role) > maxRoleNameLen || !roleNamePattern.MatchString(role) {
		return fmt.Errorf("runtime role %q is not a plain lower-case identifier", role)
	}
	if password == "" {
		return fmt.Errorf("runtime role %s has no %s", role, envPassword)
	}
	return nil
}

func ensure(ctx context.Context, dbPool pool.Pool, role, password string) error {
	db := dbPool.DB(ctx, false)

	var exists bool
	if err := db.Raw(`SELECT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = ?)`, role).Scan(&exists).Error; err != nil {
		return fmt.Errorf("look up runtime role: %w", err)
	}
	verb := "ALTER"
	if !exists {
		verb = "CREATE"
	}
	// Postgres quotes the name and the password itself: neither is ever
	// spliced into SQL text here. The statement carries the password, so it
	// runs on a session that never logs SQL, and its errors never echo it.
	quiet := db.Session(&gorm.Session{Logger: gormlogger.Discard})
	var stmt string
	if err := quiet.Raw(`SELECT format('`+verb+` ROLE %I WITH LOGIN NOSUPERUSER NOBYPASSRLS NOCREATEDB NOCREATEROLE PASSWORD %L', ?::text, ?::text)`,
		role, password).
		Scan(&stmt).
		Error; err != nil {
		return errors.New("prepare runtime role statement failed")
	}
	if err := quiet.Exec(stmt).Error; err != nil {
		return fmt.Errorf("%s runtime role %s failed (statement withheld: it carries the password)",
			strings.ToLower(verb), role)
	}

	var grants []string
	if err := db.Raw(`SELECT unnest(ARRAY[
		format('GRANT USAGE ON SCHEMA public TO %I', ?::text),
		format('GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO %I', ?::text),
		format('GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO %I', ?::text),
		format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO %I', ?::text),
		format('ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO %I', ?::text),
		format('ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO %I', ?::text),
		format('ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO %I', ?::text)
	])`, role, role, role, role, role, role, role).Scan(&grants).Error; err != nil {
		return fmt.Errorf("prepare runtime role grants: %w", err)
	}
	for _, g := range grants {
		if err := db.Exec(g).Error; err != nil {
			return fmt.Errorf("grant runtime role: %w", err)
		}
	}
	util.Log(ctx).WithField("role", role).Info("runtime database role is in place")
	return nil
}

// Step is the setup step function: it keeps the runtime role the service
// connects as, after migrate.
func Step(dbManager datastore.Manager) func(context.Context) error {
	return func(ctx context.Context) error { return Ensure(ctx, dbManager) }
}

// MustVerify stops the process when Verify refuses its database role: a
// service connected as a role that skips row-level security would read every
// tenant's rows.
func MustVerify(ctx context.Context, dbManager datastore.Manager) {
	if err := Verify(ctx, dbManager); err != nil {
		util.Log(ctx).WithError(err).Fatal("database role is not bound by row-level security")
	}
}

// Verify refuses a running service whose database role would bypass
// row-level security, when DATABASE_REQUIRE_RLS is true. Turning that on
// together with the switch to the runtime role means a service can never
// quietly fall back to the owner.
func Verify(ctx context.Context, dbManager datastore.Manager) error {
	if !strings.EqualFold(strings.TrimSpace(os.Getenv(envRequireRLS)), "true") {
		return nil
	}
	if dbManager == nil {
		return dbmigrate.ErrPoolNotInitialised
	}
	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	if dbPool == nil {
		return dbmigrate.ErrPoolNotInitialised
	}
	return verify(ctx, dbPool)
}

func verify(ctx context.Context, dbPool pool.Pool) error {
	var flags struct {
		Super  bool
		Bypass bool
		Role   string
	}
	if err := dbPool.DB(ctx, true).Raw(`SELECT current_user AS role, rolsuper AS super, rolbypassrls AS bypass
		FROM pg_roles WHERE rolname = current_user`).Scan(&flags).Error; err != nil {
		return fmt.Errorf("read database role flags: %w", err)
	}
	if flags.Super || flags.Bypass {
		return fmt.Errorf("%w: %s", ErrRoleBypassesRLS, flags.Role)
	}
	return nil
}
