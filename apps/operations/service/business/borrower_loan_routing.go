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
//
// The payment's own product says which product account the rail credited,
// so it is the trusted value: a payment without one is never matched, and a
// loan of another product is never accepted, whatever the payer quoted.
func (b *paymentRoutingBusiness) identifyBorrowerLoan(
	ctx context.Context,
	productID, paymentRef, payerRef string,
) (*identificationResult, error) {
	if productID == "" {
		return nil, errBorrowerLoanAmbiguous
	}
	if paymentRef != "" {
		if loan, err := b.repayableLoan(ctx, paymentRef); err == nil && loan.GetProductId() == productID {
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
	loans, err := b.repayableLoansOf(ctx, clientID, productID)
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
	return &identificationResult{
		Strategy:  strategyBorrowerLoan,
		ClientID:  loan.GetClientId(),
		LoanID:    loan.GetId(),
		ProductID: loan.GetProductId(),
		ProfileID: b.profileOfClient(ctx, loan.GetClientId()),
	}, nil
}

// profileOfClient is the client's profile id, or "" when it cannot be read.
func (b *paymentRoutingBusiness) profileOfClient(ctx context.Context, clientID string) string {
	if b.clients == nil || b.clients.LenderIdentity == nil {
		return ""
	}
	resp, err := b.clients.LenderIdentity.ClientGet(ctx, &fieldv1.ClientGetRequest{Id: clientID})
	if err != nil {
		return ""
	}
	return resp.GetData().GetProfileId()
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

// clientForContact finds the one client behind the payer. The payer
// reference is taken as a profile id first, which is what the payment
// service supplies when it knows the sender. Only failing that is it handed
// to the profile service to resolve as a contact; operations never reads it.
func (b *paymentRoutingBusiness) clientForContact(ctx context.Context, payerRef string) (string, error) {
	if b.clients.LenderIdentity == nil {
		return "", errBorrowerLoanAmbiguous
	}
	if clientID, err := b.clientForProfile(ctx, payerRef); err == nil {
		return clientID, nil
	}
	if b.clients.ProfileClient == nil {
		return "", errBorrowerLoanAmbiguous
	}
	profile, err := b.clients.ProfileClient.GetByContact(ctx, &profilev1.GetByContactRequest{Contact: payerRef})
	if err != nil {
		return "", fmt.Errorf("profile for payer: %w", err)
	}
	if profile.GetData().GetId() == "" {
		return "", errBorrowerLoanAmbiguous
	}
	return b.clientForProfile(ctx, profile.GetData().GetId())
}

// clientForProfile returns the one client registered on profileID.
func (b *paymentRoutingBusiness) clientForProfile(ctx context.Context, profileID string) (string, error) {
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

// repayableLoansOf lists the client's loans of the product that can take a
// repayment.
func (b *paymentRoutingBusiness) repayableLoansOf(
	ctx context.Context,
	clientID, productID string,
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
			if loan.GetClientId() == clientID && loan.GetProductId() == productID && loanTakesRepayments(loan) {
				out = append(out, loan)
			}
		}
	}
}

func loanTakesRepayments(loan *loansv1.LoanAccountObject) bool {
	switch loan.GetStatus() { //nolint:exhaustive // only repayable statuses matter
	case loansv1.LoanStatus_LOAN_STATUS_ACTIVE, loansv1.LoanStatus_LOAN_STATUS_DELINQUENT,
		loansv1.LoanStatus_LOAN_STATUS_DEFAULT, loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED,
		loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF:
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
			fieldPaymentID:        paymentID,
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
	execution := b.executeRepayment(ctx, logger, to.GetID())

	return map[string]interface{}{
		fieldPaymentID:       paymentID,
		fieldCurrency:        payment.Currency,
		fieldClientID:        clientID,
		fieldLoanID:          loanID,
		fieldTotalAmount:     payment.Amount,
		fieldAllocatedAmount: payment.Amount,
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
		fieldPaymentState: paymentState,
		fieldExecution:    execution,
	}, nil
}

// Execution outcomes of a borrower repayment order, as allocation reports
// them.
const (
	executionPosted  = "posted"
	executionPending = "pending"
)

// executeRepayment posts the repayment order at once, so the loan shows the
// payment while the borrower waits. The allocation already stands: if the
// post fails the order stays raised and the settle job posts it later.
func (b *paymentRoutingBusiness) executeRepayment(
	ctx context.Context,
	logger *util.LogEntry,
	orderID string,
) string {
	if b.executor == nil {
		return executionPending
	}
	if err := b.executor.Execute(ctx, orderID); err != nil {
		logger.WithError(err).WithField("transfer_order_id", orderID).
			Warn("borrower repayment not posted yet; the settle job retries")
		return executionPending
	}
	return executionPosted
}

// isBorrowerLoanPayment reports whether a payment was matched to a loan.
func isBorrowerLoanPayment(payment *models.IncomingPayment) bool {
	return strings.EqualFold(payment.OwnerType, ownerTypeClientLoan)
}
