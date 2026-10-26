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
//	POST /api/v1/seed/credit-profiles/{client_id}/{currency}/suspend
//	POST /api/v1/seed/credit-profiles/{client_id}/{currency}/block
//	POST /api/v1/seed/credit-profiles/{client_id}/{currency}/reinstate
//	  Operator status changes. Body is {"reason": "..."}; the reason is
//	  required and lands on the audit row. Gated by the
//	  seed_credit_profile_admin permission.
//
// Every endpoint is served behind the frame authentication, tenancy and
// per-route function access middleware wired in cmd/main.go. The route →
// permission map comes from the seed.v1 proto manifest (see
// function_access.go); a route that is not in the manifest is refused. The acting principal always comes from the
// caller's claims; the request body never names the actor. The client a
// customer borrows as is resolved from their profile via the identity
// platform, not read off the token. A body-supplied client_id is only honoured
// for staff and internal-system callers, who are allowed to act on another
// client's behalf.
package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"slices"
	"strings"
	"time"

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/seed/service/business"
	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// Server is the HTTP handler collection. One server instance exposes
// every seed HTTP endpoint; a single http.ServeMux registration hooks
// them all up.
type Server struct {
	loanRequest    business.LoanRequestBusiness
	creditProfile  business.CreditProfileBusiness
	clientResolver business.ClientResolver
	// staffRole is the role that lets a caller act on another client's behalf.
	staffRole string
	// ussd answers the USSD engine; nil when USSD is off.
	ussd business.UssdBusiness
	// agents answers which clients a field agent serves; nil refuses
	// agents everything scoped to their clients.
	agents business.AgentScope
}

// WithAgentScope lets field agents act on the clients they serve.
func (s *Server) WithAgentScope(agents business.AgentScope) *Server {
	s.agents = agents
	return s
}

// WithUssd serves the USSD engine's session-start call.
func (s *Server) WithUssd(ussd business.UssdBusiness) *Server {
	s.ussd = ussd
	return s
}

// NewServer builds a Server with the given business dependencies.
func NewServer(
	loanRequest business.LoanRequestBusiness,
	creditProfile business.CreditProfileBusiness,
	clientResolver business.ClientResolver,
	staffRole string,
) *Server {
	return &Server{
		loanRequest:    loanRequest,
		creditProfile:  creditProfile,
		clientResolver: clientResolver,
		staffRole:      staffRole,
	}
}

// principal is the authenticated caller, resolved from claims only. The client
// it borrows as is not in the token: it is looked up from the profile, at most
// once per request, and cached on these fields.
type principal struct {
	actorID   string
	actorType string
	profileID string
	isStaff   bool
	isService bool

	clientID   string
	resolved   bool
	resolveErr error
}

// callerPrincipal derives the acting identity from the request's claims. The
// request body is never consulted: a body-supplied actor would let any caller
// attribute a loan to somebody else.
func (s *Server) callerPrincipal(r *http.Request) (*principal, error) {
	claims := security.ClaimsFromContext(r.Context())
	if claims == nil || claims.GetProfileID() == "" {
		return nil, apperrors.NewError(apperrors.Unauthorised, "an authenticated caller is required")
	}

	p := &principal{
		actorID:   claims.GetProfileID(),
		actorType: actorTypeUser,
		profileID: claims.GetProfileID(),
		isService: claims.IsInternalSystem(),
	}
	if p.isService {
		p.actorType = actorTypeService
	}
	if s.staffRole != "" && slices.Contains(claims.GetRoles(), s.staffRole) {
		p.isStaff = true
	}
	return p, nil
}

// resolveTargetClient decides which client a request acts on. Staff and
// internal-system callers may name any client outright; everybody else acts on
// the client their own profile owns, and naming a different one is refused.
func (s *Server) resolveTargetClient(
	ctx context.Context,
	p *principal,
	requested string,
) (string, error) {
	requested = strings.TrimSpace(requested)
	if requested != "" && (p.isStaff || p.isService) {
		return requested, nil
	}

	own, err := s.callerClientID(ctx, p)
	if err != nil {
		return "", err
	}
	if requested != "" && requested != own {
		return "", apperrors.NewError(apperrors.Forbidden,
			"acting on another client requires staff permission")
	}
	return own, nil
}

// callerClientID resolves, and memoises, the client the caller's profile owns.
// The lookup crosses a service boundary, so a request that consults it twice
// still costs one call.
func (s *Server) callerClientID(ctx context.Context, p *principal) (string, error) {
	if !p.resolved {
		p.clientID, p.resolveErr = s.clientResolver.ResolveByProfileID(ctx, p.profileID)
		p.resolved = true
	}

	switch {
	case errors.Is(p.resolveErr, business.ErrNoClientForProfile):
		return "", apperrors.NewError(apperrors.Forbidden,
			"the caller is not registered as a borrowing client")
	case p.resolveErr != nil:
		util.Log(ctx).WithError(p.resolveErr).Error("could not resolve the caller's client")
		return "", apperrors.NewError(apperrors.ServiceUnavailable,
			"the client directory is unavailable")
	case p.clientID == "":
		return "", apperrors.NewError(apperrors.Forbidden,
			"the caller is not registered as a borrowing client")
	}
	return p.clientID, nil
}

// Register wires every seed HTTP route onto the supplied mux.
func (s *Server) Register(mux *http.ServeMux) {
	mux.HandleFunc("POST /api/v1/seed/loan-requests", s.handleRequestLoan)
	mux.HandleFunc("GET /api/v1/seed/credit-profiles/{clientId}/{currency}", s.handleGetCreditProfile)
	mux.HandleFunc("POST /api/v1/seed/internal/paid-off", s.handlePaidOff)
	mux.HandleFunc("POST /api/v1/seed/internal/ussd/state", s.handleUssdState)
	mux.HandleFunc("POST /api/v1/seed/credit-profiles/{clientId}/{currency}/suspend",
		s.handleSetStatus(models.CreditProfileStatusSuspended))
	mux.HandleFunc("POST /api/v1/seed/credit-profiles/{clientId}/{currency}/block",
		s.handleSetStatus(models.CreditProfileStatusBlocked))
	mux.HandleFunc("POST /api/v1/seed/credit-profiles/{clientId}/{currency}/reinstate",
		s.handleSetStatus(models.CreditProfileStatusActive))
	mux.HandleFunc("POST /api/v1/seed/credit-profiles/{clientId}/{currency}/cap", s.handleSetCap)
	mux.HandleFunc("POST /api/v1/seed/credit-profiles/{clientId}/{currency}/cap/clear", s.handleClearCap)
}

// CapPayload is the wire format of the temporary cap endpoint. Amount is in
// minor units; ExpiresAt is RFC3339.
type CapPayload struct {
	Amount    int64  `json:"amount"`
	ExpiresAt string `json:"expires_at"`
	Reason    string `json:"reason"`
}

// handleSetCap sets a temporary lower cap. Staff may cap any client; a field
// agent only the clients they serve.
func (s *Server) handleSetCap(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	caller, clientID, currency, err := s.capTarget(r)
	if err != nil {
		writeError(ctx, w, err)
		return
	}
	var payload CapPayload
	if decodeErr := json.NewDecoder(r.Body).Decode(&payload); decodeErr != nil {
		writeError(ctx, w, apperrors.NewError(apperrors.BadRequest, "request body is not valid JSON"))
		return
	}
	expires, parseErr := time.Parse(time.RFC3339, payload.ExpiresAt)
	if parseErr != nil || payload.Amount <= 0 {
		writeError(ctx, w, business.ErrTempCapInvalid)
		return
	}
	profile, err := s.creditProfile.SetTempCap(ctx, clientID, currency, payload.Amount, expires,
		caller.actorID, payload.Reason)
	if err != nil {
		writeError(ctx, w, err)
		return
	}
	writeJSON(ctx, w, http.StatusOK, creditProfileResponse(profile))
}

// handleClearCap lifts a temporary cap before it lapses.
func (s *Server) handleClearCap(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	caller, clientID, currency, err := s.capTarget(r)
	if err != nil {
		writeError(ctx, w, err)
		return
	}
	var payload StatusChangePayload
	if decodeErr := json.NewDecoder(r.Body).Decode(&payload); decodeErr != nil {
		writeError(ctx, w, apperrors.NewError(apperrors.BadRequest, "request body is not valid JSON"))
		return
	}
	profile, err := s.creditProfile.SetTempCap(ctx, clientID, currency, 0, time.Time{},
		caller.actorID, payload.Reason)
	if err != nil {
		writeError(ctx, w, err)
		return
	}
	writeJSON(ctx, w, http.StatusOK, creditProfileResponse(profile))
}

// capTarget resolves the caller and the client a cap change acts on: staff
// and services act on any client, a field agent only on one they serve.
func (s *Server) capTarget(r *http.Request) (*principal, string, string, error) {
	caller, err := s.callerPrincipal(r)
	if err != nil {
		return nil, "", "", err
	}
	clientID, currency := r.PathValue("clientId"), r.PathValue("currency")
	if clientID == "" || currency == "" {
		return nil, "", "", apperrors.NewError(apperrors.BadRequest, "path must be /{client_id}/{currency}/cap")
	}
	if caller.isStaff || caller.isService {
		return caller, clientID, currency, nil
	}
	if s.agents == nil {
		return nil, "", "", apperrors.NewError(apperrors.Forbidden, "only the client's field agent or staff may cap it")
	}
	serves, scopeErr := s.agents.ServesClient(r.Context(), caller.profileID, clientID)
	if scopeErr != nil {
		util.Log(r.Context()).WithError(scopeErr).Error("could not resolve the agent's clients")
		return nil, "", "", apperrors.NewError(apperrors.ServiceUnavailable, "the client directory is unavailable")
	}
	if !serves {
		return nil, "", "", apperrors.NewError(apperrors.Forbidden, "only the client's field agent or staff may cap it")
	}
	return caller, clientID, currency, nil
}

// RequestLoanPayload is the wire format of a customer-initiated loan
// request. Amount is in minor units (cents) to avoid float
// representation issues in the request/response path.
// The actor is never part of the payload: it comes from the caller's claims.
type RequestLoanPayload struct {
	ClientID       string `json:"client_id"`
	ProductID      string `json:"product_id"`
	Amount         int64  `json:"amount"`
	CurrencyCode   string `json:"currency_code"`
	Purpose        string `json:"purpose"`
	IdempotencyKey string `json:"idempotency_key"`
}

func (s *Server) handleRequestLoan(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	logger := util.Log(ctx).WithField("handler", "handleRequestLoan")
	defer logger.Release()

	caller, callerErr := s.callerPrincipal(r)
	if callerErr != nil {
		writeError(ctx, w, callerErr)
		return
	}

	var payload RequestLoanPayload
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		writeError(ctx, w, apperrors.NewError(apperrors.BadRequest, "request body is not valid JSON"))
		return
	}

	clientID, clientErr := s.resolveTargetClient(ctx, caller, payload.ClientID)
	if clientErr != nil {
		writeError(ctx, w, clientErr)
		return
	}

	result, err := s.loanRequest.RequestLoan(ctx, business.RequestLoanInput{
		ClientID:       clientID,
		ProductID:      payload.ProductID,
		Amount:         payload.Amount,
		CurrencyCode:   payload.CurrencyCode,
		Purpose:        payload.Purpose,
		IdempotencyKey: payload.IdempotencyKey,
		ActorID:        caller.actorID,
		ActorType:      caller.actorType,
	})
	if err != nil {
		logger.WithError(err).Info("loan request rejected")
		writeError(ctx, w, err)
		return
	}

	writeJSON(ctx, w, http.StatusOK, map[string]any{
		"id":               result.GetID(),
		fieldClientID:      result.ClientID,
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

	caller, callerErr := s.callerPrincipal(r)
	if callerErr != nil {
		writeError(ctx, w, callerErr)
		return
	}

	requestedClient, currency := r.PathValue("clientId"), r.PathValue("currency")
	if requestedClient == "" || currency == "" {
		writeError(ctx, w, apperrors.NewError(apperrors.BadRequest,
			"path must be /{client_id}/{currency}"))
		return
	}

	clientID, clientErr := s.resolveTargetClient(ctx, caller, requestedClient)
	if clientErr != nil {
		writeError(ctx, w, clientErr)
		return
	}

	profile, err := s.creditProfile.GetProfile(ctx, clientID, currency)
	if err != nil {
		writeError(ctx, w, apperrors.ErrDataNotFound.Extend("credit profile"))
		return
	}

	writeJSON(ctx, w, http.StatusOK, creditProfileResponse(profile))
}

// StatusChangePayload is the wire format of the suspend, block and reinstate
// endpoints. The reason is mandatory and is written to the audit row.
type StatusChangePayload struct {
	Reason string `json:"reason"`
}

// handleSetStatus builds the operator status-change handler for one target
// status. The route is gated by seed_credit_profile_admin through the
// function access middleware; the handler itself only needs an authenticated
// principal to attribute the audit row to.
func (s *Server) handleSetStatus(target models.CreditProfileStatus) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()

		if _, callerErr := s.callerPrincipal(r); callerErr != nil {
			writeError(ctx, w, callerErr)
			return
		}

		clientID, currency := r.PathValue("clientId"), r.PathValue("currency")
		if clientID == "" || currency == "" {
			writeError(ctx, w, apperrors.NewError(apperrors.BadRequest,
				"path must be /{client_id}/{currency}/<action>"))
			return
		}

		var payload StatusChangePayload
		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			writeError(ctx, w, apperrors.NewError(apperrors.BadRequest, "request body is not valid JSON"))
			return
		}

		profile, err := s.creditProfile.SetStatus(ctx, clientID, currency, target, payload.Reason)
		if err != nil {
			writeError(ctx, w, err)
			return
		}
		writeJSON(ctx, w, http.StatusOK, creditProfileResponse(profile))
	}
}

func creditProfileResponse(profile *models.CreditProfile) map[string]any {
	return map[string]any{
		"id":                     profile.GetID(),
		fieldClientID:            profile.ClientID,
		"currency_code":          profile.CurrencyCode,
		"product_id":             profile.ProductID,
		"tier":                   profile.Tier,
		"max_loan_amount":        profile.MaxLoanAmount,
		"effective_limit":        profile.EffectiveLimit(time.Now()),
		"temp_cap_amount":        profile.TempCapAmount,
		"temp_cap_expires_at":    profile.TempCapExpiresAt,
		"temp_cap_reason":        profile.TempCapReason,
		fieldStatus:              profile.Status,
		"successful_repayments":  profile.SuccessfulRepayments,
		"outstanding_loan_count": profile.OutstandingLoanCount,
		"total_borrowed":         profile.TotalBorrowed,
		"total_repaid":           profile.TotalRepaid,
		"first_borrowed_at":      profile.FirstBorrowedAt,
		"last_borrowed_at":       profile.LastBorrowedAt,
		"last_repaid_at":         profile.LastRepaidAt,
	}
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

	caller, callerErr := s.callerPrincipal(r)
	if callerErr != nil {
		writeError(ctx, w, callerErr)
		return
	}
	// This hook promotes credit tiers off claimed repayments. Only the loans
	// service (or an operator tool running as one) may call it.
	if !caller.isService && !caller.isStaff {
		writeError(ctx, w, apperrors.NewError(apperrors.Forbidden,
			"the paid-off hook is restricted to internal callers"))
		return
	}

	var payload PaidOffPayload
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		writeError(ctx, w, apperrors.NewError(apperrors.BadRequest, "request body is not valid JSON"))
		return
	}
	if strings.TrimSpace(payload.LoanAccountID) == "" {
		writeError(ctx, w, apperrors.NewError(apperrors.BadRequest, "loan_account_id is required"))
		return
	}

	if err := s.loanRequest.HandlePaidOff(ctx, payload.LoanAccountID, payload.TotalRepaid); err != nil {
		writeError(ctx, w, err)
		return
	}

	writeJSON(ctx, w, http.StatusOK, map[string]any{fieldStatus: "ok"})
}

// UssdStatePayload is the USSD engine's session-start request.
type UssdStatePayload struct {
	ServiceID string `json:"service_id"`
	ProfileID string `json:"profile_id"`
	ContactID string `json:"contact_id"`
}

// handleUssdState answers the USSD engine when a borrower opens the Seed
// menu: the rows the menu shows them now. Only a service account may call
// it (the engine, holding seed_ussd_state).
func (s *Server) handleUssdState(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	if s.ussd == nil {
		writeError(ctx, w, apperrors.NewError(apperrors.ServiceUnavailable, "USSD is not enabled"))
		return
	}

	caller, callerErr := s.callerPrincipal(r)
	if callerErr != nil {
		writeError(ctx, w, callerErr)
		return
	}
	if !caller.isService {
		writeError(ctx, w, apperrors.NewError(apperrors.Forbidden,
			"the USSD state call is restricted to the USSD service"))
		return
	}

	var payload UssdStatePayload
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		writeError(ctx, w, apperrors.NewError(apperrors.BadRequest, "request body is not valid JSON"))
		return
	}
	if strings.TrimSpace(payload.ProfileID) == "" {
		writeError(ctx, w, apperrors.NewError(apperrors.BadRequest, "profile_id is required"))
		return
	}

	rows, err := s.ussd.State(ctx, payload.ProfileID)
	if err != nil {
		writeError(ctx, w, err)
		return
	}
	writeJSON(ctx, w, http.StatusOK, map[string]any{"rows": rows})
}

// errorBody is the JSON shape every seed error response uses.
type errorBody struct {
	Error string `json:"error"`
}

func writeJSON(ctx context.Context, w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		util.Log(ctx).WithError(err).Warn("failed to encode JSON response")
	}
}

// writeError maps a business error onto an HTTP status and a caller-safe
// message. Internal error text is never echoed back to the client.
func writeError(ctx context.Context, w http.ResponseWriter, err error) {
	status := http.StatusInternalServerError
	message := "an internal error occurred"

	var appErr *apperrors.Error
	switch {
	case errors.As(err, &appErr):
		status = appErr.ErrorCode()
		message = appErr.Message()
	case errors.Is(err, business.ErrClientNotKYCVerified):
		status = http.StatusForbidden
		message = "the client is not KYC verified"
	case errors.Is(err, business.ErrAmountExceedsLimit):
		status = http.StatusUnprocessableEntity
		message = "the requested amount exceeds the client's credit limit"
	case errors.Is(err, business.ErrLoanAlreadyOutstanding):
		status = http.StatusConflict
		message = "the client already has an outstanding loan"
	case data.ErrorIsNoRows(err):
		status = http.StatusNotFound
		message = apperrors.ErrDataNotFound.Message()
	}

	writeJSON(ctx, w, status, errorBody{Error: message})
}
