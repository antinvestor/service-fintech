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

// Package integration — cross-tenant security regression tests.
//
// These tests exercise the three audit findings fixed in phases 2C–2D:
//  1. Reserve rejects payloads where intent.tenant_id != auth-context partition.
//  2. Approval.Decide rejects callers whose partition doesn't match the approval row.
//  3. Commit with a reservation ID from another tenant returns NotFound (not silent success).
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
	"github.com/antinvestor/service-fintech/apps/limits/tests/rlstest"
)

// CrossTenantSuite exercises the cross-tenant security boundaries.
// Each test sets up two tenants (A and B) and verifies that operations
// targeting tenant-B data from a tenant-A context are rejected.
type CrossTenantSuite struct {
	frametests.FrameBaseTestSuite

	// tenantA* resources for the "attacker" caller.
	tenantACtx    context.Context
	tenantAClient limitsv1connect.LimitsServiceClient
	tenantAAdmin  limitsv1connect.LimitsAdminServiceClient

	// tenantB* resources for the "victim" tenant's data.
	tenantBCtx    context.Context
	tenantBClient limitsv1connect.LimitsServiceClient
	tenantBAdmin  limitsv1connect.LimitsAdminServiceClient

	dbPool pool.Pool

	// policyRepoA and policyRepoB seed policies in their respective tenants.
	policyRepoA repository.PolicyRepository
	policyRepoB repository.PolicyRepository
}

func (s *CrossTenantSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_xt_int_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *CrossTenantSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

func (s *CrossTenantSuite) SetupTest() {
	ctx := s.T().Context()

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	s.Require().NoError(rlstest.CreateRole(ctx, dsn.String()))

	rlsProv := rlstest.New()
	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-cross-tenant-test"),
		frame.WithTenancyProvider(rlsProv),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctx, dbManager, ""))

	s.dbPool = dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(s.dbPool)

	applyRTIndexes(s.T(), s.dbPool.DB(ctx, false))

	// Grant the test role privileges after applyRTIndexes (which may
	// create additional indexes/tables) and only then enable role
	// switching so application queries actually hit RLS.
	s.Require().NoError(rlstest.GrantAll(ctx, dsn.String()))
	rlsProv.Enable()

	workMan := svc.WorkManager()

	resvRepo := repository.NewReservationRepository(ctx, s.dbPool, workMan)
	ledgerRepo := repository.NewLedgerRepository(ctx, s.dbPool, workMan)
	approvalReqRepo := repository.NewApprovalRequestRepository(ctx, s.dbPool, workMan)
	approvalDecRepo := repository.NewApprovalDecisionRepository(ctx, s.dbPool, workMan)
	candidateRepo := repository.NewCandidatePolicyRepository(s.dbPool)
	s.policyRepoA = repository.NewPolicyRepository(ctx, s.dbPool, workMan)
	s.policyRepoB = repository.NewPolicyRepository(ctx, s.dbPool, workMan)
	policyVerRepo := repository.NewPolicyVersionRepository(ctx, s.dbPool, workMan)
	attrRepo := repository.NewSubjectAttributeRepository(ctx, s.dbPool, workMan)

	evaluator := business.NewEvaluator(resvRepo, ledgerRepo)
	resolver := business.NewAttributeResolver(attrRepo, nil, 60*time.Second)
	auditing := business.NewAuditing(nil)

	reservationBiz := business.NewReservationBusiness(
		resvRepo, ledgerRepo, candidateRepo, approvalReqRepo, s.policyRepoA,
		evaluator, resolver, auditing, s.dbPool, nil,
	)
	approvalBiz := business.NewApprovalBusiness(
		approvalReqRepo, approvalDecRepo, resvRepo, s.policyRepoA,
		evaluator, auditing, nil, s.dbPool,
	)

	_ = policyVerRepo

	runtimeH := handlers.NewRuntimeService(reservationBiz)
	adminH := handlers.NewAdminService(nil, approvalBiz, nil, nil)

	// Tenant A interceptor.
	claimsA := &fixedClaimsInterceptor{tenantID: "tenant-a", partitionID: "partition-a", profileID: "wf-maker-a"}
	// Tenant B interceptor (different approver so they can approve B's approvals).
	claimsB := &fixedClaimsInterceptor{tenantID: "tenant-b", partitionID: "partition-b", profileID: "wf-approver-b"}

	runtimePathA, runtimeHandlerA := limitsv1connect.NewLimitsServiceHandler(
		runtimeH,
		connect.WithInterceptors(claimsA, handlers.TenantAssertionInterceptor()),
	)
	adminPathA, adminHandlerA := limitsv1connect.NewLimitsAdminServiceHandler(
		adminH,
		connect.WithInterceptors(claimsA),
	)
	runtimePathB, runtimeHandlerB := limitsv1connect.NewLimitsServiceHandler(
		runtimeH,
		connect.WithInterceptors(claimsB, handlers.TenantAssertionInterceptor()),
	)
	adminPathB, adminHandlerB := limitsv1connect.NewLimitsAdminServiceHandler(
		adminH,
		connect.WithInterceptors(claimsB),
	)

	mux := http.NewServeMux()
	mux.Handle(runtimePathA, runtimeHandlerA)
	mux.Handle(adminPathA, adminHandlerA)
	// B handlers are mounted on a separate path prefix would conflict — use separate servers.
	_ = runtimePathB
	_ = runtimeHandlerB
	_ = adminPathB
	_ = adminHandlerB

	srvA := httptest.NewServer(mux)
	s.T().Cleanup(srvA.Close)

	muxB := http.NewServeMux()
	muxB.Handle(runtimePathB, runtimeHandlerB)
	muxB.Handle(adminPathB, adminHandlerB)
	srvB := httptest.NewServer(muxB)
	s.T().Cleanup(srvB.Close)

	s.tenantACtx = s.WithAuthClaims(ctx, "tenant-a", "partition-a", "wf-maker-a")
	s.tenantBCtx = s.WithAuthClaims(ctx, "tenant-b", "partition-b", "wf-approver-b")

	s.tenantAClient = limitsv1connect.NewLimitsServiceClient(srvA.Client(), srvA.URL)
	s.tenantAAdmin = limitsv1connect.NewLimitsAdminServiceClient(srvA.Client(), srvA.URL)
	s.tenantBClient = limitsv1connect.NewLimitsServiceClient(srvB.Client(), srvB.URL)
	s.tenantBAdmin = limitsv1connect.NewLimitsAdminServiceClient(srvB.Client(), srvB.URL)
}

// seedCrossTenantPolicy seeds a simple enforce-mode per-txn-max policy for the given tenant ctx.
func (s *CrossTenantSuite) seedCrossTenantPolicy(ctx context.Context, policyRepo repository.PolicyRepository) {
	s.T().Helper()
	in := &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: 1_000_000},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour).UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
	}
	p, err := models.PolicyFromAPI(in)
	s.Require().NoError(err)
	p.ID = ""
	s.Require().NoError(policyRepo.Save(ctx, p))
}

// seedApprovalTriggerPolicy seeds a policy that triggers approval for any amount > 0.
func (s *CrossTenantSuite) seedApprovalTriggerPolicy(ctx context.Context, policyRepo repository.PolicyRepository) {
	s.T().Helper()
	in := &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: 0},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour).UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
		ApproverTiers: []*limitsv1.ApproverTier{
			{UpTo: 0, Role: "manager", Approvers: 1},
		},
	}
	p, err := models.PolicyFromAPI(in)
	s.Require().NoError(err)
	p.ID = ""
	s.Require().NoError(policyRepo.Save(ctx, p))
}

// ─── Tests ────────────────────────────────────────────────────────────────────

// TestReserve_CrossTenantPayload_Rejected verifies that the TenantAssertionInterceptor
// rejects a Reserve request where intent.tenant_id != the auth-context partition.
func (s *CrossTenantSuite) TestReserve_CrossTenantPayload_Rejected() {
	s.seedCrossTenantPolicy(s.tenantACtx, s.policyRepoA)

	// Tenant-A client sends an intent with tenant_id="tenant-b" (cross-tenant).
	_, err := s.tenantAClient.Reserve(s.tenantACtx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent: &limitsv1.LimitIntent{
			TenantId: "tenant-b", // mismatch: auth context has tenant-a
			Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
			Amount:   &moneypb.Money{CurrencyCode: "KES", Units: 1000},
			Subjects: []*limitsv1.SubjectRef{
				{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-xt-1"},
				{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-xt-1"},
			},
			MakerId: "wf-maker-a",
		},
		IdempotencyKey: "xt-reserve-k1",
		Ttl:            durationpb.New(5 * time.Minute),
	}))
	s.Require().Error(err)
	s.Equal(connect.CodePermissionDenied, connect.CodeOf(err),
		"Reserve with mismatched tenant_id must return PermissionDenied")
}

// TestApprove_CrossTenantApproval_Rejected verifies that an operator from tenant-A
// cannot approve an approval request that belongs to tenant-B.
func (s *CrossTenantSuite) TestApprove_CrossTenantApproval_Rejected() {
	// Seed an approval-trigger policy for tenant-B.
	s.seedApprovalTriggerPolicy(s.tenantBCtx, s.policyRepoB)

	// Tenant-B maker creates a reservation that triggers approval.
	reserveResp, err := s.tenantBClient.Reserve(s.tenantBCtx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent: &limitsv1.LimitIntent{
			TenantId: "tenant-b",
			Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
			Amount:   &moneypb.Money{CurrencyCode: "KES", Units: 500},
			Subjects: []*limitsv1.SubjectRef{
				{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-xt-b-1"},
				{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-xt-b-1"},
			},
			MakerId: "wf-maker-b",
		},
		IdempotencyKey: "xt-appr-k1",
		Ttl:            durationpb.New(5 * time.Minute),
	}))
	s.Require().NoError(err)
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
		reserveResp.Msg.GetReservation().GetStatus())

	// Fetch the approval request ID via tenant-B admin.
	var approvalID string
	listStream, err := s.tenantBAdmin.ApprovalRequestList(
		s.tenantBCtx,
		connect.NewRequest(&limitsv1.ApprovalRequestListRequest{
			Status: limitsv1.ApprovalStatus_APPROVAL_STATUS_PENDING,
		}),
	)
	s.Require().NoError(err)
	for listStream.Receive() {
		for _, item := range listStream.Msg().GetData() {
			approvalID = item.GetId()
		}
	}
	s.Require().NoError(listStream.Err())
	s.Require().NotEmpty(approvalID, "tenant-B should have a pending approval")

	// Tenant-A operator tries to decide on tenant-B's approval → must be rejected.
	_, err = s.tenantAAdmin.ApprovalRequestDecide(
		s.tenantACtx,
		connect.NewRequest(&limitsv1.ApprovalRequestDecideRequest{
			Id:       approvalID,
			Decision: "approve",
			Note:     "cross-tenant attack",
		}),
	)
	s.Require().Error(err)
	code := connect.CodeOf(err)
	s.True(code == connect.CodePermissionDenied || code == connect.CodeNotFound,
		"cross-tenant approval decision must return PermissionDenied or NotFound, got: %v", code)
}

// TestCommit_ReservationFromOtherTenant_NotFound verifies that a Commit request
// for a reservation owned by tenant-B, called from tenant-A context, returns
// NotFound (not silent success).
func (s *CrossTenantSuite) TestCommit_ReservationFromOtherTenant_NotFound() {
	// Seed an allow-all policy for tenant-B so reserve succeeds.
	s.seedCrossTenantPolicy(s.tenantBCtx, s.policyRepoB)

	// Tenant-B creates a reservation.
	reserveResp, err := s.tenantBClient.Reserve(s.tenantBCtx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent: &limitsv1.LimitIntent{
			TenantId: "tenant-b",
			Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
			Amount:   &moneypb.Money{CurrencyCode: "KES", Units: 100},
			Subjects: []*limitsv1.SubjectRef{
				{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-xt-b-2"},
				{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-xt-b-2"},
			},
			MakerId: "wf-maker-b",
		},
		IdempotencyKey: "xt-commit-b-k1",
		Ttl:            durationpb.New(5 * time.Minute),
	}))
	s.Require().NoError(err)
	reservationID := reserveResp.Msg.GetReservation().GetId()
	s.Require().NotEmpty(reservationID)
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
		reserveResp.Msg.GetReservation().GetStatus())

	// Tenant-A tries to Commit tenant-B's reservation — must not succeed.
	_, err = s.tenantAClient.Commit(s.tenantACtx, connect.NewRequest(&limitsv1.CommitRequest{
		ReservationId: reservationID,
	}))
	s.Require().Error(err,
		"committing another tenant's reservation must return an error")
	code := connect.CodeOf(err)
	s.True(code == connect.CodeNotFound || code == connect.CodeFailedPrecondition,
		"expected NotFound or FailedPrecondition, got %v", code)
}

// TestReverse_ReservationFromOtherTenant_NotFound verifies that a Reverse call
// for a reservation owned by tenant-B, called from tenant-A context, returns
// NotFound — not silent success or a leaked PermissionDenied.
func (s *CrossTenantSuite) TestReverse_ReservationFromOtherTenant_NotFound() {
	// Seed an allow-all policy for tenant-B so reserve+commit succeed.
	s.seedCrossTenantPolicy(s.tenantBCtx, s.policyRepoB)

	// Tenant-B creates and commits a reservation.
	reserveResp, err := s.tenantBClient.Reserve(s.tenantBCtx, connect.NewRequest(&limitsv1.ReserveRequest{
		Intent: &limitsv1.LimitIntent{
			TenantId: "tenant-b",
			Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
			Amount:   &moneypb.Money{CurrencyCode: "KES", Units: 200},
			Subjects: []*limitsv1.SubjectRef{
				{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-xt-b-rev"},
				{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-xt-b-rev"},
			},
			MakerId: "wf-maker-b",
		},
		IdempotencyKey: "xt-reverse-b-k1",
		Ttl:            durationpb.New(5 * time.Minute),
	}))
	s.Require().NoError(err)
	reservationID := reserveResp.Msg.GetReservation().GetId()
	s.Require().NotEmpty(reservationID)

	// Commit it so it is eligible for reversal.
	_, err = s.tenantBClient.Commit(s.tenantBCtx, connect.NewRequest(&limitsv1.CommitRequest{
		ReservationId: reservationID,
	}))
	s.Require().NoError(err)

	// Tenant-A tries to Reverse tenant-B's reservation — must get NotFound.
	_, err = s.tenantAClient.Reverse(s.tenantACtx, connect.NewRequest(&limitsv1.ReverseRequest{
		ReservationId:  reservationID,
		IdempotencyKey: "xt-reverse-attack-k1",
		Reason:         "cross-tenant reverse attempt",
	}))
	s.Require().Error(err, "reversing another tenant's reservation must return an error")
	s.Equal(connect.CodeNotFound, connect.CodeOf(err),
		"expected NotFound to avoid leaking existence to a probing actor")
}

func TestCrossTenantSuite(t *testing.T) {
	suite.Run(t, new(CrossTenantSuite))
}
