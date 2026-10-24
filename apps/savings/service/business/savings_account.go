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
	"slices"
	"strconv"
	"strings"
	"sync"
	"time"

	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/savings/service/events"
	"github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"
)

type SavingsAccountBusiness interface {
	Create(ctx context.Context, obj *savingsv1.SavingsAccountObject) (*savingsv1.SavingsAccountObject, error)
	Get(ctx context.Context, id string) (*savingsv1.SavingsAccountObject, error)
	Search(
		ctx context.Context,
		req *savingsv1.SavingsAccountSearchRequest,
		consumer func(ctx context.Context, batch []*savingsv1.SavingsAccountObject) error,
	) error
	Freeze(ctx context.Context, id, reason string) (*savingsv1.SavingsAccountObject, error)
	Close(ctx context.Context, id, reason string) (*savingsv1.SavingsAccountObject, error)
	GetBalance(ctx context.Context, accountID string) (*savingsv1.SavingsBalanceObject, error)
	GetStatement(ctx context.Context, accountID string, from, to time.Time) (*savingsv1.SavingsStatementResponse, error)
}

type savingsAccountBusiness struct {
	eventsMan fevents.Manager
	saRepo    repository.SavingsAccountRepository
	spRepo    repository.SavingsProductRepository
	depRepo   repository.DepositRepository
	wdrRepo   repository.WithdrawalRepository
	iaRepo    repository.InterestAccrualRepository
	sbRepo    repository.SavingsBalanceRepository
}

func NewSavingsAccountBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	saRepo repository.SavingsAccountRepository,
	spRepo repository.SavingsProductRepository,
	depRepo repository.DepositRepository,
	wdrRepo repository.WithdrawalRepository,
	iaRepo repository.InterestAccrualRepository,
	sbRepo repository.SavingsBalanceRepository,
) SavingsAccountBusiness {
	return &savingsAccountBusiness{
		eventsMan: eventsMan,
		saRepo:    saRepo,
		spRepo:    spRepo,
		depRepo:   depRepo,
		wdrRepo:   wdrRepo,
		iaRepo:    iaRepo,
		sbRepo:    sbRepo,
	}
}

// Create opens a savings account against an existing product. The product is
// the source of truth for the account currency, and both ledger references are
// derived server-side, so a caller cannot open an account that posts into
// another tenant's control account.
func (b *savingsAccountBusiness) Create(
	ctx context.Context,
	obj *savingsv1.SavingsAccountObject,
) (*savingsv1.SavingsAccountObject, error) {
	logger := util.Log(ctx).WithField("method", "SavingsAccountBusiness.Create")

	sa := models.SavingsAccountFromAPI(ctx, obj)

	product, err := b.spRepo.GetByID(ctx, sa.ProductID)
	if err != nil {
		return nil, ErrSavingsProductNotFound
	}
	if sa.CurrencyCode == "" {
		sa.CurrencyCode = product.CurrencyCode
	}
	if sa.CurrencyCode != product.CurrencyCode {
		return nil, ErrProductNotForAccount
	}

	sa.Status = int32(savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_ACTIVE)
	sa.LedgerAccountID = LedgerAccountRef(sa)
	sa.PaymentAccountRef = PaymentAccountRef(sa)

	if err = b.eventsMan.Emit(ctx, events.SavingsAccountSaveEvent, sa); err != nil {
		logger.WithError(err).Error("could not emit savings account save event")
		return nil, err
	}

	// Provision the authoritative running balance row for this account. The
	// Ensure call is idempotent: a re-created account or a retry of this call
	// resolves to the same zero row rather than duplicating or erroring.
	if b.sbRepo != nil {
		if _, balErr := b.sbRepo.Ensure(ctx, sa.GetID(), sa.CurrencyCode, &sa.BaseModel); balErr != nil {
			logger.WithError(balErr).Error("could not provision savings balance row")
			return nil, balErr
		}
	}

	SavingsAccountsOpened.Add(ctx, 1)

	return sa.ToAPI(), nil
}

func (b *savingsAccountBusiness) Get(ctx context.Context, id string) (*savingsv1.SavingsAccountObject, error) {
	sa, err := b.saRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrSavingsAccountNotFound
	}
	return sa.ToAPI(), nil
}

func (b *savingsAccountBusiness) Search(
	ctx context.Context,
	req *savingsv1.SavingsAccountSearchRequest,
	consumer func(ctx context.Context, batch []*savingsv1.SavingsAccountObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "SavingsAccountBusiness.Search")

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
	if req.GetOwnerId() != "" {
		andQueryVal["owner_id = ?"] = req.GetOwnerId()
	}
	if req.GetOrganizationId() != "" {
		andQueryVal["bank_id = ?"] = req.GetOrganizationId()
	}
	if req.GetProductId() != "" {
		andQueryVal["product_id = ?"] = req.GetProductId()
	}
	if req.GetStatus() != savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_UNSPECIFIED {
		andQueryVal["status = ?"] = int32(req.GetStatus())
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	if req.GetQuery() != "" {
		searchOpts = append(searchOpts,
			data.WithSearchFiltersOrByValue(map[string]any{searchableTSQuery: req.GetQuery()}),
		)
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.saRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search savings accounts")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.SavingsAccount) error {
		var apiResults []*savingsv1.SavingsAccountObject
		for _, sa := range res {
			apiResults = append(apiResults, sa.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}

func (b *savingsAccountBusiness) Freeze(
	ctx context.Context,
	id, reason string,
) (*savingsv1.SavingsAccountObject, error) {
	logger := util.Log(ctx).WithField("method", "SavingsAccountBusiness.Freeze")

	sa, err := b.saRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrSavingsAccountNotFound
	}

	if sa.Status != int32(savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_ACTIVE) {
		return nil, ErrInvalidStatusTransition
	}

	sa.Status = int32(savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_FROZEN)

	err = b.eventsMan.Emit(ctx, events.SavingsAccountSaveEvent, sa)
	if err != nil {
		logger.WithError(err).Error("could not emit savings account save event")
		return nil, err
	}

	logger.WithFields(map[string]any{fieldSavingsAccountID: id, "reason": reason}).
		Info("savings account frozen")

	return sa.ToAPI(), nil
}

func (b *savingsAccountBusiness) Close(
	ctx context.Context,
	id, reason string,
) (*savingsv1.SavingsAccountObject, error) {
	logger := util.Log(ctx).WithField("method", "SavingsAccountBusiness.Close")

	sa, err := b.saRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrSavingsAccountNotFound
	}

	currentStatus := savingsv1.SavingsAccountStatus(sa.Status)
	if currentStatus != savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_ACTIVE &&
		currentStatus != savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_FROZEN {
		return nil, ErrInvalidStatusTransition
	}

	snapshot, balErr := b.sbRepo.GetBySavingsAccountID(ctx, id)
	switch {
	case balErr == nil:
		if snapshot.Balance != 0 || snapshot.ReservedBalance != 0 {
			return nil, ErrAccountHasBalance
		}
	case errors.Is(balErr, repository.ErrSavingsBalanceNotFound):
		// Never funded: nothing can be stranded by closing it.
	default:
		return nil, balErr
	}

	sa.Status = int32(savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_CLOSED)

	err = b.eventsMan.Emit(ctx, events.SavingsAccountSaveEvent, sa)
	if err != nil {
		logger.WithError(err).Error("could not emit savings account save event")
		return nil, err
	}

	logger.WithFields(map[string]any{fieldSavingsAccountID: id, "reason": reason}).
		Info("savings account closed")

	return sa.ToAPI(), nil
}

// GetBalance reads directly from the authoritative SavingsBalance row. This
// is a constant-time read that does not depend on the size of the account's
// transaction history, and it always matches the ledger because balance
// mutations only happen after the corresponding transfer order has posted.
//
// The SavingsBalanceObject return shape is preserved for wire compatibility:
// TotalDeposits / TotalWithdrawals / TotalInterest come from the per-row
// lifetime counters, AvailableBalance is (Balance - ReservedBalance).
func (b *savingsAccountBusiness) GetBalance(
	ctx context.Context,
	accountID string,
) (*savingsv1.SavingsBalanceObject, error) {
	sa, err := b.saRepo.GetByID(ctx, accountID)
	if err != nil {
		return nil, ErrSavingsAccountNotFound
	}
	cc := sa.CurrencyCode

	if b.sbRepo == nil {
		return nil, errors.New("savings balance repository is not configured")
	}
	snapshot, err := b.sbRepo.GetBySavingsAccountID(ctx, accountID)
	if err != nil {
		if errors.Is(err, repository.ErrSavingsBalanceNotFound) {
			// Account exists but balance row was not provisioned yet: return
			// a zero snapshot rather than erroring so callers can treat
			// "unprovisioned" the same as "empty".
			return &savingsv1.SavingsBalanceObject{
				SavingsAccountId: accountID,
				TotalDeposits:    models.MinorUnitsToMoney(0, cc),
				TotalWithdrawals: models.MinorUnitsToMoney(0, cc),
				TotalInterest:    models.MinorUnitsToMoney(0, cc),
				AvailableBalance: models.MinorUnitsToMoney(0, cc),
			}, nil
		}
		return nil, err
	}

	available := snapshot.Balance - snapshot.ReservedBalance
	if available < 0 {
		available = 0
	}

	return &savingsv1.SavingsBalanceObject{
		SavingsAccountId: accountID,
		TotalDeposits:    models.MinorUnitsToMoney(snapshot.TotalDeposits, cc),
		TotalWithdrawals: models.MinorUnitsToMoney(snapshot.TotalWithdrawals, cc),
		TotalInterest:    models.MinorUnitsToMoney(snapshot.TotalInterest, cc),
		AvailableBalance: models.MinorUnitsToMoney(available, cc),
	}, nil
}

// GetStatement renders the account's movements over a bounded window.
// Callers may omit either date: the window defaults to the last
// statementDefaultWindow ending now. Entries arrive from three independent
// searches, so they are collected under a lock, ordered by date, capped at
// statementMaxEntries, and walked forward from the opening balance to give
// each row a running balance.
func (b *savingsAccountBusiness) GetStatement(
	ctx context.Context,
	accountID string,
	from, to time.Time,
) (*savingsv1.SavingsStatementResponse, error) {
	sa, err := b.saRepo.GetByID(ctx, accountID)
	if err != nil {
		return nil, ErrSavingsAccountNotFound
	}

	from, to = statementWindow(from, to)

	entries, err := b.fetchStatementEntries(ctx, accountID, sa.CurrencyCode, from, to)
	if err != nil {
		return nil, err
	}

	opening, err := b.sbRepo.OpeningBalance(ctx, accountID, from)
	if err != nil {
		return nil, err
	}
	applyRunningBalance(entries, opening, sa.CurrencyCode)

	balance, err := b.GetBalance(ctx, accountID)
	if err != nil {
		return nil, err
	}

	return &savingsv1.SavingsStatementResponse{
		Account: sa.ToAPI(),
		Balance: balance,
		Entries: entries,
	}, nil
}

// statementWindow fills in the open ends of a requested period. An absent
// end date means "up to now"; an absent start date means
// statementDefaultWindow before the end.
func statementWindow(from, to time.Time) (time.Time, time.Time) {
	if to.IsZero() {
		to = time.Now().UTC()
	}
	if from.IsZero() {
		from = to.Add(-statementDefaultWindow)
	}
	if from.After(to) {
		from = to.Add(-statementDefaultWindow)
	}
	return from, to
}

// applyRunningBalance walks entries oldest-first, carrying the balance the
// account held at the start of the window through every movement.
func applyRunningBalance(entries []*savingsv1.SavingsStatementEntry, opening int64, currency string) {
	running := opening
	for _, entry := range entries {
		running += moneyx.ToSmallestUnit(entry.GetCredit(), moneyx.Decimals(currency))
		running -= moneyx.ToSmallestUnit(entry.GetDebit(), moneyx.Decimals(currency))
		entry.Balance = models.MinorUnitsToMoney(running, currency)
	}
}

// statementCollector gathers entries from the concurrent search streams.
type statementCollector struct {
	mu      sync.Mutex
	entries []*savingsv1.SavingsStatementEntry
}

func (c *statementCollector) add(entry *savingsv1.SavingsStatementEntry, at time.Time) {
	c.mu.Lock()
	defer c.mu.Unlock()
	entry.Date = models.TimeToString(&at)
	c.entries = append(c.entries, entry)
}

// sorted returns the collected entries oldest-first, capped at
// statementMaxEntries so an account with a long history cannot produce an
// unbounded response.
func (c *statementCollector) sorted() []*savingsv1.SavingsStatementEntry {
	c.mu.Lock()
	defer c.mu.Unlock()
	slices.SortFunc(c.entries, func(a, b *savingsv1.SavingsStatementEntry) int {
		return strings.Compare(a.GetDate(), b.GetDate())
	})
	if len(c.entries) > statementMaxEntries {
		return c.entries[:statementMaxEntries]
	}
	return c.entries
}

// fetchStatementEntries gathers deposit, withdrawal, and interest accrual
// entries for the given account and period.
func (b *savingsAccountBusiness) fetchStatementEntries(
	ctx context.Context,
	accountID, currencyCode string,
	from, to time.Time,
) ([]*savingsv1.SavingsStatementEntry, error) {
	logger := util.Log(ctx).WithField("method", "SavingsAccountBusiness.fetchStatementEntries")

	collector := &statementCollector{}

	periodFilters := func(extra map[string]any) []data.SearchOption {
		filters := map[string]any{
			whereSavingsAccountIDEq: accountID,
			whereCreatedAtGte:       from,
			whereCreatedAtLte:       to,
		}
		for k, v := range extra {
			filters[k] = v
		}
		return []data.SearchOption{
			data.WithSearchFiltersAndByValue(filters),
			data.WithSearchLimit(statementMaxEntries),
		}
	}

	depResults, err := b.depRepo.Search(ctx, data.NewSearchQuery(periodFilters(map[string]any{
		whereStatusEq: int32(savingsv1.DepositStatus_DEPOSIT_STATUS_COMPLETED),
	})...))
	if err != nil {
		logger.WithError(err).Error("failed to search deposits for statement")
		return nil, err
	}
	if err = workerpoolConsumeStream(ctx, depResults, func(batch []*models.Deposit) error {
		for _, d := range batch {
			collector.add(&savingsv1.SavingsStatementEntry{
				Description: "Deposit",
				Credit:      models.MinorUnitsToMoney(d.Amount, currencyCode),
				Reference:   d.PaymentReference,
			}, d.CreatedAt)
		}
		return nil
	}); err != nil {
		return nil, err
	}

	wdrResults, err := b.wdrRepo.Search(ctx, data.NewSearchQuery(periodFilters(map[string]any{
		whereStatusEq: int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_COMPLETED),
	})...))
	if err != nil {
		logger.WithError(err).Error("failed to search withdrawals for statement")
		return nil, err
	}
	if err = workerpoolConsumeStream(ctx, wdrResults, func(batch []*models.Withdrawal) error {
		for _, w := range batch {
			collector.add(&savingsv1.SavingsStatementEntry{
				Description: "Withdrawal",
				Debit:       models.MinorUnitsToMoney(w.Amount, currencyCode),
				Reference:   w.PaymentReference,
			}, w.CreatedAt)
		}
		return nil
	}); err != nil {
		return nil, err
	}

	iaResults, err := b.iaRepo.Search(ctx, data.NewSearchQuery(periodFilters(nil)...))
	if err != nil {
		logger.WithError(err).Error("failed to search interest accruals for statement")
		return nil, err
	}
	if err = workerpoolConsumeStream(ctx, iaResults, func(batch []*models.InterestAccrual) error {
		for _, ia := range batch {
			collector.add(&savingsv1.SavingsStatementEntry{
				Description: "Interest Accrual",
				Credit:      models.MinorUnitsToMoney(ia.Amount, currencyCode),
				Reference:   ia.LedgerTransactionID,
			}, ia.CreatedAt)
		}
		return nil
	}); err != nil {
		return nil, err
	}

	return collector.sorted(), nil
}
