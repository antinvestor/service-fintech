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

	"connectrpc.com/connect/v2"

	"go.opentelemetry.io/otel/attribute"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
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
	"github.com/antinvestor/service-fintech/pkg/limits"
)

type WithdrawalBusiness interface {
	Request(ctx context.Context, req *savingsv1.WithdrawalRequestRequest) (*savingsv1.WithdrawalObject, error)
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
	wdrRepo           repository.WithdrawalRepository
	saRepo            repository.SavingsAccountRepository
	operationsCli     operationsv1connect.OperationsServiceClient
	auditWriter       *audit.Writer
	limitsCli         limitsv1connect.LimitsServiceClient
	limitsGateEnabled bool
	limitsGateMode    string
}

func NewWithdrawalBusiness(
	_ context.Context,
	wdrRepo repository.WithdrawalRepository,
	saRepo repository.SavingsAccountRepository,
	operationsCli operationsv1connect.OperationsServiceClient,
	auditWriter *audit.Writer,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsGateEnabled bool,
	limitsGateMode string,
) WithdrawalBusiness {
	return &withdrawalBusiness{
		wdrRepo:           wdrRepo,
		saRepo:            saRepo,
		operationsCli:     operationsCli,
		auditWriter:       auditWriter,
		limitsCli:         limitsCli,
		limitsGateEnabled: limitsGateEnabled,
		limitsGateMode:    limitsGateMode,
	}
}

// Request persists a PENDING withdrawal and places the balance hold in one
// database transaction, keyed on the caller's idempotency key. A retry with
// the same key loses the insert and returns the stored withdrawal, so a
// duplicated request can never place a second hold; an insufficient balance
// rolls the row back with it.
func (b *withdrawalBusiness) Request(
	ctx context.Context,
	req *savingsv1.WithdrawalRequestRequest,
) (*savingsv1.WithdrawalObject, error) {
	logger := util.Log(ctx).WithField("method", "WithdrawalBusiness.Request")

	if req.GetIdempotencyKey() == "" {
		return nil, ErrIdempotencyKeyRequired
	}

	sa, err := b.saRepo.GetByID(ctx, req.GetSavingsAccountId())
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

	wdr := models.WithdrawalFromAPI(ctx, &savingsv1.WithdrawalObject{
		SavingsAccountId:   sa.GetID(),
		Amount:             models.MinorUnitsToMoney(amountMinor, sa.CurrencyCode),
		Channel:            req.GetChannel(),
		RecipientReference: req.GetRecipientReference(),
		Reason:             req.GetReason(),
		IdempotencyKey:     req.GetIdempotencyKey(),
	})
	wdr.Status = int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_PENDING)
	wdr.CopyPartitionInfo(&sa.BaseModel)

	stored, created, claimErr := b.wdrRepo.ClaimWithHold(ctx, wdr)
	if claimErr != nil {
		if errors.Is(claimErr, repository.ErrInsufficientFunds) {
			return nil, ErrInsufficientBalance
		}
		if errors.Is(claimErr, repository.ErrSavingsBalanceNotFound) {
			return nil, ErrBalanceNotProvisioned
		}
		logger.WithError(claimErr).Error("could not claim withdrawal with balance hold")
		return nil, claimErr
	}
	if !created {
		return stored.ToAPI(), nil
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityWithdrawal,
		EntityID:   stored.GetID(),
		Action:     "savings.withdrawal.requested",
		Reason:     req.GetReason(),
		After: data.JSONMap{
			fieldStatus:       stored.Status,
			"reserved_amount": amountMinor,
		},
		Metadata: data.JSONMap{
			fieldSavingsAccountID: sa.GetID(),
			fieldOwnerID:          sa.OwnerID,
			fieldAmount:           amountMinor,
			fieldCurrency:         sa.CurrencyCode,
			fieldChannel:          stored.Channel,
			"idempotency_key":     stored.IdempotencyKey,
		},
		Parent: &stored.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for savings withdrawal request")
	})

	return stored.ToAPI(), nil
}

// Approve settles a pending withdrawal. The transfer order is posted first —
// it is idempotent on the withdrawal id, so a retry converges on one ledger
// posting — and only once it has landed does the hold turn into a debit. A
// failure anywhere before that leaves the reservation intact and the
// withdrawal still PENDING, so the money remains recoverable.
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
		// The limits service requires the client for savings actions: the
		// account owner. A group owner is not a field client, so an enforce
		// policy that filters on client attributes fails closed for it; keep
		// client-tier filters off savings actions that group accounts use.
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: sa.OwnerID},
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
		},
		limits.InPartition(sa.TenantID, sa.PartitionID),
	)
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

	toID, toErr := b.postWithdrawalTransferOrder(ctx, logger, sa, wdr)
	if toErr != nil {
		if payoutPermanentlyRejected(toErr) {
			// The payout will not pass on a retry (recipient or destination
			// refused, or the rail rejected it and operations reversed the
			// ledger leg): give the member their money back.
			if _, relErr := b.wdrRepo.ReleaseHold(ctx, wdr, "payout rejected: "+toErr.Error()); relErr != nil {
				logger.WithError(relErr).Error("could not release the hold after a rejected payout")
			}
			return nil, ErrWithdrawalPayoutRejected
		}
		return nil, toErr
	}
	wdr.LedgerTransactionID = toID

	if settleErr := b.wdrRepo.Settle(ctx, wdr); settleErr != nil {
		logger.WithError(settleErr).Error("could not settle withdrawal against the running balance")
		return nil, settleErr
	}
	wdr.Status = int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_COMPLETED)

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityWithdrawal,
		EntityID:   wdr.GetID(),
		Action:     "savings.withdrawal.approved",
		Reason:     "withdrawal approved, ledger posted, reservation settled",
		Before:     data.JSONMap{fieldStatus: int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_PENDING)},
		After: data.JSONMap{
			fieldStatus:              wdr.Status,
			fieldLedgerTransactionID: wdr.LedgerTransactionID,
		},
		Metadata: data.JSONMap{
			fieldSavingsAccountID: sa.GetID(),
			fieldOwnerID:          sa.OwnerID,
			fieldAmount:           wdr.Amount,
			fieldCurrency:         sa.CurrencyCode,
			fieldChannel:          wdr.Channel,
			"withdrawal_id":       id,
		},
		Parent: &wdr.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for savings withdrawal approval")
	})

	currencyAttr := attribute.String("currency", sa.CurrencyCode)
	SavingsWithdrawals.Add(ctx, 1, currencyAttr)
	SavingsWithdrawalsAmount.Add(ctx, float64(wdr.Amount)/minorUnitsPerMajor, currencyAttr)

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

	if sa.OwnerType == int32(savingsv1.SavingsAccountOwnerType_SAVINGS_ACCOUNT_OWNER_TYPE_GROUP) {
		// A group account has no single person to pay; its money leaves
		// through the group's own disbursement process.
		return "", ErrWithdrawalNeedsIndividualOwner
	}

	reference := fmt.Sprintf("withdrawal:%s", wdr.GetID())
	extraData := data.JSONMap{
		fieldSavingsAccountID: sa.GetID(),
		"withdrawal_id":       wdr.GetID(),
		fieldOwnerID:          sa.OwnerID,
		fieldChannel:          wdr.Channel,
		// Operations pays the owner's profile through the rail, and only to
		// a destination that is one of the owner's contacts.
		"recipient_client_id": sa.OwnerID,
		"payment_channel":     wdr.Channel,
		"payment_account_ref": wdr.RecipientReference,
	}

	req := &operationsv1.TransferOrderExecuteRequest{
		Data: &operationsv1.TransferOrderObject{
			DebitAccountRef:  LedgerAccountRef(sa),
			CreditAccountRef: PaymentAccountRef(sa),
			Amount:           moneyx.FromMinorUnitsByCurrency(sa.CurrencyCode, wdr.Amount),
			OrderType:        constants.SafeInt32FromInt(constants.TransferTypeDisbursement),
			Reference:        reference,
			Description:      "Savings withdrawal",
			ExtraData:        extraData.ToProtoStruct(),
		},
	}

	resp, execErr := b.operationsCli.TransferOrderExecute(ctx, req)
	if execErr != nil {
		logger.WithError(execErr).
			WithField("reference", reference).
			Error("could not execute transfer order for withdrawal")
		return "", fmt.Errorf("withdrawal transfer order %s failed: %w", reference, execErr)
	}
	return resp.GetData().GetId(), nil
}

// Cancel rejects a pending withdrawal and releases the hold. The status
// change and the release share one transaction and are guarded on the row
// still being PENDING, so a cancel racing an approve releases nothing.
func (b *withdrawalBusiness) Cancel(ctx context.Context, id, reason string) (*savingsv1.WithdrawalObject, error) {
	logger := util.Log(ctx).WithField("method", "WithdrawalBusiness.Cancel")

	wdr, err := b.wdrRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrWithdrawalNotFound
	}

	if wdr.Status != int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_PENDING) {
		return nil, ErrInvalidStatusTransition
	}

	released, relErr := b.wdrRepo.ReleaseHold(ctx, wdr, reason)
	if relErr != nil {
		logger.WithError(relErr).Error("could not release the hold for a cancelled withdrawal")
		return nil, relErr
	}
	if !released {
		// The row left PENDING between the read and the release, so this
		// call cancelled nothing and must not audit a cancellation.
		return nil, ErrInvalidStatusTransition
	}

	fresh, err := b.wdrRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrWithdrawalNotFound
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityWithdrawal,
		EntityID:   id,
		Action:     "savings.withdrawal.cancelled",
		Reason:     reason,
		Before:     data.JSONMap{fieldStatus: int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_PENDING)},
		After:      data.JSONMap{fieldStatus: fresh.Status},
		Metadata: data.JSONMap{
			fieldSavingsAccountID: fresh.SavingsAccountID,
			fieldAmount:           fresh.Amount,
			fieldCurrency:         fresh.CurrencyCode,
		},
		Parent: &fresh.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for savings withdrawal cancellation")
	})

	return fresh.ToAPI(), nil
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
		andQueryVal[whereSavingsAccountIDEq] = req.GetSavingsAccountId()
	}
	if req.GetStatus() != savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_UNSPECIFIED {
		andQueryVal[whereStatusEq] = int32(req.GetStatus())
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

// payoutPermanentlyRejected classifies an operations error. Operations
// guarantees that, for payout orders, these codes mean no money moved: the
// ledger leg never posted, or it posted and was reversed. Any other error
// may leave money in flight, so the hold is kept and the approval retried.
func payoutPermanentlyRejected(err error) bool {
	code := connect.CodeOf(err)
	return code == connect.CodeInvalidArgument || code == connect.CodeFailedPrecondition ||
		code == connect.CodePermissionDenied || code == connect.CodeNotFound
}
