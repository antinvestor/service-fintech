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
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

func operationsCaller() context.Context {
	return (&security.AuthenticationClaims{
		Roles:            []string{security.ConstantSystemInternalRole},
		RegisteredClaims: jwt.RegisteredClaims{Subject: "service_operations"},
	}).ClaimsToContext(context.Background())
}

// recordingClaimLoans notes the status claims made on the loan.
type recordingClaimLoans struct {
	stubLoanAccountRepo
	from, to int32
	cleared  map[string]any
}

func (r *recordingClaimLoans) ClaimStatus(_ context.Context, _ string, from, to int32) (bool, error) {
	r.from, r.to = from, to
	return true, nil
}

func (r *recordingClaimLoans) UpdateColumns(_ context.Context, _ string, values map[string]any) (int64, error) {
	r.cleared = values
	return 1, nil
}

// A disbursement the rail failed after accepting it is marked failed and
// the loan returns to awaiting disbursement, so staff can pay it again.
func TestLateFailedDisbursementReturnsTheLoanToPending(t *testing.T) {
	disb := &loansmodels.Disbursement{LoanAccountID: "loan-1", IdempotencyKey: "key-1",
		Status: int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_COMPLETED)}
	disb.ID = "disb-1"
	disbs := &stubDisbursementRepo{findResp: disb, stored: []*loansmodels.Disbursement{disb}}
	loans := &recordingClaimLoans{}
	p := NewPayoutFailures(disbs, loans, &stubRepaymentRepo{}, &noopEventsManager{}, nil)

	applied, err := p.Apply(operationsCaller(), "disbursement:key-1", "rail failed")
	require.NoError(t, err)
	assert.True(t, applied)
	assert.Equal(t, int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_FAILED), disb.Status)
	assert.Equal(t, int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE), loans.from)
	assert.Equal(t, int32(loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT), loans.to)
	assert.Contains(t, loans.cleared, "disbursed_at")

	again, err := p.Apply(operationsCaller(), "disbursement:key-1", "rail failed")
	require.NoError(t, err)
	assert.False(t, again, "an undone disbursement is not undone twice")

	_, err = p.Apply(context.Background(), "disbursement:key-1", "x")
	require.ErrorIs(t, err, ErrPayoutOutcomeCallerNotInternal, "only a service reports outcomes")
}

// A commission payout the rail failed goes back to the team's balance.
func TestLateFailedCommissionPayoutReturnsToTheBalance(t *testing.T) {
	repo := newMemCommissions(10_000)
	tc := NewTeamCommissions(repo, memberDest(), &recordingOperationsClient{}, audit.NewWriter(nil))
	paid, err := tc.Payout(context.Background(), payoutRequest("key-00009", 4_000))
	require.NoError(t, err)
	require.Equal(t, int64(4_000), repo.paidOut)

	p := NewPayoutFailures(&stubDisbursementRepo{}, &recordingClaimLoans{}, &stubRepaymentRepo{},
		&noopEventsManager{}, tc)
	applied, err := p.Apply(operationsCaller(), "team_commission_payout:"+paid.GetId(), "rail failed")
	require.NoError(t, err)
	assert.True(t, applied)
	assert.Zero(t, repo.paidOut, "the amount is back in the balance")

	again, err := p.Apply(operationsCaller(), "team_commission_payout:"+paid.GetId(), "rail failed")
	require.NoError(t, err)
	assert.False(t, again)
}
