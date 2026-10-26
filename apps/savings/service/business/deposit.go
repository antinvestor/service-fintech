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
	"strings"

	"context"
	"errors"
	"fmt"
	"strconv"

	"github.com/pitabwire/frame/v3/security"

	"github.com/antinvestor/service-fintech/pkg/transferorder"

	"go.opentelemetry.io/otel/attribute"

	"buf.build/gen/go/antinvestor/operations/connectrpc/go/v2/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
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
	depRepo       repository.DepositRepository
	saRepo        repository.SavingsAccountRepository
	operationsCli operationsv1connect.OperationsServiceClient
	auditWriter   *audit.Writer
}

func NewDepositBusiness(
	_ context.Context,
	depRepo repository.DepositRepository,
	saRepo repository.SavingsAccountRepository,
	operationsCli operationsv1connect.OperationsServiceClient,
	auditWriter *audit.Writer,
) DepositBusiness {
	return &depositBusiness{
		depRepo:       depRepo,
		saRepo:        saRepo,
		operationsCli: operationsCli,
		auditWriter:   auditWriter,
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
	// A deposit is the saver's own payment, recorded by the payment rail
	// (operations matches it to their account). Nobody records one by hand,
	// and no one takes cash on a saver's behalf.
	if claims := security.ClaimsFromContext(ctx); claims == nil || !claims.IsInternalSystem() {
		return nil, ErrDepositRecordInternalOnly
	}
	if strings.EqualFold(strings.TrimSpace(req.GetChannel()), depositChannelCash) {
		return nil, ErrCashDepositRefused
	}

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

	// No transaction limit applies here: the money has already arrived on
	// the rail, so refusing to apply it would only strand the saver's
	// payment. Limits gate money leaving, not money received.
	return b.recordInner(ctx, req)
}

// recordInner is the body of Record: validation, the synchronous
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

	req := &operationsv1.TransferOrderExecuteRequest{
		Data: transferorder.Typed(&operationsv1.TransferOrderObject{
			DebitAccountRef:  PaymentAccountRef(sa),
			CreditAccountRef: LedgerAccountRef(sa),
			Amount:           moneyx.FromMinorUnitsByCurrency(sa.CurrencyCode, amountMinor),
			Reference:        reference,
			Description:      "Savings deposit",
			ExtraData:        extraData.ToProtoStruct(),
		}, constants.TransferTypePeriodicSaving),
	}

	resp, execErr := b.operationsCli.TransferOrderExecute(ctx, req)
	if execErr != nil {
		logger.WithError(execErr).
			WithField("reference", reference).
			Error("could not execute transfer order for deposit")
		return "", fmt.Errorf("deposit transfer order %s failed: %w", reference, execErr)
	}
	return resp.GetData().GetId(), nil
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
