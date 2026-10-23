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
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

type DepositBusiness interface {
	Record(ctx context.Context, req *savingsv1.DepositRecordRequest) (*savingsv1.DepositObject, error)
	Get(ctx context.Context, id string) (*savingsv1.DepositObject, error)
	Search(
		ctx context.Context,
		req *savingsv1.DepositSearchRequest,
		consumer func(ctx context.Context, batch []*savingsv1.DepositObject) error,
	) error
}

type depositBusiness struct {
	depRepo           repository.DepositRepository
	saRepo            repository.SavingsAccountRepository
	operationsCli     operationsv1connect.OperationsServiceClient
	auditWriter       *audit.Writer
	limitsCli         limitsv1connect.LimitsServiceClient
	limitsGateEnabled bool
	limitsGateMode    string
}

func NewDepositBusiness(
	_ context.Context,
	depRepo repository.DepositRepository,
	saRepo repository.SavingsAccountRepository,
	operationsCli operationsv1connect.OperationsServiceClient,
	auditWriter *audit.Writer,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsGateEnabled bool,
	limitsGateMode string,
) DepositBusiness {
	return &depositBusiness{
		depRepo:           depRepo,
		saRepo:            saRepo,
		operationsCli:     operationsCli,
		auditWriter:       auditWriter,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsGateEnabled,
		limitsGateMode:    limitsGateMode,
	}
}

// Record applies an inbound deposit to a savings account.
//
// The deposit row is written synchronously before any money moves, and its
// idempotency key carries a unique index, so a retry or a concurrent duplicate
// loses the insert and gets the stored deposit back instead of a second
// posting. Everything after that claim converges on the same row: the
// operations transfer order is keyed on the deposit id, and the completion
// (status + ledger transaction id + balance credit) is a single guarded
// database transaction.
func (b *depositBusiness) Record(
	ctx context.Context,
	req *savingsv1.DepositRecordRequest,
) (*savingsv1.DepositObject, error) {
	idempotencyKey := req.GetIdempotencyKey()
	if idempotencyKey == "" {
		return nil, ErrIdempotencyKeyRequired
	}

	// A completed deposit is the final answer for this key. A deposit still
	// PENDING means an earlier attempt died between the claim and the ledger,
	// so the retry falls through and drives that same row to completion
	// rather than starting a second one.
	if existing, idempErr := b.depRepo.GetByIdempotencyKey(ctx, idempotencyKey); idempErr == nil &&
		existing != nil &&
		existing.Status == int32(savingsv1.DepositStatus_DEPOSIT_STATUS_COMPLETED) {
		return existing.ToAPI(), nil
	}

	if !b.limitsGateEnabled || b.limitsCli == nil || b.limitsGateMode == "off" {
		return b.recordInner(ctx, req)
	}

	sa, err := b.saRepo.GetByID(ctx, req.GetSavingsAccountId())
	if err != nil {
		return nil, ErrSavingsAccountNotFound
	}
	amountMinor, amountErr := amountInAccountCurrency(req.GetAmount(), sa.CurrencyCode)
	if amountErr != nil {
		return nil, amountErr
	}

	intent := &limitsv1.LimitIntent{
		Action:   limitsv1.LimitAction_LIMIT_ACTION_SAVINGS_DEPOSIT,
		TenantId: sa.BankID,
		Amount:   moneyx.FromMinorUnitsByCurrency(sa.CurrencyCode, amountMinor),
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT, Id: sa.GetID()},
		},
	}

	var result *savingsv1.DepositObject
	gateErr := limits.Gate(ctx, b.limitsCli, intent, idempotencyKey, limits.ParseMode(b.limitsGateMode),
		func(innerCtx context.Context, reservationID string) error {
			util.Log(innerCtx).With("limits_reservation_id", reservationID).Info("deposit gated by limits")
			inner, innerErr := b.recordInner(innerCtx, req)
			if innerErr != nil {
				return innerErr
			}
			result = inner
			return nil
		})
	return result, gateErr
}

// recordInner is the pre-Gate body of Record: validation, the synchronous
// idempotency claim, the ledger posting, and settlement.
func (b *depositBusiness) recordInner(
	ctx context.Context,
	req *savingsv1.DepositRecordRequest,
) (*savingsv1.DepositObject, error) {
	logger := util.Log(ctx).WithField("method", "DepositBusiness.Record")

	accountID := req.GetSavingsAccountId()
	sa, err := b.saRepo.GetByID(ctx, accountID)
	if err != nil {
		return nil, ErrSavingsAccountNotFound
	}
	if err = assertAccountOperable(sa); err != nil {
		return nil, err
	}

	amountMinor, err := amountInAccountCurrency(req.GetAmount(), sa.CurrencyCode)
	if err != nil {
		return nil, err
	}

	dep := models.DepositFromAPI(ctx, &savingsv1.DepositObject{
		SavingsAccountId: accountID,
		Amount:           models.MinorUnitsToMoney(amountMinor, sa.CurrencyCode),
		PaymentReference: req.GetPaymentReference(),
		Channel:          req.GetChannel(),
		PayerReference:   req.GetPayerReference(),
		IdempotencyKey:   req.GetIdempotencyKey(),
	})
	dep.Status = int32(savingsv1.DepositStatus_DEPOSIT_STATUS_PENDING)
	dep.CopyPartitionInfo(&sa.BaseModel)

	claimed, created, claimErr := b.depRepo.Claim(ctx, dep)
	if claimErr != nil {
		logger.WithError(claimErr).Error("could not claim deposit row")
		return nil, claimErr
	}
	if !created &&
		claimed.Status == int32(savingsv1.DepositStatus_DEPOSIT_STATUS_COMPLETED) {
		return claimed.ToAPI(), nil
	}
	// Whether this call made the claim or inherited an unfinished one, the
	// rest of the flow converges on the same row: the transfer order is keyed
	// on its id and the settlement is guarded on it still being PENDING.
	dep = claimed
	amountMinor = dep.Amount

	toID, toErr := b.postDepositTransferOrder(ctx, logger, sa, dep, amountMinor)
	if toErr != nil {
		return nil, toErr
	}
	dep.LedgerTransactionID = toID

	if settleErr := b.depRepo.Settle(ctx, dep, amountMinor); settleErr != nil {
		logger.WithError(settleErr).Error("could not settle deposit against the running balance")
		return nil, settleErr
	}
	dep.Status = int32(savingsv1.DepositStatus_DEPOSIT_STATUS_COMPLETED)

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
			fieldChannel:          dep.Channel,
			"idempotency_key":     dep.IdempotencyKey,
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
	}

	req := connect.NewRequest(&operationsv1.TransferOrderExecuteRequest{
		Data: &operationsv1.TransferOrderObject{
			DebitAccountRef:  PaymentAccountRef(sa),
			CreditAccountRef: LedgerAccountRef(sa),
			Amount:           moneyx.FromMinorUnitsByCurrency(sa.CurrencyCode, amountMinor),
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
		andQueryVal[whereSavingsAccountIDEq] = req.GetSavingsAccountId()
	}
	if req.GetStatus() != savingsv1.DepositStatus_DEPOSIT_STATUS_UNSPECIFIED {
		andQueryVal[whereStatusEq] = int32(req.GetStatus())
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
