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

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

type commissionProducts struct {
	repository.LoanProductRepository
	rate int64
}

func (p commissionProducts) GetByID(_ context.Context, id string) (*loansmodels.LoanProduct, error) {
	lp := &loansmodels.LoanProduct{AgentCommissionPercent: p.rate}
	lp.ID = id
	return lp, nil
}

type fixedTeam string

func (t fixedTeam) ServingTeam(context.Context, string) (string, error) { return string(t), nil }

type failingTeams struct{ err error }

func (t failingTeams) ServingTeam(context.Context, string) (string, error) { return "", t.err }

func commissionLoan() *loansmodels.LoanAccount {
	la := &loansmodels.LoanAccount{ClientID: "client-1", ProductID: "prod-1"}
	la.ID = "loan-1"
	return la
}

// The serving team earns the product's share of the interest a repayment
// paid, once per repayment, as the product's cost.
func TestCommissionIsTheTeamsShareOfRepaidInterest(t *testing.T) {
	ops := &recordingOperationsClient{}
	c := NewAgentCommission(commissionProducts{rate: 1_000}, fixedTeam("team-7"), ops)
	r := &loansmodels.Repayment{CurrencyCode: "KES", InterestApplied: 50_000, PrincipalApplied: 100_000}
	r.ID = "rep-1"

	require.NoError(t, c.Post(context.Background(), commissionLoan(), r))
	orders := ops.snapshot()
	require.Len(t, orders, 1)
	o := orders[0]
	assert.Equal(t, "commission:rep-1", o.GetReference())
	assert.Equal(t, constants.ProductCommissionExpenseAccount("prod-1"), o.GetDebitAccountRef())
	assert.Equal(t, constants.TeamCommissionPayableAccount("team-7"), o.GetCreditAccountRef())
	assert.Equal(t, int64(50), o.GetAmount().GetUnits(), "10% of KES 500 interest")
}

func TestNoCommissionWithoutARateATeamInterestOrOnARecovery(t *testing.T) {
	interest := func() *loansmodels.Repayment {
		r := &loansmodels.Repayment{CurrencyCode: "KES", InterestApplied: 50_000}
		r.ID = "rep-2"
		return r
	}
	recovery := interest()
	recovery.Properties = data.JSONMap{repaymentRecoveryKey: true}
	noInterest := interest()
	noInterest.InterestApplied = 0

	for name, tc := range map[string]struct {
		c *AgentCommission
		r *loansmodels.Repayment
	}{
		"no rate":     {NewAgentCommission(commissionProducts{}, fixedTeam("team-7"), nil), interest()},
		"no team":     {NewAgentCommission(commissionProducts{rate: 1_000}, fixedTeam(""), nil), interest()},
		"no interest": {NewAgentCommission(commissionProducts{rate: 1_000}, fixedTeam("team-7"), nil), noInterest},
		"a recovery":  {NewAgentCommission(commissionProducts{rate: 1_000}, fixedTeam("team-7"), nil), recovery},
	} {
		require.NoError(t, tc.c.Post(context.Background(), commissionLoan(), tc.r), name)
	}
}

// A commission that can never post is dropped so it does not hold back the
// funders' share; a transient failure is kept for the settlement to retry.
func TestCommissionRefusalDoesNotBlockSettlement(t *testing.T) {
	r := &loansmodels.Repayment{CurrencyCode: "KES", InterestApplied: 50_000}
	r.ID = "rep-3"

	refused := NewAgentCommission(commissionProducts{rate: 1_000},
		failingTeams{connect.NewError(connect.CodeNotFound, "no such client")}, nil)
	require.NoError(t, refused.Post(context.Background(), commissionLoan(), r))

	transient := NewAgentCommission(commissionProducts{rate: 1_000},
		failingTeams{connect.NewError(connect.CodeUnavailable, "field is down")}, nil)
	require.Error(t, transient.Post(context.Background(), commissionLoan(), r))
}
