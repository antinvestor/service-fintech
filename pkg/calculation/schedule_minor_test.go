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

package calculation_test

import (
	"strconv"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/pkg/calculation"
)

const (
	methodFlat            = 1
	methodReducingBalance = 2
	periodWeekly          = 1
	periodBiweekly        = 2
	periodMonthly         = 3
)

// TestMinorScheduleSumsToPrincipal is the invariant the loan book depends on:
// whatever the installment count, currency precision or interest method, the
// installments must amortise the principal to the last minor unit.
func TestMinorScheduleSumsToPrincipal(t *testing.T) {
	t.Parallel()

	firstDue := time.Date(2026, 3, 1, 0, 0, 0, 0, time.UTC)

	cases := []struct {
		name      string
		principal int64
		rateBP    int64
		insBP     int64
		feeBP     int64
		decimals  int32
		period    int32
	}{
		{"KES 1000.00 monthly", 100000, 1800, 100, 250, 2, periodMonthly},
		{"KES 999.99 weekly", 99999, 2400, 0, 175, 2, periodWeekly},
		{"JPY 100000 biweekly", 100000, 1250, 50, 0, 0, periodBiweekly},
		{"KWD 1000.000 monthly", 1000000, 3300, 125, 333, 3, periodMonthly},
		{"KES 1.00 monthly", 100, 1800, 100, 250, 2, periodMonthly},
	}

	methods := []struct {
		name string
		code int32
	}{
		{"flat", methodFlat},
		{"reducing", methodReducingBalance},
	}

	for _, tc := range cases {
		for _, m := range methods {
			for n := int32(1); n <= 36; n++ {
				t.Run(tc.name+"/"+m.name+"/"+strconv.Itoa(int(n)), func(t *testing.T) {
					t.Parallel()

					entries := calculation.GenerateMinorScheduleFromProduct(
						tc.principal, tc.rateBP, tc.insBP, tc.feeBP,
						m.code, n, firstDue, tc.period, tc.decimals,
					)
					require.Len(t, entries, int(n))

					var principalSum, totalSum int64
					for i, e := range entries {
						require.Equal(t, int32(i+1), e.InstallmentNumber)
						require.GreaterOrEqual(t, e.PrincipalDue, int64(0))
						require.GreaterOrEqual(t, e.InterestDue, int64(0))
						require.Equal(t,
							e.PrincipalDue+e.InterestDue+e.InsuranceDue+e.FeesDue,
							e.TotalDue,
						)
						principalSum += e.PrincipalDue
						totalSum += e.TotalDue
					}

					require.Equal(t, tc.principal, principalSum,
						"sum of installment principal must equal the loan principal exactly")
					require.GreaterOrEqual(t, totalSum, tc.principal)
				})
			}
		}
	}
}

func TestMinorScheduleDueDatesAdvance(t *testing.T) {
	t.Parallel()

	firstDue := time.Date(2026, 1, 31, 0, 0, 0, 0, time.UTC)
	entries := calculation.GenerateMinorScheduleFromProduct(
		100000, 1800, 0, 0, methodFlat, 3, firstDue, periodMonthly, 2,
	)
	require.Len(t, entries, 3)
	require.Equal(t, firstDue, entries[0].DueDate)
	for i := 1; i < len(entries); i++ {
		require.True(t, entries[i].DueDate.After(entries[i-1].DueDate))
	}
}

func TestMinorScheduleZeroInstallments(t *testing.T) {
	t.Parallel()

	require.Nil(t, calculation.GenerateMinorScheduleFromProduct(
		100000, 1800, 0, 0, methodFlat, 0, time.Now(), periodMonthly, 2,
	))
}
