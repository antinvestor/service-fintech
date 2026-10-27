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
	"fmt"
	"sync"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/v3/data"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

func (s *migrateSuite) loan(e *migrateEnv, status loansv1.LoanStatus) *models.LoanAccount {
	s.T().Helper()
	la := &models.LoanAccount{ClientID: "client", ProductID: "prod", CurrencyCode: "KES", Status: int32(status)}
	la.GenID(e.ctx)
	la.LoanRequestID = "lr-" + la.GetID()
	s.Require().NoError(repository.NewLoanAccountRepository(e.ctx, e.dbPool, nil).Create(e.ctx, la))
	return la
}

// Concurrent delinquency runs never assess the same loan, and a claimed loan
// is not due again until the next day.
func (s *migrateSuite) TestAssessmentClaimsAreDisjointAndDaily() {
	e := s.newEnv()
	loans := repository.NewLoanAccountRepository(e.ctx, e.dbPool, nil)
	for range 30 {
		s.loan(e, loansv1.LoanStatus_LOAN_STATUS_ACTIVE)
	}
	s.loan(e, loansv1.LoanStatus_LOAN_STATUS_PAID_OFF) // never assessed

	var mu sync.Mutex
	seen := map[string]int{}
	var wg sync.WaitGroup
	for range 4 {
		wg.Go(func() {
			got, err := loans.ClaimForAssessment(e.ctx, 10)
			s.Require().NoError(err)
			mu.Lock()
			defer mu.Unlock()
			for _, la := range got {
				seen[la.GetID()]++
			}
		})
	}
	wg.Wait()
	s.Len(seen, 30, "every repayable loan claimed, the paid-off one never")
	for id, n := range seen {
		s.Equal(1, n, "loan %s claimed twice", id)
	}

	again, err := loans.ClaimForAssessment(e.ctx, 10)
	s.Require().NoError(err)
	s.Empty(again, "nothing is due again while it is claimed")

	var one string
	for id := range seen {
		one = id
		break
	}
	s.Require().NoError(loans.AssessSoon(e.ctx, one))
	soon, err := loans.ClaimForAssessment(e.ctx, 10)
	s.Require().NoError(err)
	s.Require().Len(soon, 1)
	s.Equal(one, soon[0].GetID())
}

// The repayment lease admits one holder at a time.
func (s *migrateSuite) TestRepaymentLockIsExclusive() {
	e := s.newEnv()
	loans := repository.NewLoanAccountRepository(e.ctx, e.dbPool, nil)
	la := s.loan(e, loansv1.LoanStatus_LOAN_STATUS_ACTIVE)

	lease, first, err := loans.ClaimRepaymentLock(e.ctx, la.GetID())
	s.Require().NoError(err)
	s.True(first)
	_, second, err := loans.ClaimRepaymentLock(e.ctx, la.GetID())
	s.Require().NoError(err)
	s.False(second)
	s.Require().NoError(loans.ReleaseRepaymentLock(e.ctx, la.GetID(), lease))
	_, third, err := loans.ClaimRepaymentLock(e.ctx, la.GetID())
	s.Require().NoError(err)
	s.True(third)
}

// A holder that outlived its lease cannot release the lease of the
// repayment that took the loan over.
func (s *migrateSuite) TestRepaymentLockReleaseIsOwnerChecked() {
	e := s.newEnv()
	loans := repository.NewLoanAccountRepository(e.ctx, e.dbPool, nil)
	la := s.loan(e, loansv1.LoanStatus_LOAN_STATUS_ACTIVE)

	stale, claimed, err := loans.ClaimRepaymentLock(e.ctx, la.GetID())
	s.Require().NoError(err)
	s.Require().True(claimed)

	// The first holder's lease lapses and another repayment takes the loan.
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Exec(
		`UPDATE loan_accounts SET repayment_locked_at = now() - interval '1 hour' WHERE id = ?`, la.GetID()).Error)
	_, takenOver, err := loans.ClaimRepaymentLock(e.ctx, la.GetID())
	s.Require().NoError(err)
	s.Require().True(takenOver)

	s.Require().NoError(loans.ReleaseRepaymentLock(e.ctx, la.GetID(), stale))
	_, again, err := loans.ClaimRepaymentLock(e.ctx, la.GetID())
	s.Require().NoError(err)
	s.False(again, "the stale holder's release must leave the new holder's lease in place")
}

// Repayments recorded but not applied are listed for the loan, oldest first.
func (s *migrateSuite) TestListUnappliedRepayments() {
	e := s.newEnv()
	la := s.loan(e, loansv1.LoanStatus_LOAN_STATUS_ACTIVE)
	repayments := repository.NewRepaymentRepository(e.ctx, e.dbPool, nil)
	now := time.Now().UTC()
	for i, applied := range []*time.Time{&now, nil} {
		r := &models.Repayment{LoanAccountID: la.GetID(), Amount: 100, CurrencyCode: "KES",
			IdempotencyKey: fmt.Sprintf("u-%d", i), AppliedAt: applied, Properties: data.JSONMap{}}
		r.GenID(e.ctx)
		s.Require().NoError(repayments.Create(e.ctx, r))
	}
	pending, err := repayments.ListUnapplied(e.ctx, la.GetID(), 10)
	s.Require().NoError(err)
	s.Require().Len(pending, 1)
	s.Equal("u-1", pending[0].IdempotencyKey)
}

// Applying a repayment moves its installments and the balance by deltas,
// once, however often it is called.
func (s *migrateSuite) TestRepaymentAppliesOnce() {
	e := s.newEnv()
	la := s.loan(e, loansv1.LoanStatus_LOAN_STATUS_ACTIVE)
	balances := repository.NewLoanBalanceRepository(e.ctx, e.dbPool, nil)
	s.Require().NoError(balances.Create(e.ctx, &models.LoanBalance{
		LoanAccountID: la.GetID(), CurrencyCode: "KES",
		PrincipalOutstanding: 10_000, InterestAccrued: 1_000, TotalOutstanding: 11_000,
	}))
	entries := repository.NewScheduleEntryRepository(e.ctx, e.dbPool, nil)
	entry := &models.ScheduleEntry{LoanAccountID: la.GetID(), PrincipalDue: 5_000, InterestDue: 500,
		TotalDue: 5_500, Outstanding: 5_500, CurrencyCode: "KES"}
	entry.GenID(e.ctx)
	s.Require().NoError(entries.Create(e.ctx, entry))
	repayments := repository.NewRepaymentRepository(e.ctx, e.dbPool, nil)
	r := &models.Repayment{LoanAccountID: la.GetID(), Amount: 3_000, CurrencyCode: "KES",
		Status: int32(loansv1.RepaymentStatus_REPAYMENT_STATUS_PARTIAL), IdempotencyKey: "k1",
		Properties: data.JSONMap{}}
	r.GenID(e.ctx)
	s.Require().NoError(repayments.Create(e.ctx, r))

	applier := repository.NewRepaymentApplier(e.dbPool, balances)
	plan := []repository.EntryAllocation{{EntryID: entry.GetID(), Interest: 500, Principal: 2_500}}
	delta := repository.LoanBalanceDelta{InterestApplied: 500, PrincipalApplied: 2_500}
	for i := range 3 {
		applied, balance, err := applier.Apply(e.ctx, r.GetID(), la.GetID(), plan, delta)
		s.Require().NoError(err)
		s.Equal(i == 0, applied)
		s.EqualValues(8_000, balance.TotalOutstanding)
	}
	stored, err := entries.GetByID(e.ctx, entry.GetID())
	s.Require().NoError(err)
	s.EqualValues(2_500, stored.PrincipalPaid)
	s.EqualValues(500, stored.InterestPaid)
	s.EqualValues(2_500, stored.Outstanding)
	s.EqualValues(loansv1.ScheduleEntryStatus_SCHEDULE_ENTRY_STATUS_PARTIAL, stored.Status)

	// Applied and still owed to funders: the settlement job claims it once.
	claimed, err := repayments.ClaimFundingUnsettled(e.ctx, 10, 300)
	s.Require().NoError(err)
	s.Require().Len(claimed, 1)
	leased, err := repayments.ClaimFundingUnsettled(e.ctx, 10, 300)
	s.Require().NoError(err)
	s.Empty(leased, "a leased repayment is not handed out twice")
	s.Require().NoError(repayments.MarkFundingSettled(e.ctx, r.GetID(), ""))
	done, err := repayments.ClaimFundingUnsettled(e.ctx, 10, 0)
	s.Require().NoError(err)
	s.Empty(done)
}

// A lapsed offer expires once; a decided request is never expired.
func (s *migrateSuite) TestLapsedOffersExpireOnce() {
	e := s.newEnv()
	requests := repository.NewLoanRequestRepository(e.ctx, e.dbPool, nil)
	past := time.Now().Add(-time.Hour)
	future := time.Now().Add(time.Hour)
	mk := func(status loansv1.LoanRequestStatus, expires *time.Time, key string) {
		lr := &models.LoanRequest{ClientID: "c", OrganizationID: "o", CurrencyCode: "KES",
			Status: int32(status), OfferExpiresAt: expires, IdempotencyKey: key}
		lr.GenID(e.ctx)
		s.Require().NoError(requests.Create(e.ctx, lr))
	}
	mk(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED, &past, "a")
	mk(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED, &past, "b")
	mk(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED, &future, "c")
	mk(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_LOAN_CREATED, &past, "d")

	expired, err := requests.ExpireLapsedOffers(e.ctx, 10)
	s.Require().NoError(err)
	s.Len(expired, 2)
	for _, lr := range expired {
		s.EqualValues(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_EXPIRED, lr.Status)
	}
	again, err := requests.ExpireLapsedOffers(e.ctx, 10)
	s.Require().NoError(err)
	s.Empty(again)
}

// Each reminder is claimed once, only on the active schedule.
func (s *migrateSuite) TestRemindersAreClaimedOnce() {
	e := s.newEnv()
	la := s.loan(e, loansv1.LoanStatus_LOAN_STATUS_ACTIVE)
	schedules := repository.NewRepaymentScheduleRepository(e.ctx, e.dbPool, nil)
	active := &models.RepaymentSchedule{LoanAccountID: la.GetID(), IsActive: true, ScheduleVersion: 2}
	active.GenID(e.ctx)
	s.Require().NoError(schedules.Create(e.ctx, active))
	old := &models.RepaymentSchedule{LoanAccountID: la.GetID(), IsActive: false, ScheduleVersion: 1}
	old.GenID(e.ctx)
	s.Require().NoError(schedules.Create(e.ctx, old))

	entries := repository.NewScheduleEntryRepository(e.ctx, e.dbPool, nil)
	tomorrow := time.Now().Add(24 * time.Hour)
	for _, sched := range []*models.RepaymentSchedule{active, old} {
		entry := &models.ScheduleEntry{ScheduleID: sched.GetID(), LoanAccountID: la.GetID(), DueDate: &tomorrow,
			TotalDue: 100, Outstanding: 100, CurrencyCode: "KES"}
		entry.GenID(e.ctx)
		s.Require().NoError(entries.Create(e.ctx, entry))
	}

	now := time.Now()
	got, err := entries.ClaimReminders(e.ctx, repository.ReminderDue, now, now.Add(48*time.Hour), 10)
	s.Require().NoError(err)
	s.Require().Len(got, 1, "only the active schedule's installment")
	again, err := entries.ClaimReminders(e.ctx, repository.ReminderDue, now, now.Add(48*time.Hour), 10)
	s.Require().NoError(err)
	s.Empty(again)
}

// A loan keeps one active schedule, its newest, whatever order the saves
// land in; and a schedule can be updated (its version column is the lock
// counter, not the schedule's number).
func (s *migrateSuite) TestOnlyTheNewestScheduleStaysActive() {
	e := s.newEnv()
	la := s.loan(e, loansv1.LoanStatus_LOAN_STATUS_ACTIVE)
	schedules := repository.NewRepaymentScheduleRepository(e.ctx, e.dbPool, nil)

	opened := time.Now().Add(-time.Hour)
	reanchored := time.Now()
	newest := &models.RepaymentSchedule{
		LoanAccountID:   la.GetID(),
		IsActive:        true,
		ScheduleVersion: 1,
		GeneratedAt:     &reanchored,
	}
	newest.GenID(e.ctx)
	opening := &models.RepaymentSchedule{
		LoanAccountID:   la.GetID(),
		IsActive:        true,
		ScheduleVersion: 1,
		GeneratedAt:     &opened,
	}
	opening.GenID(e.ctx)

	// The re-anchored schedule lands first, the opening one after it.
	s.Require().NoError(schedules.Create(e.ctx, newest))
	s.Require().NoError(schedules.KeepLatestActive(e.ctx, la.GetID()))
	s.Require().NoError(schedules.Create(e.ctx, opening))
	s.Require().NoError(schedules.KeepLatestActive(e.ctx, la.GetID()))

	active, err := schedules.GetActivByLoanAccountID(e.ctx, la.GetID())
	s.Require().NoError(err)
	s.Equal(newest.GetID(), active.GetID())
	stale, err := schedules.GetByID(e.ctx, opening.GetID())
	s.Require().NoError(err)
	s.False(stale.IsActive, "the older schedule is deactivated")

	active.Properties = map[string]any{"note": "updated"}
	_, err = schedules.Update(e.ctx, active, "properties")
	s.Require().NoError(err, "a schedule is updatable under its lock counter")
}

// One decision per restructure; an approval left half applied can be resumed
// only after its lease, and never by a rejection.
func (s *migrateSuite) TestRestructureDecisionIsExclusive() {
	e := s.newEnv()
	restructures := repository.NewLoanRestructureRepository(e.ctx, e.dbPool, nil)
	lr := &models.LoanRestructure{LoanAccountID: "la", State: int32(commonv1.STATE_CREATED)}
	lr.GenID(e.ctx)
	s.Require().NoError(restructures.Create(e.ctx, lr))

	ok, err := restructures.ClaimDecision(e.ctx, lr.GetID(), int32(commonv1.STATE_CHECKED), "checker", "", true)
	s.Require().NoError(err)
	s.True(ok)
	ok, err = restructures.ClaimDecision(e.ctx, lr.GetID(), int32(commonv1.STATE_CHECKED), "other", "", true)
	s.Require().NoError(err)
	s.False(ok, "a fresh approval in progress is not taken over")
	ok, err = restructures.ClaimDecision(e.ctx, lr.GetID(), int32(commonv1.STATE_INACTIVE), "other", "no", false)
	s.Require().NoError(err)
	s.False(ok, "a rejection never takes over an approval")

	s.Require().NoError(restructures.ReleaseDecision(e.ctx, lr.GetID()))
	ok, err = restructures.ClaimDecision(e.ctx, lr.GetID(), int32(commonv1.STATE_INACTIVE), "other", "no", false)
	s.Require().NoError(err)
	s.True(ok, "released, it can be decided again")
}

// Paid-off loans whose notice never got through are claimed once per lease,
// fresh pay-offs are left to the repayment that made them, and a noticed
// loan is never claimed again.
func (s *migrateSuite) TestPaidOffNoticesAreClaimedUntilNoticed() {
	e := s.newEnv()
	loans := repository.NewLoanAccountRepository(e.ctx, e.dbPool, nil)
	old1 := s.loan(e, loansv1.LoanStatus_LOAN_STATUS_PAID_OFF)
	old2 := s.loan(e, loansv1.LoanStatus_LOAN_STATUS_PAID_OFF)
	s.loan(e, loansv1.LoanStatus_LOAN_STATUS_PAID_OFF) // paid off just now
	active := s.loan(e, loansv1.LoanStatus_LOAN_STATUS_ACTIVE)
	db := e.dbPool.DB(e.ctx, false)
	s.Require().NoError(db.Exec(`UPDATE loan_accounts SET modified_at = now() - interval '1 hour' WHERE id IN ?`,
		[]string{old1.GetID(), old2.GetID(), active.GetID()}).Error)

	claimed, err := loans.ClaimPaidOffUnnoticed(e.ctx, 10)
	s.Require().NoError(err)
	var ids []string
	for _, la := range claimed {
		ids = append(ids, la.GetID())
	}
	s.ElementsMatch([]string{old1.GetID(), old2.GetID()}, ids)

	again, err := loans.ClaimPaidOffUnnoticed(e.ctx, 10)
	s.Require().NoError(err)
	s.Empty(again, "a claimed notice is not handed out twice within its lease")

	s.Require().NoError(loans.MarkPaidOffNoticed(e.ctx, old1.GetID()))
	s.Require().NoError(db.Exec(
		`UPDATE loan_accounts SET paid_off_notice_claimed_at = now() - interval '1 hour' WHERE id IN ?`,
		[]string{old1.GetID(), old2.GetID()}).Error)
	retried, err := loans.ClaimPaidOffUnnoticed(e.ctx, 10)
	s.Require().NoError(err)
	s.Require().Len(retried, 1, "only the unnoticed loan is retried once its lease lapses")
	s.Equal(old2.GetID(), retried[0].GetID())
}

// A loan is claimed for assessment briefly; only the run that assessed it
// schedules it a day ahead, and only while its claim is still the loan's.
func (s *migrateSuite) TestAssessmentClaimIsShortUntilAssessed() {
	e := s.newEnv()
	loans := repository.NewLoanAccountRepository(e.ctx, e.dbPool, nil)
	la := s.loan(e, loansv1.LoanStatus_LOAN_STATUS_ACTIVE)

	claimed, err := loans.ClaimForAssessment(e.ctx, 10)
	s.Require().NoError(err)
	s.Require().Len(claimed, 1)
	lease := claimed[0].NextAssessmentAt
	s.Require().NotNil(lease)
	s.WithinDuration(time.Now().Add(15*time.Minute), *lease, time.Minute, "a short claim, not a day")

	// Not reached by its run: due again once the claim lapses.
	s.Require().NoError(e.dbPool.DB(e.ctx, false).Exec(
		`UPDATE loan_accounts SET next_assessment_at = now() - interval '1 second' WHERE id = ?`, la.GetID()).Error)
	again, err := loans.ClaimForAssessment(e.ctx, 10)
	s.Require().NoError(err)
	s.Require().Len(again, 1)

	// A stale claim does not reschedule; the live one does.
	s.Require().NoError(loans.ScheduleNextAssessment(e.ctx, la.GetID(), *lease))
	stored, err := loans.GetByID(e.ctx, la.GetID())
	s.Require().NoError(err)
	s.WithinDuration(*again[0].NextAssessmentAt, *stored.NextAssessmentAt, time.Second)

	s.Require().NoError(loans.ScheduleNextAssessment(e.ctx, la.GetID(), *again[0].NextAssessmentAt))
	stored, err = loans.GetByID(e.ctx, la.GetID())
	s.Require().NoError(err)
	s.WithinDuration(time.Now().Add(24*time.Hour), *stored.NextAssessmentAt, time.Minute)
}
