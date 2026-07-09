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
	"fmt"
	"time"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"github.com/pitabwire/frame/v2/datastore/pool"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/types/known/timestamppb"

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
	ListVersions(ctx context.Context, policyID string) ([]*limitsv1.PolicyObject, error)
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

//nolint:gocognit // save + snapshot + audit is one atomic flow; splitting obscures tx boundaries
func (b *policyBusiness) Save(ctx context.Context, in *limitsv1.PolicyObject) (*limitsv1.PolicyObject, error) {
	log := util.Log(ctx).WithField("method", "PolicyBusiness.Save")

	pol, err := models.PolicyFromAPI(in)
	if err != nil {
		log.WithError(err).Warn("invalid policy input")
		return nil, fmt.Errorf("%w: %s", ErrInvalidPolicy, err.Error())
	}

	if vErr := validatePolicy(pol); vErr != nil {
		return nil, vErr
	}

	// Snapshot version counter is managed separately from data.BaseModel.Version
	// (which is Frame's optimistic-lock counter). We derive the next snapshot
	// version by inspecting existing version rows.
	var snapshotVersion int32

	isUpdate := pol.ID != ""
	if isUpdate {
		prior, getErr := b.repo.Get(ctx, pol.ID)
		if getErr != nil {
			return nil, fmt.Errorf("%w: %s", ErrPolicyNotFound, getErr.Error())
		}
		// Preserve immutable fields so Frame's BeforeUpdate does not lose them.
		pol.CreatedAt = prior.CreatedAt
		pol.CreatedBy = prior.CreatedBy
		// Carry the Frame optimistic-lock version so BeforeUpdate increments it correctly.
		pol.Version = prior.Version

		existing, listErr := b.verRepo.List(ctx, pol.ID)
		if listErr != nil {
			log.WithError(listErr).Warn("could not count existing versions; defaulting to 1")
			snapshotVersion = 1
		} else {
			snapshotVersion = int32(len(existing)) + 1 //nolint:gosec // snapshot counts never approach int32 range
		}
	} else {
		snapshotVersion = 1
	}

	// Wrap save + audit in a single transaction so the audit row lands
	// atomically with the policy mutation. When dbPool is nil (test mode
	// without an audit writer injected) fall back to the non-tx save path.
	var apiOut *limitsv1.PolicyObject
	var snapshot []byte

	//nolint:nestif // tx-vs-non-tx fallback paths are clearer inline
	if b.dbPool != nil && b.auditing != nil {
		tx := b.dbPool.DB(ctx, false).Begin()
		if tx.Error != nil {
			return nil, tx.Error
		}
		txCommitted := false
		defer func() {
			if !txCommitted {
				_ = tx.Rollback()
			}
		}()

		if saveErr := b.repo.SaveTx(ctx, tx, pol); saveErr != nil {
			return nil, saveErr
		}
		if auditErr := b.auditing.RecordPolicySavedTx(ctx, tx, pol); auditErr != nil {
			return nil, auditErr
		}
		if commitErr := tx.Commit().Error; commitErr != nil {
			return nil, commitErr
		}
		txCommitted = true
	} else {
		if saveErr := b.repo.Save(ctx, pol); saveErr != nil {
			return nil, saveErr
		}
	}

	// Append the version snapshot using protojson for canonical proto JSON.
	// Expose snapshotVersion via the proto Version field for the response only.
	apiOut = pol.ToAPI()
	apiOut.Version = snapshotVersion

	var marshalErr error
	snapshot, marshalErr = protojson.Marshal(apiOut)
	if marshalErr != nil {
		log.WithError(marshalErr).Error("failed to marshal policy snapshot")
	}
	if snapshot != nil {
		if appendErr := b.verRepo.Append(ctx, &models.PolicyVersion{
			PolicyID: pol.ID,
			Version:  snapshotVersion,
			Snapshot: snapshot,
		}); appendErr != nil {
			// Audit-only: log and continue. The policy is saved; missing version
			// rows are recoverable via reconciliation.
			log.WithError(appendErr).Error("failed to append policy version snapshot")
		}
	}

	if b.policyCache != nil {
		b.policyCache.InvalidateTenant(pol.TenantID)
	}

	emitEvent(ctx, b.eventsMan, events.EventPolicyInvalidate, events.PolicyInvalidatePayload{
		PolicyID:    pol.ID,
		TenantID:    pol.TenantID,
		Action:      string(pol.Action),
		SubjectType: string(pol.SubjectType),
	})

	return apiOut, nil
}

func (b *policyBusiness) Get(ctx context.Context, id string) (*limitsv1.PolicyObject, error) {
	pol, err := b.repo.Get(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("%w: %s", ErrPolicyNotFound, err.Error())
	}
	return pol.ToAPI(), nil
}

func (b *policyBusiness) Search(ctx context.Context, req *limitsv1.PolicySearchRequest,
	batch func(ctx context.Context, items []*limitsv1.PolicyObject) error) error {
	const pageSize = 50
	cursor := ""
	if req.GetCursor() != nil {
		cursor = req.GetCursor().GetPage()
	}
	for {
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
		out, err := b.repo.Search(ctx, filter, pageSize, cursor)
		if err != nil {
			return err
		}
		api := make([]*limitsv1.PolicyObject, len(out.Items))
		for i, p := range out.Items {
			api[i] = p.ToAPI()
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

	if b.policyCache != nil {
		b.policyCache.InvalidateTenant(pol.TenantID)
	}

	emitEvent(ctx, b.eventsMan, events.EventPolicyInvalidate, events.PolicyInvalidatePayload{
		PolicyID:    pol.ID,
		TenantID:    pol.TenantID,
		Action:      string(pol.Action),
		SubjectType: string(pol.SubjectType),
	})
	return nil
}

func (b *policyBusiness) ListVersions(ctx context.Context, policyID string) ([]*limitsv1.PolicyObject, error) {
	rows, err := b.verRepo.List(ctx, policyID)
	if err != nil {
		return nil, err
	}
	out := make([]*limitsv1.PolicyObject, 0, len(rows))
	for _, r := range rows {
		var snap limitsv1.PolicyObject
		if uErr := protojson.Unmarshal(r.Snapshot, &snap); uErr != nil {
			continue
		}
		snap.ModifiedAt = timestamppb.New(r.CreatedAt)
		out = append(out, &snap)
	}
	return out, nil
}

func validatePolicy(p *models.Policy) error {
	if p.LimitKind == models.KindRollingWindowAmount || p.LimitKind == models.KindRollingWindowCount {
		if p.WindowSeconds <= 0 {
			return fmt.Errorf("%w: rolling kind requires window > 0", ErrInvalidPolicy)
		}
	}
	if p.LimitKind != models.KindRollingWindowCount && p.CurrencyCode == "" {
		return fmt.Errorf("%w: currency_code required for amount kinds", ErrInvalidPolicy)
	}
	if p.EffectiveFrom.IsZero() {
		p.EffectiveFrom = time.Now().UTC()
	}
	if p.EffectiveTo != nil && !p.EffectiveTo.After(p.EffectiveFrom) {
		return fmt.Errorf("%w: effective_to must be after effective_from", ErrInvalidPolicy)
	}
	return nil
}
