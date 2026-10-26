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
	"fmt"
	"strings"
	"time"

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// strategyStaffAssigned marks a payment a person tied to its loan after the
// rail's payment matched nobody.
const (
	strategyStaffAssigned = "staff_assigned"
	fieldAssignedBy       = "assigned_by"
	fieldAssignmentNote   = "assignment_note"
	fieldAssignedAt       = "assigned_at"
	maxAssignmentNoteLen  = 500
)

var (
	ErrPaymentAssignInvalid = apperrors.NewError(apperrors.BadRequest,
		"a payment, the one loan or savings account it belongs to, and a note saying why are required")
	ErrPaymentSavingsNotOpen = apperrors.NewError(apperrors.Unprocessable,
		"the savings account is not an open account of one person")
	ErrPaymentAlreadyMatched = apperrors.NewError(apperrors.Conflict,
		"this payment is already matched or allocated")
	ErrPaymentWithoutProduct = apperrors.NewError(apperrors.Unprocessable,
		"the payment names no product account, so it cannot be applied to a loan")
	ErrPaymentLoanNotRepayable = apperrors.NewError(apperrors.Unprocessable,
		"the loan does not take repayments")
	ErrPaymentLoanOtherProduct = apperrors.NewError(apperrors.Unprocessable,
		"the loan or savings account belongs to another product than the account the payment was made to")
	ErrPaymentAssignUnavailable = apperrors.NewError(apperrors.ServiceUnavailable,
		"loan matching is not configured")
)

// AssignPayment ties a payment that matched nobody to the borrower's loan or
// the saver's account it was meant for, then allocates it. The amount is the
// rail's, never typed: a person only says where the money belongs. Exactly
// one target is named; it must be of the product whose account the rail
// credited.
//
// The assignment stands even if allocation then fails; PaymentAllocate
// retries it.
func (b *paymentRoutingBusiness) AssignPayment(
	ctx context.Context,
	paymentID, loanID, savingsAccountID, note string,
) (*models.IncomingPayment, map[string]interface{}, error) {
	paymentID = strings.TrimSpace(paymentID)
	loanID = strings.TrimSpace(loanID)
	savingsAccountID = strings.TrimSpace(savingsAccountID)
	note = strings.TrimSpace(note)
	if paymentID == "" || (loanID == "") == (savingsAccountID == "") || note == "" ||
		len(note) > maxAssignmentNoteLen {
		return nil, nil, ErrPaymentAssignInvalid
	}

	payment, err := b.ipRepo.GetByID(ctx, paymentID)
	if err != nil {
		return nil, nil, apperrors.ErrDataNotFound.Extend("incoming payment")
	}
	if payment.OwnerID != "" {
		return nil, nil, ErrPaymentAlreadyMatched
	}
	productID := payment.Properties.GetString(fieldProductID)
	if productID == "" {
		return nil, nil, ErrPaymentWithoutProduct
	}

	var result *identificationResult
	if loanID != "" {
		result, err = b.assignableLoan(ctx, loanID, productID)
	} else {
		result, err = b.assignableSavings(ctx, savingsAccountID, productID)
	}
	if err != nil {
		return nil, nil, err
	}

	assignedBy := ""
	if claims := security.ClaimsFromContext(ctx); claims != nil {
		assignedBy = claims.GetProfileID()
	}
	assignment := repository.PaymentAssignment{
		OwnerID: result.ClientID,
		Properties: data.JSONMap{
			"identification_strategy": strategyStaffAssigned,
			fieldClientID:             result.ClientID,
			fieldProfileID:            result.ProfileID,
			fieldAssignedBy:           assignedBy,
			fieldAssignmentNote:       note,
			fieldAssignedAt:           time.Now().UTC().Format(time.RFC3339),
		},
	}
	if result.LoanID != "" {
		assignment.OwnerType, assignment.PayableID, assignment.PayableType = ownerTypeClientLoan, result.LoanID, "loan"
		assignment.Properties[fieldLoanID] = result.LoanID
	} else {
		assignment.OwnerType = ownerTypeClientSavings
		assignment.PayableID, assignment.PayableType = result.SavingsAccountID, payableTypeSavings
		assignment.Properties[fieldSavingsAccountID] = result.SavingsAccountID
	}
	assigned, err := b.ipRepo.AssignOwner(ctx, paymentID, assignment)
	if err != nil {
		return nil, nil, fmt.Errorf("assign payment %s: %w", paymentID, err)
	}
	if !assigned {
		return nil, nil, ErrPaymentAlreadyMatched
	}
	util.Log(ctx).WithField(fieldPaymentID, paymentID).WithField(fieldLoanID, loanID).
		WithField(fieldSavingsAccountID, savingsAccountID).
		WithField(fieldAssignedBy, assignedBy).Info("unmatched payment assigned to loan")
	recordPaymentIdentified(ctx, payment)

	allocation, allocErr := b.AllocatePayment(ctx, paymentID)
	stored, getErr := b.ipRepo.GetByID(ctx, paymentID)
	if getErr != nil {
		return nil, nil, fmt.Errorf("reload assigned payment %s: %w", paymentID, getErr)
	}
	if allocErr != nil {
		return stored, nil, allocErr
	}
	return stored, allocation, nil
}

// assignableLoan checks a staff-chosen loan can take the payment.
func (b *paymentRoutingBusiness) assignableLoan(
	ctx context.Context,
	loanID, productID string,
) (*identificationResult, error) {
	if !b.borrowerLoanMatching() {
		return nil, ErrPaymentAssignUnavailable
	}
	loan, err := b.repayableLoan(ctx, loanID)
	if err != nil {
		return nil, ErrPaymentLoanNotRepayable
	}
	if loan.GetProductId() != productID {
		return nil, ErrPaymentLoanOtherProduct
	}
	return b.borrowerLoanResult(ctx, loan)
}

// assignableSavings checks a staff-chosen savings account can take the
// payment.
func (b *paymentRoutingBusiness) assignableSavings(
	ctx context.Context,
	accountID, productID string,
) (*identificationResult, error) {
	if !b.borrowerSavingsMatching() {
		return nil, ErrPaymentAssignUnavailable
	}
	acct, err := b.openSavingsAccount(ctx, accountID)
	if err != nil {
		return nil, ErrPaymentSavingsNotOpen
	}
	if acct.GetProductId() != productID {
		return nil, ErrPaymentLoanOtherProduct
	}
	return b.saverResult(ctx, acct)
}
