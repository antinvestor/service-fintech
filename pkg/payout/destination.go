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
package payout

import (
	"strings"
	"unicode"
)

// minMSISDNDigits is the shortest number treated as a phone destination.
const minMSISDNDigits = 9

// maxCountryCodeDigits bounds how much of an international contact may be
// country code when matching a national-form destination against it.
const maxCountryCodeDigits = 3

// ContactMatchesDestination compares a profile contact with a payout
// destination of the same kind. Emails match case-insensitively, and only
// against an email contact. Phone numbers match on the full number: exactly,
// or a national form ("0701000000") against the contact's international form
// ("+256701000000") when the whole national number agrees. Digits are never
// compared across kinds or on an arbitrary suffix.
func ContactMatchesDestination(contact, destination string) bool {
	contact = strings.TrimSpace(contact)
	destination = strings.TrimSpace(destination)
	if contact == "" || destination == "" {
		return false
	}
	contactIsEmail, destinationIsEmail := strings.Contains(contact, "@"), strings.Contains(destination, "@")
	if contactIsEmail || destinationIsEmail {
		return contactIsEmail && destinationIsEmail && strings.EqualFold(contact, destination)
	}

	cd, dd := digitsOf(contact), digitsOf(destination)
	if len(cd) < minMSISDNDigits || len(dd) < minMSISDNDigits {
		return false
	}
	if cd == dd {
		return true
	}
	// National form against an international contact: "0" + national number
	// must be the whole tail of the contact after its country code.
	if strings.HasPrefix(contact, "+") && strings.HasPrefix(dd, "0") {
		national := dd[1:]
		return len(national) >= minMSISDNDigits &&
			strings.HasSuffix(cd, national) &&
			len(cd)-len(national) <= maxCountryCodeDigits
	}
	return false
}

func digitsOf(s string) string {
	var b strings.Builder
	for _, r := range s {
		if unicode.IsDigit(r) {
			b.WriteRune(r)
		}
	}
	return b.String()
}
