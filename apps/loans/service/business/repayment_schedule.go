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
	"time"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
	"github.com/pitabwire/util/decimalx"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/calculation"
)

const (
	// decimalPrecisionRS is the number of decimal places for minor unit conversions (cents).
	decimalPrecisionRS = 2
	// daysPerWeekRS is the number of days in a weekly period.
	daysPerWeekRS = 7
	// daysPerBiweekRS is the number of days in a biweekly period.
	daysPerBiweekRS = 14
	// daysPerMonthRS is the approximate number of days in a monthly period.
	daysPerMonthRS = 30
)

type RepaymentScheduleBusiness interface {
	Generate(ctx context.Context, loanAccountID string) (*loansv1.RepaymentScheduleObject, error)
	GetActive(ctx context.Context, loanAccountID string) (*loansv1.RepaymentScheduleObject, error)
}

type repaymentScheduleBusiness struct {
	eventsMan         fevents.Manager
	loanAccountRepo   repository.LoanAccountRepository
	loanProductRepo   repository.LoanProductRepository
	scheduleRepo      repository.RepaymentScheduleRepository
	scheduleEntryRepo repository.ScheduleEntryRepository
}

func NewRepaymentScheduleBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	loanAccountRepo repository.LoanAccountRepository,
	loanProductRepo repository.LoanProductRepository,
	scheduleRepo repository.RepaymentScheduleRepository,
	scheduleEntryRepo repository.ScheduleEntryRepository,
) RepaymentScheduleBusiness {
	return &repaymentScheduleBusiness{
		eventsMan:         eventsMan,
		loanAccountRepo:   loanAccountRepo,
		loanProductRepo:   loanProductRepo,
		scheduleRepo:      scheduleRepo,
		scheduleEntryRepo: scheduleEntryRepo,
	}
}

func (b *repaymentScheduleBusiness) Generate(
	ctx context.Context,
	loanAccountID string,
) (*loansv1.RepaymentScheduleObject, error) {
	logger := util.Log(ctx).WithField("method", "RepaymentScheduleBusiness.Generate")

	la, err := b.loanAccountRepo.GetByID(ctx, loanAccountID)
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}

	// Deactivate any existing active schedule
	existingSchedule, existErr := b.scheduleRepo.GetActivByLoanAccountID(ctx, loanAccountID)
	if existErr == nil && existingSchedule != nil {
		existingSchedule.IsActive = false
		err = b.eventsMan.Emit(ctx, events.RepaymentScheduleSaveEvent, existingSchedule)
		if err != nil {
			logger.WithError(err).Warn("could not deactivate existing schedule")
		}
	}

	// Create new schedule
	now := time.Now().UTC()
	schedule := &models.RepaymentSchedule{
		LoanAccountID: loanAccountID,
		Version:       1,
		IsActive:      true,
		GeneratedAt:   &now,
	}
	if existingSchedule != nil {
		schedule.Version = existingSchedule.Version + 1
	}
	schedule.GenID(ctx)

	err = b.eventsMan.Emit(ctx, events.RepaymentScheduleSaveEvent, schedule)
	if err != nil {
		logger.WithError(err).Error("could not emit repayment schedule save event")
		return nil, err
	}

	// Generate entries using calculation package with product parameters
	entryModels, err := b.generateScheduleEntries(ctx, la, schedule)
	if err != nil {
		logger.WithError(err).Error("could not generate schedule entries")
		return nil, err
	}

	for _, entry := range entryModels {
		emitErr := b.eventsMan.Emit(ctx, events.ScheduleEntrySaveEvent, entry)
		if emitErr != nil {
			logger.WithError(emitErr).Error("could not emit schedule entry save event")
			return nil, emitErr
		}
	}

	return schedule.ToAPI(entryModels), nil
}

func (b *repaymentScheduleBusiness) GetActive(
	ctx context.Context,
	loanAccountID string,
) (*loansv1.RepaymentScheduleObject, error) {
	schedule, err := b.scheduleRepo.GetActivByLoanAccountID(ctx, loanAccountID)
	if err != nil {
		return nil, ErrScheduleNotFound
	}

	entries, err := b.scheduleEntryRepo.GetByScheduleID(ctx, schedule.GetID())
	if err != nil {
		return nil, err
	}

	return schedule.ToAPI(entries), nil
}

// generateScheduleEntries creates installments using the calculation package
// with fee and insurance parameters from the loan product.
func (b *repaymentScheduleBusiness) generateScheduleEntries(
	ctx context.Context,
	la *models.LoanAccount,
	schedule *models.RepaymentSchedule,
) ([]*models.ScheduleEntry, error) {
	// Load loan product for fee rates
	lp, err := b.loanProductRepo.GetByID(ctx, la.ProductID)
	if err != nil {
		return nil, fmt.Errorf("could not load loan product: %w", err)
	}

	// Determine installment count from term and frequency
	numInstallments := computeInstallmentCount(la.TermDays, loansv1.RepaymentFrequency(la.RepaymentFrequency))
	if numInstallments <= 0 {
		numInstallments = 1
	}

	// Use interest rate from loan account (may override product)
	interestRate := la.InterestRate
	if interestRate == 0 {
		interestRate = lp.AnnualInterestRate
	}

	// Calculate first due date
	var firstDueDate time.Time
	switch {
	case la.FirstRepaymentDate != nil:
		firstDueDate = *la.FirstRepaymentDate
	case la.DisbursedAt != nil:
		firstDueDate = advanceByFrequency(*la.DisbursedAt, loansv1.RepaymentFrequency(la.RepaymentFrequency), 1)
	default:
		return nil, errors.New("cannot generate schedule: loan has no disbursement date or first repayment date")
	}

	// Map repayment frequency to period type used by calculation package
	periodType := frequencyToPeriodType(loansv1.RepaymentFrequency(la.RepaymentFrequency))

	// Determine interest method: use loan account override, fall back to product
	interestMethod := la.InterestMethod
	if interestMethod == 0 {
		interestMethod = lp.InterestMethod
	}

	// Generate schedule using product parameters
	principal := decimalx.FromMinorUnits(la.PrincipalAmount, decimalPrecisionRS)
	entries := calculation.GenerateScheduleFromProduct(
		principal,
		interestRate,
		lp.InsuranceFeePercent,
		lp.ProcessingFeePercent,
		interestMethod,
		numInstallments,
		firstDueDate,
		periodType,
	)

	// Convert calculation entries to model entries
	var modelEntries []*models.ScheduleEntry
	for _, e := range entries {
		feesDue := e.FeesDue.Add(e.InsuranceDue).ToMinorUnits(decimalPrecisionRS) // combine into fees
		principalDue := e.PrincipalDue.ToMinorUnits(decimalPrecisionRS)
		interestDue := e.InterestDue.ToMinorUnits(decimalPrecisionRS)
		totalDue := principalDue + interestDue + feesDue
		entry := &models.ScheduleEntry{
			ScheduleID:        schedule.GetID(),
			LoanAccountID:     la.GetID(),
			InstallmentNumber: e.InstallmentNumber,
			DueDate:           &e.DueDate,
			PrincipalDue:      principalDue,
			InterestDue:       interestDue,
			FeesDue:           feesDue,
			TotalDue:          totalDue,
			Outstanding:       totalDue,
			CurrencyCode:      la.CurrencyCode,
			Status:            int32(loansv1.ScheduleEntryStatus_SCHEDULE_ENTRY_STATUS_UPCOMING),
		}
		entry.GenID(ctx)
		modelEntries = append(modelEntries, entry)
	}

	// Validate schedule invariant: sum of principal must equal loan principal
	if invariantErr := validateScheduleInvariant(modelEntries, la); invariantErr != nil {
		return nil, fmt.Errorf("schedule invariant violation: %w", invariantErr)
	}

	return modelEntries, nil
}

// validateScheduleInvariant verifies that the sum of all schedule entry
// principal amounts equals the loan principal. A tolerance of 1 minor unit
// is allowed to accommodate rounding dust from the last-entry remainder.
func validateScheduleInvariant(entries []*models.ScheduleEntry, la *models.LoanAccount) error {
	var sumPrincipal int64
	for _, e := range entries {
		sumPrincipal += e.PrincipalDue
	}

	const tolerance int64 = 1 // at most 1 minor unit (e.g. 1 cent) of rounding
	diff := sumPrincipal - la.PrincipalAmount
	if diff < 0 {
		diff = -diff
	}

	if diff > tolerance {
		return fmt.Errorf(
			"sum of schedule principal (%d) differs from loan principal (%d) by %d, exceeding tolerance of %d",
			sumPrincipal, la.PrincipalAmount, diff, tolerance,
		)
	}
	return nil
}

const (
	periodTypeWeeklyRS   = 1
	periodTypeBiweeklyRS = 2
	periodTypeMonthlyRS  = 3
)

// frequencyToPeriodType maps RepaymentFrequency enum to the period type int
// used by the calculation package (1=WEEKLY, 2=BIWEEKLY, 3=MONTHLY).
func frequencyToPeriodType(freq loansv1.RepaymentFrequency) int32 {
	switch freq { //nolint:exhaustive // unspecified and unsupported frequencies default to monthly
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_WEEKLY:
		return periodTypeWeeklyRS
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_BIWEEKLY:
		return periodTypeBiweeklyRS
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_MONTHLY:
		return periodTypeMonthlyRS
	default:
		return periodTypeMonthlyRS
	}
}

func computeInstallmentCount(termDays int32, freq loansv1.RepaymentFrequency) int32 {
	switch freq { //nolint:exhaustive // unspecified and quarterly fall through to default
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_DAILY:
		return termDays
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_WEEKLY:
		return termDays / daysPerWeekRS
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_BIWEEKLY:
		return termDays / daysPerBiweekRS
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_MONTHLY:
		return termDays / daysPerMonthRS
	default:
		return 1
	}
}

func advanceByFrequency(start time.Time, freq loansv1.RepaymentFrequency, periods int) time.Time {
	switch freq { //nolint:exhaustive // unspecified and quarterly fall through to default
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_DAILY:
		return start.AddDate(0, 0, periods)
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_WEEKLY:
		return start.AddDate(0, 0, periods*daysPerWeekRS)
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_BIWEEKLY:
		return start.AddDate(0, 0, periods*daysPerBiweekRS)
	case loansv1.RepaymentFrequency_REPAYMENT_FREQUENCY_MONTHLY:
		return start.AddDate(0, periods, 0)
	default:
		return start.AddDate(0, 0, periods*daysPerMonthRS)
	}
}
