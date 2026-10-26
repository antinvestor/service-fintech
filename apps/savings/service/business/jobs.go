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

// accrueInterest settles the most recently closed day's interest on active
// accounts not yet settled through it. An account is settled whether it
// accrued or had nothing to accrue; one that failed is tried again after a
// pause. Accrue is idempotent per account and day, so overlapping runs
// credit interest once.
func (j *SavingsJobs) accrueInterest(ctx context.Context, batch int, now time.Time) (int, bool, error) {
	periodEnd := now.Truncate(accrualPeriod)
	periodStart := periodEnd.Add(-accrualPeriod)
	listCtx := security.SkipTenancyChecksOnClaims(ctx)

	accounts, err := j.accounts.ListDueForInterest(listCtx, periodEnd, now.Add(-accrualRetryAfter), batch)
	if err != nil {
		return 0, false, fmt.Errorf("accounts due for interest: %w", err)
	}
	for _, sa := range accounts {
		actCtx := j.actIn(ctx, &sa.BaseModel)
		_, accrueErr := j.interest.Accrue(actCtx, sa.GetID(), periodStart, periodEnd)
		settled := accrueErr == nil || isAccrualSkip(accrueErr)
		if !settled {
			util.Log(ctx).WithError(accrueErr).WithField(fieldSavingsAccountID, sa.GetID()).
				Warn("interest accrual failed; a later run retries")
		}
		if markErr := j.accounts.MarkInterestChecked(actCtx, sa.GetID(), periodEnd, settled); markErr != nil {
			util.Log(ctx).WithError(markErr).WithField(fieldSavingsAccountID, sa.GetID()).
				Warn("could not record the interest run on the account")
		}
	}
	return len(accounts), len(accounts) == batch, nil
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
