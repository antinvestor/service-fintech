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

package handlers

import (
	"net/http"
	"strings"

	fundingbusiness "github.com/antinvestor/service-fintech/apps/funding/service/business"
	opsbusiness "github.com/antinvestor/service-fintech/apps/operations/service/business"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// --- Period close and reconciliation ---

func handleFreezePeriod(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		period, err := biz.Period.Freeze(r.Context(), r.PathValue(paramPeriodID))
		if err != nil {
			respond(w, r, "freeze-period", nil, err)
			return
		}
		respond(w, r, "freeze-period", periodResponse(period), nil)
	}
}

func handleExtendPeriod(biz Businesses) http.HandlerFunc {
	type extendReq struct {
		Reason string `json:"reason"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		var req extendReq
		if err := decodeBody(r, &req); err != nil {
			respond(w, r, "extend-period", nil, err)
			return
		}
		period, err := biz.Period.Extend(r.Context(), r.PathValue(paramPeriodID), req.Reason)
		if err != nil {
			respond(w, r, "extend-period", nil, err)
			return
		}
		respond(w, r, "extend-period", periodResponse(period), nil)
	}
}

func handleReconcilePeriod(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		result, err := biz.Obligation.ReconcilePeriod(r.Context(), r.PathValue(paramPeriodID))
		respond(w, r, "reconcile-period", result, err)
	}
}

func handleCalculatePenalties(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		result, err := biz.Obligation.CalculatePenaltiesForPeriod(r.Context(), r.PathValue(paramPeriodID))
		respond(w, r, "calculate-penalties", result, err)
	}
}

func handleOutstandingObligations(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		result, err := biz.Obligation.OutstandingForPeriod(r.Context(), r.PathValue(paramPeriodID))
		respond(w, r, "outstanding-obligations", result, err)
	}
}

func handleCheckMemberObligations(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		result, err := biz.Obligation.CheckForMember(r.Context(), r.PathValue(paramMemberID))
		respond(w, r, "check-obligations", result, err)
	}
}

// --- Suspense and payment confirmation ---

func handleSuspenseDeposit(biz Businesses) http.HandlerFunc {
	type depositReq struct {
		TransactionID    string `json:"transaction_id"`
		Amount           int64  `json:"amount"`
		Currency         string `json:"currency"`
		SenderIdentifier string `json:"sender_identifier"`
		Reference        string `json:"reference"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		var req depositReq
		if err := decodeBody(r, &req); err != nil {
			respond(w, r, "suspense-deposit", nil, err)
			return
		}
		result, err := biz.Payment.RecordSuspenseDeposit(r.Context(), opsbusiness.SuspenseDeposit{
			GroupID:          r.PathValue(paramGroupID),
			TransactionID:    req.TransactionID,
			Amount:           req.Amount,
			Currency:         req.Currency,
			SenderIdentifier: req.SenderIdentifier,
			Reference:        req.Reference,
		})
		respond(w, r, "suspense-deposit", result, err)
	}
}

func handleSuspenseBalance(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		result, err := biz.Payment.SuspenseBalance(r.Context(), r.PathValue(paramMemberID))
		respond(w, r, "suspense-balance", result, err)
	}
}

func handleApplySuspense(biz Businesses) http.HandlerFunc {
	type applyReq struct {
		PeriodID  string `json:"period_id"`
		MaxAmount int64  `json:"max_amount"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		var req applyReq
		if err := decodeBody(r, &req); err != nil {
			respond(w, r, "apply-suspense", nil, err)
			return
		}
		result, err := biz.Payment.ApplySuspense(r.Context(), r.PathValue(paramMemberID), req.MaxAmount)
		respond(w, r, "apply-suspense", result, err)
	}
}

func handleConfirmPayment(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		result, err := biz.Payment.ConfirmPayment(r.Context(), r.PathValue("transactionId"))
		respond(w, r, "confirm-payment", result, err)
	}
}

func handleTransferFailure(biz Businesses) http.HandlerFunc {
	type failureReq struct {
		Reference     string `json:"reference"`
		TransactionID string `json:"transaction_id"`
		Error         string `json:"error"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		var req failureReq
		if err := decodeBody(r, &req); err != nil {
			respond(w, r, "transfer-failure", nil, err)
			return
		}
		reference := strings.TrimSpace(req.Reference)
		if reference == "" {
			respond(w, r, "transfer-failure", nil,
				apperrors.NewError(apperrors.BadRequest, "reference is required"))
			return
		}
		result, err := biz.TransferOrder.RecordFailure(r.Context(), reference, req.Error)
		respond(w, r, "transfer-failure", result, err)
	}
}

// --- Loan origination edges ---

func handleLoanEligibility(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		result, err := biz.LoanOffer.CheckEligibility(
			r.Context(), r.PathValue(paramGroupID), r.PathValue(paramMemberID),
		)
		respond(w, r, "loan-eligibility", result, err)
	}
}

func handleGenerateSchedule(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		result, err := biz.LoanOffer.EnsureSchedule(r.Context(), r.PathValue(paramLoanID))
		respond(w, r, "generate-schedule", result, err)
	}
}

func handleDisburseLoan(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		result, err := biz.LoanOffer.Disburse(r.Context(), r.PathValue(paramLoanID))
		respond(w, r, "disburse-loan", result, err)
	}
}

// fundingResponse names the fields the origination workflow interpolates. The
// funding result is a Go struct with no json tags, so encoding it directly
// would emit Go field names the workflow never reads.
func fundingResponse(result *fundingbusiness.AllocationResult) map[string]any {
	if result == nil {
		return map[string]any{
			"funded":            false,
			"shortfall":         int64(0),
			"funding_source_id": "",
			"total_allocated":   int64(0),
			fieldCurrency:       "",
		}
	}

	fundingSourceID := result.LoanRequestID
	if len(result.Allocations) > 0 {
		fundingSourceID = result.Allocations[0].ID
	}

	return map[string]any{
		"funded":            result.FullyFunded,
		"shortfall":         result.Deficit,
		"funding_source_id": fundingSourceID,
		"total_allocated":   result.TotalAllocated,
		"loan_request_id":   result.LoanRequestID,
		"allocation_count":  len(result.Allocations),
		fieldCurrency:       result.Currency,
	}
}
