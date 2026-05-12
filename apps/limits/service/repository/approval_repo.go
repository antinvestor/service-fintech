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

package repository

import (
	"context"
	"time"

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/tenancy"
	"github.com/pitabwire/frame/workerpool"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
)

// ApprovalRequestRepository persists ApprovalRequest rows.
type ApprovalRequestRepository interface {
	Create(ctx context.Context, ar *models.ApprovalRequest) error
	GetByID(ctx context.Context, id string) (*models.ApprovalRequest, error)
	ListByReservation(ctx context.Context, reservationID string) ([]*models.ApprovalRequest, error)
	SetStatus(ctx context.Context, id string, status models.ApprovalStatus, decidedAt *time.Time) error
	// SetStatusTx runs SetStatus inside caller-supplied tx.
	SetStatusTx(ctx context.Context, tx *gorm.DB, id string, status models.ApprovalStatus, decidedAt *time.Time) error
	ListExpired(ctx context.Context, before time.Time, limit int) ([]*models.ApprovalRequest, error)
	Search(ctx context.Context, f ApprovalSearchFilter, limit int, cursor string) (*ApprovalSearchResult, error)
}

// ApprovalSearchFilter narrows approval request search queries.
type ApprovalSearchFilter struct {
	Status       models.ApprovalStatus
	RequiredRole string
	OrgUnitID    string
}

// ApprovalSearchResult carries a page of results and the next keyset cursor.
type ApprovalSearchResult struct {
	Items      []*models.ApprovalRequest
	NextCursor string
}

// ApprovalDecisionRepository persists ApprovalDecision rows.
type ApprovalDecisionRepository interface {
	RecordDecision(ctx context.Context, d *models.ApprovalDecision) error
	// RecordDecisionTx runs RecordDecision inside caller-supplied tx.
	RecordDecisionTx(ctx context.Context, tx *gorm.DB, d *models.ApprovalDecision) error
	ListDecisions(ctx context.Context, approvalRequestID string) ([]*models.ApprovalDecision, error)
	// ListDecisionsTx runs ListDecisions inside caller-supplied tx.
	ListDecisionsTx(ctx context.Context, tx *gorm.DB, approvalRequestID string) ([]*models.ApprovalDecision, error)
}

type approvalRequestRepository struct {
	datastore.BaseRepository[*models.ApprovalRequest]
	dbPool pool.Pool
}

// NewApprovalRequestRepository constructs the repository.
func NewApprovalRequestRepository(
	ctx context.Context,
	p pool.Pool,
	workMan workerpool.Manager,
) ApprovalRequestRepository {
	r := &approvalRequestRepository{dbPool: p}
	r.BaseRepository = datastore.NewBaseRepository[*models.ApprovalRequest](
		ctx, p, workMan,
		func() *models.ApprovalRequest { return &models.ApprovalRequest{} },
	)
	return r
}

func (r *approvalRequestRepository) Create(ctx context.Context, ar *models.ApprovalRequest) error {
	if ar.ID == "" {
		ar.ID = util.IDString()
	}
	return r.BaseRepository.Create(ctx, ar)
}

func (r *approvalRequestRepository) ListByReservation(
	ctx context.Context,
	reservationID string,
) ([]*models.ApprovalRequest, error) {
	db := r.dbPool.DB(ctx, true)
	var rows []*models.ApprovalRequest
	err := db.Where("reservation_id = ?", reservationID).
		Order("created_at ASC").
		Find(&rows).Error
	return rows, err
}

func (r *approvalRequestRepository) SetStatus(
	ctx context.Context,
	id string,
	status models.ApprovalStatus,
	decidedAt *time.Time,
) error {
	db := r.dbPool.DB(ctx, false)
	updates := map[string]any{
		"status":      string(status),
		"modified_at": time.Now().UTC(),
	}
	if decidedAt != nil {
		updates["decided_at"] = decidedAt
	}
	return db.Table(models.ApprovalRequest{}.TableName()).
		Where("id = ?", id).
		Updates(updates).Error
}

func (r *approvalRequestRepository) SetStatusTx(
	ctx context.Context,
	tx *gorm.DB,
	id string,
	status models.ApprovalStatus,
	decidedAt *time.Time,
) error {
	updates := map[string]any{
		"status":      string(status),
		"modified_at": time.Now().UTC(),
	}
	if decidedAt != nil {
		updates["decided_at"] = decidedAt
	}
	return tx.Table(models.ApprovalRequest{}.TableName()).
		Where("id = ?", id).
		Updates(updates).Error
}

func (r *approvalRequestRepository) ListExpired(
	ctx context.Context,
	before time.Time,
	limit int,
) ([]*models.ApprovalRequest, error) {
	if limit <= 0 {
		limit = 1000
	}
	// Reaper queries cross-tenant: bypass RLS tenancy enforcement.
	ctx = tenancy.WithSkipEnforcement(ctx)
	db := r.dbPool.DB(ctx, true)
	var rows []*models.ApprovalRequest
	err := db.Where("status = ? AND expires_at < ?", string(models.ApprovalStatusPending), before).
		Order("expires_at ASC").
		Limit(limit).
		Find(&rows).Error
	return rows, err
}

func (r *approvalRequestRepository) Search(
	ctx context.Context,
	f ApprovalSearchFilter,
	limit int,
	cursor string,
) (*ApprovalSearchResult, error) {
	if limit <= 0 {
		limit = 50
	}
	db := r.dbPool.DB(ctx, true).
		Table(models.ApprovalRequest{}.TableName()).
		Where("deleted_at IS NULL")
	if f.Status != "" {
		db = db.Where("status = ?", string(f.Status))
	}
	if f.RequiredRole != "" {
		db = db.Where("required_role = ?", f.RequiredRole)
	}
	if f.OrgUnitID != "" {
		db = db.Where("org_unit_id = ?", f.OrgUnitID)
	}
	if cursor != "" {
		db = db.Where("id > ?", cursor)
	}
	var rows []*models.ApprovalRequest
	if err := db.Order("id ASC").Limit(limit + 1).Find(&rows).Error; err != nil {
		return nil, err
	}
	out := &ApprovalSearchResult{}
	if len(rows) > limit {
		out.NextCursor = rows[limit-1].ID
		rows = rows[:limit]
	}
	out.Items = rows
	return out, nil
}

type approvalDecisionRepository struct {
	datastore.BaseRepository[*models.ApprovalDecision]
	dbPool pool.Pool
}

// NewApprovalDecisionRepository constructs the repository.
func NewApprovalDecisionRepository(
	ctx context.Context,
	p pool.Pool,
	workMan workerpool.Manager,
) ApprovalDecisionRepository {
	r := &approvalDecisionRepository{dbPool: p}
	r.BaseRepository = datastore.NewBaseRepository[*models.ApprovalDecision](
		ctx, p, workMan,
		func() *models.ApprovalDecision { return &models.ApprovalDecision{} },
	)
	return r
}

func (r *approvalDecisionRepository) RecordDecision(ctx context.Context, d *models.ApprovalDecision) error {
	if d.ID == "" {
		d.ID = util.IDString()
	}
	// BaseRepository.Create surfaces the Postgres unique-violation error from
	// uq_approval_decision; the caller maps it to AlreadyExists.
	return r.BaseRepository.Create(ctx, d)
}

func (r *approvalDecisionRepository) RecordDecisionTx(
	ctx context.Context,
	tx *gorm.DB,
	d *models.ApprovalDecision,
) error {
	if d.ID == "" {
		d.ID = util.IDString()
	}
	return tx.Create(d).Error
}

func (r *approvalDecisionRepository) ListDecisions(
	ctx context.Context,
	approvalRequestID string,
) ([]*models.ApprovalDecision, error) {
	db := r.dbPool.DB(ctx, true)
	var rows []*models.ApprovalDecision
	err := db.Where("approval_request_id = ?", approvalRequestID).
		Order("decided_at ASC").
		Find(&rows).Error
	return rows, err
}

func (r *approvalDecisionRepository) ListDecisionsTx(
	ctx context.Context,
	tx *gorm.DB,
	approvalRequestID string,
) ([]*models.ApprovalDecision, error) {
	var rows []*models.ApprovalDecision
	err := tx.WithContext(ctx).
		Where("approval_request_id = ?", approvalRequestID).
		Order("decided_at ASC").
		Find(&rows).Error
	return rows, err
}
