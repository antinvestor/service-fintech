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
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
)

func collectionFor(t *testing.T, currency string) (CollectionBusiness, *promptRecorder) {
	t.Helper()
	loan := &loansmodels.LoanAccount{ClientID: "client-b", CurrencyCode: currency,
		Status: int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE)}
	loan.ID = "loan-1"
	contacts := NewProfilePayoutChecker(
		mapResolver{profiles: map[string]string{"client-b": "profile-b"}},
		payoutProfiles{profile: &profilev1.ProfileObject{Id: "profile-b", Contacts: []*profilev1.ContactObject{
			{Id: "contact-b", Type: profilev1.ContactType_MSISDN, Verified: true},
		}}},
	)
	prompts := &promptRecorder{}
	// The balance stub owes 100000 minor units.
	return NewCollectionBusiness(t.Context(), &stubLoanAccountRepo{account: loan}, &stubLoanBalanceRepo{}, nil,
		WithReadScope(agentScope()), WithPayoutDestinationChecker(contacts), WithPaymentClient(prompts)), prompts
}

// The legacy decimal amount is read in the loan currency's own precision: a
// shilling of UGX, which has no minor unit, is one unit, not a hundred.
func TestCollectionLegacyAmountUsesTheCurrencysPrecision(t *testing.T) {
	b, prompts := collectionFor(t, "UGX")
	legacy := &loansv1.InitiateCollectionRequest{
		LoanAccountId: "loan-1", ContactId: "contact-b", IdempotencyKey: "k-ugx",
	}
	legacy.Amount = "1500" //nolint:staticcheck // the legacy field is what is read
	_, err := b.Initiate(claimsContext(t, "profile-agent"), legacy)
	require.NoError(t, err)
	require.Len(t, prompts.sent, 1)
	assert.Equal(t, int64(1500), prompts.sent[0].GetAmount().GetUnits())

	legacy2 := &loansv1.InitiateCollectionRequest{
		LoanAccountId: "loan-1", ContactId: "contact-b", IdempotencyKey: "k-frac",
	}
	legacy2.Amount = "1500.5" //nolint:staticcheck // the legacy field is what is read
	_, err = b.Initiate(claimsContext(t, "profile-agent"), legacy2)
	require.ErrorIs(t, err, ErrRepaymentAmountInvalid, "UGX has no fractional unit to round to")
}

// A prompt never asks for more than the loan still owes.
func TestCollectionAmountIsCappedAtWhatIsOwed(t *testing.T) {
	b, prompts := collectionFor(t, "KES")
	_, err := b.Initiate(claimsContext(t, "profile-agent"), &loansv1.InitiateCollectionRequest{
		LoanAccountId: "loan-1", ContactId: "contact-b", IdempotencyKey: "k-over",
		CollectionAmount: &commonv1.Money{CurrencyCode: "KES", Units: 5_000},
	})
	require.NoError(t, err)
	require.Len(t, prompts.sent, 1)
	assert.Equal(t, int64(1_000), prompts.sent[0].GetAmount().GetUnits(), "100000 cents owed: KES 1000")
}

func TestMinorUnitsRoundTripInTheCurrencysPrecision(t *testing.T) {
	assert.Equal(t, "1500", loansmodels.MinorUnitsToString(1500, "UGX"))
	assert.Equal(t, "12.34", loansmodels.MinorUnitsToString(1234, "KES"))
	minor, err := loansmodels.StringToMinorUnits("12.34", "KES")
	require.NoError(t, err)
	assert.Equal(t, int64(1234), minor)
	_, err = loansmodels.StringToMinorUnits("12.345", "KES")
	require.Error(t, err)

	csv, err := writeCSV([]loanExportRow{{CurrencyCode: "UGX", PrincipalAmount: 250_000}})
	require.NoError(t, err)
	assert.Contains(t, string(csv), ",250000,", "UGX amounts export without invented decimals")
}
