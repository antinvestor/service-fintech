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
	"time"

	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

// partitionOf is the partition ctx acts in.
func partitionOf(ctx context.Context) string {
	if claims := security.ClaimsFromContext(ctx); claims != nil {
		return claims.GetPartitionID()
	}
	return ""
}

// tenantLoan is an active loan living in another tenant's partition than
// the scheduler that runs the jobs.
func tenantLoan() *loansmodels.LoanAccount {
	la := &loansmodels.LoanAccount{Status: int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE),
		ProductID: "prod-1", CurrencyCode: "KES"}
	la.ID = "loan-t"
	la.TenantID = "tenant-borrower"
	la.PartitionID = "partition-borrower"
	return la
}

type assessedLoans struct {
	stubLoanAccountRepo
	due []*loansmodels.LoanAccount
}

func (r *assessedLoans) ClaimForAssessment(context.Context, int) ([]*loansmodels.LoanAccount, error) {
	out := r.due
	r.due = nil
	return out, nil
}

type overdueEntries struct{ stubScheduleEntryRepo }

func (r *overdueEntries) GetOverdueEntries(
	_ context.Context,
	loanID string,
	now time.Time,
) ([]*loansmodels.ScheduleEntry, error) {
	due := now.AddDate(0, 0, -2)
	entry := &loansmodels.ScheduleEntry{LoanAccountID: loanID, DueDate: &due, Outstanding: 10_000}
	entry.ID = "entry-1"
	return []*loansmodels.ScheduleEntry{entry}, nil
}

type penaltyProducts struct {
	repository.LoanProductRepository
}

func (penaltyProducts) GetByID(_ context.Context, id string) (*loansmodels.LoanProduct, error) {
	lp := &loansmodels.LoanProduct{LatePenaltyRate: 500}
	lp.ID = id
	return lp, nil
}

// recordingPenalties records the partition each penalty was raised in.
type recordingPenalties struct {
	PenaltyBusiness
	partitions []string
}

func (p *recordingPenalties) Save(ctx context.Context, obj *loansv1.PenaltyObject) (*loansv1.PenaltyObject, error) {
	p.partitions = append(p.partitions, partitionOf(ctx))
	return obj, nil
}

// A late penalty raised by the scheduled scan is raised inside the loan's
// partition, not the scheduler's, so the penalty row belongs to the loan.
func TestDelinquencyScanActsInTheLoansPartition(t *testing.T) {
	penalties := &recordingPenalties{}
	scanner := NewDelinquencyScanner(&assessedLoans{due: []*loansmodels.LoanAccount{tenantLoan()}},
		&overdueEntries{}, penalties, nil, penaltyProducts{}, 7, 90, WithScannerSubject("service_loans"))
	jobs := NewLoanJobs(scanner, nil, nil, &stubLoanRequestRepo{}, nil, nil)

	processed, _, err := jobs.Run(internalJobContext(), loansv1.LoanJob_LOAN_JOB_DELINQUENCY_SCAN, 10)
	require.NoError(t, err)
	require.Equal(t, 1, processed)
	assert.Equal(t, []string{"partition-borrower"}, penalties.partitions)
}

type unsettledRepayments struct{ stubRepaymentRepo }

func (r *unsettledRepayments) ClaimFundingUnsettled(context.Context, int, int) ([]*loansmodels.Repayment, error) {
	rep := &loansmodels.Repayment{LoanAccountID: "loan-t", CurrencyCode: "KES", PrincipalApplied: 1_000}
	rep.ID = "rep-t"
	return []*loansmodels.Repayment{rep}, nil
}

type partitionFunding struct {
	recoveryFunding
	partitions []string
}

func (f *partitionFunding) LoanRepaymentApply(
	ctx context.Context,
	req *fundingv1.LoanRepaymentApplyRequest,
) (*fundingv1.LoanRepaymentApplyResponse, error) {
	f.partitions = append(f.partitions, partitionOf(ctx))
	return f.recoveryFunding.LoanRepaymentApply(ctx, req)
}

// The settlement job shares each repayment out inside its loan's partition.
func TestFundingSettlementJobActsInTheLoansPartition(t *testing.T) {
	funding := &partitionFunding{}
	settlement := NewFundingSettlement(&unsettledRepayments{}, &stubLoanAccountRepo{account: tenantLoan()}, funding).
		WithSubject("service_loans")

	_, _, err := settlement.RunBatch(security.SkipTenancyChecksOnClaims(internalJobContext()), 10)
	require.NoError(t, err)
	assert.Equal(t, []string{"partition-borrower"}, funding.partitions)
}

type schedulingLoans struct {
	assessedLoans
	scheduled []string
}

func (r *schedulingLoans) ScheduleNextAssessment(_ context.Context, id string, _ time.Time) error {
	r.scheduled = append(r.scheduled, id)
	return nil
}

// A scan out of time stops and reports more; the loans it did not assess are
// not scheduled a day ahead, so they are due again once their claim lapses.
// An assessed loan is.
func TestDelinquencyScanStopsAtItsTimeBudget(t *testing.T) {
	claimed := func() []*loansmodels.LoanAccount {
		la := tenantLoan()
		lease := time.Now().Add(15 * time.Minute)
		la.NextAssessmentAt = &lease
		return []*loansmodels.LoanAccount{la}
	}
	repo := &schedulingLoans{assessedLoans: assessedLoans{due: claimed()}}
	scanner := NewDelinquencyScanner(repo, &overdueEntries{}, &recordingPenalties{}, nil, penaltyProducts{}, 7, 90)
	scanner.timeBudget = -time.Second

	processed, more, err := scanner.RunBatch(internalJobContext(), 10)
	require.NoError(t, err)
	assert.Zero(t, processed)
	assert.True(t, more)
	assert.Empty(t, repo.scheduled)

	repo.due = claimed()
	scanner.timeBudget = time.Minute
	processed, _, err = scanner.RunBatch(internalJobContext(), 10)
	require.NoError(t, err)
	assert.Equal(t, 1, processed)
	assert.Equal(t, []string{"loan-t"}, repo.scheduled)
}

func TestLoanJobBatchIsBounded(t *testing.T) {
	jobs := NewLoanJobs(nil, nil, nil, &stubLoanRequestRepo{}, nil, nil)
	_, _, err := jobs.Run(internalJobContext(), loansv1.LoanJob_LOAN_JOB_DELINQUENCY_SCAN, 5001)
	require.ErrorIs(t, err, ErrJobBatchSizeInvalid)
}
