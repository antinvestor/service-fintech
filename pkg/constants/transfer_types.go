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

import "sort"

// Transfer order type constants matching Java OrderType enum values exactly.
const (
	TransferTypePayment                                   = 1
	TransferTypePaymentIdentified                         = 2
	TransferTypePaymentAllocated                          = 3
	TransferTypeDisbursement                              = 6
	TransferTypeDisbursementReversal                      = 7
	TransferTypeDisbursementReversalReroute               = 8
	TransferTypeTerminalDisbursement                      = 9
	TransferTypeTerminalDisbursementRecovery              = 10
	TransferTypeCost                                      = 11
	TransferTypeServiceFee                                = 16
	TransferTypeRegistrationFee                           = 21
	TransferTypePeriodicSaving                            = 25
	TransferTypePeriodicSavingsInterestIncomeDistribution = 26
	TransferTypePeriodicSavingRecovery                    = 27
	TransferTypePenalty                                   = 31
	TransferTypePenaltyCancel                             = 32
	TransferTypePenaltyIncomeDistribution                 = 33
	// TransferTypePenaltyRepayment settles an accrued penalty: the borrower's
	// payment clears the penalty receivable that TransferTypePenalty opened.
	// Income was recognised at accrual; settling it must not recognise it
	// again, which is why this is not TransferTypePenaltyCancel (a waiver).
	TransferTypePenaltyRepayment                  = 34
	TransferTypeLoanFundingExternalLending        = 36
	TransferTypeLoanFundingExternalLendingPayback = 37
	TransferTypeInvestorDeployment                = 38 // investor account → loan (capital deployed)
	TransferTypeInvestorPrincipalReturn           = 39 // loan repayment → investor account (principal back)
	TransferTypeInvestorIncomeDistribution        = 40 // interest/fees → investor account (earnings)
	TransferTypeLoan                              = 41
	TransferTypeLoanRepayment                     = 42
	TransferTypeShutdownLoanRecovery              = 43
	TransferTypePlatformFirstLossAbsorption       = 44 // platform reserve → loss (first-loss triggered)
	TransferTypeInvestorLossAbsorption            = 45 // investor account → loss (investor loss)
	TransferTypeLoanInterest                      = 46
	TransferTypeLoanInterestRepayment             = 47
	TransferTypeLoanInterestIncomeDistribution    = 48
	TransferTypeLoanInsurance                     = 51
	TransferTypeLoanInsuranceRepayment            = 52
	TransferTypeInterSubscriptionPayment          = 71
)

// transferTypeNames maps each transfer type constant to its human-readable name.
var transferTypeNames = map[int]string{ //nolint:gochecknoglobals // package-level lookup table
	TransferTypePayment:                                   "PAYMENT",
	TransferTypePaymentIdentified:                         "PAYMENT_IDENTIFIED",
	TransferTypePaymentAllocated:                          "PAYMENT_ALLOCATED",
	TransferTypeDisbursement:                              "DISBURSEMENT",
	TransferTypeDisbursementReversal:                      "DISBURSEMENT_REVERSAL",
	TransferTypeDisbursementReversalReroute:               "DISBURSEMENT_REVERSAL_REROUTE",
	TransferTypeTerminalDisbursement:                      "TERMINAL_DISBURSEMENT",
	TransferTypeTerminalDisbursementRecovery:              "TERMINAL_DISBURSEMENT_RECOVERY",
	TransferTypeCost:                                      "COST",
	TransferTypeServiceFee:                                "SERVICE_FEE",
	TransferTypeRegistrationFee:                           "REGISTRATION_FEE",
	TransferTypePeriodicSaving:                            "PERIODIC_SAVING",
	TransferTypePeriodicSavingsInterestIncomeDistribution: "PERIODIC_SAVINGS_INTEREST_INCOME_DISTRIBUTION",
	TransferTypePeriodicSavingRecovery:                    "PERIODIC_SAVING_RECOVERY",
	TransferTypePenalty:                                   "PENALTY",
	TransferTypePenaltyCancel:                             "PENALTY_CANCEL",
	TransferTypePenaltyIncomeDistribution:                 "PENALTY_INCOME_DISTRIBUTION",
	TransferTypePenaltyRepayment:                          "PENALTY_REPAYMENT",
	TransferTypeLoanFundingExternalLending:                "LOAN_FUNDING_EXTERNAL_LENDING",
	TransferTypeLoanFundingExternalLendingPayback:         "LOAN_FUNDING_EXTERNAL_LENDING_PAYBACK",
	TransferTypeLoan:                                      "LOAN",
	TransferTypeLoanRepayment:                             "LOAN_REPAYMENT",
	TransferTypeShutdownLoanRecovery:                      "SHUTDOWN_LOAN_RECOVERY",
	TransferTypeLoanInterest:                              "LOAN_INTEREST",
	TransferTypeLoanInterestRepayment:                     "LOAN_INTEREST_REPAYMENT",
	TransferTypeLoanInterestIncomeDistribution:            "LOAN_INTEREST_INCOME_DISTRIBUTION",
	TransferTypeLoanInsurance:                             "LOAN_INSURANCE",
	TransferTypeLoanInsuranceRepayment:                    "LOAN_INSURANCE_REPAYMENT",
	TransferTypeInvestorDeployment:                        "INVESTOR_DEPLOYMENT",
	TransferTypeInvestorPrincipalReturn:                   "INVESTOR_PRINCIPAL_RETURN",
	TransferTypeInvestorIncomeDistribution:                "INVESTOR_INCOME_DISTRIBUTION",
	TransferTypePlatformFirstLossAbsorption:               "PLATFORM_FIRST_LOSS_ABSORPTION",
	TransferTypeInvestorLossAbsorption:                    "INVESTOR_LOSS_ABSORPTION",
	TransferTypeInterSubscriptionPayment:                  "INTER_SUBSCRIPTION_PAYMENT",
}

// TransferTypeEntry pairs a transfer type value with its canonical name.
type TransferTypeEntry struct {
	Value int
	Name  string
}

// TransferTypes returns the whole transfer type table ordered by value. It is
// the single source of truth for any surface that has to render or filter by
// transfer type, including the Dart mirror in ui/operations.
func TransferTypes() []TransferTypeEntry {
	entries := make([]TransferTypeEntry, 0, len(transferTypeNames))
	for value, name := range transferTypeNames {
		entries = append(entries, TransferTypeEntry{Value: value, Name: name})
	}
	sort.Slice(entries, func(i, j int) bool { return entries[i].Value < entries[j].Value })
	return entries
}

// TransferTypeName returns a human-readable name for a transfer type.
func TransferTypeName(t int) string {
	if name, ok := transferTypeNames[t]; ok {
		return name
	}
	return "UNKNOWN"
}

// IsLoanRelated returns true if the transfer type is related to loan management.
func IsLoanRelated(t int) bool {
	switch t {
	case TransferTypeDisbursement, TransferTypeDisbursementReversal,
		TransferTypeLoan, TransferTypeLoanRepayment,
		TransferTypeLoanInterest, TransferTypeLoanInterestRepayment,
		TransferTypeLoanInsurance, TransferTypeLoanInsuranceRepayment,
		TransferTypeInvestorDeployment, TransferTypeInvestorPrincipalReturn,
		TransferTypeInvestorIncomeDistribution,
		TransferTypePlatformFirstLossAbsorption, TransferTypeInvestorLossAbsorption:
		return true
	default:
		return false
	}
}

// IsSavingsRelated returns true if the transfer type is related to savings.
func IsSavingsRelated(t int) bool {
	switch t {
	case TransferTypePeriodicSaving, TransferTypePeriodicSavingRecovery,
		TransferTypePeriodicSavingsInterestIncomeDistribution,
		TransferTypeRegistrationFee, TransferTypeTerminalDisbursement,
		TransferTypeTerminalDisbursementRecovery:
		return true
	default:
		return false
	}
}
