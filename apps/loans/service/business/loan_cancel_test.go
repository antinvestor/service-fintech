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

	"buf.build/gen/go/antinvestor/funding/connectrpc/go/v2/funding/v1/fundingv1connect"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
)

type fakeFundingRelease struct {
	fundingv1connect.FundingServiceClient
	released []string
}

func (f *fakeFundingRelease) FundingRelease(
	_ context.Context,
	req *fundingv1.FundingReleaseRequest,
) (*fundingv1.FundingReleaseResponse, error) {
	f.released = append(f.released, req.GetLoanRequestId())
	return &fundingv1.FundingReleaseResponse{}, nil
}

func cancellableLoan(status loansv1.LoanStatus) *loansmodels.LoanAccount {
	la := &loansmodels.LoanAccount{Status: int32(status), LoanRequestID: "lr-fallback",
		Properties: data.JSONMap{"loan_request_id": "lr-1"}}
	la.ID = "loan-1"
	return la
}

func cancelBusiness(
	la *loansmodels.LoanAccount,
	disb *stubDisbursementRepo,
	funding *fakeFundingRelease,
) *loanAccountBusiness {
	return &loanAccountBusiness{
		eventsMan:       &noopEventsManager{},
		loanAccountRepo: &stubLoanAccountRepo{account: la},
		disbRepo:        disb,
		fundingCli:      funding,
	}
}

func TestCancelClosesAnUndisbursedLoanAndReleasesItsFunding(t *testing.T) {
	funding := &fakeFundingRelease{}
	b := cancelBusiness(cancellableLoan(loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT),
		&stubDisbursementRepo{}, funding)

	got, err := b.Cancel(t.Context(), "loan-1", "borrower withdrew")
	require.NoError(t, err)
	assert.NotNil(t, got)
	assert.Equal(t, []string{"lr-1"}, funding.released)
}

func TestCancelIsRefusedOnceMoneyIsMovingOrMoved(t *testing.T) {
	for name, tc := range map[string]struct {
		status loansv1.LoanStatus
		disb   []*loansmodels.Disbursement
	}{
		"processing disbursement": {loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT, []*loansmodels.Disbursement{
			{Status: int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_PROCESSING)}}},
		"active loan": {loansv1.LoanStatus_LOAN_STATUS_ACTIVE, nil},
	} {
		t.Run(name, func(t *testing.T) {
			funding := &fakeFundingRelease{}
			b := cancelBusiness(cancellableLoan(tc.status), &stubDisbursementRepo{stored: tc.disb}, funding)
			_, err := b.Cancel(t.Context(), "loan-1", "too late")
			require.ErrorIs(t, err, ErrLoanCancelDisbursed)
			assert.Empty(t, funding.released, "funding behind money that moved stays committed")
		})
	}
}

func TestCancelAfterARefusedPayoutIsAllowed(t *testing.T) {
	funding := &fakeFundingRelease{}
	b := cancelBusiness(cancellableLoan(loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT),
		&stubDisbursementRepo{stored: []*loansmodels.Disbursement{
			{Status: int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_FAILED)}}}, funding)
	_, err := b.Cancel(t.Context(), "loan-1", "the rail refused the number")
	require.NoError(t, err)
	assert.Equal(t, []string{"lr-1"}, funding.released)
}
