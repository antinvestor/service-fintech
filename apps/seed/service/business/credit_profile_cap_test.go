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

	"github.com/antinvestor/service-fintech/apps/seed/service/business"
	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

// capRepo holds one profile and applies the cap writes it receives.
type capRepo struct {
	statusRepo
}

func (r *capRepo) SetTempCap(
	_ context.Context,
	_ string,
	amount int64,
	expiresAt *time.Time,
	setBy, reason string,
) (*models.CreditProfile, error) {
	updated := *r.profile
	updated.TempCapAmount, updated.TempCapExpiresAt = amount, expiresAt
	updated.TempCapSetBy, updated.TempCapReason = setBy, reason
	r.profile = &updated
	return &updated, nil
}

func TestTemporaryCapOnlyLowersTheLimitUntilItLapses(t *testing.T) {
	t.Parallel()
	repo := &capRepo{statusRepo{profile: &models.CreditProfile{ClientID: "c-1", CurrencyCode: "KES",
		MaxLoanAmount: 100_000, Status: int32(models.CreditProfileStatusActive)}}}
	biz := business.NewCreditProfileBusiness(context.Background(), repo, nil, nil, audit.NewWriter(nil))
	now := time.Now()
	week := now.Add(7 * 24 * time.Hour)

	for name, tc := range map[string]struct {
		amount  int64
		expires time.Time
		reason  string
	}{
		"a cap at or above the tier limit": {100_000, week, "x"},
		"a cap already expired":            {20_000, now.Add(-time.Hour), "x"},
		"a cap too far ahead":              {20_000, now.Add(100 * 24 * time.Hour), "x"},
		"a cap without a reason":           {20_000, week, " "},
	} {
		_, err := biz.SetTempCap(context.Background(), "c-1", "KES", tc.amount, tc.expires, "agent-1", tc.reason)
		require.ErrorIs(t, err, business.ErrTempCapInvalid, name)
	}

	capped, err := biz.SetTempCap(context.Background(), "c-1", "KES", 20_000, week, "agent-1", "missed visits")
	require.NoError(t, err)
	assert.Equal(t, int64(20_000), capped.EffectiveLimit(now))
	assert.Equal(t, int64(100_000), capped.EffectiveLimit(week.Add(time.Minute)), "the cap lapses on its own")

	lifted, err := biz.SetTempCap(context.Background(), "c-1", "KES", 0, time.Time{}, "agent-1", "visits resumed")
	require.NoError(t, err)
	assert.Equal(t, int64(100_000), lifted.EffectiveLimit(now))
}
