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
	"time"

	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

const (
	// reminderKeyDue and reminderKeyOverdue are the entry property keys that
	// record each reminder was sent, so a borrower hears each once.
	reminderKeyDue     = "reminder_due_sent_at"
	reminderKeyOverdue = "reminder_overdue_sent_at"

	reminderPageSize = 200
	reminderMaxPages = 500
	// overdueLookback bounds how far back the overdue pass looks for
	// installments never reminded, so a fresh deployment does not message
	// borrowers about ancient arrears all at once.
	overdueLookback = 60 * 24 * time.Hour
)

// DueReminderJob tells borrowers about installments about to fall due and
// about installments just missed. It is a background obligation: without it
// no borrower is ever reminded, and arrears are discovered only in person.
type DueReminderJob struct {
	scheduleRepo    repository.ScheduleEntryRepository
	loanAccountRepo repository.LoanAccountRepository
	notifier        *LoanNotifier
	daysAhead       int
	now             func() time.Time
}

// NewDueReminderJob builds the job. daysAhead is how many days before the
// due date the upcoming reminder goes out.
func NewDueReminderJob(
	scheduleRepo repository.ScheduleEntryRepository,
	loanAccountRepo repository.LoanAccountRepository,
	notifier *LoanNotifier,
	daysAhead int,
) *DueReminderJob {
	if daysAhead <= 0 {
		daysAhead = 2
	}
	return &DueReminderJob{
		scheduleRepo:    scheduleRepo,
		loanAccountRepo: loanAccountRepo,
		notifier:        notifier,
		daysAhead:       daysAhead,
		now:             time.Now,
	}
}

// Run sends the reminders that are due. It is safe to run on a schedule and
// from several replicas: each reminder is claimed on its installment.
func (j *DueReminderJob) Run(ctx context.Context) error {
	if !j.notifier.Enabled() {
		return nil
	}
	now := j.now().UTC()
	logger := util.Log(ctx).WithField("method", "DueReminderJob.Run")

	sentDue, err := j.remind(ctx, logger, now, now.Add(time.Duration(j.daysAhead)*24*time.Hour), reminderKeyDue)
	if err != nil {
		return err
	}
	sentOverdue, err := j.remind(ctx, logger, now.Add(-overdueLookback), now, reminderKeyOverdue)
	if err != nil {
		return err
	}
	logger.WithField("due_reminders", sentDue).WithField("overdue_reminders", sentOverdue).
		Info("payment reminders sent")
	return nil
}

func (j *DueReminderJob) remind(
	ctx context.Context,
	logger *util.LogEntry,
	from, to time.Time,
	key string,
) (int, error) {
	sent := 0
	afterID := ""
	loans := map[string]*models.LoanAccount{}
	for range reminderMaxPages {
		entries, err := j.scheduleRepo.ListDueBetween(ctx, from, to, afterID, reminderPageSize)
		if err != nil {
			return sent, err
		}
		if len(entries) == 0 {
			return sent, nil
		}
		afterID = entries[len(entries)-1].GetID()

		for _, entry := range entries {
			if j.remindEntry(ctx, logger, entry, key, loans) {
				sent++
			}
		}
		if len(entries) < reminderPageSize {
			return sent, nil
		}
	}
	return sent, nil
}

// remindEntry sends one reminder for one installment if its loan is still
// repayable and the reminder has not been sent. It reports whether it sent.
func (j *DueReminderJob) remindEntry(
	ctx context.Context,
	logger *util.LogEntry,
	entry *models.ScheduleEntry,
	key string,
	loans map[string]*models.LoanAccount,
) bool {
	la, ok := loans[entry.LoanAccountID]
	if !ok {
		loaded, loadErr := j.loanAccountRepo.GetByID(ctx, entry.LoanAccountID)
		if loadErr != nil || loaded == nil {
			return false
		}
		loans[entry.LoanAccountID] = loaded
		la = loaded
	}
	if !isRepayableStatus(la.Status) {
		return false
	}
	claimed, claimErr := j.scheduleRepo.MarkReminded(ctx, entry.GetID(), key)
	if claimErr != nil {
		logger.WithError(claimErr).WithField("entry_id", entry.GetID()).Warn("could not claim reminder")
		return false
	}
	if !claimed {
		return false
	}
	switch key {
	case reminderKeyDue:
		j.notifier.NotifyPaymentDue(ctx, la, entry.Outstanding, entry.DueDate)
	case reminderKeyOverdue:
		days := 0
		if entry.DueDate != nil {
			days = int(j.now().UTC().Sub(*entry.DueDate).Hours() / hoursPerDay)
		}
		j.notifier.NotifyPaymentOverdue(ctx, la, entry.Outstanding, entry.DueDate, days)
	}
	return true
}
