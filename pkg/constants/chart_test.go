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

package constants_test

import (
	"testing"

	"github.com/antinvestor/service-fintech/pkg/constants"
)

// Every account name the platform builds is on the chart.
func TestEveryAccountNameIsOnTheChart(t *testing.T) {
	names := []string{
		constants.ProductUnallocatedAccount("p"), constants.ProductUnidentifiedAccount("p"),
		constants.ProductServiceFeePayableAccount("p"), constants.ProductInsuranceAccount("p"),
		constants.ProductBadDebtExpenseAccount("p"), constants.ProductSavingsInterestExpenseAccount("p"),
		constants.ProductExternalCashAccount("p"), constants.GroupBankAccount("g"),
		constants.GroupPenaltyIncomeAccount("g"), constants.GroupInterestIncomeAccount("g"),
		constants.GroupJoiningFeeAccount("g"), constants.GroupTransactionCostsAccount("g"),
		constants.GroupServiceFeeAccount("g"), constants.GroupSavingsInterestIncomeAccount("g"),
		constants.MemberSuspenseAccount("m"), constants.ClientSuspenseAccount("c"),
		constants.MemberLendingAccount("m"), constants.MemberPeriodicSavingsAccount("m"),
		constants.MemberLoansAccount("m"), constants.AgentCashAccount("a"),
		constants.MemberPenaltyReceivableAccount("m"), constants.InvestorCapitalAccount("i"),
		constants.InvestorReservedAccount("i"), constants.PlatformFirstLossAccount("x"),
		constants.PlatformIncomeAccount("x"), constants.PlatformExternalCashAccount(),
		"savings:s1:balance",
	}
	for _, name := range names {
		if _, known := constants.LedgerForAccount(name); !known {
			t.Errorf("account %q is not on the chart", name)
		}
	}
	for _, name := range []string{
		"mystery", "member:x:unknown_kind", " member:x:loans", "member:a:b:loans",
		"member::loans", "member:X:loans", "member:a b:loans",
	} {
		if _, known := constants.LedgerForAccount(name); known {
			t.Errorf("%q must not be on the chart", name)
		}
	}
}
