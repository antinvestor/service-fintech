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

	"github.com/pitabwire/frame/v2/datastore/pool"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
)

// CandidatePolicyRepository finds every policy applicable to a given intent.
// Bypasses the TenancyPartition scope deliberately to union platform-scoped
// policies (tenant_id = ”) with the calling tenant's own policies.
type CandidatePolicyRepository interface {
	FindCandidates(ctx context.Context, q CandidateQuery) ([]*models.Policy, error)
}

type CandidateQuery struct {
	Action       models.Action
	CurrencyCode string
	TenantID     string
	OrgUnitID    string
}

type candidatePolicyRepository struct {
	dbPool pool.Pool
}

func NewCandidatePolicyRepository(p pool.Pool) CandidatePolicyRepository {
	return &candidatePolicyRepository{dbPool: p}
}

func (r *candidatePolicyRepository) FindCandidates(ctx context.Context, q CandidateQuery) ([]*models.Policy, error) {
	db := r.dbPool.DB(ctx, true)
	var rows []*models.Policy
	now := time.Now().UTC()
	err := db.Table(models.Policy{}.TableName()).
		Where("deleted_at IS NULL AND mode != ?", string(models.ModeOff)).
		Where("effective_from <= ? AND (effective_to IS NULL OR effective_to > ?)", now, now).
		Where("action = ?", string(q.Action)).
		Where("(currency_code = ? OR currency_code = '')", q.CurrencyCode).
		Where(
			"(scope = ? AND tenant_id = '') OR "+
				"(scope = ? AND tenant_id = ?) OR "+
				"(scope = ? AND tenant_id = ? AND org_unit_id = ?)",
			string(models.ScopePlatform),
			string(models.ScopeOrg), q.TenantID,
			string(models.ScopeOrgUnit), q.TenantID, q.OrgUnitID,
		).
		Find(&rows).Error
	return rows, err
}
