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
	"time"

	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/operations/service/events"
	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// ScheduleEntryInfo carries the info needed to create loan obligations from schedule entries.
type ScheduleEntryInfo struct {
	EntryID      string
	MembershipID string
	GroupID      string
	PeriodID     string
	PrincipalDue int64
	InterestDue  int64
	FeesDue      int64
	Currency     string
	DueDate      *time.Time
}

// Identity state/type constants used by payment routing and obligation logic.
const (
	MembershipTypeMember int32 = 3 // identityv1.MembershipType_MEMBERSHIP_TYPE_MEMBER
	GroupStateDeleted    int32 = 5
	GroupStateShutdown   int32 = 6
)

type obligationBusiness struct {
	eventsMan fevents.Manager
	obRepo    repository.ObligationRepository
	// settler applies a member's received money to newly raised obligations.
	settler MemberSettler
}

// MemberSettler applies what a group member has paid to what they owe and
// reports how much it applied. PaymentRoutingBusiness is one.
type MemberSettler interface {
	SettleMember(ctx context.Context, membershipID string) (int64, error)
}

// NewObligationBusiness builds the obligation business. Operations owns
// group obligations; the group service sends the period facts it owns.
func NewObligationBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	obRepo repository.ObligationRepository,
	settler MemberSettler,
) ObligationBusiness {
	return &obligationBusiness{
		eventsMan: eventsMan,
		obRepo:    obRepo,
		settler:   settler,
	}
}

// CreateLoanObligations creates obligations for due schedule entries.
func (b *obligationBusiness) CreateLoanObligations(
	ctx context.Context,
	loanAccountID string,
	entries []ScheduleEntryInfo,
) error {
	logger := util.Log(ctx).WithField("method", "ObligationBusiness.CreateLoanObligations").
		WithField("loan_account_id", loanAccountID)

	var created int
	for _, entry := range entries {
		// Check if obligations already exist for this entry to avoid duplicates
		existingObs, err := b.obRepo.GetByCauseID(ctx, entry.EntryID)
		if err == nil && len(existingObs) > 0 {
			logger.WithField("entry_id", entry.EntryID).
				Debug("obligations already exist for this schedule entry, skipping")
			continue
		}

		// Build properties map carrying the group_id so that downstream routing
		// (e.g. creditAccountForBucket) can direct funds to the correct group account.
		// The loan account id rides along too: a payment allocated to one of
		// these obligations is recorded with the lender against that loan.
		oblProps := data.JSONMap{fieldGroupID: entry.GroupID, fieldLoanAccountID: loanAccountID}

		// Create principal obligation
		if entry.PrincipalDue > 0 {
			ob := &models.Obligation{
				MembershipID:   entry.MembershipID,
				CauseType:      "loan_principal",
				CauseID:        entry.EntryID,
				ObligationType: int32(models.ObligationTypePeriodic),
				PeriodID:       entry.PeriodID,
				Amount:         entry.PrincipalDue,
				Currency:       entry.Currency,
				Deadline:       entry.DueDate,
				Description:    fmt.Sprintf("Loan principal repayment for entry %s", entry.EntryID),
				State:          int32(constants.StateActive),
				Properties:     oblProps,
			}
			ob.GenID(ctx)

			if emitErr := b.eventsMan.Emit(ctx, events.ObligationSaveEvent, ob); emitErr != nil {
				logger.WithError(emitErr).
					WithField("entry_id", entry.EntryID).
					Error("could not create principal obligation")
				continue
			}
			created++
		}

		// Create interest obligation
		if entry.InterestDue > 0 {
			ob := &models.Obligation{
				MembershipID:   entry.MembershipID,
				CauseType:      "loan_interest",
				CauseID:        entry.EntryID,
				ObligationType: int32(models.ObligationTypePeriodic),
				PeriodID:       entry.PeriodID,
				Amount:         entry.InterestDue,
				Currency:       entry.Currency,
				Deadline:       entry.DueDate,
				Description:    fmt.Sprintf("Loan interest repayment for entry %s", entry.EntryID),
				State:          int32(constants.StateActive),
				Properties:     oblProps,
			}
			ob.GenID(ctx)

			if emitErr := b.eventsMan.Emit(ctx, events.ObligationSaveEvent, ob); emitErr != nil {
				logger.WithError(emitErr).
					WithField("entry_id", entry.EntryID).
					Error("could not create interest obligation")
				continue
			}
			created++
		}

		// Create fees obligation (insurance + processing combined)
		if entry.FeesDue > 0 {
			ob := &models.Obligation{
				MembershipID:   entry.MembershipID,
				CauseType:      "loan_fees",
				CauseID:        entry.EntryID,
				ObligationType: int32(models.ObligationTypePeriodic),
				PeriodID:       entry.PeriodID,
				Amount:         entry.FeesDue,
				Currency:       entry.Currency,
				Deadline:       entry.DueDate,
				Description:    fmt.Sprintf("Loan fees for entry %s", entry.EntryID),
				State:          int32(constants.StateActive),
				Properties:     oblProps,
			}
			ob.GenID(ctx)

			if emitErr := b.eventsMan.Emit(ctx, events.ObligationSaveEvent, ob); emitErr != nil {
				logger.WithError(emitErr).
					WithField("entry_id", entry.EntryID).
					Error("could not create fees obligation")
				continue
			}
			created++
		}
	}

	logger.WithField("obligations_created", created).
		WithField("entries_processed", len(entries)).
		Info("loan obligation creation completed")

	return nil
}

// GetStatus returns the current status of a specific obligation.
func (b *obligationBusiness) GetStatus(ctx context.Context, obligationID string) (map[string]interface{}, error) {
	logger := util.Log(ctx).WithField("method", "ObligationBusiness.GetStatus").
		WithField("obligation_id", obligationID)

	ob, err := b.obRepo.GetByID(ctx, obligationID)
	if err != nil {
		return nil, fmt.Errorf("obligation not found: %w", err)
	}

	logger.Info("fetching obligation status")

	fulfilled := ob.State == int32(constants.StateInactive)

	status := map[string]interface{}{
		"id":              ob.GetID(),
		fieldMembershipID: ob.MembershipID,
		"cause_type":      ob.CauseType,
		"cause_id":        ob.CauseID,
		"obligation_type": ob.ObligationType,
		"period_id":       ob.PeriodID,
		fieldAmount:       ob.Amount,
		fieldCurrency:     ob.Currency,
		fieldState:        ob.State,
		"fulfilled":       fulfilled,
		"description":     ob.Description,
	}

	if ob.Deadline != nil {
		status["deadline"] = ob.Deadline.Format("2006-01-02T15:04:05Z")
	}

	if ob.NotificationID != "" {
		status["notification_id"] = ob.NotificationID
	}

	if ob.Properties != nil {
		if paidAmount, ok := ob.Properties["paid_amount"]; ok {
			status["paid_amount"] = paidAmount
		}
		if paidAt, ok := ob.Properties["paid_at"]; ok {
			status["paid_at"] = paidAt
		}
	}

	return status, nil
}
