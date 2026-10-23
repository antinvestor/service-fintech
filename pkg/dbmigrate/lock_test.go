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

package dbmigrate_test

import (
	"context"
	"sync"
	"testing"
	"time"

	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/frametests"
	"github.com/pitabwire/frame/v2/frametests/definition"
	"github.com/pitabwire/frame/v2/frametests/deps/testpostgres"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-fintech/pkg/dbmigrate"
)

type lockSuite struct {
	frametests.FrameBaseTestSuite
}

func TestLockSuite(t *testing.T) {
	suite.Run(t, new(lockSuite))
}

func (s *lockSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts(
				"pkg_dbmigrate",
				definition.WithUserName("ant"),
				definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false),
			),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *lockSuite) newPool() (context.Context, datastore.Manager) {
	s.T().Helper()
	ctx := s.T().Context()

	var db definition.DependancyConn
	for _, r := range s.Resources() {
		if r.Name() == testpostgres.PostgresqlDBImage && r.GetDS(ctx).IsDB() {
			db = r
		}
	}
	s.Require().NotNil(db, "postgres resource not found")

	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("dbmigrate-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)
	return ctx, svc.DatastoreManager()
}

func TestLockKey_StablePerService(t *testing.T) {
	// Pinned values: a change here would let a new binary take a different
	// lock from an older migrate Job still running against the same database.
	require.Equal(t, int64(5195585927026105942), dbmigrate.LockKey("service_loans"))
	require.Equal(t, int64(-5450104250562883858), dbmigrate.LockKey("service_savings"))
	require.NotEqual(t, dbmigrate.LockKey(""), dbmigrate.LockKey("service_identity"))
}

func TestWithLock_NilPool(t *testing.T) {
	err := dbmigrate.WithLock(t.Context(), nil, "x", func(context.Context) error { return nil })
	require.ErrorIs(t, err, dbmigrate.ErrPoolNotInitialised)
}

func (s *lockSuite) TestLocked_SecondCallerBlocksUntilRelease() {
	ctx, dbManager := s.newPool()

	firstHolding := make(chan struct{})
	releaseFirst := make(chan struct{})
	var order []string
	var mu sync.Mutex
	record := func(step string) {
		mu.Lock()
		defer mu.Unlock()
		order = append(order, step)
	}

	firstDone := make(chan error, 1)
	go func() {
		firstDone <- dbmigrate.Locked(ctx, dbManager, "service_test", func(context.Context) error {
			record("first-acquired")
			close(firstHolding)
			<-releaseFirst
			record("first-released")
			return nil
		})
	}()

	<-firstHolding
	secondDone := make(chan error, 1)
	go func() {
		secondDone <- dbmigrate.Locked(ctx, dbManager, "service_test", func(context.Context) error {
			record("second-acquired")
			return nil
		})
	}()

	select {
	case <-secondDone:
		s.FailNow("second caller acquired the lock while the first still held it")
	case <-time.After(1500 * time.Millisecond):
	}

	close(releaseFirst)
	select {
	case err := <-secondDone:
		s.Require().NoError(err)
	case <-time.After(10 * time.Second):
		s.FailNow("second caller never acquired the lock after release")
	}
	s.Require().NoError(<-firstDone)

	s.Require().Equal([]string{"first-acquired", "first-released", "second-acquired"}, order)
}

func (s *lockSuite) TestLocked_DifferentServicesDoNotBlock() {
	ctx, dbManager := s.newPool()

	holding := make(chan struct{})
	release := make(chan struct{})
	go func() {
		_ = dbmigrate.Locked(ctx, dbManager, "service_a", func(context.Context) error {
			close(holding)
			<-release
			return nil
		})
	}()
	<-holding
	defer close(release)

	done := make(chan error, 1)
	go func() {
		done <- dbmigrate.Locked(ctx, dbManager, "service_b", func(context.Context) error { return nil })
	}()
	select {
	case err := <-done:
		s.Require().NoError(err)
	case <-time.After(5 * time.Second):
		s.FailNow("service_b blocked on service_a's lock")
	}
}

func (s *lockSuite) TestLocked_ReleasesAfterCallbackError() {
	ctx, dbManager := s.newPool()

	err := dbmigrate.Locked(ctx, dbManager, "service_err", func(context.Context) error {
		return context.DeadlineExceeded
	})
	s.Require().ErrorIs(err, context.DeadlineExceeded)

	done := make(chan error, 1)
	go func() {
		done <- dbmigrate.Locked(ctx, dbManager, "service_err", func(context.Context) error { return nil })
	}()
	select {
	case err = <-done:
		s.Require().NoError(err)
	case <-time.After(5 * time.Second):
		s.FailNow("lock was not released after the callback failed")
	}
}
