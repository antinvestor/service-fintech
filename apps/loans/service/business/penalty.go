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

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
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
	eventsMan     fevents.Manager
	penaltyRepo   repository.PenaltyRepository
	loanRepo      repository.LoanAccountRepository
	operationsCli operationsv1connect.OperationsServiceClient
	auditWriter   *audit.Writer
}

func NewPenaltyBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	penaltyRepo repository.PenaltyRepository,
	loanRepo repository.LoanAccountRepository,
	operationsCli operationsv1connect.OperationsServiceClient,
	auditWriter *audit.Writer,
) PenaltyBusiness {
	return &penaltyBusiness{
		eventsMan:     eventsMan,
		penaltyRepo:   penaltyRepo,
		loanRepo:      loanRepo,
		operationsCli: operationsCli,
		auditWriter:   auditWriter,
	}
}

// Save persists a new penalty and posts the matching accrual to the ledger.
//
// The ledger posting debits the member's penalty receivable account and
// credits the loan account's penalty income account, so the loan's P&L
// recognises the penalty at accrual time rather than only when it is
// eventually settled by a repayment. The transfer order uses a stable
// reference derived from the penalty id, so retries of Save converge on a
// single posting via the operations service's reference-based idempotency.
//
// Waived penalties are persisted but not posted, because they never became
// a real receivable.
func (b *penaltyBusiness) Save(ctx context.Context, obj *loansv1.PenaltyObject) (*loansv1.PenaltyObject, error) {
	logger := util.Log(ctx).WithField("method", "PenaltyBusiness.Save")

	penalty := models.PenaltyFromAPI(ctx, obj)
	if penalty == nil {
		return nil, errors.New("penalty payload is required")
	}

	if penalty.Amount <= 0 {
		return nil, fmt.Errorf("penalty amount must be positive, got %d", penalty.Amount)
	}

	if emitErr := b.eventsMan.Emit(ctx, events.PenaltySaveEvent, penalty); emitErr != nil {
		logger.WithError(emitErr).Error("could not emit penalty save event")
		return nil, emitErr
	}

	if !penalty.IsWaived {
		if toErr := b.postPenaltyAccrual(ctx, logger, penalty); toErr != nil {
			return nil, toErr
		}
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "penalty",
		EntityID:   penalty.GetID(),
		Action:     "penalty.applied",
		Reason:     penalty.Reason,
		After: data.JSONMap{
			"amount":                penalty.Amount,
			"currency":              penalty.CurrencyCode,
			"is_waived":             penalty.IsWaived,
			"ledger_transaction_id": penalty.LedgerTransactionID,
		},
		Metadata: data.JSONMap{
			"loan_account_id": penalty.LoanAccountID,
			"penalty_type":    penalty.PenaltyType,
		},
		Parent: &penalty.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for penalty")
	})

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
) error {
	if b.operationsCli == nil {
		return errors.New("operations client is not configured; cannot post penalty accrual")
	}

	la, laErr := b.loanRepo.GetByID(ctx, penalty.LoanAccountID)
	if laErr != nil {
		return fmt.Errorf("load loan account %s for penalty: %w", penalty.LoanAccountID, laErr)
	}
	if la.ClientID == "" {
		return fmt.Errorf("loan account %s is missing client id", la.GetID())
	}
	if la.LedgerPenaltyIncomeAccountID == "" {
		return fmt.Errorf("loan account %s is missing penalty income ledger account", la.GetID())
	}

	reference := fmt.Sprintf("penalty:%s", penalty.GetID())
	extraData := data.JSONMap{
		"loan_account_id": penalty.LoanAccountID,
		"penalty_id":      penalty.GetID(),
		"penalty_type":    penalty.PenaltyType,
		"client_id":       la.ClientID,
	}

	req := connect.NewRequest(&operationsv1.TransferOrderExecuteRequest{
		Data: &operationsv1.TransferOrderObject{
			DebitAccountRef:  constants.MemberPenaltyReceivableAccount(la.ClientID),
			CreditAccountRef: la.LedgerPenaltyIncomeAccountID,
			Amount:           moneyx.FromSmallestUnit(penalty.CurrencyCode, penalty.Amount, decimalPrecision),
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
		return fmt.Errorf("penalty accrual transfer order %s failed: %w", reference, execErr)
	}
	if td := resp.Msg.GetData(); td != nil {
		penalty.LedgerTransactionID = td.GetId()
		// Best-effort update of the stored record with the ledger txn id.
		// If this emit fails we still return success: the ledger posted
		// correctly and reconciliation would catch any drift.
		if emitErr := b.eventsMan.Emit(ctx, events.PenaltySaveEvent, penalty); emitErr != nil {
			logger.WithError(emitErr).
				Warn("could not persist ledger transaction id onto penalty")
		}
	}
	return nil
}

func (b *penaltyBusiness) Waive(ctx context.Context, id, reason string) (*loansv1.PenaltyObject, error) {
	logger := util.Log(ctx).WithField("method", "PenaltyBusiness.Waive")

	penalty, err := b.penaltyRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrPenaltyNotFound
	}

	if penalty.IsWaived {
		return nil, ErrPenaltyAlreadyWaived
	}

	penalty.IsWaived = true
	penalty.WaivedReason = reason

	err = b.eventsMan.Emit(ctx, events.PenaltySaveEvent, penalty)
	if err != nil {
		logger.WithError(err).Error("could not emit penalty save event")
		return nil, err
	}

	return penalty.ToAPI(), nil
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
