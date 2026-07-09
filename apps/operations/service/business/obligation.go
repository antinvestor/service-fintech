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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
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
	eventsMan   fevents.Manager
	obRepo      repository.ObligationRepository
	identityCli identityv1connect.IdentityServiceClient
	perRepo     PeriodReader
}

func NewObligationBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	obRepo repository.ObligationRepository,
	identityCli identityv1connect.IdentityServiceClient,
	perRepo PeriodReader,
) ObligationBusiness {
	return &obligationBusiness{
		eventsMan:   eventsMan,
		obRepo:      obRepo,
		identityCli: identityCli,
		perRepo:     perRepo,
	}
}

// CalculateForGroup computes financial obligations for all active members of
// the given group in the current period.
func (b *obligationBusiness) CalculateForGroup(ctx context.Context, groupID string) error {
	logger := util.Log(ctx).WithField("method", "ObligationBusiness.CalculateForGroup").
		WithField("group_id", groupID)

	// Load the group to get saving amount and currency
	grpResp, err := b.identityCli.ClientGroupGet(ctx, connect.NewRequest(
		&identityv1.ClientGroupGetRequest{Id: groupID},
	))
	if err != nil {
		return fmt.Errorf("group not found: %w", err)
	}
	group := grpResp.Msg.GetData()

	if group.GetState() != commonv1.STATE_ACTIVE {
		logger.Warn("group is not active, skipping obligation calculation")
		return nil
	}

	savingAmount := group.GetSavingAmount()
	currencyCode := group.GetCurrencyCode()

	// Get the current period for the group
	period, err := b.perRepo.GetCurrentByGroupID(ctx, groupID)
	if err != nil {
		return fmt.Errorf("current period not found for group %s: %w", groupID, err)
	}

	logger = logger.WithField("period_id", period.GetID())
	logger.Info("calculating obligations for group")

	// Get all active memberships via identity SDK
	memberships, err := b.getMembersByGroupID(ctx, groupID)
	if err != nil {
		return fmt.Errorf("could not load memberships for group %s: %w", groupID, err)
	}

	if len(memberships) == 0 {
		logger.Warn("no active memberships found, skipping")
		return nil
	}

	// Check for existing obligations in this period to avoid duplicates
	existingObs, err := b.obRepo.GetByPeriodID(ctx, period.GetID())
	if err != nil {
		return fmt.Errorf("could not check existing obligations: %w", err)
	}

	existingByMember := make(map[string]map[string]bool) // memberID -> causeType -> exists
	for _, ob := range existingObs {
		if _, ok := existingByMember[ob.MembershipID]; !ok {
			existingByMember[ob.MembershipID] = make(map[string]bool)
		}
		existingByMember[ob.MembershipID][ob.CauseType] = true
	}

	var created int
	for _, mem := range memberships {
		memberID := mem.GetId()

		// Skip members that are not in a regular member role (agents, registrars)
		if mem.GetMembershipType() != MembershipTypeMember {
			continue
		}

		// Periodic savings obligation
		if !existingByMember[memberID]["periodic_saving"] && savingAmount > 0 {
			ob := &models.Obligation{
				MembershipID:   memberID,
				CauseType:      obligationPeriodicSaving,
				CauseID:        groupID,
				ObligationType: int32(models.ObligationTypePeriodic),
				PeriodID:       period.GetID(),
				Amount:         savingAmount,
				Currency:       currencyCode,
				Deadline:       period.EndDate,
				Description:    fmt.Sprintf("Periodic savings for period %d", period.Position),
				State:          int32(constants.StateActive),
			}
			ob.GenID(ctx)
			// Partition info is set from the request context by the frame middleware.

			if emitErr := b.eventsMan.Emit(ctx, events.ObligationSaveEvent, ob); emitErr != nil {
				logger.WithError(emitErr).
					WithField("member_id", memberID).
					Error("could not create savings obligation")
				continue
			}
			created++
		}

		// NOTE: Loan repayment obligations are created separately by
		// CreateLoanObligations when amortization schedule entries become due.
	}

	logger.WithField("obligations_created", created).
		WithField("members_processed", len(memberships)).
		Info("obligation calculation completed")

	return nil
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
		oblProps := data.JSONMap{fieldGroupID: entry.GroupID}

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

// getMembersByGroupID fetches group memberships via the identity SDK.
func (b *obligationBusiness) getMembersByGroupID(
	ctx context.Context,
	groupID string,
) ([]*identityv1.MembershipObject, error) {
	if b.identityCli == nil {
		return nil, errors.New("identity client not available")
	}

	stream, err := b.identityCli.MembershipSearch(ctx, connect.NewRequest(
		&identityv1.MembershipSearchRequest{GroupId: groupID},
	))
	if err != nil {
		return nil, err
	}

	var members []*identityv1.MembershipObject
	for stream.Receive() {
		msg := stream.Msg()
		members = append(members, msg.GetData()...)
	}
	if streamErr := stream.Err(); streamErr != nil {
		return nil, streamErr
	}

	return members, nil
}
