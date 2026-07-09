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

// identityMetrics creates transparently tenant-scoped instruments: every
// measurement automatically carries tenant_id/partition_id derived from
// the context's security claims, so call sites cannot forget tenant
// attribution.
//
//nolint:gochecknoglobals // OTel metric instruments are registered at package level per SDK convention.
var identityMetrics = telemetry.NewBusinessMetrics("service-identity")

//nolint:gochecknoglobals // OTel metric instruments are registered at package level per SDK convention.
var (
	IdentityOrganizationsCreated = identityMetrics.Counter("identity_organizations_created_total",
		"New organizations created",
		metric.WithUnit("{organization}"))

	IdentityOrgUnitsCreated = identityMetrics.Counter("identity_org_units_created_total",
		"New organizational units created",
		metric.WithUnit("{org_unit}"))

	IdentityWorkforceAdded = identityMetrics.Counter("identity_workforce_added_total",
		"Workforce members added",
		metric.WithUnit("{member}"))

	IdentityWorkforceRemoved = identityMetrics.Counter("identity_workforce_removed_total",
		"Workforce members removed (deactivated)",
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
