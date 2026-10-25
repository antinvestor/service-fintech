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

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/require"
)

// Jobs drop the caller's tenancy scope, so only an internal service account
// may run them: a staff user, a member or an anonymous call is refused before
// any work is claimed.
func TestLoanJobsRefuseCallersThatAreNotInternal(t *testing.T) {
	jobs := NewLoanJobs(nil, nil, nil, &stubLoanRequestRepo{}, nil)
	for name, ctx := range map[string]context.Context{
		"no claims": context.Background(),
		"staff user": (&security.AuthenticationClaims{
			Roles: []string{"admin"}, RegisteredClaims: jwt.RegisteredClaims{Subject: "p1"},
		}).ClaimsToContext(context.Background()),
	} {
		t.Run(name, func(t *testing.T) {
			_, _, err := jobs.Run(ctx, loansv1.LoanJob_LOAN_JOB_REQUEST_EXPIRY, 10)
			require.ErrorIs(t, err, ErrJobCallerNotInternal)
		})
	}

	internal := (&security.AuthenticationClaims{
		Roles: []string{security.ConstantSystemInternalRole}, RegisteredClaims: jwt.RegisteredClaims{Subject: "trustage"},
	}).ClaimsToContext(context.Background())
	processed, more, err := jobs.Run(internal, loansv1.LoanJob_LOAN_JOB_REQUEST_EXPIRY, 10)
	require.NoError(t, err)
	require.Zero(t, processed)
	require.False(t, more)
}
