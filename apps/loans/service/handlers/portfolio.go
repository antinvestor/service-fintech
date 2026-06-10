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
	"encoding/json"
	"net/http"
	"time"

	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/business"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

// RegisterPortfolioHandlers registers REST endpoints for portfolio reporting.
// These provide portfolio aggregation and export functionality independently
// of the proto-generated Connect RPC handlers.
func RegisterPortfolioHandlers(mux *http.ServeMux, pb business.PortfolioBusiness) {
	mux.HandleFunc("GET /api/v1/portfolio/summary", handlePortfolioSummary(pb))
	mux.HandleFunc("GET /api/v1/portfolio/export", handlePortfolioExport(pb))
}

type portfolioSummaryJSON struct {
	TotalLoans           int32  `json:"total_loans"`
	ActiveLoans          int32  `json:"active_loans"`
	DelinquentLoans      int32  `json:"delinquent_loans"`
	DefaultLoans         int32  `json:"default_loans"`
	PaidOffLoans         int32  `json:"paid_off_loans"`
	WrittenOffLoans      int32  `json:"written_off_loans"`
	TotalDisbursed       string `json:"total_disbursed"`
	TotalOutstanding     string `json:"total_outstanding"`
	TotalCollected       string `json:"total_collected"`
	PrincipalOutstanding string `json:"principal_outstanding"`
	InterestOutstanding  string `json:"interest_outstanding"`
	FeesOutstanding      string `json:"fees_outstanding"`
	PenaltiesOutstanding string `json:"penalties_outstanding"`
	CurrencyCode         string `json:"currency_code"`
	CollectionRate       string `json:"collection_rate"`
	PAR30                string `json:"par_30"`
}

func handlePortfolioSummary(pb business.PortfolioBusiness) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		logger := util.Log(ctx).WithField("handler", "portfolioSummary")

		filter := business.PortfolioFilter{
			OrganizationID: r.URL.Query().Get("organization_id"),
			BranchID:       r.URL.Query().Get("branch_id"),
			AgentID:        r.URL.Query().Get("agent_id"),
			ProductID:      r.URL.Query().Get("product_id"),
			ClientID:       r.URL.Query().Get("client_id"),
			CurrencyCode:   r.URL.Query().Get("currency_code"),
		}

		result, err := pb.GetSummary(ctx, filter)
		if err != nil {
			logger.WithError(err).Error("portfolio summary failed")
			http.Error(w, `{"error":"portfolio summary failed"}`, http.StatusInternalServerError)
			return
		}

		resp := portfolioSummaryJSON{
			TotalLoans:           result.TotalLoans,
			ActiveLoans:          result.ActiveLoans,
			DelinquentLoans:      result.DelinquentLoans,
			DefaultLoans:         result.DefaultLoans,
			PaidOffLoans:         result.PaidOffLoans,
			WrittenOffLoans:      result.WrittenOffLoans,
			TotalDisbursed:       models.MinorUnitsToString(result.TotalDisbursed),
			TotalOutstanding:     models.MinorUnitsToString(result.TotalOutstanding),
			TotalCollected:       models.MinorUnitsToString(result.TotalCollected),
			PrincipalOutstanding: models.MinorUnitsToString(result.PrincipalOutstanding),
			InterestOutstanding:  models.MinorUnitsToString(result.InterestOutstanding),
			FeesOutstanding:      models.MinorUnitsToString(result.FeesOutstanding),
			PenaltiesOutstanding: models.MinorUnitsToString(result.PenaltiesOutstanding),
			CurrencyCode:         result.CurrencyCode,
			CollectionRate:       result.CollectionRate,
			PAR30:                result.PAR30,
		}

		w.Header().Set("Content-Type", "application/json")
		if encErr := json.NewEncoder(w).Encode(resp); encErr != nil {
			logger.WithError(encErr).Error("could not encode response")
		}
	}
}

func handlePortfolioExport(pb business.PortfolioBusiness) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		logger := util.Log(ctx).WithField("handler", "portfolioExport")

		filter := business.PortfolioFilter{
			OrganizationID: r.URL.Query().Get("organization_id"),
			BranchID:       r.URL.Query().Get("branch_id"),
			AgentID:        r.URL.Query().Get("agent_id"),
			ProductID:      r.URL.Query().Get("product_id"),
			ClientID:       r.URL.Query().Get("client_id"),
			CurrencyCode:   r.URL.Query().Get("currency_code"),
		}

		csvData, err := pb.ExportCSV(ctx, filter)
		if err != nil {
			logger.WithError(err).Error("portfolio export failed")
			http.Error(w, `{"error":"portfolio export failed"}`, http.StatusInternalServerError)
			return
		}

		filename := "loan_book_" + time.Now().Format("20060102_150405") + ".csv"
		w.Header().Set("Content-Type", "text/csv")
		w.Header().Set("Content-Disposition", "attachment; filename=\""+filename+"\"")
		// Block content sniffing so the browser never tries to render the
		// CSV body as HTML/JS. Together with Content-Type: text/csv and
		// Content-Disposition: attachment this prevents any reflected-XSS
		// path (G705) through CSV cell contents.
		w.Header().Set("X-Content-Type-Options", "nosniff")

		// CSV body: nosniff + attachment, never rendered as HTML/JS.
		_, writeErr := w.Write(csvData)
		if writeErr != nil {
			logger.WithError(writeErr).Error("could not write CSV response")
		}
	}
}
