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
	"sync"
	"testing"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	moneyx "github.com/pitabwire/util/moneyx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
)

// recordingOperationsClient keeps every transfer order it is handed so a test
// can assert on the ledger references the repayment flow mints.
type recordingOperationsClient struct {
	mu     sync.Mutex
	orders []*operationsv1.TransferOrderObject
}

func (c *recordingOperationsClient) TransferOrderExecute(
	_ context.Context,
	req *operationsv1.TransferOrderExecuteRequest,
) (*operationsv1.TransferOrderExecuteResponse, error) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.orders = append(c.orders, req.GetData())
	return &operationsv1.TransferOrderExecuteResponse{
		Data: &operationsv1.TransferOrderObject{Id: "txn-rep"},
	}, nil
}

func (c *recordingOperationsClient) TransferOrderSearch(
	_ context.Context,
	_ *operationsv1.TransferOrderSearchRequest,
) (operationsv1connect.OperationsServiceTransferOrderSearchClientStream, error) {
	panic("stub: TransferOrderSearch not expected")
}

func (c *recordingOperationsClient) IncomingPaymentNotify(
	_ context.Context,
	_ *operationsv1.IncomingPaymentNotifyRequest,
) (*operationsv1.IncomingPaymentNotifyResponse, error) {
	panic("stub: IncomingPaymentNotify not expected")
}

func (c *recordingOperationsClient) PaymentAllocate(
	_ context.Context,
	_ *operationsv1.PaymentAllocateRequest,
) (*operationsv1.PaymentAllocateResponse, error) {
	panic("stub: PaymentAllocate not expected")
}

func (c *recordingOperationsClient) IncomingPaymentSearch(
	_ context.Context,
	_ *operationsv1.IncomingPaymentSearchRequest,
) (operationsv1connect.OperationsServiceIncomingPaymentSearchClientStream, error) {
	panic("stub: IncomingPaymentSearch not expected")
}

func (c *recordingOperationsClient) IncomingPaymentAssign(
	_ context.Context,
	_ *operationsv1.IncomingPaymentAssignRequest,
) (*operationsv1.IncomingPaymentAssignResponse, error) {
	panic("stub: IncomingPaymentAssign not expected")
}

func (c *recordingOperationsClient) OperationsJobRun(
	_ context.Context,
	_ *operationsv1.OperationsJobRunRequest,
) (*operationsv1.OperationsJobRunResponse, error) {
	panic("stub: OperationsJobRun not expected")
}

func (c *recordingOperationsClient) references() map[string]int64 {
	c.mu.Lock()
	defer c.mu.Unlock()
	refs := make(map[string]int64, len(c.orders))
	for _, order := range c.orders {
		refs[order.GetReference()] = order.GetAmount().GetUnits()
	}
	return refs
}

var _ operationsv1connect.OperationsServiceClient = (*recordingOperationsClient)(nil)

// recordingLoanAccountRepo notes the status transitions the repayment flow
// claims, so the pay-off path can be asserted on directly.
type recordingLoanAccountRepo struct {
	*stubLoanAccountRepo
	claimedFrom int32
	claimedTo   int32
	claims      int
}

func (r *recordingLoanAccountRepo) ClaimStatus(_ context.Context, _ string, from, to int32) (bool, error) {
	r.claims++
	r.claimedFrom = from
	r.claimedTo = to
	return true, nil
}

// TestRepaymentLedgerReferencesAreKeyedOnTheIdempotencyKey is the regression
// for double-posting on retry: a partial failure hands the idempotency key
// back and the retry writes a fresh repayment row, so a reference derived
// from that row id would let a component that already posted post again.
func TestRepaymentLedgerReferencesAreKeyedOnTheIdempotencyKey(t *testing.T) {
	la := activeLoanAccountForRepayment()
	repRepo := &stubRepaymentRepo{findErr: errors.New("not found")}
	ops := &recordingOperationsClient{}

	b := buildRepBusiness(&stubLoanAccountRepo{account: la}, repRepo, ops)

	_, err := b.Record(paymentRailContext(), &loansv1.RepaymentRecordRequest{
		LoanAccountId:  la.GetID(),
		IdempotencyKey: "idem-rep-ref",
		Amount:         moneyx.FromMinorUnitsByCurrency("KES", 5000),
	})
	require.NoError(t, err)

	refs := ops.references()
	require.NotEmpty(t, refs)
	for ref := range refs {
		assert.Contains(t, ref, "repayment:idem-rep-ref:",
			"a ledger reference must be derived from the idempotency key, not the row id")
	}
}

// TestUnscheduledRepaymentCapsPrincipalAndRoutesTheExcess covers a loan with
// no active schedule: principal can only absorb what is outstanding and the
// rest is the borrower's money, which must reach suspense rather than being
// silently swallowed into the balance clamp.
func TestUnscheduledRepaymentCapsPrincipalAndRoutesTheExcess(t *testing.T) {
	la := activeLoanAccountForRepayment()
	b := buildRepBusiness(&stubLoanAccountRepo{account: la},
		&stubRepaymentRepo{findErr: errors.New("not found")}, nil)

	balance := &loansmodels.LoanBalance{
		LoanAccountID:        la.GetID(),
		CurrencyCode:         "KES",
		PrincipalOutstanding: 100000,
		TotalOutstanding:     100000,
	}

	alloc := b.waterfallAllocate(context.Background(), la.GetID(), 150000, balance)

	assert.Equal(t, int64(100000), alloc.principalApplied, "principal cannot absorb more than is outstanding")
	assert.Equal(t, int64(50000), alloc.excessAmount, "the overpayment must survive allocation")
	assert.Equal(t, loansv1.RepaymentStatus_REPAYMENT_STATUS_OVERPAYMENT, alloc.status)
}

// TestUnscheduledOverpaymentPostsToSuspense pins the ledger side of the same
// case: the excess leaves the flow as its own transfer order.
func TestUnscheduledOverpaymentPostsToSuspense(t *testing.T) {
	la := activeLoanAccountForRepayment()
	ops := &recordingOperationsClient{}
	b := buildRepBusiness(&stubLoanAccountRepo{account: la},
		&stubRepaymentRepo{findErr: errors.New("not found")}, ops)

	// The balance stub carries 100000 minor units of outstanding principal.
	_, err := b.Record(paymentRailContext(), &loansv1.RepaymentRecordRequest{
		LoanAccountId:  la.GetID(),
		IdempotencyKey: "idem-rep-over",
		Amount:         moneyx.FromMinorUnitsByCurrency("KES", 150000),
	})
	require.NoError(t, err)

	refs := ops.references()
	assert.Equal(t, int64(1000), refs["repayment:idem-rep-over:principal"])
	assert.Equal(t, int64(500), refs["repayment:idem-rep-over:excess"],
		"money beyond the outstanding principal must be posted to suspense")
}

// TestDelinquentLoanSettlesToPaidOff is the regression for the two state
// machines disagreeing: a delinquent borrower who clears the loan must reach
// PAID_OFF through the same table an operator transition consults.
func TestDelinquentLoanSettlesToPaidOff(t *testing.T) {
	assert.True(t, transitionAllowed(
		loansv1.LoanStatus_LOAN_STATUS_DELINQUENT, loansv1.LoanStatus_LOAN_STATUS_PAID_OFF))
	assert.True(t, transitionAllowed(
		loansv1.LoanStatus_LOAN_STATUS_DEFAULT, loansv1.LoanStatus_LOAN_STATUS_PAID_OFF))
	assert.False(t, transitionAllowed(
		loansv1.LoanStatus_LOAN_STATUS_CLOSED, loansv1.LoanStatus_LOAN_STATUS_PAID_OFF))

	la := activeLoanAccountForRepayment()
	la.Status = int32(loansv1.LoanStatus_LOAN_STATUS_DELINQUENT)
	laRepo := &recordingLoanAccountRepo{stubLoanAccountRepo: &stubLoanAccountRepo{account: la}}
	ops := &recordingOperationsClient{}
	b := buildRepBusiness(laRepo, &stubRepaymentRepo{findErr: errors.New("not found")}, ops)

	// The balance stub reports 100000 minor units outstanding, so this
	// payment settles the loan in full.
	_, err := b.Record(paymentRailContext(), &loansv1.RepaymentRecordRequest{
		LoanAccountId:  la.GetID(),
		IdempotencyKey: "idem-rep-delinquent",
		Amount:         moneyx.FromMinorUnitsByCurrency("KES", 100000),
	})
	require.NoError(t, err)

	require.Equal(t, 1, laRepo.claims, "a settled delinquent loan must claim the pay-off")
	assert.Equal(t, int32(loansv1.LoanStatus_LOAN_STATUS_DELINQUENT), laRepo.claimedFrom)
	assert.Equal(t, int32(loansv1.LoanStatus_LOAN_STATUS_PAID_OFF), laRepo.claimedTo)
}

// A borrower can pay back a loan in any status that still owes: defaulted
// and written-off loans included, since recovering them is the point.
func TestRepayableStatuses(t *testing.T) {
	for status, want := range map[loansv1.LoanStatus]bool{
		loansv1.LoanStatus_LOAN_STATUS_ACTIVE:               true,
		loansv1.LoanStatus_LOAN_STATUS_DELINQUENT:           true,
		loansv1.LoanStatus_LOAN_STATUS_DEFAULT:              true,
		loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED:         true,
		loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT: false,
		loansv1.LoanStatus_LOAN_STATUS_PAID_OFF:             false,
		loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF:          true,
		loansv1.LoanStatus_LOAN_STATUS_CLOSED:               false,
	} {
		assert.Equal(t, want, isRepayableStatus(int32(status)), status.String())
	}
}
