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

	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
)

// A saver's mobile-money payment is matched to their own savings account in
// the same way a borrower's is matched to their loan: by the account id the
// payer quoted, or by the payer's profile to their one open account of the
// product the rail credited. The deposit is then recorded with the savings
// service; nobody types a deposit amount.
const (
	strategyBorrowerSavings = "borrower_savings"
	ownerTypeClientSavings  = "client_savings"
	payableTypeSavings      = "savings"
	fieldSavingsAccountID   = "savings_account_id"
)

var errSaverAmbiguous = errors.New("payer has no single open savings account")

// borrowerSavingsMatching reports whether the clients the strategy needs
// are configured.
func (b *paymentRoutingBusiness) borrowerSavingsMatching() bool {
	return b.clients != nil && b.clients.LenderSavings != nil
}

// identifySaverAccount resolves a payment to a saver's own savings account
// of the product the rail credited.
func (b *paymentRoutingBusiness) identifySaverAccount(
	ctx context.Context,
	productID, paymentRef, payerRef string,
) (*identificationResult, error) {
	if productID == "" {
		return nil, errSaverAmbiguous
	}
	if paymentRef != "" {
		acct, err := b.openSavingsAccount(ctx, paymentRef)
		if err == nil && acct.GetProductId() == productID {
			return b.saverResult(ctx, acct)
		}
		if isTransientLookupError(err) {
			return nil, err
		}
	}
	if payerRef == "" {
		return nil, errSaverAmbiguous
	}
	clientID, err := b.clientForContact(ctx, payerRef)
	if err != nil {
		return nil, err
	}
	accounts, err := b.openSavingsAccountsOf(ctx, clientID, productID)
	if err != nil {
		return nil, err
	}
	if len(accounts) != 1 {
		return nil, errSaverAmbiguous
	}
	return b.saverResult(ctx, accounts[0])
}

func (b *paymentRoutingBusiness) saverResult(
	ctx context.Context,
	acct *savingsv1.SavingsAccountObject,
) (*identificationResult, error) {
	result := &identificationResult{
		Strategy:         strategyBorrowerSavings,
		ClientID:         acct.GetOwnerId(),
		SavingsAccountID: acct.GetId(),
		ProductID:        acct.GetProductId(),
	}
	result.ProfileID = b.profileOfClient(ctx, acct.GetOwnerId())
	return result, nil
}

// openSavingsAccount loads an individual's savings account that can take a
// deposit.
func (b *paymentRoutingBusiness) openSavingsAccount(
	ctx context.Context,
	accountID string,
) (*savingsv1.SavingsAccountObject, error) {
	resp, err := b.clients.LenderSavings.SavingsAccountGet(ctx, &savingsv1.SavingsAccountGetRequest{Id: accountID})
	if err != nil {
		return nil, err
	}
	if !takesDeposits(resp.GetData()) {
		return nil, errSaverAmbiguous
	}
	return resp.GetData(), nil
}

// openSavingsAccountsOf lists the client's open individual accounts of the
// product.
func (b *paymentRoutingBusiness) openSavingsAccountsOf(
	ctx context.Context,
	clientID, productID string,
) ([]*savingsv1.SavingsAccountObject, error) {
	stream, err := b.clients.LenderSavings.SavingsAccountSearch(ctx,
		&savingsv1.SavingsAccountSearchRequest{OwnerId: clientID, ProductId: productID})
	if err != nil {
		return nil, fmt.Errorf("savings accounts of payer: %w", err)
	}
	defer func() { _ = stream.Close() }()
	var out []*savingsv1.SavingsAccountObject
	for {
		msg, recvErr := stream.Receive()
		if errors.Is(recvErr, io.EOF) {
			break
		}
		if recvErr != nil {
			return nil, fmt.Errorf("savings accounts of payer: %w", recvErr)
		}
		for _, acct := range msg.GetData() {
			if acct.GetOwnerId() == clientID && acct.GetProductId() == productID && takesDeposits(acct) {
				out = append(out, acct)
			}
		}
	}
	return out, nil
}

// takesDeposits is true for an open account a single person owns: a group's
// account is paid through the group's own collections.
func takesDeposits(acct *savingsv1.SavingsAccountObject) bool {
	return acct.GetStatus() == savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_ACTIVE &&
		acct.GetOwnerType() == savingsv1.SavingsAccountOwnerType_SAVINGS_ACCOUNT_OWNER_TYPE_INDIVIDUAL
}

// isBorrowerSavingsPayment reports whether a payment was matched to a
// saver's account.
func isBorrowerSavingsPayment(payment *models.IncomingPayment) bool {
	return strings.EqualFold(payment.OwnerType, ownerTypeClientSavings)
}

// allocateToSavings records the whole payment as a deposit to the saver's
// account. The savings service posts it from the product's collection
// account, where the rail put the money, and the deposit is keyed by the
// payment so a retry never deposits twice.
func (b *paymentRoutingBusiness) allocateToSavings(
	ctx context.Context,
	logger *util.LogEntry,
	payment *models.IncomingPayment,
	lease time.Time,
) (map[string]interface{}, error) {
	paymentID := payment.GetID()
	accountID := payment.PayableID
	if payment.OwnerID == "" || accountID == "" {
		b.releaseAllocationLease(ctx, logger, paymentID, lease)
		return nil, fmt.Errorf("payment %s is missing its saver or savings account", paymentID)
	}
	if !b.borrowerSavingsMatching() {
		b.releaseAllocationLease(ctx, logger, paymentID, lease)
		return nil, ErrPaymentAssignUnavailable
	}

	resp, err := b.clients.LenderSavings.DepositRecord(ctx, &savingsv1.DepositRecordRequest{
		SavingsAccountId: accountID,
		Amount:           moneyx.FromMinorUnitsByCurrency(payment.Currency, payment.Amount),
		PaymentReference: paymentID,
		Channel:          channelMobileMoney,
		// The saver is named by profile, never by the number they paid from.
		PayerReference: payment.Properties.GetString(fieldProfileID),
		IdempotencyKey: fmt.Sprintf("payment:%s:savings:%s", paymentID, accountID),
	})
	if err != nil {
		b.releaseAllocationLease(ctx, logger, paymentID, lease)
		return nil, fmt.Errorf("record savings deposit for payment %s: %w", paymentID, err)
	}

	paymentState := resolvePaymentState(0, payment.Amount)
	if _, outcomeErr := b.ipRepo.SetAllocationOutcome(ctx, paymentID, lease, paymentState, 0); outcomeErr != nil {
		logger.WithError(outcomeErr).Error("failed to record savings allocation outcome")
	}
	logger.WithField(fieldSavingsAccountID, accountID).WithField("deposit_id", resp.GetData().GetId()).
		Info("payment deposited to savings")

	return map[string]interface{}{
		fieldPaymentID:        paymentID,
		fieldCurrency:         payment.Currency,
		fieldClientID:         payment.OwnerID,
		fieldSavingsAccountID: accountID,
		"deposit_id":          resp.GetData().GetId(),
		fieldTotalAmount:      payment.Amount,
		fieldAllocatedAmount:  payment.Amount,
		fieldRemainingAmount:  int64(0),
		fieldPaymentState:     paymentState,
	}, nil
}
