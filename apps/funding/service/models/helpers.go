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
	"errors"
	"fmt"
	"regexp"
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/pitabwire/util/decimalx"
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

// rateDecimalPlaces is the precision of an interest rate on the wire: rates
// travel as a percentage string with two decimals ("12.50"), the same shape
// the savings and loans contracts use.
const rateDecimalPlaces = 2

// ErrRateInvalid is returned when an interest rate string is not a
// non-negative decimal percentage.
var ErrRateInvalid = errors.New("interest rate must be a non-negative decimal percentage such as \"12.50\"")

// ratePattern is the only shape ParseRate accepts: plain digits with an
// optional fractional part. Signs, exponents and words ("NaN", "Inf") are
// rejected before the decimal parser sees them.
var ratePattern = regexp.MustCompile(`^[0-9]+(\.[0-9]+)?$`)

// BasisPointsToString renders basis points as the percentage string callers
// exchange. For example, 1250 becomes "12.50".
func BasisPointsToString(v int64) string {
	return decimalx.FromMinorUnits(v, rateDecimalPlaces).String()
}

// ParseRate parses the wire form of an interest rate into basis points.
//
// The wire form is a decimal percentage: "12.50" is 12.5% (1250 basis
// points) and "12" is 12% (1200 basis points), exactly as the savings and
// loans contracts read the same field. Whitespace is trimmed, an empty string
// is "no minimum" (0), and more than two decimals are rounded to the nearest
// basis point.
//
// The legacy funding encoding that serialised the raw basis-point integer
// ("1250" for 12.5%) is deliberately NOT recognised: an integer-only string is
// indistinguishable from a whole-percent rate, and guessing would silently
// turn a 12% mandate into 0.12% (or a legacy 12.5% into 1250%). Clients that
// cached the legacy form must re-read the account, which now always emits the
// decimal form.
func ParseRate(s string) (int64, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, nil
	}
	if !ratePattern.MatchString(s) {
		return 0, fmt.Errorf("%w: %q", ErrRateInvalid, s)
	}
	d, err := decimalx.NewFromString(s)
	if err != nil {
		return 0, fmt.Errorf("%w: %q", ErrRateInvalid, s)
	}
	return d.ToMinorUnits(rateDecimalPlaces), nil
}

// StringToBasisPoints is the lenient form of ParseRate for callers that
// cannot surface an error: anything ParseRate rejects becomes 0.
func StringToBasisPoints(s string) int64 {
	v, err := ParseRate(s)
	if err != nil {
		return 0
	}
	return v
}
