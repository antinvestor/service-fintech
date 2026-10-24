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
	"io"
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
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
func (b *obligationBusiness) CalculateForGroup(
	ctx context.Context,
	groupID string,
) (map[string]interface{}, error) {
	logger := util.Log(ctx).WithField("method", "ObligationBusiness.CalculateForGroup").
		WithField("group_id", groupID)

	// Load the group to get saving amount and currency
	grpResp, err := b.identityCli.ClientGroupGet(ctx, &identityv1.ClientGroupGetRequest{Id: groupID})
	if err != nil {
		return nil, fmt.Errorf("group not found: %w", err)
	}
	group := grpResp.GetData()

	if group.GetState() != commonv1.STATE_ACTIVE {
		logger.Warn("group is not active, skipping obligation calculation")
		return emptyObligationSummary(groupID, ""), nil
	}

	savingAmount := group.GetSavingAmount()
	currencyCode := group.GetCurrencyCode()

	// Get the current period for the group
	period, err := b.perRepo.GetCurrentByGroupID(ctx, groupID)
	if err != nil {
		return nil, fmt.Errorf("current period not found for group %s: %w", groupID, err)
	}

	logger = logger.WithField("period_id", period.GetID())
	logger.Info("calculating obligations for group")

	// Get all active memberships via identity SDK
	memberships, err := b.getMembersByGroupID(ctx, groupID)
	if err != nil {
		return nil, fmt.Errorf("could not load memberships for group %s: %w", groupID, err)
	}

	if len(memberships) == 0 {
		logger.Warn("no active memberships found, skipping")
		return emptyObligationSummary(groupID, period.GetID()), nil
	}

	// Check for existing obligations in this period to avoid duplicates
	existingObs, err := b.obRepo.GetByPeriodID(ctx, period.GetID())
	if err != nil {
		return nil, fmt.Errorf("could not check existing obligations: %w", err)
	}

	existingByMember := make(map[string]map[string]bool) // memberID -> causeType -> exists
	for _, ob := range existingObs {
		if _, ok := existingByMember[ob.MembershipID]; !ok {
			existingByMember[ob.MembershipID] = make(map[string]bool)
		}
		existingByMember[ob.MembershipID][ob.CauseType] = true
	}

	created := b.raiseSavingsObligations(ctx, logger, savingsRun{
		groupID:          groupID,
		currencyCode:     currencyCode,
		savingAmount:     savingAmount,
		period:           period,
		memberships:      memberships,
		existingByMember: existingByMember,
	})

	logger.WithField("obligations_created", created).
		WithField("members_processed", len(memberships)).
		Info("obligation calculation completed")

	periodObs, err := b.obRepo.GetByPeriodID(ctx, period.GetID())
	if err != nil {
		return nil, fmt.Errorf("could not read the period's obligations: %w", err)
	}

	summary := emptyObligationSummary(groupID, period.GetID())
	summary["obligations_created"] = created
	summary["members_processed"] = len(memberships)
	summary["member_obligations"] = summariseMemberObligations(periodObs)
	return summary, nil
}

// savingsRun carries the inputs of one periodic-savings obligation run.
type savingsRun struct {
	groupID          string
	currencyCode     string
	savingAmount     int64
	period           *PeriodInfo
	memberships      []*identityv1.MembershipObject
	existingByMember map[string]map[string]bool
}

// raiseSavingsObligations creates the period's periodic savings obligation for
// every regular member that does not already have one, and reports how many
// were raised. Loan repayment obligations are raised separately by
// CreateLoanObligations as schedule entries become due.
func (b *obligationBusiness) raiseSavingsObligations(
	ctx context.Context,
	logger *util.LogEntry,
	run savingsRun,
) int {
	if run.savingAmount <= 0 {
		return 0
	}

	created := 0
	for _, mem := range run.memberships {
		memberID := mem.GetId()
		if mem.GetMembershipType() != MembershipTypeMember {
			continue
		}
		if run.existingByMember[memberID][obligationPeriodicSaving] {
			continue
		}

		ob := &models.Obligation{
			MembershipID:   memberID,
			CauseType:      obligationPeriodicSaving,
			CauseID:        run.groupID,
			ObligationType: int32(models.ObligationTypePeriodic),
			PeriodID:       run.period.GetID(),
			Amount:         run.savingAmount,
			Currency:       run.currencyCode,
			Deadline:       run.period.EndDate,
			Description:    fmt.Sprintf("Periodic savings for period %d", run.period.Position),
			State:          int32(constants.StateActive),
			Properties: data.JSONMap{
				fieldGroupID:           run.groupID,
				propertyOriginalAmount: run.savingAmount,
			},
		}
		ob.GenID(ctx)

		if emitErr := b.eventsMan.Emit(ctx, events.ObligationSaveEvent, ob); emitErr != nil {
			logger.WithError(emitErr).
				WithField(fieldMemberID, memberID).
				Error("could not create savings obligation")
			continue
		}
		created++
	}
	return created
}

// emptyObligationSummary is the shape every CalculateForGroup return follows,
// so a workflow reading member_obligations never sees a missing key.
func emptyObligationSummary(groupID, periodID string) map[string]interface{} {
	return map[string]interface{}{
		fieldGroupID:          groupID,
		fieldPeriodID:         periodID,
		"obligations_created": 0,
		"members_processed":   0,
		"member_obligations":  []map[string]interface{}{},
	}
}

// summariseMemberObligations folds a period's obligations into one row per
// member, splitting savings from loan repayment so a reminder can name both.
func summariseMemberObligations(obligations []*models.Obligation) []map[string]interface{} {
	type memberDue struct {
		savings int64
		loan    int64
		other   int64
		due     *time.Time
	}

	order := make([]string, 0, len(obligations))
	byMember := map[string]*memberDue{}
	for _, obl := range obligations {
		if obl.State != int32(constants.StateActive) || obl.Amount <= 0 {
			continue
		}
		entry, seen := byMember[obl.MembershipID]
		if !seen {
			entry = &memberDue{}
			byMember[obl.MembershipID] = entry
			order = append(order, obl.MembershipID)
		}
		switch {
		case obl.CauseType == obligationPeriodicSaving || obl.CauseType == obligationSaving:
			entry.savings += obl.Amount
		case strings.HasPrefix(obl.CauseType, "loan_"):
			entry.loan += obl.Amount
		default:
			entry.other += obl.Amount
		}
		if obl.Deadline != nil && (entry.due == nil || obl.Deadline.Before(*entry.due)) {
			entry.due = obl.Deadline
		}
	}

	result := make([]map[string]interface{}, 0, len(order))
	for _, memberID := range order {
		entry := byMember[memberID]
		row := map[string]interface{}{
			fieldMemberID:        memberID,
			fieldMembershipID:    memberID,
			"savings_due":        entry.savings,
			"loan_repayment_due": entry.loan,
			"other_due":          entry.other,
			"total_due":          entry.savings + entry.loan + entry.other,
			fieldDueDate:         formatDeadline(entry.due),
		}
		result = append(result, row)
	}
	return result
}

// formatDeadline renders an obligation deadline for a workflow template.
func formatDeadline(deadline *time.Time) string {
	if deadline == nil {
		return ""
	}
	return deadline.UTC().Format(time.RFC3339)
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

// getMembersByGroupID fetches group memberships via the identity SDK.
func (b *obligationBusiness) getMembersByGroupID(
	ctx context.Context,
	groupID string,
) ([]*identityv1.MembershipObject, error) {
	if b.identityCli == nil {
		return nil, errors.New("identity client not available")
	}

	stream, err := b.identityCli.MembershipSearch(ctx, &identityv1.MembershipSearchRequest{GroupId: groupID})
	if err != nil {
		return nil, err
	}

	var members []*identityv1.MembershipObject
	for {
		msg2, streamErr := stream.Receive()
		if streamErr != nil {
			if errors.Is(streamErr, io.EOF) {
				break
			}
			return nil, streamErr
		}
		msg := msg2
		members = append(members, msg.GetData()...)
	}

	return members, nil
}
