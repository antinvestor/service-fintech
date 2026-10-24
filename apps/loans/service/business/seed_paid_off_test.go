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

	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/gen/go/seed/connectrpc/go/seed/v1/seedv1connect"
	seedv1 "github.com/antinvestor/service-fintech/gen/go/seed/protocolbuffers/go/seed/v1"
)

type recordingSeed struct {
	seedv1connect.SeedServiceClient
	got []*seedv1.LoanPaidOffRequest
}

func (r *recordingSeed) LoanPaidOffNotify(
	_ context.Context,
	req *seedv1.LoanPaidOffRequest,
) (*seedv1.JSONResponse, error) {
	r.got = append(r.got, req)
	return &seedv1.JSONResponse{}, nil
}

func TestSeedPaidOffHook_NotifiesSeed(t *testing.T) {
	seed := &recordingSeed{}
	require.NoError(t, NewSeedPaidOffHook(seed).HandlePaidOff(t.Context(), "loan-1", 125_000))
	require.Len(t, seed.got, 1)
	require.Equal(t, "loan-1", seed.got[0].GetLoanAccountId())
	require.Equal(t, int64(125_000), seed.got[0].GetTotalRepaid())
}
