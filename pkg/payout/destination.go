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

// Package payout holds the rules every service applies before money leaves
// the platform through the payment rail.
//
// A payout destination is always one of the recipient profile's contacts,
// named by its contact id. Fintech never reads, compares or stores the phone
// number or email itself: the profile service owns contacts.
package payout

import (
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
)

// PayableContact returns the profile's contact with contactID when money may
// be sent to it: active, verified and a mobile number. It returns nil
// otherwise.
func PayableContact(profile *profilev1.ProfileObject, contactID string) *profilev1.ContactObject {
	contactID = strings.TrimSpace(contactID)
	if contactID == "" {
		return nil
	}
	for _, contact := range profile.GetContacts() {
		if contact.GetId() == contactID && payable(contact) {
			return contact
		}
	}
	return nil
}

// DefaultPayoutContactID returns the id of the profile's first payable
// contact, or "" when it has none.
func DefaultPayoutContactID(profile *profilev1.ProfileObject) string {
	for _, contact := range profile.GetContacts() {
		if payable(contact) {
			return contact.GetId()
		}
	}
	return ""
}

func payable(contact *profilev1.ContactObject) bool {
	return contact != nil && contact.GetId() != "" && contact.GetVerified() &&
		contact.GetType() == profilev1.ContactType_MSISDN &&
		contact.GetState() != commonv1.STATE_DELETED && contact.GetState() != commonv1.STATE_INACTIVE
}
