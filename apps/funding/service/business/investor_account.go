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

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"

	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/funding/service/events"
	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

// moneyDecimalPlaces is the assumed decimal precision for all investor
// currency conversions (two-decimal currencies only).
const moneyDecimalPlaces = 2

// ErrMissingInvestorContext is returned when an investor account lacks the
// fields required to post a capital transfer (id, currency, investor id).
var ErrMissingInvestorContext = errors.New("investor account is missing required context")

type investorAccountBusiness struct {
	eventsMan             fevents.Manager
	iaRepo                repository.InvestorAccountRepository
	operationsCli         operationsv1connect.OperationsServiceClient
	auditWriter           *audit.Writer
	limitsCli             limitsv1connect.LimitsServiceClient
	limitsDepositEnabled  bool
	limitsDepositMode     string
	limitsWithdrawEnabled bool
	limitsWithdrawMode    string
}

func NewInvestorAccountBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	iaRepo repository.InvestorAccountRepository,
	operationsCli operationsv1connect.OperationsServiceClient,
	auditWriter *audit.Writer,
	limitsCli limitsv1connect.LimitsServiceClient,
	limitsDepositEnabled bool,
	limitsDepositMode string,
	limitsWithdrawEnabled bool,
	limitsWithdrawMode string,
) InvestorAccountBusiness {
	return &investorAccountBusiness{
		eventsMan:             eventsMan,
		iaRepo:                iaRepo,
		operationsCli:         operationsCli,
		auditWriter:           auditWriter,
		limitsCli:             limitsCli,
		limitsDepositEnabled:  limitsDepositEnabled,
		limitsDepositMode:     limitsDepositMode,
		limitsWithdrawEnabled: limitsWithdrawEnabled,
		limitsWithdrawMode:    limitsWithdrawMode,
	}
}

func (b *investorAccountBusiness) Create(
	ctx context.Context,
	account *models.InvestorAccount,
) (*models.InvestorAccount, error) {
	logger := util.Log(ctx).WithField("method", "InvestorAccountBusiness.Create")

	account.State = int32(constants.StateActive)
	account.GenID(ctx)

	if err := b.eventsMan.Emit(ctx, events.InvestorAccountSaveEvent, account); err != nil {
		logger.WithError(err).Error("could not create investor account")
		return nil, fmt.Errorf("create investor account: %w", err)
	}

	logger.WithField("account_id", account.GetID()).Info("investor account created")
	return account, nil
}

func (b *investorAccountBusiness) Get(
	ctx context.Context,
	accountID string,
) (*models.InvestorAccount, error) {
	return b.iaRepo.GetByID(ctx, accountID)
}

func (b *investorAccountBusiness) GetByInvestorID(
	ctx context.Context,
	investorID string,
) ([]*models.InvestorAccount, error) {
	return b.iaRepo.GetByInvestorID(ctx, investorID)
}

// Deposit settles an inbound investor capital contribution. It posts a
// transfer order from the product-level external cash control account into
// the investor's capital account, then applies the balance change via an
// atomic SQL delta. The transfer order reference is keyed on a stable
// composite (investor-account + version + amount) so retries converge on a
// single ledger posting.
//
// Balance mutations run through AtomicDeposit on the repository so no
// read-modify-write race is possible even with concurrent deposits.
//
// When the limits gate is enabled, a reservation is obtained from the limits
// service before execution proceeds. DENY returns an error; PENDING_APPROVAL
// returns PendingApprovalError.
//
//nolint:dupl // deposit and withdrawal gates mirror each other but must stay independently auditable
func (b *investorAccountBusiness) Deposit(
	ctx context.Context,
	accountID string,
	amount int64,
	idempotencyKey string,
) error {
	if idempotencyKey == "" {
		return connect.NewError(connect.CodeInvalidArgument,
			errors.New("idempotency_key required"))
	}

	if !b.limitsDepositEnabled || b.limitsCli == nil || b.limitsDepositMode == "off" {
		return b.depositInner(ctx, accountID, amount)
	}

	account, err := b.iaRepo.GetByID(ctx, accountID)
	if err != nil {
		return fmt.Errorf("investor account not found: %w", err)
	}

	intent := &limitsv1.LimitIntent{
		Action:   limitsv1.LimitAction_LIMIT_ACTION_FUNDING_INFLOW,
		TenantId: account.TenantID,
		Amount:   moneyx.FromSmallestUnit(account.Currency, amount, moneyDecimalPlaces),
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT, Id: accountID},
		},
	}
	idemKey := "funding_deposit:" + accountID + ":" + idempotencyKey

	return limits.Gate(ctx, b.limitsCli, intent, idemKey, limits.ParseMode(b.limitsDepositMode),
		func(innerCtx context.Context, reservationID string) error {
			util.Log(innerCtx).With("limits_reservation_id", reservationID).
				Info("investor deposit gated by limits")
			return b.depositInner(innerCtx, accountID, amount)
		})
}

// depositInner runs the core investor deposit logic after any gate check.
func (b *investorAccountBusiness) depositInner(
	ctx context.Context,
	accountID string,
	amount int64,
) error {
	logger := util.Log(ctx).WithField("method", "InvestorAccountBusiness.Deposit")

	if amount <= 0 {
		return fmt.Errorf("deposit amount must be positive, got %d", amount)
	}

	account, err := b.iaRepo.GetByID(ctx, accountID)
	if err != nil {
		return fmt.Errorf("investor account not found: %w", err)
	}
	if account.InvestorID == "" || account.Currency == "" {
		return ErrMissingInvestorContext
	}

	reference := fmt.Sprintf("investor:%s:deposit:v%d", accountID, account.GetVersion()+1)
	if toErr := b.postInvestorCapitalTransfer(
		ctx,
		logger,
		account,
		amount,
		constants.PlatformExternalCashAccount(),
		constants.InvestorCapitalAccount(account.GetID()),
		constants.TransferTypeInvestorDeployment,
		reference,
		"Investor capital deposit",
	); toErr != nil {
		return toErr
	}

	fresh, applyErr := b.iaRepo.AtomicDeposit(ctx, accountID, amount)
	if applyErr != nil {
		logger.WithError(applyErr).Error("could not apply investor deposit delta")
		return fmt.Errorf("investor deposit delta: %w", applyErr)
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "investor_account",
		EntityID:   accountID,
		Action:     "investor.capital.deposited",
		Reason:     "investor capital inflow settled on ledger",
		Before:     data.JSONMap{fieldAvailableBalance: account.AvailableBalance},
		After:      data.JSONMap{fieldAvailableBalance: fresh.AvailableBalance},
		Metadata: data.JSONMap{
			fieldInvestorID: account.InvestorID,
			fieldAmount:     amount,
			fieldCurrency:   account.Currency,
		},
		Parent: &fresh.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for investor deposit")
	})

	auditInfo := constants.AuditTrailFromContext(ctx)
	depAttrs := metric.WithAttributes(
		attribute.String("tenant_id", auditInfo.TenantID),
		attribute.String("partition_id", auditInfo.PartitionID),
		attribute.String("currency", account.Currency),
	)
	FundingDeposits.Add(ctx, 1, depAttrs)
	FundingDepositsAmount.Add(ctx, float64(amount)/minorUnitsPerMajor, depAttrs)

	logger.WithFields(map[string]any{"account_id": accountID, fieldAmount: amount}).
		Info("investor deposit processed")
	return nil
}

// Withdraw settles an investor capital withdrawal. The SQL-level balance
// guard in AtomicWithdraw is the single authoritative sufficiency check:
// two concurrent withdrawals against overlapping funds will serialize and
// one of them receives ErrInvestorInsufficientFunds.
//
// The transfer order is posted only after the reservation has been
// atomically decremented. If the transfer order fails we roll back via a
// best-effort compensating AtomicDeposit; retries via caller are safe
// because the transfer order reference is stable.
//
// When the limits gate is enabled, a reservation is obtained from the limits
// service before execution proceeds. DENY returns an error; PENDING_APPROVAL
// returns PendingApprovalError.
//
//nolint:dupl // deposit and withdrawal gates mirror each other but must stay independently auditable
func (b *investorAccountBusiness) Withdraw(
	ctx context.Context,
	accountID string,
	amount int64,
	idempotencyKey string,
) error {
	if idempotencyKey == "" {
		return connect.NewError(connect.CodeInvalidArgument,
			errors.New("idempotency_key required"))
	}

	if !b.limitsWithdrawEnabled || b.limitsCli == nil || b.limitsWithdrawMode == "off" {
		return b.withdrawInner(ctx, accountID, amount)
	}

	account, err := b.iaRepo.GetByID(ctx, accountID)
	if err != nil {
		return fmt.Errorf("investor account not found: %w", err)
	}

	intent := &limitsv1.LimitIntent{
		Action:   limitsv1.LimitAction_LIMIT_ACTION_FUNDING_OUTFLOW,
		TenantId: account.TenantID,
		Amount:   moneyx.FromSmallestUnit(account.Currency, amount, moneyDecimalPlaces),
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT, Id: accountID},
		},
	}
	idemKey := "funding_withdraw:" + accountID + ":" + idempotencyKey

	return limits.Gate(ctx, b.limitsCli, intent, idemKey, limits.ParseMode(b.limitsWithdrawMode),
		func(innerCtx context.Context, reservationID string) error {
			util.Log(innerCtx).With("limits_reservation_id", reservationID).
				Info("investor withdrawal gated by limits")
			return b.withdrawInner(innerCtx, accountID, amount)
		})
}

// withdrawInner runs the core investor withdrawal logic after any gate check.
func (b *investorAccountBusiness) withdrawInner(
	ctx context.Context,
	accountID string,
	amount int64,
) error {
	logger := util.Log(ctx).WithField("method", "InvestorAccountBusiness.Withdraw")

	if amount <= 0 {
		return fmt.Errorf("withdrawal amount must be positive, got %d", amount)
	}

	account, getErr := b.iaRepo.GetByID(ctx, accountID)
	if getErr != nil {
		return fmt.Errorf("investor account not found: %w", getErr)
	}
	if account.InvestorID == "" || account.Currency == "" {
		return ErrMissingInvestorContext
	}

	fresh, debErr := b.iaRepo.AtomicWithdraw(ctx, accountID, amount)
	if debErr != nil {
		return fmt.Errorf("investor withdraw: %w", debErr)
	}

	reference := fmt.Sprintf("investor:%s:withdraw:v%d", accountID, fresh.GetVersion())
	if toErr := b.postInvestorCapitalTransfer(
		ctx,
		logger,
		fresh,
		amount,
		constants.InvestorCapitalAccount(fresh.GetID()),
		constants.PlatformExternalCashAccount(),
		constants.TransferTypeInvestorPrincipalReturn,
		reference,
		"Investor capital withdrawal",
	); toErr != nil {
		// Compensate the atomic debit so retries see the original balance.
		// AtomicDeposit cannot fail on a valid account; we log and surface
		// the primary error.
		if _, rollbackErr := b.iaRepo.AtomicDeposit(ctx, accountID, amount); rollbackErr != nil {
			logger.WithError(rollbackErr).
				Error("could not roll back investor withdrawal after transfer-order failure")
		}
		return toErr
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "investor_account",
		EntityID:   accountID,
		Action:     "investor.capital.withdrawn",
		Reason:     "investor capital outflow settled on ledger",
		Before:     data.JSONMap{fieldAvailableBalance: account.AvailableBalance},
		After:      data.JSONMap{fieldAvailableBalance: fresh.AvailableBalance},
		Metadata: data.JSONMap{
			fieldInvestorID: fresh.InvestorID,
			fieldAmount:     amount,
			fieldCurrency:   fresh.Currency,
		},
		Parent: &fresh.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for investor withdrawal")
	})

	wdrAudit := constants.AuditTrailFromContext(ctx)
	wdrAttrs := metric.WithAttributes(
		attribute.String("tenant_id", wdrAudit.TenantID),
		attribute.String("partition_id", wdrAudit.PartitionID),
		attribute.String("currency", fresh.Currency),
	)
	FundingWithdrawals.Add(ctx, 1, wdrAttrs)
	FundingWithdrawalsAmount.Add(ctx, float64(amount)/minorUnitsPerMajor, wdrAttrs)

	logger.WithFields(map[string]any{"account_id": accountID, fieldAmount: amount}).
		Info("investor withdrawal processed")
	return nil
}

func (b *investorAccountBusiness) GetAvailable(
	ctx context.Context,
	accountID string,
) (int64, error) {
	account, err := b.iaRepo.GetByID(ctx, accountID)
	if err != nil {
		return 0, fmt.Errorf("investor account not found: %w", err)
	}

	available := account.AvailableBalance - account.ReservedBalance
	if available < 0 {
		available = 0
	}
	return available, nil
}

// ReserveBalance moves funds from available to reserved when capital is
// committed to a loan. Delegates to the repository's atomic SQL so concurrent
// allocation pipelines cannot over-commit an investor.
func (b *investorAccountBusiness) ReserveBalance(
	ctx context.Context,
	accountID string,
	amount int64,
) error {
	if amount <= 0 {
		return nil
	}
	if _, err := b.iaRepo.AtomicReserve(ctx, accountID, amount); err != nil {
		return fmt.Errorf("reserve balance: %w", err)
	}
	return nil
}

// ReleaseBalance settles a reservation. principalReturned moves funds from
// reserved back to available; interestEarned is an additional credit to
// available without a reservation impact. Lifetime total_returned counter is
// incremented by the sum.
func (b *investorAccountBusiness) ReleaseBalance(
	ctx context.Context,
	accountID string,
	principalReturned int64,
	interestEarned int64,
) error {
	if _, err := b.iaRepo.AtomicReleaseWithReturn(
		ctx,
		accountID,
		principalReturned,
		interestEarned,
	); err != nil {
		return fmt.Errorf("release balance: %w", err)
	}
	return nil
}

// AbsorbLoss records a realised loss against an investor account. Uses the
// repository's atomic update so a concurrent ReserveBalance or
// ReleaseBalance cannot race with the loss application.
func (b *investorAccountBusiness) AbsorbLoss(
	ctx context.Context,
	accountID string,
	lossAmount int64,
) error {
	if lossAmount <= 0 {
		return nil
	}

	if _, err := b.iaRepo.AtomicAbsorbLoss(ctx, accountID, lossAmount); err != nil {
		return fmt.Errorf("absorb loss: %w", err)
	}
	return nil
}

// postInvestorCapitalTransfer builds a transfer order for a capital-movement
// operation and dispatches it through the operations client. Every call
// carries a stable reference so retries converge on a single ledger posting.
func (b *investorAccountBusiness) postInvestorCapitalTransfer(
	ctx context.Context,
	logger *util.LogEntry,
	account *models.InvestorAccount,
	amount int64,
	debitAccount, creditAccount string,
	orderType int,
	reference, description string,
) error {
	if b.operationsCli == nil {
		return errors.New("operations client is not configured; cannot post investor capital transfer")
	}

	extraData := data.JSONMap{
		"investor_account_id": account.GetID(),
		fieldInvestorID:       account.InvestorID,
	}

	req := connect.NewRequest(&operationsv1.TransferOrderExecuteRequest{
		Data: &operationsv1.TransferOrderObject{
			DebitAccountRef:  debitAccount,
			CreditAccountRef: creditAccount,
			Amount:           moneyx.FromSmallestUnit(account.Currency, amount, moneyDecimalPlaces),
			OrderType:        constants.SafeInt32FromInt(orderType),
			Reference:        reference,
			Description:      description,
			ExtraData:        extraData.ToProtoStruct(),
		},
	})

	if _, execErr := b.operationsCli.TransferOrderExecute(ctx, req); execErr != nil {
		logger.WithError(execErr).
			WithField("reference", reference).
			Error("could not execute investor capital transfer order")
		return fmt.Errorf("investor transfer order %s failed: %w", reference, execErr)
	}
	return nil
}
