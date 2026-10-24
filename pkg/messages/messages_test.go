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

package messages_test

import (
	"strings"
	"testing"

	"github.com/antinvestor/common/notification"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/pkg/messages"
)

// Every template must render every channel and its subject with exactly the
// variables it documents, with no placeholder left unresolved. A body that
// references an undocumented variable renders "<no value>" and fails here
// instead of in a borrower's inbox.
func TestEveryTemplateRendersWithDocumentedVariables(t *testing.T) {
	reg := messages.Registry()
	require.Positive(t, reg.Len())

	for _, tpl := range reg.All() {
		t.Run(tpl.Name, func(t *testing.T) {
			require.NoError(t, notification.ValidateName(tpl.Name))
			require.True(t, strings.HasPrefix(tpl.Name, "template."+messages.Owner+"."),
				"every fintech template lives under the fintech owner")
			require.NotEmpty(t, tpl.Variables, "a template must document its variables")

			vars := make(map[string]any, len(tpl.Variables))
			for _, v := range tpl.Variables {
				vars[v] = "<" + v + ">"
			}

			for channel := range tpl.Bodies {
				body, err := tpl.Render(channel, vars)
				require.NoError(t, err)
				require.NotContains(
					t,
					body,
					"<no value>",
					"%s %s body references an undocumented variable",
					tpl.Name,
					channel,
				)
				require.NotEmpty(t, strings.TrimSpace(body))
			}
			subject, err := tpl.RenderSubject(vars)
			require.NoError(t, err)
			require.NotContains(t, subject, "<no value>")
			require.NotEmpty(t, strings.TrimSpace(subject), "every template has a subject for channels that carry one")

			sms := tpl.Short()
			require.LessOrEqual(t, len(sms), 320, "%s SMS body should fit two segments before substitution", tpl.Name)
		})
	}
}

// The names services reference in code are all registered.
func TestReferencedNamesAreRegistered(t *testing.T) {
	reg := messages.Registry()
	for _, name := range []string{
		messages.LoanApplicationSubmitted, messages.LoanApplicationApproved, messages.LoanApplicationRejected,
		messages.LoanApplicationCancelled, messages.LoanDisbursed, messages.LoanRepaymentReceived, messages.LoanPaidOff,
		messages.LoanPaymentDue, messages.LoanPaymentOverdue, messages.LoanDelinquent, messages.LoanPenaltyApplied,
		messages.LoanPenaltyWaived, messages.LoanRestructured, messages.LoanWrittenOff, messages.LoanCollectionRequested,
		messages.AgentClientDelinquent, messages.AgentDisbursementFailed, messages.AgentCollectionRecorded,
		messages.AgentApplicationDecision,
		messages.ClientOnboarded, messages.ClientKYCVerified, messages.ClientKYCRejected, messages.ClientKYCInfoRequested,
		messages.WorkforceMemberOnboarded,
		messages.CaseVerificationRequired, messages.CaseApprovalRequired, messages.CaseApproved, messages.CaseRejected,
	} {
		require.True(t, reg.Has(name), "%s is referenced but not registered", name)
	}
}

func TestFormatAmountUsesCurrencyDecimalsAndGrouping(t *testing.T) {
	cases := []struct {
		currency string
		minor    int64
		want     string
	}{
		{"KES", 1_500_000, "15,000.00"},
		{"KES", 5, "0.05"},
		{"UGX", 1_500_000, "1,500,000"},
		{"UGX", 999, "999"},
		{"USD", -123_456, "-1,234.56"},
		{"KES", 0, "0.00"},
	}
	for _, c := range cases {
		require.Equal(t, c.want, messages.FormatAmount(c.currency, c.minor), "%s %d", c.currency, c.minor)
	}
}
