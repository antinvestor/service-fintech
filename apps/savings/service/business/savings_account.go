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
	"strconv"
	"time"

	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"

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
	depRepo   repository.DepositRepository
	wdrRepo   repository.WithdrawalRepository
	iaRepo    repository.InterestAccrualRepository
	sbRepo    repository.SavingsBalanceRepository
}

func NewSavingsAccountBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	saRepo repository.SavingsAccountRepository,
	depRepo repository.DepositRepository,
	wdrRepo repository.WithdrawalRepository,
	iaRepo repository.InterestAccrualRepository,
	sbRepo repository.SavingsBalanceRepository,
) SavingsAccountBusiness {
	return &savingsAccountBusiness{
		eventsMan: eventsMan,
		saRepo:    saRepo,
		depRepo:   depRepo,
		wdrRepo:   wdrRepo,
		iaRepo:    iaRepo,
		sbRepo:    sbRepo,
	}
}

func (b *savingsAccountBusiness) Create(
	ctx context.Context,
	obj *savingsv1.SavingsAccountObject,
) (*savingsv1.SavingsAccountObject, error) {
	logger := util.Log(ctx).WithField("method", "SavingsAccountBusiness.Create")

	sa := models.SavingsAccountFromAPI(ctx, obj)

	if sa.Status == 0 {
		sa.Status = int32(savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_ACTIVE)
	}

	err := b.eventsMan.Emit(ctx, events.SavingsAccountSaveEvent, sa)
	if err != nil {
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

func (b *savingsAccountBusiness) GetStatement(
	ctx context.Context,
	accountID string,
	from, to time.Time,
) (*savingsv1.SavingsStatementResponse, error) {
	stmtSa, err := b.saRepo.GetByID(ctx, accountID)
	if err != nil {
		return nil, ErrSavingsAccountNotFound
	}

	statementEntries, err := b.fetchStatementEntries(ctx, accountID, stmtSa.CurrencyCode, from, to)
	if err != nil {
		return nil, err
	}

	balance, _ := b.GetBalance(ctx, accountID)

	sa, _ := b.saRepo.GetByID(ctx, accountID)
	var saObj *savingsv1.SavingsAccountObject
	if sa != nil {
		saObj = sa.ToAPI()
	}

	return &savingsv1.SavingsStatementResponse{
		Account: saObj,
		Balance: balance,
		Entries: statementEntries,
	}, nil
}

// fetchStatementEntries gathers deposit, withdrawal, and interest accrual entries
// for the given account and time period.
func (b *savingsAccountBusiness) fetchStatementEntries(
	ctx context.Context,
	accountID, currencyCode string,
	from, to time.Time,
) ([]*savingsv1.SavingsStatementEntry, error) {
	logger := util.Log(ctx).WithField("method", "SavingsAccountBusiness.fetchStatementEntries")

	var entries []*savingsv1.SavingsStatementEntry

	// Fetch deposits in the period
	depQuery := data.NewSearchQuery(
		data.WithSearchFiltersAndByValue(map[string]any{
			whereSavingsAccountIDEq: accountID,
			whereStatusEq:           int32(savingsv1.DepositStatus_DEPOSIT_STATUS_COMPLETED),
			whereCreatedAtGte:       from,
			whereCreatedAtLte:       to,
		}),
	)
	depResults, err := b.depRepo.Search(ctx, depQuery)
	if err != nil {
		logger.WithError(err).Error("failed to search deposits for statement")
		return nil, err
	}
	_ = workerpoolConsumeStream(ctx, depResults, func(batch []*models.Deposit) error {
		for _, d := range batch {
			entries = append(entries, &savingsv1.SavingsStatementEntry{
				Date:        models.TimeToString(&d.CreatedAt),
				Description: "Deposit",
				Credit:      models.MinorUnitsToMoney(d.Amount, currencyCode),
				Reference:   d.PaymentReference,
			})
		}
		return nil
	})

	// Fetch withdrawals in the period
	wdrQuery := data.NewSearchQuery(
		data.WithSearchFiltersAndByValue(map[string]any{
			whereSavingsAccountIDEq: accountID,
			whereStatusEq:           int32(savingsv1.WithdrawalStatus_WITHDRAWAL_STATUS_COMPLETED),
			whereCreatedAtGte:       from,
			whereCreatedAtLte:       to,
		}),
	)
	wdrResults, err := b.wdrRepo.Search(ctx, wdrQuery)
	if err != nil {
		logger.WithError(err).Error("failed to search withdrawals for statement")
		return nil, err
	}
	_ = workerpoolConsumeStream(ctx, wdrResults, func(batch []*models.Withdrawal) error {
		for _, w := range batch {
			entries = append(entries, &savingsv1.SavingsStatementEntry{
				Date:        models.TimeToString(&w.CreatedAt),
				Description: "Withdrawal",
				Debit:       models.MinorUnitsToMoney(w.Amount, currencyCode),
				Reference:   w.PaymentReference,
			})
		}
		return nil
	})

	// Fetch interest accruals in the period
	iaQuery := data.NewSearchQuery(
		data.WithSearchFiltersAndByValue(map[string]any{
			whereSavingsAccountIDEq: accountID,
			whereCreatedAtGte:       from,
			whereCreatedAtLte:       to,
		}),
	)
	iaResults, err := b.iaRepo.Search(ctx, iaQuery)
	if err != nil {
		logger.WithError(err).Error("failed to search interest accruals for statement")
		return nil, err
	}
	_ = workerpoolConsumeStream(ctx, iaResults, func(batch []*models.InterestAccrual) error {
		for _, ia := range batch {
			entries = append(entries, &savingsv1.SavingsStatementEntry{
				Date:        models.TimeToString(&ia.CreatedAt),
				Description: "Interest Accrual",
				Credit:      models.MinorUnitsToMoney(ia.Amount, currencyCode),
				Reference:   ia.LedgerTransactionID,
			})
		}
		return nil
	})

	return entries, nil
}
