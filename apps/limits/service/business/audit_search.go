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
	"github.com/pitabwire/frame/datastore/pool"
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

func (b *auditSearchBusiness) Search(
	ctx context.Context,
	req *limitsv1.LimitsAuditSearchRequest,
	batch func(ctx context.Context, items []*limitsv1.LimitsAuditEventObject) error,
) error {
	const pageSize = 50
	cursor := ""
	if req.GetCursor() != nil {
		cursor = req.GetCursor().GetPage()
	}
	for {
		var rows []*audit.Event
		db := b.dbPool.DB(ctx, true).
			Table(audit.Event{}.TableName()).
			Where("deleted_at IS NULL")
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
		if cursor != "" {
			db = db.Where("id > ?", cursor)
		}
		if err := db.Order("id ASC").Limit(pageSize + 1).Find(&rows).Error; err != nil {
			return err
		}
		next := ""
		if len(rows) > pageSize {
			next = rows[pageSize-1].ID
			rows = rows[:pageSize]
		}
		api := make([]*limitsv1.LimitsAuditEventObject, len(rows))
		for i, ev := range rows {
			api[i] = auditEventToAPI(ev)
		}
		if err := batch(ctx, api); err != nil {
			return err
		}
		if next == "" {
			return nil
		}
		cursor = next
	}
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
