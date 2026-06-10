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

//nolint:gochecknoglobals // OTel metric instruments are registered at package level per SDK convention.
var identityMeter = otel.Meter("service-identity")

//nolint:gochecknoglobals // OTel metric instruments are registered at package level per SDK convention.
var (
	IdentityOrganizationsCreated, _ = identityMeter.Int64Counter("identity_organizations_created_total",
		metric.WithDescription("New organizations created"),
		metric.WithUnit("{organization}"))

	IdentityOrgUnitsCreated, _ = identityMeter.Int64Counter("identity_org_units_created_total",
		metric.WithDescription("New organizational units created"),
		metric.WithUnit("{org_unit}"))

	IdentityWorkforceAdded, _ = identityMeter.Int64Counter("identity_workforce_added_total",
		metric.WithDescription("Workforce members added"),
		metric.WithUnit("{member}"))

	IdentityWorkforceRemoved, _ = identityMeter.Int64Counter("identity_workforce_removed_total",
		metric.WithDescription("Workforce members removed (deactivated)"),
		metric.WithUnit("{member}"))
)

// MetricInfo describes a registered OTel counter for discoverability.
type MetricInfo struct {
	Name        string `json:"name"`
	Type        string `json:"type"`
	Unit        string `json:"unit"`
	Description string `json:"description"`
}

// RegisteredMetrics returns the list of all OTel counters registered by
// the identity business package.
func RegisteredMetrics() []MetricInfo {
	return []MetricInfo{
		{
			Name:        "identity_organizations_created_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "New organizations created",
		},
		{
			Name:        "identity_org_units_created_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "New organizational units created",
		},
		{
			Name:        "identity_workforce_added_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Workforce members added",
		},
		{
			Name:        "identity_workforce_removed_total",
			Type:        metricTypeCounter,
			Unit:        metricUnitCount,
			Description: "Workforce members removed (deactivated)",
		},
	}
}
