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
	"strings"
	"time"

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// maxGroupMembers bounds one raise: a group far larger than any chama is a
// caller bug, not a group.
const maxGroupMembers = 1000

// ErrGroupObligationsInternalOnly is returned when anyone but an internal
// service asks to raise or close a group period's obligations. Obligations
// decide what members owe, so they come only from the group service.
var ErrGroupObligationsInternalOnly = apperrors.NewError(apperrors.Forbidden,
	"group obligations are managed only by internal services")

// GroupMemberDue is one member's contribution for a period, in minor units.
type GroupMemberDue struct {
	MembershipID string
	ProfileID    string
	Amount       int64
}

// GroupObligationsRaise is the group service's request to raise a period's
// savings obligations.
type GroupObligationsRaise struct {
	GroupID  string
	PeriodID string
	Currency string
	DueAt    time.Time
	Members  []GroupMemberDue
}

// GroupPeriodClose is the group service's request to close a period. Penalty
// is charged once to every member still owing; zero charges nothing.
type GroupPeriodClose struct {
	GroupID  string
	PeriodID string
	Currency string
	Penalty  int64
}

// GroupMemberStanding is where one member stands for a period, in minor
// units. Due, Paid and Outstanding leave the penalty out.
type GroupMemberStanding struct {
	MembershipID string
	ProfileID    string
	Raised       bool
	Due          int64
	Paid         int64
	Outstanding  int64
	Penalty      int64
}

// GroupPeriodStanding is a period's statement. Collected counts everything
// applied, penalties included; Outstanding is the members' balances.
type GroupPeriodStanding struct {
	Currency    string
	Members     []GroupMemberStanding
	Collected   int64
	Outstanding int64
}

// RaiseGroupObligations raises the period's savings obligation for each
// member, then applies money they already paid. A retry raises nothing new:
// the unique index holds one savings obligation per member per period.
func (b *obligationBusiness) RaiseGroupObligations(
	ctx context.Context,
	req GroupObligationsRaise,
) (*GroupPeriodStanding, error) {
	logger := util.Log(ctx).WithField("method", "ObligationBusiness.RaiseGroupObligations").
		WithField(fieldGroupID, req.GroupID).WithField(fieldPeriodID, req.PeriodID)

	members, err := validateGroupRaise(&req)
	if err != nil {
		return nil, err
	}
	if _, err = b.periodObligations(ctx, req.GroupID, req.PeriodID); err != nil {
		return nil, err
	}

	dueAt := req.DueAt.UTC()
	raised := map[string]bool{}
	for _, member := range members {
		obl := &models.Obligation{
			MembershipID:   member.MembershipID,
			CauseType:      obligationPeriodicSaving,
			CauseID:        req.GroupID,
			ObligationType: int32(models.ObligationTypePeriodic),
			PeriodID:       req.PeriodID,
			Amount:         member.Amount,
			Currency:       req.Currency,
			Deadline:       &dueAt,
			Description:    "Savings for period " + req.PeriodID,
			State:          int32(constants.StateActive),
			Properties: data.JSONMap{
				fieldGroupID:           req.GroupID,
				fieldProfileID:         member.ProfileID,
				propertyOriginalAmount: member.Amount,
			},
		}
		obl.GenID(ctx)
		created, createErr := b.obRepo.CreateIfAbsent(ctx, obl)
		if createErr != nil {
			return nil, fmt.Errorf("raise savings obligation for member %s: %w", member.MembershipID, createErr)
		}
		raised[member.MembershipID] = created
	}

	// Money that arrived before the obligation existed sits in the member's
	// suspense or waits unallocated; it pays the new obligation now.
	if err = b.settleMembers(ctx, members); err != nil {
		return nil, err
	}

	obligations, err := b.periodObligations(ctx, req.GroupID, req.PeriodID)
	if err != nil {
		return nil, err
	}
	standing := periodStanding(obligations, members)
	standing.Currency = req.Currency
	for i := range standing.Members {
		standing.Members[i].Raised = raised[standing.Members[i].MembershipID]
	}
	logger.WithField("members", len(members)).Info("group period obligations raised")
	return standing, nil
}

// CloseGroupPeriod applies money members paid, charges the penalty once to
// each member still owing and reports the period's statement. A retry finds
// the penalty already raised and charges nothing more.
func (b *obligationBusiness) CloseGroupPeriod(
	ctx context.Context,
	req GroupPeriodClose,
) (*GroupPeriodStanding, error) {
	logger := util.Log(ctx).WithField("method", "ObligationBusiness.CloseGroupPeriod").
		WithField(fieldGroupID, req.GroupID).WithField(fieldPeriodID, req.PeriodID)

	req.GroupID = strings.TrimSpace(req.GroupID)
	req.PeriodID = strings.TrimSpace(req.PeriodID)
	if req.GroupID == "" || req.PeriodID == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "a group id and a period id are required")
	}
	if req.Penalty < 0 {
		return nil, apperrors.NewError(apperrors.BadRequest, "the penalty cannot be negative")
	}

	obligations, err := b.periodObligations(ctx, req.GroupID, req.PeriodID)
	if err != nil {
		return nil, err
	}
	members := membersOf(obligations)
	if len(members) == 0 {
		return &GroupPeriodStanding{Currency: req.Currency, Members: []GroupMemberStanding{}}, nil
	}
	currency := obligations[0].Currency
	if req.Penalty > 0 && !strings.EqualFold(req.Currency, currency) {
		return nil, apperrors.NewError(apperrors.BadRequest, "the penalty must be in the period's currency")
	}

	// A member who paid before the close is not penalised because the
	// allocation had not run yet.
	if err = b.settleMembers(ctx, members); err != nil {
		return nil, err
	}
	if obligations, err = b.periodObligations(ctx, req.GroupID, req.PeriodID); err != nil {
		return nil, err
	}

	charged, err := b.chargePenalties(ctx, req, obligations, members)
	if err != nil {
		return nil, err
	}
	if charged > 0 {
		if obligations, err = b.periodObligations(ctx, req.GroupID, req.PeriodID); err != nil {
			return nil, err
		}
	}

	standing := periodStanding(obligations, members)
	standing.Currency = currency
	logger.WithField("penalties_charged", charged).WithField("outstanding", standing.Outstanding).
		Info("group period closed")
	return standing, nil
}

// chargePenalties charges the period's penalty to each member still owing
// who has not been charged yet, and reports how many it charged.
func (b *obligationBusiness) chargePenalties(
	ctx context.Context,
	req GroupPeriodClose,
	obligations []*models.Obligation,
	members []GroupMemberDue,
) (int, error) {
	if req.Penalty <= 0 {
		return 0, nil
	}
	charged := 0
	for _, member := range periodStanding(obligations, members).Members {
		if member.Outstanding <= 0 || member.Penalty > 0 {
			continue
		}
		created, err := b.raisePenalty(ctx, req, member, firstObligationOf(obligations, member.MembershipID))
		if err != nil {
			return charged, err
		}
		if created {
			charged++
		}
	}
	return charged, nil
}

// raisePenalty charges one member the period's penalty. The unique index
// holds one penalty per member per period, so a concurrent or retried close
// cannot charge twice.
func (b *obligationBusiness) raisePenalty(
	ctx context.Context,
	req GroupPeriodClose,
	member GroupMemberStanding,
	source *models.Obligation,
) (bool, error) {
	now := time.Now().UTC()
	penalty := &models.Obligation{
		MembershipID:   member.MembershipID,
		CauseType:      obligationPenalty,
		CauseID:        req.GroupID,
		ObligationType: int32(models.ObligationTypeOneTime),
		PeriodID:       req.PeriodID,
		Amount:         req.Penalty,
		Currency:       source.Currency,
		Deadline:       &now,
		Description:    "Penalty for an unpaid balance in period " + req.PeriodID,
		State:          int32(constants.StateActive),
		Properties: data.JSONMap{
			fieldGroupID:           req.GroupID,
			fieldProfileID:         member.ProfileID,
			propertyOriginalAmount: req.Penalty,
		},
	}
	penalty.GenID(ctx)
	// The penalty lives where the obligation it follows lives.
	penalty.CopyPartitionInfo(&source.BaseModel)
	created, err := b.obRepo.CreateIfAbsent(ctx, penalty)
	if err != nil {
		return false, fmt.Errorf("raise penalty for member %s: %w", member.MembershipID, err)
	}
	return created, nil
}

// settleMembers applies each member's received money to what they owe.
func (b *obligationBusiness) settleMembers(ctx context.Context, members []GroupMemberDue) error {
	if b.settler == nil {
		return nil
	}
	for _, member := range members {
		if _, err := b.settler.SettleMember(ctx, member.MembershipID); err != nil {
			return fmt.Errorf("settle member %s: %w", member.MembershipID, err)
		}
	}
	return nil
}

// periodObligations reads a period's obligations, refusing a period whose
// obligations were raised for another group: period ids are the group
// service's, and one group must never close another's period.
func (b *obligationBusiness) periodObligations(
	ctx context.Context,
	groupID, periodID string,
) ([]*models.Obligation, error) {
	obligations, err := b.obRepo.GetByPeriodID(ctx, periodID)
	if err != nil {
		return nil, fmt.Errorf("read period obligations: %w", err)
	}
	for _, obl := range obligations {
		if owner := obl.Properties.GetString(fieldGroupID); owner != "" && owner != groupID {
			return nil, apperrors.NewError(apperrors.Conflict, "the period belongs to another group")
		}
	}
	return obligations, nil
}

// validateGroupRaise checks a raise and returns its members once each, in
// the order given. A member owing nothing this period is left out.
func validateGroupRaise(req *GroupObligationsRaise) ([]GroupMemberDue, error) {
	req.GroupID = strings.TrimSpace(req.GroupID)
	req.PeriodID = strings.TrimSpace(req.PeriodID)
	req.Currency = strings.ToUpper(strings.TrimSpace(req.Currency))
	switch {
	case req.GroupID == "" || req.PeriodID == "":
		return nil, apperrors.NewError(apperrors.BadRequest, "a group id and a period id are required")
	case req.Currency == "":
		return nil, apperrors.NewError(apperrors.BadRequest, "a currency code is required")
	case req.DueAt.IsZero():
		return nil, apperrors.NewError(apperrors.BadRequest, "a due date is required")
	case len(req.Members) == 0:
		return nil, apperrors.NewError(apperrors.BadRequest, "at least one member is required")
	case len(req.Members) > maxGroupMembers:
		return nil, apperrors.NewError(apperrors.BadRequest, "too many members for one group")
	}

	seen := map[string]bool{}
	members := make([]GroupMemberDue, 0, len(req.Members))
	for _, member := range req.Members {
		member.MembershipID = strings.TrimSpace(member.MembershipID)
		member.ProfileID = strings.TrimSpace(member.ProfileID)
		if member.MembershipID == "" {
			return nil, apperrors.NewError(apperrors.BadRequest, "every member needs a membership id")
		}
		if member.Amount < 0 {
			return nil, apperrors.NewError(apperrors.BadRequest, "a member's amount cannot be negative")
		}
		if member.Amount == 0 || seen[member.MembershipID] {
			continue
		}
		seen[member.MembershipID] = true
		members = append(members, member)
	}
	return members, nil
}

// membersOf lists the members a period's obligations were raised for, in the
// order they first appear.
func membersOf(obligations []*models.Obligation) []GroupMemberDue {
	seen := map[string]bool{}
	var members []GroupMemberDue
	for _, obl := range obligations {
		if seen[obl.MembershipID] {
			continue
		}
		seen[obl.MembershipID] = true
		members = append(members, GroupMemberDue{
			MembershipID: obl.MembershipID,
			ProfileID:    obl.Properties.GetString(fieldProfileID),
		})
	}
	return members
}

// firstObligationOf returns a member's first obligation in the period.
func firstObligationOf(obligations []*models.Obligation, membershipID string) *models.Obligation {
	for _, obl := range obligations {
		if obl.MembershipID == membershipID && obl.CauseType != obligationPenalty {
			return obl
		}
	}
	return obligations[0]
}

// periodStanding folds a period's obligations into one row per member, in
// the members' order.
func periodStanding(obligations []*models.Obligation, members []GroupMemberDue) *GroupPeriodStanding {
	rows := make(map[string]*GroupMemberStanding, len(members))
	standing := &GroupPeriodStanding{Members: make([]GroupMemberStanding, 0, len(members))}
	for _, member := range members {
		rows[member.MembershipID] = &GroupMemberStanding{
			MembershipID: member.MembershipID,
			ProfileID:    member.ProfileID,
		}
	}

	for _, obl := range obligations {
		row, ok := rows[obl.MembershipID]
		if !ok {
			continue
		}
		if row.ProfileID == "" {
			row.ProfileID = obl.Properties.GetString(fieldProfileID)
		}
		original := originalAmount(obl)
		owed := outstandingAmount(obl)
		standing.Collected += original - owed
		if obl.CauseType == obligationPenalty {
			row.Penalty += original
			continue
		}
		row.Due += original
		row.Paid += original - owed
		row.Outstanding += owed
	}

	for _, member := range members {
		row := rows[member.MembershipID]
		standing.Outstanding += row.Outstanding
		standing.Members = append(standing.Members, *row)
	}
	return standing
}
