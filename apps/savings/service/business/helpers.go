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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"github.com/pitabwire/frame/v3/workerpool"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// workerpoolConsumeStream wraps workerpool.ConsumeResultStream for use in business methods.
func workerpoolConsumeStream[T any](
	ctx context.Context,
	pipe workerpool.JobResultPipe[[]T],
	consumer func(batch []T) error,
) error {
	return workerpool.ConsumeResultStream(ctx, pipe, func(res []T) error {
		return consumer(res)
	})
}

// LedgerAccountRef is the internal double-entry account a savings account's
// funds live in. It is derived from the account id rather than taken from the
// request so a caller cannot route postings at an account they do not own.
func LedgerAccountRef(sa *models.SavingsAccount) string {
	return fmt.Sprintf("savings:%s:balance", sa.GetID())
}

// PaymentAccountRef is the external cash control account a savings account
// settles against. It is derived from the product, never from the request.
func PaymentAccountRef(sa *models.SavingsAccount) string {
	return constants.ProductExternalCashAccount(sa.ProductID)
}

// assertAccountOperable rejects money movement on accounts whose state
// forbids it.
func assertAccountOperable(sa *models.SavingsAccount) error {
	switch savingsv1.SavingsAccountStatus(sa.Status) {
	case savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_FROZEN:
		return ErrAccountFrozen
	case savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_CLOSED:
		return ErrAccountClosed
	case savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_ACTIVE:
		return nil
	case savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_UNSPECIFIED:
		return ErrAccountNotActive
	default:
		return ErrAccountNotActive
	}
}

// amountInAccountCurrency converts a request amount to minor units using the
// currency's own ISO 4217 precision, rejecting any amount denominated in a
// currency other than the account's. Face-value cross-currency credits are
// never allowed.
func amountInAccountCurrency(amount *commonv1.Money, accountCurrency string) (int64, error) {
	if amount == nil || amount.GetCurrencyCode() == "" {
		return 0, ErrAmountCurrencyRequired
	}
	if amount.GetCurrencyCode() != accountCurrency {
		return 0, ErrCurrencyMismatch
	}
	minor := moneyx.ToSmallestUnit(amount, moneyx.Decimals(accountCurrency))
	if minor <= 0 {
		return 0, ErrAmountNotPositive
	}
	return minor, nil
}
