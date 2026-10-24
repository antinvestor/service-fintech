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
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/util/decimalx"
	"github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/calculation"
)

// CheckEligibility answers whether a member may be offered a loan at all. A
// member qualifies when their membership is active and of the regular member
// type, and their accumulated savings price a non-zero loan under the
// product's leverage band.
func (b *loanOfferBusiness) CheckEligibility(
	ctx context.Context,
	groupID, membershipID string,
) (map[string]interface{}, error) {
	membershipID = strings.TrimSpace(membershipID)
	if membershipID == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "a member id is required")
	}
	if b.identityCli == nil {
		return nil, apperrors.NewError(apperrors.ServiceUnavailable,
			"identity service is required to check loan eligibility")
	}

	memResp, err := b.identityCli.MembershipGet(ctx, &identityv1.MembershipGetRequest{Id: membershipID})
	if err != nil {
		return nil, apperrors.ErrDataNotFound.Extend("membership")
	}
	membership := memResp.GetData()

	if membership.GetState() != commonv1.STATE_ACTIVE {
		return ineligible(membershipID, "the membership is not active"), nil
	}
	if membership.GetMembershipType() != membershipTypeMember {
		return ineligible(membershipID, "only regular members may borrow"), nil
	}
	if groupID != "" && membership.GetGroupId() != "" && membership.GetGroupId() != groupID {
		return ineligible(membershipID, "the member does not belong to this group"), nil
	}

	grpResp, err := b.identityCli.ClientGroupGet(ctx, &identityv1.ClientGroupGetRequest{Id: membership.GetGroupId()})
	if err != nil {
		return nil, apperrors.ErrDataNotFound.Extend("client group")
	}
	currency := grpResp.GetData().GetCurrencyCode()

	if b.clients == nil || b.clients.LedgerClient == nil {
		return nil, apperrors.NewError(apperrors.ServiceUnavailable,
			"ledger service is required to price a loan from member savings")
	}

	savings, balErr := b.memberSavingsBalance(ctx, membershipID, currency)
	if balErr != nil {
		return nil, fmt.Errorf("could not read savings balance: %w", balErr)
	}

	decimals := moneyx.Decimals(currency)
	leverage := b.clampLeverage(ctx, b.product.MinLeverage)
	maxLoan := calculation.CalculateMaxLoanAmount(
		decimalx.FromMinorUnits(savings, decimals), leverage,
	).ToMinorUnits(decimals)

	if maxLoan <= 0 {
		result := ineligible(membershipID, "the member has no savings to borrow against")
		result["savings_balance"] = savings
		result[fieldCurrency] = currency
		return result, nil
	}

	return map[string]interface{}{
		fieldMemberID:     membershipID,
		fieldMembershipID: membershipID,
		fieldEligible:     true,
		"reason":          "",
		"savings_balance": savings,
		"max_loan_amount": maxLoan,
		fieldCurrency:     currency,
	}, nil
}

// ineligible is the negative eligibility verdict, shaped identically to the
// positive one so the workflow always finds the fields it reads.
func ineligible(membershipID, reason string) map[string]interface{} {
	return map[string]interface{}{
		fieldMemberID:     membershipID,
		fieldMembershipID: membershipID,
		fieldEligible:     false,
		"reason":          reason,
		"savings_balance": int64(0),
		"max_loan_amount": int64(0),
		fieldCurrency:     "",
	}
}

// EnsureSchedule reports the repayment schedule the loans service generated
// for a loan account. Schedule generation belongs to the loans service; stawi
// only confirms one exists before the workflow moves on to disbursement.
func (b *loanOfferBusiness) EnsureSchedule(
	ctx context.Context,
	loanAccountID string,
) (map[string]interface{}, error) {
	loanAccountID = strings.TrimSpace(loanAccountID)
	if loanAccountID == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "a loan id is required")
	}
	if b.clients == nil || b.clients.LenderLoanMgmt == nil {
		return nil, apperrors.NewError(apperrors.ServiceUnavailable,
			"loan management service is required to read a repayment schedule")
	}

	resp, err := b.clients.LenderLoanMgmt.RepaymentScheduleGet(
		ctx,
		&loansv1.RepaymentScheduleGetRequest{LoanAccountId: loanAccountID},
	)
	if err != nil {
		return nil, fmt.Errorf("could not read repayment schedule: %w", err)
	}

	schedule := resp.GetData()
	if schedule == nil || len(schedule.GetEntries()) == 0 {
		return nil, apperrors.NewError(apperrors.Unprocessable,
			"the loans service has not generated a repayment schedule for this loan")
	}

	return map[string]interface{}{
		"loan_id":      loanAccountID,
		"schedule_id":  schedule.GetId(),
		"entry_count":  len(schedule.GetEntries()),
		"generated_at": schedule.GetGeneratedAt(),
	}, nil
}

// Disburse releases a loan's principal through the loans service. The
// idempotency key is derived from the loan account, so a workflow retry after
// a timeout converges on the disbursement the first attempt started rather
// than paying the member twice.
func (b *loanOfferBusiness) Disburse(
	ctx context.Context,
	loanAccountID string,
) (map[string]interface{}, error) {
	loanAccountID = strings.TrimSpace(loanAccountID)
	if loanAccountID == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "a loan id is required")
	}
	if b.clients == nil || b.clients.LenderLoanMgmt == nil {
		return nil, apperrors.NewError(apperrors.ServiceUnavailable,
			"loan management service is required to disburse a loan")
	}

	resp, err := b.clients.LenderLoanMgmt.DisbursementCreate(ctx, &loansv1.DisbursementCreateRequest{
		LoanAccountId:  loanAccountID,
		IdempotencyKey: "stawi:" + loanAccountID,
	})
	if err != nil {
		return nil, fmt.Errorf("could not disburse loan: %w", err)
	}

	disbursement := resp.GetData()
	if disbursement == nil {
		return nil, apperrors.NewError(apperrors.ServiceUnavailable,
			"the loans service returned no disbursement")
	}

	transactionRef := disbursement.GetPaymentReference()
	if transactionRef == "" {
		transactionRef = disbursement.GetLedgerTransactionId()
	}

	return map[string]interface{}{
		"loan_id":         loanAccountID,
		"disbursement_id": disbursement.GetId(),
		"transaction_ref": transactionRef,
		fieldStatus:       int32(disbursement.GetStatus()),
		"disbursed_at":    disbursement.GetDisbursedAt(),
	}, nil
}
