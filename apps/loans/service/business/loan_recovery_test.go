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
	"errors"
	"testing"

	"buf.build/gen/go/antinvestor/funding/connectrpc/go/v2/funding/v1/fundingv1connect"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"github.com/pitabwire/frame/v3/data"
	moneyx "github.com/pitabwire/util/moneyx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// A payment on a written-off loan reverses the write-off: its principal is
// credited to the product's bad-debt expense, not to the loan asset the
// write-off already cleared.
func TestRecoveryOnAWrittenOffLoanReversesTheBadDebt(t *testing.T) {
	la := activeLoanAccountForRepayment()
	la.Status = int32(loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF)
	la.ProductID = "prod-1"
	la.LedgerAssetAccountID = "loan-asset-1"
	ops := &recordingOperationsClient{}
	b := buildRepBusiness(&stubLoanAccountRepo{account: la},
		&stubRepaymentRepo{findErr: errors.New("not found")}, ops)

	_, err := b.Record(paymentRailContext(), &loansv1.RepaymentRecordRequest{
		LoanAccountId:  la.GetID(),
		IdempotencyKey: "idem-recovery",
		Amount:         moneyx.FromMinorUnitsByCurrency("KES", 500),
	})
	require.NoError(t, err)

	var principal bool
	for _, o := range ops.snapshot() {
		if o.GetReference() == "repayment:idem-recovery:principal" {
			principal = true
			assert.Equal(t, constants.ProductBadDebtExpenseAccount("prod-1"), o.GetCreditAccountRef())
		}
	}
	assert.True(t, principal, "the recovered principal is posted")
}

type recoveryFunding struct {
	fundingv1connect.FundingServiceClient
	recoveries []*fundingv1.LoanRecoveryApplyRequest
	repayments int
}

func (f *recoveryFunding) LoanRecoveryApply(
	_ context.Context,
	req *fundingv1.LoanRecoveryApplyRequest,
) (*fundingv1.LoanRecoveryApplyResponse, error) {
	f.recoveries = append(f.recoveries, req)
	return &fundingv1.LoanRecoveryApplyResponse{Settled: true}, nil
}

func (f *recoveryFunding) LoanRepaymentApply(
	_ context.Context,
	_ *fundingv1.LoanRepaymentApplyRequest,
) (*fundingv1.LoanRepaymentApplyResponse, error) {
	f.repayments++
	return &fundingv1.LoanRepaymentApplyResponse{Settled: true}, nil
}

// The funders of a written-off loan get its recovered principal back as a
// recovery, never as an ordinary repayment share with interest.
func TestRecoveredPrincipalGoesBackToTheFunders(t *testing.T) {
	la := &loansmodels.LoanAccount{Status: int32(loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF),
		ProductID: "prod-1", Properties: data.JSONMap{"loan_request_id": "lr-1"}}
	la.ID = "loan-1"
	r := &loansmodels.Repayment{CurrencyCode: "KES", PrincipalApplied: 40_000, InterestApplied: 5_000}
	r.ID = "rep-1"
	funding := &recoveryFunding{}
	s := NewFundingSettlement(&stubRepaymentRepo{}, &stubLoanAccountRepo{account: la}, funding)

	require.NoError(t, s.Settle(t.Context(), la, r))
	require.Len(t, funding.recoveries, 1)
	assert.Zero(t, funding.repayments)
	rec := funding.recoveries[0]
	assert.Equal(t, "lr-1", rec.GetLoanRequestId())
	assert.Equal(t, "recovery:rep-1", rec.GetRecoveryReference())
	assert.Equal(t, int64(400), rec.GetPrincipal().GetUnits(), "principal only: recovered interest is the lender's")
}

func (c *recordingOperationsClient) snapshot() []*operationsv1.TransferOrderObject {
	c.mu.Lock()
	defer c.mu.Unlock()
	return append([]*operationsv1.TransferOrderObject(nil), c.orders...)
}

// A recovery that cleared the loan closed it before its funders were
// settled; it is still settled as a recovery, from what the row recorded.
func TestRecoveryThatClosedTheLoanIsStillSettledAsARecovery(t *testing.T) {
	la := &loansmodels.LoanAccount{Status: int32(loansv1.LoanStatus_LOAN_STATUS_CLOSED),
		ProductID: "prod-1", Properties: data.JSONMap{"loan_request_id": "lr-1"}}
	la.ID = "loan-1"
	r := &loansmodels.Repayment{CurrencyCode: "KES", PrincipalApplied: 10_000,
		Properties: data.JSONMap{repaymentRecoveryKey: true}}
	r.ID = "rep-2"
	funding := &recoveryFunding{}
	s := NewFundingSettlement(&stubRepaymentRepo{}, &stubLoanAccountRepo{account: la}, funding)

	require.NoError(t, s.Settle(t.Context(), la, r))
	assert.Len(t, funding.recoveries, 1)
	assert.Zero(t, funding.repayments, "never shared out as an ordinary repayment")
}
