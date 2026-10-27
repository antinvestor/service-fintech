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

	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
)

type membershipIdentity struct {
	identityv1connect.IdentityServiceClient
	membership *identityv1.MembershipObject
}

func (m membershipIdentity) MembershipGet(
	context.Context, *identityv1.MembershipGetRequest,
) (*identityv1.MembershipGetResponse, error) {
	return &identityv1.MembershipGetResponse{Data: m.membership}, nil
}

func asCaller(t *testing.T, profileID string, roles ...string) context.Context {
	t.Helper()
	return (&security.AuthenticationClaims{
		Roles:            roles,
		RegisteredClaims: jwt.RegisteredClaims{Subject: profileID},
	}).ClaimsToContext(t.Context())
}

// A member answers only their own offer, in its own group; staff and
// services answer any.
func TestAuthorizeOfferResponse(t *testing.T) {
	b := &loanOfferBusiness{identity: membershipIdentity{
		membership: &identityv1.MembershipObject{Id: "m-1", GroupId: "g-1", ProfileId: "profile-member"},
	}}
	offer := &models.LoanOffer{MembershipID: "m-1"}

	require.NoError(t, b.authorizeOfferResponse(asCaller(t, "profile-member", "member"), "g-1", offer))
	require.Error(t, b.authorizeOfferResponse(asCaller(t, "profile-other", "member"), "g-1", offer),
		"another member cannot accept someone's offer")
	require.Error(t, b.authorizeOfferResponse(asCaller(t, "profile-member", "member"), "g-2", offer),
		"an offer of another group is not found")
	require.NoError(t, b.authorizeOfferResponse(asCaller(t, "profile-staff", "operator"), "g-1", offer))
	require.NoError(t, b.authorizeOfferResponse(
		asCaller(t, "svc", security.ConstantSystemInternalRole), "g-1", offer))
}
