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

import (
	"github.com/pitabwire/frame/v2/telemetry"
	"go.opentelemetry.io/otel/metric"
)

// minorUnitsPerMajor converts minor currency units (e.g. cents) to major units (e.g. dollars).
const minorUnitsPerMajor = 100.0

// savingsMetrics creates transparently tenant-scoped instruments: every
// measurement automatically carries tenant_id/partition_id derived from
// the context's security claims, so call sites cannot forget tenant
// attribution.
//
//nolint:gochecknoglobals // OTel metric instruments are registered at package level per SDK convention.
var savingsMetrics = telemetry.NewBusinessMetrics("service-savings")

//nolint:gochecknoglobals // OTel metric instruments are registered at package level per SDK convention.
var (
	SavingsAccountsOpened = savingsMetrics.Counter("savings_accounts_opened_total",
		"New savings accounts opened",
		metric.WithUnit("{account}"))

	SavingsDeposits = savingsMetrics.Counter("savings_deposits_total",
		"Savings deposits completed",
		metric.WithUnit("{deposit}"))

	SavingsDepositsAmount = savingsMetrics.FloatCounter("savings_deposits_amount_total",
		"Total amount deposited into savings",
		metric.WithUnit("{currency_unit}"))

	SavingsWithdrawals = savingsMetrics.Counter("savings_withdrawals_total",
		"Savings withdrawals approved",
		metric.WithUnit("{withdrawal}"))

	SavingsWithdrawalsAmount = savingsMetrics.FloatCounter("savings_withdrawals_amount_total",
		"Total amount withdrawn from savings",
		metric.WithUnit("{currency_unit}"))

	SavingsInterestAccruedAmount = savingsMetrics.FloatCounter("savings_interest_accrued_amount_total",
		"Total interest accrued on savings accounts",
		metric.WithUnit("{currency_unit}"))
)

// MetricInfo describes a registered OTel counter for discoverability.
type MetricInfo struct {
	Name        string `json:"name"`
	Type        string `json:"type"`
	Unit        string `json:"unit"`
	Description string `json:"description"`
}

// RegisteredMetrics returns the list of all OTel counters registered by
// the savings business package.
func RegisteredMetrics() []MetricInfo {
	return []MetricInfo{
		{
			Name:        "savings_accounts_opened_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "New savings accounts opened",
		},
		{
			Name:        "savings_deposits_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Savings deposits completed",
		},
		{
			Name:        "savings_deposits_amount_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCurrency,
			Description: "Total amount deposited into savings",
		},
		{
			Name:        "savings_withdrawals_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Savings withdrawals approved",
		},
		{
			Name:        "savings_withdrawals_amount_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCurrency,
			Description: "Total amount withdrawn from savings",
		},
		{
			Name:        "savings_interest_accrued_amount_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCurrency,
			Description: "Total interest accrued on savings accounts",
		},
	}
}
