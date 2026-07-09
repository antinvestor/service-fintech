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

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/savings/service/events"
	"github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

const moneyDecimalPlaces = 2

// ErrSavingsAccountLedgerRefsMissing is returned when a deposit or withdrawal
// cannot be routed through the double-entry system because the savings
// account row does not carry both the internal ledger account and the
// external payment account reference. The account must be created with
// these refs configured.
var ErrSavingsAccountLedgerRefsMissing = errors.New("savings account is missing ledger or payment account refs")

type DepositBusiness interface {
	Record(
		ctx context.Context,
		accountID, amount, paymentRef, channel, payerRef, idempotencyKey string,
	) (*savingsv1.DepositObject, error)
	Get(ctx context.Context, id string) (*savingsv1.DepositObject, error)
	Search(
		ctx context.Context,
		req *savingsv1.DepositSearchRequest,
		consumer func(ctx context.Context, batch []*savingsv1.DepositObject) error,
	) error
}

type depositBusiness struct {
	eventsMan         fevents.Manager
	depRepo           repository.DepositRepository
	saRepo            repository.SavingsAccountRepository
	sbRepo            repository.SavingsBalanceRepository
	operationsCli     operationsv1connect.OperationsServiceClient
	auditWriter       *audit.Writer
	limitsCli         limitsv1connect.LimitsServiceClient
	limitsGateEnabled bool
	limitsGateMode    string
}

func NewDepositBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	depRepo repository.DepositRepository,
	saRepo repository.SavingsAccountRepository,
	sbRepo repository.SavingsBalanceRepository,
	operationsCli operationsv1connect.OperationsServiceClient,
	auditWriter *audit.Writer,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsGateEnabled bool,
	limitsGateMode string,
) DepositBusiness {
	return &depositBusiness{
		eventsMan:         eventsMan,
		depRepo:           depRepo,
		saRepo:            saRepo,
		sbRepo:            sbRepo,
		operationsCli:     operationsCli,
		auditWriter:       auditWriter,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsGateEnabled,
		limitsGateMode:    limitsGateMode,
	}
}

// Record applies an inbound deposit to a savings account. The flow is:
//
//  1. Validate account is active and ledger-capable.
//  2. Short-circuit on caller idempotency key (previously applied deposit).
//  3. When the limits gate is enabled, reserve capacity via the limits
//     service before executing the deposit. DENY returns LimitBreachedError;
//     PENDING_APPROVAL returns PendingApprovalError.
//  4. Persist the Deposit record in PROCESSING state so downstream systems
//     can observe an in-flight posting.
//  5. Emit a transfer order (external payment account → savings ledger
//     account) via the operations service using a stable reference derived
//     from the deposit id. Operations will dedupe on that reference so a
//     retry from any failure below lands on exactly the same ledger posting.
//  6. Credit the running savings balance atomically.
//  7. Mark the deposit COMPLETED, carrying the ledger transaction id.
//
// Any step after (4) that fails leaves the deposit record visible in an
// intermediate state and returns an error. Callers retry via their own
// idempotency key; the Deposit row, the transfer order, and the balance
// credit are all keyed on stable ids so retries converge.
func (b *depositBusiness) Record(
	ctx context.Context,
	accountID, amount, paymentRef, channel, payerRef, idempotencyKey string,
) (*savingsv1.DepositObject, error) {
	// Idempotency short-circuit (local).
	if idempotencyKey != "" {
		existing, idempErr := b.depRepo.GetByIdempotencyKey(ctx, idempotencyKey)
		if idempErr == nil && existing != nil {
			return existing.ToAPI(), nil
		}
	}

	if !b.limitsGateEnabled || b.limitsCli == nil || b.limitsGateMode == "off" {
		return b.recordInner(ctx, accountID, amount, paymentRef, channel, payerRef, idempotencyKey)
	}

	// Load account to build the intent (same validation happens in recordInner).
	sa, err := b.saRepo.GetByID(ctx, accountID)
	if err != nil {
		return nil, ErrSavingsAccountNotFound
	}

	amountMinor := models.StringToMinorUnits(amount)
	intent := &limitsv1.LimitIntent{
		Action:   limitsv1.LimitAction_LIMIT_ACTION_SAVINGS_DEPOSIT,
		TenantId: sa.BankID,
		Amount:   moneyx.FromMinorUnitsByCurrency(sa.CurrencyCode, amountMinor),
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT, Id: accountID},
		},
	}
	if idempotencyKey == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("idempotency_key required for savings deposit"))
	}
	idemKey := idempotencyKey

	var result *savingsv1.DepositObject
	gateErr := limits.Gate(ctx, b.limitsCli, intent, idemKey, limits.ParseMode(b.limitsGateMode),
		func(innerCtx context.Context, reservationID string) error {
			util.Log(innerCtx).With("limits_reservation_id", reservationID).Info("deposit gated by limits")
			inner, innerErr := b.recordInner(innerCtx, accountID, amount, paymentRef, channel, payerRef, idempotencyKey)
			if innerErr != nil {
				return innerErr
			}
			result = inner
			return nil
		})
	return result, gateErr
}

// recordInner is the pre-Gate body of Record. It performs all validation,
// persistence, and ledger posting. The idempotency check lives in the outer
// Record so it is not duplicated when Gate wraps this.
func (b *depositBusiness) recordInner(
	ctx context.Context,
	accountID, amount, paymentRef, channel, payerRef, idempotencyKey string,
) (*savingsv1.DepositObject, error) {
	logger := util.Log(ctx).WithField("method", "DepositBusiness.Record")

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

	amountMinor := models.StringToMinorUnits(amount)
	if amountMinor <= 0 {
		return nil, fmt.Errorf("deposit amount must be positive, got %d", amountMinor)
	}

	dep := models.DepositFromAPI(ctx, &savingsv1.DepositObject{
		SavingsAccountId: accountID,
		Amount:           models.MinorUnitsToMoney(amountMinor, sa.CurrencyCode),
		PaymentReference: paymentRef,
		Channel:          channel,
		PayerReference:   payerRef,
		IdempotencyKey:   idempotencyKey,
	})
	dep.Status = int32(savingsv1.DepositStatus_DEPOSIT_STATUS_PENDING)

	if emitErr := b.eventsMan.Emit(ctx, events.DepositSaveEvent, dep); emitErr != nil {
		logger.WithError(emitErr).Error("could not emit deposit save event")
		return nil, emitErr
	}

	toID, toErr := b.postDepositTransferOrder(ctx, logger, sa, dep, amountMinor)
	if toErr != nil {
		return nil, toErr
	}
	dep.LedgerTransactionID = toID

	if _, balErr := b.sbRepo.Credit(ctx, accountID, amountMinor); balErr != nil {
		logger.WithError(balErr).Error("could not credit savings balance after deposit")
		return nil, balErr
	}

	dep.Status = int32(savingsv1.DepositStatus_DEPOSIT_STATUS_COMPLETED)
	if emitErr := b.eventsMan.Emit(ctx, events.DepositSaveEvent, dep); emitErr != nil {
		logger.WithError(emitErr).Error("could not emit deposit completed event")
		return nil, emitErr
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "savings_deposit",
		EntityID:   dep.GetID(),
		Action:     "savings.deposit.settled",
		Reason:     "inbound deposit posted to ledger and credited",
		After: data.JSONMap{
			fieldStatus:              dep.Status,
			fieldLedgerTransactionID: dep.LedgerTransactionID,
		},
		Metadata: data.JSONMap{
			fieldSavingsAccountID: sa.GetID(),
			fieldOwnerID:          sa.OwnerID,
			fieldAmount:           amountMinor,
			fieldCurrency:         sa.CurrencyCode,
			fieldChannel:          channel,
			"payer_reference":     payerRef,
			"payment_reference":   paymentRef,
			"idempotency_key":     idempotencyKey,
		},
		Parent: &dep.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for savings deposit")
	})

	currencyAttr := attribute.String("currency", sa.CurrencyCode)
	SavingsDeposits.Add(ctx, 1, currencyAttr)
	SavingsDepositsAmount.Add(ctx, float64(amountMinor)/minorUnitsPerMajor, currencyAttr)

	return dep.ToAPI(), nil
}

// postDepositTransferOrder builds and executes the operations-service transfer
// order for a deposit. The Reference field is used by the operations service
// as an idempotency key: retries with the same key converge on a single
// ledger posting rather than duplicating money movement.
func (b *depositBusiness) postDepositTransferOrder(
	ctx context.Context,
	logger *util.LogEntry,
	sa *models.SavingsAccount,
	dep *models.Deposit,
	amountMinor int64,
) (string, error) {
	if b.operationsCli == nil {
		return "", errors.New("operations client is not configured; cannot post deposit transfer order")
	}

	reference := fmt.Sprintf("deposit:%s", dep.GetID())
	extraData := data.JSONMap{
		fieldSavingsAccountID: sa.GetID(),
		"deposit_id":          dep.GetID(),
		fieldOwnerID:          sa.OwnerID,
		fieldChannel:          dep.Channel,
		"payer_reference":     dep.PayerReference,
		"payment_reference":   dep.PaymentReference,
	}

	req := connect.NewRequest(&operationsv1.TransferOrderExecuteRequest{
		Data: &operationsv1.TransferOrderObject{
			DebitAccountRef:  sa.PaymentAccountRef,
			CreditAccountRef: sa.LedgerAccountID,
			Amount:           moneyx.FromSmallestUnit(sa.CurrencyCode, amountMinor, moneyDecimalPlaces),
			OrderType:        constants.SafeInt32FromInt(constants.TransferTypePeriodicSaving),
			Reference:        reference,
			Description:      "Savings deposit",
			ExtraData:        extraData.ToProtoStruct(),
		},
	})

	resp, execErr := b.operationsCli.TransferOrderExecute(ctx, req)
	if execErr != nil {
		logger.WithError(execErr).
			WithField("reference", reference).
			Error("could not execute transfer order for deposit")
		return "", fmt.Errorf("deposit transfer order %s failed: %w", reference, execErr)
	}
	return resp.Msg.GetData().GetId(), nil
}

func (b *depositBusiness) Get(ctx context.Context, id string) (*savingsv1.DepositObject, error) {
	dep, err := b.depRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrDepositNotFound
	}
	return dep.ToAPI(), nil
}

//nolint:dupl // similar search logic for different entity types
func (b *depositBusiness) Search(
	ctx context.Context,
	req *savingsv1.DepositSearchRequest,
	consumer func(ctx context.Context, batch []*savingsv1.DepositObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "DepositBusiness.Search")

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
	if req.GetStatus() != savingsv1.DepositStatus_DEPOSIT_STATUS_UNSPECIFIED {
		andQueryVal["status = ?"] = int32(req.GetStatus())
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.depRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search deposits")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.Deposit) error {
		var apiResults []*savingsv1.DepositObject
		for _, dep := range res {
			apiResults = append(apiResults, dep.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}
