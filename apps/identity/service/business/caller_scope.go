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
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"

	"github.com/pitabwire/frame/v2/security"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

// callerIsStaff reports whether the caller may act across the whole
// partition: an internal principal, or a holder of a platform role above
// member (admin, operator, viewer). A field agent holds the member role and
// is scoped to the clients they are responsible for.
func callerIsStaff(ctx context.Context) bool {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil || claims.IsInternalSystem() {
		return true
	}
	for _, role := range claims.GetRoles() {
		switch strings.ToLower(role) {
		case platformRoleAdmin, platformRoleOperator, platformRoleViewer:
			return true
		}
	}
	return false
}

// callerScope is what a non-staff caller may see and act on: their own
// workforce member row and the teams it belongs to.
type callerScope struct {
	member  *models.WorkforceMember
	teamIDs []string
}

// resolveCallerScope loads the caller's workforce member and teams. A caller
// with no workforce member cannot be scoped and is refused; a field agent
// must be registered as a member before they can work with clients.
func resolveCallerScope(
	ctx context.Context,
	workforceRepo repository.WorkforceMemberRepository,
	teamMembershipRepo repository.TeamMembershipRepository,
) (*callerScope, error) {
	profileID := actorFromClaims(ctx)
	if profileID == "" || workforceRepo == nil {
		return nil, ErrCallerNotWorkforceMember
	}
	member, err := workforceRepo.GetByProfileID(ctx, profileID)
	if err != nil || member == nil {
		return nil, ErrCallerNotWorkforceMember
	}
	if member.State != int32(commonv1.STATE_ACTIVE) && member.State != int32(commonv1.STATE_CREATED) {
		// A suspended or removed member keeps no scope.
		return nil, ErrCallerNotWorkforceMember
	}
	scope := &callerScope{member: member}
	if teamMembershipRepo != nil {
		teamIDs, teamErr := teamMembershipRepo.ListActiveTeamIDs(ctx, member.GetID())
		if teamErr != nil {
			return nil, teamErr
		}
		scope.teamIDs = teamIDs
	}
	return scope, nil
}

// inTeam reports whether the scope includes teamID.
func (s *callerScope) inTeam(teamID string) bool {
	if s == nil {
		return false
	}
	for _, id := range s.teamIDs {
		if id == teamID {
			return true
		}
	}
	return false
}

// clientInCallerScope reports whether a non-staff caller may act on the
// client: it is owned by one of their teams or they hold a relationship with
// it. A nil scope (staff) may act on anything.
func clientInCallerScope(
	ctx context.Context,
	client *models.Client,
	scope *callerScope,
	crRepo repository.ClientRelationshipRepository,
) bool {
	if scope == nil {
		return true
	}
	if client == nil || scope.member == nil {
		return false
	}
	if scope.inTeam(client.OwningTeamID) {
		return true
	}
	if crRepo == nil {
		return false
	}
	rel, err := crRepo.GetByClientAndMember(ctx, client.GetID(), scope.member.GetID())
	return err == nil && rel != nil &&
		(rel.State == int32(commonv1.STATE_ACTIVE) || rel.State == int32(commonv1.STATE_CREATED))
}
