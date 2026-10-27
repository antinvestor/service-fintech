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

import (
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/stretchr/testify/assert"

	"github.com/antinvestor/service-fintech/pkg/pagination"
)

// A caller's page size cannot make one search page read a whole table, and a
// negative page is the first page.
func TestSearchPageIsBounded(t *testing.T) {
	q := data.NewSearchQuery(buildSearchOptions(&commonv1.PageCursor{Limit: 1_000_000, Page: "-2"}, nil)...)
	assert.Equal(t, pagination.MaxLimit, q.Pagination.Limit)
	assert.Zero(t, q.Pagination.Offset)
}
