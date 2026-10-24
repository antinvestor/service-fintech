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

package consumer

import (
	"context"
	"fmt"
	"sort"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	"github.com/antinvestor/common/v2"
	"github.com/antinvestor/common/v2/connection"
)

// SetupClient constructs a LimitsServiceClient from the provided config and target.
// Returns nil, nil when target.Endpoint is empty so callers can opt out of limits
// integration without special-casing.
func SetupClient(
	ctx context.Context,
	cfg any,
	target common.ServiceTarget,
) (limitsv1connect.LimitsServiceClient, error) {
	if target.Endpoint == "" {
		//nolint:nilnil // documented contract: nil client when the limits service is not configured
		return nil, nil
	}
	cli, err := connection.NewServiceClient(ctx, cfg, target, limitsv1connect.NewLimitsServiceClient)
	if err != nil {
		return nil, fmt.Errorf("limits client: %w", err)
	}
	return cli, nil
}

// RequireForGates refuses to run a service whose transaction-limit gates are
// switched on but which has no working limits client. Without the check a
// misconfigured endpoint silently turns every gate into a pass-through, and
// money moves with no limit applied. Pass the gates as name → enabled.
func RequireForGates(
	cli limitsv1connect.LimitsServiceClient,
	setupErr error,
	gates map[string]bool,
) error {
	var enabled []string
	for name, on := range gates {
		if on {
			enabled = append(enabled, name)
		}
	}
	if len(enabled) == 0 {
		return nil
	}
	sort.Strings(enabled)
	if setupErr != nil {
		return fmt.Errorf("limits gates %v enabled but the limits client failed: %w", enabled, setupErr)
	}
	if cli == nil {
		return fmt.Errorf("limits gates %v enabled but LIMITS_SERVICE_URI is not set", enabled)
	}
	return nil
}
