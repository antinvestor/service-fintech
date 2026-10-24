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
// audit_search.go streams limits-audit events to risk/compliance callers.
package business

import (
	"context"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/security"
	"google.golang.org/protobuf/types/known/structpb"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/antinvestor/service-fintech/pkg/audit"
)

// AuditSearchBusiness streams limits-audit events to risk/compliance callers.
// Default filter: only rows with action prefix "limits." are returned.
// Callers can also restrict to specific exact action verbs.
type AuditSearchBusiness interface {
	Search(
		ctx context.Context,
		req *limitsv1.LimitsAuditSearchRequest,
		batch func(ctx context.Context, items []*limitsv1.LimitsAuditEventObject) error,
	) error
}

type auditSearchBusiness struct {
	dbPool pool.Pool
}

// NewAuditSearchBusiness wires a pool.Pool into the audit search business.
func NewAuditSearchBusiness(p pool.Pool) AuditSearchBusiness {
	return &auditSearchBusiness{dbPool: p}
}

// Search returns a single page of limits audit events, newest first. An audit
// feed is read from the present backwards, so ordering by id descending makes
// the first page the useful one; the caller pages by passing the last id it saw
// as cursor.page.
func (b *auditSearchBusiness) Search(
	ctx context.Context,
	req *limitsv1.LimitsAuditSearchRequest,
	batch func(ctx context.Context, items []*limitsv1.LimitsAuditEventObject) error,
) error {
	pageSize := pageSizeFor(req.GetCursor())
	var rows []*audit.Event
	db := b.dbPool.DB(ctx, true).
		Table(audit.Event{}.TableName()).
		Where("deleted_at IS NULL")

	// LimitsAuditSearchRequest carries no tenant filter, so the predicate is
	// derived from the caller's claims. Without it the feed is cross-tenant.
	tenantPredicate, err := auditTenantPredicate(ctx)
	if err != nil {
		return err
	}
	if tenantPredicate != "" {
		db = db.Where("tenant_id = ?", tenantPredicate)
	}
	if len(req.GetActions()) == 0 {
		db = db.Where("action LIKE 'limits.%'")
	} else {
		db = db.Where("action IN ?", req.GetActions())
	}
	if req.GetEntityType() != "" {
		db = db.Where("entity_type = ?", req.GetEntityType())
	}
	if req.GetEntityId() != "" {
		db = db.Where("entity_id = ?", req.GetEntityId())
	}
	if req.GetActorId() != "" {
		db = db.Where("actor_id = ?", req.GetActorId())
	}
	if t := req.GetFrom(); t != nil {
		db = db.Where("occurred_at >= ?", t.AsTime())
	}
	if t := req.GetTo(); t != nil {
		db = db.Where("occurred_at < ?", t.AsTime())
	}
	if cursor := req.GetCursor().GetPage(); cursor != "" {
		db = db.Where("id < ?", cursor)
	}
	if err = db.Order("id DESC").Limit(pageSize).Find(&rows).Error; err != nil {
		return err
	}
	api := make([]*limitsv1.LimitsAuditEventObject, len(rows))
	for i, ev := range rows {
		api[i] = auditEventToAPI(ev)
	}
	return batch(ctx, api)
}

// auditTenantPredicate returns the tenant every returned audit row must belong
// to. It fails closed: a caller whose claims name no tenant is refused rather
// than shown every tenant's audit trail. An internal-system principal is the
// documented cross-tenant exception and gets an unfiltered feed; see
// docs/runbook/limits-rollout.md.
func auditTenantPredicate(ctx context.Context) (string, error) {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return "", connect.NewError(connect.CodeUnauthenticated, "missing caller identity")
	}
	if claims.IsInternalSystem() {
		return "", nil
	}
	tenant := claims.GetTenantID()
	if tenant == "" {
		return "", connect.NewError(connect.CodeUnauthenticated, "caller claims carry no tenant")
	}
	return tenant, nil
}

func auditEventToAPI(ev *audit.Event) *limitsv1.LimitsAuditEventObject {
	out := &limitsv1.LimitsAuditEventObject{
		Id:         ev.ID,
		EntityType: ev.EntityType,
		EntityId:   ev.EntityID,
		Action:     ev.Action,
		ActorId:    ev.ActorID,
		ActorType:  ev.ActorType,
		Reason:     ev.Reason,
	}
	if ev.OccurredAt != nil {
		out.OccurredAt = timestamppb.New(*ev.OccurredAt)
	}
	if ev.Metadata != nil {
		s, err := structpb.NewStruct(map[string]any(ev.Metadata))
		if err == nil {
			out.Metadata = s
		}
	}
	return out
}
