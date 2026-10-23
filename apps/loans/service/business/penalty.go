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

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

type PenaltyBusiness interface {
	Save(ctx context.Context, obj *loansv1.PenaltyObject) (*loansv1.PenaltyObject, error)
	Waive(ctx context.Context, id, reason string) (*loansv1.PenaltyObject, error)
	Search(
		ctx context.Context,
		req *loansv1.PenaltySearchRequest,
		consumer func(ctx context.Context, batch []*loansv1.PenaltyObject) error,
	) error
}

type penaltyBusiness struct {
	penaltyRepo     repository.PenaltyRepository
	loanRepo        repository.LoanAccountRepository
	loanBalanceRepo repository.LoanBalanceRepository
	operationsCli   operationsv1connect.OperationsServiceClient
	auditWriter     *audit.Writer
	notifier        *LoanNotifier
}

func NewPenaltyBusiness(
	_ context.Context,
	penaltyRepo repository.PenaltyRepository,
	loanRepo repository.LoanAccountRepository,
	loanBalanceRepo repository.LoanBalanceRepository,
	operationsCli operationsv1connect.OperationsServiceClient,
	auditWriter *audit.Writer,
	opts ...Option,
) PenaltyBusiness {
	return &penaltyBusiness{
		penaltyRepo:     penaltyRepo,
		loanRepo:        loanRepo,
		loanBalanceRepo: loanBalanceRepo,
		operationsCli:   operationsCli,
		auditWriter:     auditWriter,
		notifier:        applyOptions(opts).notifier,
	}
}

// Save records a penalty against a loan: it charges the borrower's balance,
// posts the matching accrual to the ledger, and stores the penalty row.
//
// The ledger posting debits the member's penalty receivable account and
// credits the loan account's penalty income account, so the loan's P&L
// recognises the penalty at accrual time rather than only when it is
// eventually settled by a repayment. The transfer order uses a stable
// reference derived from the penalty id, so retries of Save converge on a
// single posting via the operations service's reference-based idempotency.
//
// The balance delta is what makes the penalty collectable at all: the
// repayment waterfall allocates to penalties_outstanding, and a penalty that
// never enters that column is a receivable on the ledger that the loan book
// will never ask for.
func (b *penaltyBusiness) Save(ctx context.Context, obj *loansv1.PenaltyObject) (*loansv1.PenaltyObject, error) {
	logger := util.Log(ctx).WithField("method", "PenaltyBusiness.Save")

	penalty := models.PenaltyFromAPI(ctx, obj)
	if penalty == nil {
		return nil, apperrors.NewError(apperrors.BadRequest, "penalty payload is required")
	}
	if penalty.Amount <= 0 {
		return nil, ErrPenaltyAmountInvalid
	}
	if penalty.LoanAccountID == "" {
		return nil, ErrPenaltyLoanAccountRequired
	}

	// Waiving is a decision with its own reversal; it never arrives as a
	// property of a newly recorded penalty.
	penalty.IsWaived = false
	penalty.WaivedBy = ""
	penalty.WaivedReason = ""
	penalty.LedgerTransactionID = ""

	la, laErr := b.loanRepo.GetByID(ctx, penalty.LoanAccountID)
	if laErr != nil {
		return nil, ErrLoanAccountNotFound
	}
	if penalty.CurrencyCode == "" {
		penalty.CurrencyCode = la.CurrencyCode
	}
	if penalty.CurrencyCode != la.CurrencyCode {
		return nil, ErrPenaltyCurrencyMismatch
	}

	if err := b.penaltyRepo.Create(ctx, penalty); err != nil {
		logger.WithError(err).Error("could not persist penalty")
		return nil, err
	}

	if err := b.postPenaltyAccrual(ctx, logger, penalty, la); err != nil {
		return nil, err
	}

	if _, err := b.loanBalanceRepo.ApplyPenaltyDelta(ctx, penalty.LoanAccountID, penalty.Amount); err != nil {
		logger.WithError(err).Error("could not charge the penalty to the loan balance")
		return nil, err
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "penalty",
		EntityID:   penalty.GetID(),
		Action:     "penalty.applied",
		Reason:     penalty.Reason,
		After: data.JSONMap{
			fieldAmount:      penalty.Amount,
			fieldCurrency:    penalty.CurrencyCode,
			fieldIsWaived:    penalty.IsWaived,
			fieldLedgerTxnID: penalty.LedgerTransactionID,
		},
		Metadata: data.JSONMap{
			fieldLoanAccountID: penalty.LoanAccountID,
			"penalty_type":     penalty.PenaltyType,
		},
		Parent: &penalty.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for penalty")
	})

	b.notifier.NotifyPenaltyApplied(ctx, la, penalty.Amount, penalty.Reason)

	return penalty.ToAPI(), nil
}

// postPenaltyAccrual builds and executes a transfer order that records the
// penalty as a receivable against the member and income for the loan.
// Requires the penalty's loan account to carry both a client id and a
// configured penalty income ledger account id; missing either is a hard
// error because it would silently drop a money-movement record.
func (b *penaltyBusiness) postPenaltyAccrual(
	ctx context.Context,
	logger *util.LogEntry,
	penalty *models.Penalty,
	la *models.LoanAccount,
) error {
	if b.operationsCli == nil {
		return ErrOperationsClientUnavailable
	}
	if la.ClientID == "" || la.LedgerPenaltyIncomeAccountID == "" {
		return ErrLoanLedgerAccountMissing
	}

	reference := "penalty:" + penalty.GetID()
	extraData := data.JSONMap{
		fieldLoanAccountID: penalty.LoanAccountID,
		"penalty_id":       penalty.GetID(),
		"penalty_type":     penalty.PenaltyType,
		fieldClientID:      la.ClientID,
	}

	req := connect.NewRequest(&operationsv1.TransferOrderExecuteRequest{
		Data: &operationsv1.TransferOrderObject{
			DebitAccountRef:  constants.MemberPenaltyReceivableAccount(la.ClientID),
			CreditAccountRef: la.LedgerPenaltyIncomeAccountID,
			Amount:           moneyx.FromMinorUnitsByCurrency(penalty.CurrencyCode, penalty.Amount),
			OrderType:        constants.SafeInt32FromInt(constants.TransferTypePenalty),
			Reference:        reference,
			Description:      "Penalty accrual",
			ExtraData:        extraData.ToProtoStruct(),
		},
	})

	resp, execErr := b.operationsCli.TransferOrderExecute(ctx, req)
	if execErr != nil {
		logger.WithError(execErr).
			WithField("reference", reference).
			Error("could not execute penalty accrual transfer order")
		return ErrPenaltyAccrualFailed
	}

	if td := resp.Msg.GetData(); td != nil {
		penalty.LedgerTransactionID = td.GetId()
		if _, err := b.penaltyRepo.UpdateColumns(ctx, penalty.GetID(), map[string]any{
			fieldLedgerTxnID: penalty.LedgerTransactionID,
		}); err != nil {
			logger.WithError(err).Error("could not persist the ledger transaction id onto the penalty")
			return err
		}
	}
	return nil
}

// Waive cancels an unsettled penalty: it releases the charge from the loan
// balance and reverses the accrual on the ledger, so the borrower is no
// longer asked for money the lender has decided not to collect.
func (b *penaltyBusiness) Waive(ctx context.Context, id, reason string) (*loansv1.PenaltyObject, error) {
	logger := util.Log(ctx).WithField("method", "PenaltyBusiness.Waive")

	penalty, err := b.penaltyRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrPenaltyNotFound
	}
	if penalty.IsWaived {
		return nil, ErrPenaltyAlreadyWaived
	}

	waivedBy := callerSubject(ctx)

	claimed, claimErr := b.penaltyRepo.ClaimWaiver(ctx, id, waivedBy, reason)
	if claimErr != nil {
		logger.WithError(claimErr).Error("could not waive penalty")
		return nil, claimErr
	}
	if !claimed {
		return nil, ErrPenaltyAlreadyWaived
	}

	penalty.IsWaived = true
	penalty.WaivedBy = waivedBy
	penalty.WaivedReason = reason

	if _, err = b.loanBalanceRepo.ApplyPenaltyDelta(ctx, penalty.LoanAccountID, -penalty.Amount); err != nil {
		logger.WithError(err).Error("could not release the waived penalty from the loan balance")
		return nil, err
	}

	if err = b.reversePenaltyAccrual(ctx, logger, penalty); err != nil {
		return nil, err
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "penalty",
		EntityID:   penalty.GetID(),
		Action:     "penalty.waived",
		ActorID:    waivedBy,
		ActorType:  "user",
		Reason:     reason,
		Before:     data.JSONMap{fieldIsWaived: false},
		After:      data.JSONMap{fieldIsWaived: true},
		Metadata: data.JSONMap{
			fieldLoanAccountID: penalty.LoanAccountID,
			fieldAmount:        penalty.Amount,
			fieldCurrency:      penalty.CurrencyCode,
		},
		Parent: &penalty.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for penalty waiver")
	})

	if la, laErr := b.loanRepo.GetByID(ctx, penalty.LoanAccountID); laErr == nil && la != nil {
		b.notifier.NotifyPenaltyWaived(ctx, la, penalty.Amount)
	}

	return penalty.ToAPI(), nil
}

// reversePenaltyAccrual posts the contra entry for a waived penalty.
func (b *penaltyBusiness) reversePenaltyAccrual(
	ctx context.Context,
	logger *util.LogEntry,
	penalty *models.Penalty,
) error {
	if b.operationsCli == nil {
		return ErrOperationsClientUnavailable
	}

	la, laErr := b.loanRepo.GetByID(ctx, penalty.LoanAccountID)
	if laErr != nil {
		return ErrLoanAccountNotFound
	}
	if la.ClientID == "" || la.LedgerPenaltyIncomeAccountID == "" {
		return ErrLoanLedgerAccountMissing
	}

	reference := "penalty_waiver:" + penalty.GetID()
	req := connect.NewRequest(&operationsv1.TransferOrderExecuteRequest{
		Data: &operationsv1.TransferOrderObject{
			DebitAccountRef:  la.LedgerPenaltyIncomeAccountID,
			CreditAccountRef: constants.MemberPenaltyReceivableAccount(la.ClientID),
			Amount:           moneyx.FromMinorUnitsByCurrency(penalty.CurrencyCode, penalty.Amount),
			OrderType:        constants.SafeInt32FromInt(constants.TransferTypePenaltyCancel),
			Reference:        reference,
			Description:      "Penalty waiver",
			ExtraData: (&data.JSONMap{
				fieldLoanAccountID: penalty.LoanAccountID,
				"penalty_id":       penalty.GetID(),
				fieldClientID:      la.ClientID,
			}).ToProtoStruct(),
		},
	})

	if _, execErr := b.operationsCli.TransferOrderExecute(ctx, req); execErr != nil {
		logger.WithError(execErr).
			WithField("reference", reference).
			Error("could not reverse the penalty accrual")
		return ErrPenaltyAccrualFailed
	}
	return nil
}

func (b *penaltyBusiness) Search(
	ctx context.Context,
	req *loansv1.PenaltySearchRequest,
	consumer func(ctx context.Context, batch []*loansv1.PenaltyObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "PenaltyBusiness.Search")

	andQueryVal := map[string]any{}
	if req.GetLoanAccountId() != "" {
		andQueryVal["loan_account_id = ?"] = req.GetLoanAccountId()
	}
	if req.GetPenaltyType() != loansv1.PenaltyType_PENALTY_TYPE_UNSPECIFIED {
		andQueryVal["penalty_type = ?"] = int32(req.GetPenaltyType())
	}

	return executeSearch(
		ctx,
		logger,
		b.penaltyRepo.Search,
		req.GetCursor(),
		andQueryVal,
		"failed to search penalties",
		func(p *models.Penalty) *loansv1.PenaltyObject {
			return p.ToAPI()
		},
		consumer,
	)
}
