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
	"context"
	"testing"

	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/assert"
)

// The partition owner, like admins, operators and viewers, acts partition
// wide; a member (field agent) is scoped.
func TestCallerIsStaffIncludesTheOwner(t *testing.T) {
	for role, want := range map[string]bool{
		"owner": true, "admin": true, "operator": true, "viewer": true, "member": false,
	} {
		ctx := (&security.AuthenticationClaims{Roles: []string{role}}).ClaimsToContext(context.Background())
		assert.Equal(t, want, callerIsStaff(ctx), role)
	}
}
