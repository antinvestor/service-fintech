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

// Package handlers exposes stawi's workflow callback endpoints.
//
// Route shapes are the contract with products/stawi/workflows/*.json: every
// http.request URL template in those definitions must resolve here. The
// contract is asserted by TestWorkflowURLsResolveAgainstMux.
package handlers

import (
	"context"
	"encoding/json"
	"net/http"
	"strings"

	"github.com/pitabwire/util"

	groupbusiness "github.com/antinvestor/service-fintech/apps/stawi/service/business"
	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// Businesses collects the domain dependencies the workflow callbacks need.
type Businesses struct {
	Group      groupbusiness.ClientGroupBusiness
	Membership groupbusiness.MembershipBusiness
	Tenure     groupbusiness.TenureBusiness
	Period     groupbusiness.PeriodBusiness
	LoanWindow LoanWindowBusiness
	LoanOffer  LoanOfferBusiness
	Obligation GroupObligationBusiness
}

// RegisterWorkflowCallbacks registers every workflow callback HTTP endpoint.
func RegisterWorkflowCallbacks(mux *http.ServeMux, biz Businesses) {
	// Group lifecycle.
	mux.HandleFunc("POST /api/v1/groups/{groupId}/check-formation", handleCheckFormation(biz))
	mux.HandleFunc("POST /api/v1/groups/{groupId}/setup-ledger", handleSetupLedger(biz))
	mux.HandleFunc("POST /api/v1/groups/{groupId}/register-lender", handleRegisterLender(biz))
	mux.HandleFunc("POST /api/v1/groups/{groupId}/welcome", handleWelcomeGroup(biz))
	mux.HandleFunc("POST /api/v1/groups/{groupId}/create-tenure", handleCreateTenure(biz))
	mux.HandleFunc("POST /api/v1/groups/{groupId}/open-period", handleOpenPeriod(biz))
	mux.HandleFunc("POST /api/v1/groups/{groupId}/transition", handleGroupTransition(biz))

	// Membership reads.
	mux.HandleFunc("GET /api/v1/groups/{groupId}/members", handleListMembers(biz))

	// Period lifecycle.
	mux.HandleFunc("POST /api/v1/groups/{groupId}/periods/{periodId}/close", handleClosePeriod(biz))
	mux.HandleFunc(
		"POST /api/v1/groups/{groupId}/periods/{periodId}/calculate-obligations",
		handleCalculateObligations(biz),
	)
	mux.HandleFunc("POST /api/v1/groups/{groupId}/evaluate-loan-window", handleEvaluateLoanWindow(biz))
	mux.HandleFunc("POST /api/v1/groups/{groupId}/loan-window/open", handleOpenLoanWindow(biz))

	// Loan offers.
	mux.HandleFunc(
		"POST /api/v1/groups/{groupId}/loan-offers/{offerId}/respond",
		handleRespondOffer(biz),
	)
	mux.HandleFunc("POST /api/v1/groups/{groupId}/loans", handleCreateLoanAccount(biz))

	registerPeriodRoutes(mux, biz)
}

// registerPeriodRoutes wires the period close and reconciliation callbacks.
func registerPeriodRoutes(mux *http.ServeMux, biz Businesses) {
	mux.HandleFunc("POST /api/v1/groups/{groupId}/periods/{periodId}/freeze", handleFreezePeriod(biz))
	mux.HandleFunc("POST /api/v1/groups/{groupId}/periods/{periodId}/extend", handleExtendPeriod(biz))
	mux.HandleFunc("POST /api/v1/groups/{groupId}/periods/{periodId}/reconcile", handleReconcilePeriod(biz))
}

// --- Group lifecycle ---

func handleCheckFormation(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		groupID := r.PathValue(paramGroupID)
		result, err := biz.Group.CheckFormation(r.Context(), groupID)
		respond(w, r, "check-formation", result, err)
	}
}

func handleSetupLedger(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		err := biz.Group.SetupLedgerAccounts(r.Context(), r.PathValue(paramGroupID))
		respond(w, r, "setup-ledger", statusOK(), err)
	}
}

func handleRegisterLender(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		err := biz.Group.RegisterWithLender(r.Context(), r.PathValue(paramGroupID))
		respond(w, r, "register-lender", statusOK(), err)
	}
}

func handleWelcomeGroup(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		err := biz.Group.WelcomeGroup(r.Context(), r.PathValue(paramGroupID))
		respond(w, r, "welcome-group", statusOK(), err)
	}
}

func handleCreateTenure(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		tenure, err := biz.Tenure.Open(r.Context(), r.PathValue(paramGroupID))
		if err != nil {
			respond(w, r, "create-tenure", nil, err)
			return
		}
		respond(w, r, "create-tenure", tenureResponse(tenure), nil)
	}
}

func handleOpenPeriod(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		period, err := biz.Period.Open(r.Context(), r.PathValue(paramGroupID))
		if err != nil {
			respond(w, r, "open-period", nil, err)
			return
		}
		respond(w, r, "open-period", periodResponse(period), nil)
	}
}

func handleGroupTransition(biz Businesses) http.HandlerFunc {
	type transitionReq struct {
		State  int32  `json:"state"`
		Reason string `json:"reason"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		var req transitionReq
		if err := decodeBody(r, &req); err != nil {
			respond(w, r, "group-transition", nil, err)
			return
		}
		err := biz.Group.Transition(r.Context(), r.PathValue(paramGroupID), req.State, req.Reason)
		respond(w, r, "group-transition", statusOK(), err)
	}
}

func handleListMembers(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		members, err := biz.Membership.GetByGroupID(ctx, r.PathValue(paramGroupID))
		if err != nil {
			respond(w, r, "list-members", nil, err)
			return
		}

		onlyActive := strings.EqualFold(r.URL.Query().Get("status"), "active")
		result := make([]map[string]any, 0, len(members))
		for _, m := range members {
			if onlyActive && int32(m.GetState()) != int32(constants.StateActive) {
				continue
			}
			result = append(result, map[string]any{
				"id":              m.GetId(),
				fieldGroupID:      m.GetGroupId(),
				"profile_id":      m.GetProfileId(),
				"membership_type": m.GetMembershipType(),
				fieldState:        int32(m.GetState()),
			})
		}
		respond(w, r, "list-members", membersResponse(result), nil)
	}
}

// --- Period lifecycle ---

func handleClosePeriod(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		err := biz.Period.Close(r.Context(), r.PathValue(paramPeriodID))
		respond(w, r, "close-period", statusOK(), err)
	}
}

func handleCalculateObligations(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		result, err := biz.Obligation.Raise(r.Context(), r.PathValue(paramGroupID), r.PathValue(paramPeriodID))
		respond(w, r, "calculate-obligations", result, err)
	}
}

func handleEvaluateLoanWindow(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		result, err := biz.LoanWindow.Evaluate(r.Context(), r.PathValue(paramGroupID))
		respond(w, r, "evaluate-loan-window", result, err)
	}
}

func handleOpenLoanWindow(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		window, err := biz.LoanWindow.Open(r.Context(), r.PathValue(paramGroupID))
		if err != nil {
			respond(w, r, "open-loan-window", nil, err)
			return
		}
		respond(w, r, "open-loan-window", loanWindowResponse(window), nil)
	}
}

// --- Loan offers ---

// offerResponseBody is the member's answer to a loan offer.
type offerResponseBody struct {
	Response int32 `json:"response"`
}

func handleRespondOffer(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var body offerResponseBody
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			respond(w, r, "respond-loan-offer", nil,
				apperrors.NewError(apperrors.BadRequest, "request body is not valid JSON"))
			return
		}
		offerID := r.PathValue("offerId")
		offer, err := biz.LoanOffer.Respond(r.Context(), r.PathValue(paramGroupID), offerID, body.Response)
		result := map[string]any{"offer_id": offerID, "response": body.Response}
		if offer != nil {
			// An accepted offer whose loan is still being made reads
			// "pending"; the member is told when it is paid or refused.
			result["origination_status"] = offer.OriginationStatus
			result["loan_account_id"] = offer.LoanAccountID
		}
		respond(w, r, "respond-loan-offer", result, err)
	}
}

func handleCreateLoanAccount(biz Businesses) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			OfferID string `json:"offer_id"`
		}
		if err := decodeBody(r, &req); err != nil {
			respond(w, r, "create-loan-account", nil, err)
			return
		}
		if strings.TrimSpace(req.OfferID) == "" {
			respond(w, r, "create-loan-account", nil,
				apperrors.NewError(apperrors.BadRequest, "offer_id is required"))
			return
		}
		result, err := biz.LoanOffer.CreateLoanAccount(r.Context(), r.PathValue(paramGroupID), req.OfferID)
		if result != nil {
			// loan_id is the short name callers read for the loan account.
			result["loan_id"] = result["loan_account_id"]
		}
		respond(w, r, "create-loan-account", result, err)
	}
}

// --- Response plumbing ---

func statusOK() map[string]any { return map[string]any{fieldStatus: "ok"} }

// loanWindowResponse names the fields the period workflow interpolates from an
// opened loan window.
func loanWindowResponse(w *models.LoanWindow) map[string]any {
	return map[string]any{
		"loan_window_id":  w.GetID(),
		fieldGroupID:      w.GroupID,
		"period_id":       w.PeriodID,
		fieldPosition:     w.Position,
		"periodic_amount": w.PeriodicAmount,
		"leverage":        w.LeverageHundredths,
		fieldCurrency:     w.Currency,
	}
}

// membersResponse wraps a member listing in the envelope the savings workflow
// iterates over.
func membersResponse(members []map[string]any) map[string]any {
	return map[string]any{"members": members, "count": len(members)}
}

// periodResponse names the fields the period workflow interpolates. The model
// itself has no json tags, so encoding it directly would emit Go field names.
func periodResponse(p *models.Period) map[string]any {
	return map[string]any{
		"period_id":   p.GetID(),
		fieldGroupID:  p.GroupID,
		"tenure_id":   p.TenureID,
		"start_date":  p.StartDate,
		"end_date":    p.EndDate,
		fieldPosition: p.Position,
		fieldState:    p.State,
	}
}

func tenureResponse(t *models.Tenure) map[string]any {
	return map[string]any{
		"tenure_id":   t.GetID(),
		fieldGroupID:  t.GroupID,
		"start_date":  t.StartDate,
		"end_date":    t.EndDate,
		"duration":    t.Duration,
		fieldPosition: t.Position,
		fieldState:    t.State,
	}
}

// decodeBody reads an optional JSON body. Workflow steps often post nothing at
// all, so an empty body is not an error.
func decodeBody(r *http.Request, target any) error {
	if r.Body == nil {
		return nil
	}
	err := json.NewDecoder(r.Body).Decode(target)
	if err != nil {
		if strings.Contains(err.Error(), "EOF") {
			return nil
		}
		return apperrors.NewError(apperrors.BadRequest, "request body is not valid JSON")
	}
	return nil
}

// respond writes a JSON body, or maps the error onto an HTTP status through
// classifyError so permanent failures are not retried as if they were
// transient.
func respond(w http.ResponseWriter, r *http.Request, handler string, payload any, err error) {
	ctx := r.Context()
	if err != nil {
		writeError(ctx, w, handler, err)
		return
	}
	writeJSON(ctx, w, http.StatusOK, payload)
}

// writeError maps an error onto an HTTP status, a stable machine-readable
// code and a caller-safe message. The full error, which can carry internal
// ids or a payer's name, is logged here and never reaches the workflow
// engine. Permanent failures (4xx) stop the engine's retry policy; only 5xx
// responses are retried.
func writeError(ctx context.Context, w http.ResponseWriter, handler string, err error) {
	status, message := classifyError(err)
	code := errorCodeForStatus(status)

	log := util.Log(ctx).WithField(logKeyHandler, handler).WithField("status", status).WithError(err)
	if status >= http.StatusInternalServerError {
		log.Error("workflow callback failed")
	} else {
		log.Info("workflow callback rejected")
	}

	writeJSON(ctx, w, status, errorBody{Error: message, Code: code})
}

// errorBody is the JSON shape every stawi error response uses.
type errorBody struct {
	Error string `json:"error"`
	Code  string `json:"code,omitempty"`
}

func writeJSON(ctx context.Context, w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if payload == nil {
		return
	}
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		util.Log(ctx).WithError(err).Warn("failed to encode JSON response")
	}
}
