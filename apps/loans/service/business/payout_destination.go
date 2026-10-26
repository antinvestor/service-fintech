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

	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/pkg/payout"
)

// profilePayoutChecker allows a disbursement only when the loan's payment
// account ref is the contact id of one of the borrower's own payable
// contacts (active, verified mobile number). The borrower is found through
// the client's profile; the number itself is never read here.
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
	return c.ContactOfClient(ctx, la.ClientID, la.PaymentAccountRef)
}

// ContactOfClient checks contactID against the client's own profile.
func (c *profilePayoutChecker) ContactOfClient(ctx context.Context, clientID, contactID string) error {
	profile, err := c.profileOf(ctx, clientID)
	if err != nil {
		return err
	}
	if payout.PayableContact(profile, contactID) != nil {
		return nil
	}
	util.Log(ctx).WithFields(map[string]any{
		"client_id":  clientID,
		"profile_id": profile.GetId(),
	}).Error("contact is not one of the borrower's payable contacts")
	return ErrPayoutDestinationNotClient
}

// CollectionContact picks the borrower's own contact a payment prompt goes
// to. The contact is named by id; its number is never read here.
func (c *profilePayoutChecker) CollectionContact(
	ctx context.Context,
	clientID, contactID string,
) (string, string, error) {
	profile, err := c.profileOf(ctx, clientID)
	if err != nil {
		return "", "", err
	}
	if contactID == "" {
		contactID = payout.DefaultPayoutContactID(profile)
		if contactID == "" {
			return "", "", ErrCollectionNoPayingContact
		}
		return profile.GetId(), contactID, nil
	}
	if payout.PayableContact(profile, contactID) == nil {
		return "", "", ErrPayoutDestinationNotClient
	}
	return profile.GetId(), contactID, nil
}

// profileOf loads the client's profile.
func (c *profilePayoutChecker) profileOf(ctx context.Context, clientID string) (*profilev1.ProfileObject, error) {
	if c == nil || c.resolver == nil || c.profiles == nil {
		return nil, ErrPayoutDestinationUnverifiable
	}
	profileID, err := c.resolver.ProfileIDForClient(ctx, clientID)
	if err != nil {
		util.Log(ctx).WithError(err).WithField("client_id", clientID).
			Warn("payout destination check: client profile could not be resolved")
		return nil, ErrPayoutDestinationUnverifiable
	}
	resp, err := c.profiles.GetById(ctx, &profilev1.GetByIdRequest{Id: profileID})
	if err != nil {
		util.Log(ctx).WithError(err).WithField("profile_id", profileID).
			Warn("payout destination check: profile could not be loaded")
		return nil, ErrPayoutDestinationUnverifiable
	}
	return resp.GetData(), nil
}
