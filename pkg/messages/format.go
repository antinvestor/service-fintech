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

package messages

import (
	"strings"
	"time"

	"github.com/pitabwire/util/decimalx"
	"github.com/pitabwire/util/moneyx"
)

// FormatAmount renders a minor-unit amount for a human in the currency's
// ISO-4217 decimals with thousands grouping: 1500000 KES -> "15,000.00",
// 1500000 UGX -> "1,500,000". Templates never do this themselves.
func FormatAmount(currency string, minor int64) string {
	decimals := moneyx.Decimals(currency)
	text := decimalx.FromMinorUnits(minor, decimals).String()

	sign := ""
	if strings.HasPrefix(text, "-") {
		sign, text = "-", text[1:]
	}
	whole, frac, hasFrac := strings.Cut(text, ".")
	want := int(decimals)
	if want > 0 {
		if !hasFrac {
			frac = ""
		}
		for len(frac) < want {
			frac += "0"
		}
	}

	var b strings.Builder
	for i, r := range whole {
		if i > 0 && (len(whole)-i)%3 == 0 {
			b.WriteByte(',')
		}
		b.WriteRune(r)
	}
	out := sign + b.String()
	if want > 0 {
		out += "." + frac
	}
	return out
}

// FormatDate renders a date the way borrowers read it: "02 Jan 2026".
func FormatDate(t *time.Time) string {
	if t == nil || t.IsZero() {
		return ""
	}
	return t.Format("02 Jan 2006")
}
