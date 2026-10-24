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

package payout_test

import (
	"testing"

	"github.com/antinvestor/service-fintech/pkg/payout"
)

func TestContactMatchesDestination(t *testing.T) {
	cases := []struct {
		contact, destination string
		want                 bool
	}{
		{"+256701000111", "+256701000111", true},
		{"+256701000111", "0701000111", true},
		{"+256701000111", "256 701 000 111", true},
		{"+256701000111", "0701000112", false},
		{"+256701000111", "000111", false},
		{"grace@example.com", "GRACE@example.com", true},
		{"grace@example.com", "+256701000111", false},
		{"", "0701000111", false},
	}
	for _, tc := range cases {
		if got := payout.ContactMatchesDestination(tc.contact, tc.destination); got != tc.want {
			t.Errorf("ContactMatchesDestination(%q, %q) = %v, want %v", tc.contact, tc.destination, got, tc.want)
		}
	}
}
