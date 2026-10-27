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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3/security"

	"github.com/antinvestor/service-fintech/apps/funding/service/business"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
)

// ownerOf maps investor ids to the profile each signs in with.
type ownerOf map[string]string

func (o ownerOf) InvestorProfileID(_ context.Context, investorID string) (string, error) {
	return o[investorID], nil
}

func (e *fundingEnv) reads(owners business.InvestorOwnerResolver) *business.InvestorReads {
	return business.NewInvestorReads(e.iaRepo, repository.NewStatementRepository(e.dbPool), owners)
}

// asCaller acts in the test partition as a profile holding the roles.
func (e *fundingEnv) asCaller(profileID string, roles ...string) context.Context {
	return (&security.AuthenticationClaims{
		TenantID:         "tenant-funding",
		PartitionID:      "partition-funding",
		Roles:            roles,
		RegisteredClaims: jwt.RegisteredClaims{Subject: profileID},
	}).ClaimsToContext(e.ctx)
}

// units reads a KES amount in minor units.
func units(m *commonv1.Money) int64 {
	return m.GetUnits()*100 + int64(m.GetNanos())/10_000_000
}

// A statement lists what moved the investor's capital in the period, with
// totals: the deposit, the deployment, the principal and net interest a
// repayment returned, the loss of a write-off and what was recovered.
func (s *fundingSuite) TestStatementReportsEveryCapitalMovement() {
	e := s.newEnv()
	investor, _ := e.fundLoan(s, "lr-stmt")
	from := time.Now().Add(-time.Hour).UTC()

	s.Require().NoError(e.iaBiz.Deposit(e.ctx, investor.GetID(), fundingMoney("KES", 100), "dep-stmt"))
	_, err := e.repaymentBusiness(&recordingPoster{}).Apply(e.ctx, business.RepaymentApplication{
		Reference: "repayment:r-stmt", LoanRequestID: "lr-stmt", LoanAccountID: "la-s",
		ProductID: "prod", Currency: "KES", Principal: 2_000, Interest: 1_000,
	})
	s.Require().NoError(err)

	poster := &recordingPoster{}
	lossRepo := repository.NewLossAbsorptionRepository(e.ctx, e.dbPool, e.workMan)
	ftRepo := repository.NewFundingTrancheRepository(e.ctx, e.dbPool, e.workMan)
	fa := business.NewFundingAllocationBusiness(e.ctx, nil,
		repository.NewLoanFundingRepository(e.ctx, e.dbPool, e.workMan),
		repository.NewLoanFundingClaimRepository(e.ctx, e.dbPool, e.workMan),
		lossRepo, nil, e.iaRepo, ftRepo, nil, poster)
	_, err = fa.AbsorbLoss(e.ctx, business.LossApplication{
		LoanRequestID: "lr-stmt", ProductID: "prod", Amount: 8_000, Currency: "KES"})
	s.Require().NoError(err)
	rc := business.NewLossRecoveryBusiness(lossRepo,
		repository.NewLossRecoveryRepository(e.ctx, e.dbPool, e.workMan), ftRepo, poster)
	_, err = rc.Apply(e.ctx, business.Recovery{LoanRequestID: "lr-stmt", ProductID: "prod",
		Reference: "recovery:r-stmt", Principal: 3_000, Currency: "KES"})
	s.Require().NoError(err)

	staff := e.asCaller("profile-staff", "admin")
	got, err := e.reads(nil).Statement(staff, &fundingv1.InvestorStatementRequest{
		InvestorAccountId: investor.GetID(),
		From:              from.Format(time.RFC3339),
	})
	s.Require().NoError(err)
	s.False(got.Truncated)

	t := got.Totals
	s.Equal(int64(10_000), units(t.GetDeposits()))
	s.Equal(int64(9_000), units(t.GetDeployed()))
	s.Equal(int64(1_800), units(t.GetPrincipalReturned()), "90% of 2 000")
	s.Equal(int64(720), units(t.GetInterestEarned()), "900 gross, less 5% fee and 15% tax")
	s.Equal(int64(45), units(t.GetPlatformFees()))
	s.Equal(int64(135), units(t.GetWithholdingTax()))
	s.Equal(int64(7_200), units(t.GetLosses()), "the investor's 90% of the 8 000 still lent")
	s.Equal(int64(3_000), units(t.GetRecoveries()), "the senior tranche is recovered first")

	kinds := map[fundingv1.InvestorStatementEntryType]int{}
	for _, entry := range got.Entries {
		kinds[entry.GetType()]++
	}
	s.Equal(1, kinds[fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_DEPOSIT])
	s.Equal(1, kinds[fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_DEPLOYMENT])
	s.Equal(1, kinds[fundingv1.InvestorStatementEntryType_INVESTOR_STATEMENT_ENTRY_TYPE_LOSS])
	for i := 1; i < len(got.Entries); i++ {
		s.LessOrEqual(got.Entries[i-1].GetOccurredAt(), got.Entries[i].GetOccurredAt(), "oldest first")
	}

	_, err = e.reads(nil).Statement(staff, &fundingv1.InvestorStatementRequest{
		InvestorAccountId: investor.GetID(),
		From:              from.Add(-400 * 24 * time.Hour).Format(time.RFC3339),
	})
	s.Require().ErrorIs(err, business.ErrStatementPeriodInvalid)
}

// An investor reads only their own account; staff read any.
func (s *fundingSuite) TestInvestorReadsOnlyTheirOwnAccount() {
	e := s.newEnv()
	account := e.seedInvestor(s, "KES", 0)
	reads := e.reads(ownerOf{account.InvestorID: "profile-owner"})
	period := &fundingv1.InvestorStatementRequest{
		InvestorAccountId: account.GetID(),
		From:              time.Now().Add(-time.Hour).UTC().Format(time.RFC3339),
	}

	_, err := reads.Statement(e.asCaller("profile-owner", "member"), period)
	s.Require().NoError(err)

	_, err = reads.Statement(e.asCaller("profile-other", "member"), period)
	s.Require().ErrorIs(err, business.ErrInvestorAccountNotVisible)
	s.Require().ErrorIs(reads.CheckInvestor(e.asCaller("profile-other", "member"), account.InvestorID),
		business.ErrInvestorAccountNotVisible)

	s.Require().ErrorIs(reads.CheckSearch(e.asCaller("profile-owner", "member"), ""),
		business.ErrInvestorSearchNeedsOwnInvestor, "an investor may not list every account")
	s.Require().NoError(reads.CheckSearch(e.asCaller("profile-owner", "member"), account.InvestorID))

	_, err = reads.Statement(e.asCaller("profile-staff", "operator"), period)
	s.Require().NoError(err, "staff read any account")
}
