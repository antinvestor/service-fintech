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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/funding/service/events"
	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/limits"
)

// ErrMissingInvestorContext is returned when an investor account lacks the
// fields required to post a capital transfer (id, currency, investor id).
var ErrMissingInvestorContext = apperrors.NewError(
	apperrors.Unprocessable, "investor account is missing required context")

// ErrInvestorAccountNotFound is returned when the target account does not exist.
var ErrInvestorAccountNotFound = apperrors.NewError(apperrors.NotFound, "investor account not found")

// ErrIdempotencyKeyRequired is returned when a capital movement arrives
// without the key that makes it repeatable.
var ErrIdempotencyKeyRequired = apperrors.NewError(apperrors.BadRequest, "idempotency_key is required")

// ErrInvalidInterestRate is returned when min_interest_rate is not a decimal
// percentage string such as "12.50".
var ErrInvalidInterestRate = apperrors.NewError(apperrors.BadRequest, "min_interest_rate is invalid")

// ErrAmountNotPositive is returned for a zero or negative money amount.
var ErrAmountNotPositive = apperrors.NewError(apperrors.BadRequest, "amount must be positive")

// ErrCurrencyMismatch is returned when a request is denominated in a currency
// the account does not hold.
var ErrCurrencyMismatch = apperrors.NewError(
	apperrors.BadRequest, "amount currency does not match the account currency")

// ErrCurrencyRequired is returned when an account is created without a currency.
var ErrCurrencyRequired = apperrors.NewError(apperrors.BadRequest, "currency_code is required")

type investorAccountBusiness struct {
	eventsMan             fevents.Manager
	iaRepo                repository.InvestorAccountRepository
	icmRepo               repository.InvestorCapitalMovementRepository
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
	icmRepo repository.InvestorCapitalMovementRepository,
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
		icmRepo:               icmRepo,
		operationsCli:         operationsCli,
		auditWriter:           auditWriter,
		limitsCli:             limitsCli,
		limitsDepositEnabled:  limitsDepositEnabled,
		limitsDepositMode:     limitsDepositMode,
		limitsWithdrawEnabled: limitsWithdrawEnabled,
		limitsWithdrawMode:    limitsWithdrawMode,
	}
}

// Save creates or updates an investor account's profile: its name, mandate
// (allowed products, regions, group affiliations, exposure cap, minimum
// rate) and properties. It never writes a balance. Capital only enters or
// leaves through Deposit and Withdraw, and reserved / deployed / returned
// totals only move with allocations, so a caller holding the manage
// permission cannot mint capital by echoing a balance back at this endpoint.
// State is likewise not taken from the payload; use SetState.
func (b *investorAccountBusiness) Save(
	ctx context.Context,
	account *models.InvestorAccount,
) (*models.InvestorAccount, error) {
	logger := util.Log(ctx).WithField("method", "InvestorAccountBusiness.Save")

	if account.InvestorID == "" {
		return nil, ErrMissingInvestorContext
	}
	if account.Currency == "" {
		return nil, ErrCurrencyRequired
	}

	stored, err := b.iaRepo.GetByID(ctx, account.GetID())
	if err == nil && stored != nil {
		mergeInvestorMandate(stored, account)
		account = stored
	} else {
		account.GenID(ctx)
		account.State = int32(constants.StateActive)
		account.AvailableBalance = 0
		account.ReservedBalance = 0
		account.TotalDeployed = 0
		account.TotalReturned = 0
		account.TotalLost = 0
		account.LastDeployedAt = nil
	}

	if emitErr := b.eventsMan.Emit(ctx, events.InvestorAccountSaveEvent, account); emitErr != nil {
		logger.WithError(emitErr).Error("could not save investor account")
		return nil, fmt.Errorf("save investor account: %w", emitErr)
	}

	logger.WithField("account_id", account.GetID()).Info("investor account saved")
	return account, nil
}

// mergeInvestorMandate copies the caller-settable fields of an investor
// account onto the stored row, leaving every balance and lifetime counter
// exactly as the database holds it.
func mergeInvestorMandate(stored, incoming *models.InvestorAccount) {
	stored.AccountName = incoming.AccountName
	stored.MaxExposure = incoming.MaxExposure
	stored.MinInterestRate = incoming.MinInterestRate
	stored.AllowedProducts = incoming.AllowedProducts
	stored.AllowedRegions = incoming.AllowedRegions
	stored.GroupAffiliations = incoming.GroupAffiliations
	stored.Properties = incoming.Properties
}

// SetState moves an investor account between lifecycle states. It is the only
// path that writes State, so a state change is always an explicit act.
func (b *investorAccountBusiness) SetState(
	ctx context.Context,
	accountID string,
	state int32,
) (*models.InvestorAccount, error) {
	account, err := b.iaRepo.GetByID(ctx, accountID)
	if err != nil {
		return nil, ErrInvestorAccountNotFound
	}
	account.State = state
	if emitErr := b.eventsMan.Emit(ctx, events.InvestorAccountSaveEvent, account); emitErr != nil {
		return nil, fmt.Errorf("set investor account state: %w", emitErr)
	}
	return account, nil
}

func (b *investorAccountBusiness) Get(
	ctx context.Context,
	accountID string,
) (*models.InvestorAccount, error) {
	return b.iaRepo.GetByID(ctx, accountID)
}

// Search lists investor accounts. investor_id and currency_code narrow the
// result when supplied; neither is required, and the page cursor is honoured
// so a caller can walk the whole set rather than receiving a silently
// truncated first page.
func (b *investorAccountBusiness) Search(
	ctx context.Context,
	req *fundingv1.InvestorAccountSearchRequest,
) ([]*models.InvestorAccount, error) {
	limit, offset := pageWindow(req.GetCursor())
	return b.iaRepo.List(ctx, repository.InvestorAccountFilter{
		InvestorID: req.GetInvestorId(),
		Currency:   req.GetCurrencyCode(),
		Limit:      limit,
		Offset:     offset,
	})
}

// pageWindow turns a page cursor into a bounded limit/offset pair. An absent
// or oversized cursor is clamped so a caller cannot ask for the whole table.
func pageWindow(cursor *commonv1.PageCursor) (int, int) {
	limit := int(cursor.GetLimit())
	if limit <= 0 || limit > maxPageLimit {
		limit = defaultPageLimit
	}
	page, err := strconv.Atoi(cursor.GetPage())
	if err != nil || page < 0 {
		page = 0
	}
	return limit, page * limit
}

// Deposit settles an inbound investor capital contribution.
//
// The movement row is written before any money moves and is unique on
// (investor_account_id, idempotency_key), so a retry after a timeout — or a
// second concurrent call carrying the same key — loses the insert and returns
// the original movement without posting again. The ledger reference is
// derived from that row's id rather than from the account version, so two
// callers can never collide on one reference or drift onto two.
//
//nolint:dupl // deposit and withdrawal gates mirror each other but must stay independently auditable
func (b *investorAccountBusiness) Deposit(
	ctx context.Context,
	accountID string,
	amount *commonv1.Money,
	idempotencyKey string,
) error {
	account, minor, err := b.prepareMovement(ctx, accountID, amount, idempotencyKey)
	if err != nil {
		return err
	}

	if !b.limitsDepositEnabled || b.limitsCli == nil || b.limitsDepositMode == "off" {
		return b.depositInner(ctx, account, minor, idempotencyKey)
	}

	intent := &limitsv1.LimitIntent{
		Action:   limitsv1.LimitAction_LIMIT_ACTION_FUNDING_INFLOW,
		TenantId: account.TenantID,
		Amount:   moneyx.FromMinorUnitsByCurrency(account.Currency, minor),
		// The limits service requires the organization for funding actions;
		// an investor account belongs to the lender that is its tenant.
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT, Id: accountID},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: account.TenantID},
		},
	}
	idemKey := "funding_deposit:" + accountID + ":" + idempotencyKey

	return limits.Gate(ctx, b.limitsCli, intent, idemKey, limits.ParseMode(b.limitsDepositMode),
		func(innerCtx context.Context, reservationID string) error {
			util.Log(innerCtx).With("limits_reservation_id", reservationID).
				Info("investor deposit gated by limits")
			return b.depositInner(innerCtx, account, minor, idempotencyKey)
		},
		limits.InPartition(account.TenantID, account.PartitionID),
	)
}

// prepareMovement resolves and validates the account and amount that a
// capital movement will apply to.
func (b *investorAccountBusiness) prepareMovement(
	ctx context.Context,
	accountID string,
	amount *commonv1.Money,
	idempotencyKey string,
) (*models.InvestorAccount, int64, error) {
	if idempotencyKey == "" {
		return nil, 0, ErrIdempotencyKeyRequired
	}

	account, err := b.iaRepo.GetByID(ctx, accountID)
	if err != nil {
		return nil, 0, ErrInvestorAccountNotFound
	}
	if account.InvestorID == "" || account.Currency == "" {
		return nil, 0, ErrMissingInvestorContext
	}
	if amount.GetCurrencyCode() != account.Currency {
		return nil, 0, ErrCurrencyMismatch
	}

	minor := moneyx.ToSmallestUnit(amount, moneyx.Decimals(account.Currency))
	if minor <= 0 {
		return nil, 0, ErrAmountNotPositive
	}
	return account, minor, nil
}

// claimMovement takes the idempotency lock for one capital movement.
func (b *investorAccountBusiness) claimMovement(
	ctx context.Context,
	account *models.InvestorAccount,
	amount int64,
	direction models.CapitalMovementDirection,
	idempotencyKey string,
) (*models.InvestorCapitalMovement, bool, error) {
	movement := &models.InvestorCapitalMovement{
		InvestorAccountID: account.GetID(),
		Direction:         int32(direction),
		Amount:            amount,
		Currency:          account.Currency,
		IdempotencyKey:    idempotencyKey,
		Status:            models.CapitalMovementPending,
	}
	movement.GenID(ctx)
	movement.CopyPartitionInfo(&account.BaseModel)
	return b.icmRepo.Claim(ctx, movement)
}

// depositInner runs the core investor deposit logic after any gate check.
func (b *investorAccountBusiness) depositInner(
	ctx context.Context,
	account *models.InvestorAccount,
	amount int64,
	idempotencyKey string,
) error {
	logger := util.Log(ctx).WithField("method", "InvestorAccountBusiness.Deposit")

	movement, created, claimErr := b.claimMovement(
		ctx, account, amount, models.CapitalMovementDeposit, idempotencyKey)
	if claimErr != nil {
		logger.WithError(claimErr).Error("could not claim investor capital movement")
		return claimErr
	}
	if !created && movement.Status == models.CapitalMovementCompleted {
		return nil
	}
	// A claimed but uncompleted movement belongs to an attempt that died
	// part-way, so this call resumes it on the same row rather than
	// reporting a success nothing performed. The ledger reference is derived
	// from the movement id, which makes the re-post a no-op for operations,
	// and the credit is guarded on the row still being pending.
	amount = movement.Amount

	if toErr := b.postInvestorCapitalTransfer(
		ctx,
		logger,
		account,
		amount,
		constants.PlatformExternalCashAccount(),
		constants.InvestorCapitalAccount(account.GetID()),
		constants.TransferTypeInvestorDeployment,
		capitalTransferReference(movement),
		"Investor capital deposit",
	); toErr != nil {
		return toErr
	}

	credited, applyErr := b.icmRepo.CreditDeposit(ctx, movement)
	if applyErr != nil {
		logger.WithError(applyErr).Error("could not apply investor deposit delta")
		return fmt.Errorf("investor deposit delta: %w", applyErr)
	}
	if !credited {
		return nil
	}

	fresh, freshErr := b.iaRepo.GetByID(ctx, account.GetID())
	if freshErr != nil {
		return fmt.Errorf("investor deposit delta: %w", freshErr)
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "investor_account",
		EntityID:   account.GetID(),
		Action:     "investor.capital.deposited",
		Reason:     "investor capital inflow settled on ledger",
		Before:     data.JSONMap{fieldAvailableBalance: account.AvailableBalance},
		After:      data.JSONMap{fieldAvailableBalance: fresh.AvailableBalance},
		Metadata: data.JSONMap{
			fieldInvestorID: account.InvestorID,
			fieldAmount:     amount,
			fieldCurrency:   account.Currency,
			"movement_id":   movement.GetID(),
		},
		Parent: &fresh.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for investor deposit")
	})

	depCurrencyAttr := attribute.String("currency", account.Currency)
	FundingDeposits.Add(ctx, 1, depCurrencyAttr)
	FundingDepositsAmount.Add(ctx, float64(amount)/minorUnitsPerMajor, depCurrencyAttr)

	logger.WithFields(map[string]any{"account_id": account.GetID(), fieldAmount: amount}).
		Info("investor deposit processed")
	return nil
}

// capitalTransferReference derives the operations idempotency key for a
// capital movement from the movement row itself, so the reference is stable
// across retries and unique across concurrent callers.
func capitalTransferReference(movement *models.InvestorCapitalMovement) string {
	return "investor_capital_movement:" + movement.GetID()
}

// Withdraw settles an investor capital withdrawal. As with Deposit the
// movement row is the idempotency record. The SQL-level balance guard in
// DebitWithdrawal is the authoritative sufficiency check: two concurrent
// withdrawals against overlapping funds serialize and one receives
// ErrInvestorInsufficientFunds.
//
//nolint:dupl // deposit and withdrawal gates mirror each other but must stay independently auditable
func (b *investorAccountBusiness) Withdraw(
	ctx context.Context,
	accountID string,
	amount *commonv1.Money,
	idempotencyKey string,
) error {
	account, minor, err := b.prepareMovement(ctx, accountID, amount, idempotencyKey)
	if err != nil {
		return err
	}

	if !b.limitsWithdrawEnabled || b.limitsCli == nil || b.limitsWithdrawMode == "off" {
		return b.withdrawInner(ctx, account, minor, idempotencyKey)
	}

	intent := &limitsv1.LimitIntent{
		Action:   limitsv1.LimitAction_LIMIT_ACTION_FUNDING_OUTFLOW,
		TenantId: account.TenantID,
		Amount:   moneyx.FromMinorUnitsByCurrency(account.Currency, minor),
		// The limits service requires the organization for funding actions;
		// an investor account belongs to the lender that is its tenant.
		Subjects: []*limitsv1.SubjectRef{
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT, Id: accountID},
			{Type: limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION, Id: account.TenantID},
		},
	}
	idemKey := "funding_withdraw:" + accountID + ":" + idempotencyKey

	return limits.Gate(ctx, b.limitsCli, intent, idemKey, limits.ParseMode(b.limitsWithdrawMode),
		func(innerCtx context.Context, reservationID string) error {
			util.Log(innerCtx).With("limits_reservation_id", reservationID).
				Info("investor withdrawal gated by limits")
			return b.withdrawInner(innerCtx, account, minor, idempotencyKey)
		},
		limits.InPartition(account.TenantID, account.PartitionID),
	)
}

// withdrawInner runs the core investor withdrawal logic after any gate check.
func (b *investorAccountBusiness) withdrawInner(
	ctx context.Context,
	account *models.InvestorAccount,
	amount int64,
	idempotencyKey string,
) error {
	logger := util.Log(ctx).WithField("method", "InvestorAccountBusiness.Withdraw")

	movement, created, claimErr := b.claimMovement(
		ctx, account, amount, models.CapitalMovementWithdraw, idempotencyKey)
	if claimErr != nil {
		logger.WithError(claimErr).Error("could not claim investor capital movement")
		return claimErr
	}
	if !created && movement.Status == models.CapitalMovementCompleted {
		return nil
	}
	amount = movement.Amount

	// The debit and the movement's move out of PENDING happen in one
	// transaction, so a movement that is still pending is one whose funds
	// have not left, and a resumed attempt debits exactly once.
	if movement.Status == models.CapitalMovementPending {
		if _, debErr := b.icmRepo.DebitWithdrawal(ctx, movement); debErr != nil {
			return fmt.Errorf("investor withdraw: %w", debErr)
		}
	}

	if toErr := b.postInvestorCapitalTransfer(
		ctx,
		logger,
		account,
		amount,
		constants.InvestorCapitalAccount(account.GetID()),
		constants.PlatformExternalCashAccount(),
		constants.TransferTypeInvestorPrincipalReturn,
		capitalTransferReference(movement),
		"Investor capital withdrawal",
	); toErr != nil {
		// Hand the funds back and return the movement to pending so a retry
		// runs the whole flow again from a balance that never moved.
		if revertErr := b.icmRepo.RevertWithdrawalDebit(ctx, movement); revertErr != nil {
			logger.WithError(revertErr).
				Error("could not roll back investor withdrawal after transfer-order failure")
		}
		return toErr
	}

	if completeErr := b.icmRepo.MarkCompleted(ctx, movement.GetID()); completeErr != nil {
		logger.WithError(completeErr).Error("could not mark investor capital movement completed")
		return completeErr
	}

	fresh, freshErr := b.iaRepo.GetByID(ctx, account.GetID())
	if freshErr != nil {
		return fmt.Errorf("investor withdraw: %w", freshErr)
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "investor_account",
		EntityID:   account.GetID(),
		Action:     "investor.capital.withdrawn",
		Reason:     "investor capital outflow settled on ledger",
		Before:     data.JSONMap{fieldAvailableBalance: account.AvailableBalance},
		After:      data.JSONMap{fieldAvailableBalance: fresh.AvailableBalance},
		Metadata: data.JSONMap{
			fieldInvestorID: fresh.InvestorID,
			fieldAmount:     amount,
			fieldCurrency:   fresh.Currency,
			"movement_id":   movement.GetID(),
		},
		Parent: &fresh.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for investor withdrawal")
	})

	wdrCurrencyAttr := attribute.String("currency", fresh.Currency)
	FundingWithdrawals.Add(ctx, 1, wdrCurrencyAttr)
	FundingWithdrawalsAmount.Add(ctx, float64(amount)/minorUnitsPerMajor, wdrCurrencyAttr)

	logger.WithFields(map[string]any{"account_id": account.GetID(), fieldAmount: amount}).
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
			Amount:           moneyx.FromMinorUnitsByCurrency(account.Currency, amount),
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
