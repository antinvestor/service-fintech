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

// Package handlers exposes the seed product's customer-facing and
// internal HTTP endpoints. These are plain JSON over HTTP handlers
// rather than ConnectRPC because seed does not yet have a proto
// package; a future PR will add one and this package will grow a
// ConnectRPC handler alongside the JSON one without breaking callers.
//
// Endpoints:
//
//	POST /api/v1/seed/loan-requests
//	  Customer-initiated loan request. Body is a RequestLoanPayload;
//	  response is the persisted LoanRequest (in whatever state the
//	  pipeline landed, including failures — the audit stream is the
//	  authoritative diagnostic).
//
//	GET  /api/v1/seed/credit-profiles/{client_id}/{currency}
//	  Returns the client's current credit profile: tier, limit,
//	  counters, and status.
//
//	POST /api/v1/seed/internal/paid-off
//	  Called by the loans service (or an operator tool) when a loan
//	  reaches PAID_OFF. Updates the seed credit profile accordingly.
//	  Idempotent on loan_account_id.
//
// All endpoints are registered on the standard http.ServeMux so they
// compose with any additional middleware the host process wires up.
package handlers

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"

	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/seed/service/business"
)

// Server is the HTTP handler collection. One server instance exposes
// every seed HTTP endpoint; a single http.ServeMux registration hooks
// them all up.
type Server struct {
	loanRequest   business.LoanRequestBusiness
	creditProfile business.CreditProfileBusiness
}

// NewServer builds a Server with the given business dependencies.
func NewServer(
	loanRequest business.LoanRequestBusiness,
	creditProfile business.CreditProfileBusiness,
) *Server {
	return &Server{
		loanRequest:   loanRequest,
		creditProfile: creditProfile,
	}
}

// Register wires every seed HTTP route onto the supplied mux.
func (s *Server) Register(mux *http.ServeMux) {
	mux.HandleFunc("POST /api/v1/seed/loan-requests", s.handleRequestLoan)
	mux.HandleFunc("GET /api/v1/seed/credit-profiles/", s.handleGetCreditProfile)
	mux.HandleFunc("POST /api/v1/seed/internal/paid-off", s.handlePaidOff)
}

// RequestLoanPayload is the wire format of a customer-initiated loan
// request. Amount is in minor units (cents) to avoid float
// representation issues in the request/response path.
type RequestLoanPayload struct {
	ClientID       string `json:"client_id"`
	ProductID      string `json:"product_id"`
	Amount         int64  `json:"amount"`
	CurrencyCode   string `json:"currency_code"`
	Purpose        string `json:"purpose"`
	IdempotencyKey string `json:"idempotency_key"`
	ActorID        string `json:"actor_id,omitempty"`
	ActorType      string `json:"actor_type,omitempty"`
}

func (s *Server) handleRequestLoan(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	logger := util.Log(ctx).WithField("handler", "handleRequestLoan")
	defer logger.Release()

	var payload RequestLoanPayload
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		writeError(w, http.StatusBadRequest, "invalid json body", err)
		return
	}
	if payload.ActorType == "" {
		payload.ActorType = "user"
	}

	result, err := s.loanRequest.RequestLoan(ctx, business.RequestLoanInput{
		ClientID:       payload.ClientID,
		ProductID:      payload.ProductID,
		Amount:         payload.Amount,
		CurrencyCode:   payload.CurrencyCode,
		Purpose:        payload.Purpose,
		IdempotencyKey: payload.IdempotencyKey,
		ActorID:        payload.ActorID,
		ActorType:      payload.ActorType,
	})
	if err != nil {
		status := http.StatusInternalServerError
		switch {
		case errors.Is(err, business.ErrClientNotKYCVerified):
			status = http.StatusForbidden
		case errors.Is(err, business.ErrProfileSuspended):
			status = http.StatusForbidden
		case errors.Is(err, business.ErrAmountExceedsLimit):
			status = http.StatusUnprocessableEntity
		case errors.Is(err, business.ErrLoanAlreadyOutstanding):
			status = http.StatusConflict
		}
		writeError(w, status, "loan request rejected", err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"id":               result.GetID(),
		"client_id":        result.ClientID,
		"product_id":       result.ProductID,
		"amount":           result.Amount,
		"currency_code":    result.CurrencyCode,
		fieldStatus:        result.Status,
		"application_id":   result.ApplicationID,
		"loan_account_id":  result.LoanAccountID,
		"disbursement_id":  result.DisbursementID,
		"requested_at":     result.RequestedAt,
		"approved_at":      result.ApprovedAt,
		"disbursed_at":     result.DisbursedAt,
		"tier_at_approval": result.TierAtApproval,
		"denied_reason":    result.DeniedReason,
	})
}

func (s *Server) handleGetCreditProfile(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Expect /api/v1/seed/credit-profiles/{client_id}/{currency}
	const prefix = "/api/v1/seed/credit-profiles/"
	path := strings.TrimPrefix(r.URL.Path, prefix)
	const expectedPathParts = 2
	parts := strings.SplitN(path, "/", expectedPathParts)
	if len(parts) != expectedPathParts || parts[0] == "" || parts[1] == "" {
		writeError(w, http.StatusBadRequest, "path must be /{client_id}/{currency}", nil)
		return
	}
	clientID, currency := parts[0], parts[1]

	profile, err := s.creditProfile.GetProfile(ctx, clientID, currency)
	if err != nil {
		writeError(w, http.StatusNotFound, "credit profile not found", err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"id":                     profile.GetID(),
		"client_id":              profile.ClientID,
		"currency_code":          profile.CurrencyCode,
		"product_id":             profile.ProductID,
		"tier":                   profile.Tier,
		"max_loan_amount":        profile.MaxLoanAmount,
		fieldStatus:              profile.Status,
		"successful_repayments":  profile.SuccessfulRepayments,
		"outstanding_loan_count": profile.OutstandingLoanCount,
		"total_borrowed":         profile.TotalBorrowed,
		"total_repaid":           profile.TotalRepaid,
		"first_borrowed_at":      profile.FirstBorrowedAt,
		"last_borrowed_at":       profile.LastBorrowedAt,
		"last_repaid_at":         profile.LastRepaidAt,
	})
}

// PaidOffPayload is the wire format of the internal paid-off hook.
// The loans service posts this when a loan reaches PAID_OFF so seed
// can update the credit profile.
type PaidOffPayload struct {
	LoanAccountID string `json:"loan_account_id"`
	TotalRepaid   int64  `json:"total_repaid"`
}

func (s *Server) handlePaidOff(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	var payload PaidOffPayload
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		writeError(w, http.StatusBadRequest, "invalid json body", err)
		return
	}
	if payload.LoanAccountID == "" {
		writeError(w, http.StatusBadRequest, "loan_account_id is required", nil)
		return
	}

	if err := s.loanRequest.HandlePaidOff(ctx, payload.LoanAccountID, payload.TotalRepaid); err != nil {
		writeError(w, http.StatusInternalServerError, "paid-off hook failed", err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{fieldStatus: "ok"})
}

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}

func writeError(w http.ResponseWriter, status int, message string, cause error) {
	body := map[string]any{"error": message}
	if cause != nil {
		body["detail"] = cause.Error()
	}
	writeJSON(w, status, body)
}
