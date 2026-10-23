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
	"math"
	"strconv"
	"time"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

const (
	// delinquencyPageSize bounds how many loans one page of the scan holds.
	delinquencyPageSize = 200
	// delinquencyMaxPages bounds a single scan so a runaway portfolio cannot
	// keep one pass running indefinitely; the next tick resumes the work.
	delinquencyMaxPages       = 500
	hoursPerDay               = 24
	basisPointsPenaltyDivisor = 10000
	defaultDelinquencyDays    = 7
	defaultDefaultDays        = 90
)

// DelinquencyScanner detects overdue loans and transitions them to DELINQUENT
// or DEFAULT status based on configured thresholds. It also applies late
// penalties for overdue schedule entries and keeps days_past_due current, which
// is what portfolio-at-risk reporting reads.
//
// Run it from a scheduled job; it is safe to run concurrently with normal
// traffic because every write it makes is conditional.
type DelinquencyScanner struct {
	loanAccountRepo repository.LoanAccountRepository
	scheduleRepo    repository.ScheduleEntryRepository
	penaltyBusiness PenaltyBusiness
	laBusiness      LoanAccountBusiness
	loanProductRepo repository.LoanProductRepository

	delinquencyDays int // days past due to mark delinquent (default 7)
	defaultDays     int // days past due to mark default (default 90)
}

func NewDelinquencyScanner(
	loanAccountRepo repository.LoanAccountRepository,
	scheduleRepo repository.ScheduleEntryRepository,
	penaltyBusiness PenaltyBusiness,
	laBusiness LoanAccountBusiness,
	loanProductRepo repository.LoanProductRepository,
	delinquencyDays, defaultDays int,
) *DelinquencyScanner {
	if delinquencyDays <= 0 {
		delinquencyDays = defaultDelinquencyDays
	}
	if defaultDays <= 0 {
		defaultDays = defaultDefaultDays
	}
	return &DelinquencyScanner{
		loanAccountRepo: loanAccountRepo,
		scheduleRepo:    scheduleRepo,
		penaltyBusiness: penaltyBusiness,
		laBusiness:      laBusiness,
		loanProductRepo: loanProductRepo,
		delinquencyDays: delinquencyDays,
		defaultDays:     defaultDays,
	}
}

// Run adapts ScanAndTransition to the signature a scheduled job expects.
func (s *DelinquencyScanner) Run(ctx context.Context) error {
	_, err := s.ScanAndTransition(ctx)
	return err
}

// ScanAndTransition pages through active and delinquent loans, records how
// overdue each one is, charges late penalties for installments that have not
// been penalised yet, and moves loans across the delinquency thresholds.
// Returns the number of loans whose status changed.
func (s *DelinquencyScanner) ScanAndTransition(ctx context.Context) (int, error) {
	logger := util.Log(ctx).WithField("method", "DelinquencyScanner.ScanAndTransition")
	now := time.Now().UTC()
	transitioned := 0

	active, err := s.scanStatus(ctx, logger, now,
		loansv1.LoanStatus_LOAN_STATUS_ACTIVE,
		loansv1.LoanStatus_LOAN_STATUS_DELINQUENT,
		s.delinquencyDays, true)
	transitioned += active
	if err != nil {
		return transitioned, err
	}

	delinquent, err := s.scanStatus(ctx, logger, now,
		loansv1.LoanStatus_LOAN_STATUS_DELINQUENT,
		loansv1.LoanStatus_LOAN_STATUS_DEFAULT,
		s.defaultDays, false)
	transitioned += delinquent
	if err != nil {
		return transitioned, err
	}

	logger.WithField("transitioned", transitioned).Info("delinquency scan completed")
	return transitioned, nil
}

// scanStatus walks every loan in fromStatus one page at a time. Paging matters:
// a single capped query silently ignores everything past the cap, which for a
// delinquency scan means loans that quietly never default.
func (s *DelinquencyScanner) scanStatus(
	ctx context.Context,
	logger *util.LogEntry,
	now time.Time,
	fromStatus, toStatus loansv1.LoanStatus,
	thresholdDays int,
	applyPenalties bool,
) (int, error) {
	transitioned := 0
	afterID := ""

	for range delinquencyMaxPages {
		batch, err := s.loanAccountRepo.PageByStatus(
			ctx, int32(fromStatus), afterID, delinquencyPageSize,
		)
		if err != nil {
			logger.WithError(err).WithField("status", fromStatus.String()).
				Error("could not page loans for the delinquency scan")
			return transitioned, err
		}
		if len(batch) == 0 {
			return transitioned, nil
		}

		afterID = batch[len(batch)-1].GetID()

		for _, la := range batch {
			daysPastDue := s.computeDaysPastDue(ctx, la, now)
			s.recordDaysPastDue(ctx, logger, la, daysPastDue)

			if applyPenalties {
				s.applyLatePenalties(ctx, logger, la, now)
			}

			if daysPastDue < thresholdDays {
				continue
			}
			if _, transErr := s.laBusiness.TransitionStatus(
				ctx, la.GetID(), toStatus, "system",
				"overdue by "+strconv.Itoa(daysPastDue)+" days",
			); transErr != nil {
				logger.WithError(transErr).WithField("loan_id", la.GetID()).
					Warn("could not transition loan on the delinquency scan")
				continue
			}
			transitioned++
		}

		if len(batch) < delinquencyPageSize {
			return transitioned, nil
		}
	}

	return transitioned, nil
}

// recordDaysPastDue persists how overdue a loan is. Portfolio-at-risk is
// computed from this column, so leaving it at zero reports a clean book.
func (s *DelinquencyScanner) recordDaysPastDue(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	daysPastDue int,
) {
	days := clampToInt32(daysPastDue)
	if days == la.DaysPastDue {
		return
	}
	if _, err := s.loanAccountRepo.UpdateColumns(ctx, la.GetID(), map[string]any{
		"days_past_due": days,
	}); err != nil {
		logger.WithError(err).WithField("loan_id", la.GetID()).
			Warn("could not record days past due")
	}
}

// computeDaysPastDue returns the number of days since the earliest unpaid
// schedule entry's due date.
func (s *DelinquencyScanner) computeDaysPastDue(
	ctx context.Context,
	la *models.LoanAccount,
	now time.Time,
) int {
	entries, err := s.scheduleRepo.GetOverdueEntries(ctx, la.GetID(), now)
	if err != nil || len(entries) == 0 {
		return 0
	}
	earliest := entries[0]
	if earliest.DueDate == nil {
		return 0
	}
	days := int(now.Sub(*earliest.DueDate).Hours() / hoursPerDay)
	if days < 0 {
		return 0
	}
	return days
}

// applyLatePenalties charges one late penalty per overdue installment.
//
// The mark is claimed in the database before the penalty is raised, so a scan
// that runs every day does not charge the same installment every day.
func (s *DelinquencyScanner) applyLatePenalties(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	now time.Time,
) {
	product, err := s.loanProductRepo.GetByID(ctx, la.ProductID)
	if err != nil || product == nil || product.LatePenaltyRate <= 0 {
		return
	}

	entries, err := s.scheduleRepo.GetOverdueEntries(ctx, la.GetID(), now)
	if err != nil {
		return
	}

	for _, entry := range entries {
		if alreadyPenalised(entry) {
			continue
		}

		penaltyAmount := (entry.Outstanding * product.LatePenaltyRate) / basisPointsPenaltyDivisor
		if penaltyAmount <= 0 {
			continue
		}

		claimed, claimErr := s.scheduleRepo.MarkPenaltyApplied(ctx, entry.GetID())
		if claimErr != nil {
			logger.WithError(claimErr).WithField("entry_id", entry.GetID()).
				Warn("could not claim the late penalty for an installment")
			continue
		}
		if !claimed {
			continue
		}

		_, penErr := s.penaltyBusiness.Save(ctx, &loansv1.PenaltyObject{
			LoanAccountId:   la.GetID(),
			PenaltyType:     loansv1.PenaltyType_PENALTY_TYPE_LATE_PAYMENT,
			Amount:          models.MinorUnitsToMoney(penaltyAmount, la.CurrencyCode),
			Reason:          "late payment penalty for installment " + strconv.Itoa(int(entry.InstallmentNumber)),
			ScheduleEntryId: entry.GetID(),
		})
		if penErr != nil {
			logger.WithError(penErr).WithField("entry_id", entry.GetID()).
				Warn("could not apply late penalty")
		}
	}
}

// alreadyPenalised reads the mark this scanner writes onto an installment.
func alreadyPenalised(entry *models.ScheduleEntry) bool {
	if entry.Properties == nil {
		return false
	}
	applied, _ := entry.Properties["penalty_applied"].(bool)
	return applied
}

// clampToInt32 narrows a day count to the column's width without wrapping.
func clampToInt32(v int) int32 {
	switch {
	case v > math.MaxInt32:
		return math.MaxInt32
	case v < 0:
		return 0
	default:
		return int32(v)
	}
}
