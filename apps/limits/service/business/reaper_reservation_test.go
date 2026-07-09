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

package business_test

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/frametests"
	"github.com/pitabwire/frame/v2/frametests/definition"
	testpostgres "github.com/pitabwire/frame/v2/frametests/deps/testpostgres"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"
	"gorm.io/datatypes"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

type ReservationReaperSuite struct {
	frametests.FrameBaseTestSuite
}

func (s *ReservationReaperSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_reaper_resv_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *ReservationReaperSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// reaperResvEnv provisions an isolated DB and returns a ReservationRepository
// and a ReservationReaper wired against it.
func (s *ReservationReaperSuite) reaperResvEnv(tenantID, partitionID string) (
	context.Context,
	repository.ReservationRepository,
	*business.ReservationReaper,
) {
	s.T().Helper()

	ctx := s.T().Context()
	ctx = s.WithAuthClaims(ctx, tenantID, partitionID, "test-user")

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-reaper-resv-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctx, dbManager, ""))

	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	applyRuntimeIndexesForResv(s.T(), dbPool.DB(ctx, false))

	workMan := svc.WorkManager()
	resvRepo := repository.NewReservationRepository(ctx, dbPool, workMan)
	auditing := business.NewAuditing(nil)
	reaper := business.NewReservationReaper(resvRepo, auditing, 1000)

	return ctx, resvRepo, reaper
}

// sampleResvForReaper builds a Reservation with the given status and TTL.
func sampleResvForReaper(idem string, status models.ReservationStatus, ttl time.Time) *models.Reservation {
	return &models.Reservation{
		IdempotencyKey:    idem,
		Action:            models.ActionLoanDisbursement,
		CurrencyCode:      "KES",
		Amount:            1000,
		SubjectRefs:       datatypes.JSON([]byte(`[{"type":"client","id":"c1"}]`)),
		MakerID:           "wf-1",
		Status:            status,
		PoliciesEvaluated: datatypes.JSON([]byte(`[]`)),
		ReservedAt:        time.Now().Add(-1 * time.Hour).UTC(),
		TTLAt:             ttl,
	}
}

// TestReservationReaper_ExpiresPastTTL: active reservation with TTL in the past
// should be transitioned to expired after Run.
func (s *ReservationReaperSuite) TestReservationReaper_ExpiresPastTTL() {
	ctx, resvRepo, reaper := s.reaperResvEnv("tenant-a", "partition-a")

	resv := sampleResvForReaper(
		"reaper-past-ttl-1",
		models.ReservationStatusActive,
		time.Now().Add(-1*time.Minute).UTC(),
	)
	s.Require().NoError(resvRepo.Create(ctx, resv))

	s.Require().NoError(reaper.Run(ctx))

	got, err := resvRepo.GetByID(ctx, resv.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusExpired, got.Status)
}

// TestReservationReaper_DoesNotTouchFutureTTL: active reservation with TTL in
// the future must remain active after Run.
func (s *ReservationReaperSuite) TestReservationReaper_DoesNotTouchFutureTTL() {
	ctx, resvRepo, reaper := s.reaperResvEnv("tenant-a", "partition-a")

	resv := sampleResvForReaper(
		"reaper-future-ttl-1",
		models.ReservationStatusActive,
		time.Now().Add(1*time.Hour).UTC(),
	)
	s.Require().NoError(resvRepo.Create(ctx, resv))

	s.Require().NoError(reaper.Run(ctx))

	got, err := resvRepo.GetByID(ctx, resv.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusActive, got.Status)
}

// TestReservationReaper_DoesNotTouchTerminal: a reservation already in a
// terminal state (committed) must not be touched.
func (s *ReservationReaperSuite) TestReservationReaper_DoesNotTouchTerminal() {
	ctx, resvRepo, reaper := s.reaperResvEnv("tenant-a", "partition-a")

	resv := sampleResvForReaper(
		"reaper-terminal-1",
		models.ReservationStatusCommitted,
		time.Now().Add(-1*time.Minute).UTC(),
	)
	s.Require().NoError(resvRepo.Create(ctx, resv))

	s.Require().NoError(reaper.Run(ctx))

	got, err := resvRepo.GetByID(ctx, resv.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusCommitted, got.Status)
}

// TestReservationReaper_BatchLimit: with 5 expired reservations and batchSize=2,
// only 2 are reaped per Run. A second Run picks up the next batch.
func (s *ReservationReaperSuite) TestReservationReaper_BatchLimit() {
	ctx, resvRepo, _ := s.reaperResvEnv("tenant-a", "partition-a")

	// Small reaper with batchSize=2.
	auditing := business.NewAuditing(nil)
	smallReaper := business.NewReservationReaper(resvRepo, auditing, 2)

	past := time.Now().Add(-1 * time.Minute).UTC()
	for i := range 5 {
		resv := sampleResvForReaper(fmt.Sprintf("reaper-batch-%d", i), models.ReservationStatusActive, past)
		s.Require().NoError(resvRepo.Create(ctx, resv))
	}

	// First pass: expires exactly 2.
	s.Require().NoError(smallReaper.Run(ctx))
	rows, err := resvRepo.ListExpiredActive(ctx, time.Now().UTC(), 1000)
	s.Require().NoError(err)
	s.Len(rows, 3, "3 should remain after first pass")

	// Second pass: expires 2 more.
	s.Require().NoError(smallReaper.Run(ctx))
	rows, err = resvRepo.ListExpiredActive(ctx, time.Now().UTC(), 1000)
	s.Require().NoError(err)
	s.Len(rows, 1, "1 should remain after second pass")

	// Third pass: expires the last one.
	s.Require().NoError(smallReaper.Run(ctx))
	rows, err = resvRepo.ListExpiredActive(ctx, time.Now().UTC(), 1000)
	s.Require().NoError(err)
	s.Empty(rows, "none should remain after third pass")
}

func TestReservationReaperSuite(t *testing.T) {
	suite.Run(t, new(ReservationReaperSuite))
}
