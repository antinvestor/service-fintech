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
// timer. Overlapping calls on any number of replicas reap once without a
// lock: every expiry is a conditional update on the row's status, and only
// the rows a pass actually transitioned are audited and announced.
//
// A session advisory lock taken through the connection pool used to guard
// each pass; its unlock could run on another pooled connection, leaving the
// lock held by an idle connection and every later pass skipped.
type LimitsJobs struct {
	reservations jobRunner
	approvals    jobRunner
}

// NewLimitsJobs wires the reapers.
func NewLimitsJobs(reservations, approvals jobRunner) *LimitsJobs {
	return &LimitsJobs{reservations: reservations, approvals: approvals}
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
		return j.reservations.Run(ctx)
	case limitsv1.LimitsJob_LIMITS_JOB_APPROVAL_EXPIRY:
		return j.approvals.Run(ctx)
	case limitsv1.LimitsJob_LIMITS_JOB_UNSPECIFIED:
	}
	return ErrUnknownJob
}
