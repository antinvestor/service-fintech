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

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/security"
)

var (
	// ErrUnknownJob is returned for a job the service does not run.
	ErrUnknownJob = errors.New("unknown limits job")
	// ErrJobCallerNotInternal is returned when anyone but an internal
	// service account asks to run a job.
	ErrJobCallerNotInternal = errors.New("limits jobs are run only by internal services")
)

// jobRunner is one pass of a reaper.
type jobRunner interface {
	Run(ctx context.Context) error
}

// LimitsJobs runs the limits service's periodic work, one pass per call. The
// platform scheduler (trustage) calls it; nothing in the service runs on a
// timer. Each pass holds a Postgres advisory lock, so overlapping calls on
// any number of replicas reap once.
type LimitsJobs struct {
	reservations jobRunner
	approvals    jobRunner
	pool         pool.Pool
}

// NewLimitsJobs wires the reapers. p may be nil in tests, in which case a
// pass runs without the leader lock.
func NewLimitsJobs(reservations, approvals jobRunner, p pool.Pool) *LimitsJobs {
	return &LimitsJobs{reservations: reservations, approvals: approvals, pool: p}
}

// Run runs one pass of job. Reapers work across every tenant, so the pass
// runs without the caller's tenancy scope; only an internal service account
// may ask for it.
func (j *LimitsJobs) Run(ctx context.Context, job limitsv1.LimitsJob) error {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil || !claims.IsInternalSystem() {
		return ErrJobCallerNotInternal
	}
	ctx = security.SkipTenancyChecksOnClaims(ctx)
	switch job {
	case limitsv1.LimitsJob_LIMITS_JOB_RESERVATION_EXPIRY:
		return WithLeaderLock(ctx, j.pool, LockKeyReservationReaper, j.reservations.Run)
	case limitsv1.LimitsJob_LIMITS_JOB_APPROVAL_EXPIRY:
		return WithLeaderLock(ctx, j.pool, LockKeyApprovalReaper, j.approvals.Run)
	case limitsv1.LimitsJob_LIMITS_JOB_UNSPECIFIED:
	}
	return ErrUnknownJob
}
