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
	"sync"
	"time"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// TestReserve_EnforceMatchedIsNotShadow asserts that a shadow policy which
// would have breached does not turn the reservation into a shadow one while an
// enforce policy also matched. Marking it shadow would suppress ledger
// materialisation, so every rolling-window enforce cap would read usage = 0 for
// as long as any shadow policy was deployed — shadow mode would disable
// enforcement instead of observing it.
func (s *ReservationBusinessSuite) TestReserve_EnforceMatchedIsNotShadow() {
	ctx, biz, _, policyRepo, ledgerRepo := s.resvEnv("tenant-a", "partition-a")

	// A generous enforce cap that passes, plus a tiny shadow cap that breaches:
	// the normal shape of the first day of a shadow rollout.
	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 100000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))
	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 1, limitsv1.PolicyMode_POLICY_MODE_SHADOW,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION,
	))

	resp, err := biz.Reserve(
		ctx,
		kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000),
		"enforce-not-shadow-1",
		5*time.Minute,
	)
	s.Require().NoError(err)
	s.False(resp.GetReservation().GetIsShadow(),
		"an enforce policy matched, so the reservation is real, not shadow")

	_, err = biz.Commit(ctx, resp.GetReservation().GetId())
	s.Require().NoError(err)

	sum, err := ledgerRepo.WindowSum(ctx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "client-1"},
		time.Now().Add(-1*time.Hour),
	)
	s.Require().NoError(err)
	s.Equal(int64(200000), sum, "committing a non-shadow reservation must materialise the ledger")
}

// TestReserve_ConcurrentSameIdempotencyKey asserts that two simultaneous
// Reserves with one idempotency key both observe the same reservation. Before
// the unique-violation re-read, the loser got Internal — a non-idempotent
// failure on a money path, which callers retry into duplicate work.
func (s *ReservationBusinessSuite) TestReserve_ConcurrentSameIdempotencyKey() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 100000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	const attempts = 6
	var wg sync.WaitGroup
	ids := make([]string, attempts)
	errs := make([]error, attempts)
	start := make(chan struct{})
	for i := range attempts {
		wg.Add(1)
		go func() {
			defer wg.Done()
			<-start
			resp, err := biz.Reserve(
				ctx,
				kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000),
				"concurrent-idem-1",
				5*time.Minute,
			)
			errs[i] = err
			if err == nil {
				ids[i] = resp.GetReservation().GetId()
			}
		}()
	}
	close(start)
	wg.Wait()

	for i := range attempts {
		s.Require().NoError(errs[i], "every concurrent replay must succeed")
		s.Equal(ids[0], ids[i], "every replay must return the same reservation")
	}
}

// TestReserve_ClampsExcessiveTTL asserts the server caps a caller-supplied TTL.
// The proto carries no bound, so without the clamp a client could pin cap space
// for years by asking for a long-lived reservation.
func (s *ReservationBusinessSuite) TestReserve_ClampsExcessiveTTL() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 100000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	resp, err := biz.Reserve(
		ctx,
		kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000),
		"ttl-clamp-1",
		365*24*time.Hour,
	)
	s.Require().NoError(err)
	s.WithinDuration(time.Now().Add(time.Hour), resp.GetReservation().GetTtlAt().AsTime(), time.Minute,
		"a year-long TTL must be clamped to the one-hour ceiling")
}

// TestReserve_PlatformPolicyApplies asserts a platform-scoped cap is visible to
// a tenant's Reserve. Platform rows carry tenant_id = "" and are therefore
// invisible under row-level security unless the candidate lookup skips it.
func (s *ReservationBusinessSuite) TestReserve_PlatformPolicyApplies() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	platform := perTxnMaxPolicy(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	)
	platform.Scope = limitsv1.PolicyScope_POLICY_SCOPE_PLATFORM
	saved := seedPolicy(ctx, s.T(), policyRepo, platform)
	s.Empty(saved.TenantID, "a platform policy belongs to no tenant")

	_, err := biz.Reserve(
		ctx,
		kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 5000),
		"platform-cap-1",
		5*time.Minute,
	)
	s.Require().Error(err, "the platform cap must deny an over-cap intent for every tenant")
	s.Equal(connect.CodeFailedPrecondition, connect.CodeOf(err))
}

// TestDecide_WrongRoleRejected asserts an approver who does not hold the tier's
// required_role cannot decide. Without it any holder of limits_approval_act —
// every operator — could satisfy a "cfo × 2" tier.
func (s *ApprovalBusinessSuite) TestDecide_WrongRoleRejected() {
	ctx, approvalBiz, resvBiz, _, policyRepo, _, approvalRepo := s.approvalEnv("tenant-a", "partition-a")

	resvID := s.reservePendingApproval(ctx, resvBiz, policyRepo, 1000, 5000, 1)
	rows, err := approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)

	// A perfectly valid operator who simply is not a branch_manager.
	ctxOperator := withApproverClaims(ctx, "tenant-a", "partition-a", "wf-operator", "teller")
	_, err = approvalBiz.Decide(ctxOperator, &limitsv1.ApprovalRequestDecideRequest{
		Id:       rows[0].ID,
		Decision: "approve",
	})
	s.Require().Error(err)
	s.Equal(connect.CodePermissionDenied, connect.CodeOf(err))

	after, err := approvalRepo.GetByID(ctx, rows[0].ID)
	s.Require().NoError(err)
	s.Equal(models.ApprovalStatusPending, after.Status, "a refused decision must not change state")
}

// TestDecide_MakerIdFromRequestCannotSelfApprove asserts that the maker
// recorded on the approval request is the authenticated caller, not a field the
// client chose. A spoofable maker_id would let the maker approve their own
// request by naming somebody else on Reserve.
func (s *ApprovalBusinessSuite) TestDecide_MakerIdFromRequestCannotSelfApprove() {
	ctx, approvalBiz, resvBiz, _, policyRepo, _, approvalRepo := s.approvalEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, approvalPolicy(1000, 1))

	// The caller is wf-maker-1 (from approvalEnv claims) but claims to be
	// somebody else in the payload. The business layer must not believe it.
	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 5000)
	intent.MakerId = "wf-somebody-else"
	resp, err := resvBiz.Reserve(ctx, intent, "spoof-maker-"+util.IDString(), 5*time.Minute)
	s.Require().NoError(err)

	rows, err := approvalRepo.ListByReservation(ctx, resp.GetReservation().GetId())
	s.Require().NoError(err)
	s.Require().Len(rows, 1)

	// The real maker tries to approve their own request while holding the role.
	ctxMaker := withApproverClaims(ctx, "tenant-a", "partition-a", "wf-maker-1", "branch_manager")
	_, err = approvalBiz.Decide(ctxMaker, &limitsv1.ApprovalRequestDecideRequest{
		Id:       rows[0].ID,
		Decision: "approve",
	})
	s.Require().Error(err)
	s.Equal(connect.CodePermissionDenied, connect.CodeOf(err),
		"the maker must not be able to approve their own request")
}
