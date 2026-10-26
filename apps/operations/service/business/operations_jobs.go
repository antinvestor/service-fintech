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

	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

const (
	// defaultJobBatch is how many items one run handles when the caller
	// does not say.
	defaultJobBatch = 200
	// settleAfter leaves a payment or order alone for this long after its
	// last change, so the run that raised it can finish first.
	settleAfter = 2 * time.Minute
)

var (
	// ErrUnknownJob is returned for a job the service does not run.
	ErrUnknownJob = apperrors.NewError(apperrors.BadRequest, "unknown operations job")
	// ErrJobCallerNotInternal is returned when anyone but an internal
	// service account asks to run a job.
	ErrJobCallerNotInternal = apperrors.NewError(apperrors.Forbidden,
		"operations jobs are run only by internal services")
)

// OperationsJobs runs the operations service's periodic work, one bounded
// batch per call. The platform scheduler (trustage) calls it; nothing in the
// service runs on a timer. Allocation and execution each claim their row, so
// any number of runs may overlap on any number of replicas.
type OperationsJobs struct {
	routing  PaymentRoutingBusiness
	executor OrderExecutor
	ipRepo   repository.IncomingPaymentRepository
	toRepo   repository.TransferOrderRepository
	payouts  PayoutReconciler
	subject  string
}

// NewOperationsJobs wires the jobs. subject is this service's own identity,
// under which each item is processed inside its partition.
func NewOperationsJobs(
	routing PaymentRoutingBusiness,
	executor OrderExecutor,
	ipRepo repository.IncomingPaymentRepository,
	toRepo repository.TransferOrderRepository,
	subject string,
) *OperationsJobs {
	return &OperationsJobs{routing: routing, executor: executor, ipRepo: ipRepo, toRepo: toRepo, subject: subject}
}

// WithPayoutReconciler lets the jobs settle how payouts ended.
func (j *OperationsJobs) WithPayoutReconciler(r PayoutReconciler) *OperationsJobs {
	j.payouts = r
	return j
}

// Run runs one batch of job. Only an internal service account may run it:
// the batch reads across every tenant, then acts on each item inside its
// own partition.
func (j *OperationsJobs) Run(ctx context.Context, job operationsv1.OperationsJob, batch int) (int, bool, error) {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil || !claims.IsInternalSystem() {
		return 0, false, ErrJobCallerNotInternal
	}
	if batch <= 0 {
		batch = defaultJobBatch
	}
	switch job {
	case operationsv1.OperationsJob_OPERATIONS_JOB_SETTLE_PAYMENTS:
		return j.settlePayments(ctx, batch)
	case operationsv1.OperationsJob_OPERATIONS_JOB_RECONCILE_PAYOUTS:
		return j.reconcilePayouts(ctx, batch)
	case operationsv1.OperationsJob_OPERATIONS_JOB_UNSPECIFIED:
	}
	return 0, false, ErrUnknownJob
}

// settlePayments finishes what an individual's payment left undone: it
// allocates payments matched to a loan or savings account whose allocation
// did not complete, then posts borrower repayment orders that were raised
// but never executed. A failure on one item is logged and left for the next
// run; the batch goes on.
func (j *OperationsJobs) settlePayments(ctx context.Context, batch int) (int, bool, error) {
	before := time.Now().UTC().Add(-settleAfter)
	listCtx := security.SkipTenancyChecksOnClaims(ctx)

	leaseStaleBefore := time.Now().UTC().Add(-allocationLeaseStaleAfter)
	payments, err := j.ipRepo.ListAwaitingAllocation(listCtx, before, leaseStaleBefore, batch)
	if err != nil {
		return 0, false, fmt.Errorf("payments awaiting allocation: %w", err)
	}
	for _, p := range payments {
		if _, allocErr := j.routing.AllocatePayment(j.actIn(ctx, &p.BaseModel), p.GetID()); allocErr != nil {
			util.Log(ctx).WithError(allocErr).WithField(fieldPaymentID, p.GetID()).
				Warn("settle: payment allocation failed; next run retries")
		}
	}

	orders, err := j.toRepo.ListUnexecutedBorrowerRepayments(listCtx, before, batch)
	if err != nil {
		return len(payments), false, fmt.Errorf("borrower repayments awaiting execution: %w", err)
	}
	for _, o := range orders {
		if execErr := j.executor.Execute(j.actIn(ctx, &o.BaseModel), o.GetID()); execErr != nil {
			util.Log(ctx).WithError(execErr).WithField("transfer_order_id", o.GetID()).
				Warn("settle: repayment order execution failed; next run retries")
		}
	}

	processed := len(payments) + len(orders)
	if processed > 0 {
		util.Log(ctx).WithField("payments", len(payments)).WithField("orders", len(orders)).
			Info("settled individual payments")
	}
	return processed, len(payments) == batch || len(orders) == batch, nil
}

// reconcilePayouts asks how payouts the rail accepted ended, oldest checked
// first, then tells the originators of payouts the rail failed afterwards.
// A failure on one item is logged and left for the next run.
func (j *OperationsJobs) reconcilePayouts(ctx context.Context, batch int) (int, bool, error) {
	if j.payouts == nil {
		return 0, false, ErrUnknownJob
	}
	listCtx := security.SkipTenancyChecksOnClaims(ctx)
	before := time.Now().UTC().Add(-settleAfter)

	orders, err := j.toRepo.ListPayoutsToReconcile(listCtx, payoutOrderTypes(), before, batch)
	if err != nil {
		return 0, false, fmt.Errorf("payouts to reconcile: %w", err)
	}
	for _, o := range orders {
		if recErr := j.payouts.ReconcilePayout(j.actIn(ctx, &o.BaseModel), o.GetID()); recErr != nil {
			util.Log(ctx).WithError(recErr).WithField("transfer_order_id", o.GetID()).
				Warn("reconcile: payout outcome not settled; next run retries")
		}
	}

	failed, err := j.toRepo.ListLateFailedPayouts(listCtx, batch)
	if err != nil {
		return len(orders), false, fmt.Errorf("late-failed payouts to report: %w", err)
	}
	for _, o := range failed {
		if notifyErr := j.payouts.NotifyOriginator(j.actIn(ctx, &o.BaseModel), o); notifyErr != nil {
			util.Log(ctx).WithError(notifyErr).WithField("transfer_order_id", o.GetID()).
				Warn("reconcile: originator not told of a failed payout; next run retries")
		}
	}
	return len(orders) + len(failed), len(orders) == batch || len(failed) == batch, nil
}

// actIn is ctx as this service acting inside the item's partition.
func (j *OperationsJobs) actIn(ctx context.Context, item *data.BaseModel) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:    item.TenantID,
		PartitionID: item.PartitionID,
		Roles:       []string{security.ConstantSystemInternalRole},
	}
	claims.Subject = j.subject
	return claims.ClaimsToContext(ctx, security.WithoutInternalTenancySkip())
}
