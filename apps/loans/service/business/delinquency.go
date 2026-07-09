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

	"strconv"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

const (
	delinquencyBatchSize      = 500
	hoursPerDay               = 24
	basisPointsPenaltyDivisor = 10000
)

// DelinquencyScanner detects overdue loans and transitions them to DELINQUENT
// or DEFAULT status based on configured thresholds. It also applies late
// penalties for overdue schedule entries.
//
// This should be called periodically by a scheduled job (e.g., daily cronjob).
type DelinquencyScanner struct {
	loanAccountRepo repository.LoanAccountRepository
	loanBalanceRepo repository.LoanBalanceRepository
	scheduleRepo    repository.ScheduleEntryRepository
	penaltyBusiness PenaltyBusiness
	laBusiness      LoanAccountBusiness
	loanProductRepo repository.LoanProductRepository

	delinquencyDays int // days past due to mark delinquent (default 7)
	defaultDays     int // days past due to mark default (default 90)
}

func NewDelinquencyScanner(
	loanAccountRepo repository.LoanAccountRepository,
	loanBalanceRepo repository.LoanBalanceRepository,
	scheduleRepo repository.ScheduleEntryRepository,
	penaltyBusiness PenaltyBusiness,
	laBusiness LoanAccountBusiness,
	loanProductRepo repository.LoanProductRepository,
	delinquencyDays, defaultDays int,
) *DelinquencyScanner {
	if delinquencyDays <= 0 {
		delinquencyDays = 7
	}
	if defaultDays <= 0 {
		defaultDays = 90
	}
	return &DelinquencyScanner{
		loanAccountRepo: loanAccountRepo,
		loanBalanceRepo: loanBalanceRepo,
		scheduleRepo:    scheduleRepo,
		penaltyBusiness: penaltyBusiness,
		laBusiness:      laBusiness,
		loanProductRepo: loanProductRepo,
		delinquencyDays: delinquencyDays,
		defaultDays:     defaultDays,
	}
}

// ScanAndTransition scans all active and delinquent loans for overdue
// schedule entries and transitions their status accordingly.
// Returns the number of loans processed and any error.
//
//nolint:gocognit // sequential scan logic
func (s *DelinquencyScanner) ScanAndTransition(
	ctx context.Context,
) (int, error) {
	logger := util.Log(ctx).WithField("method", "DelinquencyScanner.ScanAndTransition")
	now := time.Now()
	processed := 0

	// Scan active loans for delinquency
	activeLoansCh, err := s.loanAccountRepo.Search(ctx,
		data.NewSearchQuery(
			data.WithSearchFiltersAndByValue(map[string]any{
				"status = ?": int32(loansv1.LoanStatus_LOAN_STATUS_ACTIVE),
			}),
			data.WithSearchLimit(delinquencyBatchSize),
		),
	)
	if err != nil {
		logger.WithError(err).Error("failed to search active loans")
		return 0, err
	}

	_ = workerpoolConsumeStream(ctx, activeLoansCh, func(batch []*models.LoanAccount) error {
		for _, la := range batch {
			daysPastDue := s.computeDaysPastDue(ctx, la, now)
			if daysPastDue >= s.delinquencyDays {
				if _, transErr := s.laBusiness.TransitionStatus(
					ctx, la.GetID(),
					loansv1.LoanStatus_LOAN_STATUS_DELINQUENT,
					"system", "auto-delinquency: overdue by "+strconv.Itoa(daysPastDue)+" days",
				); transErr != nil {
					logger.WithError(transErr).WithField("loan_id", la.GetID()).
						Warn("could not transition loan to delinquent")
				} else {
					processed++
				}
			}
			s.applyLatePenalties(ctx, logger, la, now)
		}
		return nil
	})

	// Scan delinquent loans for default
	delinquentLoansCh, err := s.loanAccountRepo.Search(ctx,
		data.NewSearchQuery(
			data.WithSearchFiltersAndByValue(map[string]any{
				"status = ?": int32(loansv1.LoanStatus_LOAN_STATUS_DELINQUENT),
			}),
			data.WithSearchLimit(delinquencyBatchSize),
		),
	)
	if err != nil {
		logger.WithError(err).Error("failed to search delinquent loans")
		return processed, err
	}

	_ = workerpoolConsumeStream(ctx, delinquentLoansCh, func(batch []*models.LoanAccount) error {
		for _, la := range batch {
			daysPastDue := s.computeDaysPastDue(ctx, la, now)
			if daysPastDue >= s.defaultDays {
				if _, transErr := s.laBusiness.TransitionStatus(
					ctx, la.GetID(),
					loansv1.LoanStatus_LOAN_STATUS_DEFAULT,
					"system", "auto-default: overdue by "+strconv.Itoa(daysPastDue)+" days",
				); transErr != nil {
					logger.WithError(transErr).WithField("loan_id", la.GetID()).
						Warn("could not transition loan to default")
				} else {
					processed++
				}
			}
		}
		return nil
	})

	logger.WithField("processed", processed).Info("delinquency scan completed")
	return processed, nil
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
	// Earliest overdue entry determines days past due
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

// applyLatePenalties applies late penalty for each overdue schedule entry
// that hasn't already been penalized.
func (s *DelinquencyScanner) applyLatePenalties(
	ctx context.Context,
	logger *util.LogEntry,
	la *models.LoanAccount,
	now time.Time,
) {
	product, err := s.loanProductRepo.GetByID(ctx, la.ProductID)
	if err != nil || product == nil || product.LatePenaltyRate <= 0 {
		return // No penalty rate configured
	}

	entries, err := s.scheduleRepo.GetOverdueEntries(ctx, la.GetID(), now)
	if err != nil {
		return
	}

	for _, entry := range entries {
		// Skip if already penalized (check properties)
		if entry.Properties != nil {
			if _, penalized := entry.Properties["penalty_applied"]; penalized {
				continue
			}
		}

		// Calculate penalty: late_penalty_rate (basis points) × outstanding amount
		penaltyAmount := (entry.Outstanding * product.LatePenaltyRate) / basisPointsPenaltyDivisor
		if penaltyAmount <= 0 {
			continue
		}

		_, penErr := s.penaltyBusiness.Save(ctx, &loansv1.PenaltyObject{
			LoanAccountId: la.GetID(),
			Amount:        models.MinorUnitsToMoney(penaltyAmount, la.CurrencyCode),
			Reason:        "Late payment penalty for installment " + entry.GetID(),
		})
		if penErr != nil {
			logger.WithError(penErr).WithField("entry_id", entry.GetID()).
				Warn("could not apply late penalty")
			continue
		}

		// Mark entry as penalized
		if entry.Properties == nil {
			entry.Properties = data.JSONMap{}
		}
		entry.Properties["penalty_applied"] = true
	}
}
