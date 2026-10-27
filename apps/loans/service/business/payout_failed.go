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

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

const disbursementReferencePrefix = "disbursement:"

// ErrPayoutOutcomeCallerNotInternal is returned when anyone but an internal
// service reports a payout outcome.
var ErrPayoutOutcomeCallerNotInternal = apperrors.NewError(apperrors.Forbidden,
	"payout outcomes are reported only by internal services")

// PayoutFailures undoes what loans recorded for a payout the payment rail
// failed after accepting it. Operations has already reversed the ledger leg.
type PayoutFailures struct {
	disbursements repository.DisbursementRepository
	loans         repository.LoanAccountRepository
	repayments    repository.RepaymentRepository
	eventsMan     fevents.Manager
	commissions   *TeamCommissions
}

// NewPayoutFailures wires the undo.
func NewPayoutFailures(
	disbursements repository.DisbursementRepository,
	loans repository.LoanAccountRepository,
	repayments repository.RepaymentRepository,
	eventsMan fevents.Manager,
	commissions *TeamCommissions,
) *PayoutFailures {
	return &PayoutFailures{
		disbursements: disbursements, loans: loans, repayments: repayments,
		eventsMan: eventsMan, commissions: commissions,
	}
}

// Apply undoes the record behind reference. It reports whether this call
// changed anything; a reference already undone, or not loans', is not an
// error.
func (p *PayoutFailures) Apply(ctx context.Context, reference, reason string) (bool, error) {
	if claims := security.ClaimsFromContext(ctx); claims == nil || !claims.IsInternalSystem() {
		return false, ErrPayoutOutcomeCallerNotInternal
	}
	if reason == "" {
		reason = "the payment rail failed the payout"
	}
	switch {
	case strings.HasPrefix(reference, disbursementReferencePrefix):
		return p.disbursementFailed(ctx, strings.TrimPrefix(reference, disbursementReferencePrefix), reason)
	case strings.HasPrefix(reference, commissionPayoutReference):
		if p.commissions == nil {
			return false, nil
		}
		return p.commissions.ReturnFailedPayout(ctx, strings.TrimPrefix(reference, commissionPayoutReference), reason)
	default:
		return false, nil
	}
}

// disbursementFailed marks the disbursement failed and puts the loan back to
// awaiting disbursement, so staff can pay it again. A loan the borrower has
// already repaid on is left for an operator: undoing it would hide money
// that did arrive.
func (p *PayoutFailures) disbursementFailed(ctx context.Context, key, reason string) (bool, error) {
	logger := util.Log(ctx).WithField("idempotency_key", key)
	disb, err := p.disbursements.GetByIdempotencyKey(ctx, key)
	if err != nil {
		if data.ErrorIsNoRows(err) {
			return false, nil
		}
		return false, fmt.Errorf("load disbursement: %w", err)
	}
	if disb.Status != int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_COMPLETED) {
		return false, nil
	}
	if _, err = p.disbursements.UpdateColumns(ctx, disb.GetID(), map[string]any{
		fieldStatus:        int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_FAILED),
		fieldFailureReason: reason,
	}); err != nil {
		return false, fmt.Errorf("mark disbursement failed: %w", err)
	}
	logger = logger.WithField(fieldLoanID, disb.LoanAccountID)

	repaid, err := p.repayments.ListByLoanAccountID(ctx, disb.LoanAccountID, 1)
	if err != nil {
		return true, fmt.Errorf("check repayments: %w", err)
	}
	if len(repaid) > 0 {
		logger.Error("disbursement failed at the rail but the loan has repayments; an operator must settle it")
		return true, nil
	}
	moved, err := p.loans.ClaimStatus(ctx, disb.LoanAccountID,
		int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE), int32(loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT))
	if err != nil {
		return true, fmt.Errorf("return loan to pending disbursement: %w", err)
	}
	if !moved {
		logger.Error("disbursement failed at the rail but the loan is no longer active; an operator must settle it")
		return true, nil
	}
	if _, err = p.loans.UpdateColumns(ctx, disb.LoanAccountID, map[string]any{
		"disbursed_at":         nil,
		"first_repayment_date": nil,
	}); err != nil {
		logger.WithError(err).Warn("could not clear the disbursement date")
	}
	change := &models.LoanStatusChange{
		LoanAccountID: disb.LoanAccountID,
		FromStatus:    int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE),
		ToStatus:      int32(loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT),
		ChangedBy:     actorSystem,
		Reason:        "disbursement failed at the payment rail: " + reason,
	}
	change.GenID(ctx)
	if emitErr := p.eventsMan.Emit(ctx, events.LoanStatusChangeSaveEvent, change); emitErr != nil {
		logger.WithError(emitErr).Warn("could not record the status change")
	}
	logger.Warn("disbursement failed at the rail; the loan awaits disbursement again")
	return true, nil
}
