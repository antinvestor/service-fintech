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
// auditing.go centralises emission of gating-decision audit events
// using the platform's pkg/audit infrastructure with limits.* action
// verbs. Every business path that produces a gating outcome calls
// into this file so the verb namespace and metadata schema stay
// uniform across the service.
package business

import (
	"context"
	"strconv"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

// Audit verbs for the limits gate. Stable strings; never renamed.
const (
	VerbBreachHard              = "limits.breach.hard"
	VerbBreachShadow            = "limits.breach.shadow"
	VerbApprovalRequired        = "limits.approval.required"
	VerbApprovalApproved        = "limits.approval.approved"
	VerbApprovalRejected        = "limits.approval.rejected"
	VerbApprovalAutoRejected    = "limits.approval.auto_rejected"
	VerbApprovalExpired         = "limits.approval.expired"
	VerbApprovalRejectedCascade = "limits.approval.rejected_cascade"
	VerbReservationCommitted    = "limits.reservation.committed"
	VerbReservationReleased     = "limits.reservation.released"
	VerbReservationReversed     = "limits.reservation.reversed"
	VerbReservationExpiredTTL   = "limits.reservation.expired_ttl"
	VerbPolicySaved             = "limits.policy.saved"
	VerbPolicyDeleted           = "limits.policy.deleted"
)

// Audit entity/actor labels and metadata keys shared by the records below.
const (
	auditEntityPolicy = "policy"
	auditActorUser    = "user"
	auditActorSystem  = "system"
	// SystemActorReaper is the actor stamped on audit rows the background
	// reapers write. Those rows have no caller, and an empty actor with type
	// "user" is indistinguishable from a broken claims pipeline.
	SystemActorReaper = "system:limits-reaper"
	mdKeyActionKind   = "action_kind"
	mdKeyMode         = "mode"
	mdKeyAmountMinor  = "amount_minor"
	mdKeyCurrency     = "currency"
)

// actorFromContext returns the authenticated caller's profile id. The actor on
// an audit row must never come from the request body — a maker_id a client can
// choose is not evidence of who acted.
func actorFromContext(ctx context.Context) string {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return ""
	}
	return claims.GetProfileID()
}

// actorOr resolves the audit actor: the authenticated caller when there is
// one, otherwise the supplied fallback (background jobs have no claims).
func actorOr(ctx context.Context, fallback string) string {
	if actor := actorFromContext(ctx); actor != "" {
		return actor
	}
	return fallback
}

// auditActor is the resolved (id, type) pair stamped on a record.
type auditActor struct {
	id   string
	kind string
}

// userActor attributes a record to the authenticated caller, falling back to
// the supplied id when the call has no claims.
func userActor(ctx context.Context, fallback string) auditActor {
	return auditActor{id: actorOr(ctx, fallback), kind: auditActorUser}
}

// makerOf is the nil-safe maker id of a reservation.
func makerOf(r *models.Reservation) string {
	if r == nil {
		return ""
	}
	return r.MakerID
}

// reaperActor attributes a record to the background reaper. It never reads
// claims: a reaper pass carries none, and must not inherit a stray caller.
func reaperActor() auditActor {
	return auditActor{id: SystemActorReaper, kind: auditActorSystem}
}

// Auditing wraps audit.Writer with the limits-specific verbs and metadata
// shape. Injected into business methods that emit gating events.
type Auditing struct {
	writer *audit.Writer
}

// NewAuditing constructs an Auditing wrapper. A nil writer turns the
// helper into a no-op.
func NewAuditing(w *audit.Writer) *Auditing { return &Auditing{writer: w} }

// RecordBreachHard records that a Reserve was denied because at least
// one enforce-mode policy was breached and not approval-eligible.
func (a *Auditing) RecordBreachHard(
	ctx context.Context,
	intent *limitsv1.LimitIntent,
	verdicts []*limitsv1.PolicyVerdict,
	reason string,
) {
	if a == nil || a.writer == nil {
		return
	}
	primaryPolicyID := ""
	if len(verdicts) > 0 {
		primaryPolicyID = verdicts[0].GetPolicyId()
	}
	a.writer.RecordOrLog(ctx, audit.Record{
		EntityType: auditEntityPolicy,
		EntityID:   primaryPolicyID,
		Action:     VerbBreachHard,
		ActorID:    actorOr(ctx, intent.GetMakerId()),
		ActorType:  auditActorUser,
		Reason:     reason,
		Metadata:   intentMetadata(intent, verdicts),
	}, logFailure(ctx))
}

// RecordBreachShadow records a shadow-mode would-have-blocked verdict.
func (a *Auditing) RecordBreachShadow(ctx context.Context, intent *limitsv1.LimitIntent, v *limitsv1.PolicyVerdict) {
	if a == nil || a.writer == nil {
		return
	}
	a.writer.RecordOrLog(ctx, audit.Record{
		EntityType: auditEntityPolicy,
		EntityID:   v.GetPolicyId(),
		Action:     VerbBreachShadow,
		ActorID:    actorOr(ctx, intent.GetMakerId()),
		ActorType:  auditActorUser,
		Reason:     v.GetReason(),
		Metadata:   intentMetadata(intent, []*limitsv1.PolicyVerdict{v}),
	}, logFailure(ctx))
}

// RecordBreachHardTx writes the hard-breach audit row inside tx so the denial
// record commits with the caller's transaction rather than riding the bus.
func (a *Auditing) RecordBreachHardTx(
	ctx context.Context,
	tx *gorm.DB,
	intent *limitsv1.LimitIntent,
	verdicts []*limitsv1.PolicyVerdict,
	reason string,
) error {
	if a == nil || a.writer == nil {
		return nil
	}
	primaryPolicyID := ""
	if len(verdicts) > 0 {
		primaryPolicyID = verdicts[0].GetPolicyId()
	}
	return a.writer.RecordTx(ctx, tx, audit.Record{
		EntityType: auditEntityPolicy,
		EntityID:   primaryPolicyID,
		Action:     VerbBreachHard,
		ActorID:    actorOr(ctx, intent.GetMakerId()),
		ActorType:  auditActorUser,
		Reason:     reason,
		Metadata:   intentMetadata(intent, verdicts),
	})
}

// RecordBreachShadowTx writes the shadow-breach audit row inside tx.
func (a *Auditing) RecordBreachShadowTx(
	ctx context.Context,
	tx *gorm.DB,
	intent *limitsv1.LimitIntent,
	v *limitsv1.PolicyVerdict,
) error {
	if a == nil || a.writer == nil {
		return nil
	}
	return a.writer.RecordTx(ctx, tx, audit.Record{
		EntityType: auditEntityPolicy,
		EntityID:   v.GetPolicyId(),
		Action:     VerbBreachShadow,
		ActorID:    actorOr(ctx, intent.GetMakerId()),
		ActorType:  auditActorUser,
		Reason:     v.GetReason(),
		Metadata:   intentMetadata(intent, []*limitsv1.PolicyVerdict{v}),
	})
}

// RecordReservationCommitted records that a reservation was committed.
func (a *Auditing) RecordReservationCommitted(ctx context.Context, r *models.Reservation) {
	a.recordReservation(ctx, r, VerbReservationCommitted, "committed", "", userActor(ctx, makerOf(r)))
}

// RecordReservationReleased records that a reservation was released.
func (a *Auditing) RecordReservationReleased(ctx context.Context, r *models.Reservation, reason string) {
	a.recordReservation(ctx, r, VerbReservationReleased, "released", reason, userActor(ctx, makerOf(r)))
}

// RecordReservationReversed records that a reservation was reversed.
func (a *Auditing) RecordReservationReversed(ctx context.Context, r *models.Reservation, reason string) {
	a.recordReservation(ctx, r, VerbReservationReversed, "reversed", reason, userActor(ctx, makerOf(r)))
}

// RecordReservationExpiredTTL records that a reservation was expired by the TTL reaper.
func (a *Auditing) RecordReservationExpiredTTL(ctx context.Context, r *models.Reservation) {
	a.recordReservation(ctx, r, VerbReservationExpiredTTL, "expired by TTL reaper", "", reaperActor())
}

func (a *Auditing) recordReservation(
	ctx context.Context,
	r *models.Reservation,
	verb, defaultReason, callerReason string,
	actor auditActor,
) {
	if a == nil || a.writer == nil || r == nil {
		return
	}
	reason := callerReason
	if reason == "" {
		reason = defaultReason
	}
	a.writer.RecordOrLog(ctx, audit.Record{
		EntityType: "reservation",
		EntityID:   r.ID,
		Action:     verb,
		ActorID:    actor.id,
		ActorType:  actor.kind,
		Reason:     reason,
		Metadata:   reservationMetadata(r),
		Parent:     &r.BaseModel,
	}, logFailure(ctx))
}

// RecordApprovalRequired records that an approval request was created.
func (a *Auditing) RecordApprovalRequired(ctx context.Context, ar *models.ApprovalRequest) {
	a.recordApproval(ctx, ar, VerbApprovalRequired, "approval required", "", userActor(ctx, ""))
}

// RecordApprovalApproved records that an approval request was approved.
func (a *Auditing) RecordApprovalApproved(ctx context.Context, ar *models.ApprovalRequest, approverID string) {
	a.recordApproval(ctx, ar, VerbApprovalApproved, "approved", approverID, userActor(ctx, approverID))
}

// RecordApprovalRejected records that an approval request was rejected.
func (a *Auditing) RecordApprovalRejected(ctx context.Context, ar *models.ApprovalRequest, approverID, note string) {
	a.recordApproval(ctx, ar, VerbApprovalRejected, "rejected: "+note, approverID, userActor(ctx, approverID))
}

// RecordApprovalAutoRejected records that an approval request was auto-rejected on recheck.
func (a *Auditing) RecordApprovalAutoRejected(ctx context.Context, ar *models.ApprovalRequest, reason string) {
	a.recordApproval(ctx, ar, VerbApprovalAutoRejected, "auto-rejected on recheck: "+reason, "", userActor(ctx, ""))
}

// RecordApprovalExpired records that an approval request expired pending decision.
func (a *Auditing) RecordApprovalExpired(ctx context.Context, ar *models.ApprovalRequest) {
	a.recordApproval(ctx, ar, VerbApprovalExpired, reasonExpiredPendingDecision, "", reaperActor())
}

const reasonExpiredPendingDecision = "expired pending decision"

func (a *Auditing) recordApproval(
	ctx context.Context,
	ar *models.ApprovalRequest,
	verb, reason, approverID string,
	actor auditActor,
) {
	if a == nil || a.writer == nil || ar == nil {
		return
	}
	md := approvalMetadata(ar)
	if approverID != "" {
		md["approver_id"] = approverID
	}
	a.writer.RecordOrLog(ctx, audit.Record{
		EntityType: "approval_request",
		EntityID:   ar.ID,
		Action:     verb,
		ActorID:    actor.id,
		ActorType:  actor.kind,
		Reason:     reason,
		Metadata:   md,
		Parent:     &ar.BaseModel,
	}, logFailure(ctx))
}

// ─── In-tx variants (durable, same DB tx as state change) ────────────

// RecordReservationCommittedTx writes the committed audit row inside tx.
func (a *Auditing) RecordReservationCommittedTx(ctx context.Context, tx *gorm.DB, r *models.Reservation) error {
	return a.recordReservationTx(ctx, tx, r, VerbReservationCommitted, "committed", "", userActor(ctx, makerOf(r)))
}

// RecordReservationReleasedTx writes the released audit row inside tx.
func (a *Auditing) RecordReservationReleasedTx(
	ctx context.Context,
	tx *gorm.DB,
	r *models.Reservation,
	reason string,
) error {
	return a.recordReservationTx(ctx, tx, r, VerbReservationReleased, "released", reason, userActor(ctx, makerOf(r)))
}

// RecordReservationReversedTx writes the reversed audit row inside tx.
func (a *Auditing) RecordReservationReversedTx(
	ctx context.Context,
	tx *gorm.DB,
	r *models.Reservation,
	reason string,
) error {
	return a.recordReservationTx(ctx, tx, r, VerbReservationReversed, "reversed", reason, userActor(ctx, makerOf(r)))
}

// RecordReservationExpiredTTLTx writes the expired-TTL audit row inside tx,
// attributed to the reaper and scoped to the reservation's tenant.
func (a *Auditing) RecordReservationExpiredTTLTx(ctx context.Context, tx *gorm.DB, r *models.Reservation) error {
	return a.recordReservationTx(ctx, tx, r, VerbReservationExpiredTTL, "expired by TTL reaper", "", reaperActor())
}

func (a *Auditing) recordReservationTx(
	ctx context.Context,
	tx *gorm.DB,
	r *models.Reservation,
	verb, defaultReason, callerReason string,
	actor auditActor,
) error {
	if a == nil || a.writer == nil || r == nil {
		return nil
	}
	reason := callerReason
	if reason == "" {
		reason = defaultReason
	}
	return a.writer.RecordTx(ctx, tx, audit.Record{
		EntityType: "reservation",
		EntityID:   r.ID,
		Action:     verb,
		ActorID:    actor.id,
		ActorType:  actor.kind,
		Reason:     reason,
		Metadata:   reservationMetadata(r),
		Parent:     &r.BaseModel,
	})
}

// RecordApprovalRequiredTx writes the approval-required audit row inside tx,
// atomically with the approval request row creation.
func (a *Auditing) RecordApprovalRequiredTx(ctx context.Context, tx *gorm.DB, ar *models.ApprovalRequest) error {
	return a.recordApprovalTx(ctx, tx, ar, VerbApprovalRequired, "approval required", "", userActor(ctx, ""))
}

// RecordApprovalApprovedTx writes the approved audit row inside tx.
func (a *Auditing) RecordApprovalApprovedTx(
	ctx context.Context,
	tx *gorm.DB,
	ar *models.ApprovalRequest,
	approverID string,
) error {
	return a.recordApprovalTx(ctx, tx, ar, VerbApprovalApproved, "approved", approverID, userActor(ctx, approverID))
}

// RecordApprovalRejectedTx writes the rejected audit row inside tx.
func (a *Auditing) RecordApprovalRejectedTx(
	ctx context.Context,
	tx *gorm.DB,
	ar *models.ApprovalRequest,
	approverID, note string,
) error {
	return a.recordApprovalTx(
		ctx, tx, ar, VerbApprovalRejected, "rejected: "+note, approverID, userActor(ctx, approverID),
	)
}

// RecordApprovalAutoRejectedTx writes the auto-rejected audit row inside tx.
func (a *Auditing) RecordApprovalAutoRejectedTx(
	ctx context.Context,
	tx *gorm.DB,
	ar *models.ApprovalRequest,
	reason string,
) error {
	return a.recordApprovalTx(
		ctx, tx, ar, VerbApprovalAutoRejected, "auto-rejected on recheck: "+reason, "", userActor(ctx, ""),
	)
}

// RecordApprovalRejectedCascadeTx writes a cascade-rejected approval audit row
// inside tx. Used when Release cancels pending approval requests as a side effect.
func (a *Auditing) RecordApprovalRejectedCascadeTx(
	ctx context.Context,
	tx *gorm.DB,
	ar *models.ApprovalRequest,
	reason string,
) error {
	return a.recordApprovalTx(
		ctx, tx, ar, VerbApprovalRejectedCascade, "cascade-rejected: "+reason, "", userActor(ctx, ""),
	)
}

// RecordApprovalExpiredTx writes the approval-expired audit row inside tx,
// attributed to the reaper and scoped to the approval's tenant so the row is
// visible to that tenant's LimitsAuditSearch under RLS.
func (a *Auditing) RecordApprovalExpiredTx(ctx context.Context, tx *gorm.DB, ar *models.ApprovalRequest) error {
	return a.recordApprovalTx(ctx, tx, ar, VerbApprovalExpired, reasonExpiredPendingDecision, "", reaperActor())
}

func (a *Auditing) recordApprovalTx(
	ctx context.Context,
	tx *gorm.DB,
	ar *models.ApprovalRequest,
	verb, reason, approverID string,
	actor auditActor,
) error {
	if a == nil || a.writer == nil || ar == nil {
		return nil
	}
	md := approvalMetadata(ar)
	if approverID != "" {
		md["approver_id"] = approverID
	}
	return a.writer.RecordTx(ctx, tx, audit.Record{
		EntityType: "approval_request",
		EntityID:   ar.ID,
		Action:     verb,
		ActorID:    actor.id,
		ActorType:  actor.kind,
		Reason:     reason,
		Metadata:   md,
		Parent:     &ar.BaseModel,
	})
}

// RecordPolicySavedTx writes the policy-saved audit row inside tx.
func (a *Auditing) RecordPolicySavedTx(ctx context.Context, tx *gorm.DB, pol *models.Policy) error {
	if a == nil || a.writer == nil || pol == nil {
		return nil
	}
	return a.writer.RecordTx(ctx, tx, audit.Record{
		EntityType: auditEntityPolicy,
		EntityID:   pol.ID,
		Action:     VerbPolicySaved,
		ActorID:    actorFromContext(ctx),
		ActorType:  auditActorUser,
		Reason:     "policy saved",
		Metadata: data.JSONMap{
			mdKeyActionKind: string(pol.Action),
			"subject_type":  string(pol.SubjectType),
			mdKeyMode:       string(pol.Mode),
			"limit_kind":    string(pol.LimitKind),
		},
	})
}

// RecordPolicyDeletedTx writes the policy-deleted audit row inside tx.
func (a *Auditing) RecordPolicyDeletedTx(ctx context.Context, tx *gorm.DB, pol *models.Policy) error {
	if a == nil || a.writer == nil || pol == nil {
		return nil
	}
	return a.writer.RecordTx(ctx, tx, audit.Record{
		EntityType: auditEntityPolicy,
		EntityID:   pol.ID,
		Action:     VerbPolicyDeleted,
		ActorID:    actorFromContext(ctx),
		ActorType:  auditActorUser,
		Reason:     "policy deleted",
		Metadata: data.JSONMap{
			mdKeyActionKind: string(pol.Action),
			"subject_type":  string(pol.SubjectType),
			mdKeyMode:       string(pol.Mode),
			"limit_kind":    string(pol.LimitKind),
		},
	})
}

// ─── Metadata builders ──────────────────────────────────────────────

func intentMetadata(intent *limitsv1.LimitIntent, verdicts []*limitsv1.PolicyVerdict) data.JSONMap {
	if intent == nil {
		return data.JSONMap{}
	}
	currency := intent.GetAmount().GetCurrencyCode()
	amountMinor, _ := moneyx.ToMinorUnitsByCurrency(intent.GetAmount(), currency)
	md := data.JSONMap{
		mdKeyActionKind:  intent.GetAction().String(),
		mdKeyAmountMinor: amountMinor,
		mdKeyCurrency:    currency,
		"subjects":       subjectsAsMaps(intent.GetSubjects()),
		"org_unit_id":    intent.GetOrgUnitId(),
	}
	if len(verdicts) > 0 {
		md["verdicts"] = verdictsAsMaps(verdicts)
	}
	return md
}

func reservationMetadata(r *models.Reservation) data.JSONMap {
	return data.JSONMap{
		mdKeyActionKind:      string(r.Action),
		mdKeyAmountMinor:     r.Amount,
		mdKeyCurrency:        r.CurrencyCode,
		"org_unit_id":        r.OrgUnitID,
		"reservation_status": string(r.Status),
	}
}

func approvalMetadata(ar *models.ApprovalRequest) data.JSONMap {
	return data.JSONMap{
		"reservation_id":       ar.ReservationID,
		mdKeyActionKind:        string(ar.Action),
		mdKeyAmountMinor:       ar.Amount,
		mdKeyCurrency:          ar.CurrencyCode,
		"triggering_policy_id": ar.TriggeringPolicyID,
		"policy_version":       ar.PolicyVersion,
		"required_role":        ar.RequiredRole,
		"required_count":       ar.RequiredCount,
	}
}

func subjectsAsMaps(refs []*limitsv1.SubjectRef) []map[string]string {
	out := make([]map[string]string, len(refs))
	for i, r := range refs {
		out[i] = map[string]string{"type": subjectTypeJSONStr(r.GetType()), "id": r.GetId()}
	}
	return out
}

// subjectTypeJSONStr is a local mirror of the (package-private)
// helper in models — we duplicate the few cases here to avoid a
// cross-package dependency on an internal models helper.
func subjectTypeJSONStr(t limitsv1.SubjectType) string {
	switch t {
	case limitsv1.SubjectType_SUBJECT_TYPE_CLIENT:
		return "client"
	case limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT:
		return "account"
	case limitsv1.SubjectType_SUBJECT_TYPE_PRODUCT:
		return "product"
	case limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION:
		return "organization"
	case limitsv1.SubjectType_SUBJECT_TYPE_ORG_UNIT:
		return "org_unit"
	case limitsv1.SubjectType_SUBJECT_TYPE_WORKFORCE_MEMBER:
		return "workforce_member"
	case limitsv1.SubjectType_SUBJECT_TYPE_UNSPECIFIED:
		return ""
	default:
		return ""
	}
}

func verdictsAsMaps(vs []*limitsv1.PolicyVerdict) []map[string]any {
	out := make([]map[string]any, len(vs))
	for i, v := range vs {
		m := map[string]any{
			"policy_id":              v.GetPolicyId(),
			"policy_version":         v.GetPolicyVersion(),
			"matched":                v.GetMatched(),
			"breached":               v.GetBreached(),
			"would_require_approval": v.GetWouldRequireApproval(),
			mdKeyMode:                v.GetMode().String(),
			"reason":                 v.GetReason(),
		}
		if v.GetCurrentUsage() != nil {
			cu, _ := moneyx.ToMinorUnitsByCurrency(v.GetCurrentUsage(), v.GetCurrentUsage().GetCurrencyCode())
			m["current_usage_minor"] = cu
		}
		if v.GetCapAmount() != nil {
			ca, _ := moneyx.ToMinorUnitsByCurrency(v.GetCapAmount(), v.GetCapAmount().GetCurrencyCode())
			m["cap_minor"] = ca
		}
		if v.GetCapCount() > 0 {
			m["cap_count"] = v.GetCapCount()
			m["current_count"] = v.GetCurrentCount()
		}
		out[i] = m
	}
	return out
}

func logFailure(ctx context.Context) func(error) {
	return func(err error) {
		util.Log(ctx).WithError(err).Error("audit emit failed (limits gate)")
	}
}

// FormatBreachReason builds a one-line reason string for a hard breach,
// suitable for the Reason field of an audit.Record.
func FormatBreachReason(v *limitsv1.PolicyVerdict, intentMinor int64) string {
	if v.GetCapCount() > 0 {
		return "policy=" + v.GetPolicyId() + " count=" + strconv.FormatInt(v.GetCurrentCount()+1, 10) +
			">cap=" + strconv.FormatInt(v.GetCapCount(), 10)
	}
	capMinor := int64(0)
	if c := v.GetCapAmount(); c != nil {
		capMinor, _ = moneyx.ToMinorUnitsByCurrency(c, c.GetCurrencyCode())
	}
	curr := int64(0)
	if u := v.GetCurrentUsage(); u != nil {
		curr, _ = moneyx.ToMinorUnitsByCurrency(u, u.GetCurrencyCode())
	}
	return "policy=" + v.GetPolicyId() + " usage+amount=" +
		strconv.FormatInt(curr+intentMinor, 10) + ">cap=" + strconv.FormatInt(capMinor, 10)
}
