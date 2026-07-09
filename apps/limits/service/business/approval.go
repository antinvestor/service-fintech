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
	"time"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/datastore/pool"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/frame/v2/security"
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

type approvalBusiness struct {
	approvalRepo repository.ApprovalRequestRepository
	decisionRepo repository.ApprovalDecisionRepository
	resvRepo     repository.ReservationRepository
	policyRepo   repository.PolicyRepository
	evaluator    *Evaluator
	auditing     *Auditing
	eventsMan    fevents.Manager
	dbPool       pool.Pool
}

// NewApprovalBusiness wires up dependencies. eventsMan may be nil,
// in which case event emission is a no-op.
func NewApprovalBusiness(
	approvalRepo repository.ApprovalRequestRepository,
	decisionRepo repository.ApprovalDecisionRepository,
	resvRepo repository.ReservationRepository,
	policyRepo repository.PolicyRepository,
	evaluator *Evaluator,
	auditing *Auditing,
	eventsMan fevents.Manager,
	dbPool pool.Pool,
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
	}
}

// List streams pages of approval requests filtered by tenant/status/role.
// Mirrors policyBusiness.Search from Plan 1 Task 10.
func (b *approvalBusiness) List(
	ctx context.Context,
	req *limitsv1.ApprovalRequestListRequest,
	batch func(ctx context.Context, items []*limitsv1.ApprovalRequestObject) error,
) error {
	const pageSize = 50
	cursor := ""
	if req.GetCursor() != nil {
		cursor = req.GetCursor().GetPage()
	}
	for {
		filter := repository.ApprovalSearchFilter{}
		if status, err := models.ApprovalStatusFromAPISafe(req.GetStatus()); err == nil {
			filter.Status = status
		}
		if req.GetRequiredRole() != "" {
			filter.RequiredRole = req.GetRequiredRole()
		}
		out, err := b.approvalRepo.Search(ctx, filter, pageSize, cursor)
		if err != nil {
			return err
		}
		api := make([]*limitsv1.ApprovalRequestObject, len(out.Items))
		for i, ar := range out.Items {
			decisions, _ := b.decisionRepo.ListDecisions(ctx, ar.ID)
			api[i] = ar.ToAPI(decisions)
		}
		if batchErr := batch(ctx, api); batchErr != nil {
			return batchErr
		}
		if out.NextCursor == "" {
			return nil
		}
		cursor = out.NextCursor
	}
}

// Get looks up an approval request and its decisions, returning the populated wire object.
func (b *approvalBusiness) Get(ctx context.Context, id string) (*limitsv1.ApprovalRequestObject, error) {
	ar, err := b.approvalRepo.GetByID(ctx, id)
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err)
	}
	decisions, err := b.decisionRepo.ListDecisions(ctx, id)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return ar.ToAPI(decisions), nil
}

// Decide records an approver decision (approve or reject) and transitions the
// approval request and reservation through the state machine.
//
// State machine per spec §6A:
//   - Reject: terminal; releases the reservation.
//   - Approve: count decisions; if quorum reached, re-evaluate all peer policies.
//     If any policy now breaches → auto-reject. Otherwise → approve this request;
//     if all peer requests are now approved → transition reservation to ACTIVE.
//
// The decision-record + quorum-check + reservation-activate sequence is wrapped
// in a single DB transaction so a crash mid-flow cannot strand the reservation
// in pending_approval without a matching Approval row.
//
// TODO(plan-4): per-policy role check via Keto. Currently the limits_approval_act
// permission on the RPC boundary is the only gate, supplemented by maker-exclusion.
//
//nolint:gocognit,gocyclo,cyclop,funlen // quorum decision flow is a single auditable sequence; splitting obscures the state machine
func (b *approvalBusiness) Decide(
	ctx context.Context,
	req *limitsv1.ApprovalRequestDecideRequest,
) (*limitsv1.ApprovalRequestObject, error) {
	ar, err := b.approvalRepo.GetByID(ctx, req.GetId())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err)
	}

	// 2C.4: Tenant check — approval row must belong to caller's tenant.
	claims := security.ClaimsFromContext(ctx)
	if claims != nil {
		ctxTenant := claims.GetTenantID()
		if ctxTenant != "" && ar.TenantID != ctxTenant {
			return nil, connect.NewError(connect.CodePermissionDenied,
				errors.New("approval belongs to a different tenant"))
		}
	}

	caller := callerSubject(ctx)
	if caller == "" {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("missing caller identity"))
	}
	if caller == ar.MakerID {
		return nil, connect.NewError(connect.CodePermissionDenied, errors.New("maker cannot approve own request"))
	}
	if ar.Status != models.ApprovalStatusPending {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("approval %s not pending (status=%s)", ar.ID, ar.Status))
	}
	if time.Now().UTC().After(ar.ExpiresAt) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("approval request expired"))
	}

	// 1. Persist decision (unique constraint blocks double-vote).
	// Done outside the main transaction so double-vote detection is immediate
	// and independent of the quorum path.
	d := &models.ApprovalDecision{
		ApprovalRequestID: ar.ID,
		ApproverID:        caller,
		Decision:          req.GetDecision(),
		Note:              req.GetNote(),
		DecidedAt:         time.Now().UTC(),
	}
	d.ID = util.IDString()
	if recordErr := b.decisionRepo.RecordDecision(ctx, d); recordErr != nil {
		// pgx returns code 23505 (unique_violation) on double-vote.
		return nil, connect.NewError(connect.CodeAlreadyExists,
			fmt.Errorf("approver %s already decided", caller))
	}

	// 2. Reject path: terminal, releases the reservation atomically.
	if req.GetDecision() == "reject" {
		now := time.Now().UTC()
		ar.Status = models.ApprovalStatusRejected
		ar.DecidedAt = &now
		if txErr := b.runInTx(ctx, func(tx *gorm.DB) error {
			if tx == nil {
				// No pool injected (test mode): fall back to non-transactional methods.
				if sErr := b.approvalRepo.SetStatus(ctx, ar.ID, models.ApprovalStatusRejected, &now); sErr != nil {
					return sErr
				}
				return b.resvRepo.SetReleased(ctx, ar.ReservationID, "approval rejected: "+req.GetNote(), now)
			}
			if sErr := b.approvalRepo.SetStatusTx(ctx, tx, ar.ID, models.ApprovalStatusRejected, &now); sErr != nil {
				return sErr
			}
			if rErr := b.resvRepo.SetReleasedTx(
				ctx,
				tx,
				ar.ReservationID,
				"approval rejected: "+req.GetNote(),
				now,
			); rErr != nil {
				return rErr
			}
			// Audit inside the tx so the record is durable with the state change.
			return b.auditing.RecordApprovalRejectedTx(ctx, tx, ar, caller, req.GetNote())
		}); txErr != nil {
			return nil, connect.NewError(connect.CodeInternal, txErr)
		}
		emitEvent(ctx, b.eventsMan, events.EventApprovalRejected, events.ApprovalEventPayload{
			ReservationID:     ar.ReservationID,
			ApprovalRequestID: ar.ID,
			TenantID:          ar.TenantID,
			Action:            string(ar.Action),
			MakerID:           ar.MakerID,
			Reason:            req.GetNote(),
		})
		return b.fetchWithDecisions(ctx, ar.ID)
	}

	// 3. Approve path: count approve-decisions; if last needed, re-evaluate.
	decisions, err := b.decisionRepo.ListDecisions(ctx, ar.ID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	approveCount := int32(0)
	for _, dd := range decisions {
		if dd.Decision == "approve" {
			approveCount++
		}
	}
	if approveCount < ar.RequiredCount {
		return ar.ToAPI(decisions), nil // still pending more approvers
	}

	// 4. Last required approver: re-evaluate the original intent.
	resv, err := b.resvRepo.GetByID(ctx, ar.ReservationID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Reconstruct the intent for re-evaluation.
	intent, err := intentFromReservation(resv)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Walk every peer approval request for the same reservation; for each,
	// re-evaluate the triggering policy. If ANY now breaches, auto-reject.
	peers, err := b.approvalRepo.ListByReservation(ctx, ar.ReservationID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	allClear := true
	var failingReason string
	for _, peer := range peers {
		policy, policyErr := b.policyRepo.Get(ctx, peer.TriggeringPolicyID)
		if policyErr != nil {
			allClear = false
			failingReason = "policy lookup failed: " + policyErr.Error()
			break
		}
		// Find the matching subject from the intent.
		s, ok := findSubjectByType(intent.GetSubjects(), policy.SubjectType)
		if !ok {
			allClear = false
			failingReason = "intent missing required subject for policy " + policy.ID
			break
		}
		intentMinor, _ := moneyx.ToMinorUnitsByCurrency(intent.GetAmount(), intent.GetAmount().GetCurrencyCode())
		v, evalErr := b.evaluator.Evaluate(
			ctx,
			policy,
			repository.SubjectFilter{Type: policy.SubjectType, ID: s.GetId()},
			intent,
			intentMinor,
		)
		if evalErr != nil {
			allClear = false
			failingReason = "evaluator error: " + evalErr.Error()
			break
		}
		if v.GetBreached() {
			allClear = false
			failingReason = "policy " + policy.ID + " now breaches: " + v.GetReason()
			break
		}
	}

	now := time.Now().UTC()
	if !allClear {
		// Auto-reject path: update status + release reservation atomically.
		ar.Status = models.ApprovalStatusAutoRejectedRecheck
		ar.DecidedAt = &now
		if txErr := b.runInTx(ctx, func(tx *gorm.DB) error {
			if tx == nil {
				if sErr := b.approvalRepo.SetStatus(
					ctx,
					ar.ID,
					models.ApprovalStatusAutoRejectedRecheck,
					&now,
				); sErr != nil {
					return sErr
				}
				return b.resvRepo.SetReleased(ctx, resv.ID, "auto-rejected: "+failingReason, now)
			}
			if sErr := b.approvalRepo.SetStatusTx(
				ctx,
				tx,
				ar.ID,
				models.ApprovalStatusAutoRejectedRecheck,
				&now,
			); sErr != nil {
				return sErr
			}
			if rErr := b.resvRepo.SetReleasedTx(ctx, tx, resv.ID, "auto-rejected: "+failingReason, now); rErr != nil {
				return rErr
			}
			// Audit inside the tx so the record is durable with the state change.
			return b.auditing.RecordApprovalAutoRejectedTx(ctx, tx, ar, failingReason)
		}); txErr != nil {
			return nil, connect.NewError(connect.CodeInternal, txErr)
		}
		emitEvent(ctx, b.eventsMan, events.EventApprovalAutoRejected, events.ApprovalEventPayload{
			ReservationID:     ar.ReservationID,
			ApprovalRequestID: ar.ID,
			TenantID:          ar.TenantID,
			Action:            string(ar.Action),
			MakerID:           ar.MakerID,
			Reason:            failingReason,
		})
		return b.fetchWithDecisions(ctx, ar.ID)
	}

	// 5. Approve THIS request + conditionally activate reservation atomically (2E).
	// Determine whether all peers are already approved — if so, activation is
	// included in the same transaction.
	allApproved := true
	for _, peer := range peers {
		if peer.ID == ar.ID {
			continue // this is the one we're about to approve
		}
		if peer.Status != models.ApprovalStatusApproved {
			allApproved = false
			break
		}
	}

	ar.Status = models.ApprovalStatusApproved
	ar.DecidedAt = &now

	if txErr := b.runInTx(ctx, func(tx *gorm.DB) error {
		if tx == nil {
			if sErr := b.approvalRepo.SetStatus(ctx, ar.ID, models.ApprovalStatusApproved, &now); sErr != nil {
				return sErr
			}
			if allApproved {
				return b.resvRepo.SetActive(ctx, resv.ID)
			}
			return nil
		}
		if sErr := b.approvalRepo.SetStatusTx(ctx, tx, ar.ID, models.ApprovalStatusApproved, &now); sErr != nil {
			return sErr
		}
		if allApproved {
			if aErr := b.resvRepo.SetActiveTx(ctx, tx, resv.ID); aErr != nil {
				return aErr
			}
		}
		// Audit inside the tx so the record is durable with the state change.
		return b.auditing.RecordApprovalApprovedTx(ctx, tx, ar, caller)
	}); txErr != nil {
		return nil, connect.NewError(connect.CodeInternal, txErr)
	}

	emitEvent(ctx, b.eventsMan, events.EventApprovalApproved, events.ApprovalEventPayload{
		ReservationID:     ar.ReservationID,
		ApprovalRequestID: ar.ID,
		TenantID:          ar.TenantID,
		Action:            string(ar.Action),
		MakerID:           ar.MakerID,
	})
	return b.fetchWithDecisions(ctx, ar.ID)
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
		return nil, connect.NewError(connect.CodeInternal, err)
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
