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
	"math"
	"sort"
	"strconv"
	"time"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"

	"buf.build/gen/go/antinvestor/funding/connectrpc/go/funding/v1/fundingv1connect"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"buf.build/gen/go/antinvestor/operations/connectrpc/go/operations/v1/operationsv1connect"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"
	"github.com/pitabwire/util/decimalx"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
	"github.com/antinvestor/service-fintech/pkg/calculation"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/fundingcompat"
)

const (
	// decimalPrecision is the number of decimal places for minor unit conversions (cents).
	decimalPrecision = 2
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
	loansv1.LoanStatus_LOAN_STATUS_DELINQUENT: {
		loansv1.LoanStatus_LOAN_STATUS_DEFAULT,
		loansv1.LoanStatus_LOAN_STATUS_ACTIVE,
		loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED,
	},
	loansv1.LoanStatus_LOAN_STATUS_DEFAULT: {
		loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF,
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
) LoanAccountBusiness {
	return &loanAccountBusiness{
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

	la, lp, err := b.populateLoanFromRequest(ctx, logger, loanRequestID)
	if err != nil {
		return nil, err
	}

	if la.PrincipalAmount <= 0 {
		return nil, fmt.Errorf("loan principal amount must be positive, got %d", la.PrincipalAmount)
	}

	if err = b.ensureLoanRequestFunding(ctx, logger, loanRequestID, la); err != nil {
		return nil, err
	}

	la.GenID(ctx)
	setInitialRepaymentDate(la)

	if err = b.eventsMan.Emit(ctx, events.LoanAccountSaveEvent, la); err != nil {
		logger.WithError(err).Error("could not emit loan account save event")
		return nil, err
	}

	b.createInitialBalance(ctx, logger, la, lp)

	if b.scheduleBusiness != nil {
		if _, schedErr := b.scheduleBusiness.Generate(ctx, la.GetID()); schedErr != nil {
			logger.WithError(schedErr).Error("could not generate repayment schedule")
		}
	}

	audit := constants.AuditTrailFromContext(ctx)
	LoansCreated.Add(ctx, 1, metric.WithAttributes(
		attribute.String("tenant_id", audit.TenantID),
		attribute.String("partition_id", audit.PartitionID),
		attribute.String("currency", la.CurrencyCode),
	))

	return la.ToAPI(), nil
}

// populateLoanFromRequest reads the local LoanRequest and populates a
// LoanAccount with its data and optional product defaults.
func (b *loanAccountBusiness) populateLoanFromRequest(
	ctx context.Context,
	logger *util.LogEntry,
	loanRequestID string,
) (*models.LoanAccount, *models.LoanProduct, error) {
	la := &models.LoanAccount{
		LoanRequestID: loanRequestID,
		Status:        int32(loansv1.LoanStatus_LOAN_STATUS_PENDING_DISBURSEMENT),
		Properties: data.JSONMap{
			"loan_request_id": loanRequestID,
		},
	}

	lr, lrErr := b.loanRequestRepo.GetByID(ctx, loanRequestID)
	if lrErr != nil {
		logger.WithError(lrErr).Error("could not fetch loan request")
		return nil, nil, ErrLoanRequestNotFound
	}

	if lr.Status != int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED) {
		return nil, nil, ErrLoanRequestNotApproved
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

	lp := b.applyProductDefaults(ctx, logger, la, lr.ProductID)
	applyLedgerDefaults(la)

	if la.PrincipalAmount <= 0 || la.TermDays <= 0 {
		return nil, nil, ErrLoanRequestTermsNotSet
	}

	return la, lp, nil
}

// applyProductDefaults enriches a loan account with product-level defaults
// (interest method, repayment frequency, rate, currency).
func (b *loanAccountBusiness) applyProductDefaults(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	productID string,
) *models.LoanProduct {
	if productID == "" {
		return nil
	}
	prod, prodErr := b.loanProductRepo.GetByID(ctx, productID)
	if prodErr != nil || prod == nil {
		logger.WithError(prodErr).Warn("could not fetch loan product, using application data only")
		return nil
	}
	la.InterestMethod = prod.InterestMethod
	la.RepaymentFrequency = prod.RepaymentFrequency
	if la.InterestRate == 0 {
		la.InterestRate = prod.AnnualInterestRate
	}
	if la.CurrencyCode == "" {
		la.CurrencyCode = prod.CurrencyCode
	}
	return prod
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
			"id":              allocation.GetId(),
			"loan_request_id": fundingcompat.AllocationLoanRequestID(allocation),
			"source_id":       allocation.GetSourceId(),
			"source_type":     allocation.GetSourceType(),
			"tranche_level":   float64(allocation.GetTrancheLevel()),
			"amount":          float64(amount),
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

// createInitialBalance creates the initial loan balance snapshot and emits it.
func (b *loanAccountBusiness) createInitialBalance(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	lp *models.LoanProduct,
) {
	totalInterest, totalFees := computeInterestAndFees(la, lp)
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
		logger.WithError(err).Warn("could not emit loan balance save event")
	}
}

func (b *loanAccountBusiness) Get(ctx context.Context, id string) (*loansv1.LoanAccountObject, error) {
	la, err := b.loanAccountRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrLoanAccountNotFound
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
				map[string]any{"searchable @@ websearch_to_tsquery( 'english', ?) ": req.GetQuery()},
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

	balance, balErr := b.loanBalanceRepo.GetByLoanAccountID(ctx, req.GetLoanAccountId())
	if balErr != nil {
		logger.WithError(balErr).Warn("could not load balance for statement")
	}

	var balanceAPI *loansv1.LoanBalanceObject
	if balance != nil {
		balanceAPI = balance.ToAPI()
	}

	fromDate := models.StringToTime(req.GetFromDate())
	toDate := models.StringToTime(req.GetToDate())
	statementEntries := b.buildStatementEntries(ctx, req.GetLoanAccountId(), fromDate, toDate)

	return &loansv1.LoanStatementResponse{
		Loan:    la.ToAPI(),
		Balance: balanceAPI,
		Entries: statementEntries,
	}, nil
}

// statementEntry is an internal type used to sort and compute running balances
// before converting to the proto LoanStatementEntry.
type statementEntry struct {
	date        time.Time
	description string
	debit       int64 // charges to the borrower (increases balance)
	credit      int64 // payments by the borrower (decreases balance)
	reference   string
	currency    string
}

// buildStatementEntries collects all financial events for a loan (disbursement,
// penalties, repayments), sorts them chronologically, computes a running
// balance, and returns proto statement entries filtered by the given date range.
//
//nolint:gocognit,funlen // statement assembly is inherently complex
func (b *loanAccountBusiness) buildStatementEntries(
	ctx context.Context,
	loanAccountID string,
	fromDate, toDate *time.Time,
) []*loansv1.LoanStatementEntry {
	la, laErr := b.loanAccountRepo.GetByID(ctx, loanAccountID)
	if laErr != nil {
		return nil
	}

	var raw []statementEntry

	// 1. Disbursement entry (the initial loan advance)
	if la.DisbursedAt != nil {
		raw = append(raw, statementEntry{
			date:        *la.DisbursedAt,
			description: "Loan disbursement",
			debit:       la.PrincipalAmount,
			currency:    la.CurrencyCode,
			reference:   la.LoanRequestID,
		})
	}

	// 2. Penalty entries
	penQuery := data.NewSearchQuery(
		data.WithSearchFiltersAndByValue(map[string]any{
			"loan_account_id = ?": loanAccountID,
		}),
	)
	if penResults, penErr := b.penaltyRepo.Search(ctx, penQuery); penErr == nil {
		_ = workerpoolConsumeStream(ctx, penResults, func(batch []*models.Penalty) error {
			for _, p := range batch {
				if p.IsWaived {
					continue
				}
				t := p.CreatedAt
				raw = append(raw, statementEntry{
					date:        t,
					description: "Penalty: " + p.Reason,
					debit:       p.Amount,
					currency:    p.CurrencyCode,
					reference:   p.GetID(),
				})
			}
			return nil
		})
	}

	// 3. Repayment entries
	repQuery := data.NewSearchQuery(
		data.WithSearchFiltersAndByValue(map[string]any{
			"loan_account_id = ?": loanAccountID,
		}),
	)
	if repResults, repErr := b.repaymentRepo.Search(ctx, repQuery); repErr == nil {
		_ = workerpoolConsumeStream(ctx, repResults, func(batch []*models.Repayment) error {
			for _, r := range batch {
				raw = append(raw, statementEntry{
					date:        r.CreatedAt,
					description: "Repayment via " + r.Channel,
					credit:      r.Amount,
					currency:    r.CurrencyCode,
					reference:   r.PaymentReference,
				})
			}
			return nil
		})
	}

	// Sort chronologically
	sort.Slice(raw, func(i, j int) bool {
		return raw[i].date.Before(raw[j].date)
	})

	// Compute running balance and filter by date range.
	// If fromDate is set, emit an opening balance row for the period.
	var entries []*loansv1.LoanStatementEntry
	var runningBalance int64
	openingBalanceEmitted := fromDate == nil // skip opening balance if no date filter
	currency := la.CurrencyCode

	for _, e := range raw {
		runningBalance += e.debit - e.credit

		if !isTimeInRange(e.date, fromDate, toDate) {
			continue
		}

		// Emit opening balance row before the first in-range entry
		if !openingBalanceEmitted {
			openingBalance := runningBalance - e.debit + e.credit // balance before this entry
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
			Balance:     models.MinorUnitsToMoney(runningBalance, e.currency),
			Reference:   e.reference,
		}
		if e.debit > 0 {
			entry.Debit = models.MinorUnitsToMoney(e.debit, e.currency)
		}
		if e.credit > 0 {
			entry.Credit = models.MinorUnitsToMoney(e.credit, e.currency)
		}
		entries = append(entries, entry)
	}

	return entries
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
	allowed, ok := validTransitions[currentStatus]
	if !ok {
		return nil, ErrInvalidStatusTransition
	}

	valid := false
	for _, s := range allowed {
		if s == newStatus {
			valid = true
			break
		}
	}
	if !valid {
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

	// Update loan account status
	previousStatus := currentStatus
	la.Status = int32(newStatus)
	err = b.eventsMan.Emit(ctx, events.LoanAccountSaveEvent, la)
	if err != nil {
		logger.WithError(err).Error("could not emit loan account save event")
		return nil, err
	}

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
		Before:     data.JSONMap{"status": previousStatus.String()},
		After:      data.JSONMap{"status": newStatus.String()},
		Metadata: data.JSONMap{
			"client_id":       la.ClientID,
			"product_id":      la.ProductID,
			"application_id":  la.LoanRequestID,
			"loan_request_id": loanRequestIDFromProperties(la.Properties, la.LoanRequestID),
		},
		Parent: &la.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for loan status change")
	})

	recordLoanStatusTransition(ctx, newStatus)

	// Write-off cascade. When a loan crosses into WRITTEN_OFF the remaining
	// outstanding balance stops being an asset and becomes a realised loss.
	// We record that by posting a shutdown_loan_recovery transfer order
	// (debit bad-debt expense, credit the loan asset account) for the full
	// outstanding amount. Idempotent via the writeoff:{loan_id} reference.
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

	return la.ToAPI(), nil
}

// recordLoanStatusTransition emits OTel counters for a loan status transition.
func recordLoanStatusTransition(ctx context.Context, newStatus loansv1.LoanStatus) {
	auditCtx := constants.AuditTrailFromContext(ctx)
	statusAttrs := metric.WithAttributes(
		attribute.String("tenant_id", auditCtx.TenantID),
		attribute.String("partition_id", auditCtx.PartitionID),
	)
	switch newStatus {
	case loansv1.LoanStatus_LOAN_STATUS_DEFAULT:
		LoansDefaulted.Add(ctx, 1, statusAttrs)
	case loansv1.LoanStatus_LOAN_STATUS_CLOSED:
		LoansClosed.Add(ctx, 1, statusAttrs)
	case loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED:
		LoansRestructured.Add(ctx, 1, statusAttrs)
	case loansv1.LoanStatus_LOAN_STATUS_WRITTEN_OFF:
		LoansWrittenOff.Add(ctx, 1, statusAttrs)
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
		"loan_account_id":       la.GetID(),
		"client_id":             la.ClientID,
		"principal_outstanding": balance.PrincipalOutstanding,
		"interest_outstanding":  balance.InterestAccrued,
		"fees_outstanding":      balance.FeesOutstanding,
		"penalties_outstanding": balance.PenaltiesOutstanding,
	}

	req := connect.NewRequest(&operationsv1.TransferOrderExecuteRequest{
		Data: &operationsv1.TransferOrderObject{
			DebitAccountRef:  constants.ProductBadDebtExpenseAccount(la.ProductID),
			CreditAccountRef: la.LedgerAssetAccountID,
			Amount:           moneyx.FromSmallestUnit(la.CurrencyCode, outstanding, decimalPrecision),
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

// computeInterestAndFees calculates total interest and fees for a loan based on
// the product configuration. Returns (0, 0) if no product is provided.
func computeInterestAndFees(la *models.LoanAccount, lp *models.LoanProduct) (int64, int64) {
	if lp == nil {
		return 0, 0
	}
	ppy := int64(
		calculation.PeriodsPerYear(frequencyToPeriodType(loansv1.RepaymentFrequency(la.RepaymentFrequency))),
	)
	numInstallments := computeInstallmentCount(la.TermDays, loansv1.RepaymentFrequency(la.RepaymentFrequency))
	if numInstallments <= 0 {
		numInstallments = 1
	}
	principal := decimalx.FromMinorUnits(la.PrincipalAmount, decimalPrecision)
	totalInterest := calculation.FlatRateInterest(principal, la.InterestRate, numInstallments, safeInt32(ppy)).
		ToMinorUnits(decimalPrecision)
	totalFees := calculation.FlatRateInterest(
		principal,
		lp.InsuranceFeePercent+lp.ProcessingFeePercent,
		numInstallments,
		safeInt32(ppy),
	).ToMinorUnits(decimalPrecision)
	return totalInterest, totalFees
}

// safeInt32 converts an int64 to int32 with clamping to avoid overflow.
func safeInt32(v int64) int32 {
	if v > math.MaxInt32 {
		return math.MaxInt32
	}
	if v < math.MinInt32 {
		return math.MinInt32
	}
	return int32(v)
}
