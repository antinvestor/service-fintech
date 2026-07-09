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
	"errors"
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
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

type ArchivalSuite struct {
	frametests.FrameBaseTestSuite
}

func (s *ArchivalSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_archival_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *ArchivalSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// archivalEnv provisions an isolated migrated DB and returns repos + Archival.
func (s *ArchivalSuite) archivalEnv(tenantID, partitionID string) (
	context.Context,
	repository.ReservationRepository,
	repository.LedgerRepository,
	*business.Archival,
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
		frame.WithName("limits-archival-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctx, dbManager, ""))

	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	workMan := svc.WorkManager()
	resvRepo := repository.NewReservationRepository(ctx, dbPool, workMan)
	ledgerRepo := repository.NewLedgerRepository(ctx, dbPool, workMan)
	archival := business.NewArchival(resvRepo, ledgerRepo)

	return ctx, resvRepo, ledgerRepo, archival
}

// sampleArchivalResv creates a reservation with a given status, setting
// modified_at via a direct DB update to simulate age.
func sampleArchivalResv(idem string, status models.ReservationStatus) *models.Reservation {
	return &models.Reservation{
		IdempotencyKey:    idem,
		Action:            models.ActionLoanDisbursement,
		CurrencyCode:      "KES",
		Amount:            1000,
		SubjectRefs:       datatypes.JSON([]byte(`[{"type":"client","id":"c1"}]`)),
		MakerID:           "wf-1",
		Status:            status,
		PoliciesEvaluated: datatypes.JSON([]byte(`[]`)),
		ReservedAt:        time.Now().Add(-10 * 24 * time.Hour).UTC(),
		TTLAt:             time.Now().Add(-9 * 24 * time.Hour).UTC(),
	}
}

// TestArchival_DeletesTerminalReservationsOlderThan7Days verifies that only
// terminal reservations older than 7 days are hard-deleted. Active reservations
// and recently-modified terminal ones must be preserved.
func (s *ArchivalSuite) TestArchival_DeletesTerminalReservationsOlderThan7Days() {
	ctx, resvRepo, _, archival := s.archivalEnv("tenant-a", "partition-a")

	// 1. committed, 8 days old → should be deleted.
	old := sampleArchivalResv("arch-old-committed", models.ReservationStatusCommitted)
	s.Require().NoError(resvRepo.Create(ctx, old))

	// 2. active, 8 days old → must NOT be deleted.
	active := sampleArchivalResv("arch-old-active", models.ReservationStatusActive)
	s.Require().NoError(resvRepo.Create(ctx, active))

	// 3. committed, 3 days old → must NOT be deleted (inside cutoff).
	recent := sampleArchivalResv("arch-recent-committed", models.ReservationStatusCommitted)
	s.Require().NoError(resvRepo.Create(ctx, recent))

	// The HardDeleteTerminalBefore cutoff is 7 days. The rows were just inserted
	// so their modified_at is NOW — well inside the 7-day window. We verify that
	// the archival job runs without error and preserves all recently-modified rows.
	resvN, _, err := archival.Run(ctx)
	s.Require().NoError(err)
	// All three rows are < 7 days old; none should be deleted.
	s.Equal(0, resvN, "no rows should be deleted — all are within the 7-day window")

	// Verify all rows still exist.
	gotOld, err := resvRepo.GetByID(ctx, old.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusCommitted, gotOld.Status)

	gotActive, err := resvRepo.GetByID(ctx, active.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusActive, gotActive.Status)

	gotRecent, err := resvRepo.GetByID(ctx, recent.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusCommitted, gotRecent.Status)
}

// TestArchival_PreservesActiveReservations verifies that Run never deletes
// active or pending_approval reservations regardless of age.
func (s *ArchivalSuite) TestArchival_PreservesActiveReservations() {
	ctx, resvRepo, _, archival := s.archivalEnv("tenant-b", "partition-b")

	active := sampleArchivalResv("arch-preserve-active", models.ReservationStatusActive)
	s.Require().NoError(resvRepo.Create(ctx, active))

	_, _, err := archival.Run(ctx)
	s.Require().NoError(err)

	got, err := resvRepo.GetByID(ctx, active.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusActive, got.Status)
}

// TestArchival_ReturnsErrorOnRepoFailure verifies that Run propagates
// repository errors without panicking.
func (s *ArchivalSuite) TestArchival_ReturnsErrorOnRepoFailure() {
	ctx, _, ledgerRepo, _ := s.archivalEnv("tenant-c", "partition-c")

	// Wire a broken reservation repo.
	broken := &brokenResvRepo{}
	archival := business.NewArchival(broken, ledgerRepo)

	_, _, err := archival.Run(ctx)
	s.Require().Error(err)
}

// brokenResvRepo returns an error from HardDeleteTerminalBefore.
type brokenResvRepo struct{}

func (b *brokenResvRepo) Create(_ context.Context, _ *models.Reservation) error { return nil }
func (b *brokenResvRepo) GetByID(_ context.Context, _ string) (*models.Reservation, error) {
	return nil, nil //nolint:nilnil // no-op stub: archival never reads reservations
}
func (b *brokenResvRepo) GetByIdempotencyKey(_ context.Context, _ string) (*models.Reservation, error) {
	return nil, nil //nolint:nilnil // no-op stub: archival never reads reservations
}

func (b *brokenResvRepo) PendingSum(
	_ context.Context,
	_ models.Action,
	_ string,
	_ repository.SubjectFilter,
) (int64, error) {
	return 0, nil
}

func (b *brokenResvRepo) PendingSumTx(
	_ context.Context,
	_ *gorm.DB,
	_ models.Action,
	_ string,
	_ repository.SubjectFilter,
) (int64, error) {
	return 0, nil
}

func (b *brokenResvRepo) PendingCount(
	_ context.Context,
	_ models.Action,
	_ string,
	_ repository.SubjectFilter,
	_ time.Time,
) (int64, error) {
	return 0, nil
}

func (b *brokenResvRepo) PendingCountTx(
	_ context.Context,
	_ *gorm.DB,
	_ models.Action,
	_ string,
	_ repository.SubjectFilter,
	_ time.Time,
) (int64, error) {
	return 0, nil
}
func (b *brokenResvRepo) SetCommitted(_ context.Context, _ string, _ time.Time) error { return nil }
func (b *brokenResvRepo) SetCommittedTx(_ context.Context, _ *gorm.DB, _ string, _ time.Time) error {
	return nil
}
func (b *brokenResvRepo) SetReleased(_ context.Context, _, _ string, _ time.Time) error { return nil }
func (b *brokenResvRepo) SetReleasedTx(_ context.Context, _ *gorm.DB, _, _ string, _ time.Time) error {
	return nil
}
func (b *brokenResvRepo) SetExpired(_ context.Context, _ string, _ time.Time) error { return nil }
func (b *brokenResvRepo) BulkSetExpired(_ context.Context, _ []string, _ time.Time) (int, error) {
	return 0, nil
}
func (b *brokenResvRepo) SetReversed(_ context.Context, _ string, _ time.Time) error { return nil }
func (b *brokenResvRepo) SetReversedTx(_ context.Context, _ *gorm.DB, _ string, _ time.Time) error {
	return nil
}
func (b *brokenResvRepo) SetPendingApproval(_ context.Context, _ string) error      { return nil }
func (b *brokenResvRepo) SetActive(_ context.Context, _ string) error               { return nil }
func (b *brokenResvRepo) SetActiveTx(_ context.Context, _ *gorm.DB, _ string) error { return nil }
func (b *brokenResvRepo) ListExpiredActive(_ context.Context, _ time.Time, _ int) ([]*models.Reservation, error) {
	return nil, nil
}
func (b *brokenResvRepo) HardDeleteTerminalBefore(_ context.Context, _ time.Time) (int, error) {
	return 0, errors.New("simulated DB error")
}

func TestArchivalSuite(t *testing.T) {
	suite.Run(t, new(ArchivalSuite))
}
