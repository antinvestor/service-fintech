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
	"fmt"
	"io"
	"strings"
	"time"

	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// An individual borrower's mobile-money repayment is matched straight to
// their loan: by the loan account id the payer quoted as reference, or by
// the payer's phone number through their profile and client to their one
// repayable loan. Group payments keep the membership strategies.
const (
	strategyBorrowerLoan  = "borrower_loan"
	ownerTypeClientLoan   = "client_loan"
	extraRepaymentChannel = "repayment_channel"
	channelMobileMoney    = "mobile_money"
)

var errBorrowerLoanAmbiguous = errors.New("payer has no single repayable loan")

// borrowerLoanMatching reports whether the clients the strategy needs are
// configured.
func (b *paymentRoutingBusiness) borrowerLoanMatching() bool {
	return b.clients != nil && b.clients.LenderLoanMgmt != nil
}

// identifyBorrowerLoan resolves a payment to an individual borrower's loan.
func (b *paymentRoutingBusiness) identifyBorrowerLoan(
	ctx context.Context,
	paymentRef, payerRef string,
) (*identificationResult, error) {
	if paymentRef != "" {
		if loan, err := b.repayableLoan(ctx, paymentRef); err == nil {
			return b.borrowerLoanResult(ctx, loan)
		}
	}
	if payerRef == "" {
		return nil, errBorrowerLoanAmbiguous
	}
	clientID, err := b.clientForContact(ctx, payerRef)
	if err != nil {
		return nil, err
	}
	loans, err := b.repayableLoansOf(ctx, clientID)
	if err != nil {
		return nil, err
	}
	if len(loans) != 1 {
		return nil, errBorrowerLoanAmbiguous
	}
	return b.borrowerLoanResult(ctx, loans[0])
}

func (b *paymentRoutingBusiness) borrowerLoanResult(
	ctx context.Context,
	loan *loansv1.LoanAccountObject,
) (*identificationResult, error) {
	result := &identificationResult{
		Strategy:  strategyBorrowerLoan,
		ClientID:  loan.GetClientId(),
		LoanID:    loan.GetId(),
		ProductID: loan.GetProductId(),
	}
	if b.clients.LenderIdentity != nil {
		if resp, err := b.clients.LenderIdentity.ClientGet(ctx,
			&fieldv1.ClientGetRequest{Id: loan.GetClientId()}); err == nil {
			result.ProfileID = resp.GetData().GetProfileId()
		}
	}
	return result, nil
}

// repayableLoan loads a loan by id and returns it when it can take money.
func (b *paymentRoutingBusiness) repayableLoan(ctx context.Context, loanID string) (*loansv1.LoanAccountObject, error) {
	resp, err := b.clients.LenderLoanMgmt.LoanAccountGet(ctx, &loansv1.LoanAccountGetRequest{Id: loanID})
	if err != nil {
		return nil, err
	}
	if !loanTakesRepayments(resp.GetData()) {
		return nil, errBorrowerLoanAmbiguous
	}
	return resp.GetData(), nil
}

// clientForContact finds the one client whose profile owns contact.
func (b *paymentRoutingBusiness) clientForContact(ctx context.Context, contact string) (string, error) {
	if b.clients.ProfileClient == nil || b.clients.LenderIdentity == nil {
		return "", errBorrowerLoanAmbiguous
	}
	profile, err := b.clients.ProfileClient.GetByContact(ctx, &profilev1.GetByContactRequest{Contact: contact})
	if err != nil {
		return "", fmt.Errorf("profile for payer contact: %w", err)
	}
	profileID := profile.GetData().GetId()
	if profileID == "" {
		return "", errBorrowerLoanAmbiguous
	}
	stream, err := b.clients.LenderIdentity.ClientSearch(ctx, &fieldv1.ClientSearchRequest{ProfileId: profileID})
	if err != nil {
		return "", fmt.Errorf("client for payer profile: %w", err)
	}
	defer func() { _ = stream.Close() }()
	var clientIDs []string
	for {
		msg, recvErr := stream.Receive()
		if errors.Is(recvErr, io.EOF) {
			break
		}
		if recvErr != nil {
			return "", fmt.Errorf("client for payer profile: %w", recvErr)
		}
		for _, c := range msg.GetData() {
			if c.GetProfileId() == profileID {
				clientIDs = append(clientIDs, c.GetId())
			}
		}
	}
	if len(clientIDs) != 1 {
		return "", errBorrowerLoanAmbiguous
	}
	return clientIDs[0], nil
}

// repayableLoansOf lists the client's loans that can take a repayment.
func (b *paymentRoutingBusiness) repayableLoansOf(
	ctx context.Context,
	clientID string,
) ([]*loansv1.LoanAccountObject, error) {
	stream, err := b.clients.LenderLoanMgmt.LoanAccountSearch(
		ctx,
		&loansv1.LoanAccountSearchRequest{ClientId: clientID},
	)
	if err != nil {
		return nil, fmt.Errorf("loans of payer client: %w", err)
	}
	defer func() { _ = stream.Close() }()
	var out []*loansv1.LoanAccountObject
	for {
		msg, recvErr := stream.Receive()
		if errors.Is(recvErr, io.EOF) {
			return out, nil
		}
		if recvErr != nil {
			return nil, fmt.Errorf("loans of payer client: %w", recvErr)
		}
		for _, loan := range msg.GetData() {
			if loan.GetClientId() == clientID && loanTakesRepayments(loan) {
				out = append(out, loan)
			}
		}
	}
}

func loanTakesRepayments(loan *loansv1.LoanAccountObject) bool {
	switch loan.GetStatus() { //nolint:exhaustive // only repayable statuses matter
	case loansv1.LoanStatus_LOAN_STATUS_ACTIVE, loansv1.LoanStatus_LOAN_STATUS_DELINQUENT,
		loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED:
		return true
	default:
		return false
	}
}

// allocateToBorrowerLoan books an identified borrower payment onto their
// loan in one order: the money moves from the product's external cash
// account (where the rail landed it) to the borrower's loans account, and
// the order's side effect records the repayment with the loans service,
// which posts it from that account into the loan. The order reference is
// keyed on the payment, so a replay converges on one order and one
// repayment.
func (b *paymentRoutingBusiness) allocateToBorrowerLoan(
	ctx context.Context,
	logger *util.LogEntry,
	payment *models.IncomingPayment,
	lease time.Time,
) (map[string]interface{}, error) {
	paymentID := payment.GetID()
	clientID := payment.OwnerID
	loanID := payment.PayableID
	productID := payment.Properties.GetString(fieldProductID)
	if clientID == "" || loanID == "" || productID == "" {
		b.releaseAllocationLease(ctx, logger, paymentID, lease)
		return nil, fmt.Errorf("payment %s is missing its borrower, loan or product", paymentID)
	}

	to := &models.TransferOrder{
		DebitAccountRef:  constants.ProductExternalCashAccount(productID),
		CreditAccountRef: constants.MemberLoansAccount(clientID),
		Amount:           payment.Amount,
		Currency:         payment.Currency,
		OrderType:        constants.SafeInt32FromInt(constants.TransferTypeLoanRepayment),
		Reference:        fmt.Sprintf("payment:%s:loan:%s", paymentID, loanID),
		Description:      fmt.Sprintf("Mobile-money repayment of loan %s from payment %s", loanID, paymentID),
		State:            int32(constants.StateJustCreated),
		ExtraData: data.JSONMap{
			extraKeySource:        allocationSourceMarker,
			"payment_id":          paymentID,
			fieldLoanID:           loanID,
			fieldClientID:         clientID,
			extraRepaymentChannel: channelMobileMoney,
			fieldPayerReference:   payment.Properties.GetString(fieldPayerReference),
		},
	}
	to.GenID(ctx)
	to.CopyPartitionInfo(&payment.BaseModel)
	if err := b.toRepo.CreateIfAbsent(ctx, to); err != nil {
		b.releaseAllocationLease(ctx, logger, paymentID, lease)
		return nil, fmt.Errorf("create borrower loan repayment order: %w", err)
	}

	paymentState := resolvePaymentState(0, payment.Amount)
	if _, err := b.ipRepo.SetAllocationOutcome(ctx, paymentID, lease, paymentState, 0); err != nil {
		logger.WithError(err).Error("failed to record borrower loan allocation outcome")
	}
	logger.WithField(fieldLoanID, loanID).WithField("transfer_order_id", to.GetID()).
		Info("payment allocated to borrower loan")

	return map[string]interface{}{
		fieldPaymentID:       paymentID,
		fieldCurrency:        payment.Currency,
		fieldClientID:        clientID,
		fieldLoanID:          loanID,
		"total_amount":       payment.Amount,
		"allocated_amount":   payment.Amount,
		fieldRemainingAmount: int64(0),
		fieldTransferOrders: []map[string]interface{}{{
			"bucket":             strategyBorrowerLoan,
			fieldTransferOrderID: to.GetID(),
			fieldAmount:          to.Amount,
			"from_account":       to.DebitAccountRef,
			"to_account":         to.CreditAccountRef,
			fieldCurrency:        to.Currency,
			"type":               to.OrderType,
			fieldReference:       to.Reference,
		}},
		"payment_state": paymentState,
	}, nil
}

// isBorrowerLoanPayment reports whether a payment was matched to a loan.
func isBorrowerLoanPayment(payment *models.IncomingPayment) bool {
	return strings.EqualFold(payment.OwnerType, ownerTypeClientLoan)
}
