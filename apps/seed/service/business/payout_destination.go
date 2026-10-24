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
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
)

// ErrNoPayoutDestination is returned when a borrower has no contact money can
// be sent to; a loan cannot be originated for them until one is registered.
var ErrNoPayoutDestination = errors.New("seed: borrower has no payout destination on their profile")

// PayoutDestinationResolver finds where a borrower's loan is paid out to.
type PayoutDestinationResolver interface {
	PayoutDestination(ctx context.Context, clientID string) (string, error)
}

// profilePayoutResolver walks client -> profile -> contacts and picks the
// borrower's phone number (verified first), which is the mobile-money
// destination the loans service will verify again before disbursing.
type profilePayoutResolver struct {
	fieldCli   fieldv1connect.FieldServiceClient
	profileCli profilev1connect.ProfileServiceClient
}

// NewProfilePayoutResolver builds the production resolver.
func NewProfilePayoutResolver(
	fieldCli fieldv1connect.FieldServiceClient,
	profileCli profilev1connect.ProfileServiceClient,
) PayoutDestinationResolver {
	return &profilePayoutResolver{fieldCli: fieldCli, profileCli: profileCli}
}

func (r *profilePayoutResolver) PayoutDestination(ctx context.Context, clientID string) (string, error) {
	if r == nil || r.fieldCli == nil || r.profileCli == nil {
		return "", ErrNoPayoutDestination
	}
	client, err := r.fieldCli.ClientGet(ctx, &fieldv1.ClientGetRequest{Id: clientID})
	if err != nil {
		return "", fmt.Errorf("client get: %w", err)
	}
	profileID := strings.TrimSpace(client.GetData().GetProfileId())
	if profileID == "" {
		return "", ErrNoPayoutDestination
	}
	profile, err := r.profileCli.GetById(ctx, &profilev1.GetByIdRequest{Id: profileID})
	if err != nil {
		return "", fmt.Errorf("profile get: %w", err)
	}
	// Only a verified, active phone is a destination: money is never sent to
	// a number nobody has confirmed belongs to the borrower.
	for _, contact := range profile.GetData().GetContacts() {
		if contact == nil || !contact.GetVerified() || !looksLikePhone(contact.GetDetail()) {
			continue
		}
		if contact.GetState() == commonv1.STATE_DELETED || contact.GetState() == commonv1.STATE_INACTIVE {
			continue
		}
		return contact.GetDetail(), nil
	}
	return "", ErrNoPayoutDestination
}

// minPhoneDigits is the shortest run of digits a usable phone number has.
const minPhoneDigits = 8

func looksLikePhone(detail string) bool {
	detail = strings.TrimSpace(detail)
	if detail == "" || strings.Contains(detail, "@") {
		return false
	}
	digits := 0
	for _, r := range detail {
		if r >= '0' && r <= '9' {
			digits++
		}
	}
	return digits >= minPhoneDigits
}
