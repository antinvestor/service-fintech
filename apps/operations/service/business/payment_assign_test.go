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
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/pkg/constants"
)

// unmatchedPayment records a payment the rail could not tie to anybody: the
// payer is unknown and quoted nothing usable.
func unmatchedPayment(t *testing.T, routing *paymentRoutingBusiness, txn, productID string) string {
	t.Helper()
	result, err := routing.IdentifyPayment(context.Background(), map[string]interface{}{
		"transaction_id":  txn,
		"amount":          int64(30_000),
		"currency":        "UGX",
		"payer_reference": "+256709999999",
		"product_id":      productID,
		"properties":      data.JSONMap{"reference": "my loan"},
	})
	require.NoError(t, err)
	require.Equal(t, "unidentified", result["strategy"])
	paymentID, _ := result["payment_id"].(string)
	return paymentID
}

func staffContext() context.Context {
	return (&security.AuthenticationClaims{
		Roles:            []string{"operator"},
		RegisteredClaims: jwt.RegisteredClaims{Subject: "staff-profile"},
	}).ClaimsToContext(context.Background())
}

func TestAssignPaymentTiesUnmatchedPaymentToTheLoanAndAllocatesIt(t *testing.T) {
	routing, payments, orders := newBorrowerRouting(t, []*loansv1.LoanAccountObject{activeLoan("loan-1")})
	paymentID := unmatchedPayment(t, routing, "txn-u1", "prod-1")

	payment, allocation, err := routing.AssignPayment(
		staffContext(),
		paymentID,
		"loan-1",
		"",
		"payer confirmed by phone call",
	)
	require.NoError(t, err)
	assert.Equal(t, "client-1", payment.OwnerID)
	assert.Equal(t, ownerTypeClientLoan, payment.OwnerType)
	assert.Equal(t, strategyStaffAssigned, payment.Properties.GetString("identification_strategy"))
	assert.Equal(t, "staff-profile", payment.Properties.GetString(fieldAssignedBy))
	assert.Equal(t, "payer confirmed by phone call", payment.Properties.GetString(fieldAssignmentNote))
	assert.Equal(t, int64(30_000), allocation["allocated_amount"])

	// The amount booked is the rail's, from the product's collection account.
	order := orders.byReference["payment:"+paymentID+":loan:loan-1"]
	require.NotNil(t, order)
	assert.Equal(t, int64(30_000), order.Amount)
	assert.Equal(t, constants.ProductExternalCashAccount("prod-1"), order.DebitAccountRef)
	assert.Equal(t, constants.MemberLoansAccount("client-1"), order.CreditAccountRef)

	stored, err := payments.GetByID(context.Background(), paymentID)
	require.NoError(t, err)
	assert.Equal(t, "loan-1", stored.PayableID)
}

func TestAssignPaymentRefusals(t *testing.T) {
	loans := []*loansv1.LoanAccountObject{
		activeLoan("loan-1"),
		{Id: "loan-other", ClientId: "client-1", ProductId: "prod-2", Status: loansv1.LoanStatus_LOAN_STATUS_ACTIVE},
		{Id: "loan-paid", ClientId: "client-1", ProductId: "prod-1", Status: loansv1.LoanStatus_LOAN_STATUS_PAID_OFF},
	}

	tests := []struct {
		name    string
		loanID  string
		note    string
		product string
		want    error
	}{
		{name: "note is required", loanID: "loan-1", note: " ", product: "prod-1", want: ErrPaymentAssignInvalid},
		{name: "loan of another product", loanID: "loan-other", note: "n", product: "prod-1",
			want: ErrPaymentLoanOtherProduct},
		{name: "loan that takes no repayments", loanID: "loan-paid", note: "n", product: "prod-1",
			want: ErrPaymentLoanNotRepayable},
		{name: "unknown loan", loanID: "loan-none", note: "n", product: "prod-1", want: ErrPaymentLoanNotRepayable},
		{name: "payment without a product", loanID: "loan-1", note: "n", product: "", want: ErrPaymentWithoutProduct},
	}
	for i, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			routing, _, orders := newBorrowerRouting(t, loans)
			paymentID := unmatchedPayment(t, routing, "txn-r"+string(rune('a'+i)), tc.product)

			_, _, err := routing.AssignPayment(staffContext(), paymentID, tc.loanID, "", tc.note)
			require.ErrorIs(t, err, tc.want)
			assert.Empty(t, orders.byReference)
		})
	}
}

func TestAssignPaymentOnlyOnce(t *testing.T) {
	routing, _, orders := newBorrowerRouting(
		t,
		[]*loansv1.LoanAccountObject{activeLoan("loan-1"), activeLoan("loan-2")},
	)
	paymentID := unmatchedPayment(t, routing, "txn-o1", "prod-1")

	_, _, err := routing.AssignPayment(staffContext(), paymentID, "loan-1", "", "first")
	require.NoError(t, err)

	_, _, err = routing.AssignPayment(staffContext(), paymentID, "loan-2", "", "second")
	require.ErrorIs(t, err, ErrPaymentAlreadyMatched)
	assert.Len(t, orders.byReference, 1)
}

func TestAssignPaymentRefusesAMatchedPayment(t *testing.T) {
	routing, _, _ := newBorrowerRouting(t, []*loansv1.LoanAccountObject{activeLoan("loan-1")})
	result, err := routing.IdentifyPayment(context.Background(), map[string]interface{}{
		"transaction_id":  "txn-m1",
		"amount":          int64(10_000),
		"currency":        "UGX",
		"payer_reference": "+256701000111",
		"product_id":      "prod-1",
		"properties":      data.JSONMap{},
	})
	require.NoError(t, err)
	paymentID, _ := result["payment_id"].(string)

	_, _, err = routing.AssignPayment(staffContext(), paymentID, "loan-1", "", "n")
	require.ErrorIs(t, err, ErrPaymentAlreadyMatched)
}
