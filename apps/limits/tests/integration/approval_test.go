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
// approval round-trip. Tests run against a real Postgres testcontainer and a real
// Connect-over-HTTP transport using net/http/httptest.Server.
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
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/frametests"
	"github.com/pitabwire/frame/frametests/definition"
	testpostgres "github.com/pitabwire/frame/frametests/deps/testpostgres"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"
	"google.golang.org/protobuf/types/known/durationpb"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/handlers"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// headerProfileInterceptor is a Connect server-side interceptor that reads the
// "x-test-as-profile" request header and overrides the auth claims so the
// handler sees the correct profile_id. This lets maker and approver calls share
// a single httptest.Server while injecting different identities.
type headerProfileInterceptor struct {
	tenantID       string
	partitionID    string
	defaultProfile string
}

func (h *headerProfileInterceptor) WrapUnary(next connect.UnaryFunc) connect.UnaryFunc {
	return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
		return next(h.injectClaims(ctx, req.Header()), req)
	}
}

func (h *headerProfileInterceptor) WrapStreamingClient(next connect.StreamingClientFunc) connect.StreamingClientFunc {
	return next
}

func (h *headerProfileInterceptor) WrapStreamingHandler(
	next connect.StreamingHandlerFunc,
) connect.StreamingHandlerFunc {
	return func(ctx context.Context, conn connect.StreamingHandlerConn) error {
		return next(h.injectClaims(ctx, conn.RequestHeader()), conn)
	}
}

func (h *headerProfileInterceptor) injectClaims(ctx context.Context, header http.Header) context.Context {
	profileID := header.Get("x-test-as-profile")
	if profileID == "" {
		profileID = h.defaultProfile
	}
	fci := &fixedClaimsInterceptor{
		tenantID:    h.tenantID,
		partitionID: h.partitionID,
		profileID:   profileID,
	}
	return fci.injectClaims(ctx)
}

// ApprovalIntegrationSuite exercises the full maker→approve→commit round-trip
// over LimitsService + LimitsAdminService via a shared httptest.Server that
// reads "x-test-as-profile" to switch identities.
type ApprovalIntegrationSuite struct {
	frametests.FrameBaseTestSuite

	// makerClient calls Reserve/Commit as the maker (wf-maker).
	makerClient limitsv1connect.LimitsServiceClient

	// approverClient calls ApprovalRequestList/Decide as the approver (wf-approver).
	// The "x-test-as-profile: wf-approver" header is set per request.
	approverAdminClient limitsv1connect.LimitsAdminServiceClient

	// dbPool is kept for direct DB verification.
	dbPool pool.Pool

	// policyRepo is used to seed policies before each test.
	policyRepo repository.PolicyRepository

	// ctx is the test context with auth claims for the maker.
	ctx context.Context
}

func (s *ApprovalIntegrationSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_appr_int_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *ApprovalIntegrationSuite) SetupTest() {
	ctx := s.T().Context()
	ctx = s.WithAuthClaims(ctx, "tenant-ap", "partition-ap", "wf-maker")
	s.ctx = ctx

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-approval-integration-test"),
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
	approvalReqRepo := repository.NewApprovalRequestRepository(ctx, s.dbPool, workMan)
	approvalDecRepo := repository.NewApprovalDecisionRepository(ctx, s.dbPool, workMan)
	candidateRepo := repository.NewCandidatePolicyRepository(s.dbPool)
	s.policyRepo = repository.NewPolicyRepository(ctx, s.dbPool, workMan)
	policyVerRepo := repository.NewPolicyVersionRepository(ctx, s.dbPool, workMan)
	attrRepo := repository.NewSubjectAttributeRepository(ctx, s.dbPool, workMan)

	evaluator := business.NewEvaluator(resvRepo, ledgerRepo)
	resolver := business.NewAttributeResolver(attrRepo, nil, 60*time.Second)
	auditing := business.NewAuditing(nil)

	reservationBiz := business.NewReservationBusiness(
		resvRepo, ledgerRepo, candidateRepo, approvalReqRepo, s.policyRepo,
		evaluator, resolver, auditing, s.dbPool, nil,
	)
	approvalBiz := business.NewApprovalBusiness(
		approvalReqRepo, approvalDecRepo, resvRepo, s.policyRepo,
		evaluator, auditing, nil, s.dbPool,
	)

	_ = policyVerRepo // used indirectly via Save

	runtimeH := handlers.NewRuntimeService(reservationBiz)
	adminH := handlers.NewAdminService(nil, approvalBiz, nil, nil)

	// A single interceptor that reads x-test-as-profile to switch identities.
	headerInterceptor := &headerProfileInterceptor{
		tenantID:       "tenant-ap",
		partitionID:    "partition-ap",
		defaultProfile: "wf-maker",
	}
	interceptorOpt := connect.WithInterceptors(headerInterceptor)

	runtimePath, runtimeHandler := limitsv1connect.NewLimitsServiceHandler(runtimeH, interceptorOpt)
	adminPath, adminHandler := limitsv1connect.NewLimitsAdminServiceHandler(adminH, interceptorOpt)

	mux := http.NewServeMux()
	mux.Handle(runtimePath, runtimeHandler)
	mux.Handle(adminPath, adminHandler)

	srv := httptest.NewServer(mux)
	s.T().Cleanup(srv.Close)

	s.makerClient = limitsv1connect.NewLimitsServiceClient(srv.Client(), srv.URL)

	// approverAdminClient sends "x-test-as-profile: wf-approver" on each request.
	s.approverAdminClient = limitsv1connect.NewLimitsAdminServiceClient(
		srv.Client(),
		srv.URL,
		connect.WithInterceptors(&headerInjectorInterceptor{
			key:   "x-test-as-profile",
			value: "wf-approver",
		}),
	)
}

func (s *ApprovalIntegrationSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// headerInjectorInterceptor is a Connect client-side interceptor that adds a
// fixed header to every outgoing unary or streaming request.
type headerInjectorInterceptor struct {
	key   string
	value string
}

func (h *headerInjectorInterceptor) WrapUnary(next connect.UnaryFunc) connect.UnaryFunc {
	return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
		req.Header().Set(h.key, h.value)
		return next(ctx, req)
	}
}

func (h *headerInjectorInterceptor) WrapStreamingClient(next connect.StreamingClientFunc) connect.StreamingClientFunc {
	return func(ctx context.Context, spec connect.Spec) connect.StreamingClientConn {
		conn := next(ctx, spec)
		conn.RequestHeader().Set(h.key, h.value)
		return conn
	}
}

func (h *headerInjectorInterceptor) WrapStreamingHandler(
	next connect.StreamingHandlerFunc,
) connect.StreamingHandlerFunc {
	return next
}

// seedApprovalPolicy persists a policy with cap=100 KES (10,000 minor units) and
// an approver tier with up_to=0 (unlimited). Any intent above 100 KES triggers approval.
func (s *ApprovalIntegrationSuite) seedApprovalPolicy() string {
	s.T().Helper()
	in := &limitsv1.PolicyObject{
		Scope:        limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:       limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:  limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode: "KES",
		LimitKind:    limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		// cap = 100 KES = 10,000 minor units
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: 100},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour).UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
		ApproverTiers: []*limitsv1.ApproverTier{
			// UpTo=0 means catch-all: approve any amount above cap.
			{UpTo: 0, Role: "branch_manager", Approvers: 1},
		},
	}
	p, err := models.PolicyFromAPI(in)
	s.Require().NoError(err)
	p.ID = ""
	s.Require().NoError(s.policyRepo.Save(s.ctx, p))
	s.Require().NotEmpty(p.ID)
	return p.ID
}

// ─── Tests ────────────────────────────────────────────────────────────

// TestApprovalIntegration_FullRoundTrip:
//
//  1. Seed policy: cap=0 minor units (anything >0 triggers approval), approver_tiers up_to=0 with role="branch_manager".
//  2. Maker (wf-maker) calls Reserve → expect PENDING_APPROVAL.
//  3. Approver (wf-approver) calls ApprovalRequestList → expect 1 PENDING row.
//  4. Approver calls ApprovalRequestDecide(approve) → expect APPROVED.
//  5. Maker calls Commit → expect COMMITTED.
//  6. Verify a ledger entry was created.
func (s *ApprovalIntegrationSuite) TestApprovalIntegration_FullRoundTrip() {
	// Seed: cap = 100 KES (10,000 minor units); tier up_to=0 (catch-all).
	// Intent of 500 KES exceeds the cap → triggers approval.
	s.seedApprovalPolicy()

	intent := &limitsv1.LimitIntent{
		TenantId: "tenant-ap",
		Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		// 500 KES = 50,000 minor units — above the 100 KES cap.
		Amount: &moneypb.Money{CurrencyCode: "KES", Units: 500},
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-ap-1"},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-ap-1"},
		},
		MakerId: "wf-maker",
	}

	// Step 1: maker calls Reserve → should be PENDING_APPROVAL.
	reserveResp, err := s.makerClient.Reserve(s.ctx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent:         intent,
		IdempotencyKey: "appr-round-trip-k1",
		Ttl:            durationpb.New(5 * time.Minute),
	}))
	s.Require().NoError(err)
	s.Require().NotNil(reserveResp.Msg.GetReservation())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
		reserveResp.Msg.GetReservation().GetStatus(),
		"reservation should be PENDING_APPROVAL when approval tiers require it")
	s.True(reserveResp.Msg.GetCheck().GetRequiresApproval())

	reservationID := reserveResp.Msg.GetReservation().GetId()
	s.NotEmpty(reservationID)

	// Step 2: approver lists approval requests → expect 1 PENDING row.
	var approvalID string
	listStream, err := s.approverAdminClient.ApprovalRequestList(
		s.ctx,
		connect.NewRequest(&limitsv1.ApprovalRequestListRequest{
			Status: limitsv1.ApprovalStatus_APPROVAL_STATUS_PENDING,
		}),
	)
	s.Require().NoError(err)
	var approvalItems []*limitsv1.ApprovalRequestObject
	for listStream.Receive() {
		approvalItems = append(approvalItems, listStream.Msg().GetData()...)
	}
	s.Require().NoError(listStream.Err())
	s.Require().Len(approvalItems, 1, "there should be exactly 1 pending approval request")
	approvalID = approvalItems[0].GetId()
	s.NotEmpty(approvalID)
	s.Equal(limitsv1.ApprovalStatus_APPROVAL_STATUS_PENDING, approvalItems[0].GetStatus())

	// Step 3: approver calls ApprovalRequestDecide(approve).
	approverCtx := s.ctx // approverAdminClient already injects the header
	decideResp, err := s.approverAdminClient.ApprovalRequestDecide(
		approverCtx,
		connect.NewRequest(&limitsv1.ApprovalRequestDecideRequest{
			Id:       approvalID,
			Decision: "approve",
			Note:     "approved in integration test",
		}),
	)
	s.Require().NoError(err)
	s.Require().NotNil(decideResp.Msg.GetData())
	s.Equal(limitsv1.ApprovalStatus_APPROVAL_STATUS_APPROVED, decideResp.Msg.GetData().GetStatus(),
		"approval should transition to APPROVED after last required approver")

	// Step 4: maker calls Commit → reservation should now be ACTIVE then COMMITTED.
	commitResp, err := s.makerClient.Commit(s.ctx, connect.NewRequest(&limitsv1.CommitRequest{
		ReservationId: reservationID,
	}))
	s.Require().NoError(err)
	s.Require().NotNil(commitResp.Msg.GetReservation())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_COMMITTED,
		commitResp.Msg.GetReservation().GetStatus(),
		"reservation should be COMMITTED after approved and committed")

	// Step 5: verify a ledger entry was created.
	var count int64
	s.dbPool.DB(s.ctx, true).
		Table(models.LedgerEntry{}.TableName()).
		Where("reservation_id = ?", reservationID).
		Count(&count)
	// The intent has two subjects (CLIENT + ORGANIZATION), so at least 1 ledger entry is created.
	s.GreaterOrEqual(count, int64(1), "committed reservation must have at least one ledger entry")
}

func TestApprovalIntegrationSuite(t *testing.T) {
	suite.Run(t, new(ApprovalIntegrationSuite))
}
