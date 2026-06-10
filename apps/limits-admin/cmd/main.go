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

package main

import (
	"context"
	"net/http"
	"os"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	"github.com/antinvestor/common"
	"github.com/antinvestor/common/connection"
	"github.com/spf13/cobra"
)

//nolint:gochecknoglobals // cobra persistent flags are bound to package-level vars by design
var (
	flagURI  string
	flagJSON bool
)

func main() {
	root := &cobra.Command{
		Use:   "limits-admin",
		Short: "Operator CLI for the limits service",
		Long: `limits-admin wraps the LimitsAdminService Connect endpoints with
tabwriter or JSON output. Use --uri to point at the limits service.

Authentication:
  - In-cluster (production): the CLI uses workload identity via the
    platform's standard auth mechanism. No flags required.
  - Local development: set LIMITS_ADMIN_TOKEN=<bearer-token> in your
    environment. The CLI will attach it as "Authorization: Bearer <token>"
    to every request.`,
		SilenceUsage: true,
	}

	root.PersistentFlags().StringVar(&flagURI, "uri", "https://limits.internal", "Base URL of the limits service")
	root.PersistentFlags().BoolVar(&flagJSON, "json", false, "Emit JSON instead of tabwriter plaintext")

	root.AddCommand(policiesCmd())
	root.AddCommand(reservationsCmd())
	root.AddCommand(approvalsCmd())

	if err := root.Execute(); err != nil {
		os.Exit(1)
	}
}

// newAdminClient constructs a LimitsAdminServiceClient.
//
// Auth strategy (in priority order):
//  1. LIMITS_ADMIN_TOKEN env var: attaches the value as a Bearer token on
//     every request. Intended for local operator development.
//  2. Platform workload identity: uses the platform's connection helper
//     (SPIFFE / OAuth2 as configured in the cluster). No flags required.
func newAdminClient(ctx context.Context) (limitsv1connect.LimitsAdminServiceClient, error) {
	if token := os.Getenv("LIMITS_ADMIN_TOKEN"); token != "" {
		httpClient := &http.Client{
			Transport: &bearerTokenTransport{
				token: token,
				base:  http.DefaultTransport,
			},
		}
		return limitsv1connect.NewLimitsAdminServiceClient(httpClient, flagURI), nil
	}

	// Production path: workload identity via platform auth helper.
	return connection.NewServiceClient(ctx, nil, common.ServiceTarget{
		Endpoint:  flagURI,
		Audiences: []string{"service_limits"},
	}, limitsv1connect.NewLimitsAdminServiceClient)
}

// bearerTokenTransport attaches a static Bearer token to every outbound request.
type bearerTokenTransport struct {
	token string
	base  http.RoundTripper
}

func (t *bearerTokenTransport) RoundTrip(r *http.Request) (*http.Response, error) {
	r2 := r.Clone(r.Context())
	r2.Header.Set("Authorization", "Bearer "+t.token)
	return t.base.RoundTrip(r2)
}
