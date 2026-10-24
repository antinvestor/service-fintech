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

package business

import commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"

const (
	// defaultPageSize is used when the caller does not ask for a page size.
	defaultPageSize = 50
	// maxPageSize bounds a caller-requested page so one search cannot stream
	// an unbounded slice of the table in a single response.
	maxPageSize = 500
)

// pageSizeFor resolves the caller's requested page size against the service
// bounds. Search RPCs return exactly one page: the caller drives further pages
// by re-issuing the request with the last id it saw as cursor.page.
func pageSizeFor(c *commonv1.PageCursor) int {
	limit := int(c.GetLimit())
	if limit <= 0 {
		return defaultPageSize
	}
	if limit > maxPageSize {
		return maxPageSize
	}
	return limit
}
