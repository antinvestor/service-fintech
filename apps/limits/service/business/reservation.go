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

// Package business holds the limits service domain logic.
//
// reservation.go implements the Reserve method on ReservationBusiness,
// which is the algorithmic core of the runtime path (spec §7).
package business

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/datastore/pool"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"
	"gorm.io/datatypes"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/events"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// approvalSpec pairs a candidate policy with the verdict that triggered an
// approval requirement. Used throughout Reserve to carry the two together.
type approvalSpec struct {
	policy  *models.Policy
	verdict *limitsv1.PolicyVerdict
}

// candidatePair pairs an applicable policy with the intent subject it matched.
type candidatePair struct {
	policy  *models.Policy
	subject repository.SubjectFilter
}

// maxReserveTTL is the hard server-side ceiling on a caller-requested
// reservation TTL. Without it a client could pin cap space indefinitely.
const maxReserveTTL = time.Hour

// ReservationBusiness implements the runtime path: Check, Reserve, Commit,
// Release, Reverse.
type ReservationBusiness interface {
	Check(ctx context.Context, intent *limitsv1.LimitIntent) (*limitsv1.CheckResponse, error)
	Reserve(
		ctx context.Context,
		intent *limitsv1.LimitIntent,
		idempotencyKey string,
		ttl time.Duration,
	) (*limitsv1.ReserveResponse, error)
	Commit(ctx context.Context, reservationID string) (*limitsv1.CommitResponse, error)
	Release(ctx context.Context, reservationID, reason string) (*limitsv1.ReleaseResponse, error)
	Reverse(ctx context.Context, reservationID, idempotencyKey, reason string) (*limitsv1.ReverseResponse, error)
}

type reservationBusiness struct {
	resvRepo      repository.ReservationRepository
	ledgerRepo    repository.LedgerRepository
	candidateRepo repository.CandidatePolicyRepository
	approvalRepo  repository.ApprovalRequestRepository
	policyRepo    repository.PolicyRepository
	evaluator     *Evaluator
	resolver      AttributeResolver
	auditing      *Auditing
	dbPool        pool.Pool
	eventsMan     fevents.Manager
	// ancestry places the transaction's partition in the partition tree, so
	// policies set on any ancestor apply. Nil means every tenant policy
	// applies regardless of partition (the strictest reading).
	ancestry PartitionAncestry
}

// ReservationOption configures optional collaborators.
type ReservationOption func(*reservationBusiness)

// WithPartitionAncestry tiers policies along the partition tree.
func WithPartitionAncestry(a PartitionAncestry) ReservationOption {
	return func(b *reservationBusiness) { b.ancestry = a }
}

// NewReservationBusiness wires up dependencies. eventsMan may be nil,
// in which case event emission is a no-op.
func NewReservationBusiness(
	resvRepo repository.ReservationRepository,
	ledgerRepo repository.LedgerRepository,
	candidateRepo repository.CandidatePolicyRepository,
	approvalRepo repository.ApprovalRequestRepository,
	policyRepo repository.PolicyRepository,
	evaluator *Evaluator,
	resolver AttributeResolver,
	auditing *Auditing,
	dbPool pool.Pool,
	eventsMan fevents.Manager,
	opts ...ReservationOption,
) ReservationBusiness {
	b := &reservationBusiness{
		resvRepo: resvRepo, ledgerRepo: ledgerRepo, candidateRepo: candidateRepo,
		approvalRepo: approvalRepo, policyRepo: policyRepo,
		evaluator: evaluator, resolver: resolver, auditing: auditing, dbPool: dbPool,
		eventsMan: eventsMan,
	}
	for _, opt := range opts {
		if opt != nil {
			opt(b)
		}
	}
	return b
}

// transactionPartition is the partition the transaction is evaluated in. A
// calling service forwards the partition that owns the record (frame applies
// it to the service's claims); a user calling directly is evaluated in their
// own partition. A service that forwards none is "unknown", and every tenant
// policy applies to it — the strictest reading, never a looser one.
func transactionPartition(ctx context.Context) string {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return ""
	}
	if claims.IsInternalSystem() && util.GetTenancy(ctx) == nil {
		return ""
	}
	return claims.GetPartitionID()
}

// findCandidates loads the policies that can bind this intent: platform
// policies, and tenant policies set on the transaction's partition or any of
// its ancestors. The transaction's partition is the request tenancy, which a
// calling service sets to the partition that owns the record being moved. A
// partition that cannot be placed in the tree fails the evaluation closed.
func (b *reservationBusiness) findCandidates(
	ctx context.Context,
	intent *limitsv1.LimitIntent,
	action models.Action,
	currency string,
) ([]*models.Policy, error) {
	q := repository.CandidateQuery{
		Action:       action,
		CurrencyCode: currency,
		TenantID:     intent.GetTenantId(),
		OrgUnitID:    intent.GetOrgUnitId(),
	}
	if b.ancestry != nil {
		if partitionID := transactionPartition(ctx); partitionID != "" {
			chain, err := b.ancestry.Chain(ctx, partitionID)
			if err != nil {
				return nil, connect.NewError(connect.CodeUnavailable, err)
			}
			q.PartitionIDs = chain
		}
	}
	cands, err := b.candidateRepo.FindCandidates(ctx, q)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return cands, nil
}

// evaluation holds the read-only result of evaluating a LimitIntent against
// applicable policies. Both Reserve and Check share this computation.
type evaluation struct {
	verdicts       []*limitsv1.PolicyVerdict
	hardBreaches   []*limitsv1.PolicyVerdict
	shadowBreaches []*limitsv1.PolicyVerdict
	approvalNeeded []approvalSpec
	intentMinor    int64
	action         models.Action
}

// evaluateIntent validates the intent, looks up candidate policies, filters by
// subject type and attribute predicates, runs the evaluator per policy, and
// returns the aggregated result. It does NOT open a transaction or acquire
// advisory locks (those are Reserve-only concerns).
//
//nolint:gocognit // verdict aggregation matrix is one auditable pass over policies
func (b *reservationBusiness) evaluateIntent(
	ctx context.Context,
	intent *limitsv1.LimitIntent,
) (*evaluation, error) {
	stampMakerFromClaims(ctx, intent)
	if err := validateIntent(intent); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	if err := validateRequiredSubjects(intent); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	currency := intent.GetAmount().GetCurrencyCode()
	intentMinor, err := moneyx.ToMinorUnitsByCurrency(intent.GetAmount(), currency)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	action, err := models.ActionFromAPISafe(intent.GetAction())
	if err != nil || action == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("invalid action"))
	}

	cands, err := b.findCandidates(ctx, intent, action, currency)
	if err != nil {
		return nil, err
	}

	applicable, unresolved := b.resolveApplicable(ctx, intent, cands)

	ev := &evaluation{intentMinor: intentMinor, action: action}
	ev.verdicts = append(ev.verdicts, unresolved...)
	ev.hardBreaches = append(ev.hardBreaches, unresolved...)
	for _, ap := range applicable {
		v, evErr := b.evaluator.Evaluate(ctx, ap.policy, ap.subject, intent, intentMinor)
		if evErr != nil {
			return nil, connect.NewError(connect.CodeInternal, evErr)
		}
		ev.verdicts = append(ev.verdicts, v)
		switch ap.policy.Mode {
		case models.ModeEnforce:
			if v.GetBreached() && !v.GetWouldRequireApproval() {
				ev.hardBreaches = append(ev.hardBreaches, v)
			}
			if v.GetWouldRequireApproval() {
				ev.approvalNeeded = append(ev.approvalNeeded, approvalSpec{policy: ap.policy, verdict: v})
			}
		case models.ModeShadow:
			if v.GetBreached() || v.GetWouldRequireApproval() {
				ev.shadowBreaches = append(ev.shadowBreaches, v)
			}
		case models.ModeOff:
			// Off policies are filtered out of the candidate set; nothing to aggregate.
		}
	}
	return ev, nil
}

func (b *reservationBusiness) Check(
	ctx context.Context,
	intent *limitsv1.LimitIntent,
) (*limitsv1.CheckResponse, error) {
	ev, err := b.evaluateIntent(ctx, intent)
	if err != nil {
		return nil, err
	}

	var breachedIDs []string
	for _, v := range ev.hardBreaches {
		breachedIDs = append(breachedIDs, v.GetPolicyId())
	}

	// Compute max required approvers across approval-needed specs.
	var maxApprovers int32
	for _, ap := range ev.approvalNeeded {
		if tier, ok := pickTier(ap.policy, ev.intentMinor); ok {
			if tier.Approvers > maxApprovers {
				maxApprovers = tier.Approvers
			}
		}
	}

	return &limitsv1.CheckResponse{
		Allowed:           len(ev.hardBreaches) == 0,
		RequiresApproval:  len(ev.approvalNeeded) > 0,
		RequiredApprovers: maxApprovers,
		Verdicts:          ev.verdicts,
		BreachedPolicyIds: breachedIDs,
	}, nil
}

//nolint:gocognit,gocyclo,cyclop,funlen // the reserve pipeline is a deliberately linear, numbered sequence inside one tx
func (b *reservationBusiness) Reserve(
	ctx context.Context,
	intent *limitsv1.LimitIntent,
	idempotencyKey string,
	ttl time.Duration,
) (*limitsv1.ReserveResponse, error) {
	// 1. Validate intent. The maker is re-derived from the caller's claims
	// before anything else: it gates maker-cannot-approve-own-request, so a
	// client-chosen value would let a maker approve their own disbursement.
	stampMakerFromClaims(ctx, intent)
	if err := validateIntent(intent); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	if idempotencyKey == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("idempotency_key required"))
	}

	// 2. Idempotency short-circuit.
	existing, lookupErr := b.resvRepo.GetByIdempotencyKey(ctx, intent.GetTenantId(), idempotencyKey)
	if lookupErr != nil {
		return nil, connect.NewError(connect.CodeInternal, lookupErr)
	}
	if existing != nil {
		if intentHash(intent, idempotencyKey) != reservationIntentHash(existing) {
			return nil, connect.NewError(connect.CodeAlreadyExists,
				errors.New("idempotency-key collision with a different intent"))
		}
		return &limitsv1.ReserveResponse{Reservation: existing.ToAPI()}, nil
	}

	// 2a. Clamp the caller-supplied TTL. An unbounded TTL lets a client pin
	// cap space for as long as it likes.
	if ttl > maxReserveTTL {
		ttl = maxReserveTTL
	}

	// 3. Subject schema validation.
	if err := validateRequiredSubjects(intent); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	// 4. Compute minor units.
	currency := intent.GetAmount().GetCurrencyCode()
	intentMinor, err := moneyx.ToMinorUnitsByCurrency(intent.GetAmount(), currency)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	// 5. Candidate policies.
	action, err := models.ActionFromAPISafe(intent.GetAction())
	if err != nil || action == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("invalid action"))
	}
	cands, err := b.findCandidates(ctx, intent, action, currency)
	if err != nil {
		return nil, err
	}

	// 6. Filter by subject_type + attribute predicate.
	applicable, unresolved := b.resolveApplicable(ctx, intent, cands)

	// 7. Open transaction; acquire advisory locks for rolling-window subjects.
	db := b.dbPool.DB(ctx, false)
	tx := db.Begin()
	if tx.Error != nil {
		return nil, connect.NewError(connect.CodeInternal, tx.Error)
	}
	committed := false
	defer func() {
		if !committed {
			_ = tx.Rollback()
		}
	}()

	var rollingSubjects []repository.SubjectFilter
	for _, ap := range applicable {
		if ap.policy.LimitKind == models.KindRollingWindowAmount ||
			ap.policy.LimitKind == models.KindRollingWindowCount {
			rollingSubjects = append(rollingSubjects, ap.subject)
		}
	}
	keys := LockKeys(action, currency, rollingSubjects)
	for _, k := range keys {
		if lockErr := tx.Exec("SELECT pg_advisory_xact_lock(?)", k).Error; lockErr != nil {
			return nil, connect.NewError(connect.CodeInternal, lockErr)
		}
	}

	// 8. Per-policy evaluation — use EvaluateInTx so that rolling-window reads
	// execute within the same transaction that holds the advisory lock, closing
	// the TOCTOU race between concurrent Reserves on the same subject.
	verdicts := append([]*limitsv1.PolicyVerdict(nil), unresolved...)
	hardBreaches := append([]*limitsv1.PolicyVerdict(nil), unresolved...)
	var shadowBreaches []*limitsv1.PolicyVerdict
	var approvalNeeded []approvalSpec
	enforceMatched := 0
	for _, ap := range applicable {
		v, evErr := b.evaluator.EvaluateInTx(ctx, tx, ap.policy, ap.subject, intent, intentMinor)
		if evErr != nil {
			return nil, connect.NewError(connect.CodeInternal, evErr)
		}
		verdicts = append(verdicts, v)

		// 9. Aggregate.
		switch ap.policy.Mode {
		case models.ModeEnforce:
			enforceMatched++
			if v.GetBreached() && !v.GetWouldRequireApproval() {
				hardBreaches = append(hardBreaches, v)
			}
			if v.GetWouldRequireApproval() {
				approvalNeeded = append(approvalNeeded, approvalSpec{policy: ap.policy, verdict: v})
			}
		case models.ModeShadow:
			if v.GetBreached() || v.GetWouldRequireApproval() {
				shadowBreaches = append(shadowBreaches, v)
			}
		case models.ModeOff:
			// Off policies are filtered out of the candidate set; nothing to aggregate.
		}
	}

	// 10. Hard breaches → deny. The denial is a regulatory record, so the
	// audit rows are written in their own committed transaction before the
	// error is returned rather than emitted on the lossy events bus.
	if len(hardBreaches) > 0 {
		_ = tx.Rollback()
		committed = true // prevent double-rollback in defer
		b.recordBreaches(ctx, intent, intentMinor, hardBreaches, shadowBreaches)
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			errors.New("limits cap breached"))
	}

	// 11. Persist reservation.
	resv, err := models.ReservationFromIntent(intent, idempotencyKey)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	resv.ID = util.IDString()
	if len(approvalNeeded) > 0 {
		resv.Status = models.ReservationStatusPendingApproval
		resv.TTLAt = time.Now().Add(approvalTTLForPolicies(approvalNeeded)).UTC()
	} else {
		resv.TTLAt = time.Now().Add(ttl).UTC()
	}
	// Pure-shadow: no enforce-mode policy matched at all, and at least one
	// shadow policy would have blocked. Shadow reservations do not materialise
	// ledger entries on Commit and don't count toward future caps. An enforce
	// policy that matched and passed keeps the reservation real, otherwise a
	// single shadow policy would switch enforcement off service-wide.
	if enforceMatched == 0 && len(shadowBreaches) > 0 {
		resv.IsShadow = true
	}
	resv.PoliciesEvaluated = verdictsJSON(verdicts)
	if createErr := tx.Create(resv).Error; createErr != nil {
		if isUniqueViolation(createErr) {
			// A concurrent Reserve with the same idempotency key won the race.
			// Roll back and return the reservation that landed first.
			_ = tx.Rollback()
			committed = true
			dup, dupErr := b.resvRepo.GetByIdempotencyKey(ctx, intent.GetTenantId(), idempotencyKey)
			if dupErr == nil && dup != nil {
				return &limitsv1.ReserveResponse{Reservation: dup.ToAPI()}, nil
			}
		}
		return nil, connect.NewError(connect.CodeInternal, createErr)
	}

	// 12. Persist approval requests.
	approvalRows := make([]*models.ApprovalRequest, 0, len(approvalNeeded))
	for _, ap := range approvalNeeded {
		tier, ok := pickTier(ap.policy, intentMinor)
		if !ok {
			return nil, connect.NewError(connect.CodeInternal,
				fmt.Errorf("policy %s flagged for approval but no tier covers amount", ap.policy.ID))
		}
		ar := &models.ApprovalRequest{
			ReservationID:      resv.ID,
			OrgUnitID:          resv.OrgUnitID,
			Action:             resv.Action,
			CurrencyCode:       resv.CurrencyCode,
			Amount:             resv.Amount,
			TriggeringPolicyID: ap.policy.ID,
			PolicyVersion:      int32(ap.policy.Version), //nolint:gosec // version counters never approach int32 range
			RequiredRole:       tier.Role,
			RequiredCount:      tier.Approvers,
			MakerID:            resv.MakerID,
			Status:             models.ApprovalStatusPending,
			SubmittedAt:        time.Now().UTC(),
			// One source of truth for both deadlines: the reservation's TTL is
			// the shortest approval TTL across the involved policies, and the
			// approval must not outlive the hold it is gating.
			ExpiresAt: resv.TTLAt,
		}
		ar.ID = util.IDString()
		if createErr := tx.Create(ar).Error; createErr != nil {
			return nil, connect.NewError(connect.CodeInternal, createErr)
		}
		// Audit inside the tx so the record lands atomically with the approval row.
		if auditErr := b.auditing.RecordApprovalRequiredTx(ctx, tx, ar); auditErr != nil {
			return nil, connect.NewError(connect.CodeInternal, auditErr)
		}
		approvalRows = append(approvalRows, ar)
	}

	// 13. Commit transaction.
	if commitErr := tx.Commit().Error; commitErr != nil {
		return nil, connect.NewError(connect.CodeInternal, commitErr)
	}
	committed = true

	// 14. Post-commit: shadow-breach observability and event emission.
	for _, v := range shadowBreaches {
		b.auditing.RecordBreachShadow(ctx, intent, v)
	}
	for _, ar := range approvalRows {
		emitEvent(ctx, b.eventsMan, events.EventApprovalRequested, events.ApprovalEventPayload{
			ReservationID:     ar.ReservationID,
			ApprovalRequestID: ar.ID,
			TenantID:          resv.TenantID,
			Action:            string(ar.Action),
			MakerID:           ar.MakerID,
		})
	}

	// 15. Build response.
	return &limitsv1.ReserveResponse{
		Reservation: resv.ToAPI(),
		Check: &limitsv1.CheckResponse{
			Allowed:           len(approvalNeeded) == 0,
			RequiresApproval:  len(approvalNeeded) > 0,
			RequiredApprovers: requiredApproverCount(approvalRows),
			Verdicts:          verdicts,
		},
	}, nil
}

// ─── Commit ────────────────────────────────────────────────────────────────

//nolint:gocognit // commit is a numbered linear sequence inside one tx
func (b *reservationBusiness) Commit(
	ctx context.Context,
	reservationID string,
) (*limitsv1.CommitResponse, error) {
	// 1. Fetch reservation.
	r, err := b.resvRepo.GetByID(ctx, reservationID)
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("reservation %s not found", reservationID))
	}
	if tErr := assertSameTenant(ctx, r.TenantID); tErr != nil {
		return nil, tErr
	}

	// 2. Idempotent: already committed.
	if r.Status == models.ReservationStatusCommitted {
		return &limitsv1.CommitResponse{Reservation: r.ToAPI()}, nil
	}

	// 3. Pending approval: caller must get approval first.
	if r.Status == models.ReservationStatusPendingApproval {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("pending approval"))
	}

	// 4. Must be active.
	if r.Status != models.ReservationStatusActive {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("not active"))
	}

	now := time.Now().UTC()

	// 5-8. Open transaction, update status, materialise ledger.
	db := b.dbPool.DB(ctx, false)
	tx := db.Begin()
	if tx.Error != nil {
		return nil, connect.NewError(connect.CodeInternal, tx.Error)
	}
	txCommitted := false
	defer func() {
		if !txCommitted {
			_ = tx.Rollback()
		}
	}()

	// 6. Update reservation status via scoped Tx method (enforces tenant + status guard).
	if setErr := b.resvRepo.SetCommittedTx(ctx, tx, r.ID, now); setErr != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("not active"))
	}

	// 7. Materialise ledger entries (skip for shadow reservations).
	if !r.IsShadow {
		subjects, unmarshalErr := unmarshalReservationSubjects(r.SubjectRefs)
		if unmarshalErr != nil {
			return nil, connect.NewError(connect.CodeInternal, unmarshalErr)
		}
		entries := make([]*models.LedgerEntry, 0, len(subjects))
		for _, s := range subjects {
			e := &models.LedgerEntry{
				ReservationID: r.ID,
				OrgUnitID:     r.OrgUnitID,
				Action:        r.Action,
				SubjectType:   subjectFromAPILocal(s.GetType()),
				SubjectID:     s.GetId(),
				CurrencyCode:  r.CurrencyCode,
				Amount:        r.Amount,
				CommittedAt:   now,
			}
			e.ID = util.IDString()
			entries = append(entries, e)
		}
		if len(entries) > 0 {
			if createErr := tx.Create(&entries).Error; createErr != nil {
				return nil, connect.NewError(connect.CodeInternal, createErr)
			}
		}
	}

	// 8. Audit inside the tx so the record lands atomically with the state change.
	// Apply in-memory first so reservationMetadata reflects the new status.
	r.Status = models.ReservationStatusCommitted
	r.CommittedAt = &now
	if auditErr := b.auditing.RecordReservationCommittedTx(ctx, tx, r); auditErr != nil {
		return nil, connect.NewError(connect.CodeInternal, auditErr)
	}

	// 9. Commit transaction.
	if commitErr := tx.Commit().Error; commitErr != nil {
		return nil, connect.NewError(connect.CodeInternal, commitErr)
	}
	txCommitted = true

	return &limitsv1.CommitResponse{Reservation: r.ToAPI()}, nil
}

// ─── Release ───────────────────────────────────────────────────────────────

//nolint:gocognit // release is a numbered linear sequence inside one tx
func (b *reservationBusiness) Release(
	ctx context.Context,
	reservationID, reason string,
) (*limitsv1.ReleaseResponse, error) {
	// 1. Fetch.
	r, err := b.resvRepo.GetByID(ctx, reservationID)
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("reservation %s not found", reservationID))
	}
	if tErr := assertSameTenant(ctx, r.TenantID); tErr != nil {
		return nil, tErr
	}

	// 2. Idempotent: already released.
	if r.Status == models.ReservationStatusReleased {
		return &limitsv1.ReleaseResponse{Reservation: r.ToAPI()}, nil
	}

	// 3. Must be active or pending_approval.
	if r.Status != models.ReservationStatusActive && r.Status != models.ReservationStatusPendingApproval {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("cannot release reservation with status %s", r.Status))
	}

	now := time.Now().UTC()

	// 4-6. Open transaction so the reservation update, approval cancellations,
	// and audit rows all land atomically.
	db := b.dbPool.DB(ctx, false)
	tx := db.Begin()
	if tx.Error != nil {
		return nil, connect.NewError(connect.CodeInternal, tx.Error)
	}
	txCommitted := false
	defer func() {
		if !txCommitted {
			_ = tx.Rollback()
		}
	}()

	// 4. Update reservation row.
	if setErr := b.resvRepo.SetReleasedTx(ctx, tx, reservationID, reason, now); setErr != nil {
		return nil, connect.NewError(connect.CodeInternal, setErr)
	}

	// 5. Cancel any pending approval requests.
	approvals, listErr := b.approvalRepo.ListByReservation(ctx, reservationID)
	if listErr != nil {
		return nil, connect.NewError(connect.CodeInternal, listErr)
	}
	for _, ar := range approvals {
		if ar.Status == models.ApprovalStatusPending {
			if setErr := b.approvalRepo.SetStatusTx(
				ctx,
				tx,
				ar.ID,
				models.ApprovalStatusRejected,
				&now,
			); setErr != nil {
				return nil, connect.NewError(connect.CodeInternal, setErr)
			}
			// Audit the cascade-rejected approval inside the same tx.
			if auditErr := b.auditing.RecordApprovalRejectedCascadeTx(ctx, tx, ar, reason); auditErr != nil {
				return nil, connect.NewError(connect.CodeInternal, auditErr)
			}
		}
	}

	// Apply in-memory so reservationMetadata and ToAPI reflect released state.
	r.Status = models.ReservationStatusReleased
	r.ReleasedAt = &now

	// 6. Audit the reservation release inside the tx.
	if auditErr := b.auditing.RecordReservationReleasedTx(ctx, tx, r, reason); auditErr != nil {
		return nil, connect.NewError(connect.CodeInternal, auditErr)
	}

	// 7. Commit.
	if commitErr := tx.Commit().Error; commitErr != nil {
		return nil, connect.NewError(connect.CodeInternal, commitErr)
	}
	txCommitted = true

	return &limitsv1.ReleaseResponse{Reservation: r.ToAPI()}, nil
}

// ─── Reverse ───────────────────────────────────────────────────────────────

//nolint:gocognit,funlen // reversal must stay one atomic, numbered sequence inside one tx
func (b *reservationBusiness) Reverse(
	ctx context.Context,
	reservationID, idempotencyKey, reason string,
) (*limitsv1.ReverseResponse, error) {
	// 1. Idempotency: check if a reversal-reservation already exists for this key.
	existing, lookupErr := b.resvRepo.GetByIdempotencyKey(ctx, callerTenant(ctx), idempotencyKey)
	if lookupErr != nil {
		return nil, connect.NewError(connect.CodeInternal, lookupErr)
	}
	if existing != nil &&
		existing.ReversesReservationID != nil && *existing.ReversesReservationID == reservationID {
		original, origErr := b.resvRepo.GetByID(ctx, reservationID)
		if origErr != nil {
			return nil, connect.NewError(connect.CodeInternal, origErr)
		}
		return &limitsv1.ReverseResponse{
			OriginalReservation: original.ToAPI(),
			ReversalReservation: existing.ToAPI(),
		}, nil
	}

	// 2. Fetch original.
	original, err := b.resvRepo.GetByID(ctx, reservationID)
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("reservation %s not found", reservationID))
	}

	// 2a. Defense-in-depth: reject cross-tenant access before any further work.
	if tErr := assertSameTenant(ctx, original.TenantID); tErr != nil {
		return nil, tErr
	}

	// 3. Must be committed.
	if original.Status != models.ReservationStatusCommitted {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("reservation must be committed to reverse; current status: %s", original.Status))
	}

	now := time.Now().UTC()

	// 4-9. Open transaction.
	db := b.dbPool.DB(ctx, false)
	tx := db.Begin()
	if tx.Error != nil {
		return nil, connect.NewError(connect.CodeInternal, tx.Error)
	}
	txCommitted := false
	defer func() {
		if !txCommitted {
			_ = tx.Rollback()
		}
	}()

	// 4a. Acquire advisory locks (same keys as Reserve) so concurrent Reverses
	// on the same original are serialised and only the first succeeds.
	reverseSubjects, subjectErr := unmarshalReservationSubjects(original.SubjectRefs)
	if subjectErr != nil {
		return nil, connect.NewError(connect.CodeInternal, subjectErr)
	}
	var reverseSubjectFilters []repository.SubjectFilter
	for _, s := range reverseSubjects {
		reverseSubjectFilters = append(reverseSubjectFilters, repository.SubjectFilter{
			Type: subjectFromAPILocal(s.GetType()),
			ID:   s.GetId(),
		})
	}
	lockKeys := LockKeys(original.Action, original.CurrencyCode, reverseSubjectFilters)
	for _, k := range lockKeys {
		if lockErr := tx.Exec("SELECT pg_advisory_xact_lock(?)", k).Error; lockErr != nil {
			return nil, connect.NewError(connect.CodeInternal, lockErr)
		}
	}

	// 5. Mark ledger entries reversed (within the transaction for atomicity).
	if updErr := tx.Table(models.LedgerEntry{}.TableName()).
		Where("reservation_id = ? AND reversed_at IS NULL", original.ID).
		Update("reversed_at", now).Error; updErr != nil {
		return nil, connect.NewError(connect.CodeInternal, updErr)
	}

	// 6. Create traceability reservation.
	traceability := &models.Reservation{
		IdempotencyKey:        idempotencyKey,
		OrgUnitID:             original.OrgUnitID,
		Action:                original.Action,
		CurrencyCode:          original.CurrencyCode,
		Amount:                original.Amount,
		SubjectRefs:           original.SubjectRefs,
		MakerID:               original.MakerID,
		Status:                models.ReservationStatusReversed,
		IsShadow:              original.IsShadow,
		PoliciesEvaluated:     original.PoliciesEvaluated,
		ReversesReservationID: &original.ID,
		Notes:                 reason,
		ReservedAt:            now,
		TTLAt:                 now,
		CommittedAt:           &now,
	}
	traceability.ID = util.IDString()
	// Inherit tenancy fields from original.
	traceability.TenantID = original.TenantID
	traceability.PartitionID = original.PartitionID

	if createErr := tx.Create(traceability).Error; createErr != nil {
		return nil, connect.NewError(connect.CodeInternal, createErr)
	}

	// 8. Mark original status reversed (status='committed' guard prevents double-reverse).
	if setErr := b.resvRepo.SetReversedTx(ctx, tx, original.ID, now); setErr != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("reservation %s cannot be reversed: %w", original.ID, setErr))
	}

	// Apply in-memory so reservationMetadata reflects the new status.
	original.Status = models.ReservationStatusReversed

	// 9. Audit inside the tx so the record lands atomically with the state change.
	if auditErr := b.auditing.RecordReservationReversedTx(ctx, tx, original, reason); auditErr != nil {
		return nil, connect.NewError(connect.CodeInternal, auditErr)
	}

	// 10. Commit transaction.
	if commitErr := tx.Commit().Error; commitErr != nil {
		return nil, connect.NewError(connect.CodeInternal, commitErr)
	}
	txCommitted = true

	return &limitsv1.ReverseResponse{
		OriginalReservation: original.ToAPI(),
		ReversalReservation: traceability.ToAPI(),
	}, nil
}

// ─── Helpers ───────────────────────────────────────────────────────────

func validateIntent(intent *limitsv1.LimitIntent) error {
	if intent == nil {
		return errors.New("intent: nil")
	}
	if intent.GetTenantId() == "" {
		return errors.New("intent: tenant_id required")
	}
	if intent.GetAmount() == nil {
		return errors.New("intent: amount required")
	}
	if intent.GetAction() == limitsv1.LimitAction_LIMIT_ACTION_UNSPECIFIED {
		return errors.New("intent: action required")
	}
	if len(intent.GetSubjects()) == 0 {
		return errors.New("intent: at least one subject required")
	}
	return nil
}

// actionSubjectRequirements declares the minimum subject set per action.
// Reserve refuses intents missing any required subject type.
//
//nolint:exhaustive,gochecknoglobals // static lookup table; UNSPECIFIED is rejected by validateIntent first
var actionSubjectRequirements = map[limitsv1.LimitAction][]limitsv1.SubjectType{
	limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT: {
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION,
	},
	limitsv1.LimitAction_LIMIT_ACTION_LOAN_REQUEST: {
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION,
	},
	limitsv1.LimitAction_LIMIT_ACTION_LOAN_REPAYMENT: {
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION,
	},
	limitsv1.LimitAction_LIMIT_ACTION_SAVINGS_DEPOSIT: {
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT,
	},
	limitsv1.LimitAction_LIMIT_ACTION_SAVINGS_WITHDRAWAL: {
		limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT,
	},
	limitsv1.LimitAction_LIMIT_ACTION_TRANSFER_ORDER_EXECUTE: {limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT},
	limitsv1.LimitAction_LIMIT_ACTION_INCOMING_PAYMENT:       {limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT},
	limitsv1.LimitAction_LIMIT_ACTION_FUNDING_INFLOW:         {limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION},
	limitsv1.LimitAction_LIMIT_ACTION_FUNDING_OUTFLOW:        {limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION},
	limitsv1.LimitAction_LIMIT_ACTION_STAWI_CONTRIBUTION:     {limitsv1.SubjectType_SUBJECT_TYPE_CLIENT},
	limitsv1.LimitAction_LIMIT_ACTION_STAWI_PAYOUT:           {limitsv1.SubjectType_SUBJECT_TYPE_CLIENT},
}

func validateRequiredSubjects(intent *limitsv1.LimitIntent) error {
	required, ok := actionSubjectRequirements[intent.GetAction()]
	if !ok {
		return nil // unknown action: caller already validated
	}
	have := make(map[limitsv1.SubjectType]bool)
	for _, s := range intent.GetSubjects() {
		have[s.GetType()] = true
	}
	for _, r := range required {
		if !have[r] {
			return fmt.Errorf("intent: action %s requires subject_type %s",
				intent.GetAction().String(), r.String())
		}
	}
	return nil
}

// findSubjectByType returns the first SubjectRef whose type maps to the given
// models.Subject value.
func findSubjectByType(subjects []*limitsv1.SubjectRef, t models.Subject) (*limitsv1.SubjectRef, bool) {
	target := subjectToAPILocal(t)
	for _, s := range subjects {
		if s.GetType() == target {
			return s, true
		}
	}
	return nil, false
}

// subjectToAPILocal mirrors models.subjectToAPI (package-private) without
// importing a non-exported symbol.
func subjectToAPILocal(t models.Subject) limitsv1.SubjectType {
	switch t {
	case models.SubjectClient:
		return limitsv1.SubjectType_SUBJECT_TYPE_CLIENT
	case models.SubjectAccount:
		return limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT
	case models.SubjectProduct:
		return limitsv1.SubjectType_SUBJECT_TYPE_PRODUCT
	case models.SubjectOrganization:
		return limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION
	case models.SubjectOrgUnit:
		return limitsv1.SubjectType_SUBJECT_TYPE_ORG_UNIT
	case models.SubjectWorkforceMember:
		return limitsv1.SubjectType_SUBJECT_TYPE_WORKFORCE_MEMBER
	default:
		return limitsv1.SubjectType_SUBJECT_TYPE_UNSPECIFIED
	}
}

// subjectFromAPILocal is the inverse of subjectToAPILocal: converts a proto
// SubjectType back to the models.Subject string used in ledger entries.
func subjectFromAPILocal(t limitsv1.SubjectType) models.Subject {
	switch t {
	case limitsv1.SubjectType_SUBJECT_TYPE_CLIENT:
		return models.SubjectClient
	case limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT:
		return models.SubjectAccount
	case limitsv1.SubjectType_SUBJECT_TYPE_PRODUCT:
		return models.SubjectProduct
	case limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION:
		return models.SubjectOrganization
	case limitsv1.SubjectType_SUBJECT_TYPE_ORG_UNIT:
		return models.SubjectOrgUnit
	case limitsv1.SubjectType_SUBJECT_TYPE_WORKFORCE_MEMBER:
		return models.SubjectWorkforceMember
	case limitsv1.SubjectType_SUBJECT_TYPE_UNSPECIFIED:
		return ""
	default:
		return ""
	}
}

// evaluatePredicate evaluates a Policy.AttributeFilter (a jsonb field) against
// the given attribute map. Supported operators in v1: "in" (array), "eq" (literal).
// Unknown operators or malformed filter → false (predicate denies).
//
//nolint:gocognit,nestif // small recursive-free matcher; flattening the operator checks hurts clarity
func evaluatePredicate(filter datatypes.JSON, attrs map[string]any) bool {
	if len(filter) == 0 {
		return true
	}
	var spec map[string]any
	if err := json.Unmarshal(filter, &spec); err != nil {
		return false
	}
	if attrs == nil {
		return false
	}
	for key, want := range spec {
		got, ok := attrs[key]
		if !ok {
			return false
		}
		switch w := want.(type) {
		case map[string]any:
			if inList, has := w["in"].([]any); has {
				match := false
				for _, e := range inList {
					if fmt.Sprint(e) == fmt.Sprint(got) {
						match = true
						break
					}
				}
				if !match {
					return false
				}
			} else if eqVal, hasEq := w["eq"]; hasEq {
				if fmt.Sprint(eqVal) != fmt.Sprint(got) {
					return false
				}
			} else {
				return false
			}
		default:
			if fmt.Sprint(want) != fmt.Sprint(got) {
				return false
			}
		}
	}
	return true
}

func intentHash(intent *limitsv1.LimitIntent, idempotencyKey string) string {
	currency := intent.GetAmount().GetCurrencyCode()
	amountMinor, _ := moneyx.ToMinorUnitsByCurrency(intent.GetAmount(), currency)
	subjects := ""
	var subjectsSb951 strings.Builder
	for _, s := range intent.GetSubjects() {
		subjectsSb951.WriteString(s.GetType().String() + ":" + s.GetId() + ";")
	}
	subjects += subjectsSb951.String()
	raw := fmt.Sprintf("%s|%s|%s|%d|%s|%s|%s|%s",
		idempotencyKey,
		intent.GetAction().String(),
		intent.GetTenantId(),
		amountMinor,
		currency,
		intent.GetOrgUnitId(),
		intent.GetMakerId(),
		subjects,
	)
	h := sha256.Sum256([]byte(raw))
	return hex.EncodeToString(h[:])
}

func reservationIntentHash(r *models.Reservation) string {
	subjects := ""
	if refs, err := unmarshalReservationSubjects(r.SubjectRefs); err == nil {
		var subjectsSb971 strings.Builder
		for _, s := range refs {
			subjectsSb971.WriteString(s.GetType().String() + ":" + s.GetId() + ";")
		}
		subjects += subjectsSb971.String()
	}
	raw := fmt.Sprintf("%s|%s|%s|%d|%s|%s|%s|%s",
		r.IdempotencyKey,
		models.ActionToAPISafe(r.Action).String(),
		r.TenantID,
		r.Amount,
		r.CurrencyCode,
		r.OrgUnitID,
		r.MakerID,
		subjects,
	)
	h := sha256.Sum256([]byte(raw))
	return hex.EncodeToString(h[:])
}

// unmarshalReservationSubjects pulls subject_refs JSON back into proto SubjectRefs.
// The JSON shape is [{"type":"client","id":"..."},...] as written by models.marshalSubjectRefs.
func unmarshalReservationSubjects(j datatypes.JSON) ([]*limitsv1.SubjectRef, error) {
	if len(j) == 0 {
		return nil, nil
	}
	type sr struct {
		Type string `json:"type"`
		ID   string `json:"id"`
	}
	var raw []sr
	if err := json.Unmarshal(j, &raw); err != nil {
		return nil, err
	}
	out := make([]*limitsv1.SubjectRef, len(raw))
	for i, r := range raw {
		out[i] = &limitsv1.SubjectRef{
			Type: subjectToAPILocal(models.Subject(r.Type)),
			Id:   r.ID,
		}
	}
	return out, nil
}

func verdictsJSON(verdicts []*limitsv1.PolicyVerdict) datatypes.JSON {
	type vr struct {
		PolicyID             string `json:"policy_id"`
		PolicyVersion        int32  `json:"policy_version"`
		Matched              bool   `json:"matched"`
		Breached             bool   `json:"breached"`
		WouldRequireApproval bool   `json:"would_require_approval"`
		Mode                 string `json:"mode"`
		Reason               string `json:"reason"`
	}
	out := make([]vr, len(verdicts))
	for i, v := range verdicts {
		out[i] = vr{
			PolicyID:             v.GetPolicyId(),
			PolicyVersion:        v.GetPolicyVersion(),
			Matched:              v.GetMatched(),
			Breached:             v.GetBreached(),
			WouldRequireApproval: v.GetWouldRequireApproval(),
			Mode:                 v.GetMode().String(),
			Reason:               v.GetReason(),
		}
	}
	b, _ := json.Marshal(out)
	return datatypes.JSON(b)
}

// approvalTTLForPolicies returns the SHORTEST effective approval TTL across
// the involved policies — conservative on stale-approval risk. Each policy is
// read through EffectiveApprovalTTL, so a stored zero or sub-minimum value
// can never produce an instantly-expired approval; with no policies at all
// the default applies.
func approvalTTLForPolicies(specs []approvalSpec) time.Duration {
	shortest := models.DefaultApprovalTTL
	for _, s := range specs {
		if d := s.policy.EffectiveApprovalTTL(); d < shortest {
			shortest = d
		}
	}
	return shortest
}

func requiredApproverCount(rows []*models.ApprovalRequest) int32 {
	highest := int32(0)
	for _, r := range rows {
		if r.RequiredCount > highest {
			highest = r.RequiredCount
		}
	}
	return highest
}

// resolveApplicable filters candidate policies down to those whose subject
// type appears in the intent and whose attribute predicate matches.
//
// Attribute resolution failing (identity down, no attributes available) fails
// CLOSED for enforce-mode policies: the policy is reported as breached rather
// than silently skipped, so a KYC-tier or country cap cannot be bypassed by
// making the identity lookup fail. Shadow-mode policies are still skipped.
func (b *reservationBusiness) resolveApplicable(
	ctx context.Context,
	intent *limitsv1.LimitIntent,
	cands []*models.Policy,
) ([]candidatePair, []*limitsv1.PolicyVerdict) {
	var applicable []candidatePair
	var unresolved []*limitsv1.PolicyVerdict
	for _, p := range cands {
		s, ok := findSubjectByType(intent.GetSubjects(), p.SubjectType)
		if !ok {
			continue
		}
		if len(p.AttributeFilter) > 0 {
			attrs, attrErr := b.resolver.Get(ctx, p.SubjectType, s.GetId())
			if attrErr != nil || attrs == nil {
				util.Log(ctx).WithError(attrErr).
					With("policy_id", p.ID).
					With("policy_mode", string(p.Mode)).
					Warn("attribute resolution unavailable for attribute-filtered policy")
				if p.Mode == models.ModeEnforce {
					unresolved = append(unresolved, attributeUnavailableVerdict(p))
				}
				continue
			}
			if !evaluatePredicate(p.AttributeFilter, attrs) {
				continue
			}
		}
		applicable = append(applicable, candidatePair{
			policy:  p,
			subject: repository.SubjectFilter{Type: p.SubjectType, ID: s.GetId()},
		})
	}
	return applicable, unresolved
}

// attributeUnavailableVerdict is the fail-closed verdict for an enforce-mode
// policy whose subject attributes could not be resolved.
func attributeUnavailableVerdict(p *models.Policy) *limitsv1.PolicyVerdict {
	return &limitsv1.PolicyVerdict{
		PolicyId:      p.ID,
		PolicyVersion: int32(p.Version), //nolint:gosec // version counters never approach int32 range
		Matched:       true,
		Breached:      true,
		Mode:          policyModeToAPI(p.Mode),
		Reason:        "subject attributes unavailable; enforce policy fails closed",
	}
}

// recordBreaches persists the hard- and shadow-breach audit rows for a denied
// Reserve inside their own committed transaction. A denial is a regulatory
// record, so it must not ride the fire-and-forget events bus.
func (b *reservationBusiness) recordBreaches(
	ctx context.Context,
	intent *limitsv1.LimitIntent,
	intentMinor int64,
	hardBreaches, shadowBreaches []*limitsv1.PolicyVerdict,
) {
	if b.dbPool == nil {
		for _, v := range hardBreaches {
			b.auditing.RecordBreachHard(ctx, intent, []*limitsv1.PolicyVerdict{v}, FormatBreachReason(v, intentMinor))
		}
		for _, v := range shadowBreaches {
			b.auditing.RecordBreachShadow(ctx, intent, v)
		}
		return
	}
	err := b.dbPool.DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		for _, v := range hardBreaches {
			if wErr := b.auditing.RecordBreachHardTx(
				ctx, tx, intent, []*limitsv1.PolicyVerdict{v}, FormatBreachReason(v, intentMinor),
			); wErr != nil {
				return wErr
			}
		}
		for _, v := range shadowBreaches {
			if wErr := b.auditing.RecordBreachShadowTx(ctx, tx, intent, v); wErr != nil {
				return wErr
			}
		}
		return nil
	})
	if err != nil {
		util.Log(ctx).WithError(err).Error("limits: breach audit write failed")
	}
}

// isUniqueViolation reports whether err is a Postgres unique-constraint
// violation (SQLSTATE 23505).
func isUniqueViolation(err error) bool {
	if err == nil {
		return false
	}
	if errors.Is(err, gorm.ErrDuplicatedKey) {
		return true
	}
	msg := err.Error()
	return strings.Contains(msg, "23505") ||
		strings.Contains(msg, "duplicate key value violates unique constraint")
}

// stampMakerFromClaims overwrites intent.maker_id with the authenticated
// caller. The wire field is caller-controlled and drives the maker-exclusion
// rule on approvals, so it is never trusted as supplied.
func stampMakerFromClaims(ctx context.Context, intent *limitsv1.LimitIntent) {
	if intent == nil {
		return
	}
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return
	}
	if actor := claims.GetProfileID(); actor != "" {
		intent.MakerId = actor
	}
}

// callerTenant returns the tenant carried by the request's claims, or "".
func callerTenant(ctx context.Context) string {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return ""
	}
	return claims.GetTenantID()
}

// assertSameTenant fails with NotFound when the row belongs to another tenant.
// GetByID does not apply the tenancy scope, so this is the defence-in-depth
// guard for the ID-only runtime RPCs. NotFound (not PermissionDenied) avoids
// leaking the existence of another tenant's reservation.
//
// It fails closed: claims that carry no tenant match no row. Only an
// internal-system principal legitimately acts across tenants.
func assertSameTenant(ctx context.Context, rowTenant string) error {
	if isCrossTenantPrincipal(ctx) {
		return nil
	}
	if ctxTenant := callerTenant(ctx); ctxTenant == "" || rowTenant != ctxTenant {
		return connect.NewError(connect.CodeNotFound, errors.New("reservation not found"))
	}
	return nil
}

// isCrossTenantPrincipal reports whether the caller is the one role allowed to
// operate outside a single tenant: the internal-system service principal. It
// carries no tenant claim of its own, so the tenant guards would otherwise
// reject every call it makes. See docs/runbook/limits-rollout.md.
func isCrossTenantPrincipal(ctx context.Context) bool {
	claims := security.ClaimsFromContext(ctx)
	return claims != nil && claims.IsInternalSystem()
}
