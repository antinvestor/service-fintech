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
	"math"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

func source(
	t *testing.T,
	sourceType models.FundingSource,
	owner, investor string,
	amount, repaid, lost int64,
) trancheSource {
	t.Helper()
	f := &models.LoanFunding{OwnerID: owner, FundingType: int32(sourceType)}
	f.GenID(context.Background())
	tr := &models.FundingTranche{LoanFundingID: f.GetID(), InvestorAccountID: investor, Amount: amount,
		PrincipalRepaid: repaid, LossAbsorbed: lost, Currency: "KES"}
	tr.GenID(context.Background())
	return trancheSource{tranche: tr, funding: f}
}

func TestRepaymentSharesAddUpAndCarryFeeAndTaxOnInvestorsOnly(t *testing.T) {
	sources := []trancheSource{
		source(t, models.FundingSourcePlatformReserve, "platform", "", 10_000, 0, 0),
		source(t, models.FundingSourceInvestorGeneral, "inv-1", "acct-1", 60_000, 0, 0),
		source(t, models.FundingSourceInvestorGeneral, "inv-2", "acct-2", 30_001, 0, 0),
	}
	shares := computeRepaymentShares(sources, 33_333, 10_007, "KES", 500, 1500)
	require.Len(t, shares, 3)

	var principal, interest int64
	for _, s := range shares {
		principal += s.Principal
		interest += s.InterestGross
		assert.Equal(t, s.InterestGross, s.InterestNet+s.PlatformFee+s.WithholdingTax,
			"a share's legs always add up to the share")
	}
	assert.EqualValues(t, 33_333, principal, "the last tranche takes the rounding remainder")
	assert.EqualValues(t, 10_007, interest)

	assert.Zero(t, shares[0].PlatformFee, "the platform reserve pays no fee to itself")
	assert.Zero(t, shares[0].WithholdingTax)
	assert.Positive(t, shares[1].PlatformFee)
	assert.Positive(t, shares[1].WithholdingTax)
}

func TestProportionOfDoesNotOverflow(t *testing.T) {
	got := proportionOf(math.MaxInt64/2, math.MaxInt64/2, math.MaxInt64-1)
	assert.Positive(t, got)
	assert.Equal(t, int64(0), proportionOf(100, 0, 10))
	assert.Equal(t, int64(50), proportionOf(100, 1, 2))
}

func TestRepaymentPostingsMoveInterestOutOfIncomeOnly(t *testing.T) {
	dist := &models.RepaymentDistribution{LoanRequestID: "lr", ProductID: "prod", Currency: "KES"}
	dist.GenID(context.Background())
	shares := []RepaymentShare{
		{TrancheID: "t1", SourceType: int32(models.FundingSourceInvestorGeneral), InvestorAccountID: "acct-1",
			Principal: 1000, InterestGross: 100, PlatformFee: 5, WithholdingTax: 15, InterestNet: 80},
		{TrancheID: "t2", SourceType: int32(models.FundingSourceGroupSavings), SourceID: "grp",
			Principal: 500, InterestGross: 50, InterestNet: 50},
		{TrancheID: "t3", SourceType: int32(models.FundingSourcePlatformReserve),
			Principal: 200, InterestGross: 20, InterestNet: 20},
	}
	postings := repaymentPostings(dist, shares)
	require.Len(t, postings, 3, "investor net, investor tax, group interest; principal and the reserve post nothing")
	for _, p := range postings {
		assert.Equal(t, constants.PlatformIncomeAccount("prod"), p.Debit)
	}
	assert.Equal(t, constants.InvestorCapitalAccount("acct-1"), postings[0].Credit)
	assert.EqualValues(t, 80, postings[0].Amount)
	assert.Equal(t, constants.PlatformWithholdingTaxPayableAccount("prod"), postings[1].Credit)
	assert.EqualValues(t, 15, postings[1].Amount)
	assert.Equal(t, constants.GroupInterestIncomeAccount("grp"), postings[2].Credit)
	assert.NotEqual(t, postings[0].Reference, postings[1].Reference)
}

func TestLossSharesOnlyTakeWhatIsStillLentOut(t *testing.T) {
	sources := []trancheSource{
		source(t, models.FundingSourcePlatformReserve, "platform", "", 1_000, 400, 0),  // 600 exposed
		source(t, models.FundingSourceInvestorGeneral, "inv", "acct", 9_000, 3_000, 0), // 6 000 exposed
	}
	shares, remaining := computeLossShares(sources, 10_000)
	require.Len(t, shares, 2)
	assert.EqualValues(t, 600, shares[0].Principal, "first loss takes its exposure first")
	assert.EqualValues(t, 6_000, shares[1].Principal)
	assert.EqualValues(t, 3_400, remaining, "what no tranche still carries is unrecoverable")
}

func TestSharesRoundTripThroughStorage(t *testing.T) {
	in := []RepaymentShare{{TrancheID: "t", SourceID: "s", SourceType: 4, Principal: 7, InterestNet: 3}}
	out, err := decodeShares(encodeShares(in))
	require.NoError(t, err)
	assert.Equal(t, in, out)
}
