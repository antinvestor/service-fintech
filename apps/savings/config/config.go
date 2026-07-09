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

package config

import (
	"github.com/pitabwire/frame/v2/config"
)

type SavingsConfig struct {
	config.ConfigurationDefault

	// Identity service (internal lender service)
	IdentityServiceURI                   string `envDefault:"127.0.0.1:7001"                  env:"IDENTITY_SERVICE_URI"`
	IdentityServiceWorkloadAPITargetPath string `envDefault:"/ns/fintech/sa/service-identity" env:"IDENTITY_SERVICE_WORKLOAD_API_TARGET_PATH"`

	// Operations service: the gateway through which all ledger postings are
	// made. Every deposit and withdrawal issues a transfer order against this
	// service so the double-entry ledger mirrors the savings state.
	OperationsServiceURI                   string `envDefault:"127.0.0.1:7060"                    env:"OPERATIONS_SERVICE_URI"`
	OperationsServiceWorkloadAPITargetPath string `envDefault:"/ns/fintech/sa/service-operations" env:"OPERATIONS_SERVICE_WORKLOAD_API_TARGET_PATH"`

	// Limits service: gates deposit and withdrawal actions through the
	// centralised caps engine. Both fields are optional; when LimitsServiceURI
	// is empty the consumer.SetupClient returns nil and the gate is skipped.
	LimitsServiceURI                   string `envDefault:"http://service_limits:80" env:"LIMITS_SERVICE_URI"`
	LimitsServiceWorkloadAPITargetPath string `envDefault:""                         env:"LIMITS_SERVICE_WORKLOAD_API_TARGET_PATH"`
	LimitsGateEnabledSavingsDeposit    bool   `envDefault:"false"                    env:"LIMITS_GATE_ENABLED_SAVINGS_DEPOSIT"`
	LimitsGateModeSavingsDeposit       string `envDefault:"enforce"                  env:"LIMITS_GATE_MODE_SAVINGS_DEPOSIT"`
	LimitsGateEnabledSavingsWithdrawal bool   `envDefault:"false"                    env:"LIMITS_GATE_ENABLED_SAVINGS_WITHDRAWAL"`
	LimitsGateModeSavingsWithdrawal    string `envDefault:"enforce"                  env:"LIMITS_GATE_MODE_SAVINGS_WITHDRAWAL"`
}
