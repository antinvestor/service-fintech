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

// decimalPrecision is the precision used by the String<->MinorUnits and
// basis-point helpers below. Money conversions go via moneyx and honour
// ISO 4217 per currency.
const decimalPrecision = 2

// MinorUnitsToString converts minor units (e.g. cents) stored as int64 to a decimal string.
// For example, 123456 becomes "1234.56".
func MinorUnitsToString(v int64) string {
	return decimalx.FromMinorUnits(v, decimalPrecision).String()
}

// StringToMinorUnits converts a decimal string to minor units (int64).
// Uses string splitting to avoid float precision issues.
// For example, "1234.56" becomes 123456.
func StringToMinorUnits(s string) int64 {
	d, err := decimalx.NewFromString(s)
	if err != nil {
		return 0
	}
	return d.ToMinorUnits(decimalPrecision)
}

// BasisPointsToString converts basis points stored as int64 to a percentage string.
// For example, 1250 becomes "12.50".
func BasisPointsToString(v int64) string {
	return decimalx.FromMinorUnits(v, decimalPrecision).String()
}

// StringToBasisPoints converts a percentage string to basis points (int64).
// Uses string splitting to avoid float precision issues.
// For example, "12.50" becomes 1250.
func StringToBasisPoints(s string) int64 {
	d, err := decimalx.NewFromString(s)
	if err != nil {
		return 0
	}
	return d.ToMinorUnits(decimalPrecision)
}

// TimeToString converts a *time.Time to an RFC3339 string. Returns "" if nil.
func TimeToString(t *time.Time) string {
	if t == nil {
		return ""
	}
	return t.Format(time.RFC3339)
}

// StringToTime converts an RFC3339 string to *time.Time. Returns nil on error or empty string.
func StringToTime(s string) *time.Time {
	if s == "" {
		return nil
	}
	t, err := time.Parse(time.RFC3339, s)
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
