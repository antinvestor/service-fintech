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

	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

const (
	// defaultJobBatch is how many accounts one run handles when the caller
	// does not say.
	defaultJobBatch = 200
	// accrualPeriod is the closing period interest is settled for: one UTC
	// day.
	accrualPeriod = 24 * time.Hour
	// accrualRetryAfter is how long an account whose accrual failed waits
	// before a run tries it again, so it never blocks the rest.
	accrualRetryAfter = 10 * time.Minute
	// maxAccrualDaysPerRun bounds how many missed days one run settles for
	// one account; an account further behind catches up over later runs.
	maxAccrualDaysPerRun = 31
)

var (
	// ErrUnknownJob is returned for a job the service does not run.
	ErrUnknownJob = apperrors.NewError(apperrors.BadRequest, "unknown savings job")
	// ErrJobCallerNotInternal is returned when anyone but an internal
	// service account asks to run a job.
	ErrJobCallerNotInternal = apperrors.NewError(apperrors.Forbidden,
		"savings jobs are run only by internal services")
)

// SavingsJobs runs the savings service's periodic work, one bounded batch
// per call. The platform scheduler (trustage) calls it; nothing in the
// service runs on a timer.
type SavingsJobs struct {
	accounts repository.SavingsAccountRepository
	interest InterestAccrualBusiness
	subject  string
}

// NewSavingsJobs wires the jobs. subject is this service's own identity,
// under which each account is processed inside its partition.
func NewSavingsJobs(
	accounts repository.SavingsAccountRepository,
	interest InterestAccrualBusiness,
	subject string,
) *SavingsJobs {
	return &SavingsJobs{accounts: accounts, interest: interest, subject: subject}
}

// Run runs one batch of job.
func (j *SavingsJobs) Run(ctx context.Context, job savingsv1.SavingsJob, batch int) (int, bool, error) {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil || !claims.IsInternalSystem() {
		return 0, false, ErrJobCallerNotInternal
	}
	if batch <= 0 {
		batch = defaultJobBatch
	}
	switch job {
	case savingsv1.SavingsJob_SAVINGS_JOB_ACCRUE_INTEREST:
		return j.accrueInterest(ctx, batch, time.Now().UTC())
	case savingsv1.SavingsJob_SAVINGS_JOB_UNSPECIFIED:
	}
	return 0, false, ErrUnknownJob
}

// accrueInterest settles interest on active accounts not yet settled through
// the most recently closed day: each day from where the account was last
// settled (or the day it was opened) up to that one, one period per day, at
// most maxAccrualDaysPerRun days per account per run. A day is settled
// whether it accrued or had nothing to accrue; a day that failed stops the
// account there and is tried again after a pause. Accrue is idempotent per
// account and day, so overlapping runs credit each day once.
func (j *SavingsJobs) accrueInterest(ctx context.Context, batch int, now time.Time) (int, bool, error) {
	periodEnd := now.Truncate(accrualPeriod)
	listCtx := security.SkipTenancyChecksOnClaims(ctx)

	accounts, err := j.accounts.ListDueForInterest(listCtx, periodEnd, now.Add(-accrualRetryAfter), batch)
	if err != nil {
		return 0, false, fmt.Errorf("accounts due for interest: %w", err)
	}
	more := len(accounts) == batch
	for _, sa := range accounts {
		actCtx := j.actIn(ctx, &sa.BaseModel)
		through, caughtUp := j.accrueMissedDays(actCtx, sa, periodEnd)
		if !caughtUp {
			more = true
		}
		// An account opened since the last closed day has no day to settle
		// yet: it is settled through that day.
		settled := through != nil || caughtUp
		mark := periodEnd
		if through != nil {
			mark = *through
		}
		if markErr := j.accounts.MarkInterestChecked(actCtx, sa.GetID(), mark, settled); markErr != nil {
			util.Log(ctx).WithError(markErr).WithField(fieldSavingsAccountID, sa.GetID()).
				Warn("could not record the interest run on the account")
		}
	}
	return len(accounts), more, nil
}

// accrueMissedDays accrues the account's unsettled days up to periodEnd and
// returns the end of the last day it settled (nil when none) and whether it
// reached periodEnd.
func (j *SavingsJobs) accrueMissedDays(
	ctx context.Context,
	sa *models.SavingsAccount,
	periodEnd time.Time,
) (*time.Time, bool) {
	dayStart := sa.CreatedAt.UTC().Truncate(accrualPeriod)
	if sa.InterestAccruedThrough != nil {
		dayStart = sa.InterestAccruedThrough.UTC().Truncate(accrualPeriod)
	}
	var through *time.Time
	for range maxAccrualDaysPerRun {
		dayEnd := dayStart.Add(accrualPeriod)
		if dayEnd.After(periodEnd) {
			return through, true
		}
		_, accrueErr := j.interest.Accrue(ctx, sa.GetID(), dayStart, dayEnd)
		if accrueErr != nil && !isAccrualSkip(accrueErr) {
			util.Log(ctx).WithError(accrueErr).WithField(fieldSavingsAccountID, sa.GetID()).
				WithField("period_end", dayEnd).Warn("interest accrual failed; a later run retries")
			return through, false
		}
		settledDay := dayEnd
		through = &settledDay
		dayStart = dayEnd
	}
	return through, !dayStart.Before(periodEnd)
}

// actIn is ctx as this service acting inside the item's partition.
func (j *SavingsJobs) actIn(ctx context.Context, item *data.BaseModel) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:    item.TenantID,
		PartitionID: item.PartitionID,
		Roles:       []string{security.ConstantSystemInternalRole},
	}
	claims.Subject = j.subject
	return claims.ClaimsToContext(ctx, security.WithoutInternalTenancySkip())
}
