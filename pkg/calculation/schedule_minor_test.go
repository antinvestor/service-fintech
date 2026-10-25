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
	methodCompound        = 3
	periodWeekly          = 1
	periodBiweekly        = 2
	periodMonthly         = 3
	periodDaily           = 4
	periodQuarterly       = 5
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
		{"KES 5000.00 daily", 500000, 3650, 0, 100, 2, periodDaily},
		{"KES 250000.00 quarterly", 25000000, 2000, 50, 150, 2, periodQuarterly},
	}

	methods := []struct {
		name string
		code int32
	}{
		{"flat", methodFlat},
		{"reducing", methodReducingBalance},
		{"compound", methodCompound},
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

// A loan due at the end of the month stays due at the end of the month: it
// never slides into the next month, and never drifts to the 3rd.
func TestDueDatesHoldTheEndOfTheMonth(t *testing.T) {
	t.Parallel()

	day := func(y int, m time.Month, d int) time.Time { return time.Date(y, m, d, 9, 0, 0, 0, time.UTC) }
	cases := []struct {
		name   string
		first  time.Time
		period int32
		want   []time.Time
	}{
		{"monthly from 31 Jan", day(2026, 1, 31), periodMonthly,
			[]time.Time{day(2026, 1, 31), day(2026, 2, 28), day(2026, 3, 31), day(2026, 4, 30)}},
		{"monthly from 31 Jan in a leap year", day(2028, 1, 31), periodMonthly,
			[]time.Time{day(2028, 1, 31), day(2028, 2, 29), day(2028, 3, 31)}},
		{"monthly across the year end", day(2026, 11, 30), periodMonthly,
			[]time.Time{day(2026, 11, 30), day(2026, 12, 30), day(2027, 1, 30), day(2027, 2, 28)}},
		{"quarterly from 30 Nov", day(2026, 11, 30), periodQuarterly,
			[]time.Time{day(2026, 11, 30), day(2027, 2, 28), day(2027, 5, 30), day(2027, 8, 30)}},
		{"daily across a month", day(2026, 2, 27), periodDaily,
			[]time.Time{day(2026, 2, 27), day(2026, 2, 28), day(2026, 3, 1)}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			for n, want := range tc.want {
				require.Equal(t, want, calculation.DueDateAt(tc.first, tc.period, int32(n)), "installment %d", n+1)
			}
		})
	}
}

// Compound interest grows on the principal once per period and is collected
// in equal parts. On one period it equals simple interest; on more it is
// strictly more than flat interest and matches the closed form.
func TestCompoundInterestSchedule(t *testing.T) {
	t.Parallel()

	firstDue := time.Date(2026, 3, 1, 0, 0, 0, 0, time.UTC)
	interestOf := func(method int32, n int32, period int32) int64 {
		var total int64
		for _, e := range calculation.GenerateMinorScheduleFromProduct(
			1_000_000, 2400, 0, 0, method, n, firstDue, period, 2,
		) {
			total += e.InterestDue
		}
		return total
	}

	require.Equal(t, interestOf(methodFlat, 1, periodMonthly), interestOf(methodCompound, 1, periodMonthly))
	// 10,000.00 at 24% a year, compounded monthly for 12 months:
	// 10000 * (1.02^12 - 1) = 2682.42.
	require.Equal(t, int64(268_242), interestOf(methodCompound, 12, periodMonthly))
	require.Equal(t, int64(240_000), interestOf(methodFlat, 12, periodMonthly))
	// 10,000.00 at 24% a year, compounded daily for 30 days:
	// 10000 * ((1 + 0.24/365)^30 - 1) = 199.15.
	require.Equal(t, int64(19_915), interestOf(methodCompound, 30, periodDaily))
	// Four quarters at 24%: 10000 * (1.06^4 - 1) = 2624.77.
	require.Equal(t, int64(262_477), interestOf(methodCompound, 4, periodQuarterly))
}

func TestMinorScheduleZeroInstallments(t *testing.T) {
	t.Parallel()

	require.Nil(t, calculation.GenerateMinorScheduleFromProduct(
		100000, 1800, 0, 0, methodFlat, 0, time.Now(), periodMonthly, 2,
	))
}

// Fees are a one-off percentage of the principal, collected in full over the
// schedule whatever the installment count or interest method.
func TestMinorScheduleFeesAreChargedOnce(t *testing.T) {
	const principal = int64(1_000_000) // 10,000.00
	for _, method := range []int32{1, 2} {
		for _, installments := range []int32{1, 3, 12} {
			entries := calculation.GenerateMinorScheduleFromProduct(principal, 2400, 100, 200, method, installments,
				time.Date(2026, 1, 31, 0, 0, 0, 0, time.UTC), 3, 2)
			var insurance, fees int64
			for _, e := range entries {
				insurance += e.InsuranceDue
				fees += e.FeesDue
			}
			if insurance != 10_000 {
				t.Fatalf(
					"method %d, %d installments: insurance fee %d, want 1%% of principal = 10000",
					method,
					installments,
					insurance,
				)
			}
			if fees != 20_000 {
				t.Fatalf(
					"method %d, %d installments: processing fee %d, want 2%% of principal = 20000",
					method,
					installments,
					fees,
				)
			}
		}
	}
}
