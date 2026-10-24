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

package constants

import "strings"

// LedgerCategory is the accounting class of a chart ledger.
type LedgerCategory int

const (
	CategoryAsset LedgerCategory = iota
	CategoryLiability
	CategoryIncome
	CategoryExpense
	CategoryCapital
)

// Chart ledgers: every account the platform posts to belongs to one of
// these, by the kind of account its name encodes.
const (
	LedgerCash         = "fintech_cash"         // money held: product, platform, group bank, agent cash
	LedgerReceivables  = "fintech_receivables"  // loans and penalties owed to the lender
	LedgerMemberFunds  = "fintech_member_funds" // money held for members, clients and investors
	LedgerPayables     = "fintech_payables"     // fees and premiums owed onwards
	LedgerIncome       = "fintech_income"       // interest, fees and penalties earned
	LedgerExpense      = "fintech_expense"      // bad debt, savings interest, costs
	LedgerCapital      = "fintech_capital"      // investor capital and first-loss reserves
	LedgerUnclassified = "fintech_unclassified" // names the chart does not know yet
)

// ChartLedgers lists every chart ledger and its category.
func ChartLedgers() map[string]LedgerCategory {
	return map[string]LedgerCategory{
		LedgerCash:         CategoryAsset,
		LedgerReceivables:  CategoryAsset,
		LedgerMemberFunds:  CategoryLiability,
		LedgerPayables:     CategoryLiability,
		LedgerIncome:       CategoryIncome,
		LedgerExpense:      CategoryExpense,
		LedgerCapital:      CategoryCapital,
		LedgerUnclassified: CategoryLiability,
	}
}

// chartByKind maps the "<scope>:<kind>" of an account name (its first and
// last segments) to its ledger.
//
//nolint:gochecknoglobals // immutable chart
var chartByKind = map[string]string{
	"product:external_cash":            LedgerCash,
	"platform:external_cash":           LedgerCash,
	"group:bank":                       LedgerCash,
	"agent:cash_in_hand":               LedgerCash,
	"product:unallocated":              LedgerReceivables,
	"member:penalty_receivable":        LedgerReceivables,
	"product:unidentified":             LedgerMemberFunds,
	"member:suspense":                  LedgerMemberFunds,
	"client:suspense":                  LedgerMemberFunds,
	"member:loans":                     LedgerMemberFunds,
	"member:lending":                   LedgerMemberFunds,
	"member:periodic_savings":          LedgerMemberFunds,
	"savings:balance":                  LedgerMemberFunds,
	"investor:reserved":                LedgerMemberFunds,
	"product:service_fee_payable":      LedgerPayables,
	"product:insurance":                LedgerPayables,
	"platform:income":                  LedgerIncome,
	"group:interest_income":            LedgerIncome,
	"group:penalty_income":             LedgerIncome,
	"group:joining_fee":                LedgerIncome,
	"group:service_fee":                LedgerIncome,
	"group:savings_interest_income":    LedgerIncome,
	"product:bad_debt_expense":         LedgerExpense,
	"product:savings_interest_expense": LedgerExpense,
	"group:transaction_costs":          LedgerExpense,
	"investor:capital":                 LedgerCapital,
	"platform:first_loss":              LedgerCapital,
}

// LedgerForAccount returns the chart ledger an account name belongs to, and
// whether the chart knows the name. Unknown names go to LedgerUnclassified.
func LedgerForAccount(name string) (string, bool) {
	scope, rest, found := strings.Cut(strings.TrimSpace(name), ":")
	if !found {
		return LedgerUnclassified, false
	}
	kind := rest[strings.LastIndex(rest, ":")+1:]
	if ledger, ok := chartByKind[scope+":"+kind]; ok {
		return ledger, true
	}
	return LedgerUnclassified, false
}
