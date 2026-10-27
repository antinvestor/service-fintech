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
	"strings"
	"time"

	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
)

// An investor's payment is matched to their investor account only when the
// payer quoted that account's id and the money came from the investor's own
// profile: capital is never credited on a reference alone. The deposit is
// then recorded with the funding service; nobody types an amount.
const (
	strategyInvestorDeposit  = "investor_deposit"
	ownerTypeInvestorAccount = "investor_account"
	payableTypeInvestor      = "investor_account"
	fieldInvestorAccountID   = "investor_account_id"
)

var errInvestorNotMatched = errors.New("payment is not an investor's own deposit")

// investorDepositMatching reports whether the clients the strategy needs
// are configured.
func (b *paymentRoutingBusiness) investorDepositMatching() bool {
	return b.clients != nil && b.clients.LenderFunding != nil && b.clients.LenderRegistry != nil
}

// identifyInvestorDeposit resolves a payment quoting an investor account to
// that account, when the payer is the investor.
func (b *paymentRoutingBusiness) identifyInvestorDeposit(
	ctx context.Context,
	paymentRef, payerRef, currency string,
) (*identificationResult, error) {
	if paymentRef == "" || payerRef == "" {
		return nil, errInvestorNotMatched
	}
	acct, err := b.clients.LenderFunding.InvestorAccountGet(ctx, &fundingv1.InvestorAccountGetRequest{Id: paymentRef})
	if err != nil || acct.GetData().GetInvestorId() == "" {
		return nil, errInvestorNotMatched
	}
	if accountCurrency := acct.GetData().GetAvailableBalance().GetCurrencyCode(); accountCurrency != "" &&
		!strings.EqualFold(accountCurrency, currency) {
		return nil, errInvestorNotMatched
	}
	investor, err := b.clients.LenderRegistry.InvestorGet(ctx,
		&identityv1.InvestorGetRequest{Id: acct.GetData().GetInvestorId()})
	if err != nil || investor.GetData().GetProfileId() == "" {
		return nil, errInvestorNotMatched
	}
	profileID := investor.GetData().GetProfileId()
	if !b.payerIsProfile(ctx, payerRef, profileID) {
		return nil, errInvestorNotMatched
	}
	return &identificationResult{
		Strategy:          strategyInvestorDeposit,
		ProfileID:         profileID,
		InvestorAccountID: acct.GetData().GetId(),
		InvestorOwnerID:   acct.GetData().GetInvestorId(),
	}, nil
}

// payerIsProfile reports whether the payer reference names profileID: the
// rail names payers by profile id; a notifier may name them by contact,
// which the profile service resolves.
func (b *paymentRoutingBusiness) payerIsProfile(ctx context.Context, payerRef, profileID string) bool {
	if payerRef == profileID {
		return true
	}
	if b.clients.ProfileClient == nil {
		return false
	}
	found, err := b.clients.ProfileClient.GetByContact(ctx, &profilev1.GetByContactRequest{Contact: payerRef})
	return err == nil && found.GetData().GetId() == profileID
}

// isInvestorDepositPayment reports whether a payment was matched to an
// investor account.
func isInvestorDepositPayment(payment *models.IncomingPayment) bool {
	return strings.EqualFold(payment.OwnerType, ownerTypeInvestorAccount)
}

// allocateToInvestor records the whole payment as capital in the investor's
// account, keyed by the payment so a retry never deposits twice.
func (b *paymentRoutingBusiness) allocateToInvestor(
	ctx context.Context,
	logger *util.LogEntry,
	payment *models.IncomingPayment,
	lease time.Time,
) (map[string]interface{}, error) {
	paymentID := payment.GetID()
	accountID := payment.PayableID
	if accountID == "" {
		b.releaseAllocationLease(ctx, logger, paymentID, lease)
		return nil, fmt.Errorf("payment %s is missing its investor account", paymentID)
	}
	if !b.investorDepositMatching() {
		b.releaseAllocationLease(ctx, logger, paymentID, lease)
		return nil, ErrPaymentAssignUnavailable
	}

	if _, err := b.clients.LenderFunding.InvestorDeposit(ctx, &fundingv1.InvestorDepositRequest{
		AccountId:      accountID,
		Amount:         moneyx.FromMinorUnitsByCurrency(payment.Currency, payment.Amount),
		IdempotencyKey: fmt.Sprintf("payment:%s:investor:%s", paymentID, accountID),
	}); err != nil {
		b.releaseAllocationLease(ctx, logger, paymentID, lease)
		return nil, fmt.Errorf("record investor deposit for payment %s: %w", paymentID, err)
	}

	paymentState := resolvePaymentState(0, payment.Amount)
	if _, outcomeErr := b.ipRepo.SetAllocationOutcome(ctx, paymentID, lease, paymentState, 0); outcomeErr != nil {
		logger.WithError(outcomeErr).Error("failed to record investor allocation outcome")
	}
	logger.WithField(fieldInvestorAccountID, accountID).Info("payment deposited to investor capital")

	return map[string]interface{}{
		fieldPaymentID:         paymentID,
		fieldCurrency:          payment.Currency,
		fieldInvestorAccountID: accountID,
		fieldTotalAmount:       payment.Amount,
		fieldAllocatedAmount:   payment.Amount,
		fieldRemainingAmount:   int64(0),
		fieldPaymentState:      paymentState,
	}, nil
}
