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

package business_test

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// countingCandidateRepo is a minimal stub that counts how many times
// FindCandidates reaches the backing store.
type countingCandidateRepo struct {
	calls   int
	results []*models.Policy
}

func (r *countingCandidateRepo) FindCandidates(
	_ context.Context,
	_ repository.CandidateQuery,
) ([]*models.Policy, error) {
	r.calls++
	return r.results, nil
}

func TestPolicyCache_HitsDBOnce(t *testing.T) {
	stub := &countingCandidateRepo{
		results: []*models.Policy{{Action: models.ActionLoanDisbursement}},
	}
	cache := business.NewPolicyCache(stub, 30*time.Second)
	ctx := context.Background()
	q := repository.CandidateQuery{
		TenantID:     "tenant-a",
		OrgUnitID:    "ou-1",
		Action:       models.ActionLoanDisbursement,
		CurrencyCode: "KES",
	}

	first, err := cache.FindCandidates(ctx, q)
	require.NoError(t, err)
	assert.Len(t, first, 1)

	second, err := cache.FindCandidates(ctx, q)
	require.NoError(t, err)
	assert.Len(t, second, 1)

	// Both calls returned results but the backing store was only hit once.
	assert.Equal(t, 1, stub.calls, "expected exactly one DB call due to cache hit on second request")
}

func TestPolicyCache_DifferentKeysAreCachedSeparately(t *testing.T) {
	stub := &countingCandidateRepo{results: []*models.Policy{}}
	cache := business.NewPolicyCache(stub, 30*time.Second)
	ctx := context.Background()

	q1 := repository.CandidateQuery{
		TenantID:     "tenant-a",
		OrgUnitID:    "ou-1",
		Action:       models.ActionLoanDisbursement,
		CurrencyCode: "KES",
	}
	q2 := repository.CandidateQuery{
		TenantID:     "tenant-b",
		OrgUnitID:    "ou-2",
		Action:       models.ActionLoanDisbursement,
		CurrencyCode: "KES",
	}

	_, _ = cache.FindCandidates(ctx, q1)
	_, _ = cache.FindCandidates(ctx, q2)
	_, _ = cache.FindCandidates(ctx, q1)
	_, _ = cache.FindCandidates(ctx, q2)

	assert.Equal(t, 2, stub.calls, "expected two DB calls — one per distinct key")
}

func TestPolicyCache_InvalidatePurgesCache(t *testing.T) {
	stub := &countingCandidateRepo{results: []*models.Policy{}}
	cache := business.NewPolicyCache(stub, 30*time.Second)
	ctx := context.Background()

	q := repository.CandidateQuery{
		TenantID:     "tenant-a",
		OrgUnitID:    "ou-1",
		Action:       models.ActionLoanDisbursement,
		CurrencyCode: "KES",
	}

	_, _ = cache.FindCandidates(ctx, q) // miss → DB call 1
	_, _ = cache.FindCandidates(ctx, q) // hit → no DB call

	cache.InvalidateTenant("tenant-a")

	_, _ = cache.FindCandidates(ctx, q) // miss after purge → DB call 2

	assert.Equal(t, 2, stub.calls, "expected two DB calls — before and after invalidation")
}
