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
	"sync"
	"testing"
	"time"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/frametests"
	"github.com/pitabwire/frame/v3/frametests/definition"
	testpostgres "github.com/pitabwire/frame/v3/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

// ReaperAuditSuite covers the reapers as production runs them: with a
// transaction pool, a real audit writer, and a context that carries no
// caller claims. It asserts the rows they write are attributed to the system
// actor, scoped to the affected tenant, and therefore visible to that tenant's
// LimitsAuditSearch — and that a decision racing a reaper pass converges on
// exactly one outcome.
type ReaperAuditSuite struct {
	frametests.FrameBaseTestSuite
}

func (s *ReaperAuditSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_reaper_audit_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *ReaperAuditSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

type reaperAuditEnv struct {
	// systemCtx carries the service but no caller claims, as the reaper
	// goroutine's context does in production.
	systemCtx      context.Context
	dbPool         pool.Pool
	resvRepo       repository.ReservationRepository
	approvalRepo   repository.ApprovalRequestRepository
	policyRepo     repository.PolicyRepository
	resvBiz        business.ReservationBusiness
	approvalBiz    business.ApprovalBusiness
	approvalReaper *business.ApprovalReaper
	resvReaper     *business.ReservationReaper
	auditSearch    business.AuditSearchBusiness
	policySeeded   bool
}

func (s *ReaperAuditSuite) env() *reaperAuditEnv {
	s.T().Helper()
	base := s.T().Context()

	db := s.databaseResource(base)
	dsn, cleanup, err := db.GetRandomisedDS(base, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(base) })

	ctx, svc := frame.NewServiceWithContext(
		base,
		frame.WithName("limits-reaper-audit-test"),
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
	attrRepo := repository.NewSubjectAttributeRepository(ctx, dbPool, workMan)

	evaluator := business.NewEvaluator(resvRepo, ledgerRepo)
	resolver := business.NewAttributeResolver(attrRepo, nil, 60*time.Second)
	// A writer without an events manager: every in-tx record lands directly
	// in audit_events, which is the path the reapers now use.
	auditing := business.NewAuditing(audit.NewWriter(nil))

	return &reaperAuditEnv{
		systemCtx:    ctx,
		dbPool:       dbPool,
		resvRepo:     resvRepo,
		approvalRepo: approvalRepo,
		policyRepo:   policyRepo,
		resvBiz: business.NewReservationBusiness(
			resvRepo, ledgerRepo, candidateRepo, approvalRepo, policyRepo,
			evaluator, resolver, auditing, dbPool, nil,
		),
		approvalBiz: business.NewApprovalBusiness(
			approvalRepo, decisionRepo, resvRepo, policyRepo, evaluator, auditing, nil, dbPool, nil,
		),
		approvalReaper: business.NewApprovalReaper(
			approvalRepo, resvRepo, auditing, 1000, nil, business.WithReaperPool(dbPool),
		),
		resvReaper:  business.NewReservationReaper(resvRepo, auditing, 1000, business.WithReaperPool(dbPool)),
		auditSearch: business.NewAuditSearchBusiness(dbPool),
	}
}

// pendingApproval reserves an amount that trips the approver tier under
// tenant-a and moves the approval's deadline to expiresAt.
func (s *ReaperAuditSuite) pendingApproval(e *reaperAuditEnv, expiresAt time.Time) (string, string) {
	s.T().Helper()
	makerCtx := s.WithAuthClaims(e.systemCtx, "tenant-a", "partition-a", "wf-maker-1")
	if !e.policySeeded {
		// One approval policy per env: a second one would give every later
		// reservation two approval requests.
		seedPolicy(makerCtx, s.T(), e.policyRepo, approvalPolicy(1000, 1))
		e.policySeeded = true
	}
	resp, err := e.resvBiz.Reserve(
		makerCtx,
		kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 5000),
		"reaper-audit-"+util.IDString(),
		5*time.Minute,
	)
	s.Require().NoError(err)
	s.Require().Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
		resp.GetReservation().GetStatus())
	resvID := resp.GetReservation().GetId()

	approvals, err := e.approvalRepo.ListByReservation(makerCtx, resvID)
	s.Require().NoError(err)
	s.Require().Len(approvals, 1)
	s.Require().NoError(e.dbPool.DB(makerCtx, false).
		Table(models.ApprovalRequest{}.TableName()).
		Where("id = ?", approvals[0].ID).
		Update("expires_at", expiresAt).Error)
	return resvID, approvals[0].ID
}

// searchAudit reads the tenant-scoped audit feed exactly as LimitsAuditSearch
// serves it, so the assertions exercise the same RLS predicate operators see.
func (e *reaperAuditEnv) searchAudit(
	ctx context.Context,
	s *ReaperAuditSuite,
	entityID string,
	actions ...string,
) []*limitsv1.LimitsAuditEventObject {
	s.T().Helper()
	var out []*limitsv1.LimitsAuditEventObject
	err := e.auditSearch.Search(ctx, &limitsv1.LimitsAuditSearchRequest{
		Actions:  actions,
		EntityId: entityID,
	}, func(_ context.Context, items []*limitsv1.LimitsAuditEventObject) error {
		out = append(out, items...)
		return nil
	})
	s.Require().NoError(err)
	return out
}

// TestReapers_AuditRowsCarryTenantAndSystemActor runs both reapers with a
// claims-less context and asserts the expiry rows are readable by the tenant
// that owns the reservation, attributed to the system actor, and invisible to
// every other tenant.
func (s *ReaperAuditSuite) TestReapers_AuditRowsCarryTenantAndSystemActor() {
	e := s.env()
	resvID, approvalID := s.pendingApproval(e, time.Now().Add(-time.Minute).UTC())

	makerCtx := s.WithAuthClaims(e.systemCtx, "tenant-a", "partition-a", "wf-maker-1")
	staleActive := sampleResvForReaper("reaper-audit-stale", models.ReservationStatusActive,
		time.Now().Add(-time.Minute).UTC())
	s.Require().NoError(e.resvRepo.Create(makerCtx, staleActive))

	s.Require().NoError(e.approvalReaper.Run(e.systemCtx))
	s.Require().NoError(e.resvReaper.Run(e.systemCtx))

	got, err := e.resvRepo.GetByID(makerCtx, resvID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusReleased, got.Status, "expired approval releases its reservation")

	tenantA := s.WithAuthClaims(e.systemCtx, "tenant-a", "partition-a", "auditor-a")
	expiredApprovals := e.searchAudit(tenantA, s, approvalID, business.VerbApprovalExpired)
	s.Require().Len(expiredApprovals, 1, "tenant-a must see limits.approval.expired for its own approval")
	s.Equal(business.SystemActorReaper, expiredApprovals[0].GetActorId())
	s.Equal("system", expiredApprovals[0].GetActorType())

	expiredResvs := e.searchAudit(tenantA, s, staleActive.ID, business.VerbReservationExpiredTTL)
	s.Require().Len(expiredResvs, 1, "tenant-a must see limits.reservation.expired_ttl for its own reservation")
	s.Equal(business.SystemActorReaper, expiredResvs[0].GetActorId())
	s.Equal("system", expiredResvs[0].GetActorType())

	tenantB := s.WithAuthClaims(e.systemCtx, "tenant-b", "partition-b", "auditor-b")
	s.Empty(e.searchAudit(tenantB, s, approvalID, business.VerbApprovalExpired), "other tenants see nothing")
	s.Empty(e.searchAudit(tenantB, s, staleActive.ID, business.VerbReservationExpiredTTL))

	var rows []*audit.Event
	s.Require().NoError(e.dbPool.DB(e.systemCtx, true).
		Where("entity_id IN ?", []string{approvalID, staleActive.ID}).Find(&rows).Error)
	s.Require().Len(rows, 3, "approval.required (from Reserve) + two reaper rows")
	for _, row := range rows {
		s.Equal("tenant-a", row.TenantID, "every audit row is tenant-scoped, including reaper rows")
		s.Equal("partition-a", row.PartitionID)
	}
}

// TestApprovalReaper_ConcurrentPassesExpireOnce runs two reaper passes over
// the same expired rows at once, as two replicas would without the advisory
// lock, and asserts each row is expired, released and audited exactly once.
func (s *ReaperAuditSuite) TestApprovalReaper_ConcurrentPassesExpireOnce() {
	e := s.env()
	const n = 5
	approvalIDs := make([]string, n)
	resvIDs := make([]string, n)
	for i := range n {
		resvIDs[i], approvalIDs[i] = s.pendingApproval(e, time.Now().Add(-time.Minute).UTC())
	}

	var wg sync.WaitGroup
	errs := make([]error, 2)
	for i := range errs {
		wg.Add(1)
		go func() {
			defer wg.Done()
			errs[i] = e.approvalReaper.Run(e.systemCtx)
		}()
	}
	wg.Wait()
	for _, err := range errs {
		s.Require().NoError(err)
	}

	tenantA := s.WithAuthClaims(e.systemCtx, "tenant-a", "partition-a", "auditor-a")
	for i := range n {
		ar, err := e.approvalRepo.GetByID(tenantA, approvalIDs[i])
		s.Require().NoError(err)
		s.Equal(models.ApprovalStatusExpired, ar.Status)
		resv, err := e.resvRepo.GetByID(tenantA, resvIDs[i])
		s.Require().NoError(err)
		s.Equal(models.ReservationStatusReleased, resv.Status)
		s.Len(e.searchAudit(tenantA, s, approvalIDs[i], business.VerbApprovalExpired), 1,
			"exactly one expiry audit row per approval however many passes raced")
	}
}

// TestLimitsJobs_ReapWhileAnotherSessionHoldsTheOldLeaderLock holds the
// advisory lock key the reservation reaper used to take, on a connection of
// its own, as a pooled connection left holding it would. The job must still
// reap: it may not depend on a session lock taken through the pool.
func (s *ReaperAuditSuite) TestLimitsJobs_ReapWhileAnotherSessionHoldsTheOldLeaderLock() {
	e := s.env()
	sqlDB, err := e.dbPool.DB(e.systemCtx, false).DB()
	s.Require().NoError(err)
	conn, err := sqlDB.Conn(e.systemCtx)
	s.Require().NoError(err)
	defer func() { _ = conn.Close() }()
	const oldReservationReaperKey = 6_120_260_001
	_, err = conn.ExecContext(e.systemCtx, "SELECT pg_advisory_lock($1)", oldReservationReaperKey)
	s.Require().NoError(err)

	makerCtx := s.WithAuthClaims(e.systemCtx, "tenant-a", "partition-a", "wf-maker-1")
	stale := sampleResvForReaper("reaper-leaked-lock", models.ReservationStatusActive,
		time.Now().Add(-time.Minute).UTC())
	s.Require().NoError(e.resvRepo.Create(makerCtx, stale))

	internal := (&security.AuthenticationClaims{
		Roles: []string{security.ConstantSystemInternalRole},
	}).ClaimsToContext(e.systemCtx)
	jobs := business.NewLimitsJobs(e.resvReaper, e.approvalReaper)
	s.Require().NoError(jobs.Run(internal, limitsv1.LimitsJob_LIMITS_JOB_RESERVATION_EXPIRY))

	got, err := e.resvRepo.GetByID(makerCtx, stale.ID)
	s.Require().NoError(err)
	s.Equal(models.ReservationStatusExpired, got.Status)
}

// TestDecide_RacesReaper_ConvergesToOneOutcome fires a rejection and reaper
// passes at an approval whose deadline is a few milliseconds away, many
// times over, and asserts every run ends in exactly one terminal state with
// exactly one audit row and a released reservation — never both a rejection
// and an expiry.
func (s *ReaperAuditSuite) TestDecide_RacesReaper_ConvergesToOneOutcome() {
	e := s.env()
	approverCtx := withApproverClaims(e.systemCtx, "tenant-a", "partition-a", "wf-approver", "branch_manager")
	tenantA := s.WithAuthClaims(e.systemCtx, "tenant-a", "partition-a", "auditor-a")

	// Deadline offsets alternate between "already expired" (the reaper's UPDATE
	// races Decide's row lock) and "expires well after Decide lands" so both
	// orderings are exercised; the wide offsets keep the split deterministic
	// on a slow machine, the narrow ones produce genuine contention.
	offsets := []time.Duration{0, 5 * time.Millisecond, 500 * time.Millisecond, 20 * time.Millisecond, time.Second}
	const rounds = 10
	outcomes := make(map[models.ApprovalStatus]int)
	for i := range rounds {
		offset := offsets[i%len(offsets)]
		resvID, approvalID := s.pendingApproval(e, time.Now().Add(offset).UTC())

		var wg sync.WaitGroup
		var decideErr, reaperErr error
		wg.Add(2)
		go func() {
			defer wg.Done()
			_, decideErr = e.approvalBiz.Decide(approverCtx, &limitsv1.ApprovalRequestDecideRequest{
				Id: approvalID, Decision: "reject", Note: "race",
			})
		}()
		go func() {
			defer wg.Done()
			deadline := time.Now().Add(2 * time.Second)
			for time.Now().Before(deadline) {
				if reaperErr = e.approvalReaper.Run(e.systemCtx); reaperErr != nil {
					return
				}
				var ar *models.ApprovalRequest
				if ar, reaperErr = e.approvalRepo.GetByID(tenantA, approvalID); reaperErr != nil {
					return
				}
				if ar.Status != models.ApprovalStatusPending {
					return
				}
				time.Sleep(2 * time.Millisecond)
			}
		}()
		wg.Wait()
		s.Require().NoError(reaperErr, "reaper passes must never fail during the race")

		if decideErr != nil {
			// The reaper won: Decide must have reported a precondition failure,
			// never an internal error or a phantom success.
			s.Require().Equal(connect.CodeFailedPrecondition, connect.CodeOf(decideErr),
				"losing Decide must surface FailedPrecondition, got %v", decideErr)
		}

		ar, err := e.approvalRepo.GetByID(tenantA, approvalID)
		s.Require().NoError(err)
		s.Require().Contains(
			[]models.ApprovalStatus{models.ApprovalStatusRejected, models.ApprovalStatusExpired}, ar.Status)
		outcomes[ar.Status]++
		if decideErr == nil {
			s.Equal(models.ApprovalStatusRejected, ar.Status, "a successful Decide owns the outcome")
		}

		resv, err := e.resvRepo.GetByID(tenantA, resvID)
		s.Require().NoError(err)
		s.Equal(models.ReservationStatusReleased, resv.Status)

		terminalRows := e.searchAudit(
			tenantA, s, approvalID, business.VerbApprovalRejected, business.VerbApprovalExpired,
		)
		s.Require().Len(terminalRows, 1, "exactly one terminal audit row for approval %s", approvalID)
		s.Equal(string(ar.Status), map[string]string{
			business.VerbApprovalRejected: string(models.ApprovalStatusRejected),
			business.VerbApprovalExpired:  string(models.ApprovalStatusExpired),
		}[terminalRows[0].GetAction()], "the audit verb must match the persisted status")
	}
	s.T().Logf("decide-vs-reaper outcomes over %d rounds: %v", rounds, outcomes)
	s.Positive(outcomes[models.ApprovalStatusRejected], "some rounds must be won by Decide")
	s.Positive(outcomes[models.ApprovalStatusExpired], "some rounds must be won by the reaper")
}

func TestReaperAuditSuite(t *testing.T) {
	suite.Run(t, new(ReaperAuditSuite))
}
