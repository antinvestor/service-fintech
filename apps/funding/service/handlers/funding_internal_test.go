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

package handlers

import (
	"context"
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	"connectrpc.com/connect/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/require"
)

// Operators hold fund_manage, but the figures these RPCs take move investor
// balances: only the platform's own services may call them.
func TestFundMovementsRefuseAPerson(t *testing.T) {
	s := &FundingServer{}
	operator := (&security.AuthenticationClaims{
		Roles: []string{"operator"}, RegisteredClaims: jwt.RegisteredClaims{Subject: "staff-1"},
	}).ClaimsToContext(context.Background())
	money := &commonv1.Money{CurrencyCode: "KES", Units: 100}

	_, err := s.LoanRepaymentApply(operator, &fundingv1.LoanRepaymentApplyRequest{
		LoanRequestId: "lr", LoanAccountId: "la", ProductId: "prod", RepaymentReference: "repayment:x",
		Principal: money, Interest: money,
	})
	require.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))

	_, err = s.AbsorbLoss(operator, &fundingv1.AbsorbLossRequest{LoanRequestId: "lr", Amount: money, ProductId: "prod"})
	require.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))

	internal := (&security.AuthenticationClaims{
		Roles: []string{security.ConstantSystemInternalRole}, RegisteredClaims: jwt.RegisteredClaims{Subject: "loans"},
	}).ClaimsToContext(context.Background())
	_, err = s.AbsorbLoss(internal, &fundingv1.AbsorbLossRequest{LoanRequestId: "lr", Amount: money})
	require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), "a loss must name its product")
}
