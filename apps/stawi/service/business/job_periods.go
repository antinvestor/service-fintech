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
	"strconv"
	"strings"
	"time"

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
)

// maxNamesInArrears bounds the member names a leader's arrears message
// lists, so it stays a text message.
const maxNamesInArrears = 8

// closeDuePeriods closes up to batch periods whose end date has passed. A
// period that fails is held off for a while and resumed later.
func (j *StawiJobs) closeDuePeriods(ctx context.Context, batch int) (int, bool, error) {
	periods, err := j.Periods.ListDueToClose(listCtx(ctx), j.now().UTC(), batch)
	if err != nil {
		return 0, false, fmt.Errorf("periods due to close: %w", err)
	}
	closed, handled := 0, 0
	for _, p := range periods {
		actCtx := j.actIn(ctx, &p.BaseModel)
		closeErr := j.closePeriod(actCtx, p)
		if closeErr == nil {
			closed++
			handled++
			continue
		}
		util.Log(ctx).WithError(closeErr).WithField(fieldPeriodID, p.GetID()).
			Warn("period not closed; a later run resumes it")
		if j.holdPeriod(actCtx, p, func(p *models.Period) { p.CloseRetryAt = j.retryAt() }) == nil {
			handled++
		}
	}
	return closed, len(periods) == batch && handled > 0, nil
}

// closePeriod settles a due period. Every step is idempotent and the period
// is marked closed last, so a run that stops part way is resumed by the
// next one without charging, opening or notifying twice:
//
//  1. operations charges each member still owing the late fine, once;
//  2. while the group runs, the next period opens (one, whatever the
//     retries), its obligations are raised and the loan window is opened
//     when the loan cycle says so, which makes the members' offers;
//  3. every member is sent the period's statement;
//  4. the period is closed, or with it the tenure, when that was its last.
func (j *StawiJobs) closePeriod(ctx context.Context, period *models.Period) error {
	group, err := j.Directory.Get(ctx, period.GroupID)
	if err != nil {
		return err
	}
	tenure, err := j.Tenures.GetByID(ctx, period.TenureID)
	if err != nil {
		return fmt.Errorf("tenure: %w", err)
	}

	statement, err := j.Obligation.Close(ctx, period.GroupID, period.GetID())
	if err != nil {
		return fmt.Errorf("close obligations: %w", err)
	}

	tenureEnded := false
	switch {
	case tenure.State != int32(constants.StateActive):
	case !groupActive(group):
		// The group stopped: no new period. Its tenure waits for identity
		// to restore the group.
		tenure.State = int32(constants.StateInactive)
		if err = j.updateTenure(ctx, tenure); err != nil {
			return err
		}
	default:
		tenureEnded, err = j.rollOver(ctx, period)
		if err != nil {
			return err
		}
	}

	if err = j.sendPeriodSummaries(ctx, group, period, statement); err != nil {
		return fmt.Errorf("period summaries: %w", err)
	}
	if tenureEnded {
		// Closing the tenure closes its last period with it.
		return j.Tenure.Close(ctx, tenure.GetID())
	}
	return j.Period.Close(ctx, period.GetID())
}

// rollOver opens the period after previous, raises its obligations and
// opens the loan window when it is due. It reports a tenure with no
// periods left.
func (j *StawiJobs) rollOver(ctx context.Context, previous *models.Period) (bool, error) {
	next, err := j.Period.OpenNext(ctx, previous)
	if errors.Is(err, ErrTenureExhausted) {
		return true, nil
	}
	if err != nil {
		return false, fmt.Errorf("open next period: %w", err)
	}
	if _, err = j.Obligation.Raise(ctx, next.GroupID, next.GetID()); err != nil {
		return false, fmt.Errorf("raise obligations: %w", err)
	}
	return false, j.openLoanWindow(ctx, next.GroupID)
}

// openLoanWindow opens the group's loan window for its current period when
// the loan cycle says so; opening makes the members' offers and is
// idempotent. A refusal that will not change on retry (no savings amount,
// for instance) is logged rather than holding the period close back.
func (j *StawiJobs) openLoanWindow(ctx context.Context, groupID string) error {
	evaluation, err := j.LoanWindow.Evaluate(ctx, groupID)
	if err != nil {
		return fmt.Errorf("evaluate loan window: %w", err)
	}
	if eligible, _ := evaluation[fieldEligible].(bool); !eligible {
		return nil
	}
	if _, err = j.LoanWindow.Open(ctx, groupID); err != nil {
		if permanentRefusal(err) {
			util.Log(ctx).WithError(err).WithField(fieldGroupID, groupID).Warn("loan window not opened")
			return nil
		}
		return fmt.Errorf("open loan window: %w", err)
	}
	return nil
}

// sendPeriodSummaries sends every member of the closed period's statement
// their own line, once.
func (j *StawiJobs) sendPeriodSummaries(
	ctx context.Context,
	group *identityv1.ClientGroupObject,
	period *models.Period,
	statement map[string]any,
) error {
	members, _ := statement[fieldMembers].([]map[string]any)
	currency := group.GetCurrencyCode()
	var failures []error
	for _, member := range members {
		membershipID, _ := member[fieldMembershipID].(string)
		profileID, _ := member[fieldProfileID].(string)
		saved, _ := member["savings_total"].(int64)
		outstanding, _ := member["outstanding"].(int64)
		key := "period_summary:" + period.GetID() + ":" + membershipID
		if err := j.sendOnce(ctx, key, group.GetId(), notify.Message{
			Template:  messages.GroupPeriodSummary,
			Recipient: notify.ToProfile(profileID),
			Vars: map[string]any{
				messages.VarGroupName: group.GetName(),
				messages.VarAmount:    messages.FormatAmount(currency, saved),
				messages.VarBalance:   messages.FormatAmount(currency, outstanding),
				messages.VarCurrency:  currency,
			},
		}); err != nil {
			failures = append(failures, err)
		}
	}
	return errors.Join(failures...)
}

// sendReminders reminds members of up to batch running periods whose next
// reminder is due. Each reminder offset goes out once per member; a period
// whose reminders fail is tried again a little later.
func (j *StawiJobs) sendReminders(ctx context.Context, batch int) (int, bool, error) {
	now := j.now().UTC()
	periods, err := j.Periods.ListDueForReminder(listCtx(ctx), now, batch)
	if err != nil {
		return 0, false, fmt.Errorf("periods due for reminders: %w", err)
	}
	reminded, handled := 0, 0
	for _, p := range periods {
		actCtx := j.actIn(ctx, &p.BaseModel)
		offset, remindErr := j.remind(actCtx, p, now)
		next := nextReminderAt(*p.EndDate, offset, j.reminders)
		if remindErr != nil {
			util.Log(ctx).WithError(remindErr).WithField(fieldPeriodID, p.GetID()).
				Warn("reminders not sent; a later run retries")
			next = j.retryAt()
		} else {
			reminded++
		}
		if j.holdPeriod(actCtx, p, func(p *models.Period) { p.NextReminderAt = next }) == nil {
			handled++
		}
	}
	return reminded, len(periods) == batch && handled > 0, nil
}

// remind sends the reminders of the period's tightest offset whose time has
// come, to members still owing and to the group's leaders, and returns that
// offset. Raising the period's obligations again raises nothing new and
// reports who still owes.
func (j *StawiJobs) remind(ctx context.Context, period *models.Period, now time.Time) (time.Duration, error) {
	offset := reachedOffset(*period.EndDate, now, j.reminders)
	if offset == 0 {
		return 0, nil
	}
	group, err := j.Directory.Get(ctx, period.GroupID)
	if err != nil {
		return offset, err
	}
	result, err := j.Obligation.Raise(ctx, period.GroupID, period.GetID())
	if err != nil {
		return offset, fmt.Errorf("read who owes: %w", err)
	}
	owing, _ := result[fieldMembers].([]map[string]any)
	if len(owing) == 0 {
		return offset, nil
	}

	memberships, err := j.Members.GetByGroupID(ctx, period.GroupID)
	if err != nil {
		return offset, err
	}
	suffix := ":" + strconv.Itoa(int(offset.Hours())) + "h"
	currency := group.GetCurrencyCode()
	dueDate := messages.FormatDate(period.EndDate)

	var failures []error
	names := make([]string, 0, len(owing))
	byID := membershipsByID(memberships)
	for _, member := range owing {
		membershipID, _ := member[fieldMembershipID].(string)
		profileID, _ := member[fieldProfileID].(string)
		outstanding, _ := member["amount_outstanding"].(int64)
		names = append(names, memberName(byID[membershipID]))
		key := "reminder:" + period.GetID() + ":" + membershipID + suffix
		if sendErr := j.sendOnce(ctx, key, group.GetId(), notify.Message{
			Template:  messages.GroupSavingsReminder,
			Recipient: notify.ToProfile(profileID),
			Vars: map[string]any{
				messages.VarGroupName: group.GetName(),
				messages.VarAmount:    messages.FormatAmount(currency, outstanding),
				messages.VarCurrency:  currency,
				messages.VarDueDate:   dueDate,
			},
		}); sendErr != nil {
			failures = append(failures, sendErr)
		}
	}

	leaderVars := map[string]any{
		messages.VarGroupName:   group.GetName(),
		messages.VarMemberCount: strconv.Itoa(len(owing)),
		messages.VarDueDate:     dueDate,
		messages.VarSummary:     nameList(names),
	}
	for _, m := range memberships {
		if !groupLeader(m) {
			continue
		}
		key := "arrears:" + period.GetID() + ":" + m.GetId() + suffix
		if sendErr := j.sendOnce(ctx, key, group.GetId(), notify.Message{
			Template:  messages.GroupLeaderArrears,
			Recipient: notify.ToProfile(m.GetProfileId()),
			Vars:      leaderVars,
		}); sendErr != nil {
			failures = append(failures, sendErr)
		}
	}
	return offset, errors.Join(failures...)
}

// reachedOffset is the tightest reminder offset whose time has come for a
// period ending at end, or zero when none has. A run that missed an
// earlier offset sends only the tightest, never a burst of stale ones.
func reachedOffset(end, now time.Time, offsets []time.Duration) time.Duration {
	remaining := end.Sub(now)
	var reached time.Duration
	for _, offset := range offsets {
		if remaining <= offset {
			reached = offset
		}
	}
	return reached
}

// nextReminderAt is when the reminder after sent is due: the next shorter
// offset before end, or nil when sent was the last.
func nextReminderAt(end time.Time, sent time.Duration, offsets []time.Duration) *time.Time {
	if sent == 0 {
		return nil
	}
	for _, offset := range offsets {
		if offset < sent {
			at := end.Add(-offset)
			return &at
		}
	}
	return nil
}

// holdPeriod applies change to the period and writes it under its version.
func (j *StawiJobs) holdPeriod(ctx context.Context, period *models.Period, change func(*models.Period)) error {
	change(period)
	rows, err := j.Periods.Update(ctx, period)
	if err == nil && rows == 0 {
		err = apperrors.NewError(apperrors.Conflict, "the period was changed by another request")
	}
	if err != nil {
		util.Log(ctx).WithError(err).WithField(fieldPeriodID, period.GetID()).
			Warn("could not record the period's next run")
	}
	return err
}

func membershipsByID(memberships []*identityv1.MembershipObject) map[string]*identityv1.MembershipObject {
	byID := make(map[string]*identityv1.MembershipObject, len(memberships))
	for _, m := range memberships {
		byID[m.GetId()] = m
	}
	return byID
}

// memberName is how a leader recognises a member.
func memberName(m *identityv1.MembershipObject) string {
	if m == nil || strings.TrimSpace(m.GetName()) == "" {
		return "a member"
	}
	return strings.TrimSpace(m.GetName())
}

// nameList joins names, naming at most maxNamesInArrears.
func nameList(names []string) string {
	if len(names) <= maxNamesInArrears {
		return strings.Join(names, ", ")
	}
	return strings.Join(names[:maxNamesInArrears], ", ") +
		" and " + strconv.Itoa(len(names)-maxNamesInArrears) + " more"
}
