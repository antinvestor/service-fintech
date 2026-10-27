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

package trustage

import (
	"encoding/json"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"testing/fstest"

	"github.com/stretchr/testify/require"
)

// A service's own endpoint is filled into its workflows at sync, so the
// workflow names the service and trustage needs nothing configured for it.
func TestWithEndpointFillsTheServicesOwnAddress(t *testing.T) {
	src := fstest.MapFS{
		"a.json": {Data: []byte(`{"call":{"input":{"endpoint":"${SERVICE_ENDPOINT}"}}}`)},
		"b.json": {Data: []byte(`{"name":"no calls"}`)},
	}
	out, err := withEndpoint(src, "http://service-loans.fintech.svc:80")
	require.NoError(t, err)

	a, err := fs.ReadFile(out, "a.json")
	require.NoError(t, err)
	require.JSONEq(t, `{"call":{"input":{"endpoint":"http://service-loans.fintech.svc:80"}}}`, string(a))
	b, err := fs.ReadFile(out, "b.json")
	require.NoError(t, err)
	require.JSONEq(t, `{"name":"no calls"}`, string(b))
}

func TestSelfEndpointDefaultsInClusterAndCanBeOverridden(t *testing.T) {
	t.Setenv("TRUSTAGE_CALLBACK_ENDPOINT", "")
	got := SelfEndpoint("service-loans")
	require.True(t, strings.HasPrefix(got, "http://service-loans."), got)
	require.True(t, strings.HasSuffix(got, ".svc:80"), got)

	t.Setenv("TRUSTAGE_CALLBACK_ENDPOINT", "http://service-fintech-loans.stawi.svc:80/")
	require.Equal(t, "http://service-fintech-loans.stawi.svc:80", SelfEndpoint("service-loans"))
}

// Every connect.call a service ships names its own endpoint; without it
// trustage would have no way to reach the service.
func TestShippedConnectCallsNameTheirService(t *testing.T) {
	files, err := filepath.Glob("../../products/*/workflows/*.json")
	require.NoError(t, err)
	require.NotEmpty(t, files)
	for _, f := range files {
		raw, readErr := os.ReadFile(f)
		require.NoError(t, readErr)
		var spec any
		require.NoError(t, json.Unmarshal(raw, &spec))
		for _, input := range connectCallInputs(spec) {
			require.Equal(t, EndpointPlaceholder, input["endpoint"], "%s: connect.call without its endpoint", f)
		}
	}
}

func connectCallInputs(node any) []map[string]any {
	var out []map[string]any
	switch v := node.(type) {
	case map[string]any:
		if call, ok := v["call"].(map[string]any); ok && call["action"] == "connect.call" {
			if input, isMap := call["input"].(map[string]any); isMap {
				out = append(out, input)
			}
		}
		for _, child := range v {
			out = append(out, connectCallInputs(child)...)
		}
	case []any:
		for _, child := range v {
			out = append(out, connectCallInputs(child)...)
		}
	}
	return out
}
