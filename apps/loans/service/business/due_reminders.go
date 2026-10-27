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
	"fmt"
	"time"

	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

const (
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
	// subject is this service's own identity, under which each reminder is
	// sent inside its loan's tenancy.
	subject string
}

// WithSubject names this service's identity for the reminders it sends.
func (j *DueReminderJob) WithSubject(subject string) *DueReminderJob {
	j.subject = subject
	return j
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

// RunBatch sends up to batch reminders: first those for installments about
// to fall due, then those for installments just missed. Each reminder is
// claimed on its installment before it is sent, so concurrent runs never
// send it twice. It reports how many it sent and whether the batch was full.
func (j *DueReminderJob) RunBatch(ctx context.Context, batch int) (int, bool, error) {
	if !j.notifier.Enabled() {
		return 0, false, nil
	}
	now := j.now().UTC()
	logger := util.Log(ctx).WithField("job", "due_reminders")

	due, err := j.scheduleRepo.ClaimReminders(ctx, repository.ReminderDue,
		now, now.Add(time.Duration(j.daysAhead)*hoursPerDay*time.Hour), batch)
	if err != nil {
		return 0, false, fmt.Errorf("claim due reminders: %w", err)
	}
	loans := map[string]*models.LoanAccount{}
	for _, entry := range due {
		j.remindEntry(ctx, logger, entry, repository.ReminderDue, loans)
	}
	if len(due) == batch {
		return len(due), true, nil
	}

	overdue, err := j.scheduleRepo.ClaimReminders(ctx, repository.ReminderOverdue,
		now.Add(-overdueLookback), now, batch-len(due))
	if err != nil {
		return len(due), false, fmt.Errorf("claim overdue reminders: %w", err)
	}
	for _, entry := range overdue {
		j.remindEntry(ctx, logger, entry, repository.ReminderOverdue, loans)
	}
	processed := len(due) + len(overdue)
	return processed, processed == batch, nil
}

// remindEntry sends one claimed reminder if the installment's loan is still
// repayable.
func (j *DueReminderJob) remindEntry(
	ctx context.Context,
	logger *util.LogEntry,
	entry *models.ScheduleEntry,
	kind repository.ReminderKind,
	loans map[string]*models.LoanAccount,
) {
	la, ok := loans[entry.LoanAccountID]
	if !ok {
		loaded, loadErr := j.loanAccountRepo.GetByID(ctx, entry.LoanAccountID)
		if loadErr != nil || loaded == nil {
			logger.WithError(loadErr).WithField("entry_id", entry.GetID()).Warn("loan of reminder not found")
			return
		}
		loans[entry.LoanAccountID] = loaded
		la = loaded
	}
	if !isRepayableStatus(la.Status) {
		return
	}
	ctx = actInLoan(ctx, j.subject, la)
	switch kind {
	case repository.ReminderDue:
		j.notifier.NotifyPaymentDue(ctx, la, entry.Outstanding, entry.DueDate)
	case repository.ReminderOverdue:
		days := 0
		if entry.DueDate != nil {
			days = int(j.now().UTC().Sub(*entry.DueDate).Hours() / hoursPerDay)
		}
		j.notifier.NotifyPaymentOverdue(ctx, la, entry.Outstanding, entry.DueDate, days)
	}
}
