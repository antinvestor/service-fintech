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

// Package integration provides full-stack RPC lifecycle tests for the limits
// runtime service. Tests run against a real Postgres testcontainer and a real
// Connect-over-HTTP transport using net/http/httptest.Server.
package integration

import (
	"context"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
	"time"

	moneypb "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/frametests"
	"github.com/pitabwire/frame/frametests/definition"
	testpostgres "github.com/pitabwire/frame/frametests/deps/testpostgres"
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

// RuntimeIntegrationSuite exercises Reserve/Commit/Release/Idempotency over a
// real Connect-over-HTTP transport backed by a Postgres testcontainer.
type RuntimeIntegrationSuite struct {
	frametests.FrameBaseTestSuite

	// runtimeClient points at the LimitsService (Reserve/Commit/Release/etc).
	runtimeClient limitsv1connect.LimitsServiceClient

	// dbPool is kept for direct DB verification (ledger row counts).
	dbPool pool.Pool

	// policyRepo is used to seed policies before each test.
	policyRepo repository.PolicyRepository

	// ctx is the test context with auth claims injected.
	ctx context.Context
}

func (s *RuntimeIntegrationSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_rt_int_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *RuntimeIntegrationSuite) SetupTest() {
	ctx := s.T().Context()
	ctx = s.WithAuthClaims(ctx, "tenant-rt", "partition-rt", "wf-maker")
	s.ctx = ctx

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-runtime-integration-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctx, dbManager, ""))

	s.dbPool = dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(s.dbPool)

	applyRTIndexes(s.T(), s.dbPool.DB(ctx, false))

	workMan := svc.WorkManager()
	resvRepo := repository.NewReservationRepository(ctx, s.dbPool, workMan)
	ledgerRepo := repository.NewLedgerRepository(ctx, s.dbPool, workMan)
	approvalRepo := repository.NewApprovalRequestRepository(ctx, s.dbPool, workMan)
	candidateRepo := repository.NewCandidatePolicyRepository(s.dbPool)
	s.policyRepo = repository.NewPolicyRepository(ctx, s.dbPool, workMan)
	policyVerRepo := repository.NewPolicyVersionRepository(ctx, s.dbPool, workMan)
	attrRepo := repository.NewSubjectAttributeRepository(ctx, s.dbPool, workMan)

	evaluator := business.NewEvaluator(resvRepo, ledgerRepo)
	resolver := business.NewAttributeResolver(attrRepo, nil, 60*time.Second)
	auditing := business.NewAuditing(nil)

	reservationBiz := business.NewReservationBusiness(
		resvRepo, ledgerRepo, candidateRepo, approvalRepo, s.policyRepo,
		evaluator, resolver, auditing, s.dbPool, nil,
	)

	_ = policyVerRepo // used indirectly via Save

	runtimeH := handlers.NewRuntimeService(reservationBiz)

	claimsInterceptor := &fixedClaimsInterceptor{
		tenantID:    "tenant-rt",
		partitionID: "partition-rt",
		profileID:   "wf-maker",
	}
	interceptorOpt := connect.WithInterceptors(claimsInterceptor)
	runtimePath, runtimeHandler := limitsv1connect.NewLimitsServiceHandler(runtimeH, interceptorOpt)

	mux := http.NewServeMux()
	mux.Handle(runtimePath, runtimeHandler)

	srv := httptest.NewServer(mux)
	s.T().Cleanup(srv.Close)

	s.runtimeClient = limitsv1connect.NewLimitsServiceClient(srv.Client(), srv.URL)
}

func (s *RuntimeIntegrationSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// applyRTIndexes reads and applies the SQL migration file containing the
// idempotency unique constraint and other runtime indexes.
func applyRTIndexes(t *testing.T, db *gorm.DB) {
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

// seedRTPolicy persists a policy via PolicyRepository.Save for test setup.
func (s *RuntimeIntegrationSuite) seedRTPolicy(in *limitsv1.PolicyObject) string {
	s.T().Helper()
	p, err := models.PolicyFromAPI(in)
	s.Require().NoError(err)
	p.ID = ""
	s.Require().NoError(s.policyRepo.Save(s.ctx, p))
	s.Require().NotEmpty(p.ID)
	return p.ID
}

// loanIntent builds a LOAN_DISBURSEMENT intent with the given KES units amount.
func loanIntent(tenantID string, units int64) *limitsv1.LimitIntent {
	return &limitsv1.LimitIntent{
		TenantId: tenantID,
		Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		Amount:   &moneypb.Money{CurrencyCode: "KES", Units: units},
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-rt-1"},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-rt-1"},
		},
		MakerId: "wf-maker",
	}
}

// perTxnMaxRT builds a per_txn_max policy object ready for seeding.
func perTxnMaxRT(capUnits int64, mode limitsv1.PolicyMode) *limitsv1.PolicyObject {
	return &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: capUnits},
		Mode:          mode,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour).UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
	}
}

// ─── Tests ────────────────────────────────────────────────────────────

// TestRuntimeIntegration_ReserveCommitFlow: enforce-mode policy with cap 100k KES.
// Intent 50k KES → ACTIVE; Commit → COMMITTED; ledger row created.
func (s *RuntimeIntegrationSuite) TestRuntimeIntegration_ReserveCommitFlow() {
	s.seedRTPolicy(perTxnMaxRT(100_000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE))

	intent := loanIntent("tenant-rt", 50_000)
	reserveResp, err := s.runtimeClient.Reserve(s.ctx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent:         intent,
		IdempotencyKey: "rt-commit-k1",
		Ttl:            durationpb.New(5 * time.Minute),
	}))
	s.Require().NoError(err)
	s.Require().NotNil(reserveResp.Msg.GetReservation())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE, reserveResp.Msg.GetReservation().GetStatus())

	reservationID := reserveResp.Msg.GetReservation().GetId()
	s.NotEmpty(reservationID)

	commitResp, err := s.runtimeClient.Commit(s.ctx, connect.NewRequest(&limitsv1.CommitRequest{
		ReservationId: reservationID,
	}))
	s.Require().NoError(err)
	s.Require().NotNil(commitResp.Msg.GetReservation())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_COMMITTED, commitResp.Msg.GetReservation().GetStatus())

	// Verify a ledger entry was created via direct DB query.
	var count int64
	s.dbPool.DB(s.ctx, true).
		Table(models.LedgerEntry{}.TableName()).
		Where("reservation_id = ?", reservationID).
		Count(&count)
	// The intent has two subjects (CLIENT + ORGANIZATION), so the business layer
	// creates one ledger entry per subject — at least 1 entry is required.
	s.GreaterOrEqual(count, int64(1), "committed reservation must have at least one ledger entry")
}

// TestRuntimeIntegration_ReserveDenied: intent exceeds cap → FailedPrecondition.
func (s *RuntimeIntegrationSuite) TestRuntimeIntegration_ReserveDenied() {
	s.seedRTPolicy(perTxnMaxRT(100_000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE))

	intent := loanIntent("tenant-rt", 200_000)
	_, err := s.runtimeClient.Reserve(s.ctx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent:         intent,
		IdempotencyKey: "rt-denied-k1",
		Ttl:            durationpb.New(5 * time.Minute),
	}))
	s.Require().Error(err)
	s.Equal(connect.CodeFailedPrecondition, connect.CodeOf(err))
}

// TestRuntimeIntegration_ReserveRelease: Reserve → ACTIVE; Release → RELEASED.
func (s *RuntimeIntegrationSuite) TestRuntimeIntegration_ReserveRelease() {
	s.seedRTPolicy(perTxnMaxRT(100_000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE))

	intent := loanIntent("tenant-rt", 50_000)
	reserveResp, err := s.runtimeClient.Reserve(s.ctx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent:         intent,
		IdempotencyKey: "rt-release-k1",
		Ttl:            durationpb.New(5 * time.Minute),
	}))
	s.Require().NoError(err)
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE, reserveResp.Msg.GetReservation().GetStatus())

	reservationID := reserveResp.Msg.GetReservation().GetId()

	releaseResp, err := s.runtimeClient.Release(s.ctx, connect.NewRequest(&limitsv1.ReleaseRequest{
		ReservationId: reservationID,
		Reason:        "test release",
	}))
	s.Require().NoError(err)
	s.Require().NotNil(releaseResp.Msg.GetReservation())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_RELEASED, releaseResp.Msg.GetReservation().GetStatus())
}

// TestRuntimeIntegration_Idempotency: same key + same intent → same reservation.
// Same key + different intent (different action) → AlreadyExists.
func (s *RuntimeIntegrationSuite) TestRuntimeIntegration_Idempotency() {
	// Seed policies for both actions.
	s.seedRTPolicy(perTxnMaxRT(100_000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE))
	s.seedRTPolicy(&limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_REQUEST,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: 100_000},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour).UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
	})

	intent1 := loanIntent("tenant-rt", 50_000)

	// First reserve with key "k1".
	resp1, err := s.runtimeClient.Reserve(s.ctx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent:         intent1,
		IdempotencyKey: "idem-rt-k1",
		Ttl:            durationpb.New(5 * time.Minute),
	}))
	s.Require().NoError(err)
	reservationID := resp1.Msg.GetReservation().GetId()
	s.NotEmpty(reservationID)

	// Second reserve with same key + same intent → returns same reservation_id.
	resp2, err := s.runtimeClient.Reserve(s.ctx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent:         intent1,
		IdempotencyKey: "idem-rt-k1",
		Ttl:            durationpb.New(5 * time.Minute),
	}))
	s.Require().NoError(err)
	s.Equal(reservationID, resp2.Msg.GetReservation().GetId(), "replayed idempotency key must return same reservation")

	// Third reserve with same key + different action → AlreadyExists.
	intent2 := &limitsv1.LimitIntent{
		TenantId: "tenant-rt",
		Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_REQUEST, // different action
		Amount:   &moneypb.Money{CurrencyCode: "KES", Units: 50_000},
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-rt-1"},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-rt-1"},
		},
		MakerId: "wf-maker",
	}
	_, err = s.runtimeClient.Reserve(s.ctx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent:         intent2,
		IdempotencyKey: "idem-rt-k1", // same key, different intent
		Ttl:            durationpb.New(5 * time.Minute),
	}))
	s.Require().Error(err)
	s.Equal(connect.CodeAlreadyExists, connect.CodeOf(err),
		"idempotency-key collision with different intent must return AlreadyExists")
}

func TestRuntimeIntegrationSuite(t *testing.T) {
	suite.Run(t, new(RuntimeIntegrationSuite))
}
