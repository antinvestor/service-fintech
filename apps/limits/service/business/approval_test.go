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
	"github.com/stretchr/testify/suite"
	"google.golang.org/protobuf/types/known/durationpb"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// ApprovalBusinessSuite runs the full Frame test suite with a testcontainer Postgres.
type ApprovalBusinessSuite struct {
	frametests.FrameBaseTestSuite
}

func (s *ApprovalBusinessSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_approval_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *ApprovalBusinessSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// approvalEnv provisions an isolated DB and wires up all approval+reservation
// dependencies. Returns ctx, approvalBiz, resvBiz, pool, policyRepo, ledgerRepo.
func (s *ApprovalBusinessSuite) approvalEnv(tenantID, partitionID string) (
	context.Context,
	business.ApprovalBusiness,
	business.ReservationBusiness,
	pool.Pool,
	repository.PolicyRepository,
	repository.LedgerRepository,
	repository.ApprovalRequestRepository,
) {
	s.T().Helper()

	ctx := s.T().Context()
	// The maker profile is "wf-maker-1" to match kesIntent.MakerId.
	// Approver tests use a different profile (e.g. "wf-different").
	ctx = s.WithAuthClaims(ctx, tenantID, partitionID, "wf-maker-1")

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-approvalbiz-test"),
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
	ledgerRepo := repository.NewLedgerRepository(ctx, dbPool, workMan)
	approvalRepo := repository.NewApprovalRequestRepository(ctx, dbPool, workMan)
	decisionRepo := repository.NewApprovalDecisionRepository(ctx, dbPool, workMan)
	candidateRepo := repository.NewCandidatePolicyRepository(dbPool)
	policyRepo := repository.NewPolicyRepository(ctx, dbPool, workMan)
	policyVerRepo := repository.NewPolicyVersionRepository(ctx, dbPool, workMan)
	attrRepo := repository.NewSubjectAttributeRepository(ctx, dbPool, workMan)

	evaluator := business.NewEvaluator(resvRepo, ledgerRepo)
	resolver := business.NewAttributeResolver(attrRepo, nil, 60*time.Second)
	auditing := business.NewAuditing(nil)

	resvBiz := business.NewReservationBusiness(
		resvRepo, ledgerRepo, candidateRepo, approvalRepo, policyRepo,
		evaluator, resolver, auditing, dbPool, nil,
	)
	approvalBiz := business.NewApprovalBusiness(
		approvalRepo, decisionRepo, resvRepo, policyRepo, evaluator, auditing, nil, dbPool,
	)

	_ = policyVerRepo
	return ctx, approvalBiz, resvBiz, dbPool, policyRepo, ledgerRepo, approvalRepo
}

// approvalPolicy builds a per-txn-max enforce-mode policy with one approver tier.
func approvalPolicy(capUnits int64, approvers int32) *limitsv1.PolicyObject {
	return &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: capUnits, Nanos: 0},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour).UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
		ApproverTiers: []*limitsv1.ApproverTier{
			{UpTo: 0, Role: "branch_manager", Approvers: approvers}, // up_to=0 means unlimited
		},
	}
}

// reservePendingApproval does a Reserve that trips the approval tier and
// returns the reservation ID.
func (s *ApprovalBusinessSuite) reservePendingApproval(
	ctx context.Context,
	resvBiz business.ReservationBusiness,
	policyRepo repository.PolicyRepository,
	capUnits int64,
	intentUnits int64,
	approvers int32,
) string {
	s.T().Helper()
	seedPolicy(ctx, s.T(), policyRepo, approvalPolicy(capUnits, approvers))
	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, intentUnits)
	resp, err := resvBiz.Reserve(ctx, intent, "idem-appr-"+util.IDString(), 5*time.Minute)
	s.Require().NoError(err)
	s.Require().Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
		resp.GetReservation().GetStatus(), "expected pending_approval")
	return resp.GetReservation().GetId()
}

// ─── Tests ────────────────────────────────────────────────────────────

// TestList_FiltersByStatus: seed 3 pending + 1 approved; List with status=pending → 3 returned.
func (s *ApprovalBusinessSuite) TestList_FiltersByStatus() {
	ctx, approvalBiz, resvBiz, _, policyRepo, _, approvalRepo := s.approvalEnv("tenant-a", "partition-a")

	// Seed a policy that triggers approval for any amount over 1000 KES.
	pol := approvalPolicy(1000, 1)
	savedPol := seedPolicy(ctx, s.T(), policyRepo, pol)

	// Create 3 pending approval requests.
	for range 3 {
		intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000)
		resp, err := resvBiz.Reserve(ctx, intent, "idem-list-"+util.IDString(), 5*time.Minute)
		s.Require().NoError(err)
		s.Require().Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
			resp.GetReservation().GetStatus())
	}

	// Create 1 approved request by manually setting status.
	{
		intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000)
		resp, err := resvBiz.Reserve(ctx, intent, "idem-list-approved-"+util.IDString(), 5*time.Minute)
		s.Require().NoError(err)
		resvID := resp.GetReservation().GetId()
		// Find the approval request for this reservation.
		rows, err := approvalRepo.ListByReservation(ctx, resvID)
		s.Require().NoError(err)
		s.Require().NotEmpty(rows)
		now := time.Now().UTC()
		s.Require().NoError(approvalRepo.SetStatus(ctx, rows[0].ID, models.ApprovalStatusApproved, &now))
	}
	_ = savedPol

	// List with status=pending.
	var collected []*limitsv1.ApprovalRequestObject
	err := approvalBiz.List(ctx, &limitsv1.ApprovalRequestListRequest{
		Status: limitsv1.ApprovalStatus_APPROVAL_STATUS_PENDING,
	}, func(_ context.Context, items []*limitsv1.ApprovalRequestObject) error {
		collected = append(collected, items...)
		return nil
	})
	s.Require().NoError(err)
	s.Len(collected, 3)
}

// TestGet_NotFound: Get with unknown id → CodeNotFound.
func (s *ApprovalBusinessSuite) TestGet_NotFound() {
	ctx, approvalBiz, _, _, _, _, _ := s.approvalEnv("tenant-a", "partition-a")

	_, err := approvalBiz.Get(ctx, "nonexistent-approval-id")
	s.Require().Error(err)
	var connectErr *connect.Error
	s.Require().ErrorAs(err, &connectErr)
	s.Equal(connect.CodeNotFound, connectErr.Code())
}

// TestGet_HappyPath_IncludesDecisions: seed approval + 2 decisions; Get returns full object.
func (s *ApprovalBusinessSuite) TestGet_HappyPath_IncludesDecisions() {
	ctx, approvalBiz, resvBiz, _, policyRepo, _, approvalRepo := s.approvalEnv("tenant-a", "partition-a")

	pol := approvalPolicy(1000, 2) // need 2 approvers
	seedPolicy(ctx, s.T(), policyRepo, pol)
	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000)
	resp, err := resvBiz.Reserve(ctx, intent, "idem-get-happy-"+util.IDString(), 5*time.Minute)
	s.Require().NoError(err)
	resvID := resp.GetReservation().GetId()

	rows, err := approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	arID := rows[0].ID

	// Decide twice (each as different approver context).
	ctxApprover1 := s.WithAuthClaims(ctx, "tenant-a", "partition-a", "wf-approver-1")
	ctxApprover2 := s.WithAuthClaims(ctx, "tenant-a", "partition-a", "wf-approver-2")

	_, err = approvalBiz.Decide(ctxApprover1, &limitsv1.ApprovalRequestDecideRequest{
		Id:       arID,
		Decision: "approve",
		Note:     "first approver",
	})
	s.Require().NoError(err)

	result, err := approvalBiz.Decide(ctxApprover2, &limitsv1.ApprovalRequestDecideRequest{
		Id:       arID,
		Decision: "approve",
		Note:     "second approver",
	})
	s.Require().NoError(err)

	// Get should now return the full object with 2 decisions.
	obj, err := approvalBiz.Get(ctx, arID)
	s.Require().NoError(err)
	s.Equal(arID, obj.GetId())
	s.Len(obj.GetDecisions(), 2)
	_ = result
}

// TestDecide_Approve_SingleRequired: single-tier approval; Decide(approve) by non-maker →
// status approved + reservation transitions to ACTIVE.
func (s *ApprovalBusinessSuite) TestDecide_Approve_SingleRequired() {
	ctx, approvalBiz, resvBiz, _, policyRepo, _, approvalRepo := s.approvalEnv("tenant-a", "partition-a")

	resvID := s.reservePendingApproval(ctx, resvBiz, policyRepo, 1000, 2000, 1)

	rows, err := approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	arID := rows[0].ID

	// Approver context: different from maker (wf-1 is the maker).
	ctxApprover := s.WithAuthClaims(ctx, "tenant-a", "partition-a", "wf-different")

	result, err := approvalBiz.Decide(ctxApprover, &limitsv1.ApprovalRequestDecideRequest{
		Id:       arID,
		Decision: "approve",
	})
	s.Require().NoError(err)
	s.Equal(limitsv1.ApprovalStatus_APPROVAL_STATUS_APPROVED, result.GetStatus())

	// Reservation should now be ACTIVE — verify by committing.
	commitResp, err := resvBiz.Commit(ctx, resvID)
	s.Require().NoError(err)
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_COMMITTED, commitResp.GetReservation().GetStatus())
}

// TestDecide_Approve_MultiRequired_Partial: RequiredCount=2; first Decide(approve) →
// still pending; second Decide(approve) by different approver → approved.
func (s *ApprovalBusinessSuite) TestDecide_Approve_MultiRequired_Partial() {
	ctx, approvalBiz, resvBiz, _, policyRepo, _, approvalRepo := s.approvalEnv("tenant-a", "partition-a")

	// Policy with RequiredCount=2.
	pol := approvalPolicy(1000, 2)
	pol.ApproverTiers = []*limitsv1.ApproverTier{
		{UpTo: 0, Role: "branch_manager", Approvers: 2},
	}
	seedPolicy(ctx, s.T(), policyRepo, pol)
	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000)
	resp, err := resvBiz.Reserve(ctx, intent, "idem-multi-"+util.IDString(), 5*time.Minute)
	s.Require().NoError(err)
	resvID := resp.GetReservation().GetId()

	rows, err := approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	arID := rows[0].ID

	ctxApprover1 := s.WithAuthClaims(ctx, "tenant-a", "partition-a", "wf-approver-a")
	ctxApprover2 := s.WithAuthClaims(ctx, "tenant-a", "partition-a", "wf-approver-b")

	// First approval: still pending (only 1 of 2).
	result1, err := approvalBiz.Decide(ctxApprover1, &limitsv1.ApprovalRequestDecideRequest{
		Id:       arID,
		Decision: "approve",
	})
	s.Require().NoError(err)
	s.Equal(limitsv1.ApprovalStatus_APPROVAL_STATUS_PENDING, result1.GetStatus(),
		"should still be pending after 1 of 2 approvals")

	// Second approval: quorum reached → approved.
	result2, err := approvalBiz.Decide(ctxApprover2, &limitsv1.ApprovalRequestDecideRequest{
		Id:       arID,
		Decision: "approve",
	})
	s.Require().NoError(err)
	s.Equal(limitsv1.ApprovalStatus_APPROVAL_STATUS_APPROVED, result2.GetStatus())

	_ = resvID
}

// TestDecide_Reject_ReleasesReservation: Reserve → Decide(reject) →
// reservation status=released.
func (s *ApprovalBusinessSuite) TestDecide_Reject_ReleasesReservation() {
	ctx, approvalBiz, resvBiz, dbPool, policyRepo, _, approvalRepo := s.approvalEnv("tenant-a", "partition-a")

	resvID := s.reservePendingApproval(ctx, resvBiz, policyRepo, 1000, 2000, 1)

	rows, err := approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	arID := rows[0].ID

	ctxApprover := s.WithAuthClaims(ctx, "tenant-a", "partition-a", "wf-different")

	result, err := approvalBiz.Decide(ctxApprover, &limitsv1.ApprovalRequestDecideRequest{
		Id:       arID,
		Decision: "reject",
		Note:     "insufficient collateral",
	})
	s.Require().NoError(err)
	s.Equal(limitsv1.ApprovalStatus_APPROVAL_STATUS_REJECTED, result.GetStatus())

	// Reservation should be released.
	var resvStatus string
	dbPool.DB(ctx, true).
		Table("limits_reservations").
		Where("id = ?", resvID).
		Select("status").
		Scan(&resvStatus)
	s.Equal("released", resvStatus)
}

// TestDecide_RecheckFails_AutoRejected: Reserve with a per-txn-max policy that has
// an approval tier covering the amount → PENDING_APPROVAL. Between Reserve and Decide,
// the policy is updated to remove the approval tier. Re-evaluation at Decide time
// now sees the policy without a tier → v.Breached=true → auto-reject.
func (s *ApprovalBusinessSuite) TestDecide_RecheckFails_AutoRejected() {
	ctx, approvalBiz, resvBiz, dbPool, policyRepo, _, approvalRepo := s.approvalEnv("tenant-a", "partition-a")

	// Policy: cap=1000 KES, tier covers up to 5000 KES (500,000 minor units).
	polIn := &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: 1000, Nanos: 0},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour).UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
		ApproverTiers: []*limitsv1.ApproverTier{
			{UpTo: 500000, Role: "branch_manager", Approvers: 1}, // covers up to 5000 KES
		},
	}
	savedPol := seedPolicy(ctx, s.T(), policyRepo, polIn)

	// Reserve at 2000 KES: above cap but within tier range → PENDING_APPROVAL.
	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000)
	resp, err := resvBiz.Reserve(ctx, intent, "idem-recheck-"+util.IDString(), 5*time.Minute)
	s.Require().NoError(err)
	s.Require().Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
		resp.GetReservation().GetStatus(), "should require approval")
	resvID := resp.GetReservation().GetId()

	rows, err := approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	arID := rows[0].ID

	// Between Reserve and Decide: update the policy to remove the approval tier.
	// Now the same amount (2000 KES) will breach hard (no tier to cover it).
	dbPool.DB(ctx, false).
		Table("limits_policies").
		Where("id = ?", savedPol.ID).
		Update("approver_tiers", "[]")

	// Decide(approve): re-evaluation fetches the updated policy → Breached=true → auto-reject.
	ctxApprover := s.WithAuthClaims(ctx, "tenant-a", "partition-a", "wf-different")
	result, err := approvalBiz.Decide(ctxApprover, &limitsv1.ApprovalRequestDecideRequest{
		Id:       arID,
		Decision: "approve",
	})
	s.Require().NoError(err)
	s.Equal(limitsv1.ApprovalStatus_APPROVAL_STATUS_AUTO_REJECTED_ON_RECHECK, result.GetStatus())
}

// TestDecide_MakerCannotApprove: caller == maker → CodePermissionDenied.
func (s *ApprovalBusinessSuite) TestDecide_MakerCannotApprove() {
	ctx, approvalBiz, resvBiz, _, policyRepo, _, approvalRepo := s.approvalEnv("tenant-a", "partition-a")

	resvID := s.reservePendingApproval(ctx, resvBiz, policyRepo, 1000, 2000, 1)

	rows, err := approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	arID := rows[0].ID

	// Use the same context as the maker (wf-1).
	_, err = approvalBiz.Decide(ctx, &limitsv1.ApprovalRequestDecideRequest{
		Id:       arID,
		Decision: "approve",
	})
	s.Require().Error(err)
	var connectErr *connect.Error
	s.Require().ErrorAs(err, &connectErr)
	s.Equal(connect.CodePermissionDenied, connectErr.Code())
}

// TestDecide_DoubleVoteRejected: first Decide(approve); second Decide by same approver
// → CodeAlreadyExists.
func (s *ApprovalBusinessSuite) TestDecide_DoubleVoteRejected() {
	ctx, approvalBiz, resvBiz, _, policyRepo, _, approvalRepo := s.approvalEnv("tenant-a", "partition-a")

	// Use RequiredCount=2 so the first approval doesn't finalize (easier to test).
	pol := approvalPolicy(1000, 2)
	pol.ApproverTiers = []*limitsv1.ApproverTier{
		{UpTo: 0, Role: "branch_manager", Approvers: 2},
	}
	seedPolicy(ctx, s.T(), policyRepo, pol)
	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000)
	resp, err := resvBiz.Reserve(ctx, intent, "idem-doublevote-"+util.IDString(), 5*time.Minute)
	s.Require().NoError(err)
	resvID := resp.GetReservation().GetId()

	rows, err := approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	arID := rows[0].ID

	ctxApprover := s.WithAuthClaims(ctx, "tenant-a", "partition-a", "wf-approver-unique")

	// First vote succeeds.
	_, err = approvalBiz.Decide(ctxApprover, &limitsv1.ApprovalRequestDecideRequest{
		Id:       arID,
		Decision: "approve",
	})
	s.Require().NoError(err)

	// Second vote by the same approver → CodeAlreadyExists.
	_, err = approvalBiz.Decide(ctxApprover, &limitsv1.ApprovalRequestDecideRequest{
		Id:       arID,
		Decision: "approve",
	})
	s.Require().Error(err)
	var connectErr *connect.Error
	s.Require().ErrorAs(err, &connectErr)
	s.Equal(connect.CodeAlreadyExists, connectErr.Code())
}

// TestDecide_RequestExpired: set ExpiresAt in past; Decide → CodeFailedPrecondition.
func (s *ApprovalBusinessSuite) TestDecide_RequestExpired() {
	ctx, approvalBiz, resvBiz, dbPool, policyRepo, _, approvalRepo := s.approvalEnv("tenant-a", "partition-a")

	resvID := s.reservePendingApproval(ctx, resvBiz, policyRepo, 1000, 2000, 1)

	rows, err := approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	arID := rows[0].ID

	// Force the expiry time into the past.
	past := time.Now().Add(-1 * time.Hour).UTC()
	dbPool.DB(ctx, false).
		Table("limits_approval_requests").
		Where("id = ?", arID).
		Update("expires_at", past)

	ctxApprover := s.WithAuthClaims(ctx, "tenant-a", "partition-a", "wf-different")
	_, err = approvalBiz.Decide(ctxApprover, &limitsv1.ApprovalRequestDecideRequest{
		Id:       arID,
		Decision: "approve",
	})
	s.Require().Error(err)
	var connectErr *connect.Error
	s.Require().ErrorAs(err, &connectErr)
	s.Equal(connect.CodeFailedPrecondition, connectErr.Code())
}

// TestDecide_Transactional_ApproveAndActivateAtomic verifies that the final
// approval step (SetStatus→approved) and reservation activation (SetActive→active)
// are applied atomically in a single transaction. After a successful Decide:
//   - The ApprovalRequest row in DB must be APPROVED.
//   - The Reservation row in DB must be ACTIVE (not still pending_approval).
//
// This is the positive assertion for the 2E transactional guarantee: both state
// transitions land together or not at all. If they were not in a transaction, a
// crash between the two writes would strand the reservation.
func (s *ApprovalBusinessSuite) TestDecide_Transactional_ApproveAndActivateAtomic() {
	ctx, approvalBiz, resvBiz, dbPool, policyRepo, _, approvalRepo := s.approvalEnv("tenant-a", "partition-a")

	resvID := s.reservePendingApproval(ctx, resvBiz, policyRepo, 1000, 2000, 1)

	rows, err := approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	arID := rows[0].ID

	ctxApprover := s.WithAuthClaims(ctx, "tenant-a", "partition-a", "wf-different")
	resp, err := approvalBiz.Decide(ctxApprover, &limitsv1.ApprovalRequestDecideRequest{
		Id:       arID,
		Decision: "approve",
	})
	s.Require().NoError(err)
	s.Require().NotNil(resp)

	// Verify the ApprovalRequest row in DB is APPROVED.
	s.Equal(limitsv1.ApprovalStatus_APPROVAL_STATUS_APPROVED, resp.GetStatus(),
		"approval request must be APPROVED after last required vote")

	refreshedRows, err := approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(err)
	s.Require().Len(refreshedRows, 1)
	s.Equal(models.ApprovalStatusApproved, refreshedRows[0].Status,
		"approval row in DB must be APPROVED")

	// Verify the reservation is now ACTIVE (not still pending_approval).
	var resvStatus string
	dbPool.DB(ctx, true).
		Table("limits_reservations").
		Where("id = ?", resvID).
		Select("status").
		Scan(&resvStatus)
	s.Equal("active", resvStatus,
		"reservation must be ACTIVE after all approvals are in — both writes must be in the same tx")
}

func TestApprovalBusinessSuite(t *testing.T) {
	suite.Run(t, new(ApprovalBusinessSuite))
}
