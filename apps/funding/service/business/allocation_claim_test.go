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
	return e.allocationBusinessWithClaims(
		s,
		amount,
		repository.NewLoanFundingClaimRepository(e.ctx, e.dbPool, e.workMan),
	)
}

func (e *fundingEnv) allocationBusinessWithClaims(
	s *fundingSuite,
	amount int64,
	claims repository.LoanFundingClaimRepository,
) business.FundingAllocationBusiness {
	s.T().Helper()
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Exec(
		`CREATE UNIQUE INDEX IF NOT EXISTS uq_lfclaim_request ON loan_funding_claims (loan_request_id)
		 WHERE deleted_at IS NULL`).Error)
	return business.NewFundingAllocationBusiness(e.ctx, nil,
		repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan),
		claims,
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

// completeFails is a claim store whose Complete fails, or reports the
// lease lost, after the allocation was reserved.
type completeFails struct {
	repository.LoanFundingClaimRepository
	err  error
	lost bool
}

func (c completeFails) Complete(ctx context.Context, id string, lease time.Time) (bool, error) {
	if c.err != nil {
		return false, c.err
	}
	if c.lost {
		return false, nil
	}
	return c.LoanFundingClaimRepository.Complete(ctx, id, lease)
}

// A fully reserved allocation whose claim cannot be completed gives the
// capital back and drops the claim at once, rather than leaving it reserved
// for a takeover that may never come.
func (s *fundingSuite) TestAllocationThatCannotCompleteGivesCapitalBack() {
	for name, claims := range map[string]completeFails{
		"complete fails": {err: errors.New("connection reset")},
		"lease lost":     {lost: true},
	} {
		s.Run(name, func() {
			e := s.newEnv()
			investor := e.seedInvestor(s, "KES", 50_000)
			claims.LoanFundingClaimRepository = repository.NewLoanFundingClaimRepository(e.ctx, e.dbPool, e.workMan)
			fa := e.allocationBusinessWithClaims(s, 10_000, claims)

			_, err := fa.SourceForRequest(e.ctx, "lr-incomplete")
			s.Require().Error(err)

			acct, err := e.iaRepo.GetByID(e.ctx, investor.GetID())
			s.Require().NoError(err)
			s.Zero(acct.ReservedBalance, "nothing stays reserved for an allocation that did not complete")

			var active int64
			s.Require().NoError(e.dbPool.DB(e.ctx, false).Raw(
				`SELECT count(*) FROM funding_tranches WHERE state = ?`, int32(constants.StateActive)).
				Scan(&active).Error)
			s.Zero(active)
		})
	}
}

// Voiding a funding gives back its reservations in the same transaction:
// when one cannot be given back, nothing changes, rather than the funding
// being voided with capital still reserved.
func (s *fundingSuite) TestVoidAndReleaseIsAllOrNothing() {
	e := s.newEnv()
	investor := e.seedInvestor(s, "KES", 50_000)
	lfRepo := repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan)
	ftRepo := repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan)
	funding := &models.LoanFunding{LoanRequestID: "lr-void", Amount: 4_000, Currency: "KES",
		State: int32(constants.StateActive)}
	funding.GenID(e.ctx)
	s.Require().NoError(lfRepo.Create(e.ctx, funding))
	tranche := &models.FundingTranche{LoanFundingID: funding.GetID(), InvestorAccountID: investor.GetID(),
		Amount: 4_000, Currency: "KES", State: int32(constants.StateJustCreated)}
	tranche.GenID(e.ctx)
	s.Require().NoError(ftRepo.Create(e.ctx, tranche))

	// Recorded as reserved without the account holding it.
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Exec(
		`UPDATE funding_tranches SET state = ? WHERE id = ?`, int32(constants.StateActive), tranche.GetID()).Error)
	_, err := lfRepo.VoidAndRelease(e.ctx, funding.GetID())
	s.Require().ErrorIs(err, repository.ErrReservationMissing)
	stored, err := lfRepo.GetByID(e.ctx, funding.GetID())
	s.Require().NoError(err)
	s.Equal(int32(constants.StateActive), stored.State, "the void rolled back with the failed release")

	// Reserved and activated together, it is voided and given back once.
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Exec(
		`UPDATE funding_tranches SET state = ? WHERE id = ?`, int32(constants.StateJustCreated), tranche.GetID()).Error)
	s.Require().NoError(ftRepo.ReserveAndActivate(e.ctx, tranche))
	won, err := lfRepo.VoidAndRelease(e.ctx, funding.GetID())
	s.Require().NoError(err)
	s.True(won)
	again, err := lfRepo.VoidAndRelease(e.ctx, funding.GetID())
	s.Require().NoError(err)
	s.False(again)
	acct, err := e.iaRepo.GetByID(e.ctx, investor.GetID())
	s.Require().NoError(err)
	s.Zero(acct.ReservedBalance)
}

// A tranche the investor cannot cover is neither reserved nor activated.
func (s *fundingSuite) TestReserveAndActivateChangesNothingWhenShort() {
	e := s.newEnv()
	investor := e.seedInvestor(s, "KES", 1_000)
	ftRepo := repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan)
	tranche := &models.FundingTranche{LoanFundingID: "lf-short", InvestorAccountID: investor.GetID(),
		Amount: 4_000, Currency: "KES", State: int32(constants.StateJustCreated)}
	tranche.GenID(e.ctx)
	s.Require().NoError(ftRepo.Create(e.ctx, tranche))

	s.Require().ErrorIs(ftRepo.ReserveAndActivate(e.ctx, tranche), repository.ErrInvestorInsufficientFunds)
	stored, err := ftRepo.GetByID(e.ctx, tranche.GetID())
	s.Require().NoError(err)
	s.Equal(int32(constants.StateJustCreated), stored.State)
}
