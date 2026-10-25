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

package business_test

import (
	"context"
	"errors"
	"sync"

	"github.com/antinvestor/service-fintech/apps/funding/service/business"
	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// recordingPoster keeps every posting by reference, the way operations
// converges a repeated reference on one order, and can be told to fail.
type recordingPoster struct {
	mu       sync.Mutex
	fail     bool
	byRef    map[string]business.LedgerPosting
	attempts int
}

func (p *recordingPoster) Post(_ context.Context, posting business.LedgerPosting) error {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.attempts++
	if p.fail {
		return errors.New("ledger unavailable")
	}
	if p.byRef == nil {
		p.byRef = map[string]business.LedgerPosting{}
	}
	p.byRef[posting.Reference] = posting
	return nil
}

// fundLoan writes an investor-funded loan request: the platform reserve
// carries 1 000 and one investor 9 000, reserved on their account.
func (e *fundingEnv) fundLoan(
	s *fundingSuite,
	loanRequestID string,
) (*models.InvestorAccount, []*models.FundingTranche) {
	s.T().Helper()
	investor := e.seedInvestor(s, "KES", 50_000)
	_, err := e.iaRepo.AtomicReserve(e.ctx, investor.GetID(), 9_000)
	s.Require().NoError(err)

	lfRepo := repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan)
	ftRepo := repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan)
	var tranches []*models.FundingTranche
	for _, src := range []struct {
		kind     models.FundingSource
		owner    string
		investor string
		level    int32
		amount   int64
	}{
		{models.FundingSourcePlatformReserve, "platform", "", 1, 1_000},
		{models.FundingSourceInvestorGeneral, investor.InvestorID, investor.GetID(), 3, 9_000},
	} {
		f := &models.LoanFunding{LoanRequestID: loanRequestID, OwnerID: src.owner, FundingType: int32(src.kind),
			Amount: src.amount, Currency: "KES", State: int32(constants.StateActive)}
		f.GenID(e.ctx)
		s.Require().NoError(lfRepo.Create(e.ctx, f))
		t := &models.FundingTranche{LoanFundingID: f.GetID(), InvestorAccountID: src.investor,
			TrancheLevel: src.level, Amount: src.amount, Currency: "KES", State: int32(constants.StateActive)}
		t.GenID(e.ctx)
		s.Require().NoError(ftRepo.Create(e.ctx, t))
		tranches = append(tranches, t)
	}
	return investor, tranches
}

func (e *fundingEnv) repaymentBusiness(poster business.LedgerPoster) business.RepaymentDistributionBusiness {
	return business.NewRepaymentDistributionBusiness(
		repository.NewRepaymentDistributionRepository(e.ctx, e.dbPool, e.workMan),
		repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan),
		repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan),
		poster, 500, 1500)
}

func (s *fundingSuite) TestRepaymentIsSharedOnceAndFinishedLater() {
	e := s.newEnv()
	investor, tranches := e.fundLoan(s, "lr-repay")
	poster := &recordingPoster{fail: true}
	biz := e.repaymentBusiness(poster)
	app := business.RepaymentApplication{
		Reference: "repayment:r1", LoanRequestID: "lr-repay", LoanAccountID: "la-1",
		ProductID: "prod", Currency: "KES", Principal: 2_000, Interest: 1_000,
	}

	// The ledger is down: the shares are recorded and the counters move, but
	// the repayment is not settled.
	first, err := biz.Apply(e.ctx, app)
	s.Require().NoError(err)
	s.False(first.Settled)

	after, err := e.iaRepo.GetByID(e.ctx, investor.GetID())
	s.Require().NoError(err)
	s.EqualValues(9_000-1_800, after.ReservedBalance, "the investor's 90% of the principal stops being lent")
	s.EqualValues(50_000+720, after.AvailableBalance, "net interest: 900 less 5% fee and 15% tax")

	// A retry with the ledger back posts the legs and moves nothing again.
	poster.fail = false
	second, err := biz.Apply(e.ctx, app)
	s.Require().NoError(err)
	s.True(second.Settled)
	again, err := e.iaRepo.GetByID(e.ctx, investor.GetID())
	s.Require().NoError(err)
	s.Equal(after.ReservedBalance, again.ReservedBalance)
	s.Equal(after.AvailableBalance, again.AvailableBalance)

	s.Len(poster.byRef, 2, "investor net interest and withholding tax; the reserve's share stays as income")
	var posted int64
	for _, p := range poster.byRef {
		posted += p.Amount
	}
	s.EqualValues(720+135, posted)

	ftRepo := repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan)
	investorTranche, err := ftRepo.GetByID(e.ctx, tranches[1].GetID())
	s.Require().NoError(err)
	s.EqualValues(1_800, investorTranche.PrincipalRepaid)
	s.EqualValues(900, investorTranche.InterestEarned)

	// Settled: a further call neither moves counters nor posts.
	attempts := poster.attempts
	_, err = biz.Apply(e.ctx, app)
	s.Require().NoError(err)
	s.Equal(attempts, poster.attempts)
}

func (s *fundingSuite) TestLossIsAbsorbedOnceAgainstWhatIsStillLent() {
	e := s.newEnv()
	investor, _ := e.fundLoan(s, "lr-loss")
	// Half the loan was repaid before it defaulted.
	_, err := e.repaymentBusiness(&recordingPoster{}).Apply(e.ctx, business.RepaymentApplication{
		Reference: "repayment:r-loss", LoanRequestID: "lr-loss", LoanAccountID: "la-2",
		ProductID: "prod", Currency: "KES", Principal: 5_000,
	})
	s.Require().NoError(err)

	poster := &recordingPoster{}
	fa := business.NewFundingAllocationBusiness(e.ctx, nil,
		repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan),
		repository.NewLoanFundingClaimRepository(e.ctx, e.dbPool, e.workMan),
		repository.NewLossAbsorptionRepository(e.ctx, e.dbPool, e.workMan),
		nil, e.iaRepo,
		repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan),
		nil, poster)

	loss := business.LossApplication{LoanRequestID: "lr-loss", ProductID: "prod", Amount: 6_000, Currency: "KES"}
	result, err := fa.AbsorbLoss(e.ctx, loss)
	s.Require().NoError(err)
	s.True(result.Settled)
	s.EqualValues(5_000, result.Absorbed, "only the 5 000 still lent out can be lost")
	s.EqualValues(1_000, result.Unrecoverable)

	acct, err := e.iaRepo.GetByID(e.ctx, investor.GetID())
	s.Require().NoError(err)
	s.EqualValues(4_500, acct.TotalLost, "the investor's 90% of the outstanding 5 000")

	again, err := fa.AbsorbLoss(e.ctx, loss)
	s.Require().NoError(err)
	s.Equal(result.Absorbed, again.Absorbed)
	acct2, err := e.iaRepo.GetByID(e.ctx, investor.GetID())
	s.Require().NoError(err)
	s.Equal(acct.TotalLost, acct2.TotalLost, "a repeat absorbs nothing more")

	var toCapital int64
	for _, p := range poster.byRef {
		s.Equal(constants.ProductBadDebtExpenseAccount("prod"), p.Credit)
		if p.Debit == constants.InvestorCapitalAccount(investor.GetID()) {
			toCapital += p.Amount
		}
	}
	s.EqualValues(4_500, toCapital)
}
