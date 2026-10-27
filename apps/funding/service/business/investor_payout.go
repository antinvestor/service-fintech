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
	"fmt"

	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"

	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/payout"
)

var (
	// ErrInvestorPayoutUnavailable is returned when the investor's payout
	// destination cannot be looked up.
	ErrInvestorPayoutUnavailable = apperrors.NewError(apperrors.ServiceUnavailable,
		"the investor's payout contact cannot be looked up; withdrawals are paused")
	// ErrInvestorNoPayoutContact is returned when the investor has no
	// verified mobile number to be paid to.
	ErrInvestorNoPayoutContact = apperrors.NewError(apperrors.Unprocessable,
		"the investor has no verified mobile number to be paid to")
)

// InvestorPayout is where an investor's withdrawal is paid: their own
// profile, and one of its verified mobile contacts, named by id.
type InvestorPayout struct {
	ProfileID string
	ContactID string
}

// InvestorPayoutResolver finds an investor's payout destination.
type InvestorPayoutResolver interface {
	InvestorPayout(ctx context.Context, investorID string) (InvestorPayout, error)
}

type profilePayoutResolver struct {
	investors identityv1connect.IdentityServiceClient
	profiles  profilev1connect.ProfileServiceClient
}

// NewInvestorPayoutResolver builds the production resolver: the investor's
// profile from identity, its first payable contact from the profile
// service. The number itself is never read.
func NewInvestorPayoutResolver(
	investors identityv1connect.IdentityServiceClient,
	profiles profilev1connect.ProfileServiceClient,
) InvestorPayoutResolver {
	return &profilePayoutResolver{investors: investors, profiles: profiles}
}

func (r *profilePayoutResolver) InvestorPayout(ctx context.Context, investorID string) (InvestorPayout, error) {
	if r == nil || r.investors == nil || r.profiles == nil {
		return InvestorPayout{}, ErrInvestorPayoutUnavailable
	}
	investor, err := r.investors.InvestorGet(ctx, &identityv1.InvestorGetRequest{Id: investorID})
	if err != nil {
		return InvestorPayout{}, fmt.Errorf("%w: %s", ErrInvestorPayoutUnavailable, err.Error())
	}
	profileID := investor.GetData().GetProfileId()
	if profileID == "" {
		return InvestorPayout{}, ErrInvestorNoPayoutContact
	}
	profile, err := r.profiles.GetById(ctx, &profilev1.GetByIdRequest{Id: profileID})
	if err != nil {
		return InvestorPayout{}, fmt.Errorf("%w: %s", ErrInvestorPayoutUnavailable, err.Error())
	}
	contactID := payout.DefaultPayoutContactID(profile.GetData())
	if contactID == "" {
		return InvestorPayout{}, ErrInvestorNoPayoutContact
	}
	return InvestorPayout{ProfileID: profileID, ContactID: contactID}, nil
}
