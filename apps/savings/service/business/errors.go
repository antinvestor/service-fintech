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

import "github.com/antinvestor/service-fintech/pkg/apperrors"

var (
	ErrDepositRecordInternalOnly = apperrors.NewError(apperrors.Forbidden,
		"deposits are recorded by the payment rail from the saver's own payment")
	ErrPayoutOutcomeInternalOnly = apperrors.NewError(apperrors.Forbidden,
		"payout outcomes are reported only by internal services")
	ErrCashDepositRefused = apperrors.NewError(apperrors.BadRequest,
		"cash deposits are not taken: savers pay from their own mobile money")
	ErrSavingsProductNotFound   = apperrors.NewError(apperrors.NotFound, "savings product not found")
	ErrSavingsAccountNotFound   = apperrors.NewError(apperrors.NotFound, "savings account not found")
	ErrDepositNotFound          = apperrors.NewError(apperrors.NotFound, "deposit not found")
	ErrWithdrawalNotFound       = apperrors.NewError(apperrors.NotFound, "withdrawal not found")
	ErrWithdrawalPayoutRejected = apperrors.NewError(apperrors.Unprocessable,
		"the payout was rejected; the withdrawal is rejected and the held amount released")
	ErrWithdrawalNeedsIndividualOwner = apperrors.NewError(apperrors.Unprocessable,
		"only an individually owned savings account can be paid out through the payment rail")
	ErrInterestAccrualNotFound = apperrors.NewError(apperrors.NotFound, "interest accrual not found")
	ErrAccountFrozen           = apperrors.NewError(apperrors.Unprocessable, "savings account is frozen")
	ErrAccountClosed           = apperrors.NewError(apperrors.Unprocessable, "savings account is closed")
	ErrInsufficientBalance     = apperrors.NewError(apperrors.Unprocessable, "insufficient balance for withdrawal")
	ErrInvalidStatusTransition = apperrors.NewError(apperrors.Unprocessable, "invalid status transition")
	ErrDuplicateIdempotencyKey = apperrors.NewError(apperrors.Conflict, "duplicate idempotency key")
	ErrAccountNotActive        = apperrors.NewError(apperrors.Unprocessable, "savings account is not active")
	ErrProductRateZero         = apperrors.NewError(apperrors.Unprocessable, "product interest rate is zero")
	ErrBalanceZero             = apperrors.NewError(apperrors.Unprocessable, "savings account balance is zero")
	ErrAccrualAmountZero       = apperrors.NewError(apperrors.Unprocessable, "computed accrual amount is zero")
	ErrBalanceNotProvisioned   = apperrors.NewError(
		apperrors.Unprocessable, "savings account has no balance record")

	ErrIdempotencyKeyRequired = apperrors.NewError(apperrors.BadRequest, "idempotency_key is required")
	ErrAmountCurrencyRequired = apperrors.NewError(apperrors.BadRequest, "amount currency_code is required")
	ErrCurrencyMismatch       = apperrors.NewError(
		apperrors.BadRequest, "amount currency does not match the account currency")
	ErrAmountNotPositive    = apperrors.NewError(apperrors.BadRequest, "amount must be positive")
	ErrProductNotForAccount = apperrors.NewError(
		apperrors.BadRequest, "account currency does not match the product currency")
	ErrAccountHasBalance = apperrors.NewError(
		apperrors.Unprocessable, "savings account cannot be closed while it holds funds or open reservations")
	ErrSavingsAccountLedgerRefsMissing = apperrors.NewError(
		apperrors.Unprocessable, "savings account is missing product routing information")
)
