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

	"github.com/antinvestor/service-fintech/apps/funding/service/business"
	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
)

// A reservation never takes an investor's outstanding capital past their
// exposure limit, whichever path reserves it.
func (s *fundingSuite) TestReservationsRespectMaxExposure() {
	e := s.newEnv()
	investor := e.seedInvestor(s, "KES", 50_000)
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Exec(
		`UPDATE investor_accounts SET max_exposure = 5000 WHERE id = ?`, investor.GetID()).Error)

	_, err := e.iaRepo.AtomicReserve(e.ctx, investor.GetID(), 6_000)
	s.Require().ErrorIs(err, repository.ErrInvestorExposureExceeded)

	_, tranche := e.fundingWithTranche(s, "lr-exposure", investor, 6_000)
	s.Require().ErrorIs(repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan).
		ReserveAndActivate(e.ctx, tranche), repository.ErrInvestorExposureExceeded)

	_, err = e.iaRepo.AtomicReserve(e.ctx, investor.GetID(), 5_000)
	s.Require().NoError(err, "up to the limit is fine")
}

// An investor whose capital is all reserved is not offered as a source.
func (s *fundingSuite) TestFullyReservedInvestorIsNotEligible() {
	e := s.newEnv()
	full := e.seedInvestor(s, "KES", 10_000)
	_, err := e.iaRepo.AtomicReserve(e.ctx, full.GetID(), 10_000)
	s.Require().NoError(err)
	free := e.seedInvestor(s, "KES", 10_000)

	eligible, err := e.iaRepo.GetEligibleForLoan(e.ctx, "KES", 0, 1_000, "", "")
	s.Require().NoError(err)
	s.Require().Len(eligible, 1)
	s.Equal(free.GetID(), eligible[0].GetID())
}

// drainingTranches lets another loan take the first reserved investor's
// whole capital just before this allocation reserves it.
type drainingTranches struct {
	repository.FundingTrancheRepository
	ia      repository.InvestorAccountRepository
	drained string
}

func (d *drainingTranches) ReserveAndActivate(ctx context.Context, t *models.FundingTranche) error {
	if d.drained == "" {
		d.drained = t.InvestorAccountID
		acct, err := d.ia.GetByID(ctx, t.InvestorAccountID)
		if err != nil {
			return err
		}
		if _, err = d.ia.AtomicReserve(ctx, acct.GetID(), acct.AvailableBalance-acct.ReservedBalance); err != nil {
			return err
		}
	}
	return d.FundingTrancheRepository.ReserveAndActivate(ctx, t)
}

// A reservation that loses the race for an investor's capital falls through
// to the next investor rather than failing the loan.
func (s *fundingSuite) TestReserveConflictFallsThroughToTheNextInvestor() {
	e := s.newEnv()
	first := e.seedInvestor(s, "KES", 50_000)
	second := e.seedInvestor(s, "KES", 50_000)
	tranches := &drainingTranches{
		FundingTrancheRepository: repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan),
		ia:                       e.iaRepo,
	}
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Exec(
		`CREATE UNIQUE INDEX IF NOT EXISTS uq_lfclaim_request ON loan_funding_claims (loan_request_id)
		 WHERE deleted_at IS NULL`).Error)
	fa := business.NewFundingAllocationBusiness(e.ctx, nil,
		repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan),
		repository.NewLoanFundingClaimRepository(e.ctx, e.dbPool, e.workMan),
		repository.NewLossAbsorptionRepository(e.ctx, e.dbPool, e.workMan),
		fixedLoanRequests{amount: 10_000, currency: "KES"}, e.iaRepo, tranches, noReserve{}, nil)

	result, err := fa.SourceForRequest(e.ctx, "lr-race")
	s.Require().NoError(err)
	s.True(result.FullyFunded)

	other := second.GetID()
	if tranches.drained == second.GetID() {
		other = first.GetID()
	}
	drained, err := e.iaRepo.GetByID(e.ctx, tranches.drained)
	s.Require().NoError(err)
	s.EqualValues(50_000, drained.ReservedBalance, "only the other loan's reservation")
	funder, err := e.iaRepo.GetByID(e.ctx, other)
	s.Require().NoError(err)
	s.EqualValues(10_000, funder.ReservedBalance, "the loan fell through to the investor with capital")
}
