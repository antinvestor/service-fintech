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

	"github.com/antinvestor/service-fintech/pkg/clients"
)

type StawiConfig struct {
	config.ConfigurationDefault

	// Identity service
	IdentityServiceURI                   string `envDefault:"127.0.0.1:7001"                   env:"IDENTITY_SERVICE_URI"`
	IdentityServiceWorkloadAPITargetPath string `envDefault:"/ns/identity/sa/service-identity" env:"IDENTITY_SERVICE_WORKLOAD_API_TARGET_PATH"`

	// Loan management service
	LoanMgmtServiceURI                   string `envDefault:"127.0.0.1:7011"               env:"LOANMGMT_SERVICE_URI"`
	LoanMgmtServiceWorkloadAPITargetPath string `envDefault:"/ns/fintech/sa/service-loans" env:"LOANMGMT_SERVICE_WORKLOAD_API_TARGET_PATH"`

	// Savings service
	SavingsServiceURI                   string `envDefault:"127.0.0.1:7012"                 env:"SAVINGS_SERVICE_URI"`
	SavingsServiceWorkloadAPITargetPath string `envDefault:"/ns/fintech/sa/service-savings" env:"SAVINGS_SERVICE_WORKLOAD_API_TARGET_PATH"`

	// Ledger service
	LedgerServiceURI                   string `envDefault:"127.0.0.1:7020"               env:"LEDGER_SERVICE_URI"`
	LedgerServiceWorkloadAPITargetPath string `envDefault:"/ns/ledger/sa/service-ledger" env:"LEDGER_SERVICE_WORKLOAD_API_TARGET_PATH"`

	// Payment service
	PaymentServiceURI                   string `envDefault:"127.0.0.1:7030"                 env:"PAYMENT_SERVICE_URI"`
	PaymentServiceWorkloadAPITargetPath string `envDefault:"/ns/payment/sa/service-payment" env:"PAYMENT_SERVICE_WORKLOAD_API_TARGET_PATH"`

	// Notification service
	NotificationServiceURI                   string `envDefault:"127.0.0.1:7040"                           env:"NOTIFICATION_SERVICE_URI"`
	NotificationServiceWorkloadAPITargetPath string `envDefault:"/ns/notification/sa/service-notification" env:"NOTIFICATION_SERVICE_WORKLOAD_API_TARGET_PATH"`

	// Files service
	FilesServiceURI                   string `envDefault:"127.0.0.1:7050"             env:"FILES_SERVICE_URI"`
	FilesServiceWorkloadAPITargetPath string `envDefault:"/ns/files/sa/service-files" env:"FILES_SERVICE_WORKLOAD_API_TARGET_PATH"`

	// Profile service
	ProfileServiceURI                   string `envDefault:"127.0.0.1:7005"                 env:"PROFILE_SERVICE_URI"`
	ProfileServiceWorkloadAPITargetPath string `envDefault:"/ns/profile/sa/service-profile" env:"PROFILE_SERVICE_WORKLOAD_API_TARGET_PATH"`

	// Tenancy service
	TenancyServiceURI                   string `envDefault:"127.0.0.1:7003"              env:"TENANCY_SERVICE_URI"`
	TenancyServiceWorkloadAPITargetPath string `envDefault:"/ns/auth/sa/service-tenancy" env:"TENANCY_SERVICE_WORKLOAD_API_TARGET_PATH"`

	// Limits service: gates stawi loan disbursement through the centralised
	// caps engine. Both URI fields are optional; when LimitsServiceURI is
	// empty consumer.SetupClient returns nil and the gate is skipped at runtime.
	LimitsServiceURI                       string `envDefault:"http://service_limits:80" env:"LIMITS_SERVICE_URI"`
	LimitsServiceWorkloadAPITargetPath     string `envDefault:""                         env:"LIMITS_SERVICE_WORKLOAD_API_TARGET_PATH"`
	LimitsGateEnabledStawiLoanDisbursement bool   `envDefault:"false"                    env:"LIMITS_GATE_ENABLED_STAWI_LOAN_DISBURSEMENT"`
	LimitsGateModeStawiLoanDisbursement    string `envDefault:"enforce"                  env:"LIMITS_GATE_MODE_STAWI_LOAN_DISBURSEMENT"`
}

// ServiceEndpoints returns a clients.ServiceEndpoints populated from the config.
func (c *StawiConfig) ServiceEndpoints() clients.ServiceEndpoints {
	return clients.ServiceEndpoints{
		IdentityURI:     c.IdentityServiceURI,
		LoanMgmtURI:     c.LoanMgmtServiceURI,
		SavingsURI:      c.SavingsServiceURI,
		LedgerURI:       c.LedgerServiceURI,
		PaymentURI:      c.PaymentServiceURI,
		NotificationURI: c.NotificationServiceURI,
		FilesURI:        c.FilesServiceURI,
		ProfileURI:      c.ProfileServiceURI,
		PartitionURI:    c.TenancyServiceURI,
	}
}
