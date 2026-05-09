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

package models

import (
	"strconv"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	moneyx "github.com/pitabwire/util/moneyx"
)

// MoneyToMinorUnits converts a *commonv1.Money to minor units (int64) and
// currency code. Precision follows ISO 4217 via moneyx.Decimals.
func MoneyToMinorUnits(m *commonv1.Money) (int64, string) {
	if m == nil {
		return 0, ""
	}
	cc := m.GetCurrencyCode()
	return moneyx.ToSmallestUnit(m, moneyx.Decimals(cc)), cc
}

// BasisPointsToString converts basis points stored as int64 to a string.
// For example, 1250 becomes "1250".
func BasisPointsToString(v int64) string {
	return strconv.FormatInt(v, 10)
}

// StringToBasisPoints converts a string to basis points (int64).
// Returns 0 on parse error.
func StringToBasisPoints(s string) int64 {
	v, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		return 0
	}
	return v
}
