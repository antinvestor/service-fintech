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

import "net/http"

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

// --- Suspense ---

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
