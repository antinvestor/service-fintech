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
// approval.go implements the ApprovalBusiness interface: List, Get, Decide.
// Decide enforces maker-cannot-approve, double-vote uniqueness, and
// re-runs the per-policy evaluator at the moment the last required
// approver lands so previously-passing rolling-window policies that
// have now tipped over auto-reject.
package business

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/datastore/pool"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/events"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// ApprovalBusiness is the service-layer entry point for approval workflow management.
type ApprovalBusiness interface {
	List(
		ctx context.Context,
		req *limitsv1.ApprovalRequestListRequest,
		batch func(ctx context.Context, items []*limitsv1.ApprovalRequestObject) error,
	) error
	Get(ctx context.Context, id string) (*limitsv1.ApprovalRequestObject, error)
	Decide(ctx context.Context, req *limitsv1.ApprovalRequestDecideRequest) (*limitsv1.ApprovalRequestObject, error)
}

// PermissionChecker verifies a functional permission for the caller in the
// service's own Keto namespace. *authorizer.FunctionChecker satisfies it.
type PermissionChecker interface {
	Check(ctx context.Context, permission string) error
}

// PermissionApprovalOverride is the OPL permit that lets a caller decide an
// approval request whose tier role they do not themselves hold.
const PermissionApprovalOverride = "limits_approval_override"

type approvalBusiness struct {
	approvalRepo repository.ApprovalRequestRepository
	decisionRepo repository.ApprovalDecisionRepository
	resvRepo     repository.ReservationRepository
	policyRepo   repository.PolicyRepository
	evaluator    *Evaluator
	auditing     *Auditing
	eventsMan    fevents.Manager
	dbPool       pool.Pool
	permissions  PermissionChecker
}

// NewApprovalBusiness wires up dependencies. eventsMan may be nil,
// in which case event emission is a no-op.
// permissions may be nil, in which case limits_approval_override cannot be
// used to bypass a tier role.
func NewApprovalBusiness(
	approvalRepo repository.ApprovalRequestRepository,
	decisionRepo repository.ApprovalDecisionRepository,
	resvRepo repository.ReservationRepository,
	policyRepo repository.PolicyRepository,
	evaluator *Evaluator,
	auditing *Auditing,
	eventsMan fevents.Manager,
	dbPool pool.Pool,
	permissions PermissionChecker,
) ApprovalBusiness {
	return &approvalBusiness{
		approvalRepo: approvalRepo,
		decisionRepo: decisionRepo,
		resvRepo:     resvRepo,
		policyRepo:   policyRepo,
		evaluator:    evaluator,
		auditing:     auditing,
		eventsMan:    eventsMan,
		dbPool:       dbPool,
		permissions:  permissions,
	}
}

// List streams a page of approval requests filtered by tenant/status/role.
// Only the requested page is fetched: the caller controls the size via
// cursor.limit and drives further pages by re-issuing the call.
func (b *approvalBusiness) List(
	ctx context.Context,
	req *limitsv1.ApprovalRequestListRequest,
	batch func(ctx context.Context, items []*limitsv1.ApprovalRequestObject) error,
) error {
	if err := assertRequestTenant(ctx, req.GetTenantId()); err != nil {
		return err
	}
	filter := repository.ApprovalSearchFilter{}
	if status, err := models.ApprovalStatusFromAPISafe(req.GetStatus()); err == nil {
		filter.Status = status
	}
	if req.GetRequiredRole() != "" {
		filter.RequiredRole = req.GetRequiredRole()
	}
	out, err := b.approvalRepo.Search(ctx, filter, pageSizeFor(req.GetCursor()), req.GetCursor().GetPage())
	if err != nil {
		return err
	}
	ids := make([]string, len(out.Items))
	for i, ar := range out.Items {
		ids[i] = ar.ID
	}
	byRequest, err := b.decisionRepo.ListDecisionsFor(ctx, ids)
	if err != nil {
		return err
	}
	api := make([]*limitsv1.ApprovalRequestObject, len(out.Items))
	for i, ar := range out.Items {
		api[i] = ar.ToAPI(byRequest[ar.ID])
	}
	return batch(ctx, api)
}

// Get looks up an approval request and its decisions, returning the populated wire object.
func (b *approvalBusiness) Get(ctx context.Context, id string) (*limitsv1.ApprovalRequestObject, error) {
	ar, err := b.approvalRepo.GetByID(ctx, id)
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, "approval request not found")
	}
	if tErr := assertApprovalTenant(ctx, ar); tErr != nil {
		return nil, tErr
	}
	decisions, err := b.decisionRepo.ListDecisions(ctx, id)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	return ar.ToAPI(decisions), nil
}

// Sentinels used to carry a decision outcome out of the transaction closure so
// the caller can map it onto the right Connect code.
var (
	errApprovalNoLongerPending = errors.New("approval request no longer pending")
	errApproverAlreadyDecided  = errors.New("approver already decided")
)

// Decide records an approver decision (approve or reject) and transitions the
// approval request and reservation through the state machine.
//
// State machine per spec §6A:
//   - Reject: terminal; releases the reservation.
//   - Approve: count decisions; if quorum reached, re-evaluate all peer policies.
//     If any policy now breaches → auto-reject. Otherwise → approve this request;
//     if all peer requests are now approved → transition reservation to ACTIVE.
//
// Authorisation is three-layered: the RPC needs limits_approval_act, the caller
// must hold the tier's required_role (or limits_approval_override), and the
// maker of the reservation can never approve their own request.
func (b *approvalBusiness) Decide(
	ctx context.Context,
	req *limitsv1.ApprovalRequestDecideRequest,
) (*limitsv1.ApprovalRequestObject, error) {
	ar, err := b.approvalRepo.GetByID(ctx, req.GetId())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, "approval request not found")
	}
	if tErr := assertApprovalTenant(ctx, ar); tErr != nil {
		return nil, tErr
	}

	caller := callerSubject(ctx)
	if caller == "" {
		return nil, connect.NewError(connect.CodeUnauthenticated, "missing caller identity")
	}
	if caller == ar.MakerID {
		return nil, connect.NewError(connect.CodePermissionDenied, "maker cannot approve own request")
	}
	if roleErr := b.assertApproverRole(ctx, ar); roleErr != nil {
		return nil, roleErr
	}
	if ar.Status != models.ApprovalStatusPending {
		return nil, connect.Errorf(connect.CodeFailedPrecondition,
			"approval %s not pending (status=%s)", ar.ID, ar.Status)
	}
	if time.Now().UTC().After(ar.ExpiresAt) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, "approval request expired")
	}

	switch req.GetDecision() {
	case decisionReject:
		return b.decideReject(ctx, ar, caller, req.GetNote())
	case decisionApprove:
		return b.decideApprove(ctx, ar, caller, req.GetNote())
	default:
		return nil, connect.NewError(connect.CodeInvalidArgument,
			`decision must be "approve" or "reject"`)
	}
}

const (
	decisionApprove = "approve"
	decisionReject  = "reject"
)

// assertApproverRole enforces the approver tier's required_role. The caller
// either holds the role in their claims or holds limits_approval_override.
func (b *approvalBusiness) assertApproverRole(ctx context.Context, ar *models.ApprovalRequest) error {
	required := strings.TrimSpace(ar.RequiredRole)
	if required == "" {
		return nil
	}
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return connect.NewError(connect.CodeUnauthenticated, "missing caller identity")
	}
	for _, role := range claims.GetRoles() {
		if strings.EqualFold(strings.TrimSpace(role), required) {
			return nil
		}
	}
	if b.permissions != nil && b.permissions.Check(ctx, PermissionApprovalOverride) == nil {
		util.Log(ctx).
			With("approval_request_id", ar.ID).
			With("required_role", required).
			Info("limits: approval decided under limits_approval_override")
		return nil
	}
	return connect.Errorf(connect.CodePermissionDenied,
		"approver does not hold required role %q", required)
}

// decideReject records a rejection and releases the reservation atomically.
func (b *approvalBusiness) decideReject(
	ctx context.Context,
	ar *models.ApprovalRequest,
	caller, note string,
) (*limitsv1.ApprovalRequestObject, error) {
	now := time.Now().UTC()
	txErr := b.runInTx(ctx, func(tx *gorm.DB) error {
		if lockErr := b.lockPending(ctx, tx, ar.ID); lockErr != nil {
			return lockErr
		}
		if recErr := b.recordDecision(ctx, tx, ar.ID, caller, decisionReject, note, now); recErr != nil {
			return recErr
		}
		if sErr := b.setStatus(ctx, tx, ar.ID, models.ApprovalStatusRejected, &now); sErr != nil {
			return sErr
		}
		ar.Status = models.ApprovalStatusRejected
		ar.DecidedAt = &now
		if rErr := b.releaseReservation(ctx, tx, ar.ReservationID, "approval rejected: "+note, now); rErr != nil {
			return rErr
		}
		if tx == nil {
			return nil
		}
		return b.auditing.RecordApprovalRejectedTx(ctx, tx, ar, caller, note)
	})
	if txErr != nil {
		return nil, mapDecisionErr(txErr)
	}
	emitEvent(ctx, b.eventsMan, events.EventApprovalRejected, events.ApprovalEventPayload{
		ReservationID:     ar.ReservationID,
		ApprovalRequestID: ar.ID,
		TenantID:          ar.TenantID,
		Action:            string(ar.Action),
		MakerID:           ar.MakerID,
		Reason:            note,
	})
	return b.fetchWithDecisions(ctx, ar.ID)
}

// decideApprove records an approval and, when the decision completes the
// quorum, re-evaluates every peer policy and activates the reservation. The
// whole sequence runs inside one transaction with the approval row locked
// FOR UPDATE so two concurrent final approvers cannot both activate.
//
//nolint:gocognit,funlen // quorum decision flow is a single auditable sequence
func (b *approvalBusiness) decideApprove(
	ctx context.Context,
	ar *models.ApprovalRequest,
	caller, note string,
) (*limitsv1.ApprovalRequestObject, error) {
	now := time.Now().UTC()
	quorumReached := false
	autoRejected := false
	failingReason := ""

	txErr := b.runInTx(ctx, func(tx *gorm.DB) error {
		if lockErr := b.lockPending(ctx, tx, ar.ID); lockErr != nil {
			return lockErr
		}
		if recErr := b.recordDecision(ctx, tx, ar.ID, caller, decisionApprove, note, now); recErr != nil {
			return recErr
		}
		decisions, listErr := b.listDecisions(ctx, tx, ar.ID)
		if listErr != nil {
			return listErr
		}
		approveCount := int32(0)
		for _, dd := range decisions {
			if dd.Decision == decisionApprove {
				approveCount++
			}
		}
		if approveCount < ar.RequiredCount {
			return nil // still pending more approvers
		}
		quorumReached = true

		resv, resvErr := b.resvRepo.GetByID(ctx, ar.ReservationID)
		if resvErr != nil {
			return resvErr
		}
		peers, peersErr := b.approvalRepo.ListByReservation(ctx, ar.ReservationID)
		if peersErr != nil {
			return peersErr
		}
		reason, recheckErr := b.recheckPeers(ctx, resv, peers)
		if recheckErr != nil {
			return recheckErr
		}
		if reason != "" {
			autoRejected = true
			failingReason = reason
			ar.Status = models.ApprovalStatusAutoRejectedRecheck
			ar.DecidedAt = &now
			if sErr := b.setStatus(ctx, tx, ar.ID, models.ApprovalStatusAutoRejectedRecheck, &now); sErr != nil {
				return sErr
			}
			if rErr := b.releaseReservation(ctx, tx, resv.ID, "auto-rejected: "+reason, now); rErr != nil {
				return rErr
			}
			if tx == nil {
				return nil
			}
			return b.auditing.RecordApprovalAutoRejectedTx(ctx, tx, ar, reason)
		}

		allApproved := true
		for _, peer := range peers {
			if peer.ID == ar.ID {
				continue
			}
			if peer.Status != models.ApprovalStatusApproved {
				allApproved = false
				break
			}
		}
		ar.Status = models.ApprovalStatusApproved
		ar.DecidedAt = &now
		if sErr := b.setStatus(ctx, tx, ar.ID, models.ApprovalStatusApproved, &now); sErr != nil {
			return sErr
		}
		if allApproved {
			if aErr := b.activateReservation(ctx, tx, resv.ID); aErr != nil {
				return aErr
			}
		}
		if tx == nil {
			return nil
		}
		return b.auditing.RecordApprovalApprovedTx(ctx, tx, ar, caller)
	})
	if txErr != nil {
		return nil, mapDecisionErr(txErr)
	}

	switch {
	case autoRejected:
		emitEvent(ctx, b.eventsMan, events.EventApprovalAutoRejected, events.ApprovalEventPayload{
			ReservationID:     ar.ReservationID,
			ApprovalRequestID: ar.ID,
			TenantID:          ar.TenantID,
			Action:            string(ar.Action),
			MakerID:           ar.MakerID,
			Reason:            failingReason,
		})
	case quorumReached:
		emitEvent(ctx, b.eventsMan, events.EventApprovalApproved, events.ApprovalEventPayload{
			ReservationID:     ar.ReservationID,
			ApprovalRequestID: ar.ID,
			TenantID:          ar.TenantID,
			Action:            string(ar.Action),
			MakerID:           ar.MakerID,
		})
	}
	return b.fetchWithDecisions(ctx, ar.ID)
}

// recheckPeers re-evaluates the triggering policy of every peer approval
// request at the moment quorum lands. It returns a non-empty reason when the
// reservation must be auto-rejected.
//
// A policy that merely still "would require approval" at its recorded tier is
// not a re-breach — that condition is exactly why the approval exists. The
// re-breach conditions are: the policy now hard-breaches, the approver tiers no
// longer cover the amount at all, or the tier now demanded is stricter than the
// one the approvers actually satisfied.
func (b *approvalBusiness) recheckPeers(
	ctx context.Context,
	resv *models.Reservation,
	peers []*models.ApprovalRequest,
) (string, error) {
	intent, err := intentFromReservation(resv)
	if err != nil {
		return "", err
	}
	intentMinor, minorErr := moneyx.ToMinorUnitsByCurrency(intent.GetAmount(), intent.GetAmount().GetCurrencyCode())
	if minorErr != nil {
		return "", minorErr
	}
	for _, peer := range peers {
		policy, policyErr := b.policyRepo.Get(ctx, peer.TriggeringPolicyID)
		if policyErr != nil {
			// A policy that has vanished cannot be re-verified, so the safe
			// answer at quorum time is to auto-reject rather than activate.
			util.Log(ctx).WithError(policyErr).
				With("policy_id", peer.TriggeringPolicyID).
				Warn("limits: triggering policy could not be re-read at recheck")
			return "policy lookup failed for " + peer.TriggeringPolicyID, nil
		}
		s, ok := findSubjectByType(intent.GetSubjects(), policy.SubjectType)
		if !ok {
			return "intent missing required subject for policy " + policy.ID, nil
		}
		v, evalErr := b.evaluator.Evaluate(
			ctx,
			policy,
			repository.SubjectFilter{Type: policy.SubjectType, ID: s.GetId()},
			intent,
			intentMinor,
		)
		if evalErr != nil {
			return "", evalErr
		}
		if v.GetBreached() {
			return "policy " + policy.ID + " now breaches: " + v.GetReason(), nil
		}
		if !v.GetWouldRequireApproval() {
			continue
		}
		tier, covered := pickTier(policy, intentMinor)
		if !covered {
			return "policy " + policy.ID + " no longer has an approver tier covering the amount", nil
		}
		if tier.Approvers > peer.RequiredCount || !strings.EqualFold(tier.Role, peer.RequiredRole) {
			return "policy " + policy.ID + " now demands a stricter approver tier", nil
		}
	}
	return "", nil
}

// ─── transaction-aware repository shims ────────────────────────────────

func (b *approvalBusiness) lockPending(ctx context.Context, tx *gorm.DB, id string) error {
	if tx == nil {
		return nil
	}
	locked, err := b.approvalRepo.GetForUpdateTx(ctx, tx, id)
	if err != nil {
		return err
	}
	if locked.Status != models.ApprovalStatusPending {
		return errApprovalNoLongerPending
	}
	return nil
}

func (b *approvalBusiness) recordDecision(
	ctx context.Context,
	tx *gorm.DB,
	approvalID, approverID, decision, note string,
	at time.Time,
) error {
	d := &models.ApprovalDecision{
		ApprovalRequestID: approvalID,
		ApproverID:        approverID,
		Decision:          decision,
		Note:              note,
		DecidedAt:         at,
	}
	d.ID = util.IDString()
	var err error
	if tx == nil {
		err = b.decisionRepo.RecordDecision(ctx, d)
	} else {
		err = b.decisionRepo.RecordDecisionTx(ctx, tx, d)
	}
	if err != nil {
		// The unique index on (approval_request_id, approver_id) blocks double-voting.
		return errApproverAlreadyDecided
	}
	return nil
}

func (b *approvalBusiness) listDecisions(
	ctx context.Context,
	tx *gorm.DB,
	approvalID string,
) ([]*models.ApprovalDecision, error) {
	if tx == nil {
		return b.decisionRepo.ListDecisions(ctx, approvalID)
	}
	return b.decisionRepo.ListDecisionsTx(ctx, tx, approvalID)
}

func (b *approvalBusiness) setStatus(
	ctx context.Context,
	tx *gorm.DB,
	id string,
	status models.ApprovalStatus,
	decidedAt *time.Time,
) error {
	if tx == nil {
		return b.approvalRepo.SetStatus(ctx, id, status, decidedAt)
	}
	return b.approvalRepo.SetStatusTx(ctx, tx, id, status, decidedAt)
}

// releaseReservation cascades a release inside the decision's transaction.
// The repository guards on rows-affected: a reservation the caller already
// released (or that is otherwise terminal) is tolerated and logged, because
// the decision itself is still valid; any other failure aborts the decision so
// the approval row and the hold it gates never disagree.
func (b *approvalBusiness) releaseReservation(
	ctx context.Context,
	tx *gorm.DB,
	reservationID, reason string,
	at time.Time,
) error {
	var err error
	if tx == nil {
		err = b.resvRepo.SetReleased(ctx, reservationID, reason, at)
	} else {
		err = b.resvRepo.SetReleasedTx(ctx, tx, reservationID, reason, at)
	}
	switch {
	case err == nil:
		return nil
	case errors.Is(err, repository.ErrReservationNotReleasable):
		util.Log(ctx).
			With("reservation_id", reservationID).
			Warn("limits: reservation already terminal at approval cascade; nothing to release")
		return nil
	default:
		return fmt.Errorf("release reservation %s: %w", reservationID, err)
	}
}

func (b *approvalBusiness) activateReservation(ctx context.Context, tx *gorm.DB, reservationID string) error {
	if tx == nil {
		return b.resvRepo.SetActive(ctx, reservationID)
	}
	return b.resvRepo.SetActiveTx(ctx, tx, reservationID)
}

func mapDecisionErr(err error) error {
	switch {
	case errors.Is(err, errApproverAlreadyDecided):
		return connect.NewError(connect.CodeAlreadyExists, err.Error()).WithCause(err)
	case errors.Is(err, errApprovalNoLongerPending), errors.Is(err, repository.ErrApprovalNotPending):
		return connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	case errors.Is(err, repository.ErrNotPendingApproval):
		return connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	default:
		return connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
}

// assertApprovalTenant rejects access to an approval row owned by another
// tenant. RLS already scopes the read; this is the explicit second control.
//
// It fails closed: claims that are absent, or that carry no tenant, match no
// row. Only an internal-system principal legitimately acts across tenants.
func assertApprovalTenant(ctx context.Context, ar *models.ApprovalRequest) error {
	if isCrossTenantPrincipal(ctx) {
		return nil
	}
	if ctxTenant := callerTenant(ctx); ctxTenant == "" || ar.TenantID != ctxTenant {
		return connect.NewError(connect.CodeNotFound, "approval request not found")
	}
	return nil
}

// assertRequestTenant rejects a request whose tenant_id filter names a tenant
// other than the caller's.
//
// The interceptor has already stamped the field from the caller's claims, so
// this is the defence-in-depth repeat of that check. It fails closed: a caller
// with no tenant claim can filter on no tenant. Only an internal-system
// principal legitimately names a tenant that is not its own.
func assertRequestTenant(ctx context.Context, requested string) error {
	if isCrossTenantPrincipal(ctx) {
		return nil
	}
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return connect.NewError(connect.CodeUnauthenticated, "missing caller identity")
	}
	ctxTenant := claims.GetTenantID()
	if ctxTenant == "" {
		return connect.NewError(connect.CodeUnauthenticated, "caller claims carry no tenant")
	}
	if requested != "" && requested != ctxTenant {
		return connect.NewError(connect.CodePermissionDenied, "tenant mismatch")
	}
	return nil
}

// runInTx executes fn inside a GORM transaction. If dbPool is nil (test mode
// without an injected pool), fn is invoked with a nil tx — callers must use
// the non-Tx repository methods in that case.
func (b *approvalBusiness) runInTx(ctx context.Context, fn func(tx *gorm.DB) error) error {
	if b.dbPool == nil {
		return fn(nil)
	}
	return b.dbPool.DB(ctx, false).Transaction(fn)
}

// fetchWithDecisions re-reads the approval request and its decisions from
// the DB so the returned wire object reflects the persisted state.
func (b *approvalBusiness) fetchWithDecisions(ctx context.Context, id string) (*limitsv1.ApprovalRequestObject, error) {
	ar, err := b.approvalRepo.GetByID(ctx, id)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	decisions, _ := b.decisionRepo.ListDecisions(ctx, id)
	return ar.ToAPI(decisions), nil
}

// callerSubject reads the caller's identity from frame.security claims.
// Falls back to "" if no claims (which Decide rejects with Unauthenticated).
func callerSubject(ctx context.Context) string {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return ""
	}
	return claims.GetProfileID()
}

// intentFromReservation reconstructs a LimitIntent from a stored Reservation
// for re-evaluation. Subjects are unmarshalled from the JSON column.
func intentFromReservation(r *models.Reservation) (*limitsv1.LimitIntent, error) {
	subjects, err := unmarshalReservationSubjects(r.SubjectRefs)
	if err != nil {
		return nil, err
	}
	return &limitsv1.LimitIntent{
		Action:    models.ActionToAPISafe(r.Action),
		TenantId:  r.TenantID,
		OrgUnitId: r.OrgUnitID,
		Amount:    moneyx.FromMinorUnitsByCurrency(r.CurrencyCode, r.Amount),
		Subjects:  subjects,
		MakerId:   r.MakerID,
	}, nil
}
