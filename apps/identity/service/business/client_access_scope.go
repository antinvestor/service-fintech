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
	"errors"
	"fmt"

	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
)

// AccessScope reports the clients a profile may act for. Internal service
// callers resolve the end user they name; every other caller resolves only
// themselves, so the request cannot be used to read someone else's scope.
func (b *clientBusiness) AccessScope(
	ctx context.Context,
	profileID string,
) (*fieldv1.ClientAccessScopeResponse, error) {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil || !claims.IsInternalSystem() || profileID == "" {
		profileID = actorFromClaims(ctx)
	}
	resp := &fieldv1.ClientAccessScopeResponse{}
	if profileID == "" {
		return resp, nil
	}

	client, err := b.clientRepo.GetByProfileID(ctx, profileID)
	switch {
	case err == nil && client != nil:
		resp.ClientId = client.GetID()
	case err != nil && !data.ErrorIsNoRows(err):
		return nil, fmt.Errorf("load client for profile: %w", err)
	}

	member, err := b.workforceRepo.GetByProfileID(ctx, profileID)
	if err != nil {
		if data.ErrorIsNoRows(err) {
			return resp, nil
		}
		return nil, fmt.Errorf("load workforce member for profile: %w", err)
	}
	scope, err := resolveProfileScope(ctx, member.ProfileID, b.workforceRepo, b.teamMembershipRepo)
	if err != nil {
		if errors.Is(err, ErrCallerNotWorkforceMember) {
			// Suspended or removed members keep no scope.
			return resp, nil
		}
		return nil, fmt.Errorf("resolve member scope: %w", err)
	}
	resp.MemberId = scope.member.GetID()
	served, err := b.servedClientIDs(ctx, scope)
	if err != nil {
		return nil, fmt.Errorf("list served clients: %w", err)
	}
	for _, id := range served {
		if id != "" {
			resp.ServedClientIds = append(resp.ServedClientIds, id)
		}
	}
	return resp, nil
}
