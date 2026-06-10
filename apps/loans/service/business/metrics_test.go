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
	"context"
	"testing"

	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/security"
	"github.com/stretchr/testify/require"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/metric/metricdata"
)

// sumDataPointAttrs returns the attribute sets of all int64 sum datapoints
// for the named metric in the collected resource metrics.
func sumDataPointAttrs(rm metricdata.ResourceMetrics, name string) []attribute.Set {
	var out []attribute.Set
	for _, sm := range rm.ScopeMetrics {
		for _, m := range sm.Metrics {
			if m.Name != name {
				continue
			}
			if sum, ok := m.Data.(metricdata.Sum[int64]); ok {
				for _, dp := range sum.DataPoints {
					out = append(out, dp.Attributes)
				}
			}
		}
	}
	return out
}

// The business instruments must attach tenant_id/partition_id from the
// context's security claims transparently — call sites only pass business
// attributes such as currency — while claim-less (system) measurements
// record without tenant attributes.
func TestLoansCreatedCarriesTenantAttributes(t *testing.T) {
	reader := sdkmetric.NewManualReader()
	provider := sdkmetric.NewMeterProvider(sdkmetric.WithReader(reader))
	prev := otel.GetMeterProvider()
	otel.SetMeterProvider(provider)
	t.Cleanup(func() { otel.SetMeterProvider(prev) })

	claimsCtx := (&security.AuthenticationClaims{
		TenantID:    "tenant-metrics-test",
		PartitionID: "partition-metrics-test",
		RegisteredClaims: jwt.RegisteredClaims{
			Subject: "profile-metrics-test",
		},
	}).ClaimsToContext(context.Background())

	LoansCreated.Add(claimsCtx, 1, attribute.String("currency", "KES"))
	// System path: no claims in context, no tenant attributes recorded.
	LoansCreated.Add(context.Background(), 1)

	var rm metricdata.ResourceMetrics
	require.NoError(t, reader.Collect(context.Background(), &rm))

	sets := sumDataPointAttrs(rm, "loans_created_total")
	require.Len(t, sets, 2, "tenant-scoped and system datapoints must be distinct series")

	var tenantSet, systemSet *attribute.Set
	for i := range sets {
		if _, ok := sets[i].Value("tenant_id"); ok {
			tenantSet = &sets[i]
		} else {
			systemSet = &sets[i]
		}
	}
	require.NotNil(t, tenantSet, "claims context must yield a tenant_id attribute")
	require.NotNil(t, systemSet, "claim-less context must omit tenant attributes")

	tid, _ := tenantSet.Value("tenant_id")
	pid, _ := tenantSet.Value("partition_id")
	currency, _ := tenantSet.Value("currency")
	require.Equal(t, "tenant-metrics-test", tid.AsString())
	require.Equal(t, "partition-metrics-test", pid.AsString())
	require.Equal(t, "KES", currency.AsString(), "explicit attributes preserved alongside tenant attributes")
}
