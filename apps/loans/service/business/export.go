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

import (
	"bytes"
	"context"
	"encoding/csv"
	"errors"
	"fmt"
	"strconv"

	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

// loanExportRow holds joined loan + balance data for CSV export.
type loanExportRow struct {
	ID                   string
	LoanRequestID        string
	ClientID             string
	AgentID              string
	BranchID             string
	OrganizationID       string
	ProductID            string
	Status               int32
	CurrencyCode         string
	PrincipalAmount      int64
	InterestRate         int64
	TermDays             int32
	DaysPastDue          int32
	DisbursedAt          string
	MaturityDate         string
	PrincipalOutstanding int64
	InterestAccrued      int64
	FeesOutstanding      int64
	PenaltiesOutstanding int64
	TotalOutstanding     int64
	TotalPaid            int64
	TotalDisbursed       int64
}

func (b *portfolioBusiness) ExportCSV(ctx context.Context, filter PortfolioFilter) ([]byte, error) {
	logger := util.Log(ctx).WithField("method", "PortfolioBusiness.ExportCSV")

	db := b.dbPool.DB(ctx, true)
	if db == nil {
		return nil, errors.New("database client not available")
	}

	rows, err := b.queryExportRows(db, filter)
	if err != nil {
		logger.WithError(err).Error("export query failed")
		return nil, fmt.Errorf("export query: %w", err)
	}

	return writeCSV(rows)
}

func (b *portfolioBusiness) queryExportRows(db *gorm.DB, filter PortfolioFilter) ([]loanExportRow, error) {
	query := db.Table("loan_accounts la").
		Select(`
			la.id,
			la.loan_request_id,
			la.client_id,
			la.agent_id,
			la.branch_id,
			la.organization_id,
			la.product_id,
			la.status,
			la.currency_code,
			la.principal_amount,
			la.interest_rate,
			la.term_days,
			la.days_past_due,
			COALESCE(TO_CHAR(la.disbursed_at, 'YYYY-MM-DD'), '') as disbursed_at,
			COALESCE(TO_CHAR(la.maturity_date, 'YYYY-MM-DD'), '') as maturity_date,
			COALESCE(lb.principal_outstanding, 0) as principal_outstanding,
			COALESCE(lb.interest_accrued, 0) as interest_accrued,
			COALESCE(lb.fees_outstanding, 0) as fees_outstanding,
			COALESCE(lb.penalties_outstanding, 0) as penalties_outstanding,
			COALESCE(lb.total_outstanding, 0) as total_outstanding,
			COALESCE(lb.total_paid, 0) as total_paid,
			COALESCE(lb.total_disbursed, 0) as total_disbursed
		`).
		Joins("LEFT JOIN loan_balances lb ON la.id = lb.loan_account_id").
		Order("la.created_at DESC")

	query = applyPortfolioFilters(query, filter)

	// Cap at 100k rows to prevent unbounded memory usage.
	const maxExportRows = 100_000
	query = query.Limit(maxExportRows)

	var rows []loanExportRow
	if err := query.Find(&rows).Error; err != nil {
		return nil, err
	}
	return rows, nil
}

func writeCSV(rows []loanExportRow) ([]byte, error) {
	var buf bytes.Buffer
	w := csv.NewWriter(&buf)

	header := []string{
		"Loan ID", "Application ID", "Client ID", "Agent ID", "Branch ID",
		"Organization ID", "Product ID", "Status", "Currency", "Principal Amount",
		"Interest Rate (BP)", "Term Days", "Days Past Due",
		"Disbursed At", "Maturity Date",
		"Principal Outstanding", "Interest Outstanding", "Fees Outstanding",
		"Penalties Outstanding", "Total Outstanding", "Total Paid", "Total Disbursed",
	}
	if err := w.Write(header); err != nil {
		return nil, fmt.Errorf("write CSV header: %w", err)
	}

	for _, r := range rows {
		row := []string{
			r.ID, r.LoanRequestID, r.ClientID, r.AgentID, r.BranchID,
			r.OrganizationID, r.ProductID,
			loanStatusName(r.Status), r.CurrencyCode,
			models.MinorUnitsToString(r.PrincipalAmount),
			strconv.FormatInt(r.InterestRate, 10),
			strconv.Itoa(int(r.TermDays)),
			strconv.Itoa(int(r.DaysPastDue)),
			r.DisbursedAt, r.MaturityDate,
			models.MinorUnitsToString(r.PrincipalOutstanding),
			models.MinorUnitsToString(r.InterestAccrued),
			models.MinorUnitsToString(r.FeesOutstanding),
			models.MinorUnitsToString(r.PenaltiesOutstanding),
			models.MinorUnitsToString(r.TotalOutstanding),
			models.MinorUnitsToString(r.TotalPaid),
			models.MinorUnitsToString(r.TotalDisbursed),
		}
		if err := w.Write(row); err != nil {
			return nil, fmt.Errorf("write CSV row: %w", err)
		}
	}

	w.Flush()
	if err := w.Error(); err != nil {
		return nil, fmt.Errorf("flush CSV: %w", err)
	}

	return buf.Bytes(), nil
}

//nolint:mnd // proto enum int values mapped to names
func loanStatusName(status int32) string {
	switch status {
	case 1:
		return "PENDING_DISBURSEMENT"
	case 2:
		return "ACTIVE"
	case 3:
		return "DELINQUENT"
	case 4:
		return "DEFAULT"
	case 5:
		return "PAID_OFF"
	case 6:
		return "RESTRUCTURED"
	case 7:
		return "WRITTEN_OFF"
	case 8:
		return "CLOSED"
	default:
		return "UNKNOWN"
	}
}
