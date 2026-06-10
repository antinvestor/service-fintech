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
	fieldMembershipID         = "membership_id"
	fieldPayerName            = "payer_name"
	fieldPaymentID            = "payment_id"
	fieldProductID            = "product_id"
	fieldProfileID            = "profile_id"
	fieldState                = "state"
	metricTypeCounter         = "counter"
	metricUnitCount           = "count"
	obligationPenalty         = "penalty"
	obligationPeriodicSaving  = "periodic_saving"
	obligationRegistrationFee = "registration_fee"
	obligationServiceFee      = "service_fee"
)
