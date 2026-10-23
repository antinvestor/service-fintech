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

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/security"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
)

func ctxWithProfile(profileID string, roles ...string) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:         "tenant-1",
		PartitionID:      "partition-1",
		Roles:            roles,
		RegisteredClaims: jwt.RegisteredClaims{Subject: profileID},
	}
	return claims.ClaimsToContext(context.Background())
}

func submittedRequestBy(submitter string) *loansmodels.LoanRequest {
	lr := &loansmodels.LoanRequest{
		ClientID:          "client-1",
		ProductID:         "",
		Status:            int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED),
		RequestedAmount:   50_000,
		RequestedTermDays: 30,
		CurrencyCode:      "KES",
		SubmittedBy:       submitter,
	}
	lr.GenID(context.Background())
	return lr
}

// The field agent who submitted an application cannot approve or reject it.
func TestDecisions_SubmitterCannotDecide(t *testing.T) {
	lr := submittedRequestBy("agent-profile")
	repo := &stubLoanRequestRepo{request: lr}
	b := buildLRBusiness(repo, &stubLoanProductRepo{}, nil, false)

	_, err := b.Approve(ctxWithProfile("agent-profile", "operator"), lr.GetID())
	require.ErrorIs(t, err, ErrLoanRequestSelfDecision)
	assert.Equal(t, int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED), repo.request.Status)

	_, err = b.Reject(ctxWithProfile("agent-profile", "operator"), lr.GetID(), "no")
	require.ErrorIs(t, err, ErrLoanRequestSelfDecision)

	approved, err := b.Approve(ctxWithProfile("supervisor-profile", "operator"), lr.GetID())
	require.NoError(t, err)
	assert.Equal(t, loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED, approved.GetStatus())
	assert.Equal(t, "supervisor-profile", repo.request.DecidedBy)
}

// A decision is a conditional write: when the status moved underneath the
// decider, the call fails instead of overwriting the other decision.
func TestDecisions_ConflictWhenStatusMoved(t *testing.T) {
	lr := submittedRequestBy("agent-profile")
	repo := &stubLoanRequestRepo{request: lr}
	b := buildLRBusiness(repo, &stubLoanProductRepo{}, nil, false)

	// Reject lands first.
	_, err := b.Reject(ctxWithProfile("reviewer-a", "operator"), lr.GetID(), "insufficient income")
	require.NoError(t, err)
	assert.Equal(t, int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_REJECTED), repo.request.Status)

	// A stale approver holding a SUBMITTED copy is refused by the claim.
	repo.request.Status = int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED)
	stale := &stubLoanRequestRepo{request: lr}
	stale.request = &loansmodels.LoanRequest{}
	*stale.request = *lr
	// Simulate the race: the stored row is REJECTED while the read copy says SUBMITTED.
	racing := &racingRequestRepo{stubLoanRequestRepo: stubLoanRequestRepo{request: lr}}
	b2 := buildLRBusiness(racing, &stubLoanProductRepo{}, nil, false)
	_, err = b2.Approve(ctxWithProfile("reviewer-b", "operator"), lr.GetID())
	require.ErrorIs(t, err, ErrLoanRequestDecisionConflict)
}

// racingRequestRepo serves a SUBMITTED copy on read but refuses every claim,
// as the database does when another decision landed first.
type racingRequestRepo struct {
	stubLoanRequestRepo
}

func (r *racingRequestRepo) ClaimStatus(context.Context, string, []int32, int32, map[string]any) (bool, error) {
	return false, nil
}

type fixedClientResolver struct{ clientID string }

func (f fixedClientResolver) ResolveByProfileID(context.Context, string) (string, error) {
	return f.clientID, nil
}

// A client caller cannot steer verification or the payout destination
// through request properties; staff keep those keys.
func TestSave_ReservedPropertiesStrippedForClients(t *testing.T) {
	repo := &stubLoanRequestRepo{err: ErrLoanRequestNotFound}
	b := buildLRBusiness(repo, &stubLoanProductRepo{}, nil, false)
	b.scope = NewReadScope(fixedClientResolver{clientID: "client-1"}, "operator")

	payload := func() *loansv1.LoanRequestObject {
		props, _ := (&data.JSONMap{
			"data_verification_confirmed": true,
			"payment_account_ref":         "+254700000999",
			"purpose_detail":              "stock",
		}).ToProtoStruct(), error(nil)
		return &loansv1.LoanRequestObject{
			ClientId:          "client-1",
			Status:            loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_DRAFT,
			RequestedAmount:   loansmodels.MinorUnitsToMoney(50_000, "KES"),
			RequestedTermDays: 30,
			CurrencyCode:      "KES",
			Properties:        props,
		}
	}

	asClient, err := b.Save(ctxWithProfile("borrower-profile", "member"), payload())
	require.NoError(t, err)
	clientProps := asClient.GetProperties().AsMap()
	assert.NotContains(t, clientProps, "data_verification_confirmed")
	assert.NotContains(t, clientProps, "payment_account_ref")
	assert.Equal(t, "stock", clientProps["purpose_detail"])

	asStaff, err := b.Save(ctxWithProfile("officer-profile", "operator"), payload())
	require.NoError(t, err)
	staffProps := asStaff.GetProperties().AsMap()
	assert.Equal(t, true, staffProps["data_verification_confirmed"])
	assert.Equal(t, "+254700000999", staffProps["payment_account_ref"])
}

// Only weekly, biweekly and monthly schedules exist; anything else is refused
// rather than silently billed as monthly.
func TestFrequencyToPeriodTypeRefusesUnsupported(t *testing.T) {
	for _, freq := range []loansv1.RepaymentFrequency{
		loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_DAILY,
		loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_QUARTERLY,
		loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_UNSPECIFIED,
	} {
		_, err := frequencyToPeriodType(freq)
		require.ErrorIs(t, err, ErrUnsupportedRepaymentFrequency, freq.String())
	}
	for _, freq := range []loansv1.RepaymentFrequency{
		loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_WEEKLY,
		loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_BIWEEKLY,
		loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_MONTHLY,
	} {
		_, err := frequencyToPeriodType(freq)
		require.NoError(t, err, freq.String())
	}
}

func TestContactMatchesDestination(t *testing.T) {
	assert.True(
		t,
		contactMatchesDestination("+254700000001", "0700000001"),
		"national form against the international contact",
	)
	assert.True(t, contactMatchesDestination("254700000001", "+254 700 000 001"), "same number, different punctuation")
	assert.True(t, contactMatchesDestination("Amina@Example.com", "amina@example.com"))
	assert.False(t, contactMatchesDestination("+254700000001", "+254700000002"))
	assert.False(t, contactMatchesDestination("+254700000001", "+255700000001"), "same national number, other country")
	assert.False(t, contactMatchesDestination("0700000001", "0700000001999"), "no suffix matching across lengths")
	assert.False(t, contactMatchesDestination("amina@example.com", "0700000001"), "kinds never cross")
	assert.False(t, contactMatchesDestination("+254700000001", "x@example.com"))
	assert.False(t, contactMatchesDestination("12345", "12345678"))
	assert.False(t, contactMatchesDestination("", "+254700000001"))
}
