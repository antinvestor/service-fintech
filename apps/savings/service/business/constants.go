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

import "time"

// Shared string constants for repeated metadata keys, SQL fragments, and
// label values used across this package (extracted to satisfy goconst).
const (
	fieldAmount              = "amount"
	fieldChannel             = "channel"
	fieldCurrency            = "currency"
	fieldLedgerTransactionID = "ledger_transaction_id"
	fieldOwnerID             = "owner_id"
	fieldRecipientReference  = "recipient_reference"
	fieldSavingsAccountID    = "savings_account_id"
	fieldStatus              = "status"
	entityWithdrawal         = "savings_withdrawal"
	metricTypeCounter        = "counter"
	metricUnitCount          = "count"
	metricUnitCurrency       = "currency_unit"
	whereCreatedAtGte        = "created_at >= ?"
	whereCreatedAtLte        = "created_at <= ?"
	whereSavingsAccountIDEq  = "savings_account_id = ?"
	whereStatusEq            = "status = ?"

	// searchableTSQuery is the GORM map-key predicate for full-text search
	// against the generated "searchable" tsvector column.
	searchableTSQuery = "searchable @@ websearch_to_tsquery( 'english', ?) "

	// statementDefaultWindow is how far back a statement reaches when the
	// caller does not give a start date.
	statementDefaultWindow = 90 * 24 * time.Hour
	// statementMaxEntries bounds a single statement response.
	statementMaxEntries = 500
)
