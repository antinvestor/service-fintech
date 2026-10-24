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

// Package business holds the limits service domain logic. PolicyBusiness
// coordinates the policy repository, the version-snapshot repository, and
// the audit middleware for every Save/Delete.
package business

import (
	"context"
	"encoding/json"
	"fmt"
	"sort"
	"strconv"
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"github.com/pitabwire/frame/v2/datastore/pool"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/types/known/timestamppb"
	"gorm.io/datatypes"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/events"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// PolicyBusiness is the service-layer entry point for policy management.
type PolicyBusiness interface {
	Save(ctx context.Context, in *limitsv1.PolicyObject) (*limitsv1.PolicyObject, error)
	Get(ctx context.Context, id string) (*limitsv1.PolicyObject, error)
	Search(
		ctx context.Context,
		req *limitsv1.PolicySearchRequest,
		batch func(ctx context.Context, items []*limitsv1.PolicyObject) error,
	) error
	Delete(ctx context.Context, id string) error
	// History returns one page of a policy's immutable version snapshots,
	// newest first. cursor is the version number the caller last saw ("" for
	// the first page); NextCursor is empty when the page is the last one.
	History(ctx context.Context, policyID string, cursor *commonv1.PageCursor) (*PolicyHistoryPage, error)
}

// PolicyVersionEntry is one row of a policy's version history. It is the
// domain shape of the wire PolicyVersionObject; the handler maps it 1:1 once
// the PolicyHistory RPC is published.
type PolicyVersionEntry struct {
	PolicyID  string
	Version   int32
	Snapshot  *limitsv1.PolicyObject
	CreatedAt time.Time
}

// PolicyHistoryPage is one page of PolicyVersionEntry rows plus the cursor
// for the next page.
type PolicyHistoryPage struct {
	Items      []*PolicyVersionEntry
	NextCursor string
}

type policyBusiness struct {
	repo        repository.PolicyRepository
	verRepo     repository.PolicyVersionRepository
	eventsMan   fevents.Manager
	auditing    *Auditing
	dbPool      pool.Pool
	policyCache *PolicyCache
}

// NewPolicyBusiness wires up dependencies. Caller is responsible for
// passing the audit-middleware-wrapped context. eventsMan may be nil,
// in which case event emission is a no-op. auditing and dbPool may be nil,
// in which case audit emission is skipped. policyCache may be nil, in which
// case cache invalidation on Save/Delete is a no-op.
func NewPolicyBusiness(
	repo repository.PolicyRepository,
	verRepo repository.PolicyVersionRepository,
	eventsMan fevents.Manager,
	auditing *Auditing,
	dbPool pool.Pool,
	policyCache *PolicyCache,
) PolicyBusiness {
	return &policyBusiness{
		repo: repo, verRepo: verRepo, eventsMan: eventsMan,
		auditing: auditing, dbPool: dbPool, policyCache: policyCache,
	}
}

// Save creates or updates a policy. Updates carry the caller's view of the
// policy version and are rejected when another operator has changed the row in
// the meantime, so concurrent edits can never silently clobber one another.
//
//nolint:gocognit,nestif // save + snapshot + audit is one atomic flow; splitting obscures tx boundaries
func (b *policyBusiness) Save(ctx context.Context, in *limitsv1.PolicyObject) (*limitsv1.PolicyObject, error) {
	log := util.Log(ctx).WithField("method", "PolicyBusiness.Save")

	pol, err := models.PolicyFromAPI(in)
	if err != nil {
		log.WithError(err).Warn("invalid policy input")
		return nil, fmt.Errorf("%w: %s", ErrInvalidPolicy, err.Error())
	}

	if vErr := validatePolicy(ctx, pol); vErr != nil {
		return nil, vErr
	}

	clientVersion := uint(0)
	if in.GetVersion() > 0 {
		clientVersion = uint(in.GetVersion()) //nolint:gosec // guarded positive above
	}

	// Non-transactional fallback for wiring that injects no pool.
	if b.dbPool == nil || b.auditing == nil {
		snapshotVersion := int32(1)
		if pol.ID != "" {
			prior, getErr := b.repo.Get(ctx, pol.ID)
			if getErr != nil {
				return nil, fmt.Errorf("%w: %s", ErrPolicyNotFound, getErr.Error())
			}
			if clientVersion != 0 && clientVersion != prior.Version {
				return nil, fmt.Errorf("%w: policy was modified by another operator", ErrPolicyVersionConflict)
			}
			pol.CreatedAt = prior.CreatedAt
			pol.CreatedBy = prior.CreatedBy
			pol.Version = prior.Version
			existing, listErr := b.verRepo.List(ctx, pol.ID)
			if listErr != nil {
				return nil, listErr
			}
			snapshotVersion = int32(len(existing)) + 1 //nolint:gosec // snapshot counts never approach int32 range
		}
		if saveErr := b.repo.Save(ctx, pol); saveErr != nil {
			return nil, saveErr
		}
		if appendErr := b.appendSnapshot(ctx, nil, pol, snapshotVersion); appendErr != nil {
			return nil, appendErr
		}
		b.invalidate(ctx, pol)
		return pol.ToAPI(), nil
	}

	txErr := b.dbPool.DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		snapshotVersion := int32(1)
		if pol.ID != "" {
			prior, getErr := b.repo.GetForUpdateTx(ctx, tx, pol.ID)
			if getErr != nil {
				return fmt.Errorf("%w: %s", ErrPolicyNotFound, getErr.Error())
			}
			if clientVersion != 0 && clientVersion != prior.Version {
				return fmt.Errorf("%w: policy was modified by another operator", ErrPolicyVersionConflict)
			}
			// Preserve immutable fields so Frame's BeforeUpdate does not lose them.
			pol.CreatedAt = prior.CreatedAt
			pol.CreatedBy = prior.CreatedBy
			pol.TenantID = prior.TenantID
			pol.PartitionID = prior.PartitionID
			// Carry the stored lock version so BeforeUpdate increments it correctly.
			pol.Version = prior.Version

			existing, listErr := b.verRepo.ListTx(ctx, tx, pol.ID)
			if listErr != nil {
				return listErr
			}
			snapshotVersion = int32(len(existing)) + 1 //nolint:gosec // snapshot counts never approach int32 range
		}

		if saveErr := b.repo.SaveTx(ctx, tx, pol); saveErr != nil {
			return saveErr
		}
		if auditErr := b.auditing.RecordPolicySavedTx(ctx, tx, pol); auditErr != nil {
			return auditErr
		}

		// The version snapshot is part of the same commit: a policy change
		// without its history row is an audit gap, not an acceptable partial.
		return b.appendSnapshot(ctx, tx, pol, snapshotVersion)
	})
	if txErr != nil {
		return nil, txErr
	}

	b.invalidate(ctx, pol)
	return pol.ToAPI(), nil
}

// appendSnapshot writes the immutable history row for a saved policy. tx may
// be nil, in which case the write goes through the pool.
func (b *policyBusiness) appendSnapshot(
	ctx context.Context,
	tx *gorm.DB,
	pol *models.Policy,
	version int32,
) error {
	snapshot, marshalErr := protojson.Marshal(pol.ToAPI())
	if marshalErr != nil {
		return marshalErr
	}
	row := &models.PolicyVersion{
		PolicyID: pol.ID,
		Version:  version,
		Snapshot: snapshot,
	}
	if tx == nil {
		return b.verRepo.Append(ctx, row)
	}
	return b.verRepo.AppendTx(ctx, tx, row)
}

// invalidate purges the candidate cache and announces the change so peer
// replicas can drop their own copies.
func (b *policyBusiness) invalidate(ctx context.Context, pol *models.Policy) {
	if b.policyCache != nil {
		b.policyCache.InvalidateTenant(pol.TenantID)
	}
	emitEvent(ctx, b.eventsMan, events.EventPolicyInvalidate, events.PolicyInvalidatePayload{
		PolicyID:    pol.ID,
		TenantID:    pol.TenantID,
		Action:      string(pol.Action),
		SubjectType: string(pol.SubjectType),
	})
}

func (b *policyBusiness) Get(ctx context.Context, id string) (*limitsv1.PolicyObject, error) {
	pol, err := b.repo.Get(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("%w: %s", ErrPolicyNotFound, err.Error())
	}
	return pol.ToAPI(), nil
}

// Search returns a single page of matching policies. The caller controls the
// page size via cursor.limit and pages by re-issuing the request with the last
// id it saw; the server never drains the whole table into one stream.
func (b *policyBusiness) Search(ctx context.Context, req *limitsv1.PolicySearchRequest,
	batch func(ctx context.Context, items []*limitsv1.PolicyObject) error) error {
	if err := assertRequestTenant(ctx, req.GetTenantId()); err != nil {
		return err
	}
	filter := repository.PolicySearchFilter{
		Query:     req.GetQuery(),
		OrgUnitID: req.GetOrgUnitId(),
	}
	if a, err := models.ActionFromAPISafe(req.GetAction()); err == nil {
		filter.Action = a
	}
	if s, err := models.SubjectFromAPISafe(req.GetSubjectType()); err == nil {
		filter.SubjectType = s
	}
	if m, err := models.ModeFromAPISafe(req.GetMode()); err == nil {
		filter.Mode = m
	}
	out, err := b.repo.Search(ctx, filter, pageSizeFor(req.GetCursor()), req.GetCursor().GetPage())
	if err != nil {
		return err
	}
	api := make([]*limitsv1.PolicyObject, len(out.Items))
	for i, p := range out.Items {
		api[i] = p.ToAPI()
	}
	return batch(ctx, api)
}

func (b *policyBusiness) Delete(ctx context.Context, id string) error {
	pol, err := b.repo.Get(ctx, id)
	if err != nil {
		return fmt.Errorf("%w: %s", ErrPolicyNotFound, err.Error())
	}

	//nolint:nestif // tx-vs-non-tx fallback paths are clearer inline
	if b.dbPool != nil && b.auditing != nil {
		tx := b.dbPool.DB(ctx, false).Begin()
		if tx.Error != nil {
			return tx.Error
		}
		txCommitted := false
		defer func() {
			if !txCommitted {
				_ = tx.Rollback()
			}
		}()
		if dErr := b.repo.DeleteTx(ctx, tx, id); dErr != nil {
			return dErr
		}
		if auditErr := b.auditing.RecordPolicyDeletedTx(ctx, tx, pol); auditErr != nil {
			return auditErr
		}
		if commitErr := tx.Commit().Error; commitErr != nil {
			return commitErr
		}
		txCommitted = true
	} else {
		if delErr := b.repo.Delete(ctx, id); delErr != nil {
			return delErr
		}
	}

	b.invalidate(ctx, pol)
	return nil
}

func (b *policyBusiness) History(
	ctx context.Context,
	policyID string,
	cursor *commonv1.PageCursor,
) (*PolicyHistoryPage, error) {
	if strings.TrimSpace(policyID) == "" {
		return nil, fmt.Errorf("%w: policy id required", ErrInvalidPolicy)
	}
	if _, err := b.repo.Get(ctx, policyID); err != nil {
		return nil, fmt.Errorf("%w: %s", ErrPolicyNotFound, err.Error())
	}
	var before int32
	if page := cursor.GetPage(); page != "" {
		v, convErr := strconv.ParseInt(page, 10, 32)
		if convErr != nil || v <= 0 {
			return nil, fmt.Errorf("%w: cursor.page must be a version number", ErrInvalidPolicy)
		}
		before = int32(v)
	}
	limit := pageSizeFor(cursor)
	// Fetch one extra row to learn whether a further page exists without a
	// second count query.
	rows, err := b.verRepo.ListPage(ctx, policyID, limit+1, before)
	if err != nil {
		return nil, err
	}
	out := &PolicyHistoryPage{Items: make([]*PolicyVersionEntry, 0, len(rows))}
	hasMore := len(rows) > limit
	if hasMore {
		rows = rows[:limit]
	}
	for _, r := range rows {
		var snap limitsv1.PolicyObject
		if uErr := protojson.Unmarshal(r.Snapshot, &snap); uErr != nil {
			util.Log(ctx).WithError(uErr).
				With("policy_id", policyID).With("version", r.Version).
				Warn("limits: policy version snapshot is unreadable")
			continue
		}
		snap.Version = r.Version
		snap.ModifiedAt = timestamppb.New(r.CreatedAt)
		out.Items = append(out.Items, &PolicyVersionEntry{
			PolicyID:  r.PolicyID,
			Version:   r.Version,
			Snapshot:  &snap,
			CreatedAt: r.CreatedAt,
		})
	}
	if hasMore && len(rows) > 0 {
		out.NextCursor = strconv.Itoa(int(rows[len(rows)-1].Version))
	}
	return out, nil
}

// maxApproverCount mirrors the approver_tiers check constraint on the table.
const maxApproverCount = 11

func validatePolicy(ctx context.Context, p *models.Policy) error {
	if p.Scope == models.ScopePlatform {
		// A platform policy binds every tenant, so only an internal-system
		// principal may create one — a tenant admin holds policy_manage on
		// their own tenancy path, not on the platform.
		claims := security.ClaimsFromContext(ctx)
		if claims == nil || !claims.IsInternalSystem() {
			return fmt.Errorf("%w: platform scope is reserved for platform operators", ErrPolicyScopeForbidden)
		}
	}
	if err := validatePolicyScope(p); err != nil {
		return err
	}
	if p.LimitKind == models.KindRollingWindowAmount || p.LimitKind == models.KindRollingWindowCount {
		if p.WindowSeconds <= 0 {
			return fmt.Errorf("%w: rolling kind requires window > 0", ErrInvalidPolicy)
		}
	}
	if p.LimitKind != models.KindRollingWindowCount && p.CurrencyCode == "" {
		return fmt.Errorf("%w: currency_code required for amount kinds", ErrInvalidPolicy)
	}
	if p.LimitKind != models.KindPerTxnMin && p.Value <= 0 {
		// A zero cap on any "maximum" kind breaches every positive amount, so
		// an operator who forgets the cap field would block the whole action.
		return fmt.Errorf("%w: cap must be greater than zero", ErrInvalidPolicy)
	}
	// approval_ttl is clamped, not rejected: the stored value is what both the
	// approval request and its reservation will expire on (models.MinApprovalTTL).
	p.NormaliseApprovalTTL()
	if p.EffectiveFrom.IsZero() {
		p.EffectiveFrom = time.Now().UTC()
	}
	if p.EffectiveTo != nil && !p.EffectiveTo.After(p.EffectiveFrom) {
		return fmt.Errorf("%w: effective_to must be after effective_from", ErrInvalidPolicy)
	}
	return normaliseApproverTiers(p)
}

// validatePolicyScope keeps the branch tier unambiguous. A branch policy
// without a branch would match every intent that carries no branch, and an
// org or platform policy with one would never match anything.
func validatePolicyScope(p *models.Policy) error {
	p.OrgUnitID = strings.TrimSpace(p.OrgUnitID)
	switch p.Scope {
	case models.ScopeOrgUnit:
		if p.OrgUnitID == "" {
			return fmt.Errorf("%w: org_unit scope requires org_unit_id", ErrInvalidPolicy)
		}
	case models.ScopeOrg, models.ScopePlatform:
		if p.OrgUnitID != "" {
			return fmt.Errorf("%w: org_unit_id is only valid on org_unit scope", ErrInvalidPolicy)
		}
	default:
		return fmt.Errorf("%w: unknown scope %q", ErrInvalidPolicy, p.Scope)
	}
	return nil
}

// normaliseApproverTiers validates the approver ladder and rewrites it in
// ascending order with the catch-all (up_to = 0) last. pickTier walks the list
// in order and returns the first covering tier, so an unsorted ladder would let
// a large amount be approved at the lowest tier — or force every amount,
// however small, through the highest.
//
//nolint:gocognit // one linear pass of ladder rules; splitting hides the contract
func normaliseApproverTiers(p *models.Policy) error {
	tiers, err := unmarshalPolicyApproverTiers(p)
	if err != nil {
		return fmt.Errorf("%w: %s", ErrApproverTiersInvalid, err.Error())
	}
	if len(tiers) == 0 {
		return nil
	}
	seen := map[int64]bool{}
	catchAll := 0
	for _, t := range tiers {
		if t.Role == "" {
			return fmt.Errorf("%w: every tier needs a role", ErrApproverTiersInvalid)
		}
		if t.Approvers < 1 || t.Approvers > maxApproverCount {
			return fmt.Errorf("%w: approvers must be between 1 and %d", ErrApproverTiersInvalid, maxApproverCount)
		}
		if t.UpTo < 0 {
			return fmt.Errorf("%w: up_to cannot be negative", ErrApproverTiersInvalid)
		}
		if t.UpTo == 0 {
			catchAll++
			if catchAll > 1 {
				return fmt.Errorf("%w: only one catch-all tier is allowed", ErrApproverTiersInvalid)
			}
			continue
		}
		if seen[t.UpTo] {
			return fmt.Errorf("%w: duplicate up_to bound", ErrApproverTiersInvalid)
		}
		seen[t.UpTo] = true
	}
	sort.SliceStable(tiers, func(i, j int) bool {
		if tiers[i].UpTo == 0 {
			return false
		}
		if tiers[j].UpTo == 0 {
			return true
		}
		return tiers[i].UpTo < tiers[j].UpTo
	})
	type wire struct {
		UpTo      int64  `json:"up_to"`
		Role      string `json:"role"`
		Approvers int32  `json:"approvers"`
	}
	out := make([]wire, len(tiers))
	for i, t := range tiers {
		out[i] = wire(t)
	}
	encoded, marshalErr := json.Marshal(out)
	if marshalErr != nil {
		return fmt.Errorf("%w: %s", ErrApproverTiersInvalid, marshalErr.Error())
	}
	p.ApproverTiers = datatypes.JSON(encoded)
	return nil
}
