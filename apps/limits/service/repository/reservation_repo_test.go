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

package repository_test

import (
	"context"
	"testing"
	"time"

	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/frametests"
	"github.com/pitabwire/frame/v2/frametests/definition"
	"github.com/pitabwire/frame/v2/frametests/deps/testpostgres"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"
	"gorm.io/datatypes"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

type ReservationRepoSuite struct {
	frametests.FrameBaseTestSuite
}

func (s *ReservationRepoSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

// newEnv creates an isolated DB + migrated repo for each test.
func (s *ReservationRepoSuite) newEnv(
	tenantID, partitionID string,
) (context.Context, repository.ReservationRepository) {
	s.T().Helper()

	ctx := s.T().Context()
	ctx = s.WithAuthClaims(ctx, tenantID, partitionID, "test-user")

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-reservation-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctx, dbManager, ""))

	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	return ctx, repository.NewReservationRepository(ctx, dbPool, svc.WorkManager())
}

func (s *ReservationRepoSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

func sampleResv(idem string, action models.Action, amount int64) *models.Reservation {
	return &models.Reservation{
		IdempotencyKey:    idem,
		Action:            action,
		CurrencyCode:      "KES",
		Amount:            amount,
		SubjectRefs:       datatypes.JSON([]byte(`[{"type":"client","id":"c1"}]`)),
		MakerID:           "wf-1",
		Status:            models.ReservationStatusActive,
		PoliciesEvaluated: datatypes.JSON([]byte(`[]`)),
		ReservedAt:        time.Now().UTC(),
		TTLAt:             time.Now().Add(5 * time.Minute).UTC(),
	}
}

func (s *ReservationRepoSuite) TestCreateAndGetByIdempotencyKey() {
	ctx, repo := s.newEnv("t-1", "p-1")
	r := sampleResv("idem-1", models.ActionLoanDisbursement, 1000)
	s.Require().NoError(repo.Create(ctx, r))
	s.NotEmpty(r.ID)
	got, err := repo.GetByIdempotencyKey(ctx, "idem-1")
	s.Require().NoError(err)
	s.Equal(r.ID, got.ID)
}

func (s *ReservationRepoSuite) TestPendingSumByTenantSubject() {
	ctx, repo := s.newEnv("t-1", "p-1")
	r1 := sampleResv("idem-1", models.ActionLoanDisbursement, 1000)
	r2 := sampleResv("idem-2", models.ActionLoanDisbursement, 2000)
	s.Require().NoError(repo.Create(ctx, r1))
	s.Require().NoError(repo.Create(ctx, r2))
	sum, err := repo.PendingSum(ctx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"})
	s.Require().NoError(err)
	s.Equal(int64(3000), sum)
}

func (s *ReservationRepoSuite) TestListExpiredActive() {
	ctx, repo := s.newEnv("t-1", "p-1")
	r := sampleResv("idem-old", models.ActionLoanDisbursement, 1)
	r.TTLAt = time.Now().Add(-1 * time.Minute).UTC()
	s.Require().NoError(repo.Create(ctx, r))
	out, err := repo.ListExpiredActive(ctx, time.Now().UTC(), 100)
	s.Require().NoError(err)
	s.Len(out, 1)
	s.Equal(r.ID, out[0].ID)
}

func (s *ReservationRepoSuite) TestTransitionToCommitted() {
	ctx, repo := s.newEnv("t-1", "p-1")
	r := sampleResv("idem-1", models.ActionLoanDisbursement, 1)
	s.Require().NoError(repo.Create(ctx, r))
	now := time.Now().UTC()
	s.Require().NoError(repo.SetCommitted(ctx, r.ID, now))
	got, err := repo.GetByID(ctx, r.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusCommitted, got.Status)
	s.NotNil(got.CommittedAt)
}

func (s *ReservationRepoSuite) TestBulkSetExpired_OnlyTouchesActive() {
	ctx, repo := s.newEnv("t-1", "p-1")

	// Three reservations: two active, one committed.
	active1 := sampleResv("bulk-active-1", models.ActionLoanDisbursement, 100)
	active2 := sampleResv("bulk-active-2", models.ActionLoanDisbursement, 200)
	committed := sampleResv("bulk-committed-1", models.ActionLoanDisbursement, 300)

	s.Require().NoError(repo.Create(ctx, active1))
	s.Require().NoError(repo.Create(ctx, active2))
	s.Require().NoError(repo.Create(ctx, committed))

	// Transition the third row to committed state.
	s.Require().NoError(repo.SetCommitted(ctx, committed.ID, time.Now().UTC()))

	// Call BulkSetExpired with all three IDs.
	now := time.Now().UTC()
	n, err := repo.BulkSetExpired(ctx, []string{active1.ID, active2.ID, committed.ID}, now)
	s.Require().NoError(err)
	s.Equal(2, n, "only the two active rows should be updated")

	// Verify the active rows flipped.
	got1, err := repo.GetByID(ctx, active1.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusExpired, got1.Status)

	got2, err := repo.GetByID(ctx, active2.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusExpired, got2.Status)

	// Verify the committed row is unchanged.
	gotC, err := repo.GetByID(ctx, committed.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusCommitted, gotC.Status)
}

func TestReservationRepoSuite(t *testing.T) {
	suite.Run(t, new(ReservationRepoSuite))
}
