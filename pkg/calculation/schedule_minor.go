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

package calculation

import (
	"time"

	"github.com/pitabwire/util/decimalx"
)

// MinorScheduleEntry is a single installment expressed in integer minor units
// of the loan currency. It is the storable form of ScheduleEntry: every
// component is already rounded, and the rounding residual has been absorbed so
// that the schedule amortises exactly the amounts it was built from.
type MinorScheduleEntry struct {
	InstallmentNumber int32
	DueDate           time.Time
	PrincipalDue      int64
	InterestDue       int64
	InsuranceDue      int64
	FeesDue           int64
	TotalDue          int64
}

// GenerateMinorScheduleFromProduct builds an amortization schedule directly in
// minor units.
//
// Working in minor units is what makes the schedule exact. Rounding a decimal
// installment independently per period leaves a residual of up to half a minor
// unit each time, which for a twelve-month loan is enough to make the schedule
// disagree with the principal it is meant to repay. Here each component is
// split by integer division and the final installment takes the remainder, so
// sum(PrincipalDue) == principalMinor for every installment count, currency
// precision and interest method.
//
// decimals is the currency's ISO-4217 fraction digit count.
func GenerateMinorScheduleFromProduct(
	principalMinor int64,
	annualInterestRateBP int64,
	insuranceFeePercentBP int64,
	processingFeePercentBP int64,
	interestMethod int32,
	installments int32,
	firstDueDate time.Time,
	periodType int32,
	decimals int32,
) []MinorScheduleEntry {
	if installments <= 0 || principalMinor < 0 {
		return nil
	}

	if interestMethod == interestMethodReducingBalance {
		return reducingBalanceMinorSchedule(
			principalMinor, annualInterestRateBP, insuranceFeePercentBP, processingFeePercentBP,
			installments, firstDueDate, periodType, decimals,
		)
	}
	return flatMinorSchedule(
		principalMinor, annualInterestRateBP, insuranceFeePercentBP, processingFeePercentBP,
		installments, firstDueDate, periodType, decimals, interestMethod == interestMethodCompound,
	)
}

func flatMinorSchedule(
	principalMinor int64,
	annualInterestRateBP, insuranceFeePercentBP, processingFeePercentBP int64,
	installments int32,
	firstDueDate time.Time,
	periodType int32,
	decimals int32,
	compound bool,
) []MinorScheduleEntry {
	principal := decimalx.FromMinorUnits(principalMinor, decimals)
	periodsPerYear := PeriodsPerYear(periodType)

	// Compound interest grows on the principal once per period over the
	// term and, like flat interest, is collected in equal parts.
	interest := FlatRateInterest(principal, annualInterestRateBP, installments, periodsPerYear)
	if compound {
		interest = CompoundInterest(principal, annualInterestRateBP, installments, periodsPerYear)
	}

	// Fees are a one-off percentage of the principal spread over the
	// installments, not an annual rate: a 2% processing fee on a three-month
	// loan collects 2%, not 0.5%.
	totals := [4]int64{
		principalMinor,
		interest.ToMinorUnits(decimals),
		decimalx.ApplyBasisPoints(principal, insuranceFeePercentBP).ToMinorUnits(decimals),
		decimalx.ApplyBasisPoints(principal, processingFeePercentBP).ToMinorUnits(decimals),
	}

	entries := make([]MinorScheduleEntry, installments)
	for i := range installments {
		last := i == installments-1
		entries[i] = MinorScheduleEntry{
			InstallmentNumber: i + 1,
			DueDate:           DueDateAt(firstDueDate, periodType, i),
			PrincipalDue:      installmentShare(totals[0], installments, last),
			InterestDue:       installmentShare(totals[1], installments, last),
			InsuranceDue:      installmentShare(totals[2], installments, last),
			FeesDue:           installmentShare(totals[3], installments, last),
		}
		entries[i].TotalDue = entries[i].PrincipalDue + entries[i].InterestDue +
			entries[i].InsuranceDue + entries[i].FeesDue
	}
	return entries
}

func reducingBalanceMinorSchedule(
	principalMinor int64,
	annualInterestRateBP, insuranceFeePercentBP, processingFeePercentBP int64,
	installments int32,
	firstDueDate time.Time,
	periodType int32,
	decimals int32,
) []MinorScheduleEntry {
	ppy := decimalx.NewFromInt64(int64(PeriodsPerYear(periodType)))
	entries := make([]MinorScheduleEntry, installments)
	remaining := principalMinor

	// Fees are a one-off percentage of the principal spread over the
	// installments, the same as on a flat schedule.
	principal := decimalx.FromMinorUnits(principalMinor, decimals)
	insuranceTotal := decimalx.ApplyBasisPoints(principal, insuranceFeePercentBP).ToMinorUnits(decimals)
	feesTotal := decimalx.ApplyBasisPoints(principal, processingFeePercentBP).ToMinorUnits(decimals)

	for i := range installments {
		last := i == installments-1
		outstanding := decimalx.FromMinorUnits(remaining, decimals)

		principalDue := installmentShare(principalMinor, installments, last)
		if last {
			principalDue = remaining
		}

		entries[i] = MinorScheduleEntry{
			InstallmentNumber: i + 1,
			DueDate:           DueDateAt(firstDueDate, periodType, i),
			PrincipalDue:      principalDue,
			InterestDue: decimalx.ApplyBasisPoints(outstanding, annualInterestRateBP).
				Div(ppy).ToMinorUnits(decimals),
			InsuranceDue: installmentShare(insuranceTotal, installments, i == installments-1),
			FeesDue:      installmentShare(feesTotal, installments, i == installments-1),
		}
		entries[i].TotalDue = entries[i].PrincipalDue + entries[i].InterestDue +
			entries[i].InsuranceDue + entries[i].FeesDue

		remaining -= principalDue
	}
	return entries
}

// installmentShare splits total evenly across installments, giving the final
// installment the whole remainder so the shares sum back to total exactly.
func installmentShare(total int64, installments int32, last bool) int64 {
	n := int64(installments)
	base := total / n
	if last {
		return total - base*(n-1)
	}
	return base
}
