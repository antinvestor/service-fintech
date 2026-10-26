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
	"errors"
	"time"

	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/tenancy"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	stawiv1 "github.com/antinvestor/service-fintech/gen/go/stawi/protocolbuffers/go/stawi/v1"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/notify"
	stawiproduct "github.com/antinvestor/service-fintech/products/stawi"
)

const (
	// jobRetryAfter is how long an item whose step failed waits before a
	// run tries it again, so it never blocks the rest.
	jobRetryAfter = 10 * time.Minute
	// groupCheckInterval is how often a running group's state in identity
	// is compared with its tenure.
	groupCheckInterval = time.Hour

	notifyKindGroup = "group"
)

var (
	// ErrUnknownJob is returned for a job the service does not run.
	ErrUnknownJob = apperrors.NewError(apperrors.BadRequest, "unknown stawi job")
	// ErrJobCallerNotInternal is returned when anyone but an internal
	// service account asks to run a job.
	ErrJobCallerNotInternal = apperrors.NewError(apperrors.Forbidden,
		"stawi jobs are run only by internal services")
)

// PartitionActor is the context a job works on one item in: this service
// acting inside the item's own partition.
type PartitionActor func(ctx context.Context, item *data.BaseModel) context.Context

// GroupSetup is the part of the group business a group's setup runs.
type GroupSetup interface {
	SetupLedgerAccounts(ctx context.Context, groupID string) error
	RegisterWithLender(ctx context.Context, groupID string) error
}

// JobDeps are the collaborators of the scheduled jobs.
type JobDeps struct {
	Product    stawiproduct.ProductConfig
	Directory  GroupDirectory
	Groups     GroupSetup
	Members    MemberLister
	Tenures    repository.TenureRepository
	Periods    repository.PeriodRepository
	Tenure     TenureBusiness
	Period     PeriodBusiness
	Obligation GroupObligationBusiness
	LoanWindow LoanWindowBusiness
	LoanOffers LoanOfferBusiness
	Notices    repository.NoticeRepository
	Notifier   *notify.Notifier
	// Subject is this service's own identity, under which each item is
	// worked inside its partition.
	Subject string
}

// StawiJobs runs stawi's periodic work, one bounded batch per call. The
// platform scheduler (trustage) calls it; nothing in the service runs on a
// timer. Every step is idempotent, so a retried or overlapping run never
// charges, opens or notifies twice.
type StawiJobs struct {
	JobDeps

	reminders []time.Duration
	now       func() time.Time
}

// NewStawiJobs wires the jobs.
func NewStawiJobs(deps JobDeps) *StawiJobs {
	return &StawiJobs{JobDeps: deps, reminders: deps.Product.ReminderOffsets(), now: time.Now}
}

// Run runs one batch of job and reports how many items it handled and
// whether more may be waiting. Only an internal service account may run it:
// the batch reads across every tenant, then works on each item inside its
// own partition.
func (j *StawiJobs) Run(ctx context.Context, job stawiv1.StawiJob, batch int) (int, bool, error) {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil || !claims.IsInternalSystem() {
		return 0, false, ErrJobCallerNotInternal
	}
	// Batches are bounded like the offer sweeps', so a run finishes in one
	// request whatever the backlog.
	batch = sweepBatch(batch)
	switch job {
	case stawiv1.StawiJob_STAWI_JOB_GROUP_LIFECYCLE:
		return j.groupLifecycle(ctx, batch)
	case stawiv1.StawiJob_STAWI_JOB_CLOSE_DUE_PERIODS:
		return j.closeDuePeriods(ctx, batch)
	case stawiv1.StawiJob_STAWI_JOB_SEND_REMINDERS:
		return j.sendReminders(ctx, batch)
	case stawiv1.StawiJob_STAWI_JOB_LOAN_OFFERS:
		return j.loanOffers(ctx, batch)
	case stawiv1.StawiJob_STAWI_JOB_UNSPECIFIED:
	}
	return 0, false, ErrUnknownJob
}

// loanOffers finishes accepted offers, closes expired ones and retries the
// cancels of failed offers' loans. Offers whose step failed are held off
// for a while, so a batch of them cannot keep a run looping.
func (j *StawiJobs) loanOffers(ctx context.Context, batch int) (int, bool, error) {
	resumed, err := j.LoanOffers.ResumePendingOrigination(ctx, batch, j.actIn)
	if err != nil {
		return 0, false, err
	}
	expired, err := j.LoanOffers.ExpireStale(ctx, j.now().UTC(), batch, j.actIn)
	if err != nil {
		return resumed.Scanned, false, err
	}
	cancels, err := j.LoanOffers.RetryLoanCancels(ctx, j.now().UTC(), batch, j.actIn)
	if err != nil {
		return resumed.Scanned + expired, false, err
	}
	more := (resumed.Scanned == batch && resumed.Disbursed+resumed.Failed > 0) ||
		expired == batch ||
		(cancels.Scanned == batch && cancels.Cancelled > 0)
	return resumed.Scanned + expired + cancels.Scanned, more, nil
}

// actIn is ctx as this service acting inside the item's partition.
func (j *StawiJobs) actIn(ctx context.Context, item *data.BaseModel) context.Context {
	return j.actInPartition(ctx, item.TenantID, item.PartitionID)
}

func (j *StawiJobs) actInPartition(ctx context.Context, tenantID, partitionID string) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:    tenantID,
		PartitionID: partitionID,
		Roles:       []string{security.ConstantSystemInternalRole},
	}
	claims.Subject = j.Subject
	return claims.ClaimsToContext(ctx, security.WithoutInternalTenancySkip())
}

// listCtx reads across every tenant.
func listCtx(ctx context.Context) context.Context {
	return security.SkipTenancyChecksOnClaims(ctx)
}

// jobTenant is the tenant the scheduler named for this run.
func jobTenant(ctx context.Context) string {
	if claims := tenancy.ClaimsFromContext(ctx); claims != nil {
		return claims.TenantID
	}
	return ""
}

// sendOnce sends msg unless a notice under key was already sent. The key is
// claimed first, so a retried run skips it; a send that fails releases the
// claim, so a later run sends it.
func (j *StawiJobs) sendOnce(ctx context.Context, key, groupID string, msg notify.Message) error {
	if msg.Recipient == nil {
		util.Log(ctx).WithField("notice", key).Warn("no profile to notify")
		return nil
	}
	msg.Kind = notifyKindGroup
	msg.Priority = notificationv1.PRIORITY_HIGH
	claimed, err := j.Notices.Claim(ctx, &models.Notice{
		Key: key, GroupID: groupID, ProfileID: msg.Recipient.GetProfileId(), Template: msg.Template,
	})
	if err != nil || !claimed {
		return err
	}
	sendErr := j.Notifier.Send(ctx, msg)
	switch {
	case sendErr == nil:
		return nil
	case errors.Is(sendErr, notify.ErrDisabled):
		// Nothing will ever send in this deployment; holding the work back
		// for it would stall the group.
		util.Log(ctx).WithField("notice", key).Warn("notification not sent: notifications are disabled")
		return nil
	}
	if relErr := j.Notices.Release(ctx, key); relErr != nil {
		util.Log(ctx).WithError(relErr).WithField("notice", key).Error("could not release an unsent notice")
	}
	return sendErr
}

// retryAt is when an item whose step just failed is next tried.
func (j *StawiJobs) retryAt() *time.Time {
	at := j.now().UTC().Add(jobRetryAfter)
	return &at
}
