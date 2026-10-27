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
	"testing"

	"buf.build/gen/go/antinvestor/payment/connectrpc/go/v2/v1/paymentv1connect"
	paymentv1 "buf.build/gen/go/antinvestor/payment/protocolbuffers/go/v1"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/assert"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
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
	contacts := NewProfilePayoutChecker(
		mapResolver{profiles: map[string]string{"client-b": "profile-b"}},
		payoutProfiles{profile: &profilev1.ProfileObject{Id: "profile-b", Contacts: []*profilev1.ContactObject{
			{Id: "contact-b", Type: profilev1.ContactType_MSISDN, Verified: true},
		}}},
	)
	prompts := &promptRecorder{}
	b := NewCollectionBusiness(t.Context(), &stubLoanAccountRepo{account: loan}, &stubLoanBalanceRepo{}, nil,
		WithReadScope(agentScope()), WithPayoutDestinationChecker(contacts), WithPaymentClient(prompts))

	req := func() *loansv1.InitiateCollectionRequest {
		return &loansv1.InitiateCollectionRequest{
			LoanAccountId:    "loan-1",
			ContactId:        "contact-b",
			IdempotencyKey:   "k-1",
			CollectionAmount: &commonv1.Money{CurrencyCode: "KES", Units: 500},
		}
	}

	resp, err := b.Initiate(claimsContext(t, "profile-agent"), req())
	require.NoError(t, err)
	require.Equal(t, collectionPromptID("loan-1", "k-1"), resp.GetPaymentPromptId())
	require.Len(t, prompts.sent, 1)

	_, err = b.Initiate(claimsContext(t, "profile-borrower"), req())
	require.ErrorIs(t, err, ErrNotServingClient, "a borrower cannot raise prompts to an arbitrary phone")

	_, err = b.Initiate(claimsContext(t, "profile-stranger"), req())
	require.ErrorIs(t, err, ErrNotServingClient)

	// A raw number is refused; a contact id not on the borrower's profile
	// is refused.
	raw := req()
	raw.ContactId = ""
	raw.PhoneNumber = "+254700000001" //nolint:staticcheck // the deprecated field is what is refused
	_, err = b.Initiate(claimsContext(t, "profile-agent"), raw)
	require.ErrorIs(t, err, ErrCollectionRawContactRefused)

	stranger := req()
	stranger.ContactId = "contact-of-someone-else"
	_, err = b.Initiate(claimsContext(t, "profile-agent"), stranger)
	require.ErrorIs(t, err, ErrPayoutDestinationNotClient)

	wrongCurrency := req()
	wrongCurrency.CollectionAmount = &commonv1.Money{CurrencyCode: "UGX", Units: 500}
	_, err = b.Initiate(claimsContext(t, "profile-agent"), wrongCurrency)
	require.ErrorIs(t, err, ErrRepaymentCurrencyMismatch)
}

// promptRecorder stands in for the payment service.
type promptRecorder struct {
	paymentv1connect.PaymentServiceClient

	sent []*paymentv1.InitiatePromptRequest
}

func (p *promptRecorder) InitiatePrompt(
	_ context.Context,
	req *paymentv1.InitiatePromptRequest,
) (*paymentv1.InitiatePromptResponse, error) {
	p.sent = append(p.sent, req)
	return &paymentv1.InitiatePromptResponse{}, nil
}

// A collection asks the borrower to pay from their own verified mobile
// number, named by contact id; the prompt carries the loan and product the
// rail matches the money to, and the same request never prompts twice.
func TestCollectionInitiate_RaisesAPromptOnTheBorrowersOwnContact(t *testing.T) {
	loan := &loansmodels.LoanAccount{
		ClientID:     "client-b",
		ProductID:    "prod-1",
		CurrencyCode: "KES",
		Status:       int32(loansv1.LoanStatus_LOAN_STATUS_DEFAULT),
	}
	loan.ID = "loan-1"
	contacts := NewProfilePayoutChecker(
		mapResolver{profiles: map[string]string{"client-b": "profile-b"}},
		payoutProfiles{profile: &profilev1.ProfileObject{Id: "profile-b", Contacts: []*profilev1.ContactObject{
			{Id: "contact-email", Type: profilev1.ContactType_EMAIL, Verified: true},
			{Id: "contact-b", Type: profilev1.ContactType_MSISDN, Verified: true},
		}}},
	)
	prompts := &promptRecorder{}
	b := NewCollectionBusiness(t.Context(), &stubLoanAccountRepo{account: loan}, &stubLoanBalanceRepo{}, nil,
		WithReadScope(agentScope()), WithPayoutDestinationChecker(contacts), WithPaymentClient(prompts))

	req := &loansv1.InitiateCollectionRequest{
		LoanAccountId:    "loan-1",
		IdempotencyKey:   "k-2",
		CollectionAmount: &commonv1.Money{CurrencyCode: "KES", Units: 500},
	}
	first, err := b.Initiate(claimsContext(t, "profile-agent"), req)
	require.NoError(t, err)
	again, err := b.Initiate(claimsContext(t, "profile-agent"), req)
	require.NoError(t, err)
	assert.Equal(t, first.GetPaymentPromptId(), again.GetPaymentPromptId())
	assert.LessOrEqual(t, len(first.GetPaymentPromptId()), 40)

	require.Len(t, prompts.sent, 2)
	sent := prompts.sent[0]
	assert.Equal(t, first.GetPaymentPromptId(), sent.GetId(), "the payment service dedupes on this id")
	assert.Equal(t, "profile-b", sent.GetSource().GetProfileId())
	assert.Equal(t, "contact-b", sent.GetSource().GetContactId(), "their first verified mobile, by id")
	assert.Equal(t, int64(500), sent.GetAmount().GetUnits())
	extra := sent.GetExtra().AsMap()
	assert.Equal(t, "prod-1", extra["product_id"])
	assert.Equal(t, "loan-1", extra["loan_account_id"])
}

func TestCollectionInitiate_RefusedWithoutPaymentPrompts(t *testing.T) {
	loan := &loansmodels.LoanAccount{ClientID: "client-b", CurrencyCode: "KES",
		Status: int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE)}
	loan.ID = "loan-1"
	b := NewCollectionBusiness(t.Context(), &stubLoanAccountRepo{account: loan}, &stubLoanBalanceRepo{}, nil,
		WithReadScope(agentScope()))
	_, err := b.Initiate(claimsContext(t, "profile-agent"), &loansv1.InitiateCollectionRequest{
		LoanAccountId:    "loan-1",
		IdempotencyKey:   "k-3",
		CollectionAmount: &commonv1.Money{CurrencyCode: "KES", Units: 500},
	})
	require.ErrorIs(t, err, ErrCollectionPromptUnavailable)
}

// A loan opened from a request that named no payout contact pays out to the
// borrower's first verified mobile number, by id; without one it has none.
func TestLoanAccountDefaultsItsPayoutContact(t *testing.T) {
	contacts := NewProfilePayoutChecker(
		mapResolver{profiles: map[string]string{"client-b": "profile-b"}},
		payoutProfiles{profile: &profilev1.ProfileObject{Id: "profile-b", Contacts: []*profilev1.ContactObject{
			{Id: "contact-unverified", Type: profilev1.ContactType_MSISDN},
			{Id: "contact-b", Type: profilev1.ContactType_MSISDN, Verified: true},
		}}},
	)
	b := &loanAccountBusiness{contacts: contacts}
	logger := util.Log(t.Context())
	assert.Equal(t, "contact-b", b.defaultPayoutContact(t.Context(), logger, "client-b"))
	assert.Empty(t, b.defaultPayoutContact(t.Context(), logger, "client-unknown"))
	assert.Empty(t, (&loanAccountBusiness{}).defaultPayoutContact(t.Context(), logger, "client-b"))
}
