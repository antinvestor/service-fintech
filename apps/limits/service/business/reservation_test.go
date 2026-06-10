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
	"fmt"
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
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

type ReservationBusinessSuite struct {
	frametests.FrameBaseTestSuite
}

func (s *ReservationBusinessSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *ReservationBusinessSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// resvEnv provisions a fresh isolated DB and wires up all dependencies.
// Returns ctx (with tenancy), biz (ReservationBusiness), dbPool, and a
// policyRepo for test setup.
func (s *ReservationBusinessSuite) resvEnv(tenantID, partitionID string) (
	context.Context,
	business.ReservationBusiness,
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
		frame.WithName("limits-resvbiz-test"),
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
	candidateRepo := repository.NewCandidatePolicyRepository(dbPool)
	policyRepo := repository.NewPolicyRepository(ctx, dbPool, workMan)
	policyVerRepo := repository.NewPolicyVersionRepository(ctx, dbPool, workMan)
	attrRepo := repository.NewSubjectAttributeRepository(ctx, dbPool, workMan)

	evaluator := business.NewEvaluator(resvRepo, ledgerRepo)
	// nil identity client: attribute resolver falls back to DB-only (no remote calls in tests).
	resolver := business.NewAttributeResolver(attrRepo, nil, 60*time.Second)
	// nil audit writer: audit events are dispatched via the frame events queue which
	// is not set up in unit tests. Audit-row verification is deferred to integration tests.
	auditing := business.NewAuditing(nil)

	biz := business.NewReservationBusiness(
		resvRepo, ledgerRepo, candidateRepo, approvalRepo, policyRepo,
		evaluator, resolver, auditing, dbPool, nil,
	)

	_ = policyVerRepo // used indirectly via Save
	return ctx, biz, dbPool, policyRepo, ledgerRepo
}

// applyRuntimeIndexesForResv reads and applies the SQL migration file
// containing the idempotency unique constraint.
func applyRuntimeIndexesForResv(t *testing.T, db *gorm.DB) {
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

// seedPolicy persists a policy directly via PolicyRepository.Save, bypassing
// version tracking for test simplicity.
func seedPolicy(
	ctx context.Context,
	t *testing.T,
	policyRepo repository.PolicyRepository,
	in *limitsv1.PolicyObject,
) *models.Policy {
	t.Helper()
	p, err := models.PolicyFromAPI(in)
	require.NoError(t, err)
	// Do NOT pre-set ID or Version: Save with an empty ID calls BaseRepository.Create,
	// which stamps tenancy fields, generates an xid, and sets Version=1.
	p.ID = ""
	require.NoError(t, policyRepo.Save(ctx, p))
	require.NotEmpty(t, p.ID, "policy ID must be set by Save")
	saved, err := policyRepo.Get(ctx, p.ID)
	require.NoError(t, err)
	return saved
}

// ─── Intent builders ──────────────────────────────────────────────────

func kesIntent(action limitsv1.LimitAction, units int64) *limitsv1.LimitIntent {
	subjects := subjectsForAction(action)
	return &limitsv1.LimitIntent{
		TenantId: "tenant-a",
		Action:   action,
		Amount:   &moneypb.Money{CurrencyCode: "KES", Units: units, Nanos: 0},
		Subjects: subjects,
		MakerId:  "wf-maker-1",
	}
}

//nolint:exhaustive // remaining actions take the default single-client subject set
func subjectsForAction(action limitsv1.LimitAction) []*limitsv1.SubjectRef {
	switch action {
	case limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_REQUEST,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_REPAYMENT:
		return []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-1"},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-1"},
		}
	case limitsv1.LimitAction_LIMIT_ACTION_SAVINGS_DEPOSIT,
		limitsv1.LimitAction_LIMIT_ACTION_SAVINGS_WITHDRAWAL:
		return []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-1"},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT, Id: "acct-1"},
		}
	case limitsv1.LimitAction_LIMIT_ACTION_FUNDING_INFLOW,
		limitsv1.LimitAction_LIMIT_ACTION_FUNDING_OUTFLOW:
		return []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: "org-1"},
		}
	default:
		return []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "client-1"},
		}
	}
}

func perTxnMaxPolicy(
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
		CapAmount:     &moneypb.Money{CurrencyCode: currency, Units: capUnits, Nanos: 0},
		Mode:          mode,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour).UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
	}
}

func rollingWindowPolicy(
	currency string,
	capUnits int64,
	windowHours int,
	mode limitsv1.PolicyMode,
	action limitsv1.LimitAction,
	subjectType limitsv1.SubjectType,
) *limitsv1.PolicyObject {
	return &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        action,
		SubjectType:   subjectType,
		CurrencyCode:  currency,
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_ROLLING_WINDOW_AMOUNT,
		CapAmount:     &moneypb.Money{CurrencyCode: currency, Units: capUnits, Nanos: 0},
		Window:        durationpb.New(time.Duration(windowHours) * time.Hour),
		Mode:          mode,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour).UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
	}
}

// ─── Tests ────────────────────────────────────────────────────────────

// TestReserveHappyPath: per_txn_max cap=1000 KES, intent 500 KES → ACTIVE.
func (s *ReservationBusinessSuite) TestReserveHappyPath() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500)
	resp, err := biz.Reserve(ctx, intent, "idem-happy-1", 5*time.Minute)
	s.Require().NoError(err)
	s.Require().NotNil(resp.GetReservation())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE, resp.GetReservation().GetStatus())
	s.True(resp.GetCheck().GetAllowed())
	s.False(resp.GetCheck().GetRequiresApproval())
}

// TestReserveHardBreach: per_txn_max cap=1000 KES, intent 2000 KES → FailedPrecondition.
func (s *ReservationBusinessSuite) TestReserveHardBreach() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000)
	resp, err := biz.Reserve(ctx, intent, "idem-breach-1", 5*time.Minute)
	s.Require().Error(err)
	s.Nil(resp)

	var connectErr *connect.Error
	s.Require().ErrorAs(err, &connectErr)
	s.Equal(connect.CodeFailedPrecondition, connectErr.Code())
}

// TestReserveShadowBreach: same policy shape but mode=SHADOW →
// reservation created with is_shadow=true, status ACTIVE.
func (s *ReservationBusinessSuite) TestReserveShadowBreach() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_SHADOW,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000)
	resp, err := biz.Reserve(ctx, intent, "idem-shadow-1", 5*time.Minute)
	s.Require().NoError(err)
	s.Require().NotNil(resp.GetReservation())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE, resp.GetReservation().GetStatus())
	s.True(resp.GetReservation().GetIsShadow())
}

// TestReserveRollingWindowUnderCap: rolling 24h cap=1000 KES, pre-seeded 200 KES,
// intent 500 KES → ACTIVE.
func (s *ReservationBusinessSuite) TestReserveRollingWindowUnderCap() {
	ctx, biz, dbPool, policyRepo, ledgerRepo := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, rollingWindowPolicy(
		"KES", 1000, 24, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	// Pre-seed a committed ledger entry of 200 KES for client-1.
	seedLedger(ctx, s.T(), ledgerRepo, dbPool, models.ActionLoanDisbursement, "KES", 200, "client")

	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500)
	resp, err := biz.Reserve(ctx, intent, "idem-rolling-under-1", 5*time.Minute)
	s.Require().NoError(err)
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE, resp.GetReservation().GetStatus())
}

// TestReserveRollingWindowOverCap: same setup, intent 900 KES → FailedPrecondition.
func (s *ReservationBusinessSuite) TestReserveRollingWindowOverCap() {
	ctx, biz, dbPool, policyRepo, ledgerRepo := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, rollingWindowPolicy(
		"KES", 1000, 24, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	// Pre-seed a committed ledger entry of 200 KES for client-1.
	seedLedger(ctx, s.T(), ledgerRepo, dbPool, models.ActionLoanDisbursement, "KES", 200, "client")

	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 900)
	resp, err := biz.Reserve(ctx, intent, "idem-rolling-over-1", 5*time.Minute)
	s.Require().Error(err)
	s.Nil(resp)

	var connectErr *connect.Error
	s.Require().ErrorAs(err, &connectErr)
	s.Equal(connect.CodeFailedPrecondition, connectErr.Code())
}

// TestReserveIdempotencyReplay: second call with same key returns original reservation.
func (s *ReservationBusinessSuite) TestReserveIdempotencyReplay() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500)

	resp1, err := biz.Reserve(ctx, intent, "idem-replay-1", 5*time.Minute)
	s.Require().NoError(err)
	s.Require().NotNil(resp1.GetReservation())

	resp2, err := biz.Reserve(ctx, intent, "idem-replay-1", 5*time.Minute)
	s.Require().NoError(err)
	s.Require().NotNil(resp2.GetReservation())

	// Both calls must return the same reservation ID.
	s.Equal(resp1.GetReservation().GetId(), resp2.GetReservation().GetId())
}

// TestReserveIdempotencyConflictDifferentIntent: same key, different action → AlreadyExists.
func (s *ReservationBusinessSuite) TestReserveIdempotencyConflictDifferentIntent() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	// Seed policies for both actions.
	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))
	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_REQUEST,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	intent1 := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500)
	intent2 := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_REQUEST, 500) // different action

	_, err := biz.Reserve(ctx, intent1, "idem-conflict-1", 5*time.Minute)
	s.Require().NoError(err)

	_, err = biz.Reserve(ctx, intent2, "idem-conflict-1", 5*time.Minute)
	s.Require().Error(err)

	var connectErr *connect.Error
	s.Require().ErrorAs(err, &connectErr)
	s.Equal(connect.CodeAlreadyExists, connectErr.Code())
}

// TestReserveApprovalRequired: per_txn_max with an approver tier; intent over cap →
// PENDING_APPROVAL, ApprovalRequest row created.
func (s *ReservationBusinessSuite) TestReserveApprovalRequired() {
	ctx, biz, dbPool, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	// Policy: cap=1000 KES, but allow approval up to 5000 KES.
	polIn := perTxnMaxPolicy(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	)
	polIn.ApproverTiers = []*limitsv1.ApproverTier{
		{UpTo: 500000, Role: "branch_manager", Approvers: 1}, // up to 5000 KES (minor units)
	}
	seedPolicy(ctx, s.T(), policyRepo, polIn)

	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000) // 2000 KES > 1000 cap
	resp, err := biz.Reserve(ctx, intent, "idem-approval-1", 5*time.Minute)
	s.Require().NoError(err)
	s.Require().NotNil(resp.GetReservation())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL, resp.GetReservation().GetStatus())
	s.True(resp.GetCheck().GetRequiresApproval())
	s.Equal(int32(1), resp.GetCheck().GetRequiredApprovers())

	// Verify ApprovalRequest row in DB.
	var count int64
	dbPool.DB(ctx, true).
		Table("limits_approval_requests").
		Where("reservation_id = ?", resp.GetReservation().GetId()).
		Count(&count)
	s.Equal(int64(1), count)
}

// ─── Ledger seed helper ───────────────────────────────────────────────

// seedLedger inserts a committed ledger entry directly to set up rolling-window state.
func seedLedger(
	ctx context.Context,
	t *testing.T,
	ledgerRepo repository.LedgerRepository,
	_ pool.Pool,
	action models.Action,
	currency string,
	amountUnits int64,
	subjectType string,
) {
	t.Helper()
	entry := &models.LedgerEntry{
		ReservationID: "seed-resv-" + util.IDString(),
		Action:        action,
		SubjectType:   models.Subject(subjectType),
		SubjectID:     "client-1",
		CurrencyCode:  currency,
		Amount:        amountUnits * 100, // minor units: KES has 2 decimal places
		CommittedAt:   time.Now().UTC(),
	}
	require.NoError(t, ledgerRepo.CreateBatch(ctx, []*models.LedgerEntry{entry}))
}

// ─── Commit tests ─────────────────────────────────────────────────────────────

// TestCommit_HappyPath: Reserve → Commit → ledger entries present (WindowSum > 0).
func (s *ReservationBusinessSuite) TestCommit_HappyPath() {
	ctx, biz, _, policyRepo, ledgerRepo := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 10000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500)
	resp, err := biz.Reserve(ctx, intent, "commit-happy-1", 5*time.Minute)
	s.Require().NoError(err)
	resvID := resp.GetReservation().GetId()

	commitResp, err := biz.Commit(ctx, resvID)
	s.Require().NoError(err)
	s.Require().NotNil(commitResp.GetReservation())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_COMMITTED, commitResp.GetReservation().GetStatus())

	// WindowSum should reflect the committed amount.
	sum, err := ledgerRepo.WindowSum(ctx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "client-1"},
		time.Now().Add(-1*time.Hour),
	)
	s.Require().NoError(err)
	s.Equal(int64(500*100), sum)
}

// TestCommit_Idempotent: second Commit returns the committed reservation without error.
func (s *ReservationBusinessSuite) TestCommit_Idempotent() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 10000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	resp, err := biz.Reserve(
		ctx,
		kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 300),
		"commit-idem-1",
		5*time.Minute,
	)
	s.Require().NoError(err)
	resvID := resp.GetReservation().GetId()

	_, err = biz.Commit(ctx, resvID)
	s.Require().NoError(err)

	// Second commit must succeed idempotently.
	resp2, err := biz.Commit(ctx, resvID)
	s.Require().NoError(err)
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_COMMITTED, resp2.GetReservation().GetStatus())
}

// TestCommit_PendingApprovalFails: a reservation waiting for approval returns FailedPrecondition.
func (s *ReservationBusinessSuite) TestCommit_PendingApprovalFails() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	polIn := perTxnMaxPolicy(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	)
	polIn.ApproverTiers = []*limitsv1.ApproverTier{
		{UpTo: 500000, Role: "manager", Approvers: 1},
	}
	seedPolicy(ctx, s.T(), policyRepo, polIn)

	resp, err := biz.Reserve(
		ctx,
		kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000),
		"commit-pending-1",
		5*time.Minute,
	)
	s.Require().NoError(err)
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL, resp.GetReservation().GetStatus())

	_, err = biz.Commit(ctx, resp.GetReservation().GetId())
	s.Require().Error(err)
	var connectErr *connect.Error
	s.Require().ErrorAs(err, &connectErr)
	s.Equal(connect.CodeFailedPrecondition, connectErr.Code())
}

// TestCommit_NotFound: Commit on unknown id returns NotFound.
func (s *ReservationBusinessSuite) TestCommit_NotFound() {
	ctx, biz, _, _, _ := s.resvEnv("tenant-a", "partition-a")

	_, err := biz.Commit(ctx, "nonexistent-id")
	s.Require().Error(err)
	var connectErr *connect.Error
	s.Require().ErrorAs(err, &connectErr)
	s.Equal(connect.CodeNotFound, connectErr.Code())
}

// TestCommit_ShadowSkipsLedger: shadow reservation commits but no ledger row is created.
func (s *ReservationBusinessSuite) TestCommit_ShadowSkipsLedger() {
	ctx, biz, _, policyRepo, ledgerRepo := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_SHADOW,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	// Shadow breach → reservation created with is_shadow=true.
	resp, err := biz.Reserve(
		ctx,
		kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000),
		"commit-shadow-1",
		5*time.Minute,
	)
	s.Require().NoError(err)
	s.True(resp.GetReservation().GetIsShadow())

	commitResp, err := biz.Commit(ctx, resp.GetReservation().GetId())
	s.Require().NoError(err)
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_COMMITTED, commitResp.GetReservation().GetStatus())

	// No ledger entries should exist for this reservation.
	sum, err := ledgerRepo.WindowSum(ctx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "client-1"},
		time.Now().Add(-1*time.Hour),
	)
	s.Require().NoError(err)
	s.Equal(int64(0), sum)
}

// ─── Release tests ─────────────────────────────────────────────────────────────

// TestRelease_HappyPath: Reserve → Release → status=released.
func (s *ReservationBusinessSuite) TestRelease_HappyPath() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 10000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	resp, err := biz.Reserve(
		ctx,
		kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500),
		"release-happy-1",
		5*time.Minute,
	)
	s.Require().NoError(err)

	releaseResp, err := biz.Release(ctx, resp.GetReservation().GetId(), "caller released")
	s.Require().NoError(err)
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_RELEASED, releaseResp.GetReservation().GetStatus())
}

// TestRelease_PendingApprovalCascadesApprovalRejection: pending approval reservation
// gets released, and the open approval request transitions to rejected.
func (s *ReservationBusinessSuite) TestRelease_PendingApprovalCascadesApprovalRejection() {
	ctx, biz, dbPool, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	polIn := perTxnMaxPolicy(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	)
	polIn.ApproverTiers = []*limitsv1.ApproverTier{
		{UpTo: 500000, Role: "manager", Approvers: 1},
	}
	seedPolicy(ctx, s.T(), policyRepo, polIn)

	resp, err := biz.Reserve(
		ctx,
		kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000),
		"release-approval-1",
		5*time.Minute,
	)
	s.Require().NoError(err)
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL, resp.GetReservation().GetStatus())
	resvID := resp.GetReservation().GetId()

	_, err = biz.Release(ctx, resvID, "released by caller")
	s.Require().NoError(err)

	// Approval request should now be rejected.
	var status string
	dbPool.DB(ctx, true).
		Table("limits_approval_requests").
		Where("reservation_id = ?", resvID).
		Select("status").
		Scan(&status)
	s.Equal("rejected", status)
}

// TestRelease_Idempotent: double-Release is a no-op.
func (s *ReservationBusinessSuite) TestRelease_Idempotent() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 10000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	resp, err := biz.Reserve(
		ctx,
		kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500),
		"release-idem-1",
		5*time.Minute,
	)
	s.Require().NoError(err)
	resvID := resp.GetReservation().GetId()

	_, err = biz.Release(ctx, resvID, "first release")
	s.Require().NoError(err)

	// Second release must succeed idempotently.
	resp2, err := biz.Release(ctx, resvID, "second release")
	s.Require().NoError(err)
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_RELEASED, resp2.GetReservation().GetStatus())
}

// ─── Reverse tests ─────────────────────────────────────────────────────────────

// TestReverse_HappyPath: Reserve → Commit → Reverse; subsequent WindowSum excludes entries.
func (s *ReservationBusinessSuite) TestReverse_HappyPath() {
	ctx, biz, _, policyRepo, ledgerRepo := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 10000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	resp, err := biz.Reserve(
		ctx,
		kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500),
		"reverse-happy-1",
		5*time.Minute,
	)
	s.Require().NoError(err)
	resvID := resp.GetReservation().GetId()

	_, err = biz.Commit(ctx, resvID)
	s.Require().NoError(err)

	// WindowSum before reversal.
	sum, err := ledgerRepo.WindowSum(ctx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "client-1"},
		time.Now().Add(-1*time.Hour),
	)
	s.Require().NoError(err)
	s.Equal(int64(500*100), sum)

	revResp, err := biz.Reverse(ctx, resvID, "rev-idem-happy-1", "test reversal")
	s.Require().NoError(err)
	s.Require().NotNil(revResp.GetOriginalReservation())
	s.Require().NotNil(revResp.GetReversalReservation())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_REVERSED, revResp.GetOriginalReservation().GetStatus())
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_REVERSED, revResp.GetReversalReservation().GetStatus())

	// WindowSum after reversal should be 0 (reversed entries are excluded).
	sum, err = ledgerRepo.WindowSum(ctx, models.ActionLoanDisbursement, "KES",
		repository.SubjectFilter{Type: models.SubjectClient, ID: "client-1"},
		time.Now().Add(-1*time.Hour),
	)
	s.Require().NoError(err)
	s.Equal(int64(0), sum)
}

// TestReverse_NotCommittedFails: Reverse on an active (not committed) reservation
// returns FailedPrecondition.
func (s *ReservationBusinessSuite) TestReverse_NotCommittedFails() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 10000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	resp, err := biz.Reserve(
		ctx,
		kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500),
		"reverse-notcommit-1",
		5*time.Minute,
	)
	s.Require().NoError(err)

	_, err = biz.Reverse(ctx, resp.GetReservation().GetId(), "rev-nc-1", "should fail")
	s.Require().Error(err)
	var connectErr *connect.Error
	s.Require().ErrorAs(err, &connectErr)
	s.Equal(connect.CodeFailedPrecondition, connectErr.Code())
}

// TestReverse_Idempotent: double-Reverse with the same idempotency_key returns
// the same traceability reservation id.
func (s *ReservationBusinessSuite) TestReverse_Idempotent() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 10000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	resp, err := biz.Reserve(
		ctx,
		kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500),
		"reverse-idem-base-1",
		5*time.Minute,
	)
	s.Require().NoError(err)
	resvID := resp.GetReservation().GetId()

	_, err = biz.Commit(ctx, resvID)
	s.Require().NoError(err)

	rev1, err := biz.Reverse(ctx, resvID, "rev-idem-key-1", "first reversal")
	s.Require().NoError(err)

	rev2, err := biz.Reverse(ctx, resvID, "rev-idem-key-1", "second reversal (same key)")
	s.Require().NoError(err)

	// Both calls return the same traceability reservation.
	s.Equal(rev1.GetReversalReservation().GetId(), rev2.GetReversalReservation().GetId())
}

// ─── Check tests ─────────────────────────────────────────────────────────────

// TestCheck_HappyPath: under cap → allowed=true, requires_approval=false.
func (s *ReservationBusinessSuite) TestCheck_HappyPath() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 10000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	checkResp, err := biz.Check(ctx, kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500))
	s.Require().NoError(err)
	s.True(checkResp.GetAllowed())
	s.False(checkResp.GetRequiresApproval())
	s.Empty(checkResp.GetBreachedPolicyIds())
}

// TestCheck_HardBreach: over cap → allowed=false, breached_policy_ids populated.
func (s *ReservationBusinessSuite) TestCheck_HardBreach() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	checkResp, err := biz.Check(ctx, kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000))
	s.Require().NoError(err)
	s.False(checkResp.GetAllowed())
	s.NotEmpty(checkResp.GetBreachedPolicyIds())
}

// TestCheck_ApprovalRequired: approver-tier-covered amount → requires_approval=true.
func (s *ReservationBusinessSuite) TestCheck_ApprovalRequired() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	polIn := perTxnMaxPolicy(
		"KES", 1000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	)
	polIn.ApproverTiers = []*limitsv1.ApproverTier{
		{UpTo: 500000, Role: "branch_manager", Approvers: 2},
	}
	seedPolicy(ctx, s.T(), policyRepo, polIn)

	checkResp, err := biz.Check(ctx, kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 2000))
	s.Require().NoError(err)
	s.True(checkResp.GetAllowed())
	s.True(checkResp.GetRequiresApproval())
	s.Equal(int32(2), checkResp.GetRequiredApprovers())
}

// TestReverse_Concurrent_OnlyOneSucceeds verifies that two concurrent Reverse
// calls targeting the same committed reservation only produce one traceability row.
// The advisory lock + status='committed' guard in SetReversedTx ensures exactly-once
// semantics: the second goroutine must receive an error (FailedPrecondition) because
// the reservation status is no longer 'committed' after the first reversal.
func (s *ReservationBusinessSuite) TestReverse_Concurrent_OnlyOneSucceeds() {
	ctx, biz, dbPool, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

	seedPolicy(ctx, s.T(), policyRepo, perTxnMaxPolicy(
		"KES", 100_000, limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
	))

	// 1. Reserve + Commit to produce a committed reservation.
	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 1000)
	reserveResp, err := biz.Reserve(ctx, intent, "concurrent-reverse-k1", 5*time.Minute)
	s.Require().NoError(err)
	resvID := reserveResp.GetReservation().GetId()
	s.Require().NotEmpty(resvID)

	_, err = biz.Commit(ctx, resvID)
	s.Require().NoError(err)

	// 2. Launch two concurrent Reverses with different idempotency keys.
	type result struct {
		resp *limitsv1.ReverseResponse
		err  error
	}
	ch := make(chan result, 2)
	for i := range 2 {
		idemKey := fmt.Sprintf("concurrent-reverse-rev-k%d", i)
		go func(key string) {
			resp, rerr := biz.Reverse(ctx, resvID, key, "concurrent test")
			ch <- result{resp, rerr}
		}(idemKey)
	}

	r1 := <-ch
	r2 := <-ch

	// 3. Exactly one must succeed and one must fail.
	successCount := 0
	failCount := 0
	for _, r := range []result{r1, r2} {
		if r.err == nil {
			successCount++
		} else {
			failCount++
			// The failing one must be FailedPrecondition (status guard blocked it).
			var connectErr *connect.Error
			s.Require().ErrorAs(r.err, &connectErr)
			s.Equal(connect.CodeFailedPrecondition, connectErr.Code(),
				"concurrent reverse loser must return FailedPrecondition")
		}
	}
	s.Equal(1, successCount, "exactly one Reverse must succeed")
	s.Equal(1, failCount, "exactly one Reverse must fail")

	// 4. Verify only one traceability row exists.
	var count int64
	dbPool.DB(ctx, true).
		Table("limits_reservations").
		Where("reverses_reservation_id = ?", resvID).
		Count(&count)
	s.Equal(int64(1), count, "only one traceability row should be created")
}

func TestReservationBusinessSuite(t *testing.T) {
	suite.Run(t, new(ReservationBusinessSuite))
}
