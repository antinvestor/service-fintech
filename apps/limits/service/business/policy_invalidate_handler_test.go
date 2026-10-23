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
	"github.com/antinvestor/service-fintech/apps/limits/service/events"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// TestPolicyInvalidateHandler_PurgesCacheOnEvent plays the invalidation event
// a peer replica would publish into the subscriber and asserts the next lookup
// goes back to the store instead of serving the stale entry.
func TestPolicyInvalidateHandler_PurgesCacheOnEvent(t *testing.T) {
	stub := &countingCandidateRepo{results: []*models.Policy{{Action: models.ActionLoanDisbursement}}}
	cache := business.NewPolicyCache(stub, time.Hour) // long TTL: only the event can evict
	handler := business.NewPolicyInvalidateHandler(cache)
	ctx := context.Background()
	q := repository.CandidateQuery{
		TenantID: "tenant-a", OrgUnitID: "ou-1", Action: models.ActionLoanDisbursement, CurrencyCode: "KES",
	}

	_, err := cache.FindCandidates(ctx, q)
	require.NoError(t, err)
	_, err = cache.FindCandidates(ctx, q)
	require.NoError(t, err)
	require.Equal(t, 1, stub.calls, "warm cache serves the second read")

	assert.Equal(t, events.EventPolicyInvalidate, handler.Name())
	_, isPayload := handler.PayloadType().(*events.PolicyInvalidatePayload)
	assert.True(t, isPayload, "PayloadType must decode to the emitted payload struct")

	payload := &events.PolicyInvalidatePayload{PolicyID: "pol-1", TenantID: "tenant-a"}
	require.NoError(t, handler.Validate(ctx, payload))
	require.NoError(t, handler.Execute(ctx, payload))

	_, err = cache.FindCandidates(ctx, q)
	require.NoError(t, err)
	assert.Equal(t, 2, stub.calls, "the event must evict the entry so the next read reaches the store")

	// Redelivery is harmless.
	require.NoError(t, handler.Execute(ctx, payload))
}

func TestPolicyInvalidateHandler_RejectsForeignPayload(t *testing.T) {
	handler := business.NewPolicyInvalidateHandler(business.NewPolicyCache(&countingCandidateRepo{}, time.Minute))
	ctx := context.Background()

	require.Error(t, handler.Validate(ctx, "not a payload"))
	require.Error(t, handler.Execute(ctx, &events.ApprovalEventPayload{}))
}

func TestPolicyInvalidateHandler_NilCacheIsNoop(t *testing.T) {
	handler := business.NewPolicyInvalidateHandler(nil)
	require.NoError(t, handler.Execute(context.Background(), &events.PolicyInvalidatePayload{TenantID: "t"}))
}
