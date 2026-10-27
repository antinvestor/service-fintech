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
	return e.allocationBusinessWith(s, amount, claims, repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan))
}

func (e *fundingEnv) allocationBusinessWith(
	s *fundingSuite,
	amount int64,
	claims repository.LoanFundingClaimRepository,
	fundings repository.LoanFundingRepository,
) business.FundingAllocationBusiness {
	s.T().Helper()
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Exec(
		`CREATE UNIQUE INDEX IF NOT EXISTS uq_lfclaim_request ON loan_funding_claims (loan_request_id)
		 WHERE deleted_at IS NULL`).Error)
	return business.NewFundingAllocationBusiness(e.ctx, nil,
		fundings,
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
	err    error
	lost   bool
	landed bool
}

func (c completeFails) Complete(ctx context.Context, id string, lease time.Time) (bool, error) {
	if c.landed {
		// The write lands but the caller never hears so.
		_, _ = c.LoanFundingClaimRepository.Complete(ctx, id, lease)
		return false, errors.New("connection reset after commit")
	}
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

// A completion that landed although the caller heard an error is read back
// and kept: the allocation is complete and nothing is given back.
func (s *fundingSuite) TestCompletionThatLandedDespiteAnErrorIsKept() {
	e := s.newEnv()
	investor := e.seedInvestor(s, "KES", 50_000)
	claims := completeFails{landed: true,
		LoanFundingClaimRepository: repository.NewLoanFundingClaimRepository(e.ctx, e.dbPool, e.workMan)}
	fa := e.allocationBusinessWithClaims(s, 10_000, claims)

	result, err := fa.SourceForRequest(e.ctx, "lr-landed")
	s.Require().NoError(err)
	s.True(result.FullyFunded)
	acct, err := e.iaRepo.GetByID(e.ctx, investor.GetID())
	s.Require().NoError(err)
	s.EqualValues(10_000, acct.ReservedBalance, "a completed allocation keeps its capital")

	// ReleaseHeld never drops a completed claim.
	var claim models.LoanFundingClaim
	s.Require().NoError(e.dbPool.DB(e.ctx, false).First(&claim, "loan_request_id = ?", "lr-landed").Error)
	s.Equal(models.LoanFundingClaimComplete, claim.Status)
	released, err := claims.ReleaseHeld(e.ctx, "lr-landed", *claim.ClaimedAt)
	s.Require().NoError(err)
	s.False(released)
}

// A takeover whose predecessor left a tranche the investor account no
// longer holds the reservation for still funds the loan: that tranche is
// voided and flagged for reconciliation instead of failing every retry.
func (s *fundingSuite) TestTakeoverIsNotBlockedByAnUnreleasableTranche() {
	e := s.newEnv()
	investor := e.seedInvestor(s, "KES", 50_000)
	fa := e.allocationBusiness(s, 10_000)
	e.leaveClaim(s, "lr-stuck", time.Now().Add(-time.Hour))
	funding, bad := e.fundingWithTranche(s, "lr-stuck", investor, 4_000)
	e.markActive(s, bad) // recorded as reserved, never held by the account

	result, err := fa.SourceForRequest(e.ctx, "lr-stuck")
	s.Require().NoError(err)
	s.True(result.FullyFunded)

	stored := e.tranche(s, bad.GetID())
	s.Equal(int32(constants.StateInactive), stored.State)
	s.Equal(repository.TrancheReconcileReservationMissing, stored.Properties["reconcile"])
	lf, err := repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan).GetByID(e.ctx, funding.GetID())
	s.Require().NoError(err)
	s.Equal(int32(constants.StateInactive), lf.State)
}

func (e *fundingEnv) fundingWithTranche(
	s *fundingSuite,
	loanRequestID string,
	investor *models.InvestorAccount,
	amount int64,
) (*models.LoanFunding, *models.FundingTranche) {
	s.T().Helper()
	funding := &models.LoanFunding{LoanRequestID: loanRequestID, Amount: amount, Currency: "KES",
		State: int32(constants.StateActive)}
	funding.GenID(e.ctx)
	s.Require().NoError(repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan).Create(e.ctx, funding))
	return funding, e.pendingTranche(s, funding, investor, amount)
}

func (e *fundingEnv) pendingTranche(
	s *fundingSuite,
	funding *models.LoanFunding,
	investor *models.InvestorAccount,
	amount int64,
) *models.FundingTranche {
	s.T().Helper()
	tranche := &models.FundingTranche{LoanFundingID: funding.GetID(), InvestorAccountID: investor.GetID(),
		Amount: amount, Currency: "KES", State: int32(constants.StateJustCreated)}
	tranche.GenID(e.ctx)
	s.Require().NoError(repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan).Create(e.ctx, tranche))
	return tranche
}

func (e *fundingEnv) markActive(s *fundingSuite, t *models.FundingTranche) {
	s.T().Helper()
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Exec(
		`UPDATE funding_tranches SET state = ? WHERE id = ?`, int32(constants.StateActive), t.GetID()).Error)
}

func (e *fundingEnv) tranche(s *fundingSuite, id string) *models.FundingTranche {
	s.T().Helper()
	t, err := repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan).GetByID(e.ctx, id)
	s.Require().NoError(err)
	return t
}

// Voiding a funding gives back its reservations in the same transaction. A
// tranche whose reservation the account no longer holds is voided and
// flagged, not given back, and does not stop the others.
func (s *fundingSuite) TestVoidAndReleaseIsolatesAnUnreleasableTranche() {
	e := s.newEnv()
	investor := e.seedInvestor(s, "KES", 50_000)
	lfRepo := repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan)
	ftRepo := repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan)
	funding, bad := e.fundingWithTranche(s, "lr-void", investor, 4_000)
	good := e.pendingTranche(s, funding, investor, 3_000)
	pending := e.pendingTranche(s, funding, investor, 1_000)
	e.markActive(s, bad)
	s.Require().NoError(ftRepo.ReserveAndActivate(e.ctx, good))

	won, unreleased, err := lfRepo.VoidAndRelease(e.ctx, funding.GetID())
	s.Require().NoError(err)
	s.True(won)
	s.Equal([]string{bad.GetID()}, unreleased)

	acct, err := e.iaRepo.GetByID(e.ctx, investor.GetID())
	s.Require().NoError(err)
	s.Zero(acct.ReservedBalance, "the reserved tranche is given back; the others held nothing")
	for _, id := range []string{bad.GetID(), good.GetID(), pending.GetID()} {
		s.Equal(int32(constants.StateInactive), e.tranche(s, id).State)
	}
	s.Equal(repository.TrancheReconcileReservationMissing, e.tranche(s, bad.GetID()).Properties["reconcile"])
	s.Nil(e.tranche(s, good.GetID()).Properties["reconcile"])

	again, _, err := lfRepo.VoidAndRelease(e.ctx, funding.GetID())
	s.Require().NoError(err)
	s.False(again, "voided once")
}

// A tranche whose funding was voided first reserves nothing: the reservation
// and the void serialise on the funding row.
func (s *fundingSuite) TestReserveAfterVoidReservesNothing() {
	e := s.newEnv()
	investor := e.seedInvestor(s, "KES", 50_000)
	funding, tranche := e.fundingWithTranche(s, "lr-race", investor, 4_000)
	_, _, err := repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan).VoidAndRelease(e.ctx, funding.GetID())
	s.Require().NoError(err)

	s.Require().Error(repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan).
		ReserveAndActivate(e.ctx, tranche))
	acct, err := e.iaRepo.GetByID(e.ctx, investor.GetID())
	s.Require().NoError(err)
	s.Zero(acct.ReservedBalance)
}

// A tranche the investor cannot cover is neither reserved nor activated.
func (s *fundingSuite) TestReserveAndActivateChangesNothingWhenShort() {
	e := s.newEnv()
	investor := e.seedInvestor(s, "KES", 1_000)
	_, tranche := e.fundingWithTranche(s, "lr-short", investor, 4_000)
	ftRepo := repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan)

	s.Require().ErrorIs(ftRepo.ReserveAndActivate(e.ctx, tranche), repository.ErrInvestorInsufficientFunds)
	s.Equal(int32(constants.StateJustCreated), e.tranche(s, tranche.GetID()).State)
}

// voidFails is a funding store whose voids fail.
type voidFails struct {
	repository.LoanFundingRepository
}

func (voidFails) VoidAndRelease(context.Context, string) (bool, []string, error) {
	return false, nil, errors.New("connection reset")
}

// An allocation being given back keeps its claim until the void is done: if
// the void fails the claim stays (abandoning), and once its lease lapses the
// next call voids what is left before allocating, so the capital is never
// committed twice.
func (s *fundingSuite) TestFailedAbandonKeepsTheClaimUntilVoided() {
	e := s.newEnv()
	investor := e.seedInvestor(s, "KES", 50_000)
	claims := completeFails{err: errors.New("connection reset"),
		LoanFundingClaimRepository: repository.NewLoanFundingClaimRepository(e.ctx, e.dbPool, e.workMan)}
	failing := e.allocationBusinessWith(s, 10_000, claims,
		voidFails{repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan)})

	_, err := failing.SourceForRequest(e.ctx, "lr-abandon")
	s.Require().Error(err)

	var claim models.LoanFundingClaim
	s.Require().NoError(e.dbPool.DB(e.ctx, false).First(&claim, "loan_request_id = ?", "lr-abandon").Error)
	s.Equal(models.LoanFundingClaimAbandoning, claim.Status, "the claim outlives a void that failed")
	acct, err := e.iaRepo.GetByID(e.ctx, investor.GetID())
	s.Require().NoError(err)
	s.EqualValues(10_000, acct.ReservedBalance)

	// While its lease is live, nobody allocates on top of it.
	fa := e.allocationBusiness(s, 10_000)
	_, err = fa.SourceForRequest(e.ctx, "lr-abandon")
	s.Require().ErrorIs(err, business.ErrAllocationInProgress)

	// Once it lapses, the next call voids the leftover and funds afresh.
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Exec(
		`UPDATE loan_funding_claims SET claimed_at = now() - interval '1 hour' WHERE loan_request_id = ?`,
		"lr-abandon").Error)
	result, err := fa.SourceForRequest(e.ctx, "lr-abandon")
	s.Require().NoError(err)
	s.True(result.FullyFunded)
	acct, err = e.iaRepo.GetByID(e.ctx, investor.GetID())
	s.Require().NoError(err)
	s.EqualValues(10_000, acct.ReservedBalance, "the leftover was given back, not committed twice")
}

// A fresh claim on a request that still has active fundings (left by a call
// that died after dropping its claim) voids them before allocating.
func (s *fundingSuite) TestFreshClaimVoidsLeftoverFundings() {
	e := s.newEnv()
	investor := e.seedInvestor(s, "KES", 50_000)
	_, leftover := e.fundingWithTranche(s, "lr-leftover", investor, 4_000)
	s.Require().NoError(repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan).
		ReserveAndActivate(e.ctx, leftover))

	result, err := e.allocationBusiness(s, 10_000).SourceForRequest(e.ctx, "lr-leftover")
	s.Require().NoError(err)
	s.EqualValues(10_000, result.TotalAllocated)
	acct, err := e.iaRepo.GetByID(e.ctx, investor.GetID())
	s.Require().NoError(err)
	s.EqualValues(10_000, acct.ReservedBalance)
}
