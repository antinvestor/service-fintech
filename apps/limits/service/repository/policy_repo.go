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

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

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
func (r *policyRepository) SaveTx(ctx context.Context, tx *gorm.DB, p *models.Policy) error {
	if p.ID == "" {
		p.GenID(ctx)
		return tx.Create(p).Error
	}
	return tx.Save(p).Error
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
		db = db.Where("notes ILIKE ?", "%"+strings.ToLower(f.Query)+"%")
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

// Delete soft-deletes a Policy by its ID.
func (r *policyRepository) Delete(ctx context.Context, id string) error {
	return r.BaseRepository.Delete(ctx, id)
}

// PolicyVersionRepository persists immutable policy snapshots.
type PolicyVersionRepository interface {
	Append(ctx context.Context, v *models.PolicyVersion) error
	List(ctx context.Context, policyID string) ([]*models.PolicyVersion, error)
}

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

func (r *policyVersionRepository) List(ctx context.Context, policyID string) ([]*models.PolicyVersion, error) {
	var rows []*models.PolicyVersion
	db := r.dbPool.DB(ctx, true)
	err := db.Model(&models.PolicyVersion{}).
		Where("policy_id = ?", policyID).
		Order("version ASC").
		Find(&rows).Error
	return rows, err
}
