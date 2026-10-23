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
	"fmt"
	"sort"
	"strconv"
	"time"

	"go.opentelemetry.io/otel/attribute"

	"buf.build/gen/go/antinvestor/funding/connectrpc/go/funding/v1/fundingv1connect"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/fundingcompat"
)

const (
	// daysPerWeek is the number of days in a weekly period.
	daysPerWeek = 7
	// daysPerBiweek is the number of days in a biweekly period.
	daysPerBiweek = 14
	// daysPerMonth is the approximate number of days in a monthly period.
	daysPerMonth = 30
	// daysPerQuarter is the approximate number of days in a quarterly period.
	daysPerQuarter = 90
)

// validTransitions defines the allowed loan status transitions.
var validTransitions = map[loansv1.LoanStatus][]loansv1.LoanStatus{ //nolint:gochecknoglobals // state machine
	loansv1.LoanStatus_LOAN_STATUS_UNSPECIFIED: {},
	loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT: {
		loansv1.LoanStatus_LOAN_STATUS_ACTIVE,
		loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED,
	},
	loansv1.LoanStatus_LOAN_STATUS_ACTIVE: {
		loansv1.LoanStatus_LOAN_STATUS_DELINQUENT,
		loansv1.LoanStatus_LOAN_STATUS_PAID_OFF,
		loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED,
	},
	// A delinquent or defaulted loan that is paid in full goes straight to
	// PAID_OFF: a borrower catching up is exactly what these states exist to
	// be recovered from, and the automatic pay-off a settling repayment
	// triggers runs through this same table.
	loansv1.LoanStatus_LOAN_STATUS_DELINQUENT: {
		loansv1.LoanStatus_LOAN_STATUS_DEFAULT,
		loansv1.LoanStatus_LOAN_STATUS_ACTIVE,
		loansv1.LoanStatus_LOAN_STATUS_PAID_OFF,
		loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED,
	},
	loansv1.LoanStatus_LOAN_STATUS_DEFAULT: {
		loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF,
		loansv1.LoanStatus_LOAN_STATUS_PAID_OFF,
		loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED,
	},
	loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED: {
		loansv1.LoanStatus_LOAN_STATUS_ACTIVE,
		loansv1.LoanStatus_LOAN_STATUS_DELINQUENT,
		loansv1.LoanStatus_LOAN_STATUS_PAID_OFF,
	},
	loansv1.LoanStatus_LOAN_STATUS_PAID_OFF: {
		loansv1.LoanStatus_LOAN_STATUS_CLOSED,
	},
	loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF: {
		loansv1.LoanStatus_LOAN_STATUS_CLOSED,
	},
	loansv1.LoanStatus_LOAN_STATUS_CLOSED: {},
}

// transitionAllowed reports whether the loan state machine permits a move
// between two statuses. Every path that changes a loan's status consults it,
// so the automatic pay-off a fully settled repayment triggers and the
// operator-driven transition can never disagree about what is legal.
func transitionAllowed(from, to loansv1.LoanStatus) bool {
	for _, allowed := range validTransitions[from] {
		if allowed == to {
			return true
		}
	}
	return false
}

type LoanAccountBusiness interface {
	Create(ctx context.Context, loanRequestID string) (*loansv1.LoanAccountObject, error)
	Get(ctx context.Context, id string) (*loansv1.LoanAccountObject, error)
	Search(
		ctx context.Context,
		req *loansv1.LoanAccountSearchRequest,
		consumer func(ctx context.Context, batch []*loansv1.LoanAccountObject) error,
	) error
	GetBalance(ctx context.Context, loanAccountID string) (*loansv1.LoanBalanceObject, error)
	GetStatement(ctx context.Context, req *loansv1.LoanStatementRequest) (*loansv1.LoanStatementResponse, error)
	TransitionStatus(
		ctx context.Context,
		loanAccountID string,
		newStatus loansv1.LoanStatus,
		changedBy, reason string,
	) (*loansv1.LoanAccountObject, error)
}

type loanAccountBusiness struct {
	eventsMan        fevents.Manager
	loanProductRepo  repository.LoanProductRepository
	loanAccountRepo  repository.LoanAccountRepository
	loanBalanceRepo  repository.LoanBalanceRepository
	statusChangeRepo repository.LoanStatusChangeRepository
	repaymentRepo    repository.RepaymentRepository
	penaltyRepo      repository.PenaltyRepository
	loanRequestRepo  repository.LoanRequestRepository
	fundingCli       fundingv1connect.FundingServiceClient
	scheduleBusiness RepaymentScheduleBusiness
	operationsCli    operationsv1connect.OperationsServiceClient
	auditWriter      *audit.Writer

	scope             *ReadScope
	disbRepo          repository.DisbursementRepository
	scheduleEntryRepo repository.ScheduleEntryRepository
	notifier          *LoanNotifier
}

func NewLoanAccountBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	loanProductRepo repository.LoanProductRepository,
	loanAccountRepo repository.LoanAccountRepository,
	loanBalanceRepo repository.LoanBalanceRepository,
	statusChangeRepo repository.LoanStatusChangeRepository,
	repaymentRepo repository.RepaymentRepository,
	penaltyRepo repository.PenaltyRepository,
	loanRequestRepo repository.LoanRequestRepository,
	fundingCli fundingv1connect.FundingServiceClient,
	scheduleBusiness RepaymentScheduleBusiness,
	operationsCli operationsv1connect.OperationsServiceClient,
	auditWriter *audit.Writer,
	opts ...Option,
) LoanAccountBusiness {
	o := applyOptions(opts)
	if (o.disbRepo == nil || o.scheduleEntryRepo == nil) && loanAccountRepo != nil && loanAccountRepo.Pool() != nil {
		// The statement reads disbursements and the schedule; derive the
		// repositories from the shared pool so a binary that has not wired
		// them explicitly still produces a complete statement.
		if o.disbRepo == nil {
			o.disbRepo = repository.NewDisbursementRepository(
				context.Background(), loanAccountRepo.Pool(), loanAccountRepo.WorkManager())
		}
		if o.scheduleEntryRepo == nil {
			o.scheduleEntryRepo = repository.NewScheduleEntryRepository(
				context.Background(), loanAccountRepo.Pool(), loanAccountRepo.WorkManager())
		}
	}
	return &loanAccountBusiness{
		scope:             o.scope,
		disbRepo:          o.disbRepo,
		scheduleEntryRepo: o.scheduleEntryRepo,
		notifier:          o.notifier,

		eventsMan:        eventsMan,
		loanProductRepo:  loanProductRepo,
		loanAccountRepo:  loanAccountRepo,
		loanBalanceRepo:  loanBalanceRepo,
		statusChangeRepo: statusChangeRepo,
		repaymentRepo:    repaymentRepo,
		penaltyRepo:      penaltyRepo,
		loanRequestRepo:  loanRequestRepo,
		fundingCli:       fundingCli,
		scheduleBusiness: scheduleBusiness,
		operationsCli:    operationsCli,
		auditWriter:      auditWriter,
	}
}

func (b *loanAccountBusiness) Create(ctx context.Context, loanRequestID string) (*loansv1.LoanAccountObject, error) {
	logger := util.Log(ctx).WithField("method", "LoanAccountBusiness.Create")

	// A loan request has exactly one loan account. Resolving it first is what
	// makes a retried create return the original loan rather than reserving
	// funding a second time and then failing on the unique index.
	if existing, err := b.loanAccountRepo.GetByLoanRequestID(ctx, loanRequestID); err == nil && existing != nil {
		return existing.ToAPI(), nil
	}

	la, err := b.populateLoanFromRequest(ctx, logger, loanRequestID)
	if err != nil {
		return nil, err
	}

	la.GenID(ctx)
	setInitialRepaymentDate(la)

	// Claim the request before any money moves. The claim is a conditional
	// UPDATE, so of two concurrent creates exactly one proceeds; the loser
	// resolves the winner's loan account and returns it.
	claimed, claimErr := b.loanRequestRepo.ClaimForLoanCreation(ctx, loanRequestID, la.GetID())
	if claimErr != nil {
		logger.WithError(claimErr).Error("could not claim loan request for loan creation")
		return nil, claimErr
	}
	if !claimed {
		return b.resolveExistingLoanAccount(ctx, loanRequestID)
	}

	account, err := b.completeLoanCreation(ctx, logger, la, loanRequestID)
	if err != nil {
		if releaseErr := b.loanRequestRepo.ReleaseLoanCreationClaim(
			ctx, loanRequestID, la.GetID(),
		); releaseErr != nil {
			logger.WithError(releaseErr).Error("could not release loan request claim after failed loan creation")
		}
		return nil, err
	}

	LoansCreated.Add(ctx, 1, attribute.String("currency", la.CurrencyCode))

	return account, nil
}

// completeLoanCreation reserves funding, writes the loan account, and derives
// its opening schedule and balance. Every step is required: a loan without a
// schedule cannot allocate a repayment across interest, fees and principal, so
// a schedule failure fails the creation rather than leaving a loan that
// silently treats every payment as principal.
func (b *loanAccountBusiness) completeLoanCreation(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	loanRequestID string,
) (*loansv1.LoanAccountObject, error) {
	if err := b.ensureLoanRequestFunding(ctx, logger, loanRequestID, la); err != nil {
		return nil, err
	}

	// Written synchronously rather than emitted: the schedule generator and
	// every later read need the row to exist, and the event queue makes no
	// promise about when it would.
	if err := b.loanAccountRepo.Create(ctx, la); err != nil {
		logger.WithError(err).Error("could not persist loan account")
		return nil, err
	}

	schedule, schedErr := b.scheduleBusiness.GenerateFor(ctx, la, la.PrincipalAmount)
	if schedErr != nil {
		logger.WithError(schedErr).Error("could not generate repayment schedule")
		return nil, schedErr
	}

	if err := b.createInitialBalance(ctx, la, schedule); err != nil {
		return nil, err
	}

	return la.ToAPI(), nil
}

// resolveExistingLoanAccount returns the loan account that another caller
// created for this request.
func (b *loanAccountBusiness) resolveExistingLoanAccount(
	ctx context.Context,
	loanRequestID string,
) (*loansv1.LoanAccountObject, error) {
	if existing, err := b.loanAccountRepo.GetByLoanRequestID(ctx, loanRequestID); err == nil && existing != nil {
		return existing.ToAPI(), nil
	}
	return nil, ErrLoanRequestNotApproved
}

// populateLoanFromRequest reads the local LoanRequest and populates a
// LoanAccount with its data and optional product defaults.
func (b *loanAccountBusiness) populateLoanFromRequest(
	ctx context.Context,
	logger *util.LogEntry,
	loanRequestID string,
) (*models.LoanAccount, error) {
	la := &models.LoanAccount{
		LoanRequestID: loanRequestID,
		Status:        int32(loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT),
		Properties: data.JSONMap{
			fieldLoanRequestID: loanRequestID,
		},
	}

	lr, lrErr := b.loanRequestRepo.GetByID(ctx, loanRequestID)
	if lrErr != nil {
		logger.WithError(lrErr).Error("could not fetch loan request")
		return nil, ErrLoanRequestNotFound
	}

	if lr.Status != int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED) {
		return nil, ErrLoanRequestNotApproved
	}

	la.ProductID = lr.ProductID
	la.ClientID = lr.ClientID
	la.AgentID = lr.AgentID
	la.BranchID = lr.BranchID
	la.OrganizationID = lr.OrganizationID
	la.CurrencyCode = lr.CurrencyCode
	la.PrincipalAmount = lr.ApprovedAmount
	la.InterestRate = lr.InterestRate
	la.TermDays = lr.ApprovedTermDays

	if lr.Properties != nil {
		la.Properties = lr.Properties
		if la.Properties == nil {
			la.Properties = data.JSONMap{}
		}
	}
	la.Properties["loan_request_id"] = loanRequestID
	if paymentAccountRef := loanRequestStringProperty(la.Properties, "payment_account_ref"); paymentAccountRef != "" {
		la.PaymentAccountRef = paymentAccountRef
	}

	b.applyProductDefaults(ctx, logger, la, lr.ProductID)
	applyLedgerDefaults(la)

	if la.PrincipalAmount <= 0 || la.TermDays <= 0 {
		return nil, ErrLoanRequestTermsNotSet
	}

	return la, nil
}

// applyProductDefaults enriches a loan account with product-level defaults
// (interest method, repayment frequency, rate, currency).
func (b *loanAccountBusiness) applyProductDefaults(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	productID string,
) {
	if productID == "" {
		return
	}
	prod, prodErr := b.loanProductRepo.GetByID(ctx, productID)
	if prodErr != nil || prod == nil {
		logger.WithError(prodErr).Warn("could not fetch loan product, using application data only")
		return
	}
	la.InterestMethod = prod.InterestMethod
	la.RepaymentFrequency = prod.RepaymentFrequency
	if la.InterestRate == 0 {
		la.InterestRate = prod.AnnualInterestRate
	}
	if la.CurrencyCode == "" {
		la.CurrencyCode = prod.CurrencyCode
	}
}

func (b *loanAccountBusiness) ensureLoanRequestFunding(
	ctx context.Context,
	logger *util.LogEntry,
	loanRequestID string,
	la *models.LoanAccount,
) error {
	if b.fundingCli == nil {
		return ErrFundingServiceUnavailable
	}

	resp, err := b.fundingCli.FundLoan(ctx, connect.NewRequest(fundingcompat.NewFundLoanRequest(loanRequestID)))
	if err != nil {
		logger.WithError(err).Error("could not reserve funding for loan request")
		return ErrFundingAllocationUnavailable
	}

	totalAllocated, _ := models.MoneyToMinorUnits(resp.Msg.GetTotalAllocated())
	if !resp.Msg.GetFullyFunded() || totalAllocated < la.PrincipalAmount {
		return ErrLoanFundingInsufficient
	}

	if la.Properties == nil {
		la.Properties = data.JSONMap{}
	}
	la.Properties["loan_request_id"] = loanRequestID
	la.Properties["funding_fully_funded"] = true
	la.Properties["funding_total_allocated"] = float64(totalAllocated)
	la.Properties["funding_allocation_count"] = float64(len(resp.Msg.GetAllocations()))
	la.Properties["funding_allocations"] = fundingAllocationsJSON(resp.Msg.GetAllocations())
	return nil
}

func fundingAllocationsJSON(allocations []*fundingv1.FundingAllocationObject) []map[string]any {
	if len(allocations) == 0 {
		return nil
	}

	result := make([]map[string]any, 0, len(allocations))
	for _, allocation := range allocations {
		if allocation == nil {
			continue
		}
		amount, _ := models.MoneyToMinorUnits(allocation.GetAmount())
		result = append(result, map[string]any{
			"id":               allocation.GetId(),
			fieldLoanRequestID: fundingcompat.AllocationLoanRequestID(allocation),
			"source_id":        allocation.GetSourceId(),
			"source_type":      allocation.GetSourceType(),
			"tranche_level":    float64(allocation.GetTrancheLevel()),
			fieldAmount:        float64(amount),
		})
	}
	return result
}

func loanRequestStringProperty(properties data.JSONMap, key string) string {
	if properties == nil {
		return ""
	}
	if value, ok := properties[key].(string); ok {
		return value
	}
	return ""
}

func applyLedgerDefaults(la *models.LoanAccount) {
	if la.LedgerAssetAccountID == "" && la.ProductID != "" {
		la.LedgerAssetAccountID = constants.ProductUnallocatedAccount(la.ProductID)
	}
	if la.LedgerInterestIncomeAccountID == "" && la.ProductID != "" {
		la.LedgerInterestIncomeAccountID = constants.PlatformIncomeAccount(la.ProductID)
	}
	if la.LedgerFeeIncomeAccountID == "" && la.ProductID != "" {
		la.LedgerFeeIncomeAccountID = constants.ProductServiceFeePayableAccount(la.ProductID)
	}
	if la.LedgerPenaltyIncomeAccountID == "" && la.ProductID != "" {
		la.LedgerPenaltyIncomeAccountID = constants.PlatformIncomeAccount(la.ProductID)
	}
}

// setInitialRepaymentDate computes the expected first repayment date without
// marking the loan as already disbursed.
func setInitialRepaymentDate(la *models.LoanAccount) {
	now := time.Now().UTC()
	firstRepayment := now.AddDate(0, 0, computeFirstRepaymentDays(loansv1.RepaymentFrequency(la.RepaymentFrequency)))
	la.FirstRepaymentDate = &firstRepayment
}

// createInitialBalance opens the loan's balance from the schedule that will
// actually be collected. Recomputing interest independently drifts from the
// schedule whenever the product amortises on a reducing balance, and a balance
// that overstates interest never reaches zero, so the loan never pays off.
func (b *loanAccountBusiness) createInitialBalance(
	ctx context.Context,
	la *models.LoanAccount,
	schedule *ScheduleResult,
) error {
	totalInterest := schedule.TotalInterest()
	totalFees := schedule.TotalFees()
	now := time.Now().UTC()

	balance := &models.LoanBalance{
		LoanAccountID:        la.GetID(),
		CurrencyCode:         la.CurrencyCode,
		PrincipalOutstanding: la.PrincipalAmount,
		InterestAccrued:      totalInterest,
		FeesOutstanding:      totalFees,
		TotalOutstanding:     la.PrincipalAmount + totalInterest + totalFees,
		TotalDisbursed:       la.PrincipalAmount,
		LastCalculatedAt:     &now,
	}
	balance.GenID(ctx)

	if err := b.eventsMan.Emit(ctx, events.LoanBalanceSaveEvent, balance); err != nil {
		util.Log(ctx).WithError(err).Error("could not emit loan balance save event")
		return err
	}
	return nil
}

func (b *loanAccountBusiness) Get(ctx context.Context, id string) (*loansv1.LoanAccountObject, error) {
	la, err := b.loanAccountRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}
	if scopeErr := b.scope.AuthorizeClient(ctx, la.ClientID); scopeErr != nil {
		return nil, scopeErr
	}
	return la.ToAPI(), nil
}

func (b *loanAccountBusiness) Search(
	ctx context.Context,
	req *loansv1.LoanAccountSearchRequest,
	consumer func(ctx context.Context, batch []*loansv1.LoanAccountObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "LoanAccountBusiness.Search")

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
	if req.GetClientId() != "" {
		andQueryVal["client_id = ?"] = req.GetClientId()
	}
	if req.GetAgentId() != "" {
		andQueryVal["agent_id = ?"] = req.GetAgentId()
	}
	if req.GetBranchId() != "" {
		andQueryVal["branch_id = ?"] = req.GetBranchId()
	}
	if req.GetOrganizationId() != "" {
		andQueryVal["organization_id = ?"] = req.GetOrganizationId()
	}
	if req.GetStatus() != loansv1.LoanStatus_LOAN_STATUS_UNSPECIFIED {
		andQueryVal["status = ?"] = int32(req.GetStatus())
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	if req.GetQuery() != "" {
		searchOpts = append(searchOpts,
			data.WithSearchFiltersOrByValue(
				map[string]any{searchableTSQuery: req.GetQuery()},
			),
		)
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.loanAccountRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search loan accounts")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.LoanAccount) error {
		var apiResults []*loansv1.LoanAccountObject
		for _, la := range res {
			apiResults = append(apiResults, la.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}

func (b *loanAccountBusiness) GetBalance(
	ctx context.Context,
	loanAccountID string,
) (*loansv1.LoanBalanceObject, error) {
	if scopeErr := authorizeLoanAccount(ctx, b.scope, b.loanAccountRepo, loanAccountID); scopeErr != nil {
		return nil, scopeErr
	}
	balance, err := b.loanBalanceRepo.GetByLoanAccountID(ctx, loanAccountID)
	if err != nil {
		return nil, ErrBalanceNotFound
	}
	return balance.ToAPI(), nil
}

func (b *loanAccountBusiness) GetStatement(
	ctx context.Context,
	req *loansv1.LoanStatementRequest,
) (*loansv1.LoanStatementResponse, error) {
	logger := util.Log(ctx).WithField("method", "LoanAccountBusiness.GetStatement")

	la, err := b.loanAccountRepo.GetByID(ctx, req.GetLoanAccountId())
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}
	if scopeErr := b.scope.AuthorizeClient(ctx, la.ClientID); scopeErr != nil {
		return nil, scopeErr
	}

	balance, balErr := b.loanBalanceRepo.GetByLoanAccountID(ctx, req.GetLoanAccountId())
	if balErr != nil {
		logger.WithError(balErr).Warn("could not load balance for statement")
	}

	var balanceAPI *loansv1.LoanBalanceObject
	if balance != nil {
		balanceAPI = balance.ToAPI()
	}

	raw, err := b.loadStatementEntries(ctx, la)
	if err != nil {
		return nil, err
	}

	fromDate := models.StringToTime(req.GetFromDate())
	toDate := models.StringToTime(req.GetToDate())

	return &loansv1.LoanStatementResponse{
		Loan:    la.ToAPI(),
		Balance: balanceAPI,
		Entries: buildStatementEntries(raw, la.CurrencyCode, fromDate, toDate),
	}, nil
}

// statementRowLimit bounds every per-loan listing the statement reads. A loan
// with more rows than this in any one table is truncated (and logged) rather
// than allowed to pull an unbounded result set into memory.
const statementRowLimit = 5000

// statementEntry is an internal type used to sort and compute running balances
// before converting to the proto LoanStatementEntry.
type statementEntry struct {
	date        time.Time
	description string
	debit       int64 // charges to the borrower (increases balance)
	credit      int64 // payments by the borrower (decreases balance)
	reference   string
}

// loadStatementEntries reads the financial events of one loan — completed
// disbursements, scheduled interest and fees, unwaived penalties and
// repayments — with one bounded, index-served query per table, and refuses
// to total rows that are not all in the loan's currency.
//
//nolint:gocognit,funlen // one pass over four row types; splitting it would only hide the flow
func (b *loanAccountBusiness) loadStatementEntries(
	ctx context.Context,
	la *models.LoanAccount,
) ([]statementEntry, error) {
	logger := util.Log(ctx).WithField("loan_account_id", la.GetID())
	currency := la.CurrencyCode

	sameCurrency := func(rowCurrency string) bool {
		return rowCurrency == "" || rowCurrency == currency
	}
	warnTruncated := func(table string, n int) {
		if n >= statementRowLimit {
			logger.WithField("table", table).WithField("limit", statementRowLimit).
				Warn("loan statement truncated: row limit reached")
		}
	}

	var raw []statementEntry

	// 1. Disbursements. Completed rows are the advances actually made. Loans
	// created before disbursements were recorded as rows only carry
	// DisbursedAt on the account, which is used as the fallback.
	disbursed := false
	if b.disbRepo != nil {
		disbs, err := b.disbRepo.ListByLoanAccountID(ctx, la.GetID(), statementRowLimit)
		if err != nil {
			return nil, fmt.Errorf("statement disbursements: %w", err)
		}
		warnTruncated("disbursements", len(disbs))
		for _, d := range disbs {
			if d.Status != int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_COMPLETED) {
				continue
			}
			if !sameCurrency(d.CurrencyCode) {
				return nil, ErrStatementCurrencyMismatch
			}
			disbursed = true
			raw = append(raw, statementEntry{
				date:        d.CreatedAt,
				description: "Loan disbursement",
				debit:       d.Amount,
				reference:   firstNonEmpty(d.PaymentReference, d.GetID()),
			})
		}
	}
	if !disbursed && la.DisbursedAt != nil {
		raw = append(raw, statementEntry{
			date:        *la.DisbursedAt,
			description: "Loan disbursement",
			debit:       la.PrincipalAmount,
			reference:   la.LoanRequestID,
		})
	}

	// 2. Scheduled interest and fees fall due on each installment date.
	if b.scheduleEntryRepo != nil {
		entries, err := b.scheduleEntryRepo.GetByLoanAccountID(ctx, la.GetID())
		if err != nil {
			return nil, fmt.Errorf("statement schedule: %w", err)
		}
		for _, e := range entries {
			charge := e.InterestDue + e.FeesDue
			if charge <= 0 || e.DueDate == nil {
				continue
			}
			if !sameCurrency(e.CurrencyCode) {
				return nil, ErrStatementCurrencyMismatch
			}
			raw = append(raw, statementEntry{
				date:        *e.DueDate,
				description: fmt.Sprintf("Installment %d interest and fees due", e.InstallmentNumber),
				debit:       charge,
				reference:   e.GetID(),
			})
		}
	}

	// 3. Penalties that have not been waived.
	penalties, err := b.penaltyRepo.ListByLoanAccountID(ctx, la.GetID(), statementRowLimit)
	if err != nil {
		return nil, fmt.Errorf("statement penalties: %w", err)
	}
	warnTruncated("penalties", len(penalties))
	for _, p := range penalties {
		if p.IsWaived {
			continue
		}
		if !sameCurrency(p.CurrencyCode) {
			return nil, ErrStatementCurrencyMismatch
		}
		raw = append(raw, statementEntry{
			date:        p.CreatedAt,
			description: "Penalty: " + p.Reason,
			debit:       p.Amount,
			reference:   p.GetID(),
		})
	}

	// 4. Repayments, excluding reversed ones.
	repayments, err := b.repaymentRepo.ListByLoanAccountID(ctx, la.GetID(), statementRowLimit)
	if err != nil {
		return nil, fmt.Errorf("statement repayments: %w", err)
	}
	warnTruncated("repayments", len(repayments))
	for _, r := range repayments {
		if r.Status == int32(loansv1.RepaymentStatus_REPAYMENT_STATUS_REVERSED) {
			continue
		}
		if !sameCurrency(r.CurrencyCode) {
			return nil, ErrStatementCurrencyMismatch
		}
		raw = append(raw, statementEntry{
			date:        r.CreatedAt,
			description: "Repayment via " + r.Channel,
			credit:      r.Amount,
			reference:   firstNonEmpty(r.PaymentReference, r.GetID()),
		})
	}

	sort.SliceStable(raw, func(i, j int) bool {
		return raw[i].date.Before(raw[j].date)
	})
	return raw, nil
}

// buildStatementEntries walks chronologically sorted entries, computes the
// running balance in the loan's currency, and returns the proto rows inside
// the date range. When fromDate is set, an opening balance row precedes the
// first in-range entry so the period reconciles on its own.
func buildStatementEntries(
	raw []statementEntry,
	currency string,
	fromDate, toDate *time.Time,
) []*loansv1.LoanStatementEntry {
	var entries []*loansv1.LoanStatementEntry
	var runningBalance int64
	openingBalanceEmitted := fromDate == nil

	for _, e := range raw {
		runningBalance += e.debit - e.credit

		if !isTimeInRange(e.date, fromDate, toDate) {
			continue
		}

		if !openingBalanceEmitted {
			openingBalance := runningBalance - e.debit + e.credit
			entries = append(entries, &loansv1.LoanStatementEntry{
				Date:        models.TimeToString(fromDate),
				Description: "Opening balance brought forward",
				Balance:     models.MinorUnitsToMoney(openingBalance, currency),
			})
			openingBalanceEmitted = true
		}

		entry := &loansv1.LoanStatementEntry{
			Date:        models.TimeToString(&e.date),
			Description: e.description,
			Balance:     models.MinorUnitsToMoney(runningBalance, currency),
			Reference:   e.reference,
		}
		if e.debit > 0 {
			entry.Debit = models.MinorUnitsToMoney(e.debit, currency)
		}
		if e.credit > 0 {
			entry.Credit = models.MinorUnitsToMoney(e.credit, currency)
		}
		entries = append(entries, entry)
	}

	return entries
}

func firstNonEmpty(values ...string) string {
	for _, v := range values {
		if v != "" {
			return v
		}
	}
	return ""
}

// isTimeInRange checks whether a time falls within the given date range.
func isTimeInRange(t time.Time, fromDate, toDate *time.Time) bool {
	if fromDate != nil && t.Before(*fromDate) {
		return false
	}
	if toDate != nil && t.After(*toDate) {
		return false
	}
	return true
}

func (b *loanAccountBusiness) TransitionStatus(
	ctx context.Context,
	loanAccountID string,
	newStatus loansv1.LoanStatus,
	changedBy, reason string,
) (*loansv1.LoanAccountObject, error) {
	logger := util.Log(ctx).WithField("method", "LoanAccountBusiness.TransitionStatus")

	la, err := b.loanAccountRepo.GetByID(ctx, loanAccountID)
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}

	currentStatus := loansv1.LoanStatus(la.Status)

	// Validate transition
	if _, ok := validTransitions[currentStatus]; !ok {
		return nil, ErrInvalidStatusTransition
	}
	if !transitionAllowed(currentStatus, newStatus) {
		return nil, ErrInvalidStatusTransition.Extend(
			"cannot transition from " + currentStatus.String() + " to " + newStatus.String(),
		)
	}

	// Record status change
	statusChange := &models.LoanStatusChange{
		LoanAccountID: la.GetID(),
		FromStatus:    la.Status,
		ToStatus:      int32(newStatus),
		ChangedBy:     changedBy,
		Reason:        reason,
	}
	statusChange.GenID(ctx)

	err = b.eventsMan.Emit(ctx, events.LoanStatusChangeSaveEvent, statusChange)
	if err != nil {
		logger.WithError(err).Error("could not emit loan status change save event")
		return nil, err
	}

	// Write-off cascade. When a loan crosses into WRITTEN_OFF the remaining
	// outstanding balance stops being an asset and becomes a realised loss.
	// We record that by posting a shutdown_loan_recovery transfer order
	// (debit bad-debt expense, credit the loan asset account) for the full
	// outstanding amount. It runs before the status is claimed and is
	// idempotent on the writeoff:{loan_id} reference: a failure here leaves
	// the loan in its current status so the caller can retry, where claiming
	// first would strand it in WRITTEN_OFF — a status that only leads to
	// CLOSED — with no bad-debt posting and no way to make one.
	//
	// Per-investor tranche loss absorption is intentionally deferred: it
	// requires the funding service to enumerate tranches and post an
	// investor_loss_absorption order per tranche. That's the natural next
	// step once funding has an operations client wired; for now the loan's
	// own ledger balance is settled correctly and reconciliation will
	// surface the residual investor exposure.
	if newStatus == loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF {
		if writeOffErr := b.postWriteOffLedgerCascade(ctx, logger, la); writeOffErr != nil {
			return nil, writeOffErr
		}
	}

	// The status is claimed with a conditional write against the status we
	// validated, so two transitions racing on the same loan cannot both
	// succeed, and no other column on the row is overwritten from this
	// possibly stale copy.
	previousStatus := currentStatus
	claimed, claimErr := b.loanAccountRepo.ClaimStatus(ctx, la.GetID(), la.Status, int32(newStatus))
	if claimErr != nil {
		logger.WithError(claimErr).Error("could not update loan account status")
		return nil, claimErr
	}
	if !claimed {
		return nil, ErrInvalidStatusTransition.Extend(
			"the loan status changed while this transition was being applied",
		)
	}
	la.Status = int32(newStatus)

	// Descriptive state-change audit. Captures the transition verb, the
	// before/after status, the actor, and the reason in a single
	// queryable record so future operators can trace who moved the loan
	// from X to Y and why without having to cross-reference two tables.
	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: "loan_account",
		EntityID:   la.GetID(),
		Action:     "loan.status_changed",
		ActorID:    changedBy,
		ActorType:  "user",
		Reason:     reason,
		Before:     data.JSONMap{fieldStatus: previousStatus.String()},
		After:      data.JSONMap{fieldStatus: newStatus.String()},
		Metadata: data.JSONMap{
			fieldClientID:      la.ClientID,
			"product_id":       la.ProductID,
			"application_id":   la.LoanRequestID,
			fieldLoanRequestID: loanRequestIDFromProperties(la.Properties, la.LoanRequestID),
		},
		Parent: &la.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for loan status change")
	})

	if newStatus == loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF {
		if balance, balErr := b.loanBalanceRepo.GetByLoanAccountID(ctx, la.GetID()); balErr == nil && balance != nil {
			b.notifier.NotifyLoanWrittenOff(ctx, la, balance.TotalOutstanding)
		}
	}

	recordLoanStatusTransition(ctx, newStatus)

	return la.ToAPI(), nil
}

// recordLoanStatusTransition emits OTel counters for a loan status transition.
// Tenant attribution is attached automatically from the context's claims.
func recordLoanStatusTransition(ctx context.Context, newStatus loansv1.LoanStatus) {
	switch newStatus {
	case loansv1.LoanStatus_LOAN_STATUS_DEFAULT:
		LoansDefaulted.Add(ctx, 1)
	case loansv1.LoanStatus_LOAN_STATUS_CLOSED:
		LoansClosed.Add(ctx, 1)
	case loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED:
		LoansRestructured.Add(ctx, 1)
	case loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF:
		LoansWrittenOff.Add(ctx, 1)
	case loansv1.LoanStatus_LOAN_STATUS_UNSPECIFIED,
		loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT,
		loansv1.LoanStatus_LOAN_STATUS_ACTIVE,
		loansv1.LoanStatus_LOAN_STATUS_DELINQUENT,
		loansv1.LoanStatus_LOAN_STATUS_PAID_OFF:
		// These statuses do not have dedicated counters.
	}
}

// postWriteOffLedgerCascade issues the transfer order that recognises the
// realised loss when a loan is written off. The amount is the current
// outstanding balance (principal + accrued interest + fees + penalties).
// Missing balance rows are treated as a hard error so a silent write-off
// against a loan with unknown exposure cannot happen.
func (b *loanAccountBusiness) postWriteOffLedgerCascade(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
) error {
	if b.operationsCli == nil {
		return fmt.Errorf("operations client is not configured; cannot post write-off for loan %s", la.GetID())
	}
	if la.LedgerAssetAccountID == "" {
		return fmt.Errorf("loan %s is missing LedgerAssetAccountID; cannot post write-off", la.GetID())
	}
	if la.ProductID == "" {
		return fmt.Errorf("loan %s is missing product id; cannot resolve bad-debt expense account", la.GetID())
	}

	balance, err := b.loanBalanceRepo.GetByLoanAccountID(ctx, la.GetID())
	if err != nil || balance == nil {
		return fmt.Errorf("cannot load loan balance for write-off of %s: %w", la.GetID(), err)
	}

	outstanding := balance.TotalOutstanding
	if outstanding <= 0 {
		logger.WithField("loan_id", la.GetID()).
			Info("write-off requested on loan with zero outstanding balance; no ledger posting")
		return nil
	}

	reference := fmt.Sprintf("writeoff:%s", la.GetID())
	extraData := data.JSONMap{
		fieldLoanAccountID:      la.GetID(),
		fieldClientID:           la.ClientID,
		"principal_outstanding": balance.PrincipalOutstanding,
		"interest_outstanding":  balance.InterestAccrued,
		"fees_outstanding":      balance.FeesOutstanding,
		"penalties_outstanding": balance.PenaltiesOutstanding,
	}

	req := connect.NewRequest(&operationsv1.TransferOrderExecuteRequest{
		Data: &operationsv1.TransferOrderObject{
			DebitAccountRef:  constants.ProductBadDebtExpenseAccount(la.ProductID),
			CreditAccountRef: la.LedgerAssetAccountID,
			Amount:           moneyx.FromMinorUnitsByCurrency(la.CurrencyCode, outstanding),
			OrderType:        constants.SafeInt32FromInt(constants.TransferTypeShutdownLoanRecovery),
			Reference:        reference,
			Description:      "Loan write-off recovery",
			ExtraData:        extraData.ToProtoStruct(),
		},
	})

	if _, execErr := b.operationsCli.TransferOrderExecute(ctx, req); execErr != nil {
		logger.WithError(execErr).
			WithField("reference", reference).
			Error("could not execute write-off transfer order")
		return fmt.Errorf("write-off transfer order %s failed: %w", reference, execErr)
	}
	logger.WithField("loan_id", la.GetID()).
		WithField("amount", outstanding).
		Info("loan written off")
	return nil
}

// computeFirstRepaymentDays returns the number of days from disbursement
// to the first repayment date based on the repayment frequency.
func computeFirstRepaymentDays(freq loansv1.RepaymentFrequency) int {
	switch freq { //nolint:exhaustive // unspecified and quarterly fall through to default (weekly)
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_DAILY:
		return 1
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_WEEKLY:
		return daysPerWeek
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_BIWEEKLY:
		return daysPerBiweek
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_MONTHLY:
		return daysPerMonth
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_QUARTERLY:
		return daysPerQuarter
	default:
		return daysPerWeek
	}
}
