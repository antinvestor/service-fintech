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
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	moneyx "github.com/pitabwire/util/moneyx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	loansmodels "github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

// memRepaymentRepo keeps the repayments it is given, so a recorded but
// unapplied repayment is there for the next call to find.
type memRepaymentRepo struct {
	stubRepaymentRepo
	rows []*loansmodels.Repayment
}

func (r *memRepaymentRepo) GetByIdempotencyKey(_ context.Context, key string) (*loansmodels.Repayment, error) {
	for _, row := range r.rows {
		if row.IdempotencyKey == key {
			return row, nil
		}
	}
	return nil, errors.New("not found")
}

func (r *memRepaymentRepo) ClaimIdempotencyKey(
	ctx context.Context,
	rep *loansmodels.Repayment,
) (*loansmodels.Repayment, bool, error) {
	if existing, err := r.GetByIdempotencyKey(ctx, rep.IdempotencyKey); err == nil {
		return existing, false, nil
	}
	r.rows = append(r.rows, rep)
	return rep, true, nil
}

func (r *memRepaymentRepo) ListUnapplied(_ context.Context, loanID string, _ int) ([]*loansmodels.Repayment, error) {
	var out []*loansmodels.Repayment
	for _, row := range r.rows {
		if row.LoanAccountID == loanID && row.AppliedAt == nil {
			out = append(out, row)
		}
	}
	return out, nil
}

// memLoanBalanceRepo holds one loan's balance and moves it as repayments
// apply, so an allocation sees what earlier repayments left outstanding.
type memLoanBalanceRepo struct {
	stubLoanBalanceRepo
	principal int64
}

func (r *memLoanBalanceRepo) GetByLoanAccountID(_ context.Context, id string) (*loansmodels.LoanBalance, error) {
	return &loansmodels.LoanBalance{LoanAccountID: id, CurrencyCode: "KES",
		PrincipalOutstanding: r.principal, TotalOutstanding: r.principal}, nil
}

func (r *memLoanBalanceRepo) ApplyRepaymentDelta(
	ctx context.Context,
	id string,
	delta repository.LoanBalanceDelta,
) (*loansmodels.LoanBalance, error) {
	r.principal -= delta.PrincipalApplied
	return r.GetByLoanAccountID(ctx, id)
}

// A repayment recorded but stopped before it applied is finished before the
// next repayment on the loan is allocated, so the two never claim the same
// principal.
func TestRecord_FinishesUnappliedRepaymentBeforeAllocating(t *testing.T) {
	la := activeLoanAccountForRepayment()
	repRepo := &memRepaymentRepo{}
	opsCli := &stubOperationsClient{transferErr: errors.New("ledger down")}
	b := buildRepBusiness(&stubLoanAccountRepo{account: la}, repRepo, opsCli)
	b.loanBalanceRepo = &memLoanBalanceRepo{principal: 10_000}

	_, err := b.Record(paymentRailContext(), &loansv1.RepaymentRecordRequest{
		LoanAccountId: la.GetID(), IdempotencyKey: "first", Amount: moneyx.FromMinorUnitsByCurrency("KES", 8_000),
	})
	require.Error(t, err, "the ledger is down, so the first repayment stays unapplied")
	require.Len(t, repRepo.rows, 1)
	require.Nil(t, repRepo.rows[0].AppliedAt)

	opsCli.transferErr = nil
	opsCli.transferResp = &operationsv1.TransferOrderExecuteResponse{Data: &operationsv1.TransferOrderObject{Id: "t"}}
	second, err := b.Record(paymentRailContext(), &loansv1.RepaymentRecordRequest{
		LoanAccountId: la.GetID(), IdempotencyKey: "second", Amount: moneyx.FromMinorUnitsByCurrency("KES", 8_000),
	})
	require.NoError(t, err)

	require.NotNil(t, repRepo.rows[0].AppliedAt, "the earlier repayment is finished first")
	assert.EqualValues(t, 8_000, repRepo.rows[0].PrincipalApplied)
	// Only 2,000 of principal was left once the first applied; the rest of
	// the second payment is excess, not principal a second time.
	assert.EqualValues(t, 2_000, repRepo.rows[1].PrincipalApplied)
	assert.EqualValues(t, 6_000, repRepo.rows[1].ExcessAmount)
	assert.Equal(t, loansv1.RepaymentStatus_REPAYMENT_STATUS_OVERPAYMENT, second.GetStatus())
}

// While an earlier repayment cannot be finished, a new one is refused rather
// than allocated against installments the earlier one already claimed.
func TestRecord_RefusesWhileAnEarlierRepaymentIsUnfinished(t *testing.T) {
	la := activeLoanAccountForRepayment()
	repRepo := &memRepaymentRepo{}
	opsCli := &stubOperationsClient{transferErr: errors.New("ledger down")}
	b := buildRepBusiness(&stubLoanAccountRepo{account: la}, repRepo, opsCli)
	b.loanBalanceRepo = &memLoanBalanceRepo{principal: 10_000}

	_, err := b.Record(paymentRailContext(), &loansv1.RepaymentRecordRequest{
		LoanAccountId: la.GetID(), IdempotencyKey: "first", Amount: moneyx.FromMinorUnitsByCurrency("KES", 8_000),
	})
	require.Error(t, err)

	_, err = b.Record(paymentRailContext(), &loansv1.RepaymentRecordRequest{
		LoanAccountId: la.GetID(), IdempotencyKey: "second", Amount: moneyx.FromMinorUnitsByCurrency("KES", 8_000),
	})
	require.ErrorIs(t, err, ErrRepaymentInProgress)
	assert.Len(t, repRepo.rows, 1, "no second allocation is recorded")
}
