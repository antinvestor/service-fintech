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
	"os"
	"strings"
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
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

type ApprovalRepoSuite struct {
	frametests.FrameBaseTestSuite
}

func (s *ApprovalRepoSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *ApprovalRepoSuite) approvalDBResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// applyRuntimeIndexes reads the SQL migration file and executes each statement
// individually. It strips comment lines first so that semicolons inside
// comments don't break the statement splitter.
func applyRuntimeIndexes(t *testing.T, db *gorm.DB) {
	t.Helper()
	sqlBytes, err := os.ReadFile("../../migrations/20260506_runtime_indexes.up.sql")
	require.NoError(t, err)

	// Strip line comments before splitting on semicolons.
	var noComments strings.Builder
	for _, line := range strings.Split(string(sqlBytes), "\n") {
		trimmed := strings.TrimSpace(line)
		if strings.HasPrefix(trimmed, "--") {
			continue
		}
		noComments.WriteString(line)
		noComments.WriteByte('\n')
	}

	for _, stmt := range strings.Split(noComments.String(), ";") {
		stmt = strings.TrimSpace(stmt)
		if stmt == "" {
			continue
		}
		require.NoError(t, db.Exec(stmt).Error, "failed to execute SQL: %s", stmt)
	}
}

func (s *ApprovalRepoSuite) newApprovalEnv(tenantID, partitionID string) (
	context.Context,
	repository.ApprovalRequestRepository,
	repository.ApprovalDecisionRepository,
) {
	s.T().Helper()

	ctx := s.T().Context()
	ctx = s.WithAuthClaims(ctx, tenantID, partitionID, "test-user")

	db := s.approvalDBResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-approval-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctx, dbManager, ""))

	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	applyRuntimeIndexes(s.T(), dbPool.DB(ctx, false))

	return ctx,
		repository.NewApprovalRequestRepository(ctx, dbPool, svc.WorkManager()),
		repository.NewApprovalDecisionRepository(ctx, dbPool, svc.WorkManager())
}

func sampleApproval() *models.ApprovalRequest {
	return &models.ApprovalRequest{
		ReservationID:      "res-1",
		Action:             models.ActionLoanDisbursement,
		CurrencyCode:       "KES",
		Amount:             1000,
		TriggeringPolicyID: "pol-1",
		PolicyVersion:      1,
		RequiredRole:       "branch_manager",
		RequiredCount:      1,
		MakerID:            "wf-1",
		Status:             models.ApprovalStatusPending,
		SubmittedAt:        time.Now().UTC(),
		ExpiresAt:          time.Now().Add(72 * time.Hour).UTC(),
	}
}

func (s *ApprovalRepoSuite) TestApprovalCreateAndGet() {
	ctx, reqRepo, _ := s.newApprovalEnv("t-1", "p-1")
	ar := sampleApproval()
	s.Require().NoError(reqRepo.Create(ctx, ar))
	s.NotEmpty(ar.ID)

	got, err := reqRepo.GetByID(ctx, ar.ID)
	s.Require().NoError(err)
	s.Equal(ar.ID, got.ID)
	s.Equal(ar.ReservationID, got.ReservationID)
	s.Equal(models.ApprovalStatusPending, got.Status)
}

func (s *ApprovalRepoSuite) TestApprovalListByReservation() {
	ctx, reqRepo, _ := s.newApprovalEnv("t-1", "p-1")

	ar1 := sampleApproval()
	ar2 := sampleApproval()
	ar2.TriggeringPolicyID = "pol-2"

	s.Require().NoError(reqRepo.Create(ctx, ar1))
	s.Require().NoError(reqRepo.Create(ctx, ar2))

	list, err := reqRepo.ListByReservation(ctx, "res-1")
	s.Require().NoError(err)
	s.Len(list, 2)
}

func (s *ApprovalRepoSuite) TestApprovalDecisionDoubleVoteRejected() {
	ctx, reqRepo, decRepo := s.newApprovalEnv("t-1", "p-1")

	ar := sampleApproval()
	s.Require().NoError(reqRepo.Create(ctx, ar))

	d1 := &models.ApprovalDecision{
		ApprovalRequestID: ar.ID,
		ApproverID:        "approver-1",
		Decision:          "approve",
		DecidedAt:         time.Now().UTC(),
	}
	s.Require().NoError(decRepo.RecordDecision(ctx, d1))

	d2 := &models.ApprovalDecision{
		ApprovalRequestID: ar.ID,
		ApproverID:        "approver-1",
		Decision:          "approve",
		DecidedAt:         time.Now().UTC(),
	}
	err := decRepo.RecordDecision(ctx, d2)
	s.Require().Error(err, "expected unique-constraint violation on double vote")
}

func (s *ApprovalRepoSuite) TestApprovalSetStatus() {
	ctx, reqRepo, _ := s.newApprovalEnv("t-1", "p-1")

	ar := sampleApproval()
	s.Require().NoError(reqRepo.Create(ctx, ar))

	now := time.Now().UTC()
	s.Require().NoError(reqRepo.SetStatus(ctx, ar.ID, models.ApprovalStatusApproved, &now))

	got, err := reqRepo.GetByID(ctx, ar.ID)
	s.Require().NoError(err)
	s.Equal(models.ApprovalStatusApproved, got.Status)
	s.NotNil(got.DecidedAt)
}

func (s *ApprovalRepoSuite) TestApprovalListExpired() {
	ctx, reqRepo, _ := s.newApprovalEnv("t-1", "p-1")

	past := sampleApproval()
	past.ExpiresAt = time.Now().Add(-1 * time.Hour).UTC()
	s.Require().NoError(reqRepo.Create(ctx, past))

	future := sampleApproval()
	future.ReservationID = "res-2"
	future.ExpiresAt = time.Now().Add(72 * time.Hour).UTC()
	s.Require().NoError(reqRepo.Create(ctx, future))

	expired, err := reqRepo.ListExpired(ctx, time.Now().UTC(), 100)
	s.Require().NoError(err)
	s.Len(expired, 1)
	s.Equal(past.ID, expired[0].ID)
}

func TestApprovalRepoSuite(t *testing.T) {
	suite.Run(t, new(ApprovalRepoSuite))
}
