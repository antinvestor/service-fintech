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

package handlers_test

import (
	"context"
	"os"
	"strings"
	"testing"
	"time"

	moneypb "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/frametests"
	"github.com/pitabwire/frame/v2/frametests/definition"
	testpostgres "github.com/pitabwire/frame/v2/frametests/deps/testpostgres"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
	"google.golang.org/protobuf/types/known/durationpb"
	"google.golang.org/protobuf/types/known/timestamppb"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/handlers"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

type RuntimeHandlerSuite struct {
	frametests.FrameBaseTestSuite
}

func (s *RuntimeHandlerSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_runtime_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *RuntimeHandlerSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// runtimeEnv provisions an isolated DB and returns a fully wired RuntimeService.
func (s *RuntimeHandlerSuite) runtimeEnv(tenantID, partitionID string) (
	context.Context,
	*handlers.RuntimeService,
	pool.Pool,
	repository.PolicyRepository,
	repository.LedgerRepository,
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
		frame.WithName("limits-runtime-handler-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctx, dbManager, ""))

	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	applyRuntimeIndexes(s.T(), dbPool.DB(ctx, false))

	workMan := svc.WorkManager()

	resvRepo := repository.NewReservationRepository(ctx, dbPool, workMan)
	ledgerRepo := repository.NewLedgerRepository(ctx, dbPool, workMan)
	approvalRepo := repository.NewApprovalRequestRepository(ctx, dbPool, workMan)
	candidateRepo := repository.NewCandidatePolicyRepository(dbPool)
	policyRepo := repository.NewPolicyRepository(ctx, dbPool, workMan)
	attrRepo := repository.NewSubjectAttributeRepository(ctx, dbPool, workMan)

	evaluator := business.NewEvaluator(resvRepo, ledgerRepo)
	resolver := business.NewAttributeResolver(attrRepo, nil, 60*time.Second)
	auditing := business.NewAuditing(nil)

	biz := business.NewReservationBusiness(
		resvRepo, ledgerRepo, candidateRepo, approvalRepo, policyRepo,
		evaluator, resolver, auditing, dbPool, nil,
	)

	handler := handlers.NewRuntimeService(biz)
	return ctx, handler, dbPool, policyRepo, ledgerRepo
}

// applyRuntimeIndexes reads and applies the SQL migration file containing
// the idempotency unique constraint.
func applyRuntimeIndexes(t *testing.T, db *gorm.DB) {
	t.Helper()
	sqlBytes, err := os.ReadFile("../../migrations/20260506_runtime_indexes.up.sql")
	require.NoError(t, err)

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

// seedPolicyForHandler persists a policy directly for handler tests.
func seedPolicyForHandler(
	ctx context.Context,
	t *testing.T,
	policyRepo repository.PolicyRepository,
	in *limitsv1.PolicyObject,
) *models.Policy {
	t.Helper()
	p, err := models.PolicyFromAPI(in)
	require.NoError(t, err)
	p.ID = ""
	require.NoError(t, policyRepo.Save(ctx, p))
	require.NotEmpty(t, p.ID)
	saved, err := policyRepo.Get(ctx, p.ID)
	require.NoError(t, err)
	return saved
}

// perTxnMaxPolicyHandler builds a policy object for handler tests.
func perTxnMaxPolicyHandler(
	currency string,
	capUnits int64,
	mode limitsv1.PolicyMode,
	action limitsv1.LimitAction,
	subjectType limitsv1.SubjectType,
) *limitsv1.PolicyObject {
	return &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        action,
		SubjectType:   subjectType,
		CurrencyCode:  currency,
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: currency, Units: capUnits},
		Mode:          mode,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour).UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
	}
}

// kesIntentForHandler builds a LimitIntent with the required subjects for the action.
//
//nolint:exhaustive // remaining actions take the default single-client subject set
func kesIntentForHandler(action limitsv1.LimitAction, units int64) *limitsv1.LimitIntent {
	var subjects []*limitsv1.SubjectRef
	switch action {
	case limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_REQUEST,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_REPAYMENT:
		subjects = []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-handler-1"},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-handler-1"},
		}
	default:
		subjects = []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-handler-1"},
		}
	}
	return &limitsv1.LimitIntent{
		TenantId: "tenant-a",
		Action:   action,
		Amount:   &moneypb.Money{CurrencyCode: "KES", Units: units},
		Subjects: subjects,
		MakerId:  "wf-maker-1",
	}
}

// TestRuntimeService_ReserveCommitFlow: Reserve → ACTIVE, Commit → COMMITTED.
func (s *RuntimeHandlerSuite) TestRuntimeService_ReserveCommitFlow() {
	ctx, handler, _, policyRepo, _ := s.runtimeEnv("tenant-a", "partition-a")

	seedPolicyForHandler(ctx, s.T(), policyRepo, perTxnMaxPolicyHandler(
		"KES", 10000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	intent := kesIntentForHandler(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500)
	reserveResp, err := handler.Reserve(ctx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent:         intent,
		IdempotencyKey: "rt-handler-reserve-commit-1",
		Ttl:            durationpb.New(5 * time.Minute),
	}))
	s.Require().NoError(err)
	s.Require().NotNil(reserveResp.Msg.GetReservation())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE, reserveResp.Msg.GetReservation().GetStatus())

	resvID := reserveResp.Msg.GetReservation().GetId()
	commitResp, err := handler.Commit(ctx, connect.NewRequest(&limitsv1.CommitRequest{
		ReservationId: resvID,
	}))
	s.Require().NoError(err)
	s.Require().NotNil(commitResp.Msg.GetReservation())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_COMMITTED, commitResp.Msg.GetReservation().GetStatus())
}

// TestRuntimeService_CheckReadOnly: Check on a breaching amount returns Allowed=false
// and writes no reservation row.
func (s *RuntimeHandlerSuite) TestRuntimeService_CheckReadOnly() {
	ctx, handler, dbPool, policyRepo, _ := s.runtimeEnv("tenant-a", "partition-a")

	seedPolicyForHandler(ctx, s.T(), policyRepo, perTxnMaxPolicyHandler(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	intent := kesIntentForHandler(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000)
	checkResp, err := handler.Check(ctx, connect.NewRequest(&limitsv1.CheckRequest{
		Intent: intent,
	}))
	s.Require().NoError(err)
	s.False(checkResp.Msg.GetAllowed())
	s.NotEmpty(checkResp.Msg.GetBreachedPolicyIds())

	// Verify no reservation row was written.
	var count int64
	dbPool.DB(ctx, true).Table("limits_reservations").Count(&count)
	s.Equal(int64(0), count)
}

// TestRuntimeService_ReserveRelease: Reserve → Release → RELEASED.
func (s *RuntimeHandlerSuite) TestRuntimeService_ReserveRelease() {
	ctx, handler, _, policyRepo, _ := s.runtimeEnv("tenant-a", "partition-a")

	seedPolicyForHandler(ctx, s.T(), policyRepo, perTxnMaxPolicyHandler(
		"KES", 10000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	intent := kesIntentForHandler(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500)
	reserveResp, err := handler.Reserve(ctx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent:         intent,
		IdempotencyKey: "rt-handler-reserve-release-1",
		Ttl:            durationpb.New(5 * time.Minute),
	}))
	s.Require().NoError(err)
	s.Require().NotNil(reserveResp.Msg.GetReservation())
	resvID := reserveResp.Msg.GetReservation().GetId()

	releaseResp, err := handler.Release(ctx, connect.NewRequest(&limitsv1.ReleaseRequest{
		ReservationId: resvID,
		Reason:        "handler test release",
	}))
	s.Require().NoError(err)
	s.Require().NotNil(releaseResp.Msg.GetReservation())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_RELEASED, releaseResp.Msg.GetReservation().GetStatus())
}

func TestRuntimeHandlerSuite(t *testing.T) {
	suite.Run(t, new(RuntimeHandlerSuite))
}
