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
	"time"

	"github.com/pitabwire/frame/v3/data"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

func ids[T interface{ GetID() string }](items []T) []string {
	out := make([]string, 0, len(items))
	for _, item := range items {
		out = append(out, item.GetID())
	}
	return out
}

// The scheduled jobs pick periods by end date, retry hold-off and reminder
// time, and find the period opened after another.
func (s *migrateSuite) TestPeriodJobQueries() {
	e := s.newEnv()
	now := time.Now().UTC()
	past, future, later := now.Add(-time.Hour), now.Add(time.Hour), now.Add(48*time.Hour)

	due := s.newPeriod(e.ctx, "group-j", "tenure-j", "", 1)
	due.EndDate = &past
	held := s.newPeriod(e.ctx, "group-k", "tenure-k", "", 1)
	held.EndDate, held.CloseRetryAt = &past, &future
	closed := s.newPeriod(e.ctx, "group-l", "tenure-l", "", 1)
	closed.EndDate, closed.State = &past, int32(constants.StateShutdown)
	remind := s.newPeriod(e.ctx, "group-m", "tenure-m", "", 1)
	remind.EndDate, remind.NextReminderAt = &later, &past
	notYet := s.newPeriod(e.ctx, "group-n", "tenure-n", "", 1)
	notYet.EndDate, notYet.NextReminderAt = &later, &future
	for _, p := range []*models.Period{due, held, closed, remind, notYet} {
		s.Require().NoError(e.periods.Create(e.ctx, p))
	}

	toClose, err := e.periods.ListDueToClose(e.ctx, now, 10)
	s.Require().NoError(err)
	s.Equal([]string{due.GetID()}, ids(toClose))

	toRemind, err := e.periods.ListDueForReminder(e.ctx, now, 10)
	s.Require().NoError(err)
	s.Equal([]string{remind.GetID()}, ids(toRemind))

	next := s.newPeriod(e.ctx, "group-j", "tenure-j", due.GetID(), 2)
	s.Require().NoError(e.periods.Create(e.ctx, next))
	found, err := e.periods.GetByParentID(e.ctx, due.GetID())
	s.Require().NoError(err)
	s.Equal(next.GetID(), found.GetID())
	_, err = e.periods.GetByParentID(e.ctx, next.GetID())
	s.True(data.ErrorIsNoRows(err), "no period follows the newest one: %v", err)
}

// Tenures are picked for setup and for the group check, and each group's
// latest tenure is read in one query.
func (s *migrateSuite) TestTenureJobQueries() {
	e := s.newEnv()
	now := time.Now().UTC()
	future, recent, stale := now.Add(time.Hour), now.Add(-time.Minute), now.Add(-2*time.Hour)

	tenure := func(group string, position int32, state int32, change func(*models.Tenure)) *models.Tenure {
		t := &models.Tenure{GroupID: group, Duration: 52, Position: position, State: state}
		change(t)
		t.GenID(e.ctx)
		s.Require().NoError(e.tenures.Create(e.ctx, t))
		return t
	}
	active := int32(constants.StateActive)
	pending := tenure("group-p", 1, active, func(*models.Tenure) {})
	heldSetup := tenure("group-q", 1, active, func(t *models.Tenure) { t.SetupRetryAt = &future })
	checkedLongAgo := tenure("group-r", 1, active, func(t *models.Tenure) { t.Welcomed, t.CheckedAt = true, &stale })
	tenure("group-s", 1, active, func(t *models.Tenure) { t.Welcomed, t.CheckedAt = true, &recent })
	old := tenure("group-t", 1, int32(constants.StateShutdown), func(*models.Tenure) {})
	newer := tenure("group-t", 2, active, func(t *models.Tenure) { t.Welcomed = true })

	setups, err := e.tenures.ListPendingSetup(e.ctx, now, 10)
	s.Require().NoError(err)
	s.Equal([]string{pending.GetID()}, ids(setups))
	s.NotContains(ids(setups), heldSetup.GetID())

	checks, err := e.tenures.ListDueForCheck(e.ctx, now.Add(-time.Hour), 10)
	s.Require().NoError(err)
	s.ElementsMatch([]string{pending.GetID(), heldSetup.GetID(), checkedLongAgo.GetID(), newer.GetID()}, ids(checks))
	s.Equal(checkedLongAgo.GetID(), ids(checks)[len(checks)-1], "never-checked tenures come first")

	latest, err := e.tenures.LatestByGroupIDs(e.ctx, []string{"group-t", "group-p", "group-none"})
	s.Require().NoError(err)
	s.Len(latest, 2)
	s.Equal(newer.GetID(), latest["group-t"].GetID())
	s.NotEqual(old.GetID(), latest["group-t"].GetID())
}

// The offer sweeps skip offers held off after a failure and find failed
// offers whose loan is still to be cancelled.
func (s *migrateSuite) TestOfferJobQueries() {
	e := s.newEnv()
	now := time.Now().UTC()
	future := now.Add(time.Hour)

	offer := func(member string, change func(*models.LoanOffer)) *models.LoanOffer {
		o := &models.LoanOffer{MembershipID: member, LoanWindowID: "window-1", PeriodID: "period-1",
			Amount: 100, Currency: "KES", Response: int32(models.LoanOfferResponseAccept)}
		change(o)
		o.GenID(e.ctx)
		s.Require().NoError(e.offers.Create(e.ctx, o))
		return o
	}
	pending := offer("m1", func(o *models.LoanOffer) { o.OriginationStatus = models.OriginationPending })
	offer("m2", func(o *models.LoanOffer) { o.OriginationStatus, o.RetryAt = models.OriginationPending, &future })
	uncancelled := offer("m3", func(o *models.LoanOffer) {
		o.OriginationStatus, o.LoanAccountID = models.OriginationFailed, "loan-3"
		o.Properties = data.JSONMap{"loan_cancelled": false}
	})
	offer("m4", func(o *models.LoanOffer) {
		o.OriginationStatus, o.LoanAccountID = models.OriginationFailed, "loan-4"
		o.Properties = data.JSONMap{"loan_cancelled": true}
	})
	offer("m5", func(o *models.LoanOffer) { o.OriginationStatus = models.OriginationFailed })

	resume, err := e.offers.ListPendingOrigination(e.ctx, now, 10)
	s.Require().NoError(err)
	s.Equal([]string{pending.GetID()}, ids(resume))

	cancels, err := e.offers.ListUncancelledLoans(e.ctx, now, 10)
	s.Require().NoError(err)
	s.Equal([]string{uncancelled.GetID()}, ids(cancels))
}

// A notice is claimed once; a released one can be claimed again.
func (s *migrateSuite) TestNoticeIsClaimedOnce() {
	e := s.newEnv()
	claim := func() bool {
		claimed, err := e.notices.Claim(e.ctx, &models.Notice{Key: "reminder:p-1:m-1:24h", GroupID: "group-1"})
		s.Require().NoError(err)
		return claimed
	}
	s.True(claim())
	s.False(claim(), "a second claim of the same key is refused")
	s.Require().NoError(e.notices.Release(e.ctx, "reminder:p-1:m-1:24h"))
	s.True(claim(), "a released notice is claimed again")
}
