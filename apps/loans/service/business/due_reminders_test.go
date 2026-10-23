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
	"testing"
	"time"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/v2/data"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
)

// memScheduleEntryRepo serves entries by due-date window and records
// reminder claims the way the Postgres repository does.
type memScheduleEntryRepo struct {
	repository.ScheduleEntryRepository
	entries []*models.ScheduleEntry
}

func (r *memScheduleEntryRepo) ListDueBetween(
	_ context.Context,
	from, to time.Time,
	afterID string,
	_ int,
) ([]*models.ScheduleEntry, error) {
	var out []*models.ScheduleEntry
	for _, e := range r.entries {
		if e.DueDate == nil || e.Outstanding <= 0 {
			continue
		}
		if e.DueDate.Before(from) || !e.DueDate.Before(to) {
			continue
		}
		if afterID != "" && e.GetID() <= afterID {
			continue
		}
		out = append(out, e)
	}
	return out, nil
}

func (r *memScheduleEntryRepo) MarkReminded(_ context.Context, entryID, key string) (bool, error) {
	for _, e := range r.entries {
		if e.GetID() != entryID {
			continue
		}
		if e.Properties == nil {
			e.Properties = data.JSONMap{}
		}
		if _, done := e.Properties[key]; done {
			return false, nil
		}
		e.Properties[key] = time.Now().UTC().Format(time.RFC3339)
		return true, nil
	}
	return false, nil
}

type memLoanAccountRepo struct {
	repository.LoanAccountRepository
	loans map[string]*models.LoanAccount
}

func (r *memLoanAccountRepo) GetByID(_ context.Context, id string) (*models.LoanAccount, error) {
	la, ok := r.loans[id]
	if !ok {
		return nil, ErrLoanAccountNotFound
	}
	return la, nil
}

func TestDueReminderJob_RemindsOnceAndSkipsClosedLoans(t *testing.T) {
	now := time.Date(2026, 10, 24, 9, 0, 0, 0, time.UTC)
	activeLoan := &models.LoanAccount{ClientID: "client-1", CurrencyCode: "KES",
		Status: int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE)}
	activeLoan.GenID(context.Background())
	closedLoan := &models.LoanAccount{ClientID: "client-2", CurrencyCode: "KES",
		Status: int32(loansv1.LoanStatus_LOAN_STATUS_PAID_OFF)}
	closedLoan.GenID(context.Background())

	entry := func(loan *models.LoanAccount, due time.Time, outstanding int64) *models.ScheduleEntry {
		e := &models.ScheduleEntry{LoanAccountID: loan.GetID(), DueDate: &due, Outstanding: outstanding,
			TotalDue: outstanding, CurrencyCode: "KES"}
		e.GenID(context.Background())
		return e
	}
	tomorrow := now.Add(24 * time.Hour)
	fiveDaysAgo := now.Add(-5 * 24 * time.Hour)
	farFuture := now.Add(20 * 24 * time.Hour)
	entries := &memScheduleEntryRepo{entries: []*models.ScheduleEntry{
		entry(activeLoan, tomorrow, 150_000),   // due soon → reminder
		entry(activeLoan, fiveDaysAgo, 90_000), // overdue → overdue notice
		entry(activeLoan, farFuture, 150_000),  // not yet
		entry(closedLoan, tomorrow, 10_000),    // loan not repayable → nothing
	}}
	loans := &memLoanAccountRepo{loans: map[string]*models.LoanAccount{
		activeLoan.GetID(): activeLoan, closedLoan.GetID(): closedLoan,
	}}
	sender := &captureSender{}
	notifier := NewLoanNotifier(notify.NewWithSender(sender, messages.Registry()),
		mapResolver{profiles: map[string]string{"client-1": "profile-1", "client-2": "profile-2"}}, "Harvest")

	job := NewDueReminderJob(entries, loans, notifier, 2)
	job.now = func() time.Time { return now }

	require.NoError(t, job.Run(context.Background()))
	require.Len(t, sender.got, 2)
	templates := []string{sender.got[0].GetTemplate(), sender.got[1].GetTemplate()}
	assert.ElementsMatch(t, []string{messages.LoanPaymentDue, messages.LoanPaymentOverdue}, templates)
	for _, got := range sender.got {
		assert.Equal(t, "profile-1", got.GetRecipient().GetProfileId())
		payload := got.GetPayload().AsMap()
		if got.GetTemplate() == messages.LoanPaymentOverdue {
			assert.Equal(t, "5", payload[messages.VarDaysOverdue])
			assert.Equal(t, "900.00", payload[messages.VarAmount])
		} else {
			assert.Equal(t, "1,500.00", payload[messages.VarAmount])
			assert.Equal(t, "25 Oct 2026", payload[messages.VarDueDate])
		}
	}

	// A second run sends nothing: each reminder is claimed on its installment.
	require.NoError(t, job.Run(context.Background()))
	assert.Len(t, sender.got, 2)
}

func TestDueReminderJob_DisabledNotifierIsANoop(t *testing.T) {
	job := NewDueReminderJob(&memScheduleEntryRepo{}, &memLoanAccountRepo{}, nil, 2)
	require.NoError(t, job.Run(context.Background()))
}
