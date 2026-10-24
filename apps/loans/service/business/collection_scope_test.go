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
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
)

func TestCollectionInitiate_OnlyStaffOrServingAgent(t *testing.T) {
	loan := &loansmodels.LoanAccount{
		ClientID:     "client-b",
		CurrencyCode: "KES",
		Status:       int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE),
	}
	loan.ID = "loan-1"
	b := NewCollectionBusiness(t.Context(), &stubLoanAccountRepo{account: loan}, &stubLoanBalanceRepo{}, nil,
		WithReadScope(agentScope()))

	req := func() *loansv1.InitiateCollectionRequest {
		return &loansv1.InitiateCollectionRequest{
			LoanAccountId:    "loan-1",
			PhoneNumber:      "+254700000001",
			IdempotencyKey:   "k-1",
			CollectionAmount: &commonv1.Money{CurrencyCode: "KES", Units: 500},
		}
	}

	resp, err := b.Initiate(claimsContext(t, "profile-agent"), req())
	require.NoError(t, err)
	require.Equal(t, "collection:loan-1:k-1", resp.GetPaymentPromptId())

	_, err = b.Initiate(claimsContext(t, "profile-borrower"), req())
	require.ErrorIs(t, err, ErrNotServingClient, "a borrower cannot raise prompts to an arbitrary phone")

	_, err = b.Initiate(claimsContext(t, "profile-stranger"), req())
	require.ErrorIs(t, err, ErrNotServingClient)

	wrongCurrency := req()
	wrongCurrency.CollectionAmount = &commonv1.Money{CurrencyCode: "UGX", Units: 500}
	_, err = b.Initiate(claimsContext(t, "profile-agent"), wrongCurrency)
	require.ErrorIs(t, err, ErrRepaymentCurrencyMismatch)
}
