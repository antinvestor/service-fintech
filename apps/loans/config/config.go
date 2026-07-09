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

type LoanManagementConfig struct {
	config.ConfigurationDefault
	IdentityServiceURI                       string `envDefault:"127.0.0.1:7001"                           env:"IDENTITY_SERVICE_URI"`
	IdentityServiceWorkloadAPITargetPath     string `envDefault:"/ns/identity/sa/service-identity"         env:"IDENTITY_SERVICE_WORKLOAD_API_TARGET_PATH"`
	LedgerServiceURI                         string `envDefault:"127.0.0.1:7020"                           env:"LEDGER_SERVICE_URI"`
	LedgerServiceWorkloadAPITargetPath       string `envDefault:"/ns/ledger/sa/service-ledger"             env:"LEDGER_SERVICE_WORKLOAD_API_TARGET_PATH"`
	PaymentServiceURI                        string `envDefault:"127.0.0.1:7030"                           env:"PAYMENT_SERVICE_URI"`
	PaymentServiceWorkloadAPITargetPath      string `envDefault:"/ns/payment/sa/service-payment"           env:"PAYMENT_SERVICE_WORKLOAD_API_TARGET_PATH"`
	NotificationServiceURI                   string `envDefault:"127.0.0.1:7040"                           env:"NOTIFICATION_SERVICE_URI"`
	NotificationServiceWorkloadAPITargetPath string `envDefault:"/ns/notification/sa/service-notification" env:"NOTIFICATION_SERVICE_WORKLOAD_API_TARGET_PATH"`
	TrustageServiceURI                       string `envDefault:"127.0.0.1:7050"                           env:"TRUSTAGE_SERVICE_URI"`
	TrustageServiceWorkloadAPITargetPath     string `envDefault:"/ns/trustage/sa/service-trustage"         env:"TRUSTAGE_SERVICE_WORKLOAD_API_TARGET_PATH"`
	ProfileServiceURI                        string `envDefault:"127.0.0.1:7005"                           env:"PROFILE_SERVICE_URI"`
	ProfileServiceWorkloadAPITargetPath      string `envDefault:"/ns/profile/sa/service-profile"           env:"PROFILE_SERVICE_WORKLOAD_API_TARGET_PATH"`
	TenancyServiceURI                        string `envDefault:"127.0.0.1:7003"                           env:"TENANCY_SERVICE_URI"`
	TenancyServiceWorkloadAPITargetPath      string `envDefault:"/ns/auth/sa/service-tenancy"              env:"TENANCY_SERVICE_WORKLOAD_API_TARGET_PATH"`
	OperationsServiceURI                     string `envDefault:"127.0.0.1:7060"                           env:"OPERATIONS_SERVICE_URI"`
	OperationsServiceWorkloadAPITargetPath   string `envDefault:"/ns/fintech/sa/service-operations"        env:"OPERATIONS_SERVICE_WORKLOAD_API_TARGET_PATH"`
	FundingServiceURI                        string `envDefault:"127.0.0.1:7070"                           env:"FUNDING_SERVICE_URI"`
	FundingServiceWorkloadAPITargetPath      string `envDefault:"/ns/fintech/sa/service-funding"           env:"FUNDING_SERVICE_WORKLOAD_API_TARGET_PATH"`
	LimitsServiceURI                         string `envDefault:"http://service_limits:80"                 env:"LIMITS_SERVICE_URI"`
	LimitsServiceWorkloadAPITargetPath       string `envDefault:""                                         env:"LIMITS_SERVICE_WORKLOAD_API_TARGET_PATH"`
	LimitsGateEnabledLoanDisbursement        bool   `envDefault:"false"                                    env:"LIMITS_GATE_ENABLED_LOAN_DISBURSEMENT"`
	LimitsGateModeLoanDisbursement           string `envDefault:"enforce"                                  env:"LIMITS_GATE_MODE_LOAN_DISBURSEMENT"`
	LimitsGateEnabledLoanRequestApproval     bool   `envDefault:"false"                                    env:"LIMITS_GATE_ENABLED_LOAN_REQUEST_APPROVAL"`
	LimitsGateModeLoanRequestApproval        string `envDefault:"enforce"                                  env:"LIMITS_GATE_MODE_LOAN_REQUEST_APPROVAL"`
	LimitsGateEnabledLoanRepayment           bool   `envDefault:"false"                                    env:"LIMITS_GATE_ENABLED_LOAN_REPAYMENT"`
	LimitsGateModeLoanRepayment              string `envDefault:"enforce"                                  env:"LIMITS_GATE_MODE_LOAN_REPAYMENT"`

	DefaultGracePeriodDays   int `envDefault:"3"  env:"DEFAULT_GRACE_PERIOD_DAYS"`
	DelinquencyThresholdDays int `envDefault:"7"  env:"DELINQUENCY_THRESHOLD_DAYS"`
	DefaultThresholdDays     int `envDefault:"90" env:"DEFAULT_THRESHOLD_DAYS"`
}
