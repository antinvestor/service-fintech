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
	"errors"
	"testing"

	"buf.build/gen/go/antinvestor/funding/connectrpc/go/v2/funding/v1/fundingv1connect"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
)

type fakeFundingLoss struct {
	fundingv1connect.FundingServiceClient
	calls []*fundingv1.AbsorbLossRequest
	err   error
}

func (f *fakeFundingLoss) AbsorbLoss(
	_ context.Context,
	req *fundingv1.AbsorbLossRequest,
) (*fundingv1.AbsorbLossResponse, error) {
	f.calls = append(f.calls, req)
	if f.err != nil {
		return nil, f.err
	}
	return &fundingv1.AbsorbLossResponse{Absorbed: req.GetAmount()}, nil
}

func TestAbsorbWriteOffLoss_ChargesPrincipalToTheFundingTranches(t *testing.T) {
	la := &loansmodels.LoanAccount{CurrencyCode: "KES", LoanRequestID: "lr-fallback",
		Properties: data.JSONMap{"loan_request_id": "lr-1"}}
	la.ID = "loan-1"
	logger := util.Log(t.Context())

	funding := &fakeFundingLoss{}
	b := &loanAccountBusiness{fundingCli: funding}
	require.NoError(t, b.absorbWriteOffLoss(t.Context(), logger, la, 150_000, "writeoff:loan-1"))
	require.Len(t, funding.calls, 1)
	call := funding.calls[0]
	require.Equal(t, "lr-1", call.GetLoanRequestId())
	require.Equal(t, "KES", call.GetAmount().GetCurrencyCode())
	require.Equal(t, int64(1500), call.GetAmount().GetUnits(), "only principal is absorbed")
	require.Equal(t, "writeoff:loan-1", call.GetLossReference())

	// Nothing owed, nothing absorbed.
	require.NoError(t, b.absorbWriteOffLoss(t.Context(), logger, la, 0, "writeoff:loan-1"))
	require.Len(t, funding.calls, 1)

	// A funding failure blocks the write-off so it is retried whole.
	funding.err = errors.New("funding down")
	require.Error(t, b.absorbWriteOffLoss(t.Context(), logger, la, 1, "writeoff:loan-1"))
	require.ErrorIs(t, (&loanAccountBusiness{}).absorbWriteOffLoss(t.Context(), logger, la, 1, "r"),
		ErrFundingServiceUnavailable)
}
