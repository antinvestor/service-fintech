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
	"github.com/pitabwire/frame/telemetry"
	"go.opentelemetry.io/otel/metric"
)

// minorUnitsPerMajor converts minor currency units (e.g. cents) to major units (e.g. dollars).
const minorUnitsPerMajor = 100.0

// operationsMetrics creates transparently tenant-scoped instruments: every
// measurement automatically carries tenant_id/partition_id derived from
// the context's security claims, so call sites cannot forget tenant
// attribution.
//
//nolint:gochecknoglobals // OTel metric instruments are registered at package level per SDK convention.
var operationsMetrics = telemetry.NewBusinessMetrics("service-operations")

//nolint:gochecknoglobals // OTel metric instruments are registered at package level per SDK convention.
var (
	OpsTransfersExecuted = operationsMetrics.Counter("ops_transfers_executed_total",
		"Transfer orders executed",
		metric.WithUnit("{transfer}"))

	OpsTransfersAmount = operationsMetrics.FloatCounter("ops_transfers_amount_total",
		"Total amount of executed transfers",
		metric.WithUnit("{currency_unit}"))

	OpsPaymentsReceived = operationsMetrics.Counter("ops_payments_received_total",
		"Incoming payments received",
		metric.WithUnit("{payment}"))

	OpsPaymentsAmount = operationsMetrics.FloatCounter("ops_payments_amount_total",
		"Total amount of incoming payments",
		metric.WithUnit("{currency_unit}"))

	OpsPaymentsAllocated = operationsMetrics.Counter("ops_payments_allocated_total",
		"Payments successfully allocated to obligations",
		metric.WithUnit("{payment}"))

	OpsPaymentsUnmatched = operationsMetrics.Counter("ops_payments_unmatched_total",
		"Payments that could not be identified",
		metric.WithUnit("{payment}"))
)

// MetricInfo describes a registered OTel counter for discoverability.
type MetricInfo struct {
	Name        string `json:"name"`
	Type        string `json:"type"`
	Unit        string `json:"unit"`
	Description string `json:"description"`
}

// RegisteredMetrics returns the list of all OTel counters registered by
// the operations business package.
func RegisteredMetrics() []MetricInfo {
	return []MetricInfo{
		{
			Name:        "ops_transfers_executed_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Transfer orders executed",
		},
		{
			Name:        "ops_transfers_amount_total",
			Type:        metricTypeCounter,
			Unit:        "currency_unit",
			Description: "Total amount of executed transfers",
		},
		{
			Name:        "ops_payments_received_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Incoming payments received",
		},
		{
			Name:        "ops_payments_amount_total",
			Type:        metricTypeCounter,
			Unit:        "currency_unit",
			Description: "Total amount of incoming payments",
		},
		{
			Name:        "ops_payments_allocated_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Payments successfully allocated to obligations",
		},
		{
			Name:        "ops_payments_unmatched_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Payments that could not be identified",
		},
	}
}
