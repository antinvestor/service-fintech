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
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

// The grace period defers the late penalty by whole days after the due
// date; with no grace period the penalty is due the moment the installment is.
func TestWithinGracePeriod(t *testing.T) {
	due := time.Date(2026, 10, 1, 0, 0, 0, 0, time.UTC)
	entry := &models.ScheduleEntry{DueDate: &due}

	cases := []struct {
		name  string
		grace int32
		now   time.Time
		want  bool
	}{
		{"no grace period", 0, due.Add(time.Hour), false},
		{"inside three days", 3, due.AddDate(0, 0, 2), true},
		{"last moment of the grace period", 3, due.AddDate(0, 0, 3).Add(-time.Second), true},
		{"grace period over", 3, due.AddDate(0, 0, 3), false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			require.Equal(t, tc.want, withinGracePeriod(entry, tc.grace, tc.now))
		})
	}
	require.False(t, withinGracePeriod(&models.ScheduleEntry{}, 3, due), "an entry with no due date has no grace")
}

func TestLoanProductGracePeriodBounds(t *testing.T) {
	product := func(grace int32) *models.LoanProduct {
		return &models.LoanProduct{Name: "p", Code: "c", CurrencyCode: "KES", GracePeriodDays: grace}
	}
	require.NoError(t, validateLoanProduct(product(0)))
	require.NoError(t, validateLoanProduct(product(maxGracePeriodDays)))
	require.ErrorIs(t, validateLoanProduct(product(-1)), ErrLoanProductGracePeriodInvalid)
	require.ErrorIs(t, validateLoanProduct(product(maxGracePeriodDays+1)), ErrLoanProductGracePeriodInvalid)
}
