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

// Package integration provides end-to-end tests for limits.Gate against a real
// limits backend (Postgres testcontainer + httptest.Server). These tests verify
// the three canonical Gate outcomes:
//
//  1. Gate allowed  — policy permits amount → Reserve ACTIVE → handler runs →
//     Commit → ledger entry visible.
//  2. Gate denied   — policy denies amount → Reserve FailedPrecondition →
//     handler never runs → no ledger entry.
//  3. Gate pending  — approver tier covers the amount → Reserve returns
//     PENDING_APPROVAL → Gate returns *limits.PendingApprovalError →
//     reservation row in PENDING_APPROVAL state persists.
//
// Approach: simplified limits-only (no loans layer). The test drives
// limits.Gate directly with a real limitsv1connect.LimitsServiceClient
// pointed at an httptest.Server backed by a real reservationBiz+repositories.
// This proves the Gate function end-to-end without requiring the full loans
// service wire-up. Unit tests in apps/loans/service/business/disbursement_test.go
// already cover the loans→Gate integration path via stubs.
package integration

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	moneypb "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/frametests"
	"github.com/pitabwire/frame/v2/frametests/definition"
	testpostgres "github.com/pitabwire/frame/v2/frametests/deps/testpostgres"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"
	"google.golang.org/protobuf/types/known/durationpb"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/handlers"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

// GateIntegrationSuite drives limits.Gate against a real limits backend to
// verify allowed / denied / pending outcomes end-to-end.
type GateIntegrationSuite struct {
	frametests.FrameBaseTestSuite

	// gateClient is a real Connect client pointing at the test httptest.Server.
	gateClient limitsv1connect.LimitsServiceClient

	// dbPool is kept for direct DB verification (ledger, reservation counts).
	dbPool pool.Pool

	// policyRepo is used to seed policies before each test.
	policyRepo repository.PolicyRepository

	// resvRepo is used for direct reservation-state assertions.
	resvRepo repository.ReservationRepository

	// ctx is the test context with auth claims injected.
	ctx context.Context
}

func (s *GateIntegrationSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_gate_int_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *GateIntegrationSuite) SetupTest() {
	ctx := s.T().Context()
	ctx = s.WithAuthClaims(ctx, "tenant-gate", "partition-gate", "wf-maker")
	s.ctx = ctx

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-gate-integration-test"),
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
	s.resvRepo = repository.NewReservationRepository(ctx, s.dbPool, workMan)
	ledgerRepo := repository.NewLedgerRepository(ctx, s.dbPool, workMan)
	approvalRepo := repository.NewApprovalRequestRepository(ctx, s.dbPool, workMan)
	candidateRepo := repository.NewCandidatePolicyRepository(s.dbPool)
	s.policyRepo = repository.NewPolicyRepository(ctx, s.dbPool, workMan)
	policyVerRepo := repository.NewPolicyVersionRepository(ctx, s.dbPool, workMan)
	attrRepo := repository.NewSubjectAttributeRepository(ctx, s.dbPool, workMan)

	_ = policyVerRepo // used indirectly via Save

	evaluator := business.NewEvaluator(s.resvRepo, ledgerRepo)
	resolver := business.NewAttributeResolver(attrRepo, nil, 60*time.Second)
	auditing := business.NewAuditing(nil)

	reservationBiz := business.NewReservationBusiness(
		s.resvRepo, ledgerRepo, candidateRepo, approvalRepo, s.policyRepo,
		evaluator, resolver, auditing, s.dbPool, nil,
	)

	runtimeH := handlers.NewRuntimeService(reservationBiz)

	claimsInterceptor := &fixedClaimsInterceptor{
		tenantID:    "tenant-gate",
		partitionID: "partition-gate",
		profileID:   "wf-maker",
	}
	interceptorOpt := connect.WithInterceptors(claimsInterceptor)
	runtimePath, runtimeHandler := limitsv1connect.NewLimitsServiceHandler(runtimeH, interceptorOpt)

	mux := http.NewServeMux()
	mux.Handle(runtimePath, runtimeHandler)

	srv := httptest.NewServer(mux)
	s.T().Cleanup(srv.Close)

	s.gateClient = limitsv1connect.NewLimitsServiceClient(srv.Client(), srv.URL)
}

func (s *GateIntegrationSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// seedPolicy persists a policy via PolicyRepository.Save for test setup.
func (s *GateIntegrationSuite) seedPolicy(in *limitsv1.PolicyObject) string {
	s.T().Helper()
	p, err := models.PolicyFromAPI(in)
	s.Require().NoError(err)
	p.ID = ""
	s.Require().NoError(s.policyRepo.Save(s.ctx, p))
	s.Require().NotEmpty(p.ID)
	return p.ID
}

// gateIntent builds a LOAN_DISBURSEMENT LimitIntent for the given KES units amount.
// units is in KES major units (Gate will convert via the limits service).
func gateIntent(units int64) *limitsv1.LimitIntent {
	return &limitsv1.LimitIntent{
		TenantId: "tenant-gate",
		Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		Amount:   &moneypb.Money{CurrencyCode: "KES", Units: units},
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-gate-1"},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-gate-1"},
		},
		MakerId: "wf-maker",
	}
}

// perTxnMaxPolicy builds a per_txn_max policy object ready for seeding.
// capUnits is in KES major units.
func perTxnMaxPolicy(capUnits int64, mode limitsv1.PolicyMode) *limitsv1.PolicyObject {
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

// TestGate_Allowed_LedgerPopulated seeds a policy that permits the intent
// amount (5000 KES < cap 10000 KES). Gate must succeed and a ledger entry
// must be visible for the committed reservation.
func (s *GateIntegrationSuite) TestGate_Allowed_LedgerPopulated() {
	// Cap = 10,000 KES; intent = 5,000 KES → allowed.
	s.seedPolicy(perTxnMaxPolicy(10_000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE))

	intent := gateIntent(5_000)
	idempKey := "gate-allowed-k1"

	var capturedReservationID string
	handlerCalled := false

	err := limits.Gate(s.ctx, s.gateClient, intent, idempKey, limits.ModeEnforce,
		func(_ context.Context, reservationID string) error {
			capturedReservationID = reservationID
			handlerCalled = true
			return nil
		},
	)

	s.Require().NoError(err, "Gate should succeed when intent is within policy cap")
	s.True(handlerCalled, "handler must be invoked for an allowed reservation")
	s.NotEmpty(capturedReservationID)

	// Verify a ledger entry exists for the committed reservation.
	var count int64
	s.dbPool.DB(s.ctx, true).
		Table(models.LedgerEntry{}.TableName()).
		Where("reservation_id = ?", capturedReservationID).
		Count(&count)
	s.GreaterOrEqual(count, int64(1),
		"committed reservation must have at least one ledger entry (one per subject)")
}

// TestGate_Denied_NoLedgerEntry seeds a policy that denies the intent amount
// (5000 KES > cap 1000 KES). Gate must return an error and no ledger entry
// must be created.
func (s *GateIntegrationSuite) TestGate_Denied_NoLedgerEntry() {
	// Cap = 1,000 KES; intent = 5,000 KES → denied.
	s.seedPolicy(perTxnMaxPolicy(1_000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE))

	intent := gateIntent(5_000)
	idempKey := "gate-denied-k1"

	handlerCalled := false

	err := limits.Gate(s.ctx, s.gateClient, intent, idempKey, limits.ModeEnforce,
		func(_ context.Context, _ string) error {
			handlerCalled = true
			return nil
		},
	)

	s.Require().Error(err, "Gate should return an error when policy denies the intent")
	s.Equal(connect.CodeFailedPrecondition, connect.CodeOf(err),
		"denied reserve must surface as FailedPrecondition")
	s.False(handlerCalled, "handler must NOT be called when the gate is denied")

	// Verify no ledger entries were created.
	var count int64
	s.dbPool.DB(s.ctx, true).
		Table(models.LedgerEntry{}.TableName()).
		Count(&count)
	s.Equal(int64(0), count, "no ledger entries should exist after a gate denial")
}

// TestGate_Pending_TypedError seeds a policy with an approver tier that covers
// the intent amount. Gate must return a *limits.PendingApprovalError and a
// reservation row in PENDING_APPROVAL state must persist.
func (s *GateIntegrationSuite) TestGate_Pending_TypedError() {
	// Cap = 1,000 KES with a catch-all approver tier (up_to=0 covers anything above cap).
	// Intent = 5,000 KES exceeds cap → triggers approver tier.
	tierPolicy := perTxnMaxPolicy(1_000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE)
	tierPolicy.ApproverTiers = []*limitsv1.ApproverTier{
		{UpTo: 0, Role: "branch_manager", Approvers: 1},
	}
	s.seedPolicy(tierPolicy)

	intent := gateIntent(5_000)
	idempKey := "gate-pending-k1"

	handlerCalled := false

	err := limits.Gate(s.ctx, s.gateClient, intent, idempKey, limits.ModeEnforce,
		func(_ context.Context, _ string) error {
			handlerCalled = true
			return nil
		},
	)

	s.Require().Error(err, "Gate must return an error for PENDING_APPROVAL")
	s.False(handlerCalled, "handler must NOT be called when reservation is pending approval")

	// The error must wrap a *limits.PendingApprovalError.
	var pendingErr *limits.PendingApprovalError
	s.Require().ErrorAs(err, &pendingErr,
		"error must be (or wrap) *limits.PendingApprovalError; got: %T / %v", err, err)
	s.NotEmpty(pendingErr.ReservationID,
		"PendingApprovalError must carry the reservation ID")

	// Verify the reservation row is in PENDING_APPROVAL state.
	resv, dbErr := s.resvRepo.GetByID(s.ctx, pendingErr.ReservationID)
	s.Require().NoError(dbErr, "reservation row must be persisted")
	s.Equal(models.ReservationStatusPendingApproval, resv.Status,
		"reservation status must be pending_approval")
}

func TestGateIntegrationSuite(t *testing.T) {
	suite.Run(t, new(GateIntegrationSuite))
}
