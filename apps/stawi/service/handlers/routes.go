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

// Package handlers exposes stawi over Connect (StawiService) and the plain
// JSON route members' apps answer loan offers on.
package handlers

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// LoanOfferResponder records a member's answer to a loan offer.
type LoanOfferResponder interface {
	Respond(ctx context.Context, groupID, offerID string, response int32) (*models.LoanOffer, error)
}

// RegisterRoutes registers stawi's plain JSON routes.
func RegisterRoutes(mux *http.ServeMux, offers LoanOfferResponder) {
	mux.HandleFunc("POST /api/v1/groups/{groupId}/loan-offers/{offerId}/respond", handleRespondOffer(offers))
}

// offerResponseBody is the member's answer to a loan offer.
type offerResponseBody struct {
	Response int32 `json:"response"`
}

func handleRespondOffer(offers LoanOfferResponder) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var body offerResponseBody
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			respond(w, r, "respond-loan-offer", nil,
				apperrors.NewError(apperrors.BadRequest, "request body is not valid JSON"))
			return
		}
		groupID, offerID := r.PathValue("groupId"), r.PathValue("offerId")
		offer, err := offers.Respond(r.Context(), groupID, offerID, body.Response)
		respond(w, r, "respond-loan-offer", offerResult(offerID, body.Response, offer), err)
	}
}

// offerResult is the reply to an answered offer. An accepted offer whose
// loan is still being made reads "pending"; the member is told when it is
// paid or refused.
func offerResult(offerID string, response int32, offer *models.LoanOffer) map[string]any {
	result := map[string]any{"offer_id": offerID, "response": response}
	if offer != nil {
		result["origination_status"] = offer.OriginationStatus
		result["loan_account_id"] = offer.LoanAccountID
	}
	return result
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
// ids or a payer's name, is logged here and never reaches the caller.
func writeError(ctx context.Context, w http.ResponseWriter, handler string, err error) {
	status, message := classifyError(err)
	code := errorCodeForStatus(status)

	log := util.Log(ctx).WithField("handler", handler).WithField("status", status).WithError(err)
	if status >= http.StatusInternalServerError {
		log.Error("request failed")
	} else {
		log.Info("request rejected")
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
