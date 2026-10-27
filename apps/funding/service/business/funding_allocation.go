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

	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"
	"github.com/pitabwire/util/decimalx"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/calculation"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

const (
	// basisPointsDenominator is the multiplier used to convert proportions to basis points.
	basisPointsDenominator = 10000
	// trancheMezzanine is the tranche level for mezzanine (affiliated/general investor) sources.
	trancheMezzanine int32 = 2
	// trancheSenior is the tranche level for senior (general investor) sources.
	trancheSenior int32 = 3
)

var (
	// ErrLoanRequestNotFound is returned when the request to fund does not exist.
	ErrLoanRequestNotFound = apperrors.NewError(apperrors.NotFound, "loan request not found")
	// ErrLoanRequestAmountInvalid is returned when a request carries no amount to fund.
	ErrLoanRequestAmountInvalid = apperrors.NewError(
		apperrors.Unprocessable, "loan request has no amount to fund")
	// ErrLossProductRequired is returned for a loss that names no product:
	// without one the loss cannot be posted to funders' capital.
	ErrLossProductRequired = apperrors.NewError(apperrors.BadRequest,
		"a loss must name the product whose bad debt the funders take")
	// ErrLossAmountNotPositive is returned for a zero or negative loss.
	ErrLossAmountNotPositive = apperrors.NewError(apperrors.BadRequest, "loss amount must be positive")
	// ErrAllocationInProgress is returned while another call is building the
	// request's allocation. The caller retries; it never gets a partial one.
	ErrAllocationInProgress = apperrors.NewError(apperrors.ServiceUnavailable,
		"the loan request's funding is being allocated; retry shortly")
)

// allocationLeaseSeconds bounds how long a call may take to build an
// allocation before another call may take the request over. An allocation is
// a handful of reads and writes; a holder still running past this has
// crashed or stalled.
const allocationLeaseSeconds = 300

type fundingAllocationBusiness struct {
	eventsMan  fevents.Manager
	lfRepo     repository.LoanFundingRepository
	claimRepo  repository.LoanFundingClaimRepository
	lossRepo   repository.LossAbsorptionRepository
	lrReader   LoanRequestReader
	iaRepo     repository.InvestorAccountRepository
	ftRepo     repository.FundingTrancheRepository
	srcBalance SourceBalances
	poster     LedgerPoster
}

func NewFundingAllocationBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	lfRepo repository.LoanFundingRepository,
	claimRepo repository.LoanFundingClaimRepository,
	lossRepo repository.LossAbsorptionRepository,
	lrReader LoanRequestReader,
	iaRepo repository.InvestorAccountRepository,
	ftRepo repository.FundingTrancheRepository,
	srcBalance SourceBalances,
	poster LedgerPoster,
) FundingAllocationBusiness {
	return &fundingAllocationBusiness{
		eventsMan:  eventsMan,
		lfRepo:     lfRepo,
		claimRepo:  claimRepo,
		lossRepo:   lossRepo,
		lrReader:   lrReader,
		iaRepo:     iaRepo,
		ftRepo:     ftRepo,
		srcBalance: srcBalance,
		poster:     poster,
	}
}

// SourceForRequest allocates funding sources for a loan request.
//
// A unique loan_request_id claim row is taken before anything is computed, so
// only one call can ever build an allocation for a request: a concurrent or
// retried FundLoan reads back what the winner persisted instead of reserving
// investor capital a second time. Every source's available capital is read
// from the system that actually holds it, and a reservation that cannot be
// placed fails the whole allocation rather than leaving a loan reported as
// funded against capital nobody committed.
func (b *fundingAllocationBusiness) SourceForRequest(
	ctx context.Context,
	loanRequestID string,
) (*AllocationResult, error) {
	logger := util.Log(ctx).WithField("method", "FundingAllocationBusiness.SourceForRequest")

	if b.lrReader == nil {
		return nil, errors.New("loan request reader not configured")
	}
	requestInfo, err := b.lrReader.GetByID(ctx, loanRequestID)
	if err != nil {
		return nil, ErrLoanRequestNotFound
	}

	claim := &models.LoanFundingClaim{LoanRequestID: loanRequestID}
	claim.GenID(ctx)
	claim.CopyPartitionInfo(&requestInfo.BaseModel)

	outcome, lease, claimErr := b.claimRepo.Claim(ctx, claim, allocationLeaseSeconds)
	if claimErr != nil {
		return nil, fmt.Errorf("claim allocation lock: %w", claimErr)
	}
	switch outcome {
	case repository.ClaimCompleted:
		return b.buildPersistedResult(ctx, loanRequestID, requestInfo)
	case repository.ClaimHeld:
		return nil, ErrAllocationInProgress
	case repository.ClaimTakenOver:
		// The previous holder stopped part way: give back what it reserved
		// and void what it wrote before building the allocation afresh.
		logger.Warn("taking over an allocation left unfinished; voiding what it left")
		fundings, loadErr := b.lfRepo.GetByLoanRequestID(ctx, loanRequestID)
		if loadErr != nil {
			return nil, fmt.Errorf("load the unfinished allocation: %w", loadErr)
		}
		if _, _, voidErr := b.voidActiveFundings(ctx, logger, fundings); voidErr != nil {
			return nil, voidErr
		}
	case repository.ClaimTaken:
	}

	// Giving capital back must not be cut short by the caller going away.
	cleanupCtx := context.WithoutCancel(ctx)

	result, run, err := b.allocate(ctx, logger, loanRequestID, requestInfo)
	if err != nil {
		// Nothing was committed, so drop the lock and let the request be
		// funded on a later attempt.
		if releaseErr := b.claimRepo.ReleaseHeld(cleanupCtx, loanRequestID, lease); releaseErr != nil {
			logger.WithError(releaseErr).Error("could not release the allocation lock after a failed allocation")
		}
		return nil, err
	}
	if !result.FullyFunded {
		// A short allocation is not a funded loan. Holding the lock and the
		// reservations would answer every retry with the same shortfall even
		// after new capital arrives; give both back so a later attempt can
		// fund the request in full.
		logger.WithField("deficit", result.Deficit).Warn("loan request not fully funded; releasing allocation")
		b.rollbackReservations(cleanupCtx, logger, run.reserved)
		b.voidRecords(cleanupCtx, logger, run.written)
		if releaseErr := b.claimRepo.ReleaseHeld(cleanupCtx, loanRequestID, lease); releaseErr != nil {
			logger.WithError(releaseErr).Error("could not release the allocation lock after a short allocation")
		}
		result.Allocations = nil
		result.TotalAllocated = 0
		result.Deficit = result.LoanAmount
		return result, nil
	}

	completed, completeErr := b.claimRepo.Complete(ctx, loanRequestID, lease)
	if completeErr != nil {
		// Left allocating: once the lease lapses a retry voids this run's
		// allocation and builds it again.
		return nil, fmt.Errorf("complete the allocation: %w", completeErr)
	}
	if !completed {
		// This call outlived its lease and another took the request over.
		// That call voided what it found; void the rest of this run.
		logger.Warn("allocation lease lapsed before it completed; voiding this run's allocation")
		if _, _, voidErr := b.voidActiveFundings(cleanupCtx, logger, run.written.fundings); voidErr != nil {
			logger.WithError(voidErr).Error("could not void an allocation whose lease lapsed")
		}
		return nil, ErrAllocationInProgress
	}
	return result, nil
}

// reservation is capital set aside on an investor account during allocation,
// kept so a failed or short allocation can give it back, together with the
// funding records this run wrote so they can be voided alongside.
type reservation struct {
	investorAccountID string
	amount            int64
}

// writtenRecords are the funding and tranche rows one allocation run emitted.
type writtenRecords struct {
	fundings []*models.LoanFunding
	tranches []*models.FundingTranche
}

// voidRecords marks the run's funding and tranche rows inactive, so a later
// read of the request's allocation does not count capital that was given
// back. Emitted through the same event path that created them.
func (b *fundingAllocationBusiness) voidRecords(ctx context.Context, logger *util.LogEntry, written writtenRecords) {
	for _, f := range written.fundings {
		f.State = int32(constants.StateInactive)
		if _, err := b.lfRepo.Update(ctx, f, "state"); err != nil {
			logger.WithError(err).WithField("loan_funding_id", f.GetID()).Error("could not void loan funding record")
		}
	}
	for _, t := range written.tranches {
		t.State = int32(constants.StateInactive)
		if _, err := b.ftRepo.Update(ctx, t, "state"); err != nil {
			logger.WithError(err).
				WithField("funding_tranche_id", t.GetID()).
				Error("could not void funding tranche record")
		}
	}
}

// rollbackReservations returns reserved capital to the investors' available
// balances. Each release is logged on failure and the rest still run.
func (b *fundingAllocationBusiness) rollbackReservations(
	ctx context.Context,
	logger *util.LogEntry,
	reserved []reservation,
) {
	for _, r := range reserved {
		if _, err := b.iaRepo.AtomicRelease(ctx, r.investorAccountID, r.amount); err != nil {
			logger.WithError(err).WithFields(map[string]any{
				fieldInvestorAccountID: r.investorAccountID,
				"amount":               r.amount,
			}).Error("could not release investor reservation; capital stays reserved until reconciled")
		}
	}
}

// allocate computes and persists the tranche allocation for a claimed
// request, returning what it reserved so the caller can give it back.
func (b *fundingAllocationBusiness) allocate(
	ctx context.Context,
	logger *util.LogEntry,
	loanRequestID string,
	requestInfo *LoanRequestInfo,
) (*AllocationResult, allocationRun, error) {
	loanAmount := requestInfo.Amount
	if loanAmount <= 0 {
		return nil, allocationRun{}, ErrLoanRequestAmountInvalid
	}

	precision := moneyx.Decimals(requestInfo.Currency)
	loanAmountDec := decimalx.FromMinorUnits(loanAmount, precision)
	request := buildFundingRequest(requestInfo, loanAmountDec)

	sources, err := b.gatherFundingSources(ctx, request, precision)
	if err != nil {
		return nil, allocationRun{}, err
	}
	calcResult := calculation.AllocateLoanFunding(request, sources)

	if !calculation.VerifyTrancheAllocationInvariant(loanAmountDec, calcResult) {
		logger.WithField("total_allocated", calcResult.TotalAllocated).
			WithField("deficit", calcResult.Deficit).
			Warn("loan request not fully funded")
	}

	allocations, run, err := b.persistAllocations(ctx, loanRequestID, requestInfo.Currency, precision, calcResult)
	if err != nil {
		return nil, allocationRun{}, err
	}

	logger.WithField("loan_request_id", loanRequestID).
		WithField("loan_amount", loanAmount).
		WithField("tranches", len(calcResult.Allocations)).
		Info("tranche-based funding allocation completed")

	currencyAttr := attribute.String("currency", requestInfo.Currency)
	FundingAllocations.Add(ctx, 1, currencyAttr)
	FundingAllocationsAmount.Add(ctx,
		float64(calcResult.TotalAllocated.ToMinorUnits(precision))/minorUnitsPerMajor,
		currencyAttr)

	deficit := calcResult.Deficit.ToMinorUnits(precision)
	return &AllocationResult{
		LoanRequestID:  loanRequestID,
		Currency:       requestInfo.Currency,
		LoanAmount:     loanAmount,
		TotalAllocated: calcResult.TotalAllocated.ToMinorUnits(precision),
		Deficit:        deficit,
		FullyFunded:    deficit == 0,
		IsGroupLoan:    request.IsGroupLoan,
		Allocations:    allocations,
	}, run, nil
}

// allocationRun is what one allocation attempt reserved and wrote.
type allocationRun struct {
	reserved []reservation
	written  writtenRecords
}

// persistAllocations creates the LoanFunding and FundingTranche records for
// each allocation and reserves the investor capital behind them. A failure at
// any step aborts the allocation: a partially reserved loan is not a funded
// loan.
func (b *fundingAllocationBusiness) persistAllocations(
	ctx context.Context,
	loanRequestID, currency string,
	precision int32,
	result calculation.FundingResult,
) ([]Allocation, allocationRun, error) {
	allocations := make([]Allocation, 0, len(result.Allocations))
	var run allocationRun
	// Giving capital back must not be cut short by the caller going away.
	cleanupCtx := context.WithoutCancel(ctx)
	for _, alloc := range result.Allocations {
		if !alloc.Amount.IsPositive() {
			continue
		}

		proportion := computeProportion(alloc.Amount, result.TotalAllocated)
		allocAmount := alloc.Amount.ToMinorUnits(precision)

		funding := buildLoanFundingRecord(ctx, loanRequestID, currency, alloc, proportion, allocAmount)
		// Written synchronously: a record a later run or a rollback acts on
		// must exist by the time this call returns.
		if createErr := b.lfRepo.Create(ctx, funding); createErr != nil {
			b.rollbackReservations(cleanupCtx, util.Log(ctx), run.reserved)
			b.voidRecords(cleanupCtx, util.Log(ctx), run.written)
			return nil, allocationRun{}, fmt.Errorf("persist loan funding: %w", createErr)
		}
		run.written.fundings = append(run.written.fundings, funding)

		investorAccountID := investorAccountIDForAlloc(alloc)
		tranche := buildFundingTrancheRecord(ctx, funding.GetID(), investorAccountID, alloc, allocAmount, currency)
		if investorAccountID != "" {
			// Active only once its capital is reserved, so whoever voids an
			// unfinished allocation gives back exactly what was reserved.
			tranche.State = int32(constants.StateJustCreated)
		}
		if createErr := b.ftRepo.Create(ctx, tranche); createErr != nil {
			b.rollbackReservations(cleanupCtx, util.Log(ctx), run.reserved)
			b.voidRecords(cleanupCtx, util.Log(ctx), run.written)
			return nil, allocationRun{}, fmt.Errorf("persist funding tranche: %w", createErr)
		}
		run.written.tranches = append(run.written.tranches, tranche)

		if investorAccountID != "" {
			if resErr := b.reserveInvestorBalance(ctx, investorAccountID, allocAmount); resErr != nil {
				// A partially reserved loan is not a funded loan: give back
				// what this run reserved and void what it wrote before failing.
				b.rollbackReservations(cleanupCtx, util.Log(ctx), run.reserved)
				b.voidRecords(cleanupCtx, util.Log(ctx), run.written)
				return nil, allocationRun{}, resErr
			}
			run.reserved = append(run.reserved, reservation{investorAccountID: investorAccountID, amount: allocAmount})
			tranche.State = int32(constants.StateActive)
			if _, markErr := b.ftRepo.Update(ctx, tranche, "state"); markErr != nil {
				b.rollbackReservations(cleanupCtx, util.Log(ctx), run.reserved)
				b.voidRecords(cleanupCtx, util.Log(ctx), run.written)
				return nil, allocationRun{}, fmt.Errorf("mark funding tranche reserved: %w", markErr)
			}
		}

		allocations = append(allocations, Allocation{
			ID:            funding.GetID(),
			LoanRequestID: loanRequestID,
			SourceID:      alloc.SourceID,
			SourceType:    fundingSourceLabel(alloc.SourceType),
			TrancheLevel:  alloc.TrancheLevel,
			Amount:        allocAmount,
			Currency:      currency,
		})
	}

	return allocations, run, nil
}

// computeProportion returns the allocation proportion in basis points.
func computeProportion(amount, totalAllocated decimalx.Decimal) int64 {
	if !totalAllocated.IsPositive() {
		return 0
	}
	return amount.Mul(decimalx.NewFromInt64(basisPointsDenominator)).
		Div(totalAllocated).
		Int64()
}

// investorAccountIDForAlloc returns the source ID if the allocation is investor-backed.
func investorAccountIDForAlloc(alloc calculation.FundingAllocation) string {
	if alloc.SourceType == int32(models.FundingSourceInvestorAffiliated) ||
		alloc.SourceType == int32(models.FundingSourceInvestorGeneral) {
		return alloc.SourceID
	}
	return ""
}

// buildLoanFundingRecord creates a LoanFunding model from an allocation.
func buildLoanFundingRecord(
	ctx context.Context,
	loanRequestID, currency string,
	alloc calculation.FundingAllocation,
	proportion, allocAmount int64,
) *models.LoanFunding {
	funding := &models.LoanFunding{
		LoanRequestID: loanRequestID,
		FundingType:   alloc.SourceType,
		Proportion:    proportion,
		Amount:        allocAmount,
		Currency:      currency,
		OwnerID:       alloc.SourceID,
		OwnerType:     fundingSourceOwnerType(alloc.SourceType),
		Description: fmt.Sprintf("Tranche %d funding from %s for request %s",
			alloc.TrancheLevel, alloc.SourceID, loanRequestID),
		State: int32(constants.StateActive),
	}
	funding.GenID(ctx)
	return funding
}

// buildFundingTrancheRecord creates a FundingTranche model for a funding record.
func buildFundingTrancheRecord(
	ctx context.Context,
	loanFundingID, investorAccountID string,
	alloc calculation.FundingAllocation,
	allocAmount int64,
	currency string,
) *models.FundingTranche {
	tranche := &models.FundingTranche{
		LoanFundingID:     loanFundingID,
		InvestorAccountID: investorAccountID,
		TrancheLevel:      alloc.TrancheLevel,
		Amount:            allocAmount,
		Currency:          currency,
		State:             int32(constants.StateActive),
	}
	tranche.GenID(ctx)
	return tranche
}

// buildFundingRequest extracts loan parameters from request properties into a FundingRequest.
func buildFundingRequest(requestInfo *LoanRequestInfo, loanAmount decimalx.Decimal) calculation.FundingRequest {
	var (
		isGroupLoan  bool
		groupID      string
		productType  string
		region       string
		interestRate int64
	)

	if requestInfo.Properties != nil {
		if gid, ok := requestInfo.Properties["group_id"].(string); ok && gid != "" {
			isGroupLoan = true
			groupID = gid
		}
		if pt, ok := requestInfo.Properties["product_type"].(string); ok {
			productType = pt
		}
		if r, ok := requestInfo.Properties["region"].(string); ok {
			region = r
		}
		if ir, ok := requestInfo.Properties["interest_rate"].(float64); ok {
			interestRate = int64(ir)
		}
	}

	return calculation.FundingRequest{
		LoanAmount:   loanAmount,
		Currency:     requestInfo.Currency,
		InterestRate: interestRate,
		ProductType:  productType,
		Region:       region,
		GroupID:      groupID,
		IsGroupLoan:  isGroupLoan,
	}
}

// AbsorbLoss distributes a loss across the loan's funding tranches in order,
// first-loss first, and reports what they actually covered.
//
// A tranche can only lose what it still has lent out: its amount less the
// principal already repaid and any loss it already took. The absorption row,
// every tranche charge and every investor charge are written in one
// transaction unique on the loss reference, so a repeat moves nothing and a
// crash part way leaves nothing half applied. When the loss names a product,
// each funder's part is then moved off the product's bad-debt expense onto
// their capital on the ledger; a repeat finishes postings left undone.
func (b *fundingAllocationBusiness) AbsorbLoss(
	ctx context.Context,
	loss LossApplication,
) (*LossResult, error) {
	logger := util.Log(ctx).WithField("method", "FundingAllocationBusiness.AbsorbLoss").
		WithField("loan_request_id", loss.LoanRequestID)

	if loss.Amount <= 0 {
		return nil, ErrLossAmountNotPositive
	}

	if stored, err := b.lossRepo.GetByReference(ctx, lossReference(loss.LoanRequestID)); err == nil && stored != nil {
		return b.settleLoss(ctx, logger, stored)
	}

	sources, err := loadTrancheSources(ctx, b.lfRepo, b.ftRepo, loss.LoanRequestID)
	if err != nil {
		return nil, err
	}
	currency := loss.Currency
	if len(sources) > 0 && sources[0].tranche.Currency != "" {
		currency = sources[0].tranche.Currency
	}

	shares, remaining := computeLossShares(sources, loss.Amount)
	absorption := &models.LossAbsorption{
		LoanRequestID: loss.LoanRequestID,
		Reference:     lossReference(loss.LoanRequestID),
		LossAmount:    loss.Amount,
		Absorbed:      loss.Amount - remaining,
		Unrecoverable: remaining,
		Currency:      currency,
		ProductID:     loss.ProductID,
		Properties:    encodeShares(shares),
	}
	absorption.GenID(ctx)
	if len(sources) > 0 {
		absorption.CopyPartitionInfo(&sources[0].tranche.BaseModel)
	}

	movements := make([]repository.TrancheMovement, 0, len(shares))
	for _, s := range shares {
		movements = append(movements, repository.TrancheMovement{
			TrancheID:         s.TrancheID,
			InvestorAccountID: s.InvestorAccountID,
			Principal:         s.Principal,
		})
	}
	stored, _, err := b.lossRepo.ClaimAndApply(ctx, absorption, movements)
	if err != nil {
		return nil, fmt.Errorf("absorb loss: %w", err)
	}
	if stored.Unrecoverable > 0 {
		logger.WithField("unrecoverable", stored.Unrecoverable).
			Error("unrecoverable loss: all tranches exhausted")
	}
	return b.settleLoss(ctx, logger, stored)
}

// computeLossShares walks the tranches in priority order and charges each
// the most it can still carry, returning the shares and what none covered.
func computeLossShares(sources []trancheSource, lossAmount int64) ([]RepaymentShare, int64) {
	remaining := lossAmount
	var shares []RepaymentShare
	for _, s := range sources {
		if remaining <= 0 {
			break
		}
		exposure := s.tranche.Amount - s.tranche.PrincipalRepaid - s.tranche.LossAbsorbed
		if exposure <= 0 {
			continue
		}
		absorbed := min(exposure, remaining)
		remaining -= absorbed
		shares = append(shares, RepaymentShare{
			TrancheID:         s.tranche.GetID(),
			SourceID:          s.funding.OwnerID,
			SourceType:        s.funding.FundingType,
			TrancheLevel:      s.tranche.TrancheLevel,
			InvestorAccountID: s.tranche.InvestorAccountID,
			Principal:         absorbed,
		})
	}
	return shares, remaining
}

// settleLoss posts the absorbed loss to the ledger: each investor's capital
// and the platform's first-loss reserve take their part of the product's
// bad-debt expense. A group's part stays an expense of the product until the
// group's own ledger carries members' savings losses.
func (b *fundingAllocationBusiness) settleLoss(
	ctx context.Context,
	logger *util.LogEntry,
	stored *models.LossAbsorption,
) (*LossResult, error) {
	result := &LossResult{
		Absorbed:      stored.Absorbed,
		Unrecoverable: stored.Unrecoverable,
		Currency:      stored.Currency,
		Settled:       stored.SettledAt != nil || stored.ProductID == "",
	}
	if result.Settled {
		return result, nil
	}
	if b.poster == nil {
		return result, nil
	}
	shares, err := decodeShares(stored.Properties)
	if err != nil {
		return nil, fmt.Errorf("read loss absorption %s: %w", stored.GetID(), err)
	}
	expense := constants.ProductBadDebtExpenseAccount(stored.ProductID)
	for _, s := range shares {
		var debit string
		var transferType int
		switch models.FundingSource(s.SourceType) {
		case models.FundingSourceInvestorAffiliated, models.FundingSourceInvestorGeneral:
			debit, transferType = constants.InvestorCapitalAccount(s.InvestorAccountID),
				constants.TransferTypeInvestorLossAbsorption
		case models.FundingSourcePlatformReserve:
			debit, transferType = constants.PlatformFirstLossAccount(stored.ProductID),
				constants.TransferTypePlatformFirstLossAbsorption
		case models.FundingSourceGroupSavings, models.FundingSourceGroupIncome, models.FundingSourceUnspecified:
			continue
		}
		posting := LedgerPosting{
			Reference: fmt.Sprintf("fund-loss:%s:%s", stored.GetID(), s.TrancheID),
			Debit:     debit, Credit: expense,
			Amount: s.Principal, Currency: stored.Currency, Type: transferType,
			Description: "Funder share of a written-off loan",
			Extra: data.JSONMap{
				fieldLoanRequestID:     stored.LoanRequestID,
				fieldTrancheID:         s.TrancheID,
				fieldInvestorAccountID: s.InvestorAccountID,
			},
		}
		if postErr := b.poster.Post(ctx, posting); postErr != nil {
			logger.WithError(postErr).WithField("posting_reference", posting.Reference).
				Warn("loss share not yet posted; a later call finishes it")
			return result, nil
		}
	}
	if markErr := b.lossRepo.MarkSettled(ctx, stored.GetID()); markErr != nil {
		logger.WithError(markErr).Warn("loss shares posted but not marked settled; a later call marks it")
		return result, nil
	}
	result.Settled = true
	return result, nil
}

// lossReference derives the idempotency key for one absorption. A loan is
// written off once, so the loan request alone keys it. Folding the amount in
// would make a retry that rounds differently, or a second write-off attempt
// for a larger figure, mint a fresh key and eat the tranches twice.
func lossReference(loanRequestID string) string {
	return "loss:" + loanRequestID
}

// buildPersistedResult renders the allocation another call already committed.
func (b *fundingAllocationBusiness) buildPersistedResult(
	ctx context.Context,
	loanRequestID string,
	requestInfo *LoanRequestInfo,
) (*AllocationResult, error) {
	fundings, err := b.lfRepo.GetByLoanRequestID(ctx, loanRequestID)
	if err != nil {
		return nil, fmt.Errorf("load persisted allocation: %w", err)
	}

	allocations := make([]Allocation, 0, len(fundings))
	var totalAllocated int64
	for _, funding := range fundings {
		if funding.State != int32(constants.StateActive) {
			// Voided by a short or failed allocation: not capital behind this loan.
			continue
		}
		totalAllocated += funding.Amount
		trancheLevel := int32(0)
		tranches, trancheErr := b.ftRepo.GetByLoanFundingID(ctx, funding.GetID())
		if trancheErr != nil {
			return nil, fmt.Errorf("load persisted tranches: %w", trancheErr)
		}
		if len(tranches) > 0 {
			trancheLevel = tranches[0].TrancheLevel
		}
		allocations = append(allocations, Allocation{
			ID:            funding.GetID(),
			LoanRequestID: loanRequestID,
			SourceID:      funding.OwnerID,
			SourceType:    fundingSourceLabel(funding.FundingType),
			TrancheLevel:  trancheLevel,
			Amount:        funding.Amount,
			Currency:      funding.Currency,
		})
	}

	deficit := max(requestInfo.Amount-totalAllocated, 0)

	return &AllocationResult{
		LoanRequestID:  loanRequestID,
		Currency:       requestInfo.Currency,
		LoanAmount:     requestInfo.Amount,
		TotalAllocated: totalAllocated,
		Deficit:        deficit,
		FullyFunded:    deficit == 0,
		Allocations:    allocations,
	}, nil
}

// FundingSourceLabel names a funding source type for API responses.
func FundingSourceLabel(sourceType int32) string { return fundingSourceLabel(sourceType) }

func fundingSourceLabel(sourceType int32) string {
	switch models.FundingSource(sourceType) {
	case models.FundingSourceUnspecified:
		return "unspecified"
	case models.FundingSourceGroupSavings:
		return "group_savings"
	case models.FundingSourceGroupIncome:
		return "group_income"
	case models.FundingSourceInvestorAffiliated:
		return "investor_affiliated"
	case models.FundingSourceInvestorGeneral:
		return "investor_general"
	case models.FundingSourcePlatformReserve:
		return "platform_reserve"
	default:
		return "unspecified"
	}
}

// gatherFundingSources collects the funding sources available to a request.
// Every balance is read from the system that holds it; a source whose balance
// cannot be verified aborts the allocation rather than being invented, and a
// failed investor query is an error, never an empty investor pool.
func (b *fundingAllocationBusiness) gatherFundingSources(
	ctx context.Context,
	request calculation.FundingRequest,
	precision int32,
) ([]calculation.FundingSource, error) {
	if request.IsGroupLoan {
		return b.groupLoanSources(ctx, request, precision)
	}
	return b.directLoanSources(ctx, request, precision)
}

// groupLoanSources builds the three-tranche stack for a group loan: the
// group's own savings first, then affiliated investors, then the general pool.
func (b *fundingAllocationBusiness) groupLoanSources(
	ctx context.Context,
	request calculation.FundingRequest,
	precision int32,
) ([]calculation.FundingSource, error) {
	var sources []calculation.FundingSource

	groupSavings, err := b.srcBalance.GroupSavings(ctx, request.GroupID, request.Currency)
	if err != nil {
		return nil, err
	}
	if groupSavings > 0 {
		sources = append(sources, calculation.FundingSource{
			SourceID:        request.GroupID,
			SourceType:      int32(models.FundingSourceGroupSavings),
			TrancheLevel:    1,
			AvailableAmount: decimalx.FromMinorUnits(groupSavings, precision),
		})
	}

	affiliated, err := b.iaRepo.GetAffiliatedForGroup(ctx, request.GroupID, request.Currency, request.InterestRate)
	if err != nil {
		return nil, fmt.Errorf("load affiliated investors: %w", err)
	}
	sources = appendInvestorSources(
		sources, affiliated, int32(models.FundingSourceInvestorAffiliated), trancheMezzanine, nil, precision)

	general, err := b.eligibleInvestors(ctx, request, precision)
	if err != nil {
		return nil, err
	}
	excludeIDs := make(map[string]bool, len(affiliated))
	for _, inv := range affiliated {
		excludeIDs[inv.GetID()] = true
	}
	sources = appendInvestorSources(
		sources, general, int32(models.FundingSourceInvestorGeneral), trancheSenior, excludeIDs, precision)

	return sources, nil
}

// directLoanSources builds the two-tranche stack for a direct-to-client loan:
// the platform first-loss reserve, then the general investor pool.
func (b *fundingAllocationBusiness) directLoanSources(
	ctx context.Context,
	request calculation.FundingRequest,
	precision int32,
) ([]calculation.FundingSource, error) {
	var sources []calculation.FundingSource

	reserve, err := b.srcBalance.PlatformReserve(ctx, request.ProductType, request.Currency)
	if err != nil {
		return nil, err
	}
	// The reserve carries at most the configured first-loss slice of a loan,
	// bounded by what it actually holds.
	firstLossTarget := decimalx.ApplyBasisPoints(request.LoanAmount, calculation.DefaultFirstLossPercent)
	available := decimalx.FromMinorUnits(reserve, precision)
	if available.Cmp(firstLossTarget) > 0 {
		available = firstLossTarget
	}
	if available.IsPositive() {
		sources = append(sources, calculation.FundingSource{
			SourceID:        "platform",
			SourceType:      int32(models.FundingSourcePlatformReserve),
			TrancheLevel:    1,
			AvailableAmount: available,
		})
	}

	eligible, err := b.eligibleInvestors(ctx, request, precision)
	if err != nil {
		return nil, err
	}
	sources = appendInvestorSources(
		sources, eligible, int32(models.FundingSourceInvestorGeneral), trancheMezzanine, nil, precision)

	return sources, nil
}

// eligibleInvestors loads the general investor pool for a request.
func (b *fundingAllocationBusiness) eligibleInvestors(
	ctx context.Context,
	request calculation.FundingRequest,
	precision int32,
) ([]*models.InvestorAccount, error) {
	investors, err := b.iaRepo.GetEligibleForLoan(
		ctx,
		request.Currency,
		request.InterestRate,
		request.LoanAmount.ToMinorUnits(precision),
		request.ProductType,
		request.Region,
	)
	if err != nil {
		return nil, fmt.Errorf("load eligible investors: %w", err)
	}
	return investors, nil
}

// appendInvestorSources converts investor accounts into FundingSource entries,
// computing available balance and exposure headroom for each.
// Accounts in excludeIDs are skipped. TotalDeployed is passed through so the
// allocation algorithm can sort by utilization ratio for fair rotation.
func appendInvestorSources(
	sources []calculation.FundingSource,
	investors []*models.InvestorAccount,
	sourceType int32,
	trancheLevel int32,
	excludeIDs map[string]bool,
	precision int32,
) []calculation.FundingSource {
	for _, inv := range investors {
		if excludeIDs != nil && excludeIDs[inv.GetID()] {
			continue
		}
		available := inv.AvailableBalance - inv.ReservedBalance
		if available <= 0 {
			continue
		}
		maxForLoan := available
		if inv.MaxExposure > 0 {
			headroom := inv.MaxExposure - inv.ReservedBalance
			if headroom < maxForLoan {
				maxForLoan = headroom
			}
			if headroom <= 0 {
				continue // exposure limit already reached
			}
		}
		fs := calculation.FundingSource{
			SourceID:        inv.GetID(),
			SourceType:      sourceType,
			TrancheLevel:    trancheLevel,
			AvailableAmount: decimalx.FromMinorUnits(available, precision),
			MaxForThisLoan:  decimalx.FromMinorUnits(maxForLoan, precision),
			TotalDeployed:   decimalx.FromMinorUnits(inv.TotalDeployed, precision),
		}
		if inv.LastDeployedAt != nil {
			fs.LastDeployedAt = *inv.LastDeployedAt
		}
		sources = append(sources, fs)
	}
	return sources
}

// reserveInvestorBalance atomically increments the reserved balance on an
// investor account using a SQL-level guard that prevents concurrent
// over-commitment. Replaces the prior read-modify-write pattern.
func (b *fundingAllocationBusiness) reserveInvestorBalance(
	ctx context.Context,
	investorAccountID string,
	amount int64,
) error {
	_, err := b.iaRepo.AtomicReserve(ctx, investorAccountID, amount)
	if err != nil {
		return fmt.Errorf("reserve investor balance: %w", err)
	}
	return nil
}

func fundingSourceOwnerType(sourceType int32) string {
	switch models.FundingSource(sourceType) {
	case models.FundingSourceGroupSavings, models.FundingSourceGroupIncome:
		return "group"
	case models.FundingSourceInvestorAffiliated, models.FundingSourceInvestorGeneral:
		return "investor"
	case models.FundingSourcePlatformReserve:
		return "platform"
	case models.FundingSourceUnspecified:
		return "unknown"
	default:
		return "unknown"
	}
}

// ReleaseForRequest gives back the capital reserved for a loan request whose
// loan was cancelled before it was disbursed. Each active funding record is
// voided by a conditional write before its investor reservation is returned,
// so a repeated or concurrent release returns each reservation once. The
// allocation lock is then dropped, so the request could be funded afresh.
func (b *fundingAllocationBusiness) ReleaseForRequest(
	ctx context.Context,
	loanRequestID string,
) (int64, string, error) {
	logger := util.Log(ctx).WithField("method", "FundingAllocationBusiness.ReleaseForRequest").
		WithField("loan_request_id", loanRequestID)

	fundings, err := b.lfRepo.GetByLoanRequestID(ctx, loanRequestID)
	if err != nil {
		return 0, "", fmt.Errorf("load loan funding: %w", err)
	}
	released, currency, err := b.voidActiveFundings(ctx, logger, fundings)
	if err != nil {
		return released, currency, err
	}
	if releaseErr := b.claimRepo.Release(ctx, loanRequestID); releaseErr != nil {
		logger.WithError(releaseErr).Error("could not release the allocation lock")
	}
	if released > 0 {
		logger.WithField("released", released).Info("funding released for a cancelled loan")
	}
	return released, currency, nil
}

// voidActiveFundings voids each active funding record by a conditional write
// and, for each one this call voided, gives back the capital its reserved
// tranches hold and voids the tranches. A funding someone else voided first
// is skipped, so a repeated or concurrent void returns each reservation once.
// It returns the amount of funding voided and its currency.
func (b *fundingAllocationBusiness) voidActiveFundings(
	ctx context.Context,
	logger *util.LogEntry,
	fundings []*models.LoanFunding,
) (int64, string, error) {
	var released int64
	currency := ""
	for _, funding := range fundings {
		if funding.State != int32(constants.StateActive) {
			continue
		}
		won, voidErr := b.lfRepo.VoidIfActive(ctx, funding.GetID())
		if voidErr != nil {
			return released, currency, fmt.Errorf("void loan funding %s: %w", funding.GetID(), voidErr)
		}
		if !won {
			continue
		}
		currency = funding.Currency
		tranches, trErr := b.ftRepo.GetByLoanFundingID(ctx, funding.GetID())
		if trErr != nil {
			return released, currency, fmt.Errorf("load tranches of %s: %w", funding.GetID(), trErr)
		}
		var reserved []reservation
		for _, t := range tranches {
			if t.InvestorAccountID != "" && t.State == int32(constants.StateActive) {
				reserved = append(reserved, reservation{investorAccountID: t.InvestorAccountID, amount: t.Amount})
			}
		}
		b.rollbackReservations(ctx, logger, reserved)
		b.voidRecords(ctx, logger, writtenRecords{tranches: tranches})
		released += funding.Amount
	}
	return released, currency, nil
}
