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
	"time"

	"github.com/pitabwire/frame/v3/data"

	"github.com/antinvestor/service-fintech/apps/funding/service/business"
	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// fixedLoanRequests answers every loan request with the same amount.
type fixedLoanRequests struct {
	amount   int64
	currency string
}

func (f fixedLoanRequests) GetByID(_ context.Context, id string) (*business.LoanRequestInfo, error) {
	info := &business.LoanRequestInfo{Amount: f.amount, Currency: f.currency, Properties: data.JSONMap{}}
	info.ID = id
	return info, nil
}

// noReserve is a platform with nothing in its first-loss reserve, so the
// investor pool funds the whole loan.
type noReserve struct{}

func (noReserve) GroupSavings(context.Context, string, string) (int64, error)    { return 0, nil }
func (noReserve) PlatformReserve(context.Context, string, string) (int64, error) { return 0, nil }

func (e *fundingEnv) allocationBusiness(s *fundingSuite, amount int64) business.FundingAllocationBusiness {
	s.T().Helper()
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Exec(
		`CREATE UNIQUE INDEX IF NOT EXISTS uq_lfclaim_request ON loan_funding_claims (loan_request_id)
		 WHERE deleted_at IS NULL`).Error)
	return business.NewFundingAllocationBusiness(e.ctx, nil,
		repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan),
		repository.NewLoanFundingClaimRepository(e.ctx, e.dbPool, e.workMan),
		repository.NewLossAbsorptionRepository(e.ctx, e.dbPool, e.workMan),
		fixedLoanRequests{amount: amount, currency: "KES"}, e.iaRepo,
		repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan),
		noReserve{}, nil)
}

// leaveClaim writes an allocating claim taken at claimedAt.
func (e *fundingEnv) leaveClaim(s *fundingSuite, loanRequestID string, claimedAt time.Time) {
	s.T().Helper()
	claim := &models.LoanFundingClaim{LoanRequestID: loanRequestID,
		Status: models.LoanFundingClaimAllocating, ClaimedAt: &claimedAt}
	claim.GenID(e.ctx)
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Create(claim).Error)
}

// A call that crashed part way through an allocation leaves its claim
// allocating. Once its lease lapses, the next call gives back what it
// reserved, voids what it wrote and funds the request in full, instead of
// answering every retry with the partial allocation.
func (s *fundingSuite) TestLapsedAllocationIsVoidedAndRedone() {
	e := s.newEnv()
	investor := e.seedInvestor(s, "KES", 50_000)
	fa := e.allocationBusiness(s, 10_000)

	// The crashed call: a funding with one tranche it reserved and one it
	// wrote but never got to reserve.
	e.leaveClaim(s, "lr-crashed", time.Now().Add(-time.Hour))
	lfRepo := repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan)
	ftRepo := repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan)
	partial := &models.LoanFunding{LoanRequestID: "lr-crashed", OwnerID: investor.InvestorID,
		FundingType: int32(models.FundingSourceInvestorGeneral), Amount: 6_000, Currency: "KES",
		State: int32(constants.StateActive)}
	partial.GenID(e.ctx)
	s.Require().NoError(lfRepo.Create(e.ctx, partial))
	for _, t := range []struct {
		amount int64
		state  int32
	}{{4_000, int32(constants.StateActive)}, {2_000, int32(constants.StateJustCreated)}} {
		tranche := &models.FundingTranche{LoanFundingID: partial.GetID(), InvestorAccountID: investor.GetID(),
			TrancheLevel: 2, Amount: t.amount, Currency: "KES", State: t.state}
		tranche.GenID(e.ctx)
		s.Require().NoError(ftRepo.Create(e.ctx, tranche))
	}
	_, err := e.iaRepo.AtomicReserve(e.ctx, investor.GetID(), 4_000)
	s.Require().NoError(err)

	result, err := fa.SourceForRequest(e.ctx, "lr-crashed")
	s.Require().NoError(err)
	s.True(result.FullyFunded)
	s.EqualValues(10_000, result.TotalAllocated)

	acct, err := e.iaRepo.GetByID(e.ctx, investor.GetID())
	s.Require().NoError(err)
	s.EqualValues(10_000, acct.ReservedBalance,
		"the crashed call's 4 000 is given back and only the new allocation stays reserved")

	stale, err := lfRepo.GetByID(e.ctx, partial.GetID())
	s.Require().NoError(err)
	s.Equal(int32(constants.StateInactive), stale.State)

	// Complete now: a retry reads the allocation back and reserves nothing.
	again, err := fa.SourceForRequest(e.ctx, "lr-crashed")
	s.Require().NoError(err)
	s.EqualValues(10_000, again.TotalAllocated)
	acct, err = e.iaRepo.GetByID(e.ctx, investor.GetID())
	s.Require().NoError(err)
	s.EqualValues(10_000, acct.ReservedBalance)
}

// While another call holds a live claim, a concurrent call is told to retry
// rather than handed whatever part of the allocation exists so far.
func (s *fundingSuite) TestLiveAllocationClaimIsRetryable() {
	e := s.newEnv()
	e.seedInvestor(s, "KES", 50_000)
	fa := e.allocationBusiness(s, 10_000)
	e.leaveClaim(s, "lr-live", time.Now())

	result, err := fa.SourceForRequest(e.ctx, "lr-live")
	s.Require().ErrorIs(err, business.ErrAllocationInProgress)
	s.Nil(result)
}
