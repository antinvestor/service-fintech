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

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

type ApprovalReaperSuite struct {
	frametests.FrameBaseTestSuite
}

func (s *ApprovalReaperSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_reaper_appr_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *ApprovalReaperSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// reaperApprEnv provisions an isolated DB and returns repos and a wired ApprovalReaper.
func (s *ApprovalReaperSuite) reaperApprEnv(tenantID, partitionID string) (
	context.Context,
	repository.ReservationRepository,
	repository.ApprovalRequestRepository,
	*business.ApprovalReaper,
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
		frame.WithName("limits-reaper-appr-test"),
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
	approvalRepo := repository.NewApprovalRequestRepository(ctx, dbPool, workMan)
	auditing := business.NewAuditing(nil)
	reaper := business.NewApprovalReaper(approvalRepo, resvRepo, auditing, 1000, nil)

	return ctx, resvRepo, approvalRepo, reaper
}

// seedApprovalRequest inserts an ApprovalRequest row directly.
func seedApprovalRequest(
	resvID string,
	status models.ApprovalStatus,
	expiresAt time.Time,
) *models.ApprovalRequest {
	return &models.ApprovalRequest{
		ReservationID:      resvID,
		Action:             models.ActionLoanDisbursement,
		CurrencyCode:       "KES",
		Amount:             100000,
		TriggeringPolicyID: "policy-1",
		PolicyVersion:      1,
		RequiredRole:       "branch_manager",
		RequiredCount:      1,
		MakerID:            "wf-1",
		Status:             status,
		SubmittedAt:        time.Now().Add(-2 * time.Hour).UTC(),
		ExpiresAt:          expiresAt,
	}
}

// TestApprovalReaper_ExpiresPending: pending approval + corresponding active
// reservation, both past expires_at; Run → approval=expired, reservation=released.
func (s *ApprovalReaperSuite) TestApprovalReaper_ExpiresPending() {
	ctx, resvRepo, approvalRepo, reaper := s.reaperApprEnv("tenant-a", "partition-a")

	// Create an active reservation in pending_approval state.
	resv := sampleResvForReaper(
		"reaper-appr-pending-1",
		models.ReservationStatusPendingApproval,
		time.Now().Add(1*time.Hour).UTC(),
	)
	s.Require().NoError(resvRepo.Create(ctx, resv))

	// Create a pending approval request whose expires_at is in the past.
	ar := seedApprovalRequest(resv.ID, models.ApprovalStatusPending, time.Now().Add(-1*time.Minute).UTC())
	s.Require().NoError(approvalRepo.Create(ctx, ar))

	s.Require().NoError(reaper.Run(ctx))

	// Approval should be expired.
	rows, err := approvalRepo.ListByReservation(ctx, resv.ID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	s.Equal(models.ApprovalStatusExpired, rows[0].Status)

	// Reservation should be released.
	got, err := resvRepo.GetByID(ctx, resv.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusReleased, got.Status)
}

// TestApprovalReaper_DoesNotTouchTerminal: an approved approval request must not
// be transitioned by the reaper even if its expires_at is past.
func (s *ApprovalReaperSuite) TestApprovalReaper_DoesNotTouchTerminal() {
	ctx, resvRepo, approvalRepo, reaper := s.reaperApprEnv("tenant-a", "partition-a")

	resv := sampleResvForReaper(
		"reaper-appr-terminal-1",
		models.ReservationStatusActive,
		time.Now().Add(1*time.Hour).UTC(),
	)
	s.Require().NoError(resvRepo.Create(ctx, resv))

	// Already-approved request with expired expires_at: reaper must skip it.
	ar := seedApprovalRequest(resv.ID, models.ApprovalStatusApproved, time.Now().Add(-1*time.Minute).UTC())
	s.Require().NoError(approvalRepo.Create(ctx, ar))

	s.Require().NoError(reaper.Run(ctx))

	rows, err := approvalRepo.ListByReservation(ctx, resv.ID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	s.Equal(models.ApprovalStatusApproved, rows[0].Status)
}

// TestApprovalReaper_FutureExpiresAt: pending approval with expires_at in the
// future must remain pending after Run.
func (s *ApprovalReaperSuite) TestApprovalReaper_FutureExpiresAt() {
	ctx, resvRepo, approvalRepo, reaper := s.reaperApprEnv("tenant-a", "partition-a")

	resv := sampleResvForReaper(
		"reaper-appr-future-1",
		models.ReservationStatusPendingApproval,
		time.Now().Add(1*time.Hour).UTC(),
	)
	s.Require().NoError(resvRepo.Create(ctx, resv))

	ar := seedApprovalRequest(resv.ID, models.ApprovalStatusPending, time.Now().Add(1*time.Hour).UTC())
	s.Require().NoError(approvalRepo.Create(ctx, ar))

	s.Require().NoError(reaper.Run(ctx))

	rows, err := approvalRepo.ListByReservation(ctx, resv.ID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	s.Equal(models.ApprovalStatusPending, rows[0].Status)

	// Reservation must remain pending_approval.
	got, err := resvRepo.GetByID(ctx, resv.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusPendingApproval, got.Status)
}

func TestApprovalReaperSuite(t *testing.T) {
	suite.Run(t, new(ApprovalReaperSuite))
}
