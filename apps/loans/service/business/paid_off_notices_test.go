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
	"testing"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
)

// unnoticedLoans hands out paid-off loans whose notice never got through
// and records which ones were acknowledged.
type unnoticedLoans struct {
	stubLoanAccountRepo

	unnoticed []*loansmodels.LoanAccount
	noticed   []string
}

func (r *unnoticedLoans) ClaimPaidOffUnnoticed(_ context.Context, limit int) ([]*loansmodels.LoanAccount, error) {
	var out []*loansmodels.LoanAccount
	for _, la := range r.unnoticed {
		if len(out) < limit && !contains(r.noticed, la.GetID()) {
			out = append(out, la)
		}
	}
	return out, nil
}

func (r *unnoticedLoans) MarkPaidOffNoticed(_ context.Context, id string) error {
	r.noticed = append(r.noticed, id)
	return nil
}

func contains(ids []string, id string) bool {
	for _, v := range ids {
		if v == id {
			return true
		}
	}
	return false
}

// flakyPaidOffHook fails until told to succeed, recording each call's
// partition.
type flakyPaidOffHook struct {
	failing    bool
	calls      []string
	partitions []string
}

func (h *flakyPaidOffHook) HandlePaidOff(ctx context.Context, loanAccountID string, _ int64) error {
	h.calls = append(h.calls, loanAccountID)
	if claims := security.ClaimsFromContext(ctx); claims != nil {
		h.partitions = append(h.partitions, claims.GetPartitionID())
	}
	if h.failing {
		return errors.New("seed unavailable")
	}
	return nil
}

func paidOffLoan(id string) *loansmodels.LoanAccount {
	la := &loansmodels.LoanAccount{Status: int32(loansv1.LoanStatus_LOAN_STATUS_PAID_OFF)}
	la.ID = id
	la.TenantID = "tenant-1"
	la.PartitionID = "partition-1"
	return la
}

func TestPaidOffNoticeThatFailedIsRetriedUntilAcknowledged(t *testing.T) {
	loans := &unnoticedLoans{unnoticed: []*loansmodels.LoanAccount{paidOffLoan("loan-1")}}
	hook := &flakyPaidOffHook{failing: true}
	notices := NewPaidOffNotices(loans, &stubLoanBalanceRepo{}, hook, "service_loans")

	// The repayment's own notice fails: nothing is recorded.
	require.Error(t, notices.Notify(context.Background(), loans.unnoticed[0], 1000))
	assert.Empty(t, loans.noticed)

	// The job retries it once seed is back, inside the loan's partition.
	hook.failing = false
	jobs := NewLoanJobs(nil, nil, nil, &stubLoanRequestRepo{}, nil, notices)
	processed, more, err := jobs.Run(internalJobContext(), loansv1.LoanJob_LOAN_JOB_PAID_OFF_NOTICES, 10)
	require.NoError(t, err)
	assert.Equal(t, 1, processed)
	assert.False(t, more)
	assert.Equal(t, []string{"loan-1"}, loans.noticed)
	assert.Equal(t, "partition-1", hook.partitions[len(hook.partitions)-1])

	// Acknowledged: the next run has nothing to do.
	processed, _, err = jobs.Run(internalJobContext(), loansv1.LoanJob_LOAN_JOB_PAID_OFF_NOTICES, 10)
	require.NoError(t, err)
	assert.Zero(t, processed)
}

func TestPaidOffNoticesWithoutADownstreamProductDoNothing(t *testing.T) {
	notices := NewPaidOffNotices(&unnoticedLoans{}, &stubLoanBalanceRepo{}, nil, "service_loans")
	processed, more, err := notices.RunBatch(context.Background(), 10)
	require.NoError(t, err)
	assert.Zero(t, processed)
	assert.False(t, more)
}

func internalJobContext() context.Context {
	return (&security.AuthenticationClaims{
		Roles: []string{security.ConstantSystemInternalRole},
	}).ClaimsToContext(context.Background())
}
