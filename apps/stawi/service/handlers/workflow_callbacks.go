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
	"context"
	"encoding/json"
	"net/http"

	"github.com/pitabwire/util"

	groupbusiness "github.com/antinvestor/service-fintech/apps/stawi/service/business"
	"github.com/antinvestor/service-fintech/pkg/clients"
)

// RegisterWorkflowCallbacks registers all workflow callback HTTP endpoints.
func RegisterWorkflowCallbacks(
	mux *http.ServeMux,
	grpBusiness groupbusiness.ClientGroupBusiness,
	memBusiness groupbusiness.MembershipBusiness,
	tenBusiness groupbusiness.TenureBusiness,
	perBusiness groupbusiness.PeriodBusiness,
	lwBusiness LoanWindowBusiness,
	loBusiness LoanOfferBusiness,
	lfBusiness FundingAllocationBusiness,
	prBusiness PaymentRoutingBusiness,
	toBusiness TransferOrderBusiness,
	obBusiness ObligationBusiness,
	platformClients *clients.PlatformClients,
) {
	// Group lifecycle callbacks
	mux.HandleFunc("POST /api/v1/groups/{id}/check-formation", handleCheckFormation(grpBusiness, memBusiness))
	mux.HandleFunc(
		"POST /api/v1/groups/{id}/welcome",
		handleWelcomeGroup(grpBusiness, memBusiness, tenBusiness, perBusiness, platformClients),
	)
	mux.HandleFunc(
		"POST /api/v1/groups/{id}/setup-ledger",
		handleSetupLedger(grpBusiness, memBusiness, platformClients),
	)
	mux.HandleFunc("POST /api/v1/groups/{id}/create-tenure", handleCreateTenure(tenBusiness))
	mux.HandleFunc(
		"POST /api/v1/groups/{id}/register-lender",
		handleRegisterLender(grpBusiness, memBusiness, platformClients),
	)
	mux.HandleFunc("POST /api/v1/groups/{id}/open-period", handleOpenPeriod(perBusiness))
	mux.HandleFunc("POST /api/v1/groups/{id}/evaluate-loan-window", handleEvaluateLoanWindow(lwBusiness, perBusiness))
	mux.HandleFunc(
		"POST /api/v1/groups/{id}/calculate-obligations",
		handleCalculateObligations(obBusiness, memBusiness),
	)
	mux.HandleFunc("POST /api/v1/groups/{id}/transition", handleGroupTransition(grpBusiness))

	// Period lifecycle callbacks
	mux.HandleFunc("POST /api/v1/periods/{id}/close", handleClosePeriod(perBusiness, memBusiness, obBusiness))

	// Membership callbacks
	mux.HandleFunc(
		"POST /api/v1/memberships/{id}/check-periodic-payment",
		handleCheckPeriodicPayment(memBusiness, obBusiness),
	)

	// Funding callbacks
	mux.HandleFunc("POST /api/v1/loan-windows/{id}/generate-offers", handleGenerateOffers(lwBusiness, loBusiness))
	mux.HandleFunc("POST /api/v1/loan-offers/{id}/source-funding", handleSourceFunding(loBusiness, lfBusiness))
	mux.HandleFunc(
		"POST /api/v1/loan-offers/{id}/create-loan-account",
		handleCreateLoanAccount(loBusiness, platformClients),
	)
	mux.HandleFunc("POST /api/v1/loan-accounts/{id}/generate-schedule", handleGenerateSchedule(platformClients))
	mux.HandleFunc("POST /api/v1/loan-accounts/{id}/disburse", handleDisburse(platformClients))

	// Payment routing callbacks
	mux.HandleFunc("POST /api/v1/payments/identify", handleIdentifyPayment(prBusiness))
	mux.HandleFunc("POST /api/v1/payments/{id}/allocate", handleAllocatePayment(prBusiness, toBusiness, obBusiness))
	mux.HandleFunc("POST /api/v1/transfer-orders/{id}/execute", handleExecuteTransferOrder(toBusiness))

	// Status check callbacks
	mux.HandleFunc("GET /api/v1/obligations/{id}/status", handleObligationStatus(obBusiness))
}

// --- Callback handler factories ---

// Each returns an http.HandlerFunc that:
// 1. Extracts path parameter {id} from request
// 2. Decodes optional JSON body
// 3. Calls business logic
// 4. Returns JSON response or error

func handleCheckFormation(
	grpBusiness groupbusiness.ClientGroupBusiness,
	_ groupbusiness.MembershipBusiness,
) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		groupID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "check-formation", fieldGroupID: groupID})

		result, err := grpBusiness.CheckFormation(ctx, groupID)
		if err != nil {
			log.WithError(err).Error("check formation failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, result)
	}
}

func handleWelcomeGroup(
	grpBusiness groupbusiness.ClientGroupBusiness,
	_ groupbusiness.MembershipBusiness,
	_ groupbusiness.TenureBusiness,
	_ groupbusiness.PeriodBusiness,
	_ *clients.PlatformClients,
) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		groupID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "welcome-group", fieldGroupID: groupID})

		err := grpBusiness.WelcomeGroup(ctx, groupID)
		if err != nil {
			log.WithError(err).Error("welcome group failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, map[string]string{fieldStatus: "ok"})
	}
}

func handleSetupLedger(
	grpBusiness groupbusiness.ClientGroupBusiness,
	_ groupbusiness.MembershipBusiness,
	_ *clients.PlatformClients,
) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		groupID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "setup-ledger", fieldGroupID: groupID})

		err := grpBusiness.SetupLedgerAccounts(ctx, groupID)
		if err != nil {
			log.WithError(err).Error("setup ledger failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, map[string]string{fieldStatus: "ok"})
	}
}

func handleCreateTenure(tenBusiness groupbusiness.TenureBusiness) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		groupID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "create-tenure", fieldGroupID: groupID})

		tenure, err := tenBusiness.Open(ctx, groupID)
		if err != nil {
			log.WithError(err).Error("create tenure failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, tenure)
	}
}

func handleRegisterLender(
	grpBusiness groupbusiness.ClientGroupBusiness,
	_ groupbusiness.MembershipBusiness,
	_ *clients.PlatformClients,
) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		groupID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "register-lender", fieldGroupID: groupID})

		err := grpBusiness.RegisterWithLender(ctx, groupID)
		if err != nil {
			log.WithError(err).Error("register lender failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, map[string]string{fieldStatus: "ok"})
	}
}

func handleOpenPeriod(perBusiness groupbusiness.PeriodBusiness) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		groupID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "open-period", fieldGroupID: groupID})

		period, err := perBusiness.Open(ctx, groupID)
		if err != nil {
			log.WithError(err).Error("open period failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, period)
	}
}

func handleEvaluateLoanWindow(
	lwBusiness LoanWindowBusiness,
	_ groupbusiness.PeriodBusiness,
) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		groupID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "evaluate-loan-window", fieldGroupID: groupID})

		result, err := lwBusiness.Evaluate(ctx, groupID)
		if err != nil {
			log.WithError(err).Error("evaluate loan window failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, result)
	}
}

func handleCalculateObligations(
	obBusiness ObligationBusiness,
	_ groupbusiness.MembershipBusiness,
) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		groupID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "calculate-obligations", fieldGroupID: groupID})

		err := obBusiness.CalculateForGroup(ctx, groupID)
		if err != nil {
			log.WithError(err).Error("calculate obligations failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, map[string]string{fieldStatus: "ok"})
	}
}

func handleGroupTransition(grpBusiness groupbusiness.ClientGroupBusiness) http.HandlerFunc {
	type transitionReq struct {
		State  int32  `json:"state"`
		Reason string `json:"reason"`
	}
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		groupID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "group-transition", fieldGroupID: groupID})

		var req transitionReq
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "invalid request body", http.StatusBadRequest)
			return
		}

		err := grpBusiness.Transition(ctx, groupID, req.State, req.Reason)
		if err != nil {
			log.WithError(err).Error("group transition failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, map[string]string{fieldStatus: "ok"})
	}
}

func handleClosePeriod(
	perBusiness groupbusiness.PeriodBusiness,
	_ groupbusiness.MembershipBusiness,
	_ ObligationBusiness,
) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		periodID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "close-period", "period_id": periodID})

		err := perBusiness.Close(ctx, periodID)
		if err != nil {
			log.WithError(err).Error("close period failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, map[string]string{fieldStatus: "ok"})
	}
}

func handleCheckPeriodicPayment(
	memBusiness groupbusiness.MembershipBusiness,
	_ ObligationBusiness,
) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		membershipID := r.PathValue("id")
		log := util.Log(ctx).
			WithFields(map[string]any{logKeyHandler: "check-periodic-payment", "membership_id": membershipID})

		result, err := memBusiness.CheckPeriodicPayment(ctx, membershipID)
		if err != nil {
			log.WithError(err).Error("check periodic payment failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, result)
	}
}

func handleGenerateOffers(
	_ LoanWindowBusiness,
	loBusiness LoanOfferBusiness,
) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		windowID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "generate-offers", "window_id": windowID})

		offers, err := loBusiness.GenerateForWindow(ctx, windowID)
		if err != nil {
			log.WithError(err).Error("generate offers failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, offers)
	}
}

func handleSourceFunding(
	_ LoanOfferBusiness,
	lfBusiness FundingAllocationBusiness,
) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		loanRequestID := r.PathValue("id")
		log := util.Log(ctx).
			WithFields(map[string]any{logKeyHandler: "source-funding", "loan_request_id": loanRequestID})

		result, err := lfBusiness.SourceForRequest(ctx, loanRequestID)
		if err != nil {
			log.WithError(err).Error("source funding failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, result)
	}
}

func handleCreateLoanAccount(
	loBusiness LoanOfferBusiness,
	_ *clients.PlatformClients,
) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		offerID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "create-loan-account", "offer_id": offerID})

		result, err := loBusiness.CreateLoanAccount(ctx, offerID)
		if err != nil {
			log.WithError(err).Error("create loan account failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, result)
	}
}

func handleGenerateSchedule(_ *clients.PlatformClients) http.HandlerFunc {
	return func(w http.ResponseWriter, _ *http.Request) {
		http.Error(w, "schedule generation must be triggered via loans service", http.StatusNotImplemented)
	}
}

func handleDisburse(_ *clients.PlatformClients) http.HandlerFunc {
	return func(w http.ResponseWriter, _ *http.Request) {
		http.Error(
			w,
			"disbursement requires operations service - create a DISBURSEMENT transfer order",
			http.StatusNotImplemented,
		)
	}
}

func handleIdentifyPayment(prBusiness PaymentRoutingBusiness) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		log := util.Log(ctx).WithField("handler", "identify-payment")

		var req map[string]interface{}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "invalid request body", http.StatusBadRequest)
			return
		}

		result, err := prBusiness.IdentifyPayment(ctx, req)
		if err != nil {
			log.WithError(err).Error("identify payment failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, result)
	}
}

func handleAllocatePayment(
	prBusiness PaymentRoutingBusiness,
	_ TransferOrderBusiness,
	_ ObligationBusiness,
) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		paymentID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "allocate-payment", "payment_id": paymentID})

		result, err := prBusiness.AllocatePayment(ctx, paymentID)
		if err != nil {
			log.WithError(err).Error("allocate payment failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, result)
	}
}

func handleExecuteTransferOrder(toBusiness TransferOrderBusiness) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		orderID := r.PathValue("id")
		log := util.Log(ctx).WithFields(map[string]any{logKeyHandler: "execute-transfer-order", "order_id": orderID})

		err := toBusiness.Execute(ctx, orderID)
		if err != nil {
			log.WithError(err).Error("execute transfer order failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, map[string]string{fieldStatus: "ok"})
	}
}

func handleObligationStatus(obBusiness ObligationBusiness) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		obligationID := r.PathValue("id")
		log := util.Log(ctx).
			WithFields(map[string]any{logKeyHandler: "obligation-status", "obligation_id": obligationID})

		status, err := obBusiness.GetStatus(ctx, obligationID)
		if err != nil {
			log.WithError(err).Error("get obligation status failed")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		writeJSON(w, status)
	}
}

// writeJSON writes a JSON response with HTTP 200 OK status.
func writeJSON(w http.ResponseWriter, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		util.Log(context.Background()).WithError(err).Warn("failed to encode JSON response")
	}
}
