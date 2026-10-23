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

package models_test

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
)

// TestParseRate_ReadsTheDecimalPercentageForm pins the wire semantics shared
// with savings and loans: the string is a percentage with up to two decimals,
// never a raw basis-point integer.
func TestParseRate_ReadsTheDecimalPercentageForm(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name    string
		in      string
		want    int64
		wantErr bool
	}{
		{name: "two decimals", in: "12.50", want: 1250},
		{name: "one decimal", in: "12.5", want: 1250},
		{name: "whole percent is a percent, not basis points", in: "12", want: 1200},
		{name: "zero", in: "0", want: 0},
		{name: "zero with decimals", in: "0.00", want: 0},
		{name: "empty means no minimum", in: "", want: 0},
		{name: "surrounding whitespace is ignored", in: " 7.25 ", want: 725},
		{name: "sub-basis-point precision rounds to the nearest basis point (down)", in: "12.501", want: 1250},
		{name: "sub-basis-point precision rounds to the nearest basis point (up)", in: "12.499", want: 1250},
		// The legacy funding encoding ("1250" meaning 12.50%) is not
		// recognised: it is read as the decimal it claims to be, 1250.00%.
		{name: "legacy raw basis points are read as a percentage", in: "1250", want: 125000},
		{name: "letters", in: "abc", wantErr: true},
		{name: "negative", in: "-1", wantErr: true},
		{name: "explicit plus sign", in: "+12", wantErr: true},
		{name: "exponent", in: "1e2", wantErr: true},
		{name: "not a number", in: "NaN", wantErr: true},
		{name: "infinity", in: "Inf", wantErr: true},
		{name: "trailing dot", in: "12.", wantErr: true},
		{name: "percent sign", in: "12%", wantErr: true},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			got, err := models.ParseRate(tc.in)
			if tc.wantErr {
				require.ErrorIs(t, err, models.ErrRateInvalid, "input %q must be rejected", tc.in)
				return
			}
			require.NoError(t, err)
			require.Equal(t, tc.want, got, "input %q", tc.in)
		})
	}
}

// TestStringToBasisPoints_IsLenient documents the fallback used where an
// error cannot be surfaced: invalid input reads as "no minimum".
func TestStringToBasisPoints_IsLenient(t *testing.T) {
	t.Parallel()

	require.Equal(t, int64(1250), models.StringToBasisPoints("12.50"))
	require.Equal(t, int64(1200), models.StringToBasisPoints("12"))
	require.Equal(t, int64(0), models.StringToBasisPoints("garbage"))
	require.Equal(t, int64(0), models.StringToBasisPoints("-5"))
}

// TestBasisPointsToString_EmitsTheDecimalForm proves funding now serialises
// the same shape it parses, so a read-modify-write round trip is lossless.
func TestBasisPointsToString_EmitsTheDecimalForm(t *testing.T) {
	t.Parallel()

	cases := []struct {
		bp   int64
		want string
	}{
		{bp: 1250, want: "12.50"},
		{bp: 1200, want: "12.00"},
		{bp: 0, want: "0.00"},
		{bp: 5, want: "0.05"},
		{bp: 125000, want: "1250.00"},
	}
	for _, tc := range cases {
		got := models.BasisPointsToString(tc.bp)
		require.Equal(t, tc.want, got, "basis points %d", tc.bp)

		back, err := models.ParseRate(got)
		require.NoError(t, err)
		require.Equal(t, tc.bp, back, "round trip of %d basis points", tc.bp)
	}
}
