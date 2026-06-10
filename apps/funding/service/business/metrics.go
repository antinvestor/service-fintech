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
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/metric"
)

// minorUnitsPerMajor converts minor currency units (e.g. cents) to major units (e.g. dollars).
const minorUnitsPerMajor = 100.0

//nolint:gochecknoglobals // OTel metric instruments are registered at package level per SDK convention.
var fundingMeter = otel.Meter("service-funding")

//nolint:gochecknoglobals // OTel metric instruments are registered at package level per SDK convention.
var (
	FundingDeposits, _ = fundingMeter.Int64Counter("funding_deposits_total",
		metric.WithDescription("Investor capital deposits"),
		metric.WithUnit("{deposit}"))

	FundingDepositsAmount, _ = fundingMeter.Float64Counter("funding_deposits_amount_total",
		metric.WithDescription("Total investor capital deposited"),
		metric.WithUnit("{currency_unit}"))

	FundingWithdrawals, _ = fundingMeter.Int64Counter("funding_withdrawals_total",
		metric.WithDescription("Investor capital withdrawals"),
		metric.WithUnit("{withdrawal}"))

	FundingWithdrawalsAmount, _ = fundingMeter.Float64Counter("funding_withdrawals_amount_total",
		metric.WithDescription("Total investor capital withdrawn"),
		metric.WithUnit("{currency_unit}"))

	FundingAllocations, _ = fundingMeter.Int64Counter("funding_allocations_total",
		metric.WithDescription("Funding allocations completed for loan requests"),
		metric.WithUnit("{allocation}"))

	FundingAllocationsAmount, _ = fundingMeter.Float64Counter("funding_allocations_amount_total",
		metric.WithDescription("Total funding allocated to loan requests"),
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
// the funding business package.
func RegisteredMetrics() []MetricInfo {
	return []MetricInfo{
		{
			Name:        "funding_deposits_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Investor capital deposits",
		},
		{
			Name:        "funding_deposits_amount_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCurrency,
			Description: "Total investor capital deposited",
		},
		{
			Name:        "funding_withdrawals_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Investor capital withdrawals",
		},
		{
			Name:        "funding_withdrawals_amount_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCurrency,
			Description: "Total investor capital withdrawn",
		},
		{
			Name:        "funding_allocations_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Funding allocations completed for loan requests",
		},
		{
			Name:        "funding_allocations_amount_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCurrency,
			Description: "Total funding allocated to loan requests",
		},
	}
}
