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

	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
)

type payoutProfiles struct {
	profilev1connect.ProfileServiceClient
	profile *profilev1.ProfileObject
}

//nolint:revive,staticcheck // implements the generated profile client
func (p payoutProfiles) GetById(
	context.Context, *profilev1.GetByIdRequest,
) (*profilev1.GetByIdResponse, error) {
	return &profilev1.GetByIdResponse{Data: p.profile}, nil
}

// The payout destination is a contact id on the borrower's own profile, and
// only a verified mobile contact is payable.
func TestProfilePayoutChecker_ContactIDOnTheBorrowersProfile(t *testing.T) {
	checker := NewProfilePayoutChecker(
		mapResolver{profiles: map[string]string{"client-1": "profile-1"}},
		payoutProfiles{
			profile: &profilev1.ProfileObject{Id: "profile-1", Contacts: []*profilev1.ContactObject{
				{Id: "c-phone", Type: profilev1.ContactType_MSISDN, Verified: true},
				{Id: "c-email", Type: profilev1.ContactType_EMAIL, Verified: true},
			}},
		},
	)
	loan := func(ref string) *loansmodels.LoanAccount {
		return &loansmodels.LoanAccount{ClientID: "client-1", PaymentAccountRef: ref}
	}

	require.NoError(t, checker.Allowed(t.Context(), loan("c-phone")))
	require.ErrorIs(t, checker.Allowed(t.Context(), loan("c-email")), ErrPayoutDestinationNotClient)
	require.ErrorIs(t, checker.Allowed(t.Context(), loan("+256701000111")), ErrPayoutDestinationNotClient,
		"a raw number is never accepted as a destination")
	require.ErrorIs(t, checker.Allowed(t.Context(), loan("")), ErrLoanPaymentAccountMissing)
}
