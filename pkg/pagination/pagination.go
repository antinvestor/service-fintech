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

// Package pagination bounds the page a search caller asks for, so a caller's
// limit can never make one page read a whole table.
package pagination

import "strconv"

const (
	// DefaultLimit is the page size when a caller names none.
	DefaultLimit = 50
	// MaxLimit is the largest page one search returns.
	MaxLimit = 200
)

// Limit is the caller's page size bounded to 1..MaxLimit; none is
// DefaultLimit.
func Limit(limit int32) int {
	switch {
	case limit <= 0:
		return DefaultLimit
	case limit > MaxLimit:
		return MaxLimit
	default:
		return int(limit)
	}
}

// Page is the cursor's page number; one that is unparsable or negative is
// the first page.
func Page(page string) int {
	n, err := strconv.Atoi(page)
	if err != nil || n < 0 {
		return 0
	}
	return n
}
