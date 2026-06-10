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

// loansMetrics creates transparently tenant-scoped instruments: every
// measurement automatically carries tenant_id/partition_id derived from
// the context's security claims, so call sites cannot forget tenant
// attribution.
//
//nolint:gochecknoglobals // OTel metric instruments are registered at package level per SDK convention.
var loansMetrics = telemetry.NewBusinessMetrics("service-loans")

//nolint:gochecknoglobals // OTel metric instruments are registered at package level per SDK convention.
var (
	LoansCreated = loansMetrics.Counter("loans_created_total",
		"New loan accounts created",
		metric.WithUnit("{loan}"))

	LoansDisbursed = loansMetrics.Counter("loans_disbursed_total",
		"Loan disbursements completed",
		metric.WithUnit("{disbursement}"))

	LoansDisbursedAmount = loansMetrics.FloatCounter("loans_disbursed_amount_total",
		"Total amount disbursed",
		metric.WithUnit("{currency_unit}"))

	LoansRepaid = loansMetrics.Counter("loans_repaid_total",
		"Loan repayments recorded",
		metric.WithUnit("{repayment}"))

	LoansRepaidAmount = loansMetrics.FloatCounter("loans_repaid_amount_total",
		"Total amount repaid",
		metric.WithUnit("{currency_unit}"))

	LoansDefaulted = loansMetrics.Counter("loans_defaulted_total",
		"Loans transitioned to default status",
		metric.WithUnit("{loan}"))

	LoansClosed = loansMetrics.Counter("loans_closed_total",
		"Loans closed",
		metric.WithUnit("{loan}"))

	LoansRestructured = loansMetrics.Counter("loans_restructured_total",
		"Loans restructured",
		metric.WithUnit("{loan}"))

	LoansWrittenOff = loansMetrics.Counter("loans_written_off_total",
		"Loans written off",
		metric.WithUnit("{loan}"))
)

// MetricInfo describes a registered OTel counter for discoverability.
type MetricInfo struct {
	Name        string `json:"name"`
	Type        string `json:"type"`
	Unit        string `json:"unit"`
	Description string `json:"description"`
}

// RegisteredMetrics returns the list of all OTel counters registered by
// the loans business package.
func RegisteredMetrics() []MetricInfo {
	return []MetricInfo{
		{
			Name:        "loans_created_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "New loan accounts created",
		},
		{
			Name:        "loans_disbursed_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Loan disbursements completed",
		},
		{
			Name:        "loans_disbursed_amount_total",
			Type:        metricTypeCounter,
			Unit:        "currency_unit",
			Description: "Total amount disbursed",
		},
		{
			Name:        "loans_repaid_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Loan repayments recorded",
		},
		{
			Name:        "loans_repaid_amount_total",
			Type:        metricTypeCounter,
			Unit:        "currency_unit",
			Description: "Total amount repaid",
		},
		{
			Name:        "loans_defaulted_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Loans transitioned to default status",
		},
		{Name: "loans_closed_total", Type: metricTypeCounter, Unit: metricUnitCount, Description: "Loans closed"},
		{
			Name:        "loans_restructured_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Loans restructured",
		},
		{
			Name:        "loans_written_off_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Loans written off",
		},
	}
}
