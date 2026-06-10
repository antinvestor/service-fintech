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

package business

import (
	"context"
	"fmt"
	"time"

	"github.com/hashicorp/golang-lru/v2/expirable"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// PolicyCache wraps the candidate-policy repository with an expirable LRU
// cache keyed by (tenant_id, org_unit_id, action, currency). Entries expire
// after 30 s to bound staleness from operator policy changes. PolicyBusiness
// calls InvalidateTenant on Save/Delete for sub-second propagation.
type PolicyCache struct {
	inner repository.CandidatePolicyRepository
	cache *expirable.LRU[string, []*models.Policy]
}

const (
	// policyCacheSize bounds the candidate-policy LRU.
	policyCacheSize = 2048
	// policyCacheTTL is how long cached candidate sets stay fresh.
	policyCacheTTL = 30 * time.Second
)

// NewPolicyCache constructs a cache wrapping inner.
func NewPolicyCache(inner repository.CandidatePolicyRepository) *PolicyCache {
	return &PolicyCache{
		inner: inner,
		cache: expirable.NewLRU[string, []*models.Policy](policyCacheSize, nil, policyCacheTTL),
	}
}

// FindCandidates returns cached candidates when available; falls through to the
// wrapped repository on a miss and populates the cache on success.
func (c *PolicyCache) FindCandidates(ctx context.Context, q repository.CandidateQuery) ([]*models.Policy, error) {
	key := fmt.Sprintf("%s|%s|%s|%s", q.TenantID, q.OrgUnitID, string(q.Action), q.CurrencyCode)
	if hit, ok := c.cache.Get(key); ok {
		return hit, nil
	}
	rows, err := c.inner.FindCandidates(ctx, q)
	if err != nil {
		return nil, err
	}
	c.cache.Add(key, rows)
	return rows, nil
}

// InvalidateTenant purges the entire cache. The cache is small (≤2048 entries)
// and tenant policy changes are rare relative to the read rate, so a full purge
// is acceptable and avoids the complexity of partial invalidation.
func (c *PolicyCache) InvalidateTenant(_ string) {
	c.cache.Purge()
}
