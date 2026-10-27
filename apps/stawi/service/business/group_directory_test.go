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
	"github.com/stretchr/testify/assert"

	stawiproduct "github.com/antinvestor/service-fintech/products/stawi"
)

// The directory asks identity for only the states and group types stawi
// runs, so enrolment pages through stawi's groups, not the whole tenant.
func TestGroupDirectorySearchAsksForStawisGroupsOnly(t *testing.T) {
	d := &identityGroupDirectory{product: stawiproduct.ProductConfig{GroupTypes: []int32{2, 5, 6}}}

	req := d.searchRequest(400, commonv1.STATE_ACTIVE)
	assert.Equal(t, []commonv1.STATE{commonv1.STATE_ACTIVE}, req.GetStates())
	assert.Equal(t, []int32{2, 5, 6}, req.GetGroupTypes())
	assert.Equal(t, groupSearchPage, req.GetCursor().GetLimit())
	assert.Equal(t, "400", req.GetCursor().GetPage())
}
