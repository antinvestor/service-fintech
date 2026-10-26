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

// Shared string constants for repeated metadata keys, SQL fragments, and
// label values used across this package (extracted to satisfy goconst).
const (
	fieldAmount               = "amount"
	fieldCurrency             = "currency"
	fieldGroupID              = "group_id"
	fieldLoanAccountID        = "loan_account_id"
	fieldMembershipID         = "membership_id"
	fieldStrategy             = "strategy"
	fieldPayerName            = "payer_name"
	fieldPayerReference       = "payer_reference"
	fieldLoanID               = "loan_id"
	fieldClientID             = "client_id"
	fieldPaymentID            = "payment_id"
	fieldProductID            = "product_id"
	fieldProfileID            = "profile_id"
	fieldReference            = "reference"
	fieldRemainingAmount      = "remaining_amount"
	fieldTotalAmount          = "total_amount"
	fieldAllocatedAmount      = "allocated_amount"
	fieldPaymentState         = "payment_state"
	fieldIdentification       = "identification_strategy"
	fieldMemberID             = "member_id"
	fieldPeriodID             = "period_id"
	fieldDueDate              = "due_date"
	fieldState                = "state"
	fieldStatus               = "status"
	fieldTransactionID        = "transaction_id"
	fieldTransferOrderID      = "transfer_order_id"
	fieldTransferOrders       = "transfer_orders"
	fieldTotalOutstanding     = "total_outstanding"
	entityTransferOrder       = "transfer_order"
	metricTypeCounter         = "counter"
	metricUnitCount           = "count"
	obligationPenalty         = "penalty"
	obligationPeriodicSaving  = "periodic_saving"
	obligationSaving          = "saving"
	obligationRegistrationFee = "registration_fee"
	obligationServiceFee      = "service_fee"
)
