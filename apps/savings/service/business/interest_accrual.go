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
	"time"

	"gorm.io/gorm"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"

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
)

const (
	// basisPointsDenominator converts basis points to a ratio: 10000 bps = 100%.
	basisPointsDenominator = 10000
	// daysPerYear is the day count basis for interest accrual. Using 365 for
	// simplicity; switch to 360 if/when a product-level convention is added.
	daysPerYear = 365
)

// InterestAccrualBusiness exposes both the read surface (Get/Search) and the
// write surface (Accrue/AccrueAllActive) for savings interest accrual. The
// writer is intended to be driven by a scheduled job; every call is
// idempotent on (savings_account_id, period_end) so reruns of the same
// closing period do not double-credit.
type InterestAccrualBusiness interface {
	Get(ctx context.Context, id string) (*savingsv1.InterestAccrualObject, error)
	Search(
		ctx context.Context,
		req *savingsv1.InterestAccrualSearchRequest,
		consumer func(ctx context.Context, batch []*savingsv1.InterestAccrualObject) error,
	) error

	// Accrue computes and posts the interest accrual for one savings account
	// for one closing period. On a rerun it returns the existing row rather
	// than double-posting.
	Accrue(
		ctx context.Context,
		savingsAccountID string,
		periodStart, periodEnd time.Time,
	) (*savingsv1.InterestAccrualObject, error)

	// AccrueAllActive walks every active savings account and invokes Accrue
	// for the given period. Intended to be driven by a daily/monthly cron.
	// Returns the per-account errors encountered without aborting the run
	// so one bad account cannot stop the whole batch.
	AccrueAllActive(
		ctx context.Context,
		periodStart, periodEnd time.Time,
	) (processed int, errs []error)
}

type interestAccrualBusiness struct {
	eventsMan     fevents.Manager
	iaRepo        repository.InterestAccrualRepository
	saRepo        repository.SavingsAccountRepository
	spRepo        repository.SavingsProductRepository
	sbRepo        repository.SavingsBalanceRepository
	operationsCli operationsv1connect.OperationsServiceClient
	auditWriter   *audit.Writer
}

func NewInterestAccrualBusiness(
	_ context.Context,
	iaRepo repository.InterestAccrualRepository,
	saRepo repository.SavingsAccountRepository,
	spRepo repository.SavingsProductRepository,
	sbRepo repository.SavingsBalanceRepository,
	eventsMan fevents.Manager,
	operationsCli operationsv1connect.OperationsServiceClient,
	auditWriter *audit.Writer,
) InterestAccrualBusiness {
	return &interestAccrualBusiness{
		eventsMan:     eventsMan,
		iaRepo:        iaRepo,
		saRepo:        saRepo,
		spRepo:        spRepo,
		sbRepo:        sbRepo,
		operationsCli: operationsCli,
		auditWriter:   auditWriter,
	}
}

func (b *interestAccrualBusiness) Get(ctx context.Context, id string) (*savingsv1.InterestAccrualObject, error) {
	ia, err := b.iaRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrInterestAccrualNotFound
	}
	return ia.ToAPI(), nil
}

// Accrue computes the interest due on a savings account for a closing period
// and posts it to the ledger. The flow is:
//
//  1. Idempotency — if an accrual row already exists for (account, period_end),
//     return it unchanged.
//  2. Load the account, its product (for the rate), and the current running
//     balance used as the accrual base.
//  3. accrued = balance * rate_bps / 10000 * days_in_period / 365
//  4. Persist the InterestAccrual row.
//  5. Post a transfer order (debit product savings_interest_expense, credit
//     the member's savings ledger account) keyed on a stable reference
//     derived from account id + period end, so retries converge.
//  6. Credit the running savings balance via CreditInterest so GetBalance
//     reflects interest separately from principal deposits.
//
// Skips accounts with a zero or negative balance on the accrual base, since
// there is nothing to compute interest on.
func (b *interestAccrualBusiness) Accrue( //nolint:funlen // sequential accrual pipeline
	ctx context.Context,
	savingsAccountID string,
	periodStart, periodEnd time.Time,
) (*savingsv1.InterestAccrualObject, error) {
	logger := util.Log(ctx).WithField("method", "InterestAccrualBusiness.Accrue").
		WithField("savings_account_id", savingsAccountID)

	if !periodEnd.After(periodStart) {
		return nil, errors.New("period end must be after period start")
	}

	existing, lookupErr := b.iaRepo.GetByAccountAndPeriod(ctx, savingsAccountID, periodEnd)
	if lookupErr != nil && !errors.Is(lookupErr, gorm.ErrRecordNotFound) {
		return nil, fmt.Errorf("lookup accrual: %w", lookupErr)
	}
	if existing != nil {
		return existing.ToAPI(), nil
	}

	sa, err := b.saRepo.GetByID(ctx, savingsAccountID)
	if err != nil {
		return nil, fmt.Errorf("load savings account: %w", err)
	}
	if savingsv1.SavingsAccountStatus(sa.Status) != savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_ACTIVE {
		logger.Info("skipping accrual on non-active savings account")
		return nil, ErrAccountNotActive
	}
	if sa.LedgerAccountID == "" || sa.ProductID == "" {
		return nil, fmt.Errorf("savings account %s is missing product or ledger account", savingsAccountID)
	}

	product, err := b.spRepo.GetByID(ctx, sa.ProductID)
	if err != nil {
		return nil, fmt.Errorf("load savings product: %w", err)
	}
	if product.InterestRate <= 0 {
		logger.WithField("product_id", sa.ProductID).
			Info("skipping accrual: product interest rate is zero")
		return nil, ErrProductRateZero
	}

	balance, err := b.sbRepo.GetBySavingsAccountID(ctx, savingsAccountID)
	if err != nil {
		return nil, fmt.Errorf("load running balance: %w", err)
	}
	if balance.Balance <= 0 {
		logger.Info("skipping accrual: zero balance")
		return nil, ErrBalanceZero
	}

	const hoursPerDay = 24
	days := int64(periodEnd.Sub(periodStart).Hours() / hoursPerDay)
	if days <= 0 {
		days = 1
	}
	// Multiply first to maximize precision before integer division.
	// balance * rate * days overflows at ~2.5 trillion minor units (~25B currency)
	// which is well above any single savings account, so overflow is safe.
	numerator := balance.Balance * product.InterestRate * days
	denominator := int64(basisPointsDenominator) * int64(daysPerYear)
	accrued := numerator / denominator
	// Round up: if the remainder is >= half the denominator, add 1.
	if remainder := numerator % denominator; remainder*2 >= denominator {
		accrued++
	}
	if accrued <= 0 {
		logger.Info("skipping accrual: computed amount is zero")
		return nil, ErrAccrualAmountZero
	}

	ia := &models.InterestAccrual{
		SavingsAccountID: savingsAccountID,
		Amount:           accrued,
		CurrencyCode:     sa.CurrencyCode,
		PeriodStart:      &periodStart,
		PeriodEnd:        &periodEnd,
		RateApplied:      product.InterestRate,
		BalanceUsed:      balance.Balance,
	}
	ia.GenID(ctx)
	ia.CopyPartitionInfo(&sa.BaseModel)

	if emitErr := b.eventsMan.Emit(ctx, events.InterestAccrualSaveEvent, ia); emitErr != nil {
		logger.WithError(emitErr).Error("could not emit interest accrual save event")
		return nil, emitErr
	}

	toID, toErr := b.postInterestAccrualTransferOrder(ctx, logger, sa, ia)
	if toErr != nil {
		return nil, toErr
	}
	ia.LedgerTransactionID = toID

	if _, balErr := b.sbRepo.CreditInterest(ctx, savingsAccountID, accrued); balErr != nil {
		logger.WithError(balErr).Error("could not credit interest onto running balance")
		return nil, balErr
	}

	// Best-effort update of the stored accrual with the ledger txn id.
	if emitErr := b.eventsMan.Emit(ctx, events.InterestAccrualSaveEvent, ia); emitErr != nil {
		logger.WithError(emitErr).Warn("could not persist ledger txn id onto interest accrual")
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "interest_accrual",
		EntityID:   ia.GetID(),
		Action:     "savings.interest.accrued",
		Reason:     "periodic interest accrual posted to ledger",
		After: data.JSONMap{
			fieldAmount:              accrued,
			fieldLedgerTransactionID: ia.LedgerTransactionID,
		},
		Metadata: data.JSONMap{
			fieldSavingsAccountID: savingsAccountID,
			"period_start":        periodStart.UTC().Format(time.RFC3339),
			"period_end":          periodEnd.UTC().Format(time.RFC3339),
			"rate_bps":            product.InterestRate,
			"balance_used":        balance.Balance,
			"days":                days,
			fieldCurrency:         sa.CurrencyCode,
		},
		Parent: &ia.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for interest accrual")
	})

	audit := constants.AuditTrailFromContext(ctx)
	SavingsInterestAccruedAmount.Add(ctx, float64(accrued)/minorUnitsPerMajor, metric.WithAttributes(
		attribute.String("tenant_id", audit.TenantID),
		attribute.String("partition_id", audit.PartitionID),
		attribute.String("currency", sa.CurrencyCode),
	))

	logger.WithFields(map[string]any{
		fieldAmount: accrued,
		"days":      days,
	}).Info("interest accrual posted")
	return ia.ToAPI(), nil
}

// postInterestAccrualTransferOrder emits the double-entry posting for an
// accrual: debit the product's savings interest expense account, credit the
// member's savings ledger account. Reference is keyed on account + period
// end so reruns of the same closing period converge.
func (b *interestAccrualBusiness) postInterestAccrualTransferOrder(
	ctx context.Context,
	logger *util.LogEntry,
	sa *models.SavingsAccount,
	ia *models.InterestAccrual,
) (string, error) {
	if b.operationsCli == nil {
		return "", errors.New("operations client is not configured; cannot post interest accrual")
	}

	reference := fmt.Sprintf("interest_accrual:%s:%s", sa.GetID(), ia.PeriodEnd.UTC().Format(time.RFC3339))
	extraData := data.JSONMap{
		fieldSavingsAccountID: sa.GetID(),
		"interest_accrual_id": ia.GetID(),
		"period_start":        ia.PeriodStart.UTC().Format(time.RFC3339),
		"period_end":          ia.PeriodEnd.UTC().Format(time.RFC3339),
		"rate_bps":            ia.RateApplied,
		"balance_used":        ia.BalanceUsed,
	}

	req := connect.NewRequest(&operationsv1.TransferOrderExecuteRequest{
		Data: &operationsv1.TransferOrderObject{
			DebitAccountRef:  constants.ProductSavingsInterestExpenseAccount(sa.ProductID),
			CreditAccountRef: sa.LedgerAccountID,
			Amount:           moneyx.FromSmallestUnit(sa.CurrencyCode, ia.Amount, moneyDecimalPlaces),
			OrderType: constants.SafeInt32FromInt(
				constants.TransferTypePeriodicSavingsInterestIncomeDistribution,
			),
			Reference:   reference,
			Description: "Savings interest accrual",
			ExtraData:   extraData.ToProtoStruct(),
		},
	})

	resp, execErr := b.operationsCli.TransferOrderExecute(ctx, req)
	if execErr != nil {
		logger.WithError(execErr).
			WithField("reference", reference).
			Error("could not execute interest accrual transfer order")
		return "", fmt.Errorf("interest accrual transfer order %s failed: %w", reference, execErr)
	}
	if td := resp.Msg.GetData(); td != nil {
		return td.GetId(), nil
	}
	return "", nil
}

// AccrueAllActive iterates every active savings account and calls Accrue.
// Errors are collected rather than returned immediately so a single bad
// account cannot abort the whole batch run; the caller (a scheduled job,
// typically) can log and alert on the error list.
func (b *interestAccrualBusiness) AccrueAllActive(
	ctx context.Context,
	periodStart, periodEnd time.Time,
) (int, []error) {
	logger := util.Log(ctx).WithField("method", "InterestAccrualBusiness.AccrueAllActive")

	query := data.NewSearchQuery(
		data.WithSearchFiltersAndByValue(map[string]any{
			whereStatusEq: int32(savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_ACTIVE),
		}),
	)
	results, err := b.saRepo.Search(ctx, query)
	if err != nil {
		return 0, []error{fmt.Errorf("search active accounts: %w", err)}
	}

	var processed int
	var errs []error
	if streamErr := workerpoolConsumeStream(ctx, results, func(batch []*models.SavingsAccount) error {
		for _, sa := range batch {
			if _, accrualErr := b.Accrue(ctx, sa.GetID(), periodStart, periodEnd); accrualErr != nil {
				errs = append(errs, fmt.Errorf("account %s: %w", sa.GetID(), accrualErr))
				continue
			}
			processed++
		}
		return nil
	}); streamErr != nil {
		errs = append(errs, fmt.Errorf("consume active accounts stream: %w", streamErr))
	}
	logger.WithField("processed", processed).
		WithField("errors", len(errs)).
		Info("interest accrual batch complete")
	return processed, errs
}

func (b *interestAccrualBusiness) Search(
	ctx context.Context,
	req *savingsv1.InterestAccrualSearchRequest,
	consumer func(ctx context.Context, batch []*savingsv1.InterestAccrualObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "InterestAccrualBusiness.Search")

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

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.iaRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search interest accruals")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.InterestAccrual) error {
		var apiResults []*savingsv1.InterestAccrualObject
		for _, ia := range res {
			apiResults = append(apiResults, ia.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}
