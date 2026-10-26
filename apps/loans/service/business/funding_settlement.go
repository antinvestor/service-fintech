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
	"fmt"

	"buf.build/gen/go/antinvestor/funding/connectrpc/go/v2/funding/v1/fundingv1connect"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

// fundingLeaseSeconds is how long one settlement attempt holds a repayment
// before another run may take it over.
const fundingLeaseSeconds = 300

// FundingSettlement shares recorded repayments out to the loans' funders
// through the funding service. A repayment is attempted right after it is
// recorded; the scheduled job finishes whatever that attempt left.
type FundingSettlement struct {
	repaymentRepo   repository.RepaymentRepository
	loanAccountRepo repository.LoanAccountRepository
	fundingCli      fundingv1connect.FundingServiceClient
	commission      *AgentCommission
}

// WithCommission makes settlement credit the serving team's commission on
// each repayment's interest before sharing it out to the funders.
func (s *FundingSettlement) WithCommission(c *AgentCommission) *FundingSettlement {
	s.commission = c
	return s
}

// NewFundingSettlement builds the settlement step.
func NewFundingSettlement(
	repaymentRepo repository.RepaymentRepository,
	loanAccountRepo repository.LoanAccountRepository,
	fundingCli fundingv1connect.FundingServiceClient,
) *FundingSettlement {
	return &FundingSettlement{
		repaymentRepo:   repaymentRepo,
		loanAccountRepo: loanAccountRepo,
		fundingCli:      fundingCli,
	}
}

// Settle shares one repayment out and marks it settled once funding reports
// every ledger leg posted. A refusal that will never pass (the loan has no
// funding, the request is malformed) is recorded on the repayment and
// settled, so it is not retried for ever; anything else is left for the job.
func (s *FundingSettlement) Settle(ctx context.Context, la *models.LoanAccount, r *models.Repayment) error {
	if s == nil || s.fundingCli == nil {
		return errors.New("funding client is not configured")
	}
	if r.PrincipalApplied+r.InterestApplied <= 0 {
		return s.repaymentRepo.MarkFundingSettled(ctx, r.GetID(), "nothing to share")
	}

	if IsRecovery(r) || la.Status == int32(loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF) {
		return s.settleRecovery(ctx, la, r)
	}
	// The commission is keyed on the repayment, so a retried settlement
	// credits it once; until it posts the repayment stays unsettled.
	if commErr := s.commission.Post(ctx, la, r); commErr != nil {
		return commErr
	}

	resp, err := s.fundingCli.LoanRepaymentApply(ctx, &fundingv1.LoanRepaymentApplyRequest{
		LoanRequestId:      loanRequestIDFromProperties(la.Properties, la.LoanRequestID),
		LoanAccountId:      la.GetID(),
		ProductId:          la.ProductID,
		RepaymentReference: "repayment:" + r.GetID(),
		Principal:          moneyx.FromMinorUnitsByCurrency(r.CurrencyCode, r.PrincipalApplied),
		Interest:           moneyx.FromMinorUnitsByCurrency(r.CurrencyCode, r.InterestApplied),
	})
	if err != nil {
		if permanentFundingRefusal(err) {
			util.Log(ctx).WithError(err).WithField("repayment_id", r.GetID()).
				Error("funding refused the repayment share; recorded and not retried")
			return s.repaymentRepo.MarkFundingSettled(ctx, r.GetID(), "refused: "+err.Error())
		}
		return fmt.Errorf("share repayment %s with funders: %w", r.GetID(), err)
	}
	if !resp.GetSettled() {
		return fmt.Errorf("repayment %s shared but not yet posted", r.GetID())
	}
	return s.repaymentRepo.MarkFundingSettled(ctx, r.GetID(), "")
}

// settleRecovery hands principal recovered on a written-off loan back to the
// funders who absorbed its loss. Interest and fees recovered are the
// lender's: the funders' share of them was never owed once the loan was
// written off.
func (s *FundingSettlement) settleRecovery(ctx context.Context, la *models.LoanAccount, r *models.Repayment) error {
	if r.PrincipalApplied <= 0 {
		return s.repaymentRepo.MarkFundingSettled(ctx, r.GetID(), "recovery without principal")
	}
	resp, err := s.fundingCli.LoanRecoveryApply(ctx, &fundingv1.LoanRecoveryApplyRequest{
		LoanRequestId:     loanRequestIDFromProperties(la.Properties, la.LoanRequestID),
		ProductId:         la.ProductID,
		RecoveryReference: "recovery:" + r.GetID(),
		Principal:         moneyx.FromMinorUnitsByCurrency(r.CurrencyCode, r.PrincipalApplied),
	})
	if err != nil {
		if permanentFundingRefusal(err) {
			util.Log(ctx).WithError(err).WithField("repayment_id", r.GetID()).
				Error("funding refused the recovery; recorded and not retried")
			return s.repaymentRepo.MarkFundingSettled(ctx, r.GetID(), "refused: "+err.Error())
		}
		return fmt.Errorf("return recovery %s to funders: %w", r.GetID(), err)
	}
	if !resp.GetSettled() {
		return fmt.Errorf("recovery %s returned but not yet posted", r.GetID())
	}
	return s.repaymentRepo.MarkFundingSettled(ctx, r.GetID(), "")
}

// RunBatch claims up to batch unsettled repayments and settles each. It
// reports how many it worked through and whether the batch was full.
func (s *FundingSettlement) RunBatch(ctx context.Context, batch int) (int, bool, error) {
	rows, err := s.repaymentRepo.ClaimFundingUnsettled(ctx, batch, fundingLeaseSeconds)
	if err != nil {
		return 0, false, fmt.Errorf("claim unsettled repayments: %w", err)
	}
	logger := util.Log(ctx).WithField("job", "funding_settlement")
	for _, r := range rows {
		if ctx.Err() != nil {
			return 0, true, ctx.Err()
		}
		la, laErr := s.loanAccountRepo.GetByID(ctx, r.LoanAccountID)
		if laErr != nil {
			logger.WithError(laErr).WithField("repayment_id", r.GetID()).Warn("loan of repayment not found")
			continue
		}
		if settleErr := s.Settle(ctx, la, r); settleErr != nil {
			logger.WithError(settleErr).WithField("repayment_id", r.GetID()).
				Warn("repayment not yet settled with funders; a later run retries")
		}
	}
	return len(rows), len(rows) == batch, nil
}

// permanentFundingRefusal reports whether funding refused the request in a
// way a retry cannot change.
func permanentFundingRefusal(err error) bool {
	code := connect.CodeOf(err)
	return code == connect.CodeInvalidArgument || code == connect.CodeFailedPrecondition ||
		code == connect.CodeNotFound
}
