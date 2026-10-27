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

package repository_test

import (
	"sync"
	"sync/atomic"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

func accrual(team, reference string, amount int64) *models.TeamCommissionMovement {
	return &models.TeamCommissionMovement{
		TeamID: team, CurrencyCode: "KES", Kind: int32(models.TeamCommissionAccrual),
		Amount: amount, Reference: reference,
		Status: int32(loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_COMPLETED),
	}
}

func payoutClaim(team, key string, amount int64) *models.TeamCommissionMovement {
	return &models.TeamCommissionMovement{
		TeamID: team, CurrencyCode: "KES", Kind: int32(models.TeamCommissionPayout),
		Amount: amount, Reference: "team-payout:" + key, MemberID: "member-1",
		Status: int32(loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_PENDING),
	}
}

// An accrual is counted once however often its settlement is retried.
func (s *migrateSuite) TestCommissionAccruesOncePerReference() {
	e := s.newEnv()
	repo := repository.NewTeamCommissionRepository(e.dbPool)

	first, err := repo.Accrue(e.ctx, accrual("team-a", "commission:rep-1", 500))
	s.Require().NoError(err)
	s.True(first)
	again, err := repo.Accrue(e.ctx, accrual("team-a", "commission:rep-1", 500))
	s.Require().NoError(err)
	s.False(again, "a retried accrual is not counted again")
	_, err = repo.Accrue(e.ctx, accrual("team-a", "commission:rep-2", 300))
	s.Require().NoError(err)

	rows, err := repo.Search(e.ctx, "team-a", 0, 10)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	s.Equal(int64(800), rows[0].Accrued)
}

// Concurrent payouts never take more than the team has, and a refused one
// gives its amount back.
func (s *migrateSuite) TestCommissionPayoutsNeverOverdraw() {
	e := s.newEnv()
	repo := repository.NewTeamCommissionRepository(e.dbPool)
	_, err := repo.Accrue(e.ctx, accrual("team-b", "commission:rep-9", 1_000))
	s.Require().NoError(err)

	var taken atomic.Int64
	var wg sync.WaitGroup
	for i := range 5 {
		wg.Go(func() {
			m, _, claimErr := repo.ClaimPayout(e.ctx, payoutClaim("team-b", "key-"+string(rune('a'+i)), 400))
			s.Require().NoError(claimErr)
			if repo.DebitPayout(e.ctx, m) == nil {
				taken.Add(400)
			}
		})
	}
	wg.Wait()
	s.Equal(int64(800), taken.Load(), "only two payouts of 400 fit in 1000")

	m, created, err := repo.ClaimPayout(e.ctx, payoutClaim("team-b", "key-z", 200))
	s.Require().NoError(err)
	s.True(created)
	s.Require().NoError(repo.DebitPayout(e.ctx, m))
	s.Require().NoError(repo.DebitPayout(e.ctx, m), "a second debit of the same payout is a no-op")
	s.Require().NoError(repo.RevertPayout(e.ctx, m, "rail refused"))

	rows, err := repo.Search(e.ctx, "team-b", 0, 10)
	s.Require().NoError(err)
	s.Require().Len(rows, 1)
	s.Equal(int64(800), rows[0].PaidOut, "the refused payout went back to the balance")

	same, created, err := repo.ClaimPayout(e.ctx, payoutClaim("team-b", "key-z", 200))
	s.Require().NoError(err)
	s.False(created)
	s.Equal(m.GetID(), same.GetID())
	s.Equal(int32(loansv1.TeamCommissionPayoutStatus_TEAM_COMMISSION_PAYOUT_STATUS_PENDING), same.Status)
	s.Equal("rail refused", same.FailureReason)

	payouts, err := repo.SearchPayouts(e.ctx, "team-b", 0, 10)
	s.Require().NoError(err)
	s.Len(payouts, 6)
}
