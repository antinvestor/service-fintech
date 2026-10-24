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
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/pkg/payout"
)

// profilePayoutChecker allows a disbursement only when the loan's payment
// account ref is one of the borrower's own contacts (a phone number for
// mobile money, an email for a payment link). The borrower is found through
// the client's profile.
type profilePayoutChecker struct {
	resolver ClientProfileResolver
	profiles profilev1connect.ProfileServiceClient
}

// NewProfilePayoutChecker builds the production checker.
func NewProfilePayoutChecker(
	resolver ClientProfileResolver,
	profiles profilev1connect.ProfileServiceClient,
) PayoutDestinationChecker {
	return &profilePayoutChecker{resolver: resolver, profiles: profiles}
}

func (c *profilePayoutChecker) Allowed(ctx context.Context, la *models.LoanAccount) error {
	if la == nil || strings.TrimSpace(la.PaymentAccountRef) == "" {
		return ErrLoanPaymentAccountMissing
	}
	if c == nil || c.resolver == nil || c.profiles == nil {
		return ErrPayoutDestinationUnverifiable
	}
	profileID, err := c.resolver.ProfileIDForClient(ctx, la.ClientID)
	if err != nil {
		util.Log(ctx).WithError(err).WithField("client_id", la.ClientID).
			Warn("payout destination check: client profile could not be resolved")
		return ErrPayoutDestinationUnverifiable
	}
	resp, err := c.profiles.GetById(ctx, &profilev1.GetByIdRequest{Id: profileID})
	if err != nil {
		util.Log(ctx).WithError(err).WithField("profile_id", profileID).
			Warn("payout destination check: profile could not be loaded")
		return ErrPayoutDestinationUnverifiable
	}
	for _, contact := range resp.GetData().GetContacts() {
		if contact == nil || contact.GetState() == commonv1.STATE_DELETED ||
			contact.GetState() == commonv1.STATE_INACTIVE {
			continue
		}
		if contactMatchesDestination(contact.GetDetail(), la.PaymentAccountRef) {
			return nil
		}
	}
	util.Log(ctx).WithFields(map[string]any{
		"client_id":  la.ClientID,
		"profile_id": profileID,
	}).Error("payout destination is not one of the borrower's contacts")
	return ErrPayoutDestinationNotClient
}

// contactMatchesDestination applies the platform payout destination rule.
func contactMatchesDestination(contact, destination string) bool {
	return payout.ContactMatchesDestination(contact, destination)
}
