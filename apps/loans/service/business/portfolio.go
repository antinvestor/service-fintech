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
	"context"
	"errors"
	"fmt"

	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/util"
	"gorm.io/gorm"
)

// PortfolioSummaryResult holds aggregated portfolio metrics.
type PortfolioSummaryResult struct {
	TotalLoans           int32
	ActiveLoans          int32
	DelinquentLoans      int32
	DefaultLoans         int32
	PaidOffLoans         int32
	WrittenOffLoans      int32
	TotalDisbursed       int64
	TotalOutstanding     int64
	TotalCollected       int64
	PrincipalOutstanding int64
	InterestOutstanding  int64
	FeesOutstanding      int64
	PenaltiesOutstanding int64
	CurrencyCode         string
	CollectionRate       string // percentage string e.g. "85.50"
	PAR30                string // percentage string e.g. "12.30"
}

// PortfolioFilter defines the filter criteria for portfolio queries.
type PortfolioFilter struct {
	OrganizationID string
	BranchID       string
	AgentID        string
	ProductID      string
	ClientID       string
	CurrencyCode   string
}

// PortfolioBusiness provides portfolio aggregation and export.
type PortfolioBusiness interface {
	GetSummary(ctx context.Context, filter PortfolioFilter) (*PortfolioSummaryResult, error)
	ExportCSV(ctx context.Context, filter PortfolioFilter) ([]byte, error)
}

type portfolioBusiness struct {
	dbPool pool.Pool
}

// NewPortfolioBusiness creates a new PortfolioBusiness.
func NewPortfolioBusiness(_ context.Context, dbPool pool.Pool) PortfolioBusiness {
	return &portfolioBusiness{dbPool: dbPool}
}

// portfolioRow holds the result of the aggregation SQL query.
type portfolioRow struct {
	TotalLoans           int32
	ActiveLoans          int32
	DelinquentLoans      int32
	DefaultLoans         int32
	PaidOffLoans         int32
	WrittenOffLoans      int32
	TotalDisbursed       int64
	TotalOutstanding     int64
	TotalCollected       int64
	PrincipalOutstanding int64
	InterestOutstanding  int64
	FeesOutstanding      int64
	PenaltiesOutstanding int64
	PAR30Count           int32
}

func (b *portfolioBusiness) GetSummary(ctx context.Context, filter PortfolioFilter) (*PortfolioSummaryResult, error) {
	logger := util.Log(ctx).WithField("method", "PortfolioBusiness.GetSummary")

	db := b.dbPool.DB(ctx, true)
	if db == nil {
		return nil, errors.New("database client not available")
	}

	row, err := b.runAggregationQuery(db, filter)
	if err != nil {
		logger.WithError(err).Error("portfolio aggregation query failed")
		return nil, fmt.Errorf("portfolio query: %w", err)
	}

	result := &PortfolioSummaryResult{
		TotalLoans:           row.TotalLoans,
		ActiveLoans:          row.ActiveLoans,
		DelinquentLoans:      row.DelinquentLoans,
		DefaultLoans:         row.DefaultLoans,
		PaidOffLoans:         row.PaidOffLoans,
		WrittenOffLoans:      row.WrittenOffLoans,
		TotalDisbursed:       row.TotalDisbursed,
		TotalOutstanding:     row.TotalOutstanding,
		TotalCollected:       row.TotalCollected,
		PrincipalOutstanding: row.PrincipalOutstanding,
		InterestOutstanding:  row.InterestOutstanding,
		FeesOutstanding:      row.FeesOutstanding,
		PenaltiesOutstanding: row.PenaltiesOutstanding,
		CurrencyCode:         filter.CurrencyCode,
	}

	// Collection rate = (total_disbursed - principal_outstanding) / total_disbursed * 100
	// This measures how much principal has been recovered relative to what was lent out.
	if row.TotalDisbursed > 0 {
		principalCollected := row.TotalDisbursed - row.PrincipalOutstanding
		if principalCollected < 0 {
			principalCollected = 0
		}
		rate := float64(principalCollected) / float64(row.TotalDisbursed) * 100 //nolint:mnd // percentage
		result.CollectionRate = fmt.Sprintf("%.2f", rate)
	} else {
		result.CollectionRate = "0.00"
	}

	// PAR30 = loans with days_past_due > 30 / active loans * 100
	activeAndDelinquent := row.ActiveLoans + row.DelinquentLoans + row.DefaultLoans
	if activeAndDelinquent > 0 {
		par := float64(row.PAR30Count) / float64(activeAndDelinquent) * 100 //nolint:mnd // percentage
		result.PAR30 = fmt.Sprintf("%.2f", par)
	} else {
		result.PAR30 = "0.00"
	}

	return result, nil
}

// runAggregationQuery executes the portfolio aggregation SQL.
func (b *portfolioBusiness) runAggregationQuery(db *gorm.DB, filter PortfolioFilter) (*portfolioRow, error) {
	query := db.Table("loan_accounts la").
		Select(`
			COUNT(*) as total_loans,
			COUNT(CASE WHEN la.status = 2 THEN 1 END) as active_loans,
			COUNT(CASE WHEN la.status = 3 THEN 1 END) as delinquent_loans,
			COUNT(CASE WHEN la.status = 4 THEN 1 END) as default_loans,
			COUNT(CASE WHEN la.status = 5 THEN 1 END) as paid_off_loans,
			COUNT(CASE WHEN la.status = 7 THEN 1 END) as written_off_loans,
			COALESCE(SUM(lb.total_disbursed), 0) as total_disbursed,
			COALESCE(SUM(lb.total_outstanding), 0) as total_outstanding,
			COALESCE(SUM(lb.total_paid), 0) as total_collected,
			COALESCE(SUM(lb.principal_outstanding), 0) as principal_outstanding,
			COALESCE(SUM(lb.interest_accrued), 0) as interest_outstanding,
			COALESCE(SUM(lb.fees_outstanding), 0) as fees_outstanding,
			COALESCE(SUM(lb.penalties_outstanding), 0) as penalties_outstanding,
			COUNT(CASE WHEN la.days_past_due > 30 THEN 1 END) as par30_count
		`).
		Joins("LEFT JOIN loan_balances lb ON la.id = lb.loan_account_id")

	query = applyPortfolioFilters(query, filter)

	var row portfolioRow
	if err := query.Scan(&row).Error; err != nil {
		return nil, err
	}
	return &row, nil
}

func applyPortfolioFilters(query *gorm.DB, filter PortfolioFilter) *gorm.DB {
	if filter.OrganizationID != "" {
		query = query.Where("la.organization_id = ?", filter.OrganizationID)
	}
	if filter.BranchID != "" {
		query = query.Where("la.branch_id = ?", filter.BranchID)
	}
	if filter.AgentID != "" {
		query = query.Where("la.agent_id = ?", filter.AgentID)
	}
	if filter.ProductID != "" {
		query = query.Where("la.product_id = ?", filter.ProductID)
	}
	if filter.ClientID != "" {
		query = query.Where("la.client_id = ?", filter.ClientID)
	}
	if filter.CurrencyCode != "" {
		query = query.Where("la.currency_code = ?", filter.CurrencyCode)
	}
	return query
}
