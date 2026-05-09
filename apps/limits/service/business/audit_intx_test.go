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

// Tests for Phase 3 in-tx audit guarantees (spec §6A).
package business_test

import (
	"context"
	"testing"
	"time"

	moneypb "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
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
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

// AuditInTxSuite verifies the in-tx audit writer: rows are durable on commit
// and absent on rollback (Tests 3.A, 3.B, 3.C).
type AuditInTxSuite struct {
	frametests.FrameBaseTestSuite
}

func (s *AuditInTxSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *AuditInTxSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// auditEnv provisions an isolated DB and returns ctx, dbPool, auditWriter, Auditing, and repos.
// The tenant is "tenant-a" to match the kesIntent helper.
func (s *AuditInTxSuite) auditEnv() (
	context.Context,
	pool.Pool,
	*audit.Writer,
	*business.Auditing,
	repository.PolicyRepository,
	repository.ReservationRepository,
	repository.ApprovalRequestRepository,
) {
	s.T().Helper()

	ctx := s.T().Context()
	ctx = s.WithAuthClaims(ctx, "tenant-a", "partition-a", "test-user")

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-auditing-tx-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctx, dbManager, ""))

	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	workMan := svc.WorkManager()

	policyRepo := repository.NewPolicyRepository(ctx, dbPool, workMan)
	resvRepo := repository.NewReservationRepository(ctx, dbPool, workMan)
	approvalRepo := repository.NewApprovalRequestRepository(ctx, dbPool, workMan)

	// In these tests we pass a nil events.Manager to the Writer so RecordTx
	// is exercised directly (no async emission path).
	auditWriter := audit.NewWriter(nil)
	auditing := business.NewAuditing(auditWriter)

	return ctx, dbPool, auditWriter, auditing, policyRepo, resvRepo, approvalRepo
}

// countAuditRows returns the number of audit_events rows matching action+entityID.
func countAuditRows(ctx context.Context, dbPool pool.Pool, action, entityID string) int64 {
	var count int64
	dbPool.DB(ctx, true).
		Table(audit.Event{}.TableName()).
		Where("action = ? AND entity_id = ?", action, entityID).
		Count(&count)
	return count
}

// ─── Test 3.A: in-tx persistence — rollback drops the row, commit keeps it ───

func (s *AuditInTxSuite) TestRecordTx_RollbackDropsRow() {
	ctx, dbPool, _, auditing, _, _, _ := s.auditEnv()

	r := &models.Reservation{
		MakerID:      "user-rollback",
		CurrencyCode: "KES",
		Amount:       100_00,
		Action:       models.ActionLoanDisbursement,
		OrgUnitID:    "ou-1",
		Status:       models.ReservationStatusCommitted,
	}
	r.ID = util.IDString()

	db := dbPool.DB(ctx, false)
	tx := db.Begin()
	s.Require().NoError(tx.Error)

	s.Require().NoError(auditing.RecordReservationCommittedTx(ctx, tx, r))

	// Rollback — the audit row must vanish.
	s.Require().NoError(tx.Rollback().Error)

	s.Equal(int64(0), countAuditRows(ctx, dbPool, business.VerbReservationCommitted, r.ID),
		"rolled-back tx must not leave audit rows")
}

func (s *AuditInTxSuite) TestRecordTx_CommitPersistsRow() {
	ctx, dbPool, _, auditing, _, _, _ := s.auditEnv()

	r := &models.Reservation{
		MakerID:      "user-commit",
		CurrencyCode: "KES",
		Amount:       200_00,
		Action:       models.ActionLoanDisbursement,
		OrgUnitID:    "ou-1",
		Status:       models.ReservationStatusCommitted,
	}
	r.ID = util.IDString()

	db := dbPool.DB(ctx, false)
	tx := db.Begin()
	s.Require().NoError(tx.Error)

	s.Require().NoError(auditing.RecordReservationCommittedTx(ctx, tx, r))
	s.Require().NoError(tx.Commit().Error)

	s.Equal(int64(1), countAuditRows(ctx, dbPool, business.VerbReservationCommitted, r.ID),
		"committed tx must persist exactly one audit row")
}

func (s *AuditInTxSuite) TestRecordTx_NilTxReturnsError() {
	ctx, _, auditWriter, _, _, _, _ := s.auditEnv()

	err := auditWriter.RecordTx(ctx, nil, audit.Record{
		EntityType: "reservation",
		EntityID:   "x",
		Action:     business.VerbReservationCommitted,
	})
	s.Require().Error(err)
	s.Contains(err.Error(), "non-nil tx")
}

// ─── Test 3.B: PolicySave/Delete audit rows ───────────────────────────────

func (s *AuditInTxSuite) TestPolicySaveAuditRow() {
	ctx, dbPool, _, _, policyRepo, _, _ := s.auditEnv()
	workMan := frame.FromContext(ctx).WorkManager()
	dbManager := frame.FromContext(ctx).DatastoreManager()
	verRepo := repository.NewPolicyVersionRepository(ctx, dbManager.GetPool(ctx, datastore.DefaultPoolName), workMan)

	auditWriter := audit.NewWriter(nil)
	auditing := business.NewAuditing(auditWriter)
	biz := business.NewPolicyBusiness(policyRepo, verRepo, nil, auditing, dbPool, nil)

	in := goodPolicyForAudit()
	saved, err := biz.Save(ctx, in)
	s.Require().NoError(err)
	s.Require().NotEmpty(saved.GetId())

	s.Equal(int64(1), countAuditRows(ctx, dbPool, business.VerbPolicySaved, saved.GetId()),
		"Save must emit a limits.policy.saved audit row")
}

func (s *AuditInTxSuite) TestPolicyDeleteAuditRow() {
	ctx, dbPool, _, _, policyRepo, _, _ := s.auditEnv()
	workMan := frame.FromContext(ctx).WorkManager()
	dbManager := frame.FromContext(ctx).DatastoreManager()
	verRepo := repository.NewPolicyVersionRepository(ctx, dbManager.GetPool(ctx, datastore.DefaultPoolName), workMan)

	auditWriter := audit.NewWriter(nil)
	auditing := business.NewAuditing(auditWriter)
	biz := business.NewPolicyBusiness(policyRepo, verRepo, nil, auditing, dbPool, nil)

	in := goodPolicyForAudit()
	saved, err := biz.Save(ctx, in)
	s.Require().NoError(err)
	polID := saved.GetId()

	s.Require().NoError(biz.Delete(ctx, polID))

	s.Equal(int64(1), countAuditRows(ctx, dbPool, business.VerbPolicyDeleted, polID),
		"Delete must emit a limits.policy.deleted audit row")
}

// ─── Test 3.C: Release cascade audit ─────────────────────────────────────

func (s *AuditInTxSuite) TestReleaseCascadeAudit() {
	ctx, dbPool, _, _, policyRepo, _, _ := s.auditEnv()

	applyRuntimeIndexesForResv(s.T(), dbPool.DB(ctx, false))

	workMan := frame.FromContext(ctx).WorkManager()
	ledgerRepo := repository.NewLedgerRepository(ctx, dbPool, workMan)
	approvalRepo := repository.NewApprovalRequestRepository(ctx, dbPool, workMan)
	candidateRepo := repository.NewCandidatePolicyRepository(dbPool)
	evaluator := business.NewEvaluator(repository.NewReservationRepository(ctx, dbPool, workMan), ledgerRepo)
	resolver := business.NewAttributeResolver(
		repository.NewSubjectAttributeRepository(ctx, dbPool, workMan), nil, 60*time.Second,
	)

	auditWriter := audit.NewWriter(nil)
	auditing := business.NewAuditing(auditWriter)
	resvBiz := business.NewReservationBusiness(
		repository.NewReservationRepository(ctx, dbPool, workMan),
		ledgerRepo, candidateRepo, approvalRepo, policyRepo,
		evaluator, resolver, auditing, dbPool, nil,
	)

	// Seed an approval-gated policy.
	polIn := &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: 100},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		EffectiveFrom: timestamppb.New(time.Now().Add(-1 * time.Hour)),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
		ApproverTiers: []*limitsv1.ApproverTier{
			{UpTo: 500_000_00, Role: "manager", Approvers: 1},
		},
	}
	seedPolicy(s.T(), ctx, policyRepo, polIn)

	// Reserve over cap → PENDING_APPROVAL.
	intent := kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 500)
	resp, err := resvBiz.Reserve(ctx, intent, "cascade-audit-idem-1", 5*time.Minute)
	s.Require().NoError(err)
	resvID := resp.GetReservation().GetId()
	s.Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL, resp.GetReservation().GetStatus())

	// Fetch the approval request to get its ID.
	approvals, listErr := approvalRepo.ListByReservation(ctx, resvID)
	s.Require().NoError(listErr)
	s.Require().NotEmpty(approvals)
	arID := approvals[0].ID

	// Release the reservation — should cascade-reject the approval.
	_, err = resvBiz.Release(ctx, resvID, "cancelled by maker")
	s.Require().NoError(err)

	// Expect both audit rows.
	s.Equal(int64(1), countAuditRows(ctx, dbPool, business.VerbReservationReleased, resvID),
		"Release must emit limits.reservation.released")
	s.Equal(int64(1), countAuditRows(ctx, dbPool, business.VerbApprovalRejectedCascade, arID),
		"Release must emit limits.approval.rejected_cascade for each cancelled approval")
}

func goodPolicyForAudit() *limitsv1.PolicyObject {
	return &limitsv1.PolicyObject{
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
}

func TestAuditInTxSuite(t *testing.T) {
	suite.Run(t, new(AuditInTxSuite))
}
