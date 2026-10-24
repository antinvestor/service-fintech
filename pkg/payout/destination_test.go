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

package payout_test

import (
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"

	"github.com/antinvestor/service-fintech/pkg/payout"
)

func TestPayableContact(t *testing.T) {
	profile := &profilev1.ProfileObject{Contacts: []*profilev1.ContactObject{
		{Id: "c-email", Type: profilev1.ContactType_EMAIL, Verified: true},
		{Id: "c-unverified", Type: profilev1.ContactType_MSISDN},
		{Id: "c-deleted", Type: profilev1.ContactType_MSISDN, Verified: true, State: commonv1.STATE_DELETED},
		{Id: "c-phone", Type: profilev1.ContactType_MSISDN, Verified: true, State: commonv1.STATE_ACTIVE},
	}}
	cases := map[string]bool{"c-email": false, "c-unverified": false, "c-deleted": false,
		"c-phone": true, "c-other": false, "": false}
	for id, want := range cases {
		if got := payout.PayableContact(profile, id) != nil; got != want {
			t.Errorf("PayableContact(%q) = %v, want %v", id, got, want)
		}
	}
	if got := payout.DefaultPayoutContactID(profile); got != "c-phone" {
		t.Errorf("DefaultPayoutContactID = %q, want c-phone", got)
	}
}
