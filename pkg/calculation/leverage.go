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

import "github.com/pitabwire/util/decimalx"

// leverageDivisor scales leverage factors expressed in hundredths (100 = 1.00x).
const leverageDivisor = 100

// CalculateMaxLoanAmount computes the maximum loan amount a member is eligible for
// based on their savings balance and leverage factor.
// leverageFactor is in hundredths (e.g., 190 = 1.90x).
// savingsBalance is a Decimal amount.
// Returns the max loan amount as a Decimal.
func CalculateMaxLoanAmount(savingsBalance decimalx.Decimal, leverageFactor int64) decimalx.Decimal {
	if !savingsBalance.IsPositive() || leverageFactor <= 0 {
		return decimalx.Zero()
	}
	// maxLoan = savings * leverage / 100
	return savingsBalance.Mul(decimalx.NewFromInt64(leverageFactor)).Div(decimalx.NewFromInt64(leverageDivisor))
}

// CalculateLeverageRatio computes the effective leverage ratio.
// Returns hundredths (e.g., 190 for 1.90x).
func CalculateLeverageRatio(loanAmount, savingsBalance decimalx.Decimal) int64 {
	if !savingsBalance.IsPositive() {
		return 0
	}
	return loanAmount.Mul(decimalx.NewFromInt64(leverageDivisor)).Div(savingsBalance).Int64()
}
