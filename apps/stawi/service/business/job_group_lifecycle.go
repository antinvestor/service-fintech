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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
)

// membershipTypeRegistrar is identity's membership type of a group's leader.
const membershipTypeRegistrar int32 = 1

// errGroupNotActive holds a tenure's setup while identity does not hold its
// group active; the group check stops it.
var errGroupNotActive = apperrors.NewError(apperrors.Unprocessable, "the group is not active")

// groupLifecycle brings stawi in line with identity's groups, in three
// bounded steps:
//
//  1. enrol: an active group with no running tenure gets one (a group
//     identity restored gets its tenure back);
//  2. set up: a tenure whose setup has not finished gets its ledger
//     accounts, lender registration, a running period, that period's
//     obligations and the members' welcome;
//  3. check: a running tenure whose group identity shut down or deactivated
//     stops, so no new period opens; the open period still runs to its end
//     before any late fine is charged.
func (j *StawiJobs) groupLifecycle(ctx context.Context, batch int) (int, bool, error) {
	enrolled, enrolMore, err := j.enrolActiveGroups(ctx, batch)
	if err != nil {
		return 0, false, err
	}
	setUp, setupMore, err := j.finishGroupSetups(ctx, batch)
	if err != nil {
		return enrolled, false, err
	}
	stopped, checkMore, err := j.checkGroupStates(ctx, batch)
	if err != nil {
		return enrolled + setUp, false, err
	}
	return enrolled + setUp + stopped, enrolMore || setupMore || checkMore, nil
}

// enrolActiveGroups gives up to batch active groups a running tenure. A
// group that fails is tried again on the next pass; more is reported only
// while groups are still waiting and this pass enrolled some, so a group
// that keeps failing cannot keep the run looping.
func (j *StawiJobs) enrolActiveGroups(ctx context.Context, batch int) (int, bool, error) {
	groups, err := j.Directory.ActiveGroups(ctx)
	if err != nil {
		return 0, false, fmt.Errorf("active groups: %w", err)
	}
	ids := make([]string, 0, len(groups))
	for _, g := range groups {
		ids = append(ids, g.GetId())
	}
	latest, err := j.Tenures.LatestByGroupIDs(listCtx(ctx), ids)
	if err != nil {
		return 0, false, fmt.Errorf("latest tenures: %w", err)
	}

	tenant := jobTenant(ctx)
	waiting, attempted, enrolled := 0, 0, 0
	for _, g := range groups {
		tenure := latest[g.GetId()]
		if tenure != nil && tenure.State == int32(constants.StateActive) {
			continue
		}
		waiting++
		if attempted == batch {
			continue
		}
		attempted++
		if enrolErr := j.enrol(ctx, tenant, g, tenure); enrolErr != nil {
			util.Log(ctx).WithError(enrolErr).WithField(fieldGroupID, g.GetId()).
				Warn("group not enrolled; a later run retries")
			continue
		}
		enrolled++
	}
	return enrolled, waiting > attempted && enrolled > 0, nil
}

// enrol starts the group's tenure inside the partition of its branch. A
// tenure identity's restore of the group brings back is reactivated, so its
// periods carry on; otherwise a new tenure opens. Setup finishes it.
func (j *StawiJobs) enrol(
	ctx context.Context,
	tenant string,
	group *identityv1.ClientGroupObject,
	latest *models.Tenure,
) error {
	if latest != nil && latest.State == int32(constants.StateInactive) {
		actCtx := j.actIn(ctx, &latest.BaseModel)
		latest.State = int32(constants.StateActive)
		latest.Welcomed = false
		latest.SetupRetryAt = nil
		return j.updateTenure(actCtx, latest)
	}

	partition, err := j.Directory.PartitionOf(ctx, group)
	if err != nil {
		return err
	}
	_, err = j.Tenure.Open(j.actInPartition(ctx, tenant, partition), group.GetId())
	if isConflict(err) {
		// Another run opened it first.
		return nil
	}
	return err
}

// finishGroupSetups runs the setup of up to batch tenures that have not
// finished it. A tenure whose setup fails is held off for a while.
func (j *StawiJobs) finishGroupSetups(ctx context.Context, batch int) (int, bool, error) {
	tenures, err := j.Tenures.ListPendingSetup(listCtx(ctx), j.now().UTC(), batch)
	if err != nil {
		return 0, false, fmt.Errorf("tenures pending setup: %w", err)
	}
	finished, handled := 0, 0
	for _, t := range tenures {
		actCtx := j.actIn(ctx, &t.BaseModel)
		setupErr := j.setUpGroup(actCtx, t)
		if setupErr == nil {
			finished++
			handled++
			continue
		}
		util.Log(ctx).WithError(setupErr).WithField(fieldGroupID, t.GroupID).
			Warn("group setup not finished; a later run resumes it")
		t.SetupRetryAt = j.retryAt()
		if holdErr := j.updateTenure(actCtx, t); holdErr == nil {
			handled++
		}
	}
	return finished, len(tenures) == batch && handled > 0, nil
}

// setUpGroup runs every setup step; each is idempotent, so a setup that
// stopped part way resumes where it stopped.
func (j *StawiJobs) setUpGroup(ctx context.Context, tenure *models.Tenure) error {
	group, err := j.Directory.Get(ctx, tenure.GroupID)
	if err != nil {
		return err
	}
	if !groupActive(group) {
		return errGroupNotActive
	}
	if err = j.Groups.SetupLedgerAccounts(ctx, group.GetId()); err != nil {
		return fmt.Errorf("ledger accounts: %w", err)
	}
	if err = j.Groups.RegisterWithLender(ctx, group.GetId()); err != nil {
		return fmt.Errorf("lender registration: %w", err)
	}
	period, err := j.ensurePeriod(ctx, tenure)
	if err != nil {
		return fmt.Errorf("running period: %w", err)
	}
	if _, err = j.Obligation.Raise(ctx, group.GetId(), period.GetID()); err != nil {
		return fmt.Errorf("raise obligations: %w", err)
	}
	if err = j.welcome(ctx, group, tenure, period); err != nil {
		return fmt.Errorf("welcome: %w", err)
	}
	tenure.Welcomed = true
	tenure.SetupRetryAt = nil
	return j.updateTenure(ctx, tenure)
}

// ensurePeriod returns the tenure's running period, opening one when there
// is none: the first period of a new tenure, or the one after the last
// period of a tenure that resumed.
func (j *StawiJobs) ensurePeriod(ctx context.Context, tenure *models.Tenure) (*models.Period, error) {
	current, err := j.Periods.GetCurrentByGroupID(ctx, tenure.GroupID)
	if err != nil && !data.ErrorIsNoRows(err) {
		return nil, err
	}
	if err != nil || current.GetID() == "" || current.TenureID != tenure.GetID() {
		return j.Period.Open(ctx, tenure.GroupID)
	}
	if current.State == int32(constants.StateActive) {
		return current, nil
	}
	next, err := j.Period.OpenNext(ctx, current)
	if errors.Is(err, ErrTenureExhausted) {
		// The resumed tenure has no periods left: it ends, and the group's
		// next tenure is enrolled on a later run.
		if closeErr := j.Tenure.Close(ctx, tenure.GetID()); closeErr != nil {
			return nil, errors.Join(err, closeErr)
		}
	}
	return next, err
}

// welcome tells every saving member and leader the group is running, once
// per tenure.
func (j *StawiJobs) welcome(
	ctx context.Context,
	group *identityv1.ClientGroupObject,
	tenure *models.Tenure,
	period *models.Period,
) error {
	memberships, err := j.Members.GetByGroupID(ctx, group.GetId())
	if err != nil {
		return err
	}
	vars := map[string]any{
		messages.VarGroupName: group.GetName(),
		messages.VarAmount:    messages.FormatAmount(group.GetCurrencyCode(), group.GetSavingAmount()),
		messages.VarCurrency:  group.GetCurrencyCode(),
		messages.VarDueDate:   messages.FormatDate(period.EndDate),
	}
	var failures []error
	for _, m := range memberships {
		if !savingMember(m) && !groupLeader(m) {
			continue
		}
		key := "welcome:" + tenure.GetID() + ":" + m.GetId()
		if sendErr := j.sendOnce(ctx, key, group.GetId(), notify.Message{
			Template:  messages.GroupWelcome,
			Recipient: notify.ToProfile(m.GetProfileId()),
			Vars:      vars,
		}); sendErr != nil {
			failures = append(failures, sendErr)
		}
	}
	return errors.Join(failures...)
}

// checkGroupStates compares up to batch running tenures with their group in
// identity and stops those whose group no longer runs. Each tenure is
// checked at most once per groupCheckInterval.
func (j *StawiJobs) checkGroupStates(ctx context.Context, batch int) (int, bool, error) {
	now := j.now().UTC()
	tenures, err := j.Tenures.ListDueForCheck(listCtx(ctx), now.Add(-groupCheckInterval), batch)
	if err != nil {
		return 0, false, fmt.Errorf("tenures due for check: %w", err)
	}
	stopped := 0
	for _, t := range tenures {
		actCtx := j.actIn(ctx, &t.BaseModel)
		group, getErr := j.Directory.Get(actCtx, t.GroupID)
		switch {
		case getErr != nil:
			util.Log(ctx).WithError(getErr).WithField(fieldGroupID, t.GroupID).
				Warn("group state not checked; the next check retries")
		case groupStopped(group):
			t.State = int32(constants.StateInactive)
			stopped++
		}
		t.CheckedAt = &now
		if updErr := j.updateTenure(actCtx, t); updErr != nil {
			util.Log(ctx).WithError(updErr).WithField(fieldGroupID, t.GroupID).
				Warn("could not record the group check")
		}
	}
	return stopped, len(tenures) == batch, nil
}

// groupStopped reports whether identity holds the group deactivated or
// removed, so it opens no new period.
func groupStopped(group *identityv1.ClientGroupObject) bool {
	switch group.GetState() { //nolint:exhaustive // a created or checked group has no tenure yet
	case commonv1.STATE_INACTIVE, commonv1.STATE_DELETED:
		return true
	default:
		return false
	}
}

// groupLeader reports whether a live membership leads the group.
func groupLeader(membership *identityv1.MembershipObject) bool {
	if membership.GetMembershipType() != membershipTypeRegistrar {
		return false
	}
	return liveState(membership.GetState())
}

// updateTenure writes the tenure under its version.
func (j *StawiJobs) updateTenure(ctx context.Context, tenure *models.Tenure) error {
	rows, err := j.Tenures.Update(ctx, tenure)
	if err != nil {
		return err
	}
	if rows == 0 {
		return apperrors.NewError(apperrors.Conflict, "the tenure was changed by another request")
	}
	return nil
}

// isConflict reports an error that says another request already did it.
func isConflict(err error) bool {
	var appErr *apperrors.Error
	return errors.As(err, &appErr) && appErr.ErrorCode() == apperrors.Conflict
}
