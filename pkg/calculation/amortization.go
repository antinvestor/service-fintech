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

const (
	// periodTypeWeekly is the period type code for weekly periods.
	periodTypeWeekly = 1
	// periodTypeBiweekly is the period type code for biweekly periods.
	periodTypeBiweekly = 2
	// periodTypeMonthly is the period type code for monthly periods.
	periodTypeMonthly = 3
	// periodTypeDaily is the period type code for daily periods.
	periodTypeDaily = 4
	// periodTypeQuarterly is the period type code for quarterly periods.
	periodTypeQuarterly = 5
	// monthsPerQuarter is the number of months in a quarterly period.
	monthsPerQuarter = 3
	// daysPerWeek is the number of days in a weekly period.
	daysPerWeek = 7
	// daysPerBiweek is the number of days in a biweekly period.
	daysPerBiweek = 14
	// interestMethodReducingBalance is the code for reducing-balance interest calculation.
	interestMethodReducingBalance = 2
	// interestMethodCompound is the code for compound interest calculation.
	interestMethodCompound = 3
)

// ScheduleEntry represents a single installment in an amortization schedule.
type ScheduleEntry struct {
	InstallmentNumber int32
	DueDate           time.Time
	PrincipalDue      decimalx.Decimal
	InterestDue       decimalx.Decimal
	InsuranceDue      decimalx.Decimal
	FeesDue           decimalx.Decimal // processing/origination fees
	TotalDue          decimalx.Decimal
}

// GenerateFlatSchedule generates a flat-rate amortization schedule.
// principal, totalInterest, totalInsurance, totalFees are Decimal amounts.
// installments is the number of payments.
// firstDueDate is when the first payment is due.
// periodType determines the interval (1=WEEKLY, 2=BIWEEKLY, 3=MONTHLY).
func GenerateFlatSchedule(
	principal decimalx.Decimal,
	totalInterest decimalx.Decimal,
	totalInsurance decimalx.Decimal,
	totalFees decimalx.Decimal,
	installments int32,
	firstDueDate time.Time,
	periodType int32,
) []ScheduleEntry {
	if installments <= 0 {
		return nil
	}

	n := decimalx.NewFromInt64(int64(installments))
	entries := make([]ScheduleEntry, installments)
	principalPerPeriod := principal.Div(n)
	interestPerPeriod := totalInterest.Div(n)
	insurancePerPeriod := totalInsurance.Div(n)
	feesPerPeriod := totalFees.Div(n)

	// Dust handling: last installment absorbs rounding remainder
	principalRemainder := principal.Sub(principalPerPeriod.Mul(n))
	interestRemainder := totalInterest.Sub(interestPerPeriod.Mul(n))
	insuranceRemainder := totalInsurance.Sub(insurancePerPeriod.Mul(n))
	feesRemainder := totalFees.Sub(feesPerPeriod.Mul(n))

	for i := range installments {
		entry := ScheduleEntry{
			InstallmentNumber: i + 1,
			DueDate:           DueDateAt(firstDueDate, periodType, i),
			PrincipalDue:      principalPerPeriod,
			InterestDue:       interestPerPeriod,
			InsuranceDue:      insurancePerPeriod,
			FeesDue:           feesPerPeriod,
		}

		// Last installment absorbs remainder
		if i == installments-1 {
			entry.PrincipalDue = entry.PrincipalDue.Add(principalRemainder)
			entry.InterestDue = entry.InterestDue.Add(interestRemainder)
			entry.InsuranceDue = entry.InsuranceDue.Add(insuranceRemainder)
			entry.FeesDue = entry.FeesDue.Add(feesRemainder)
		}

		entry.TotalDue = entry.PrincipalDue.Add(entry.InterestDue).Add(entry.InsuranceDue).Add(entry.FeesDue)
		entries[i] = entry
	}

	return entries
}

// GenerateReducingBalanceSchedule generates a reducing-balance amortization schedule.
func GenerateReducingBalanceSchedule(
	principal decimalx.Decimal,
	annualRateBP int64,
	insuranceRateBP int64,
	feeRateBP int64,
	installments int32,
	firstDueDate time.Time,
	periodType int32,
) []ScheduleEntry {
	if installments <= 0 {
		return nil
	}

	ppy := decimalx.NewFromInt64(int64(PeriodsPerYear(periodType)))
	entries := make([]ScheduleEntry, installments)
	remaining := principal
	n := decimalx.NewFromInt64(int64(installments))
	principalPerPeriod := principal.Div(n)

	for i := range installments {
		pDue := principalPerPeriod
		if i == installments-1 {
			pDue = remaining // last installment gets the remainder
		}

		iDue := decimalx.ApplyBasisPoints(remaining, annualRateBP).Div(ppy)
		insDue := decimalx.ApplyBasisPoints(remaining, insuranceRateBP).Div(ppy)
		fDue := decimalx.ApplyBasisPoints(remaining, feeRateBP).Div(ppy)

		entries[i] = ScheduleEntry{
			InstallmentNumber: i + 1,
			DueDate:           DueDateAt(firstDueDate, periodType, i),
			PrincipalDue:      pDue,
			InterestDue:       iDue,
			InsuranceDue:      insDue,
			FeesDue:           fDue,
			TotalDue:          pDue.Add(iDue).Add(insDue).Add(fDue),
		}

		remaining = remaining.Sub(pDue)
	}

	return entries
}

// GenerateScheduleFromProduct creates a schedule using loan product parameters.
func GenerateScheduleFromProduct(
	principal decimalx.Decimal,
	annualInterestRateBP int64,
	insuranceFeePercentBP int64,
	processingFeePercentBP int64,
	interestMethod int32, // 1=FLAT, 2=REDUCING_BALANCE, 3=COMPOUND
	installments int32,
	firstDueDate time.Time,
	periodType int32,
) []ScheduleEntry {
	periodsPerYear := PeriodsPerYear(periodType)

	if interestMethod == interestMethodReducingBalance {
		return GenerateReducingBalanceSchedule(
			principal, annualInterestRateBP, insuranceFeePercentBP, processingFeePercentBP,
			installments, firstDueDate, periodType,
		)
	}

	// FLAT (default) and COMPOUND collect their interest in equal parts.
	totalInterest := FlatRateInterest(principal, annualInterestRateBP, installments, periodsPerYear)
	if interestMethod == interestMethodCompound {
		totalInterest = CompoundInterest(principal, annualInterestRateBP, installments, periodsPerYear)
	}
	totalInsurance := FlatRateInterest(principal, insuranceFeePercentBP, installments, periodsPerYear)
	totalFees := FlatRateInterest(principal, processingFeePercentBP, installments, periodsPerYear)
	return GenerateFlatSchedule(
		principal,
		totalInterest,
		totalInsurance,
		totalFees,
		installments,
		firstDueDate,
		periodType,
	)
}

// DueDateAt is the due date of the installment n periods after first.
// Monthly and quarterly dates are counted from the first due date and held
// to the last day of a shorter month, so a loan first due on 31 January is
// next due on 28 or 29 February and then on 31 March, never drifting to the
// 3rd of the month.
func DueDateAt(first time.Time, periodType int32, n int32) time.Time {
	switch periodType {
	case periodTypeDaily:
		return first.AddDate(0, 0, int(n))
	case periodTypeWeekly:
		return first.AddDate(0, 0, int(n)*daysPerWeek)
	case periodTypeBiweekly:
		return first.AddDate(0, 0, int(n)*daysPerBiweek)
	case periodTypeMonthly:
		return addMonthsClamped(first, int(n))
	case periodTypeQuarterly:
		return addMonthsClamped(first, int(n)*monthsPerQuarter)
	default:
		return first.AddDate(0, 0, int(n)*daysPerWeek)
	}
}

// addMonthsClamped adds months to t, keeping the day of the month unless the
// target month is shorter, in which case it is the target month's last day.
func addMonthsClamped(t time.Time, months int) time.Time {
	year, month, day := t.Date()
	firstOfTarget := time.Date(year, month+time.Month(months), 1,
		t.Hour(), t.Minute(), t.Second(), t.Nanosecond(), t.Location())
	lastDay := firstOfTarget.AddDate(0, 1, -1).Day()
	if day > lastDay {
		day = lastDay
	}
	return firstOfTarget.AddDate(0, 0, day-1)
}
