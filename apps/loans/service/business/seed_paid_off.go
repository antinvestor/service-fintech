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
	"fmt"

	"github.com/antinvestor/service-fintech/gen/go/seed/connectrpc/go/seed/v1/seedv1connect"
	seedv1 "github.com/antinvestor/service-fintech/gen/go/seed/protocolbuffers/go/seed/v1"
)

// seedPaidOffHook tells the seed product a loan was repaid in full. Seed
// ignores loans it did not originate and handles each loan once, so the
// hook may fire for every paid-off loan and on replays.
type seedPaidOffHook struct {
	seed seedv1connect.SeedServiceClient
}

// NewSeedPaidOffHook builds the hook over a seed client.
func NewSeedPaidOffHook(seed seedv1connect.SeedServiceClient) PaidOffHook {
	return &seedPaidOffHook{seed: seed}
}

func (h *seedPaidOffHook) HandlePaidOff(ctx context.Context, loanAccountID string, totalRepaid int64) error {
	if _, err := h.seed.LoanPaidOffNotify(ctx, &seedv1.LoanPaidOffRequest{
		LoanAccountId: loanAccountID,
		TotalRepaid:   totalRepaid,
	}); err != nil {
		return fmt.Errorf("notify seed of paid-off loan %s: %w", loanAccountID, err)
	}
	return nil
}
