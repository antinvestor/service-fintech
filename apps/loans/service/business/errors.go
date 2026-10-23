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
	ErrLoanProductNotFound       = apperrors.NewError(apperrors.NotFound, "loan product not found")
	ErrLoanAccountNotFound       = apperrors.NewError(apperrors.NotFound, "loan account not found")
	ErrRepaymentNotFound         = apperrors.NewError(apperrors.NotFound, "repayment not found")
	ErrRepaymentAmountInvalid    = apperrors.NewError(apperrors.BadRequest, "repayment amount must be positive")
	ErrRepaymentCurrencyMismatch = apperrors.NewError(
		apperrors.BadRequest,
		"repayment currency does not match the loan currency",
	)
	ErrLoanNotRepayable = apperrors.NewError(
		apperrors.Unprocessable,
		"the loan is not in a state that accepts repayments",
	)
	ErrRepaymentPostingFailed = apperrors.NewError(
		apperrors.ServiceUnavailable,
		"the repayment could not be posted to the ledger; retry with the same idempotency key",
	)
	ErrPenaltyNotFound     = apperrors.NewError(apperrors.NotFound, "penalty not found")
	ErrRestructureNotFound = apperrors.NewError(apperrors.NotFound, "loan restructure not found")
	ErrScheduleNotFound    = apperrors.NewError(apperrors.NotFound, "repayment schedule not found")
	ErrBalanceNotFound     = apperrors.NewError(apperrors.NotFound, "loan balance not found")
	ErrLoanNotOwned        = apperrors.NewError(
		apperrors.Forbidden,
		"the caller may only read loan records belonging to its own client",
	)
	ErrReadScopeUnavailable = apperrors.NewError(
		apperrors.InternalServerError,
		"client-scoped reads are not configured on this service",
	)
	ErrStatementCurrencyMismatch = apperrors.NewError(
		apperrors.Unprocessable,
		"the loan statement mixes currencies and cannot be totalled",
	)
	ErrReconciliationNotFound = apperrors.NewError(apperrors.NotFound, "reconciliation not found")

	ErrInvalidStatusTransition = apperrors.NewError(
		apperrors.Unprocessable,
		"invalid loan status transition",
	)
	ErrLoanNotActive = apperrors.NewError(
		apperrors.Unprocessable,
		"loan is not in active status",
	)
	ErrLoanNotPendingDisbursement = apperrors.NewError(
		apperrors.Unprocessable,
		"loan is not pending disbursement",
	)
	ErrRestructureNotPending = apperrors.NewError(
		apperrors.Unprocessable,
		"restructure is not in pending state",
	)
	ErrRestructureLoanAccountRequired = apperrors.NewError(
		apperrors.BadRequest,
		"a restructure must name the loan account it applies to",
	)
	ErrRestructureTermsInvalid = apperrors.NewError(
		apperrors.BadRequest,
		"restructured terms must not be negative",
	)
	ErrRestructureTypeRequired = apperrors.NewError(
		apperrors.BadRequest,
		"a restructure type is required",
	)
	ErrRestructureTypeUnsupported = apperrors.NewError(
		apperrors.Gone,
		"waivers and write-offs are not settled by restructuring; "+
			"write the loan off through a status change so the loss reaches the ledger",
	)
	ErrRestructureLoanNotEligible = apperrors.NewError(
		apperrors.Unprocessable,
		"the loan is not in a state that can be restructured",
	)
	ErrRestructureNothingOutstanding = apperrors.NewError(
		apperrors.Unprocessable,
		"the loan has no outstanding principal to restructure",
	)
	ErrPenaltyAlreadyWaived       = apperrors.NewError(apperrors.Unprocessable, "penalty is already waived")
	ErrPenaltyAmountInvalid       = apperrors.NewError(apperrors.BadRequest, "penalty amount must be positive")
	ErrPenaltyLoanAccountRequired = apperrors.NewError(
		apperrors.BadRequest,
		"a penalty must name the loan account it applies to",
	)
	ErrPenaltyCurrencyMismatch = apperrors.NewError(
		apperrors.BadRequest,
		"penalty currency does not match the loan currency",
	)
	ErrPenaltyAccrualFailed = apperrors.NewError(
		apperrors.ServiceUnavailable,
		"the penalty could not be posted to the ledger",
	)

	ErrLoanRequestNotFound     = apperrors.NewError(apperrors.NotFound, "loan request not found")
	ErrLoanRequestNotSubmitted = apperrors.NewError(
		apperrors.Unprocessable,
		"loan request is not in submitted status",
	)
	ErrLoanRequestTerminal    = apperrors.NewError(apperrors.Unprocessable, "loan request is in a terminal status")
	ErrLoanRequestNotApproved = apperrors.NewError(apperrors.Unprocessable, "loan request is not approved")
	ErrLoanRequestTermsNotSet = apperrors.NewError(
		apperrors.Unprocessable,
		"loan request does not have approved terms",
	)
	ErrLoanRequestStatusNotSettable = apperrors.NewError(
		apperrors.BadRequest,
		"a loan request may only be saved as a draft or submitted; use approve, reject or cancel to decide it",
	)
	ErrLoanRequestStatusRegression = apperrors.NewError(
		apperrors.Unprocessable,
		"a loan request cannot be moved back to an earlier status",
	)
	ErrLoanRequestAmountInvalid = apperrors.NewError(
		apperrors.BadRequest,
		"the requested amount must be positive",
	)
	ErrLoanRequestTermInvalid = apperrors.NewError(
		apperrors.BadRequest,
		"the requested term must be positive",
	)
	ErrLoanRequestAmountOutOfRange = apperrors.NewError(
		apperrors.Unprocessable,
		"the requested amount is outside the loan product's permitted range",
	)
	ErrLoanRequestTermOutOfRange = apperrors.NewError(
		apperrors.Unprocessable,
		"the requested term is outside the loan product's permitted range",
	)
	ErrLoanRequestCurrencyMismatch = apperrors.NewError(
		apperrors.BadRequest,
		"the requested currency does not match the loan product's currency",
	)
	ErrLoanRequestOfferExpired = apperrors.NewError(
		apperrors.Unprocessable,
		"the loan offer has expired",
	)
	ErrClientProductAccessNotFound   = apperrors.NewError(apperrors.NotFound, "client product access not found")
	ErrClientProductAccessIncomplete = apperrors.NewError(
		apperrors.BadRequest,
		"a client product access grant must name both a client and a product",
	)
	ErrCollectionContactRequired = apperrors.NewError(
		apperrors.BadRequest,
		"a contact is required to prompt a borrower for payment",
	)
	ErrCollectionNothingOutstanding = apperrors.NewError(
		apperrors.Unprocessable,
		"the loan has nothing outstanding to collect",
	)
	ErrDataVerificationRequired = apperrors.NewError(
		apperrors.Unprocessable,
		"loan product requires data verification; set data_verification_confirmed on the loan request after verifying all required forms",
	)

	ErrDisbursementNotFound   = apperrors.NewError(apperrors.NotFound, "disbursement not found")
	ErrIdempotencyKeyRequired = apperrors.NewError(
		apperrors.BadRequest,
		"an idempotency key is required so a retry cannot move money twice",
	)
	ErrDisbursementTransferFailed = apperrors.NewError(
		apperrors.ServiceUnavailable,
		"the disbursement could not be settled; retry with the same idempotency key",
	)
	ErrOperationsClientUnavailable = apperrors.NewError(
		apperrors.ServiceUnavailable,
		"the ledger is not reachable; no money movement can be recorded",
	)
	ErrDuplicateIdempotencyKey   = apperrors.NewError(apperrors.Conflict, "duplicate idempotency key")
	ErrFundingServiceUnavailable = apperrors.NewError(
		apperrors.ServiceUnavailable,
		"funding service is not available",
	)
	ErrFundingAllocationUnavailable = apperrors.NewError(
		apperrors.ServiceUnavailable,
		"loan funding allocation is unavailable",
	)
	ErrLoanFundingInsufficient = apperrors.NewError(
		apperrors.Unprocessable,
		"loan request is not fully funded",
	)
	ErrLoanFundingNotReady = apperrors.NewError(
		apperrors.Unprocessable,
		"loan funding is not ready for disbursement",
	)
	ErrLoanPaymentAccountMissing = apperrors.NewError(
		apperrors.Unprocessable,
		"loan payment account reference is missing",
	)
	ErrLoanLedgerAccountMissing = apperrors.NewError(
		apperrors.Unprocessable,
		"loan ledger asset account is missing",
	)

	ErrLoanProductNameRequired       = apperrors.NewError(apperrors.BadRequest, "a loan product needs a name")
	ErrLoanProductCodeRequired       = apperrors.NewError(apperrors.BadRequest, "a loan product needs a code")
	ErrLoanProductCurrencyRequired   = apperrors.NewError(apperrors.BadRequest, "a loan product needs a currency")
	ErrLoanProductAmountRangeInvalid = apperrors.NewError(
		apperrors.BadRequest,
		"the loan product's maximum amount must not be below its minimum",
	)
	ErrLoanProductTermRangeInvalid = apperrors.NewError(
		apperrors.BadRequest,
		"the loan product's maximum term must not be below its minimum",
	)
	ErrLoanProductRatesInvalid = apperrors.NewError(
		apperrors.BadRequest,
		"loan product rates must not be negative",
	)
)
