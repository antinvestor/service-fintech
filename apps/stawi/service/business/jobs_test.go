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
	"slices"
	"sort"
	"sync"
	"testing"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	stawiv1 "github.com/antinvestor/service-fintech/gen/go/stawi/protocolbuffers/go/stawi/v1"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
	stawiproduct "github.com/antinvestor/service-fintech/products/stawi"
)

// ---------------------------------------------------------------------------
// In-memory repositories with the uniqueness and versioning the database
// enforces.
// ---------------------------------------------------------------------------

type memTenures struct {
	repository.TenureRepository

	mu   sync.Mutex
	seq  int
	rows map[string]*models.Tenure
	at   map[string]int // creation order
}

func newMemTenures() *memTenures {
	return &memTenures{rows: map[string]*models.Tenure{}, at: map[string]int{}}
}

func cloneTenure(t *models.Tenure) *models.Tenure { c := *t; return &c }

func (r *memTenures) sorted(keep func(*models.Tenure) bool) []*models.Tenure {
	var out []*models.Tenure
	for _, t := range r.rows {
		if keep(t) {
			out = append(out, cloneTenure(t))
		}
	}
	sort.Slice(out, func(i, j int) bool { return r.at[out[i].GetID()] < r.at[out[j].GetID()] })
	return out
}

func (r *memTenures) GetByID(_ context.Context, id string) (*models.Tenure, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	t, ok := r.rows[id]
	if !ok {
		return nil, gorm.ErrRecordNotFound
	}
	return cloneTenure(t), nil
}

func (r *memTenures) latest(groupID string) (*models.Tenure, error) {
	all := r.sorted(func(t *models.Tenure) bool {
		return t.GroupID == groupID && t.State != int32(constants.StateDeleted)
	})
	if len(all) == 0 {
		return &models.Tenure{}, gorm.ErrRecordNotFound
	}
	return all[len(all)-1], nil
}

func (r *memTenures) GetActiveByGroupID(_ context.Context, groupID string) (*models.Tenure, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.latest(groupID)
}

func (r *memTenures) GetLastestBy(_ context.Context, q map[string]any) (*models.Tenure, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	groupID, _ := q[fieldGroupID].(string)
	return r.latest(groupID)
}

func (r *memTenures) Create(_ context.Context, t *models.Tenure) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, existing := range r.rows {
		if existing.GroupID == t.GroupID && existing.State == int32(constants.StateActive) &&
			t.State == int32(constants.StateActive) {
			return gorm.ErrDuplicatedKey
		}
	}
	r.seq++
	t.Version = 1
	r.rows[t.GetID()] = cloneTenure(t)
	r.at[t.GetID()] = r.seq
	return nil
}

func (r *memTenures) Update(_ context.Context, t *models.Tenure, _ ...string) (int64, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	stored, ok := r.rows[t.GetID()]
	if !ok || stored.Version != t.Version {
		return 0, nil
	}
	t.Version++
	r.rows[t.GetID()] = cloneTenure(t)
	return 1, nil
}

func (r *memTenures) LatestByGroupIDs(_ context.Context, ids []string) (map[string]*models.Tenure, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	out := map[string]*models.Tenure{}
	for _, id := range ids {
		if t, err := r.latest(id); err == nil {
			out[id] = t
		}
	}
	return out, nil
}

func (r *memTenures) ListPendingSetup(_ context.Context, now time.Time, limit int) ([]*models.Tenure, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	return limitTo(r.sorted(func(t *models.Tenure) bool {
		return t.State == int32(constants.StateActive) && !t.Welcomed &&
			(t.SetupRetryAt == nil || !t.SetupRetryAt.After(now))
	}), limit), nil
}

func (r *memTenures) ListDueForCheck(_ context.Context, before time.Time, limit int) ([]*models.Tenure, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	return limitTo(r.sorted(func(t *models.Tenure) bool {
		return t.State == int32(constants.StateActive) && (t.CheckedAt == nil || t.CheckedAt.Before(before))
	}), limit), nil
}

func (r *memTenures) forGroup(groupID string) []*models.Tenure {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.sorted(func(t *models.Tenure) bool { return t.GroupID == groupID })
}

type memPeriods struct {
	repository.PeriodRepository

	mu   sync.Mutex
	seq  int
	rows map[string]*models.Period
	at   map[string]int
}

func newMemPeriods() *memPeriods {
	return &memPeriods{rows: map[string]*models.Period{}, at: map[string]int{}}
}

func clonePeriod(p *models.Period) *models.Period { c := *p; return &c }

func (r *memPeriods) sorted(keep func(*models.Period) bool) []*models.Period {
	var out []*models.Period
	for _, p := range r.rows {
		if keep(p) {
			out = append(out, clonePeriod(p))
		}
	}
	sort.Slice(out, func(i, j int) bool { return r.at[out[i].GetID()] < r.at[out[j].GetID()] })
	return out
}

func (r *memPeriods) GetByID(_ context.Context, id string) (*models.Period, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	p, ok := r.rows[id]
	if !ok {
		return nil, gorm.ErrRecordNotFound
	}
	return clonePeriod(p), nil
}

func (r *memPeriods) lastWhere(keep func(*models.Period) bool) (*models.Period, error) {
	all := r.sorted(keep)
	if len(all) == 0 {
		return &models.Period{}, gorm.ErrRecordNotFound
	}
	return all[len(all)-1], nil
}

func (r *memPeriods) GetCurrentByGroupID(_ context.Context, groupID string) (*models.Period, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.lastWhere(func(p *models.Period) bool {
		return p.GroupID == groupID && p.State != int32(constants.StateDeleted)
	})
}

func (r *memPeriods) GetLastestBy(_ context.Context, q map[string]any) (*models.Period, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	tenureID, _ := q["tenure_id"].(string)
	return r.lastWhere(func(p *models.Period) bool { return p.TenureID == tenureID })
}

func (r *memPeriods) GetByParentID(_ context.Context, parentID string) (*models.Period, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.lastWhere(func(p *models.Period) bool { return p.ParentPeriodID == parentID })
}

func (r *memPeriods) Create(_ context.Context, p *models.Period) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, existing := range r.rows {
		if (p.ParentPeriodID != "" && existing.ParentPeriodID == p.ParentPeriodID) ||
			(existing.TenureID == p.TenureID && existing.Position == p.Position) {
			return gorm.ErrDuplicatedKey
		}
	}
	r.seq++
	p.Version = 1
	r.rows[p.GetID()] = clonePeriod(p)
	r.at[p.GetID()] = r.seq
	return nil
}

func (r *memPeriods) Update(_ context.Context, p *models.Period, _ ...string) (int64, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	stored, ok := r.rows[p.GetID()]
	if !ok || stored.Version != p.Version {
		return 0, nil
	}
	p.Version++
	r.rows[p.GetID()] = clonePeriod(p)
	return 1, nil
}

func (r *memPeriods) ListDueToClose(_ context.Context, now time.Time, limit int) ([]*models.Period, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	return limitTo(r.sorted(func(p *models.Period) bool {
		return p.State == int32(constants.StateActive) && p.EndDate != nil && !p.EndDate.After(now) &&
			(p.CloseRetryAt == nil || !p.CloseRetryAt.After(now))
	}), limit), nil
}

func (r *memPeriods) ListDueForReminder(_ context.Context, now time.Time, limit int) ([]*models.Period, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	return limitTo(r.sorted(func(p *models.Period) bool {
		return p.State == int32(constants.StateActive) && p.EndDate != nil && p.EndDate.After(now) &&
			p.NextReminderAt != nil && !p.NextReminderAt.After(now)
	}), limit), nil
}

func (r *memPeriods) forGroup(groupID string) []*models.Period {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.sorted(func(p *models.Period) bool { return p.GroupID == groupID })
}

func limitTo[T any](items []T, limit int) []T {
	if limit > 0 && len(items) > limit {
		return items[:limit]
	}
	return items
}

type memNotices struct {
	mu   sync.Mutex
	keys map[string]bool
}

func (n *memNotices) Claim(_ context.Context, notice *models.Notice) (bool, error) {
	n.mu.Lock()
	defer n.mu.Unlock()
	if n.keys[notice.Key] {
		return false, nil
	}
	n.keys[notice.Key] = true
	return true, nil
}

func (n *memNotices) Release(_ context.Context, key string) error {
	n.mu.Lock()
	defer n.mu.Unlock()
	delete(n.keys, key)
	return nil
}

// ---------------------------------------------------------------------------
// Collaborator fakes
// ---------------------------------------------------------------------------

type fakeDirectory struct {
	groups     map[string]*identityv1.ClientGroupObject
	partitions map[string]string
}

func (d *fakeDirectory) ActiveGroups(context.Context) ([]*identityv1.ClientGroupObject, error) {
	var out []*identityv1.ClientGroupObject
	for _, g := range d.groups {
		if groupActive(g) {
			out = append(out, g)
		}
	}
	sort.Slice(out, func(i, j int) bool { return out[i].GetId() < out[j].GetId() })
	return out, nil
}

func (d *fakeDirectory) Get(_ context.Context, id string) (*identityv1.ClientGroupObject, error) {
	g, ok := d.groups[id]
	if !ok {
		return nil, connect.NewError(connect.CodeNotFound, "group not found")
	}
	return g, nil
}

func (d *fakeDirectory) PartitionOf(_ context.Context, g *identityv1.ClientGroupObject) (string, error) {
	if p := d.partitions[g.GetId()]; p != "" {
		return p, nil
	}
	return "", errors.New("no branch")
}

type fakeGroupSetup struct {
	ledger, lender int
	lenderErr      error
}

func (f *fakeGroupSetup) SetupLedgerAccounts(context.Context, string) error {
	f.ledger++
	return nil
}

func (f *fakeGroupSetup) RegisterWithLender(context.Context, string) error {
	f.lender++
	return f.lenderErr
}

// fakeObligations stands in for operations: raising is idempotent and
// reports who still owes, closing charges the late fine once per period.
type fakeObligations struct {
	mu        sync.Mutex
	raises    map[string]int
	closes    map[string]int
	owing     map[string][]map[string]any
	statement []map[string]any
	closeErr  error
}

func (f *fakeObligations) Raise(_ context.Context, _, periodID string) (map[string]any, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.raises[periodID]++
	return map[string]any{fieldMembers: f.owing[periodID]}, nil
}

func (f *fakeObligations) Close(_ context.Context, _, periodID string) (map[string]any, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.closeErr != nil {
		return nil, f.closeErr
	}
	f.closes[periodID]++
	return map[string]any{fieldMembers: f.statement}, nil
}

type fakeLoanWindow struct {
	eligible bool
	opened   []string
}

func (f *fakeLoanWindow) Evaluate(context.Context, string) (map[string]any, error) {
	return map[string]any{fieldEligible: f.eligible}, nil
}

func (f *fakeLoanWindow) Open(_ context.Context, groupID string) (*models.LoanWindow, error) {
	f.opened = append(f.opened, groupID)
	return &models.LoanWindow{GroupID: groupID}, nil
}

// ---------------------------------------------------------------------------
// Fixture
// ---------------------------------------------------------------------------

const (
	jobTenantID    = "tenant-1"
	jobPartitionID = "partition-branch-1"
)

type jobFixture struct {
	jobs        *StawiJobs
	tenures     *memTenures
	periods     *memPeriods
	notices     *memNotices
	sender      *recordingSender
	directory   *fakeDirectory
	setup       *fakeGroupSetup
	obligations *fakeObligations
	window      *fakeLoanWindow
	group       *identityv1.ClientGroupObject
	now         time.Time
}

func newJobFixture(t *testing.T) *jobFixture {
	t.Helper()
	group := &identityv1.ClientGroupObject{
		Id: "group-1", Name: "Umoja Chama", CurrencyCode: "KES", SavingAmount: 50_000,
		State: commonv1.STATE_ACTIVE, GroupType: 2, BranchId: "branch-1",
	}
	product := stawiproduct.ProductConfig{
		GroupLifeDuration: 3, ReminderOffsetsHours: []int{24, 72}, GroupTypes: []int32{2},
	}
	tenures, periods := newMemTenures(), newMemPeriods()
	identity := &fakeIdentity{groups: map[string]*identityv1.ClientGroupObject{group.GetId(): group}}
	directory := &fakeDirectory{
		groups:     map[string]*identityv1.ClientGroupObject{group.GetId(): group},
		partitions: map[string]string{group.GetId(): jobPartitionID},
	}
	setup := &fakeGroupSetup{}
	obligations := &fakeObligations{
		raises: map[string]int{},
		closes: map[string]int{},
		owing:  map[string][]map[string]any{},
	}
	window := &fakeLoanWindow{}
	notices := &memNotices{keys: map[string]bool{}}
	sender := &recordingSender{}
	active := int32(commonv1.STATE_ACTIVE)

	jobs := NewStawiJobs(JobDeps{
		Product:   product,
		Directory: directory,
		Groups:    setup,
		Members: &fakeMembers{members: []*identityv1.MembershipObject{
			membership("m1", membershipTypeMember, active),
			membership("m2", membershipTypeMember, active),
			membership("leader", membershipTypeRegistrar, active),
			membership("agent", 2, active),
		}},
		Tenures:    tenures,
		Periods:    periods,
		Tenure:     NewTenureBusiness(context.Background(), product, identity, tenures, periods),
		Period:     NewPeriodBusiness(context.Background(), product, tenures, periods),
		Obligation: obligations,
		LoanWindow: window,
		Notices:    notices,
		Notifier:   notify.NewWithSender(sender, messages.Registry()),
		Subject:    "service_stawi",
	})
	now := time.Now().UTC()
	jobs.now = func() time.Time { return now }

	return &jobFixture{
		jobs: jobs, tenures: tenures, periods: periods, notices: notices, sender: sender,
		directory: directory, setup: setup, obligations: obligations, window: window, group: group, now: now,
	}
}

// schedulerCtx is the context of a trustage call: an internal service
// acting for one tenant.
func schedulerCtx(t *testing.T) context.Context {
	t.Helper()
	claims := &security.AuthenticationClaims{
		TenantID: jobTenantID,
		Roles:    []string{security.ConstantSystemInternalRole},
	}
	claims.Subject = "service_trustage"
	return claims.ClaimsToContext(t.Context())
}

func (f *jobFixture) run(t *testing.T, job stawiv1.StawiJob) (int, bool) {
	t.Helper()
	processed, more, err := f.jobs.Run(schedulerCtx(t), job, 0)
	require.NoError(t, err)
	return processed, more
}

// runningPeriod stores a running tenure and its current period ending at
// end, as a finished setup leaves them.
func (f *jobFixture) runningPeriod(t *testing.T, position int32, end time.Time) *models.Period {
	t.Helper()
	ctx := t.Context()
	tenure := &models.Tenure{GroupID: f.group.GetId(), Duration: 3, Position: 1, Welcomed: true,
		State: int32(constants.StateActive)}
	tenure.ID = "tenure-1"
	tenure.TenantID, tenure.PartitionID = jobTenantID, jobPartitionID
	require.NoError(t, f.tenures.Create(ctx, tenure))

	start := end.AddDate(0, 0, -7)
	period := &models.Period{GroupID: f.group.GetId(), TenureID: tenure.GetID(), StartDate: &start, EndDate: &end,
		PeriodType: int32(models.PeriodTypeWeekly), Position: position, State: int32(constants.StateActive),
		NextReminderAt: firstReminderAt(end, f.jobs.reminders)}
	period.ID = "period-1"
	period.CopyPartitionInfo(&tenure.BaseModel)
	require.NoError(t, f.periods.Create(ctx, period))
	return period
}

func count(templates []string, template string) int {
	n := 0
	for _, tpl := range templates {
		if tpl == template {
			n++
		}
	}
	return n
}

// ---------------------------------------------------------------------------
// Internal-only
// ---------------------------------------------------------------------------

// Every job reads across tenants, so only an internal service may run one.
func TestJobsRefuseCallersThatAreNotInternal(t *testing.T) {
	f := newJobFixture(t)
	member := &security.AuthenticationClaims{
		TenantID:    jobTenantID,
		PartitionID: jobPartitionID,
		Roles:       []string{"user"},
	}
	member.Subject = "profile-m1"

	for _, job := range []stawiv1.StawiJob{
		stawiv1.StawiJob_STAWI_JOB_GROUP_LIFECYCLE,
		stawiv1.StawiJob_STAWI_JOB_CLOSE_DUE_PERIODS,
		stawiv1.StawiJob_STAWI_JOB_SEND_REMINDERS,
		stawiv1.StawiJob_STAWI_JOB_LOAN_OFFERS,
	} {
		_, _, err := f.jobs.Run(member.ClaimsToContext(t.Context()), job, 0)
		require.ErrorIs(t, err, ErrJobCallerNotInternal, job.String())
		_, _, err = f.jobs.Run(t.Context(), job, 0)
		require.ErrorIs(t, err, ErrJobCallerNotInternal, "no caller at all: %s", job.String())
	}
	_, _, err := f.jobs.Run(schedulerCtx(t), stawiv1.StawiJob_STAWI_JOB_UNSPECIFIED, 0)
	require.ErrorIs(t, err, ErrUnknownJob)
	assert.Empty(t, f.tenures.forGroup(f.group.GetId()))
}

// ---------------------------------------------------------------------------
// GROUP_LIFECYCLE
// ---------------------------------------------------------------------------

// An active group is set up once: one tenure in its branch's partition, one
// first period with its obligations, one welcome per member and leader,
// however often the job runs.
func TestGroupLifecycle_SetsUpAnActiveGroupOnce(t *testing.T) {
	f := newJobFixture(t)

	processed, more := f.run(t, stawiv1.StawiJob_STAWI_JOB_GROUP_LIFECYCLE)
	assert.Equal(t, 2, processed, "enrolled and set up")
	assert.False(t, more)
	for range 2 {
		f.run(t, stawiv1.StawiJob_STAWI_JOB_GROUP_LIFECYCLE)
	}

	tenures := f.tenures.forGroup(f.group.GetId())
	require.Len(t, tenures, 1)
	assert.True(t, tenures[0].Welcomed)
	assert.Equal(t, jobPartitionID, tenures[0].PartitionID, "the group's records live in its branch's partition")
	assert.Equal(t, jobTenantID, tenures[0].TenantID)

	periods := f.periods.forGroup(f.group.GetId())
	require.Len(t, periods, 1)
	assert.Equal(t, int32(1), periods[0].Position)
	assert.Equal(t, jobPartitionID, periods[0].PartitionID)
	require.NotNil(t, periods[0].NextReminderAt, "the period's first reminder is scheduled")
	assert.Equal(t, periods[0].EndDate.Add(-72*time.Hour), *periods[0].NextReminderAt)

	assert.Equal(t, 1, f.obligations.raises[periods[0].GetID()])
	assert.Equal(t, 1, f.setup.ledger)
	assert.Equal(t, 1, f.setup.lender, "members are registered with the lender once")
	assert.Equal(t, 3, count(f.sender.templates(), messages.GroupWelcome), "two members and the leader")
}

// A setup that fails part way is held off, then resumed without repeating
// what it already did.
func TestGroupLifecycle_ResumesAFailedSetup(t *testing.T) {
	f := newJobFixture(t)
	f.setup.lenderErr = connect.NewError(connect.CodeUnavailable, "field unavailable")

	f.run(t, stawiv1.StawiJob_STAWI_JOB_GROUP_LIFECYCLE)
	tenures := f.tenures.forGroup(f.group.GetId())
	require.Len(t, tenures, 1)
	assert.False(t, tenures[0].Welcomed)
	require.NotNil(t, tenures[0].SetupRetryAt)
	assert.Empty(t, f.periods.forGroup(f.group.GetId()))

	f.setup.lenderErr = nil
	f.run(t, stawiv1.StawiJob_STAWI_JOB_GROUP_LIFECYCLE)
	assert.Equal(t, 1, f.setup.lender, "held off until its retry time")

	later := f.now.Add(jobRetryAfter)
	f.jobs.now = func() time.Time { return later }
	f.run(t, stawiv1.StawiJob_STAWI_JOB_GROUP_LIFECYCLE)
	tenures = f.tenures.forGroup(f.group.GetId())
	require.Len(t, tenures, 1, "the retry does not open a second tenure")
	assert.True(t, tenures[0].Welcomed)
	assert.Len(t, f.periods.forGroup(f.group.GetId()), 1)
	assert.Equal(t, 3, count(f.sender.templates(), messages.GroupWelcome))
}

// A group identity deactivates stops: its tenure no longer opens periods,
// and the period running now is not closed early.
func TestGroupLifecycle_StopsAGroupIdentityDeactivated(t *testing.T) {
	f := newJobFixture(t)
	period := f.runningPeriod(t, 1, f.now.Add(48*time.Hour))
	f.group.State = commonv1.STATE_INACTIVE

	f.run(t, stawiv1.StawiJob_STAWI_JOB_GROUP_LIFECYCLE)

	tenures := f.tenures.forGroup(f.group.GetId())
	require.Len(t, tenures, 1)
	assert.Equal(t, int32(constants.StateInactive), tenures[0].State)
	stored, err := f.periods.GetByID(t.Context(), period.GetID())
	require.NoError(t, err)
	assert.Equal(t, int32(constants.StateActive), stored.State, "the running period runs to its end")
	assert.Zero(t, f.obligations.closes[period.GetID()], "no fine before the period ends")

	// Restored, the group's tenure resumes rather than a new one opening.
	f.group.State = commonv1.STATE_ACTIVE
	f.run(t, stawiv1.StawiJob_STAWI_JOB_GROUP_LIFECYCLE)
	tenures = f.tenures.forGroup(f.group.GetId())
	require.Len(t, tenures, 1)
	assert.Equal(t, int32(constants.StateActive), tenures[0].State)
	assert.True(t, tenures[0].Welcomed)
	assert.Len(t, f.periods.forGroup(f.group.GetId()), 1, "the running period carries on")
}

// ---------------------------------------------------------------------------
// CLOSE_DUE_PERIODS
// ---------------------------------------------------------------------------

// A due period is closed once: the late fine is charged once, one next
// period opens with its obligations raised, the loan window opens when due,
// and every member gets their statement once, however often the job runs.
func TestCloseDuePeriods_ClosesOnceAndOpensOneNextPeriod(t *testing.T) {
	f := newJobFixture(t)
	f.window.eligible = true
	period := f.runningPeriod(t, 1, f.now.Add(-time.Hour))
	f.obligations.statement = []map[string]any{
		{
			fieldMembershipID: "m1",
			fieldProfileID:    "profile-m1",
			"savings_total":   int64(50_000),
			"outstanding":     int64(0),
		},
		{
			fieldMembershipID: "m2",
			fieldProfileID:    "profile-m2",
			"savings_total":   int64(0),
			"outstanding":     int64(55_000),
		},
	}

	processed, more := f.run(t, stawiv1.StawiJob_STAWI_JOB_CLOSE_DUE_PERIODS)
	assert.Equal(t, 1, processed)
	assert.False(t, more)
	f.run(t, stawiv1.StawiJob_STAWI_JOB_CLOSE_DUE_PERIODS)

	periods := f.periods.forGroup(f.group.GetId())
	require.Len(t, periods, 2, "exactly one next period")
	closed, next := periods[0], periods[1]
	assert.Equal(t, int32(constants.StateShutdown), closed.State)
	assert.Equal(t, *period.EndDate, *closed.EndDate, "a late close keeps the scheduled end")
	assert.Equal(t, int32(constants.StateActive), next.State)
	assert.Equal(t, period.GetID(), next.ParentPeriodID)
	assert.Equal(t, *period.EndDate, *next.StartDate, "the next period starts on schedule")
	assert.Equal(t, jobPartitionID, next.PartitionID)

	assert.Equal(t, 1, f.obligations.closes[period.GetID()], "the late fine is charged once")
	assert.Equal(t, 1, f.obligations.raises[next.GetID()], "the next period's obligations are raised")
	assert.Equal(t, []string{f.group.GetId()}, f.window.opened)
	assert.Equal(t, 2, count(f.sender.templates(), messages.GroupPeriodSummary))
}

// A close that fails part way resumes on the next run without opening a
// second period or sending a second statement.
func TestCloseDuePeriods_ResumesWithoutRepeating(t *testing.T) {
	f := newJobFixture(t)
	period := f.runningPeriod(t, 1, f.now.Add(-time.Hour))
	f.obligations.statement = []map[string]any{
		{
			fieldMembershipID: "m1",
			fieldProfileID:    "profile-m1",
			"savings_total":   int64(50_000),
			"outstanding":     int64(0),
		},
	}
	f.sender.failNext = 1

	f.run(t, stawiv1.StawiJob_STAWI_JOB_CLOSE_DUE_PERIODS)
	stored, err := f.periods.GetByID(t.Context(), period.GetID())
	require.NoError(t, err)
	assert.Equal(t, int32(constants.StateActive), stored.State, "not closed while a statement is unsent")
	require.NotNil(t, stored.CloseRetryAt)

	later := f.now.Add(jobRetryAfter)
	f.jobs.now = func() time.Time { return later }
	f.run(t, stawiv1.StawiJob_STAWI_JOB_CLOSE_DUE_PERIODS)

	periods := f.periods.forGroup(f.group.GetId())
	require.Len(t, periods, 2, "the retry reuses the period it opened")
	assert.Equal(t, int32(constants.StateShutdown), periods[0].State)
	assert.Equal(t, 1, count(f.sender.templates(), messages.GroupPeriodSummary), "one statement after the failed send")
}

// A period still running is left alone.
func TestCloseDuePeriods_LeavesARunningPeriodAlone(t *testing.T) {
	f := newJobFixture(t)
	period := f.runningPeriod(t, 1, f.now.Add(time.Hour))

	processed, _ := f.run(t, stawiv1.StawiJob_STAWI_JOB_CLOSE_DUE_PERIODS)
	assert.Zero(t, processed)
	assert.Zero(t, f.obligations.closes[period.GetID()])
	assert.Len(t, f.periods.forGroup(f.group.GetId()), 1)
	assert.Empty(t, f.sender.templates())
}

// The last period of a tenure closes with the tenure; the group's next
// tenure is enrolled by the lifecycle job.
func TestCloseDuePeriods_LastPeriodEndsTheTenure(t *testing.T) {
	f := newJobFixture(t)
	f.runningPeriod(t, 3, f.now.Add(-time.Hour))

	f.run(t, stawiv1.StawiJob_STAWI_JOB_CLOSE_DUE_PERIODS)

	periods := f.periods.forGroup(f.group.GetId())
	require.Len(t, periods, 1, "no period past the tenure's duration")
	assert.Equal(t, int32(constants.StateShutdown), periods[0].State)
	tenures := f.tenures.forGroup(f.group.GetId())
	assert.Equal(t, int32(constants.StateShutdown), tenures[0].State)

	f.run(t, stawiv1.StawiJob_STAWI_JOB_GROUP_LIFECYCLE)
	tenures = f.tenures.forGroup(f.group.GetId())
	require.Len(t, tenures, 2)
	assert.Equal(t, int32(2), tenures[1].Position)
	assert.True(t, tenures[1].Welcomed)
}

// A group identity stopped is fined for the period that ended but gets no
// next period.
func TestCloseDuePeriods_StoppedGroupGetsNoNextPeriod(t *testing.T) {
	f := newJobFixture(t)
	period := f.runningPeriod(t, 1, f.now.Add(-time.Hour))
	f.group.State = commonv1.STATE_DELETED

	f.run(t, stawiv1.StawiJob_STAWI_JOB_CLOSE_DUE_PERIODS)

	assert.Equal(t, 1, f.obligations.closes[period.GetID()])
	periods := f.periods.forGroup(f.group.GetId())
	require.Len(t, periods, 1)
	assert.Equal(t, int32(constants.StateShutdown), periods[0].State)
	assert.Equal(t, int32(constants.StateInactive), f.tenures.forGroup(f.group.GetId())[0].State)
}

// ---------------------------------------------------------------------------
// SEND_REMINDERS
// ---------------------------------------------------------------------------

// Members still owing are reminded once per offset, and the leader is told
// who is behind, however often the job runs.
func TestSendReminders_OncePerOffset(t *testing.T) {
	f := newJobFixture(t)
	end := f.now.Add(60 * time.Hour)
	period := f.runningPeriod(t, 1, end)
	f.obligations.owing[period.GetID()] = []map[string]any{
		{fieldMembershipID: "m2", fieldProfileID: "profile-m2", "amount_outstanding": int64(50_000)},
	}

	processed, _ := f.run(t, stawiv1.StawiJob_STAWI_JOB_SEND_REMINDERS)
	assert.Equal(t, 1, processed)
	f.run(t, stawiv1.StawiJob_STAWI_JOB_SEND_REMINDERS)
	assert.Equal(t, 1, count(f.sender.templates(), messages.GroupSavingsReminder))
	assert.Equal(t, 1, count(f.sender.templates(), messages.GroupLeaderArrears))
	stored, err := f.periods.GetByID(t.Context(), period.GetID())
	require.NoError(t, err)
	require.NotNil(t, stored.NextReminderAt)
	assert.Equal(t, end.Add(-24*time.Hour), *stored.NextReminderAt, "the 24h reminder is next")

	// The next offset sends once more, then reminders stop.
	dayBefore := end.Add(-20 * time.Hour)
	f.jobs.now = func() time.Time { return dayBefore }
	f.run(t, stawiv1.StawiJob_STAWI_JOB_SEND_REMINDERS)
	f.run(t, stawiv1.StawiJob_STAWI_JOB_SEND_REMINDERS)
	assert.Equal(t, 2, count(f.sender.templates(), messages.GroupSavingsReminder))
	assert.Equal(t, 2, count(f.sender.templates(), messages.GroupLeaderArrears))
	stored, err = f.periods.GetByID(t.Context(), period.GetID())
	require.NoError(t, err)
	assert.Nil(t, stored.NextReminderAt)

	for _, n := range f.sender.sent {
		assert.NotEmpty(t, n.GetRecipient().GetProfileId(), "members are notified by profile id")
	}
}

// A period ahead of its first reminder offset is not reminded.
func TestSendReminders_NotBeforeTheFirstOffset(t *testing.T) {
	f := newJobFixture(t)
	period := f.runningPeriod(t, 1, f.now.Add(5*24*time.Hour))
	f.obligations.owing[period.GetID()] = []map[string]any{
		{fieldMembershipID: "m2", fieldProfileID: "profile-m2", "amount_outstanding": int64(50_000)},
	}

	processed, _ := f.run(t, stawiv1.StawiJob_STAWI_JOB_SEND_REMINDERS)
	assert.Zero(t, processed)
	assert.Empty(t, f.sender.templates())
}

func TestReachedOffsetPicksTheTightestOffsetDue(t *testing.T) {
	offsets := []time.Duration{72 * time.Hour, 24 * time.Hour}
	end := time.Date(2026, 11, 2, 0, 0, 0, 0, time.UTC)
	assert.Zero(t, reachedOffset(end, end.Add(-80*time.Hour), offsets))
	assert.Equal(t, 72*time.Hour, reachedOffset(end, end.Add(-50*time.Hour), offsets))
	assert.Equal(t, 24*time.Hour, reachedOffset(end, end.Add(-2*time.Hour), offsets),
		"a run that missed the first offset sends only the tightest")
	assert.Nil(t, nextReminderAt(end, 24*time.Hour, offsets))
	next := nextReminderAt(end, 72*time.Hour, offsets)
	require.NotNil(t, next)
	assert.Equal(t, end.Add(-24*time.Hour), *next)
}

// ---------------------------------------------------------------------------
// LOAN_OFFERS
// ---------------------------------------------------------------------------

// The offers job resumes accepted offers, closes expired ones and retries a
// failed loan cancel, each once.
func TestLoanOffersJob_ResumesExpiresAndRetriesCancels(t *testing.T) {
	of := newOfferFixture(t)
	jobs := NewStawiJobs(JobDeps{LoanOffers: of.biz, Subject: "service_stawi"})
	jobs.now = func() time.Time { return of.now }

	// An accepted offer whose payout failed transiently.
	pending := of.openOffer()
	of.lender.failOnce["disburse"] = connect.NewError(connect.CodeUnavailable, "operations unavailable")
	_, err := of.accept(t, pending.GetID())
	require.NoError(t, err)

	// An offer nobody answered.
	expired := of.openOffer()
	past := of.now.Add(-time.Hour)
	stored := of.repo.get(t, expired.GetID())
	stored.MembershipID = "m-other"
	stored.ExpiryDate = &past
	of.repo.put(stored)

	// A failed offer whose loan could not be cancelled.
	failed := of.repo.put(&models.LoanOffer{
		MembershipID: "m-failed", LoanWindowID: testWindow, PeriodID: testPeriod, Amount: 1, Currency: "KES",
		Response: int32(models.LoanOfferResponseAccept), OriginationStatus: models.OriginationFailed,
		LoanAccountID: "loan-failed", State: int32(constants.StateInactive),
	})
	setProp(failed, propLoanCancelled, false)
	of.repo.put(failed)

	later := of.now.Add(sweepRetryAfter)
	of.biz.now = func() time.Time { return later }
	jobs.now = func() time.Time { return later }

	processed, more, err := jobs.Run(schedulerCtx(t), stawiv1.StawiJob_STAWI_JOB_LOAN_OFFERS, 0)
	require.NoError(t, err)
	assert.Equal(t, 3, processed)
	assert.False(t, more)

	assert.Equal(t, models.OriginationDisbursed, of.repo.get(t, pending.GetID()).OriginationStatus)
	assert.Equal(t, "expired", propString(of.repo.get(t, expired.GetID()), propClosedReason))
	assert.Equal(t, true, of.repo.get(t, failed.GetID()).Properties[propLoanCancelled])
	assert.True(t, slices.Contains(of.lender.cancelled, "loan-failed"))

	processed, _, err = jobs.Run(schedulerCtx(t), stawiv1.StawiJob_STAWI_JOB_LOAN_OFFERS, 0)
	require.NoError(t, err)
	assert.Zero(t, processed, "nothing is left to do")
	assert.Len(t, of.lender.disbursements, 1, "one payout")
	assert.Len(t, of.lender.cancelled, 1)
}
