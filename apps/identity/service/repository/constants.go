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

package repository

// Shared string constants for repeated metadata keys, SQL fragments, and
// label values used across this package (extracted to satisfy goconst).
const (
	exprCoalesceCode           = "coalesce(%scode, '')"
	exprCoalesceGeoID          = "coalesce(%sgeo_id, '')"
	exprCoalesceMemberID       = "coalesce(%smember_id, '')"
	exprCoalesceName           = "coalesce(%sname, '')"
	exprCoalesceOrganizationID = "coalesce(%sorganization_id, '')"
	exprCoalesceProfileID      = "coalesce(%sprofile_id, '')"
	exprCoalesceProperties     = "coalesce(%sproperties::text, '')"

	// Columns every conditional update touches alongside its own fields.
	colModifiedAt = "modified_at"
	colModifiedBy = "modified_by"
	colVerifiedAt = "verified_at"
	colVersion    = "version"

	// Client data review columns.
	colVerificationStatus = "verification_status"
	colReviewerID         = "reviewer_id"
)
