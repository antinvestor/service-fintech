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

import "fmt"

// ProductUnallocatedAccount returns the product-level unallocated ledger account name.
func ProductUnallocatedAccount(productID string) string {
	return fmt.Sprintf("product:%s:unallocated", productID)
}

func ProductUnidentifiedAccount(productID string) string {
	return fmt.Sprintf("product:%s:unidentified", productID)
}

func ProductServiceFeePayableAccount(productID string) string {
	return fmt.Sprintf("product:%s:service_fee_payable", productID)
}

func ProductInsuranceAccount(productID string) string {
	return fmt.Sprintf("product:%s:insurance", productID)
}

// ProductBadDebtExpenseAccount returns the product-level bad-debt expense
// ledger account. Loans that transition to WRITTEN_OFF debit their
// outstanding balance into this expense account so the P&L reflects the
// realised loss.
func ProductBadDebtExpenseAccount(productID string) string {
	return fmt.Sprintf("product:%s:bad_debt_expense", productID)
}

// ProductSavingsInterestExpenseAccount returns the product-level savings
// interest expense account. Each savings interest accrual debits this
// account (an expense to the platform) and credits the member's savings
// asset account (a liability we owe the member).
func ProductSavingsInterestExpenseAccount(productID string) string {
	return fmt.Sprintf("product:%s:savings_interest_expense", productID)
}

// ProductExternalCashAccount is the product-level external cash control
// account: the stand-in for "real world" money held on behalf of the
// product (e.g. the bank account for investor capital inflows). Every
// money-in or money-out posting at the product scope debits or credits
// this account.
func ProductExternalCashAccount(productID string) string {
	return fmt.Sprintf("product:%s:external_cash", productID)
}

// GroupBankAccount returns the group-level bank ledger account name.
func GroupBankAccount(groupID string) string {
	return fmt.Sprintf("group:%s:bank", groupID)
}

func GroupPenaltyIncomeAccount(groupID string) string {
	return fmt.Sprintf("group:%s:penalty_income", groupID)
}

func GroupInterestIncomeAccount(groupID string) string {
	return fmt.Sprintf("group:%s:interest_income", groupID)
}

func GroupJoiningFeeAccount(groupID string) string {
	return fmt.Sprintf("group:%s:joining_fee", groupID)
}

func GroupTransactionCostsAccount(groupID string) string {
	return fmt.Sprintf("group:%s:transaction_costs", groupID)
}

func GroupServiceFeeAccount(groupID string) string {
	return fmt.Sprintf("group:%s:service_fee", groupID)
}

func GroupSavingsInterestIncomeAccount(groupID string) string {
	return fmt.Sprintf("group:%s:savings_interest_income", groupID)
}

// MemberSuspenseAccount returns the member-level suspense ledger account name.
func MemberSuspenseAccount(memberID string) string {
	return fmt.Sprintf("member:%s:suspense", memberID)
}

// ClientSuspenseAccount returns the client-level suspense ledger account
// name used by the seed direct-to-client lending product. Every inbound
// payment for a seed client first lands in this account; obligation-
// driven transfer orders then move funds from the suspense into the
// specific destination (loan, savings, fee, etc.).
func ClientSuspenseAccount(clientID string) string {
	return fmt.Sprintf("client:%s:suspense", clientID)
}

func MemberLendingAccount(memberID string) string {
	return fmt.Sprintf("member:%s:lending", memberID)
}

func MemberPeriodicSavingsAccount(memberID string) string {
	return fmt.Sprintf("member:%s:periodic_savings", memberID)
}

func MemberLoansAccount(memberID string) string {
	return fmt.Sprintf("member:%s:loans", memberID)
}

// AgentCashAccount is the cash a field agent holds on the lender's behalf:
// repayments collected in cash are debited here, not to the borrower's own
// account, until the agent remits them. Its balance is what the agent owes
// the till.
func AgentCashAccount(agentProfileID string) string {
	return fmt.Sprintf("agent:%s:cash_in_hand", agentProfileID)
}

// MemberPenaltyReceivableAccount is the receivable account that is debited
// when a penalty is applied to a member and credited when the penalty is
// settled via repayment waterfall. It is the accrual-side counterpart to
// the product's penalty income account.
func MemberPenaltyReceivableAccount(memberID string) string {
	return fmt.Sprintf("member:%s:penalty_receivable", memberID)
}

// InvestorCapitalAccount returns the investor-level capital ledger account name.
func InvestorCapitalAccount(investorAccountID string) string {
	return fmt.Sprintf("investor:%s:capital", investorAccountID)
}

func InvestorReservedAccount(investorAccountID string) string {
	return fmt.Sprintf("investor:%s:reserved", investorAccountID)
}

// PlatformFirstLossAccount returns the platform-level first loss ledger account name.
func PlatformFirstLossAccount(productID string) string {
	return fmt.Sprintf("platform:%s:first_loss", productID)
}

func PlatformIncomeAccount(productID string) string {
	return fmt.Sprintf("platform:%s:income", productID)
}

// PlatformExternalCashAccount returns the platform-wide external cash
// control account. Used as the counter-party for money movements that are
// not scoped to a specific product — notably investor capital deposits and
// withdrawals, which are investor-scoped rather than product-scoped.
func PlatformExternalCashAccount() string {
	return "platform:external_cash"
}
