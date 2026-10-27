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

package business_test

import (
	"context"
	"testing"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
)

type countingReaper struct{ runs int }

func (r *countingReaper) Run(context.Context) error {
	r.runs++
	return nil
}

func TestLimitsJobsRunTheNamedReaperForInternalCallersOnly(t *testing.T) {
	resv, approvals := &countingReaper{}, &countingReaper{}
	jobs := business.NewLimitsJobs(resv, approvals, nil)

	internal := (&security.AuthenticationClaims{
		Roles: []string{security.ConstantSystemInternalRole},
	}).ClaimsToContext(context.Background())
	require.NoError(t, jobs.Run(internal, limitsv1.LimitsJob_LIMITS_JOB_RESERVATION_EXPIRY))
	require.NoError(t, jobs.Run(internal, limitsv1.LimitsJob_LIMITS_JOB_APPROVAL_EXPIRY))
	assert.Equal(t, 1, resv.runs)
	assert.Equal(t, 1, approvals.runs)

	require.ErrorIs(t, jobs.Run(internal, limitsv1.LimitsJob_LIMITS_JOB_UNSPECIFIED), business.ErrUnknownJob)

	staff := (&security.AuthenticationClaims{Roles: []string{"admin"}}).ClaimsToContext(context.Background())
	require.ErrorIs(t, jobs.Run(staff, limitsv1.LimitsJob_LIMITS_JOB_RESERVATION_EXPIRY),
		business.ErrJobCallerNotInternal)
	assert.Equal(t, 1, resv.runs, "nothing ran for a person")
}
