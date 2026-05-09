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
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/pitabwire/util/decimalx"
	moneyx "github.com/pitabwire/util/moneyx"
)

const timeLayout = time.RFC3339

// decimalPrecision is the precision used by the String<->MinorUnits helpers
// below. Money conversions go via moneyx and honour ISO 4217 per currency.
const decimalPrecision = 2

// MinorUnitsToString converts an int64 minor-unit amount (e.g. cents) to a
// decimal string with two fractional digits. 123456 -> "1234.56".
func MinorUnitsToString(v int64) string {
	return decimalx.FromMinorUnits(v, decimalPrecision).String()
}

// StringToMinorUnits parses a decimal string (e.g. "1234.56") into int64 minor
// units. Uses string splitting to avoid float precision issues. Returns 0 on
// parse error.
func StringToMinorUnits(s string) int64 {
	d, err := decimalx.NewFromString(s)
	if err != nil {
		return 0
	}
	return d.ToMinorUnits(decimalPrecision)
}

// BasisPointsToString converts basis points (int64) to a percentage string.
// 1500 -> "15.00".
func BasisPointsToString(v int64) string {
	return decimalx.FromMinorUnits(v, decimalPrecision).String()
}

// StringToBasisPoints parses a percentage string into basis points.
// Uses string splitting to avoid float precision issues. "15.00" -> 1500.
func StringToBasisPoints(s string) int64 {
	d, err := decimalx.NewFromString(s)
	if err != nil {
		return 0
	}
	return d.ToMinorUnits(decimalPrecision)
}

// TimeToString converts a *time.Time to an RFC3339 string.
// Returns "" for nil.
func TimeToString(t *time.Time) string {
	if t == nil {
		return ""
	}
	return t.Format(timeLayout)
}

// StringToTime parses an RFC3339 string into *time.Time.
// Returns nil on empty or parse error.
func StringToTime(s string) *time.Time {
	if s == "" {
		return nil
	}
	t, err := time.Parse(timeLayout, s)
	if err != nil {
		return nil
	}
	return &t
}

// MinorUnitsToMoney converts minor units (e.g. cents) and a currency code to a
// *commonv1.Money proto message. Precision follows ISO 4217 via moneyx.Decimals
// (JPY=0, KWD/BHD/OMR=3, else=2).
func MinorUnitsToMoney(v int64, currencyCode string) *commonv1.Money {
	return moneyx.FromMinorUnitsByCurrency(currencyCode, v)
}

// MoneyToMinorUnits converts a *commonv1.Money to minor units (int64) and
// currency code. Precision follows ISO 4217 via moneyx.Decimals.
func MoneyToMinorUnits(m *commonv1.Money) (int64, string) {
	if m == nil {
		return 0, ""
	}
	cc := m.GetCurrencyCode()
	return moneyx.ToSmallestUnit(m, moneyx.Decimals(cc)), cc
}
