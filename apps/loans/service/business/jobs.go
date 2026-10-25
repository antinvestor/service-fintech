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

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// defaultJobBatch is how many items one run handles when the caller does not
// say.
const defaultJobBatch = 200

var (
	// ErrUnknownJob is returned for a job the service does not run.
	ErrUnknownJob = apperrors.NewError(apperrors.BadRequest, "unknown loans job")
	// ErrJobCallerNotInternal is returned when anyone but an internal
	// service account asks to run a job.
	ErrJobCallerNotInternal = apperrors.NewError(apperrors.Forbidden,
		"loan jobs are run only by internal services")
)

// LoanJobs runs the loans service's periodic work, one bounded batch per call.
// The platform scheduler (trustage) calls it; nothing in the service runs on
// a timer. Every job claims its items in the database, so any number of calls
// may run at once on any number of replicas.
type LoanJobs struct {
	delinquency *DelinquencyScanner
	reminders   *DueReminderJob
	settlement  *FundingSettlement
	requestRepo repository.LoanRequestRepository
	notifier    *LoanNotifier
}

// NewLoanJobs wires the jobs.
func NewLoanJobs(
	delinquency *DelinquencyScanner,
	reminders *DueReminderJob,
	settlement *FundingSettlement,
	requestRepo repository.LoanRequestRepository,
	notifier *LoanNotifier,
) *LoanJobs {
	return &LoanJobs{
		delinquency: delinquency,
		reminders:   reminders,
		settlement:  settlement,
		requestRepo: requestRepo,
		notifier:    notifier,
	}
}

// Run runs one batch of job. Jobs work across every tenant, so the batch runs
// without the caller's tenancy scope. That is allowed only for an internal
// service account, checked here as well as by the RPC permission, so the
// scope is never dropped for anyone else.
func (j *LoanJobs) Run(ctx context.Context, job loansv1.LoanJob, batch int) (int, bool, error) {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil || !claims.IsInternalSystem() {
		return 0, false, ErrJobCallerNotInternal
	}
	if batch <= 0 {
		batch = defaultJobBatch
	}
	ctx = security.SkipTenancyChecksOnClaims(ctx)
	switch job {
	case loansv1.LoanJob_LOAN_JOB_DELINQUENCY_SCAN:
		return j.delinquency.RunBatch(ctx, batch)
	case loansv1.LoanJob_LOAN_JOB_DUE_REMINDERS:
		return j.reminders.RunBatch(ctx, batch)
	case loansv1.LoanJob_LOAN_JOB_FUNDING_SETTLEMENT:
		return j.settlement.RunBatch(ctx, batch)
	case loansv1.LoanJob_LOAN_JOB_REQUEST_EXPIRY:
		return j.expireRequests(ctx, batch)
	case loansv1.LoanJob_LOAN_JOB_UNSPECIFIED:
	}
	return 0, false, ErrUnknownJob
}

// expireRequests expires submitted and approved requests whose offer lapsed
// and tells each borrower.
func (j *LoanJobs) expireRequests(ctx context.Context, batch int) (int, bool, error) {
	expired, err := j.requestRepo.ExpireLapsedOffers(ctx, batch)
	if err != nil {
		return 0, false, fmt.Errorf("expire lapsed offers: %w", err)
	}
	for _, lr := range expired {
		j.notifier.NotifyApplicationExpired(ctx, lr)
	}
	if len(expired) > 0 {
		util.Log(ctx).WithField("expired", len(expired)).Info("lapsed loan offers expired")
	}
	return len(expired), len(expired) == batch, nil
}
