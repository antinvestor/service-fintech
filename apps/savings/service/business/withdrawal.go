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
	"strconv"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/savings/service/events"
	"github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

type WithdrawalBusiness interface {
	Request(
		ctx context.Context,
		accountID, amount, channel, recipientRef, reason, idempotencyKey string,
	) (*savingsv1.WithdrawalObject, error)
	Approve(ctx context.Context, id string) (*savingsv1.WithdrawalObject, error)
	Cancel(ctx context.Context, id, reason string) (*savingsv1.WithdrawalObject, error)
	Get(ctx context.Context, id string) (*savingsv1.WithdrawalObject, error)
	Search(
		ctx context.Context,
		req *savingsv1.WithdrawalSearchRequest,
		consumer func(ctx context.Context, batch []*savingsv1.WithdrawalObject) error,
	) error
}

type withdrawalBusiness struct {
	eventsMan         fevents.Manager
	wdrRepo           repository.WithdrawalRepository
	saRepo            repository.SavingsAccountRepository
	sbRepo            repository.SavingsBalanceRepository
	saBusiness        SavingsAccountBusiness
	operationsCli     operationsv1connect.OperationsServiceClient
	auditWriter       *audit.Writer
	limitsCli         limitsv1connect.LimitsServiceClient
	limitsGateEnabled bool
	limitsGateMode    string
}

func NewWithdrawalBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	wdrRepo repository.WithdrawalRepository,
	saRepo repository.SavingsAccountRepository,
	sbRepo repository.SavingsBalanceRepository,
	saBusiness SavingsAccountBusiness,
	operationsCli operationsv1connect.OperationsServiceClient,
	auditWriter *audit.Writer,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsGateEnabled bool,
	limitsGateMode string,
) WithdrawalBusiness {
	return &withdrawalBusiness{
		eventsMan:         eventsMan,
		wdrRepo:           wdrRepo,
		saRepo:            saRepo,
		sbRepo:            sbRepo,
		saBusiness:        saBusiness,
		operationsCli:     operationsCli,
		auditWriter:       auditWriter,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsGateEnabled,
		limitsGateMode:    limitsGateMode,
	}
}

// Request places an authoritative hold on the requested amount via an atomic
// reservation on the running savings balance. If the balance guard fails the
// request is rejected immediately without persisting a withdrawal row, so
// two concurrent Requests against overlapping funds cannot both succeed.
//
// On success a PENDING withdrawal row is persisted. The reservation remains
// in place until Approve settles it (DebitReserved) or a future cancel path
// releases it.
func (b *withdrawalBusiness) Request(
	ctx context.Context,
	accountID, amount, channel, recipientRef, reason, idempotencyKey string,
) (*savingsv1.WithdrawalObject, error) {
	logger := util.Log(ctx).WithField("method", "WithdrawalBusiness.Request")

	sa, err := b.saRepo.GetByID(ctx, accountID)
	if err != nil {
		return nil, ErrSavingsAccountNotFound
	}

	currentStatus := savingsv1.SavingsAccountStatus(sa.Status)
	if currentStatus == savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_FROZEN {
		return nil, ErrAccountFrozen
	}
	if currentStatus == savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_CLOSED {
		return nil, ErrAccountClosed
	}
	if sa.LedgerAccountID == "" || sa.PaymentAccountRef == "" {
		return nil, ErrSavingsAccountLedgerRefsMissing
	}

	if idempotencyKey != "" {
		existing, idempErr := b.wdrRepo.GetByIdempotencyKey(ctx, idempotencyKey)
		if idempErr == nil && existing != nil {
			return existing.ToAPI(), nil
		}
	}

	amountMinor := models.StringToMinorUnits(amount)
	if amountMinor <= 0 {
		return nil, fmt.Errorf("withdrawal amount must be positive, got %d", amountMinor)
	}

	// Atomic balance guard. Reserve will return ErrInsufficientFunds if
	// (balance - reserved_balance) < amountMinor, so this is the single
	// authoritative check: no read-then-write race is possible.
	if _, resErr := b.sbRepo.Reserve(ctx, accountID, amountMinor); resErr != nil {
		if errors.Is(resErr, repository.ErrInsufficientFunds) {
			return nil, ErrInsufficientBalance
		}
		logger.WithError(resErr).Error("could not reserve funds for withdrawal")
		return nil, resErr
	}

	wdr := models.WithdrawalFromAPI(ctx, &savingsv1.WithdrawalObject{
		SavingsAccountId:   accountID,
		Amount:             models.MinorUnitsToMoney(amountMinor, sa.CurrencyCode),
		Channel:            channel,
		RecipientReference: recipientRef,
		Reason:             reason,
		IdempotencyKey:     idempotencyKey,
	})
	wdr.Status = int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_PENDING)

	if emitErr := b.eventsMan.Emit(ctx, events.WithdrawalSaveEvent, wdr); emitErr != nil {
		logger.WithError(emitErr).Error("could not emit withdrawal save event")
		// Best-effort compensation: release the hold so retries have the same
		// funds available. This only runs in-process on error before return.
		if _, releaseErr := b.sbRepo.ReleaseReserved(ctx, accountID, amountMinor); releaseErr != nil {
			logger.WithError(releaseErr).Error("could not release reservation after save failure")
		}
		return nil, emitErr
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "savings_withdrawal",
		EntityID:   wdr.GetID(),
		Action:     "savings.withdrawal.requested",
		Reason:     reason,
		After: data.JSONMap{
			"status":           wdr.Status,
			"reserved_amount":  amountMinor,
			"balance_reserved": true,
		},
		Metadata: data.JSONMap{
			"savings_account_id":  sa.GetID(),
			"owner_id":            sa.OwnerID,
			"amount":              amountMinor,
			"currency":            sa.CurrencyCode,
			"channel":             channel,
			"recipient_reference": recipientRef,
			"idempotency_key":     idempotencyKey,
		},
		Parent: &wdr.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for savings withdrawal request")
	})

	return wdr.ToAPI(), nil
}

// Approve settles a pending withdrawal: it moves money off the reserved hold
// via DebitReserved, emits a transfer order through operations (which in
// turn posts to the external ledger and triggers the payment), and marks
// the withdrawal as completed.
//
// When the limits gate is enabled, a reservation is obtained from the limits
// service before the settlement executes. DENY returns LimitBreachedError;
// PENDING_APPROVAL returns PendingApprovalError.
//
// The transfer order reference is keyed on the withdrawal id so retries of
// Approve (for example after a transient operations outage) converge on a
// single ledger posting rather than double-paying the recipient.
func (b *withdrawalBusiness) Approve(ctx context.Context, id string) (*savingsv1.WithdrawalObject, error) {
	wdr, err := b.wdrRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrWithdrawalNotFound
	}

	if wdr.Status != int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_PENDING) {
		return nil, ErrInvalidStatusTransition
	}

	if !b.limitsGateEnabled || b.limitsCli == nil || b.limitsGateMode == "off" {
		return b.approveInner(ctx, id, wdr)
	}

	sa, saErr := b.saRepo.GetByID(ctx, wdr.SavingsAccountID)
	if saErr != nil {
		return nil, ErrSavingsAccountNotFound
	}

	intent := &limitsv1.LimitIntent{
		Action:   limitsv1.LimitAction_LIMIT_ACTION_SAVINGS_WITHDRAWAL,
		TenantId: sa.BankID,
		Amount:   moneyx.FromMinorUnitsByCurrency(sa.CurrencyCode, wdr.Amount),
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT, Id: wdr.SavingsAccountID},
		},
	}
	idemKey := "savings_withdrawal:" + id

	var result *savingsv1.WithdrawalObject
	gateErr := limits.Gate(ctx, b.limitsCli, intent, idemKey, limits.ParseMode(b.limitsGateMode),
		func(innerCtx context.Context, reservationID string) error {
			util.Log(innerCtx).With("limits_reservation_id", reservationID).Info("withdrawal approve gated by limits")
			inner, innerErr := b.approveInner(innerCtx, id, wdr)
			if innerErr != nil {
				return innerErr
			}
			result = inner
			return nil
		})
	return result, gateErr
}

// approveInner executes the withdrawal settlement after any gate check.
// wdr must already be validated as PENDING before calling this.
func (b *withdrawalBusiness) approveInner(
	ctx context.Context,
	id string,
	wdr *models.Withdrawal,
) (*savingsv1.WithdrawalObject, error) {
	logger := util.Log(ctx).WithField("method", "WithdrawalBusiness.Approve")

	sa, saErr := b.saRepo.GetByID(ctx, wdr.SavingsAccountID)
	if saErr != nil {
		return nil, ErrSavingsAccountNotFound
	}
	if sa.LedgerAccountID == "" || sa.PaymentAccountRef == "" {
		return nil, ErrSavingsAccountLedgerRefsMissing
	}

	// Settle the reservation. DebitReserved is guarded on both reserved_balance
	// and balance being >= amount, so a double-approve cannot over-draw.
	if _, debErr := b.sbRepo.DebitReserved(ctx, wdr.SavingsAccountID, wdr.Amount); debErr != nil {
		logger.WithError(debErr).Error("could not debit reserved funds on approve")
		return nil, debErr
	}

	toID, toErr := b.postWithdrawalTransferOrder(ctx, logger, sa, wdr)
	if toErr != nil {
		return nil, toErr
	}
	wdr.LedgerTransactionID = toID

	wdr.Status = int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_COMPLETED)
	if emitErr := b.eventsMan.Emit(ctx, events.WithdrawalSaveEvent, wdr); emitErr != nil {
		logger.WithError(emitErr).Error("could not emit withdrawal completed event")
		return nil, emitErr
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "savings_withdrawal",
		EntityID:   wdr.GetID(),
		Action:     "savings.withdrawal.approved",
		Reason:     "withdrawal approved, ledger posted, reservation settled",
		Before:     data.JSONMap{"status": int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_PENDING)},
		After: data.JSONMap{
			"status":                wdr.Status,
			"ledger_transaction_id": wdr.LedgerTransactionID,
		},
		Metadata: data.JSONMap{
			"savings_account_id":  sa.GetID(),
			"owner_id":            sa.OwnerID,
			"amount":              wdr.Amount,
			"currency":            sa.CurrencyCode,
			"channel":             wdr.Channel,
			"recipient_reference": wdr.RecipientReference,
			"withdrawal_id":       id,
		},
		Parent: &wdr.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for savings withdrawal approval")
	})

	wdrAudit := constants.AuditTrailFromContext(ctx)
	wdrAttrs := metric.WithAttributes(
		attribute.String("tenant_id", wdrAudit.TenantID),
		attribute.String("partition_id", wdrAudit.PartitionID),
		attribute.String("currency", sa.CurrencyCode),
	)
	SavingsWithdrawals.Add(ctx, 1, wdrAttrs)
	SavingsWithdrawalsAmount.Add(ctx, float64(wdr.Amount)/minorUnitsPerMajor, wdrAttrs)

	return wdr.ToAPI(), nil
}

// postWithdrawalTransferOrder builds and executes the operations-service
// transfer order for a settled withdrawal. As with deposits, the Reference
// is used by operations as an idempotency key so retries converge on a
// single posting.
func (b *withdrawalBusiness) postWithdrawalTransferOrder(
	ctx context.Context,
	logger *util.LogEntry,
	sa *models.SavingsAccount,
	wdr *models.Withdrawal,
) (string, error) {
	if b.operationsCli == nil {
		return "", errors.New("operations client is not configured; cannot post withdrawal transfer order")
	}

	reference := fmt.Sprintf("withdrawal:%s", wdr.GetID())
	extraData := data.JSONMap{
		"savings_account_id":  sa.GetID(),
		"withdrawal_id":       wdr.GetID(),
		"owner_id":            sa.OwnerID,
		"channel":             wdr.Channel,
		"recipient_reference": wdr.RecipientReference,
	}

	req := connect.NewRequest(&operationsv1.TransferOrderExecuteRequest{
		Data: &operationsv1.TransferOrderObject{
			DebitAccountRef:  sa.LedgerAccountID,
			CreditAccountRef: sa.PaymentAccountRef,
			Amount:           moneyx.FromSmallestUnit(sa.CurrencyCode, wdr.Amount, moneyDecimalPlaces),
			OrderType:        constants.SafeInt32FromInt(constants.TransferTypePeriodicSavingRecovery),
			Reference:        reference,
			Description:      "Savings withdrawal",
			ExtraData:        extraData.ToProtoStruct(),
		},
	})

	resp, execErr := b.operationsCli.TransferOrderExecute(ctx, req)
	if execErr != nil {
		logger.WithError(execErr).
			WithField("reference", reference).
			Error("could not execute transfer order for withdrawal")
		return "", fmt.Errorf("withdrawal transfer order %s failed: %w", reference, execErr)
	}
	return resp.Msg.GetData().GetId(), nil
}

// Cancel rejects a pending withdrawal and releases the reserved balance.
func (b *withdrawalBusiness) Cancel(ctx context.Context, id, reason string) (*savingsv1.WithdrawalObject, error) {
	logger := util.Log(ctx).WithField("method", "WithdrawalBusiness.Cancel")

	wdr, err := b.wdrRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrWithdrawalNotFound
	}

	if wdr.Status != int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_PENDING) {
		return nil, errors.New("only pending withdrawals can be cancelled")
	}

	// Release the reserved balance back to available.
	if _, relErr := b.sbRepo.ReleaseReserved(ctx, wdr.SavingsAccountID, wdr.Amount); relErr != nil {
		logger.WithError(relErr).Error("could not release reserved balance for cancelled withdrawal")
		return nil, fmt.Errorf("release reserved balance: %w", relErr)
	}

	wdr.Status = int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_REJECTED)
	wdr.Reason = reason

	if emitErr := b.eventsMan.Emit(ctx, events.WithdrawalSaveEvent, wdr); emitErr != nil {
		logger.WithError(emitErr).Error("could not save cancelled withdrawal")
		return nil, emitErr
	}

	logger.WithField("withdrawal_id", id).Info("withdrawal cancelled and balance released")
	return wdr.ToAPI(), nil
}

func (b *withdrawalBusiness) Get(ctx context.Context, id string) (*savingsv1.WithdrawalObject, error) {
	wdr, err := b.wdrRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrWithdrawalNotFound
	}
	return wdr.ToAPI(), nil
}

//nolint:dupl // similar search logic for different entity types
func (b *withdrawalBusiness) Search(
	ctx context.Context,
	req *savingsv1.WithdrawalSearchRequest,
	consumer func(ctx context.Context, batch []*savingsv1.WithdrawalObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "WithdrawalBusiness.Search")

	var searchOpts []data.SearchOption

	cursor := req.GetCursor()
	if cursor != nil {
		offset, offsetErr := strconv.Atoi(cursor.GetPage())
		if offsetErr != nil {
			offset = 0
		}
		searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(int(cursor.GetLimit())))
	}

	andQueryVal := map[string]any{}
	if req.GetSavingsAccountId() != "" {
		andQueryVal["savings_account_id = ?"] = req.GetSavingsAccountId()
	}
	if req.GetStatus() != savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_UNSPECIFIED {
		andQueryVal["status = ?"] = int32(req.GetStatus())
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.wdrRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search withdrawals")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.Withdrawal) error {
		var apiResults []*savingsv1.WithdrawalObject
		for _, wdr := range res {
			apiResults = append(apiResults, wdr.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}
