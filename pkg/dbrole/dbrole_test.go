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

package dbrole

import (
	"context"
	"net/url"
	"strings"
	"testing"

	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/frametests"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/frame/v3/frametests/deps/testpostgres"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"
)

type roleSuite struct {
	frametests.FrameBaseTestSuite
}

func TestRoleSuite(t *testing.T) {
	if testing.Short() {
		t.Skip("needs Docker")
	}
	suite.Run(t, new(roleSuite))
}

func (s *roleSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("dbrole", definition.WithUserName("ant"), definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false)),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

// connect opens a pool on dsn.
func (s *roleSuite) connect(ctx context.Context, dsn string) pool.Pool {
	ctx, svc := frame.NewServiceWithContext(ctx, frame.WithName("dbrole-test-"+util.RandomAlphaNumericString(4)),
		frame.WithDatastore(pool.WithConnection(dsn, false)))
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)
	p := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(p)
	return p
}

// The setup step creates a runtime role row-level security applies to; the
// running service, connected as it, sees only its tenant's rows, and the
// startup check refuses the owner.
func (s *roleSuite) TestRuntimeRoleIsBoundByRowLevelSecurity() {
	ctx := s.T().Context()
	var db definition.DependancyConn
	for _, r := range s.Resources() {
		if r.Name() == testpostgres.PostgresqlDBImage && r.GetDS(ctx).IsDB() {
			db = r
		}
	}
	s.Require().NotNil(db)
	ds, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })
	owner := s.connect(ctx, ds.String())

	// A tenant table as frame enrols it: forced RLS keyed on app.tenant_id.
	odb := owner.DB(ctx, false)
	s.Require().NoError(odb.Exec(`CREATE TABLE things (id text PRIMARY KEY, tenant_id text NOT NULL)`).Error)
	s.Require().NoError(odb.Exec(`INSERT INTO things VALUES ('a','t1'), ('b','t2')`).Error)
	s.Require().NoError(odb.Exec(`ALTER TABLE things ENABLE ROW LEVEL SECURITY`).Error)
	s.Require().NoError(odb.Exec(`ALTER TABLE things FORCE ROW LEVEL SECURITY`).Error)
	s.Require().
		NoError(odb.Exec(`CREATE POLICY tenant ON things USING (tenant_id = current_setting('app.tenant_id', true))`).Error)

	s.Require().ErrorIs(verify(ctx, owner), ErrRoleBypassesRLS, "the container's owner is a superuser")

	role := "svc_runtime_" + util.RandomAlphaNumericString(6)
	s.Require().NoError(ensure(ctx, owner, role, "first-pass'word"), "a quote in the password is harmless")
	s.Require().NoError(ensure(ctx, owner, role, "second-password"), "a re-run updates the role")

	u, err := url.Parse(ds.String())
	s.Require().NoError(err)
	u.User = url.UserPassword(role, "second-password")
	runtime := s.connect(ctx, u.String())
	s.Require().NoError(verify(ctx, runtime), "the runtime role cannot bypass row-level security")

	rdb := runtime.DB(ctx, false)
	var seen []string
	s.Require().NoError(rdb.Transaction(func(tx *gorm.DB) error {
		if err := tx.Exec(`SELECT set_config('app.tenant_id', 't1', true)`).Error; err != nil {
			return err
		}
		return tx.Raw(`SELECT id FROM things ORDER BY id`).Scan(&seen).Error
	}))
	s.Equal([]string{"a"}, seen, "only the tenant's own rows")

	// Tables later migrations create are granted too.
	s.Require().NoError(odb.Exec(`CREATE TABLE later (id text PRIMARY KEY)`).Error)
	s.Require().NoError(rdb.Exec(`INSERT INTO later VALUES ('x')`).Error)
}

func TestValidate(t *testing.T) {
	for _, bad := range []string{"", "Bad", "has-dash", "x; drop", "1abc"} {
		if validate(bad, "pw") == nil {
			t.Errorf("role %q accepted", bad)
		}
	}
	if validate("svc_runtime", "") == nil {
		t.Error("empty password accepted")
	}
	if err := validate("finance_loans_rt", "pw"); err != nil {
		t.Error(err)
	}
}

// The verifier is what Postgres stores, never the password itself.
func TestScramVerifierCarriesNoPassword(t *testing.T) {
	v, err := scramVerifier("hunter2-secret")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.HasPrefix(v, "SCRAM-SHA-256$4096:") || strings.Contains(v, "hunter2") {
		t.Fatalf("unexpected verifier %q", v)
	}
	again, _ := scramVerifier("hunter2-secret")
	if again == v {
		t.Fatal("verifiers must be salted")
	}
}
