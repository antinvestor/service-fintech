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

package models

import (
	"github.com/pitabwire/frame/v2/data"
)

// SavingsBalance is the authoritative running-balance snapshot for a savings
// account. It holds:
//
//   - Balance          total settled funds available to the account
//   - ReservedBalance  funds earmarked by pending withdrawals
//
// Available funds for a new withdrawal are (Balance - ReservedBalance). All
// mutations must go through atomic SQL on the repository (Credit/Reserve/
// DebitReserved/ReleaseReserved) so concurrent deposit/withdrawal flows
// serialize correctly at the row level without application-side locking.
//
// Balance itself is updated only when a transfer order reaches the external
// Ledger successfully, so drift between this snapshot and the Ledger should
// only ever arise from a bug or an in-flight operation, never from races.
type SavingsBalance struct {
	data.BaseModel
	SavingsAccountID string `gorm:"type:varchar(50);uniqueIndex:uq_sb_savings_account"`
	CurrencyCode     string `gorm:"type:varchar(3)"`
	Balance          int64
	ReservedBalance  int64
	TotalDeposits    int64
	TotalWithdrawals int64
	TotalInterest    int64
}

func (m *SavingsBalance) TableName() string { return "savings_balances" }
