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
	"time"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/calculation"
)

const (
	// daysPerWeekRS is the number of days in a weekly period.
	daysPerWeekRS = 7
	// daysPerBiweekRS is the number of days in a biweekly period.
	daysPerBiweekRS = 14
	// daysPerMonthRS is the approximate number of days in a monthly period.
	daysPerMonthRS = 30
)

// ScheduleResult carries the freshly generated schedule alongside its
// entries, so callers that have to derive further state from the schedule
// (the opening loan balance, for instance) can read it in memory instead of
// racing the asynchronous persistence of the entries.
type ScheduleResult struct {
	Schedule *models.RepaymentSchedule
	Entries  []*models.ScheduleEntry
}

// API renders the result as the proto schedule object.
func (r *ScheduleResult) API() *loansv1.RepaymentScheduleObject {
	return r.Schedule.ToAPI(r.Entries)
}

// TotalInterest returns the interest the schedule expects to collect.
func (r *ScheduleResult) TotalInterest() int64 {
	var total int64
	for _, e := range r.Entries {
		total += e.InterestDue
	}
	return total
}

// TotalFees returns the fees (insurance plus processing) the schedule expects
// to collect.
func (r *ScheduleResult) TotalFees() int64 {
	var total int64
	for _, e := range r.Entries {
		total += e.FeesDue
	}
	return total
}

type RepaymentScheduleBusiness interface {
	Generate(ctx context.Context, loanAccountID string) (*loansv1.RepaymentScheduleObject, error)
	// GenerateFor builds a schedule for a loan account already held in
	// memory, amortising principalMinor rather than the account's original
	// principal. Restructures pass the outstanding principal; new loans pass
	// the full principal.
	GenerateFor(
		ctx context.Context,
		la *models.LoanAccount,
		principalMinor int64,
	) (*ScheduleResult, error)
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
	la, err := b.loanAccountRepo.GetByID(ctx, loanAccountID)
	if err != nil {
		return nil, ErrLoanAccountNotFound
	}

	result, err := b.GenerateFor(ctx, la, la.PrincipalAmount)
	if err != nil {
		return nil, err
	}
	return result.API(), nil
}

func (b *repaymentScheduleBusiness) GenerateFor(
	ctx context.Context,
	la *models.LoanAccount,
	principalMinor int64,
) (*ScheduleResult, error) {
	logger := util.Log(ctx).WithField("method", "RepaymentScheduleBusiness.GenerateFor")

	if la == nil {
		return nil, ErrLoanAccountNotFound
	}
	if principalMinor <= 0 {
		return nil, apperrors.NewError(apperrors.Unprocessable,
			"cannot generate a repayment schedule for a non-positive principal")
	}

	now := time.Now().UTC()
	schedule := &models.RepaymentSchedule{
		LoanAccountID: la.GetID(),
		Version:       1,
		IsActive:      true,
		GeneratedAt:   &now,
	}

	existingSchedule, existErr := b.scheduleRepo.GetActivByLoanAccountID(ctx, la.GetID())
	if existErr == nil && existingSchedule != nil {
		schedule.Version = existingSchedule.Version + 1
	}
	schedule.GenID(ctx)

	entryModels, err := b.generateScheduleEntries(ctx, la, schedule, principalMinor)
	if err != nil {
		return nil, err
	}

	// The schedule and its entries are only published once the entries have
	// been built and validated, so a rejected schedule never leaves a
	// half-written version behind.
	if existingSchedule != nil {
		existingSchedule.IsActive = false
		if deactivateErr := b.eventsMan.Emit(
			ctx, events.RepaymentScheduleSaveEvent, existingSchedule,
		); deactivateErr != nil {
			logger.WithError(deactivateErr).Error("could not deactivate existing schedule")
			return nil, deactivateErr
		}
	}

	if err = b.eventsMan.Emit(ctx, events.RepaymentScheduleSaveEvent, schedule); err != nil {
		logger.WithError(err).Error("could not emit repayment schedule save event")
		return nil, err
	}

	for _, entry := range entryModels {
		if emitErr := b.eventsMan.Emit(ctx, events.ScheduleEntrySaveEvent, entry); emitErr != nil {
			logger.WithError(emitErr).Error("could not emit schedule entry save event")
			return nil, emitErr
		}
	}

	return &ScheduleResult{Schedule: schedule, Entries: entryModels}, nil
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
	principalMinor int64,
) ([]*models.ScheduleEntry, error) {
	lp, err := b.loanProductRepo.GetByID(ctx, la.ProductID)
	if err != nil {
		return nil, ErrLoanProductNotFound
	}

	numInstallments := computeInstallmentCount(la.TermDays, loansv1.RepaymentFrequency(la.RepaymentFrequency))
	if numInstallments <= 0 {
		numInstallments = 1
	}

	interestRate := la.InterestRate
	if interestRate == 0 {
		interestRate = lp.AnnualInterestRate
	}

	firstDueDate, dueErr := scheduleFirstDueDate(la)
	if dueErr != nil {
		return nil, dueErr
	}

	interestMethod := la.InterestMethod
	if interestMethod == 0 {
		interestMethod = lp.InterestMethod
	}

	decimals := moneyx.Decimals(la.CurrencyCode)
	entries := calculation.GenerateMinorScheduleFromProduct(
		principalMinor,
		interestRate,
		lp.InsuranceFeePercent,
		lp.ProcessingFeePercent,
		interestMethod,
		numInstallments,
		firstDueDate,
		frequencyToPeriodType(loansv1.RepaymentFrequency(la.RepaymentFrequency)),
		decimals,
	)

	modelEntries := make([]*models.ScheduleEntry, 0, len(entries))
	for _, e := range entries {
		dueDate := e.DueDate
		feesDue := e.FeesDue + e.InsuranceDue
		totalDue := e.PrincipalDue + e.InterestDue + feesDue
		entry := &models.ScheduleEntry{
			ScheduleID:        schedule.GetID(),
			LoanAccountID:     la.GetID(),
			InstallmentNumber: e.InstallmentNumber,
			DueDate:           &dueDate,
			PrincipalDue:      e.PrincipalDue,
			InterestDue:       e.InterestDue,
			FeesDue:           feesDue,
			TotalDue:          totalDue,
			Outstanding:       totalDue,
			CurrencyCode:      la.CurrencyCode,
			Status:            int32(loansv1.ScheduleEntryStatus_SCHEDULE_ENTRY_STATUS_UPCOMING),
		}
		entry.GenID(ctx)
		modelEntries = append(modelEntries, entry)
	}

	if invariantErr := validateScheduleInvariant(modelEntries, principalMinor); invariantErr != nil {
		return nil, invariantErr
	}

	return modelEntries, nil
}

// scheduleFirstDueDate resolves when the first installment falls due.
func scheduleFirstDueDate(la *models.LoanAccount) (time.Time, error) {
	switch {
	case la.FirstRepaymentDate != nil:
		return *la.FirstRepaymentDate, nil
	case la.DisbursedAt != nil:
		return advanceByFrequency(
			*la.DisbursedAt,
			loansv1.RepaymentFrequency(la.RepaymentFrequency),
			1,
		), nil
	default:
		return time.Time{}, apperrors.NewError(apperrors.Unprocessable,
			"cannot generate a repayment schedule: the loan has no disbursement date "+
				"and no first repayment date")
	}
}

// validateScheduleInvariant verifies that the installments amortise exactly
// the principal they were generated from. The generator distributes in minor
// units, so any difference at all means the schedule is wrong, not rounded.
func validateScheduleInvariant(entries []*models.ScheduleEntry, principalMinor int64) error {
	var sumPrincipal int64
	for _, e := range entries {
		sumPrincipal += e.PrincipalDue
	}

	if sumPrincipal != principalMinor {
		return apperrors.NewError(apperrors.Unprocessable,
			"generated repayment schedule does not amortise the loan principal")
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
