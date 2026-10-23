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
	"strings"
	"time"

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/util"
	"github.com/pitabwire/util/decimalx"
	"github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/operations/service/events"
	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/calculation"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// propertyOriginalAmount records what an obligation was worth when it was
// raised. Allocation consumes the Amount column in place, so settlement can
// only be derived by comparing what is left against this.
const propertyOriginalAmount = "original_amount"

// penaltyCausePrefix scopes a penalty obligation's cause id to the obligation
// it punishes, which is what makes penalty creation idempotent.
const penaltyCausePrefix = "penalty:"

// originalAmount reports what an obligation started at, falling back to its
// current amount for rows raised before the field existed.
func originalAmount(obl *models.Obligation) int64 {
	if obl.Properties != nil {
		if raw, ok := obl.Properties[propertyOriginalAmount]; ok {
			switch typed := raw.(type) {
			case float64:
				return int64(typed)
			case int64:
				return typed
			}
		}
	}
	return obl.Amount
}

// outstandingAmount is what a member still owes on an obligation.
func outstandingAmount(obl *models.Obligation) int64 {
	if obl.State != int32(constants.StateActive) || obl.Amount <= 0 {
		return 0
	}
	return obl.Amount
}

// ReconcilePeriod summarises what each member actually settled in a period. It
// is the read the period-close workflow sends members as their statement, and
// the input to the penalty run.
func (b *obligationBusiness) ReconcilePeriod(
	ctx context.Context,
	periodID string,
) (map[string]interface{}, error) {
	periodID = strings.TrimSpace(periodID)
	if periodID == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "a period id is required")
	}

	obligations, err := b.obRepo.GetByPeriodID(ctx, periodID)
	if err != nil {
		return nil, err
	}

	type memberTotals struct {
		savingsTotal int64
		penalties    int64
		outstanding  int64
	}

	order := make([]string, 0, len(obligations))
	byMember := map[string]*memberTotals{}
	for _, obl := range obligations {
		entry, seen := byMember[obl.MembershipID]
		if !seen {
			entry = &memberTotals{}
			byMember[obl.MembershipID] = entry
			order = append(order, obl.MembershipID)
		}

		settled := originalAmount(obl) - outstandingAmount(obl)
		switch obl.CauseType {
		case obligationPeriodicSaving, obligationSaving:
			entry.savingsTotal += settled
		case obligationPenalty:
			entry.penalties += outstandingAmount(obl)
		}
		entry.outstanding += outstandingAmount(obl)
	}

	members := make([]map[string]interface{}, 0, len(order))
	var totalOutstanding int64
	for _, memberID := range order {
		entry := byMember[memberID]
		totalOutstanding += entry.outstanding
		members = append(members, map[string]interface{}{
			"id":              memberID,
			fieldMemberID:     memberID,
			fieldMembershipID: memberID,
			"savings_total":   entry.savingsTotal,
			"penalties":       entry.penalties,
			"outstanding":     entry.outstanding,
		})
	}

	return map[string]interface{}{
		fieldPeriodID:         periodID,
		"members":             members,
		"count":               len(members),
		fieldTotalOutstanding: totalOutstanding,
	}, nil
}

// OutstandingForPeriod lists the members who still owe money in a period. The
// savings reminder workflow drives its escalating reminders off this.
func (b *obligationBusiness) OutstandingForPeriod(
	ctx context.Context,
	periodID string,
) (map[string]interface{}, error) {
	periodID = strings.TrimSpace(periodID)
	if periodID == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "a period id is required")
	}

	obligations, err := b.obRepo.GetByPeriodID(ctx, periodID)
	if err != nil {
		return nil, err
	}

	type memberOutstanding struct {
		amount int64
		due    *time.Time
	}

	order := make([]string, 0, len(obligations))
	byMember := map[string]*memberOutstanding{}
	var totalOutstanding int64

	for _, obl := range obligations {
		owed := outstandingAmount(obl)
		if owed == 0 {
			continue
		}
		entry, seen := byMember[obl.MembershipID]
		if !seen {
			entry = &memberOutstanding{}
			byMember[obl.MembershipID] = entry
			order = append(order, obl.MembershipID)
		}
		entry.amount += owed
		totalOutstanding += owed
		if obl.Deadline != nil && (entry.due == nil || obl.Deadline.Before(*entry.due)) {
			entry.due = obl.Deadline
		}
	}

	members := make([]map[string]interface{}, 0, len(order))
	for _, memberID := range order {
		entry := byMember[memberID]
		members = append(members, map[string]interface{}{
			"id":                 memberID,
			fieldMemberID:        memberID,
			fieldMembershipID:    memberID,
			"amount_outstanding": entry.amount,
			fieldDueDate:         formatDeadline(entry.due),
		})
	}

	return map[string]interface{}{
		fieldPeriodID:         periodID,
		"members":             members,
		"count":               len(members),
		fieldTotalOutstanding: totalOutstanding,
	}, nil
}

// CheckForMember reports whether a member has settled everything owed. The
// payment routing workflow uses it to decide whether to congratulate the payer.
func (b *obligationBusiness) CheckForMember(
	ctx context.Context,
	membershipID string,
) (map[string]interface{}, error) {
	membershipID = strings.TrimSpace(membershipID)
	if membershipID == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "a member id is required")
	}

	obligations, err := b.obRepo.GetByMembershipID(ctx, membershipID)
	if err != nil {
		return nil, err
	}

	var total int64
	outstandingCount := 0
	var nextDue *time.Time
	for _, obl := range obligations {
		owed := outstandingAmount(obl)
		if owed == 0 {
			continue
		}
		total += owed
		outstandingCount++
		if obl.Deadline != nil && (nextDue == nil || obl.Deadline.Before(*nextDue)) {
			nextDue = obl.Deadline
		}
	}

	return map[string]interface{}{
		fieldMemberID:         membershipID,
		fieldMembershipID:     membershipID,
		"all_met":             outstandingCount == 0,
		"outstanding_count":   outstandingCount,
		fieldTotalOutstanding: total,
		fieldDueDate:          formatDeadline(nextDue),
	}, nil
}

// CalculatePenaltiesForPeriod raises a penalty obligation for every overdue
// obligation left in a period. The fine escalates with how many deadlines the
// member has already missed, following the product's fine ladder.
//
// It is idempotent: a penalty's cause id is derived from the obligation it
// punishes, so a re-run finds the existing row and skips it.
func (b *obligationBusiness) CalculatePenaltiesForPeriod(
	ctx context.Context,
	periodID string,
) (map[string]interface{}, error) {
	logger := util.Log(ctx).WithField("method", "ObligationBusiness.CalculatePenaltiesForPeriod").
		WithField(fieldPeriodID, periodID)

	periodID = strings.TrimSpace(periodID)
	if periodID == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "a period id is required")
	}

	obligations, err := b.obRepo.GetByPeriodID(ctx, periodID)
	if err != nil {
		return nil, err
	}

	fineRates := calculation.DefaultFineRates()
	now := time.Now().UTC()

	created := 0
	var totalPenalty int64

	for _, obl := range obligations {
		penaltyObl := b.buildPenalty(ctx, obl, periodID, now, fineRates)
		if penaltyObl == nil {
			continue
		}
		if emitErr := b.eventsMan.Emit(ctx, events.ObligationSaveEvent, penaltyObl); emitErr != nil {
			logger.WithError(emitErr).WithField("obligation_id", obl.GetID()).
				Error("could not raise penalty obligation")
			continue
		}
		created++
		totalPenalty += penaltyObl.Amount
	}

	logger.WithField("penalties_created", created).Info("penalty calculation completed")

	return map[string]interface{}{
		fieldPeriodID:         periodID,
		"penalties_created":   created,
		"total_penalty":       totalPenalty,
		"obligations_scanned": len(obligations),
	}, nil
}

// buildPenalty prices the penalty owed on one overdue obligation, or returns
// nil when the obligation is current, already settled, already penalised, or
// too small to attract a fine.
func (b *obligationBusiness) buildPenalty(
	ctx context.Context,
	obl *models.Obligation,
	periodID string,
	now time.Time,
	fineRates []int64,
) *models.Obligation {
	owed := outstandingAmount(obl)
	if owed == 0 || obl.CauseType == obligationPenalty {
		return nil
	}
	if obl.Deadline == nil || !now.After(*obl.Deadline) {
		return nil
	}

	causeID := penaltyCausePrefix + obl.GetID()
	existing, lookupErr := b.obRepo.GetByCauseID(ctx, causeID)
	if lookupErr == nil && len(existing) > 0 {
		return nil
	}

	decimals := moneyx.Decimals(obl.Currency)
	penalty := calculation.EscalatingPenalty(
		decimalx.FromMinorUnits(owed, decimals),
		periodsLate(now, *obl.Deadline),
		fineRates,
	).ToMinorUnits(decimals)
	if penalty <= 0 {
		return nil
	}

	properties := data.JSONMap{propertyOriginalAmount: penalty}
	if obl.Properties != nil {
		if groupID, ok := obl.Properties[fieldGroupID]; ok {
			properties[fieldGroupID] = groupID
		}
	}

	penaltyObl := &models.Obligation{
		MembershipID:   obl.MembershipID,
		CauseType:      obligationPenalty,
		CauseID:        causeID,
		ObligationType: int32(models.ObligationTypeOneTime),
		PeriodID:       periodID,
		Amount:         penalty,
		Currency:       obl.Currency,
		Deadline:       obl.Deadline,
		Description:    "Late payment penalty for obligation " + obl.GetID(),
		State:          int32(constants.StateActive),
		Properties:     properties,
	}
	penaltyObl.GenID(ctx)
	penaltyObl.CopyPartitionInfo(&obl.BaseModel)

	return penaltyObl
}

// periodsLate counts how many whole penalty windows have elapsed since a
// deadline, which selects the fine tier. It is at least one for any overdue
// obligation.
func periodsLate(now, deadline time.Time) int32 {
	const (
		daysPerPenaltyWindow = 7
		hoursPerDay          = 24
	)
	days := int(now.Sub(deadline).Hours() / hoursPerDay)
	tier := days/daysPerPenaltyWindow + 1
	return constants.SafeInt32FromInt(tier)
}
