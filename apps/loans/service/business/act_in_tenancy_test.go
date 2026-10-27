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

	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
)

// A job's per-item context names the record's tenancy where peer clients
// read it (X-Tenant-Id), as well as in the claims that scope the database.
func TestActInTenancyCarriesTheRecordsTenancyToPeerCalls(t *testing.T) {
	ctx := actInTenancy(t.Context(), "service_loans", "tenant-a", "partition-a")

	tenancy := util.GetTenancy(ctx)
	require.NotNil(t, tenancy, "peer calls would name no tenant")
	require.Equal(t, "tenant-a", tenancy.GetTenantID())
	require.Equal(t, "partition-a", tenancy.GetPartitionID())

	claims := security.ClaimsFromContext(ctx)
	require.NotNil(t, claims)
	require.True(t, claims.IsInternalSystem())
	require.Equal(t, "service_loans", claims.Subject)
	require.Equal(t, "tenant-a", claims.GetTenantID())
}
