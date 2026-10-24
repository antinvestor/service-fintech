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
	"strings"

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/tenancy"
	"github.com/pitabwire/frame/v3/workerpool"
	"github.com/pitabwire/util"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
)

// PolicySearchFilter narrows the result set for PolicyRepository.Search.
type PolicySearchFilter struct {
	Query       string
	OrgUnitID   string
	Action      models.Action
	SubjectType models.Subject
	Mode        models.Mode
}

// PolicySearchResult is a paged batch of policies plus a next-cursor.
type PolicySearchResult struct {
	Items      []*models.Policy
	NextCursor string
}

// PolicyRepository is the data-access surface for Policy.
type PolicyRepository interface {
	Save(ctx context.Context, p *models.Policy) error
	// SaveTx creates or updates the policy within the caller's DB transaction.
	// Use this when the policy mutation must be atomic with an audit write.
	SaveTx(ctx context.Context, tx *gorm.DB, p *models.Policy) error
	Get(ctx context.Context, id string) (*models.Policy, error)
	// GetForUpdateTx reads a policy inside tx with a row-level lock so a
	// read-modify-write cycle cannot interleave with a concurrent save.
	GetForUpdateTx(ctx context.Context, tx *gorm.DB, id string) (*models.Policy, error)
	// MaxLiveWindowSeconds returns the largest rolling window declared by any
	// live (non-deleted, non-off) policy across all tenants. Archival uses it
	// to refuse deleting ledger rows a live cap still reads.
	MaxLiveWindowSeconds(ctx context.Context) (int64, error)
	Search(ctx context.Context, f PolicySearchFilter, limit int, cursor string) (*PolicySearchResult, error)
	Delete(ctx context.Context, id string) error
	// DeleteTx soft-deletes the policy within the caller's DB transaction.
	DeleteTx(ctx context.Context, tx *gorm.DB, id string) error
}

type policyRepository struct {
	datastore.BaseRepository[*models.Policy]
	dbPool pool.Pool
}

// NewPolicyRepository constructs a PolicyRepository backed by Frame's BaseRepository.
func NewPolicyRepository(ctx context.Context, p pool.Pool, workMan workerpool.Manager) PolicyRepository {
	return &policyRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Policy](
			ctx, p, workMan,
			func() *models.Policy { return &models.Policy{} },
		),
		dbPool: p,
	}
}

// Save creates or updates a Policy.
// A policy without an ID is inserted; one with an ID is updated.
func (r *policyRepository) Save(ctx context.Context, p *models.Policy) error {
	if p.ID == "" {
		return r.BaseRepository.Create(ctx, p)
	}
	_, err := r.BaseRepository.Update(ctx, p)
	return err
}

// SaveTx creates or updates a Policy within the caller's DB transaction.
// GORM's BeforeCreate/BeforeUpdate hooks fire normally on the tx session.
// Platform-scoped rows carry no tenant, so RLS enforcement is skipped for
// them — the WITH CHECK predicate would otherwise reject the empty tenant.
func (r *policyRepository) SaveTx(ctx context.Context, tx *gorm.DB, p *models.Policy) error {
	if p.Scope == models.ScopePlatform {
		ctx = tenancy.WithSkipEnforcement(ctx)
		tx = tx.WithContext(ctx)
	}
	if p.ID == "" {
		p.GenID(ctx)
		return tx.Create(p).Error
	}
	return tx.Save(p).Error
}

// GetForUpdateTx reads a policy with SELECT ... FOR UPDATE inside tx.
func (r *policyRepository) GetForUpdateTx(ctx context.Context, tx *gorm.DB, id string) (*models.Policy, error) {
	var out models.Policy
	err := tx.WithContext(ctx).
		Clauses(clause.Locking{Strength: "UPDATE"}).
		Where("id = ?", id).
		First(&out).Error
	if err != nil {
		return nil, err
	}
	return &out, nil
}

// MaxLiveWindowSeconds returns the widest rolling window in use, cross-tenant.
func (r *policyRepository) MaxLiveWindowSeconds(ctx context.Context) (int64, error) {
	ctx = tenancy.WithSkipEnforcement(ctx)
	var maxWindow int64
	err := r.dbPool.DB(ctx, true).
		Table(models.Policy{}.TableName()).
		Where("deleted_at IS NULL AND mode != ?", string(models.ModeOff)).
		Select("COALESCE(MAX(window_seconds), 0)").
		Scan(&maxWindow).Error
	return maxWindow, err
}

// DeleteTx soft-deletes a Policy within the caller's DB transaction.
func (r *policyRepository) DeleteTx(_ context.Context, tx *gorm.DB, id string) error {
	entity := &models.Policy{}
	return tx.Where("id = ?", id).Delete(entity).Error
}

// Get retrieves a single Policy by its ID.
func (r *policyRepository) Get(ctx context.Context, id string) (*models.Policy, error) {
	return r.BaseRepository.GetByID(ctx, id)
}

// Search returns policies matching the given filter, scoped to the current tenant/partition.
// Results are ordered by ID ascending for stable cursor-based pagination.
func (r *policyRepository) Search(
	ctx context.Context,
	f PolicySearchFilter,
	limit int,
	cursor string,
) (*PolicySearchResult, error) {
	if limit <= 0 {
		limit = 50
	}

	db := r.dbPool.DB(ctx, true).
		Model(&models.Policy{})

	if f.OrgUnitID != "" {
		db = db.Where("org_unit_id = ?", f.OrgUnitID)
	}
	if f.Action != "" {
		db = db.Where("action = ?", string(f.Action))
	}
	if f.SubjectType != "" {
		db = db.Where("subject_type = ?", string(f.SubjectType))
	}
	if f.Mode != "" {
		db = db.Where("mode = ?", string(f.Mode))
	}
	if f.Query != "" {
		db = db.Where(`notes ILIKE ? ESCAPE '\'`, "%"+escapeLike(f.Query)+"%")
	}
	if cursor != "" {
		db = db.Where("id > ?", cursor)
	}

	var rows []*models.Policy
	if err := db.Order("id ASC").Limit(limit + 1).Find(&rows).Error; err != nil {
		return nil, err
	}

	out := &PolicySearchResult{}
	if len(rows) > limit {
		out.NextCursor = rows[limit-1].ID
		rows = rows[:limit]
	}
	out.Items = rows
	return out, nil
}

// escapeLike neutralises the LIKE wildcards a user may type into a free-text
// search box so they match literally.
func escapeLike(s string) string {
	r := strings.NewReplacer(`\`, `\\`, "%", `\%`, "_", `\_`)
	return r.Replace(s)
}

// Delete soft-deletes a Policy by its ID.
func (r *policyRepository) Delete(ctx context.Context, id string) error {
	return r.BaseRepository.Delete(ctx, id)
}

// PolicyVersionRepository persists immutable policy snapshots.
type PolicyVersionRepository interface {
	Append(ctx context.Context, v *models.PolicyVersion) error
	// AppendTx writes the snapshot inside the caller's transaction so the
	// history row commits with the policy change it describes.
	AppendTx(ctx context.Context, tx *gorm.DB, v *models.PolicyVersion) error
	List(ctx context.Context, policyID string) ([]*models.PolicyVersion, error)
	// ListPage returns one page of snapshots newest-first. beforeVersion is
	// the keyset cursor: only versions strictly below it are returned; zero
	// means start from the latest.
	ListPage(ctx context.Context, policyID string, limit int, beforeVersion int32) ([]*models.PolicyVersion, error)
	// ListTx reads the snapshots inside the caller's transaction.
	ListTx(ctx context.Context, tx *gorm.DB, policyID string) ([]*models.PolicyVersion, error)
}

// defaultVersionPageSize is the history page size when the caller sets none.
const defaultVersionPageSize = 50

type policyVersionRepository struct {
	datastore.BaseRepository[*models.PolicyVersion]
	dbPool pool.Pool
}

// NewPolicyVersionRepository constructs a PolicyVersionRepository.
func NewPolicyVersionRepository(ctx context.Context, p pool.Pool, workMan workerpool.Manager) PolicyVersionRepository {
	r := &policyVersionRepository{dbPool: p}
	r.BaseRepository = datastore.NewBaseRepository[*models.PolicyVersion](
		ctx, p, workMan,
		func() *models.PolicyVersion { return &models.PolicyVersion{} },
	)
	return r
}

func (r *policyVersionRepository) Append(ctx context.Context, v *models.PolicyVersion) error {
	if v.ID == "" {
		v.ID = util.IDString()
	}
	return r.BaseRepository.Create(ctx, v)
}

func (r *policyVersionRepository) AppendTx(ctx context.Context, tx *gorm.DB, v *models.PolicyVersion) error {
	if v.ID == "" {
		v.ID = util.IDString()
	}
	v.GenID(ctx)
	return tx.WithContext(ctx).Create(v).Error
}

func (r *policyVersionRepository) ListTx(
	ctx context.Context,
	tx *gorm.DB,
	policyID string,
) ([]*models.PolicyVersion, error) {
	var rows []*models.PolicyVersion
	err := tx.WithContext(ctx).
		Model(&models.PolicyVersion{}).
		Where("policy_id = ?", policyID).
		Order("version ASC").
		Find(&rows).Error
	return rows, err
}

func (r *policyVersionRepository) List(ctx context.Context, policyID string) ([]*models.PolicyVersion, error) {
	var rows []*models.PolicyVersion
	db := r.dbPool.DB(ctx, true)
	err := db.Model(&models.PolicyVersion{}).
		Where("policy_id = ?", policyID).
		Order("version ASC").
		Find(&rows).Error
	return rows, err
}

func (r *policyVersionRepository) ListPage(
	ctx context.Context,
	policyID string,
	limit int,
	beforeVersion int32,
) ([]*models.PolicyVersion, error) {
	if limit <= 0 {
		limit = defaultVersionPageSize
	}
	db := r.dbPool.DB(ctx, true).
		Model(&models.PolicyVersion{}).
		Where("policy_id = ?", policyID)
	if beforeVersion > 0 {
		db = db.Where("version < ?", beforeVersion)
	}
	var rows []*models.PolicyVersion
	err := db.Order("version DESC").Limit(limit).Find(&rows).Error
	return rows, err
}
