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

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
)

// recordingExecutor stands in for TransferOrderBusiness.Execute.
type recordingExecutor struct {
	executed []string
	err      error
}

func (e *recordingExecutor) Execute(ctx context.Context, orderID string) error {
	if claims := security.ClaimsFromContext(ctx); claims == nil {
		return errors.New("executed without claims")
	}
	if e.err != nil {
		return e.err
	}
	e.executed = append(e.executed, orderID)
	return nil
}

func borrowerPayment(txn string) map[string]interface{} {
	return map[string]interface{}{
		"transaction_id":  txn,
		"amount":          int64(40_000),
		"currency":        "UGX",
		"payer_reference": "profile-1",
		"product_id":      "prod-1",
		"properties":      data.JSONMap{},
	}
}

func internalContext() context.Context {
	return (&security.AuthenticationClaims{
		Roles: []string{security.ConstantSystemInternalRole},
	}).ClaimsToContext(context.Background())
}

func TestMatchedBorrowerPaymentIsPostedAtOnce(t *testing.T) {
	routing, _, orders := newBorrowerRouting(t, []*loansv1.LoanAccountObject{activeLoan("loan-1")})
	exec := &recordingExecutor{}
	routing.executor = exec

	result, err := routing.IdentifyPayment(internalContext(), borrowerPayment("txn-x1"))
	require.NoError(t, err)

	paymentID, _ := result["payment_id"].(string)
	order := orders.byReference["payment:"+paymentID+":loan:loan-1"]
	require.NotNil(t, order)
	assert.Equal(t, []string{order.GetID()}, exec.executed, "the repayment reaches the loan without a sweep")
	assert.Equal(t, executionPosted, result["execution"])
}

func TestBorrowerPaymentStaysAllocatedWhenPostingFails(t *testing.T) {
	routing, payments, orders := newBorrowerRouting(t, []*loansv1.LoanAccountObject{activeLoan("loan-1")})
	routing.executor = &recordingExecutor{err: errors.New("ledger unavailable")}

	result, err := routing.IdentifyPayment(context.Background(), borrowerPayment("txn-x2"))
	require.NoError(t, err, "a posting failure never fails the payment")
	assert.Equal(t, executionPending, result["execution"])
	assert.Len(t, orders.byReference, 1, "the order stands for the settle job")

	paymentID, _ := result["payment_id"].(string)
	stored, err := payments.GetByID(context.Background(), paymentID)
	require.NoError(t, err)
	assert.Equal(t, int64(0), paymentRemainder(stored), "the money is spoken for")
}

func TestSettleJobAllocatesMatchedPaymentsAndPostsRaisedOrders(t *testing.T) {
	routing, payments, orders := newBorrowerRouting(t, []*loansv1.LoanAccountObject{activeLoan("loan-1")})

	// One payment matched and allocated, its order never posted.
	posted, err := routing.IdentifyPayment(context.Background(), borrowerPayment("txn-s1"))
	require.NoError(t, err)
	postedID, _ := posted["payment_id"].(string)

	// One payment matched by staff whose allocation never ran.
	unmatched := unmatchedPayment(t, routing, "txn-s2", "prod-1")
	assigned, err := payments.AssignOwner(context.Background(), unmatched, repository.PaymentAssignment{
		OwnerID: "client-1", OwnerType: ownerTypeClientLoan, PayableID: "loan-1", PayableType: "loan",
		Properties: data.JSONMap{fieldProfileID: "profile-1"},
	})
	require.NoError(t, err)
	require.True(t, assigned)

	exec := &recordingExecutor{}
	jobs := NewOperationsJobs(routing, exec, payments, orders, "service_operations")
	processed, more, err := jobs.Run(internalContext(), operationsv1.OperationsJob_OPERATIONS_JOB_SETTLE_PAYMENTS, 50)
	require.NoError(t, err)
	assert.False(t, more)
	assert.Equal(t, 3, processed, "one allocation, two postings")

	require.Len(t, orders.byReference, 2)
	var want []string
	for _, ref := range []string{"payment:" + postedID + ":loan:loan-1", "payment:" + unmatched + ":loan:loan-1"} {
		require.Contains(t, orders.byReference, ref)
		want = append(want, orders.byReference[ref].GetID())
	}
	assert.ElementsMatch(t, want, exec.executed)
}

func TestSettleJobIsRunOnlyByInternalServices(t *testing.T) {
	routing, payments, orders := newBorrowerRouting(t, nil)
	jobs := NewOperationsJobs(routing, &recordingExecutor{}, payments, orders, "service_operations")

	_, _, err := jobs.Run(staffContext(), operationsv1.OperationsJob_OPERATIONS_JOB_SETTLE_PAYMENTS, 10)
	require.ErrorIs(t, err, ErrJobCallerNotInternal)

	_, _, err = jobs.Run(internalContext(), operationsv1.OperationsJob_OPERATIONS_JOB_UNSPECIFIED, 10)
	require.ErrorIs(t, err, ErrUnknownJob)
}
