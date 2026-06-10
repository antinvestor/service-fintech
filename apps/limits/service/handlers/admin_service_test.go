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
	"github.com/antinvestor/service-fintech/pkg/audit"
)

type AdminHandlerSuite struct {
	frametests.FrameBaseTestSuite
	handler *handlers.AdminService

	// saved for sub-test use
	dbPool       pool.Pool
	policyRepo   repository.PolicyRepository
	approvalBiz  business.ApprovalBusiness
	ledgerBiz    business.LedgerSearchBusiness
	resvBiz      business.ReservationBusiness
	approvalRepo repository.ApprovalRequestRepository
	ledgerRepo   repository.LedgerRepository
}

func (s *AdminHandlerSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *AdminHandlerSuite) SetupTest() {
	ctx := s.T().Context()
	ctx = s.WithAuthClaims(ctx, "tenant-a", "partition-a", "wf-maker-1")

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-handler-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctx, dbManager, ""))

	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	applyAdminHandlerIndexes(s.T(), dbPool.DB(ctx, false))

	workMan := svc.WorkManager()

	policyRepo := repository.NewPolicyRepository(ctx, dbPool, workMan)
	versionRepo := repository.NewPolicyVersionRepository(ctx, dbPool, workMan)
	resvRepo := repository.NewReservationRepository(ctx, dbPool, workMan)
	ledgerRepo := repository.NewLedgerRepository(ctx, dbPool, workMan)
	approvalRepo := repository.NewApprovalRequestRepository(ctx, dbPool, workMan)
	decisionRepo := repository.NewApprovalDecisionRepository(ctx, dbPool, workMan)
	candidateRepo := repository.NewCandidatePolicyRepository(dbPool)
	attrRepo := repository.NewSubjectAttributeRepository(ctx, dbPool, workMan)

	evaluator := business.NewEvaluator(resvRepo, ledgerRepo)
	resolver := business.NewAttributeResolver(attrRepo, nil, 60*time.Second)
	auditing := business.NewAuditing(nil)

	policyBiz := business.NewPolicyBusiness(policyRepo, versionRepo, nil, nil, nil, nil)
	approvalBiz := business.NewApprovalBusiness(
		approvalRepo,
		decisionRepo,
		resvRepo,
		policyRepo,
		evaluator,
		auditing,
		nil,
		dbPool,
	)
	ledgerBiz := business.NewLedgerSearchBusiness(ledgerRepo)
	resvBiz := business.NewReservationBusiness(
		resvRepo, ledgerRepo, candidateRepo, approvalRepo, policyRepo,
		evaluator, resolver, auditing, dbPool, nil,
	)

	s.dbPool = dbPool
	s.policyRepo = policyRepo
	s.approvalBiz = approvalBiz
	s.ledgerBiz = ledgerBiz
	s.resvBiz = resvBiz
	s.approvalRepo = approvalRepo
	s.ledgerRepo = ledgerRepo
	s.handler = handlers.NewAdminService(policyBiz, approvalBiz, ledgerBiz, nil)
}

func (s *AdminHandlerSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

func (s *AdminHandlerSuite) TestPolicySaveThenGet() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "")
	in := &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: 100},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_SHADOW,
		EffectiveFrom: timestamppb.New(time.Now().UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
	}

	saveResp, err := s.handler.PolicySave(ctx, connect.NewRequest(&limitsv1.PolicySaveRequest{Data: in}))
	s.Require().NoError(err)
	s.NotEmpty(saveResp.Msg.GetData().GetId())

	getResp, err := s.handler.PolicyGet(
		ctx,
		connect.NewRequest(&limitsv1.PolicyGetRequest{Id: saveResp.Msg.GetData().GetId()}),
	)
	s.Require().NoError(err)
	s.Equal(saveResp.Msg.GetData().GetId(), getResp.Msg.GetData().GetId())
}

func (s *AdminHandlerSuite) TestPolicyGetMissingReturnsNotFound() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "")
	_, err := s.handler.PolicyGet(ctx, connect.NewRequest(&limitsv1.PolicyGetRequest{Id: "nonexistent"}))
	s.Require().Error(err)
	s.Equal(connect.CodeNotFound, connect.CodeOf(err))
}

func (s *AdminHandlerSuite) TestPolicyDelete() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "")
	in := &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_REQUEST,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: 1},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_SHADOW,
		EffectiveFrom: timestamppb.New(time.Now().UTC()),
	}
	saveResp, err := s.handler.PolicySave(ctx, connect.NewRequest(&limitsv1.PolicySaveRequest{Data: in}))
	s.Require().NoError(err)

	_, err = s.handler.PolicyDelete(
		ctx,
		connect.NewRequest(&limitsv1.PolicyDeleteRequest{Id: saveResp.Msg.GetData().GetId()}),
	)
	s.Require().NoError(err)

	_, err = s.handler.PolicyGet(
		ctx,
		connect.NewRequest(&limitsv1.PolicyGetRequest{Id: saveResp.Msg.GetData().GetId()}),
	)
	s.Equal(connect.CodeNotFound, connect.CodeOf(err))
}

// applyAdminHandlerIndexes loads and applies the runtime SQL migration.
func applyAdminHandlerIndexes(t *testing.T, db *gorm.DB) {
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

// seedAdminPolicy persists a policy via the repo for handler-level tests.
func (s *AdminHandlerSuite) seedAdminPolicy(ctx context.Context, in *limitsv1.PolicyObject) *models.Policy {
	s.T().Helper()
	p, err := models.PolicyFromAPI(in)
	s.Require().NoError(err)
	p.ID = ""
	s.Require().NoError(s.policyRepo.Save(ctx, p))
	s.Require().NotEmpty(p.ID)
	saved, err := s.policyRepo.Get(ctx, p.ID)
	s.Require().NoError(err)
	return saved
}

// reservePendingApproval creates a policy and a reservation that requires approval.
func (s *AdminHandlerSuite) reservePendingApproval(
	ctx context.Context,
	capUnits, intentUnits int64,
	approvers int32,
) string {
	s.T().Helper()
	pol := &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: capUnits},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour).UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
		ApproverTiers: []*limitsv1.ApproverTier{
			{UpTo: 0, Role: "branch_manager", Approvers: approvers},
		},
	}
	s.seedAdminPolicy(ctx, pol)

	intent := &limitsv1.LimitIntent{
		TenantId: "tenant-a",
		Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		Amount:   &moneypb.Money{CurrencyCode: "KES", Units: intentUnits},
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-admin-1"},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-admin-1"},
		},
		MakerId: "wf-maker-1",
	}
	resp, err := s.resvBiz.Reserve(ctx, intent, "idem-admin-"+util.IDString(), 5*time.Minute)
	s.Require().NoError(err)
	s.Require().Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
		resp.GetReservation().GetStatus())
	return resp.GetReservation().GetId()
}

// ─── Approval handler tests ─────────────────────────────────────────────

// TestApprovalRequestList: seed approval rows; exercise via business layer since
// ApprovalRequestList is a streaming RPC and connect.ServerStream is a concrete struct
// that cannot be constructed directly in unit tests. The handler is one line of
// delegation so the business layer test provides the meaningful coverage.
func (s *AdminHandlerSuite) TestApprovalRequestList() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "wf-maker-1")

	// Seed a single policy once; each reserve below will create exactly one
	// approval request (not one per seed call).
	pol := &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: 1000},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour).UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
		ApproverTiers: []*limitsv1.ApproverTier{
			{UpTo: 0, Role: "branch_manager", Approvers: 1},
		},
	}
	s.seedAdminPolicy(ctx, pol)

	intent := &limitsv1.LimitIntent{
		TenantId: "tenant-a",
		Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		Amount:   &moneypb.Money{CurrencyCode: "KES", Units: 2000},
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-list-1"},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-list-1"},
		},
		MakerId: "wf-maker-1",
	}
	for range 3 {
		_, err := s.resvBiz.Reserve(ctx, intent, "idem-list-"+util.IDString(), 5*time.Minute)
		s.Require().NoError(err)
	}

	var collected []*limitsv1.ApprovalRequestObject
	err := s.approvalBiz.List(ctx, &limitsv1.ApprovalRequestListRequest{
		Status: limitsv1.ApprovalStatus_APPROVAL_STATUS_PENDING,
	}, func(_ context.Context, items []*limitsv1.ApprovalRequestObject) error {
		collected = append(collected, items...)
		return nil
	})
	s.Require().NoError(err)
	s.Len(collected, 3)
}

// TestApprovalRequestGet: seed one row, fetch by ID via the handler (unary RPC).
func (s *AdminHandlerSuite) TestApprovalRequestGet() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "wf-maker-1")

	resvID := s.reservePendingApproval(ctx, 1000, 2000, 1)

	rows, err := s.approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	arID := rows[0].ID

	resp, err := s.handler.ApprovalRequestGet(ctx, connect.NewRequest(&limitsv1.ApprovalRequestGetRequest{Id: arID}))
	s.Require().NoError(err)
	s.Equal(arID, resp.Msg.GetData().GetId())
	s.Equal(resvID, resp.Msg.GetData().GetReservationId())
}

// TestApprovalRequestDecide_Approve: seed pending approval + reservation,
// call handler.Decide(approve), verify status transition (unary RPC).
func (s *AdminHandlerSuite) TestApprovalRequestDecide_Approve() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "wf-maker-1")

	resvID := s.reservePendingApproval(ctx, 1000, 2000, 1)

	rows, err := s.approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	arID := rows[0].ID

	// Approver context: different from maker.
	ctxApprover := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "wf-approver-distinct")

	resp, err := s.handler.ApprovalRequestDecide(ctxApprover, connect.NewRequest(&limitsv1.ApprovalRequestDecideRequest{
		Id:       arID,
		Decision: "approve",
		Note:     "approved by handler test",
	}))
	s.Require().NoError(err)
	s.Equal(limitsv1.ApprovalStatus_APPROVAL_STATUS_APPROVED, resp.Msg.GetData().GetStatus())
}

// ─── Ledger handler tests ─────────────────────────────────────────────

// TestLedgerSearch: seed ledger rows via Reserve→Commit, exercise via business
// layer (LedgerSearch is streaming; connect.ServerStream is a concrete struct).
func (s *AdminHandlerSuite) TestLedgerSearch() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "wf-maker-1")

	// Seed a high-cap policy so Reserve succeeds without breaching.
	pol := &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: 100000},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour).UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
	}
	s.seedAdminPolicy(ctx, pol)

	intent := &limitsv1.LimitIntent{
		TenantId: "tenant-a",
		Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		Amount:   &moneypb.Money{CurrencyCode: "KES", Units: 500},
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-ledger-1"},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-ledger-1"},
		},
		MakerId: "wf-maker-1",
	}

	// Reserve then commit to materialise a ledger entry.
	resvResp, err := s.resvBiz.Reserve(ctx, intent, "idem-ledger-search-1", 5*time.Minute)
	s.Require().NoError(err)
	resvID := resvResp.GetReservation().GetId()

	_, err = s.resvBiz.Commit(ctx, resvID)
	s.Require().NoError(err)

	// Verify via business layer (streaming handler delegates to business.Search).
	var entries []*limitsv1.LedgerEntryObject
	err = s.ledgerBiz.Search(ctx, &limitsv1.LedgerSearchRequest{
		CurrencyCode: "KES",
	}, func(_ context.Context, items []*limitsv1.LedgerEntryObject) error {
		entries = append(entries, items...)
		return nil
	})
	s.Require().NoError(err)
	s.NotEmpty(entries)

	found := false
	for _, e := range entries {
		if e.GetReservationId() == resvID {
			found = true
			break
		}
	}
	s.True(found, "expected at least one ledger entry for reservation %s", resvID)
}

// TestLimitsAuditSearch_FiltersToLimitsVerbsOnly seeds three audit_events rows
// (two with "limits.*" action, one non-limits), then verifies that the default
// filter returns only the two limits rows.
func (s *AdminHandlerSuite) TestLimitsAuditSearch_FiltersToLimitsVerbsOnly() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "wf-1")
	now := time.Now().UTC()
	rows := []*audit.Event{
		{Action: "limits.breach.hard", EntityType: "policy", EntityID: "pol-1", Reason: "test", OccurredAt: &now},
		{
			Action:     "limits.reservation.committed",
			EntityType: "reservation",
			EntityID:   "res-1",
			Reason:     "test",
			OccurredAt: &now,
		},
		{Action: "non.limits.event", EntityType: "other", EntityID: "x-1", Reason: "test", OccurredAt: &now},
	}
	for _, r := range rows {
		r.GenID(ctx)
		r.TenantID = "tenant-a"
		r.PartitionID = "partition-a"
		s.Require().NoError(s.dbPool.DB(ctx, false).Create(r).Error)
	}

	auditBiz := business.NewAuditSearchBusiness(s.dbPool)
	var got []*limitsv1.LimitsAuditEventObject
	err := auditBiz.Search(
		ctx,
		&limitsv1.LimitsAuditSearchRequest{},
		func(_ context.Context, items []*limitsv1.LimitsAuditEventObject) error {
			got = append(got, items...)
			return nil
		},
	)
	s.Require().NoError(err)
	s.Len(got, 2, "should return only limits.* rows")
}

func TestAdminHandlerSuite(t *testing.T) {
	suite.Run(t, new(AdminHandlerSuite))
}
