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
	"maps"
	"sync"
	"testing"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/structpb"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
	stawiproduct "github.com/antinvestor/service-fintech/products/stawi"
)

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

// memOfferRepo keeps offers in memory with the versioned-write behaviour of
// frame's repository and the (window, member) unique index.
type memOfferRepo struct {
	repository.LoanOfferRepository

	mu     sync.Mutex
	offers map[string]*models.LoanOffer
}

func newMemOfferRepo() *memOfferRepo {
	return &memOfferRepo{offers: map[string]*models.LoanOffer{}}
}

func cloneOffer(o *models.LoanOffer) *models.LoanOffer {
	c := *o
	if o.Properties != nil {
		c.Properties = data.JSONMap{}
		maps.Copy(c.Properties, o.Properties)
	}
	if o.ExpiryDate != nil {
		t := *o.ExpiryDate
		c.ExpiryDate = &t
	}
	return &c
}

func (r *memOfferRepo) GetByID(_ context.Context, id string) (*models.LoanOffer, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	o, ok := r.offers[id]
	if !ok {
		return nil, gorm.ErrRecordNotFound
	}
	return cloneOffer(o), nil
}

func (r *memOfferRepo) Create(_ context.Context, o *models.LoanOffer) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, existing := range r.offers {
		if existing.LoanWindowID != "" && existing.LoanWindowID == o.LoanWindowID &&
			existing.MembershipID == o.MembershipID {
			return gorm.ErrDuplicatedKey
		}
	}
	o.Version = 1
	r.offers[o.GetID()] = cloneOffer(o)
	return nil
}

func (r *memOfferRepo) Update(_ context.Context, o *models.LoanOffer, _ ...string) (int64, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	stored, ok := r.offers[o.GetID()]
	if !ok || stored.Version != o.Version {
		return 0, nil
	}
	o.Version++
	r.offers[o.GetID()] = cloneOffer(o)
	return 1, nil
}

func (r *memOfferRepo) GetByLoanWindowID(_ context.Context, windowID string) ([]*models.LoanOffer, error) {
	return r.filter(func(o *models.LoanOffer) bool { return o.LoanWindowID == windowID }, 0), nil
}

func (r *memOfferRepo) CountOpenElsewhere(_ context.Context, membershipID, exceptWindowID string) (int64, error) {
	return int64(len(r.filter(func(o *models.LoanOffer) bool {
		return o.MembershipID == membershipID && o.LoanWindowID != exceptWindowID &&
			o.State == int32(constants.StateActive)
	}, 0))), nil
}

func (r *memOfferRepo) ListPendingOrigination(_ context.Context, limit int) ([]*models.LoanOffer, error) {
	return r.filter(func(o *models.LoanOffer) bool {
		return o.OriginationStatus == models.OriginationPending
	}, limit), nil
}

func (r *memOfferRepo) ListExpired(_ context.Context, now time.Time, limit int) ([]*models.LoanOffer, error) {
	return r.filter(func(o *models.LoanOffer) bool {
		return o.State == int32(constants.StateActive) && o.Response == int32(models.LoanOfferResponseNone) &&
			o.ExpiryDate != nil && !o.ExpiryDate.After(now)
	}, limit), nil
}

func (r *memOfferRepo) filter(keep func(*models.LoanOffer) bool, limit int) []*models.LoanOffer {
	r.mu.Lock()
	defer r.mu.Unlock()
	var out []*models.LoanOffer
	for _, o := range r.offers {
		if keep(o) {
			out = append(out, cloneOffer(o))
		}
		if limit > 0 && len(out) == limit {
			break
		}
	}
	return out
}

func (r *memOfferRepo) put(o *models.LoanOffer) *models.LoanOffer {
	if o.GetID() == "" {
		o.GenID(context.Background())
	}
	r.mu.Lock()
	defer r.mu.Unlock()
	o.Version = 1
	r.offers[o.GetID()] = cloneOffer(o)
	return o
}

func (r *memOfferRepo) get(t *testing.T, id string) *models.LoanOffer {
	t.Helper()
	o, err := r.GetByID(context.Background(), id)
	require.NoError(t, err)
	return o
}

// fakeLender is the loans service: idempotent where loans is, counting every
// call so a test can tell a repeated step from a resumed one.
type fakeLender struct {
	mu sync.Mutex

	openLoans     map[string]bool
	requests      map[string]*loansv1.LoanRequestObject
	accounts      map[string]string // loan request id → loan account id
	disbursements map[string]*loansv1.DisbursementObject

	submits, approves, accountCreates, disburses int
	cancelled                                    []string

	// failOnce makes the named step fail once with the error; failAlways on
	// every call. approveLosesReply approves and then reports a failure, as
	// a timed-out reply would.
	failOnce          map[string]error
	failAlways        map[string]error
	approveLosesReply bool
}

func newFakeLender() *fakeLender {
	return &fakeLender{
		openLoans:     map[string]bool{},
		requests:      map[string]*loansv1.LoanRequestObject{},
		accounts:      map[string]string{},
		disbursements: map[string]*loansv1.DisbursementObject{},
		failOnce:      map[string]error{},
		failAlways:    map[string]error{},
	}
}

func (l *fakeLender) injected(step string) error {
	if err, ok := l.failAlways[step]; ok {
		return err
	}
	if err, ok := l.failOnce[step]; ok {
		delete(l.failOnce, step)
		return err
	}
	return nil
}

func (l *fakeLender) HasOpenLoan(_ context.Context, clientID string) (bool, error) {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.openLoans[clientID], nil
}

func (l *fakeLender) LoanRequestStatus(_ context.Context, id string) (loansv1.LoanRequestStatus, bool, error) {
	l.mu.Lock()
	defer l.mu.Unlock()
	req, ok := l.requests[id]
	if !ok {
		return loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_UNSPECIFIED, false, nil
	}
	return req.GetStatus(), true, nil
}

func (l *fakeLender) SubmitLoanRequest(_ context.Context, request *loansv1.LoanRequestObject) error {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.submits++
	if err := l.injected("submit"); err != nil {
		return err
	}
	l.requests[request.GetId()] = request
	return nil
}

func (l *fakeLender) ApproveLoanRequest(_ context.Context, id string) error {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.approves++
	if err := l.injected("approve"); err != nil {
		return err
	}
	req, ok := l.requests[id]
	if !ok || req.GetStatus() != loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED {
		return connect.NewError(connect.CodeFailedPrecondition, "loan request is not in submitted status")
	}
	req.Status = loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED
	if l.approveLosesReply {
		l.approveLosesReply = false
		return connect.NewError(connect.CodeDeadlineExceeded, "reply lost")
	}
	return nil
}

func (l *fakeLender) CreateLoanAccount(_ context.Context, loanRequestID string) (string, error) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.accountCreates++
	if err := l.injected("account"); err != nil {
		return "", err
	}
	if id, ok := l.accounts[loanRequestID]; ok {
		return id, nil
	}
	id := "loan-" + loanRequestID
	l.accounts[loanRequestID] = id
	return id, nil
}

func (l *fakeLender) Disburse(_ context.Context, loanAccountID, key string) (*loansv1.DisbursementObject, error) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.disburses++
	if err := l.injected("disburse"); err != nil {
		return nil, err
	}
	if d, ok := l.disbursements[key]; ok {
		return d, nil
	}
	d := &loansv1.DisbursementObject{
		Id:             "disb-" + loanAccountID,
		LoanAccountId:  loanAccountID,
		IdempotencyKey: key,
		Status:         loansv1.DisbursementStatus_DISBURSEMENT_STATUS_COMPLETED,
	}
	l.disbursements[key] = d
	return d, nil
}

func (l *fakeLender) CancelLoanAccount(_ context.Context, loanAccountID, _ string) error {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.cancelled = append(l.cancelled, loanAccountID)
	return nil
}

type fakeIdentity struct {
	identityv1connect.IdentityServiceClient
	memberships map[string]*identityv1.MembershipObject
}

func (f *fakeIdentity) MembershipGet(
	_ context.Context, req *identityv1.MembershipGetRequest,
) (*identityv1.MembershipGetResponse, error) {
	m, ok := f.memberships[req.GetId()]
	if !ok {
		return nil, connect.NewError(connect.CodeNotFound, "membership not found")
	}
	return &identityv1.MembershipGetResponse{Data: m}, nil
}

type fakeClients struct {
	fieldv1connect.FieldServiceClient
	profileByClient map[string]string
}

func (f *fakeClients) ClientGet(_ context.Context, req *fieldv1.ClientGetRequest) (*fieldv1.ClientGetResponse, error) {
	return &fieldv1.ClientGetResponse{Data: &fieldv1.ClientObject{
		Id: req.GetId(), ProfileId: f.profileByClient[req.GetId()],
	}}, nil
}

type fakeProfiles struct {
	profilev1connect.ProfileServiceClient
	payoutContact map[string]string // profile id → verified mobile contact id
}

func (f *fakeProfiles) GetById( //nolint:revive,staticcheck // the generated client's method name
	_ context.Context, req *profilev1.GetByIdRequest,
) (*profilev1.GetByIdResponse, error) {
	profile := &profilev1.ProfileObject{Id: req.GetId()}
	if contactID := f.payoutContact[req.GetId()]; contactID != "" {
		profile.Contacts = []*profilev1.ContactObject{{
			Id: contactID, Type: profilev1.ContactType_MSISDN, Verified: true, State: commonv1.STATE_ACTIVE,
		}}
	}
	return &profilev1.GetByIdResponse{Data: profile}, nil
}

type recordingSender struct {
	mu   sync.Mutex
	sent []*notificationv1.Notification
}

func (s *recordingSender) Send(_ context.Context, n *notificationv1.Notification) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.sent = append(s.sent, n)
	return nil
}

func (s *recordingSender) templates() []string {
	s.mu.Lock()
	defer s.mu.Unlock()
	out := make([]string, 0, len(s.sent))
	for _, n := range s.sent {
		out = append(out, n.GetTemplate())
	}
	return out
}

// ---------------------------------------------------------------------------
// Fixture
// ---------------------------------------------------------------------------

const (
	testGroupID = "group-1"
	testWindow  = "window-1"
	testPeriod  = "period-5"
)

type offerFixture struct {
	biz      *loanOfferBusiness
	repo     *memOfferRepo
	lender   *fakeLender
	sender   *recordingSender
	identity *fakeIdentity
	profiles *fakeProfiles
	members  *fakeMembers
	window   *models.LoanWindow
	group    *identityv1.ClientGroupObject
	now      time.Time
}

func member(
	t *testing.T,
	id, profileID, clientID string,
	memberType int32,
	state commonv1.STATE,
) *identityv1.MembershipObject {
	t.Helper()
	m := &identityv1.MembershipObject{
		Id: id, GroupId: testGroupID, ProfileId: profileID, MembershipType: memberType, State: state,
	}
	if clientID != "" {
		props, err := structpb.NewStruct(map[string]any{"client_id": clientID})
		require.NoError(t, err)
		m.Properties = props
	}
	return m
}

func newOfferFixture(t *testing.T) *offerFixture {
	t.Helper()
	now := time.Date(2026, 10, 26, 9, 0, 0, 0, time.UTC)
	end := now.Add(5 * 24 * time.Hour)

	period := &models.Period{GroupID: testGroupID, Position: 5, EndDate: &end, State: int32(constants.StateActive)}
	period.ID = testPeriod
	window := &models.LoanWindow{
		GroupID: testGroupID, PeriodID: testPeriod, PeriodicAmount: 100_000,
		LeverageHundredths: 200, Currency: "KES", State: int32(constants.StateActive),
	}
	window.ID = testWindow

	memberships := []*identityv1.MembershipObject{
		member(t, "m-ok", "p-ok", "c-ok", membershipTypeMember, commonv1.STATE_ACTIVE),
		member(t, "m-agent", "p-agent", "c-agent", 1, commonv1.STATE_ACTIVE),
		member(t, "m-inactive", "p-inactive", "c-inactive", membershipTypeMember, commonv1.STATE_INACTIVE),
		member(t, "m-noclient", "p-noclient", "", membershipTypeMember, commonv1.STATE_ACTIVE),
		member(t, "m-borrower", "p-borrower", "c-borrower", membershipTypeMember, commonv1.STATE_ACTIVE),
	}
	byID := map[string]*identityv1.MembershipObject{}
	for _, m := range memberships {
		byID[m.GetId()] = m
	}

	lender := newFakeLender()
	lender.openLoans["c-borrower"] = true

	repo := newMemOfferRepo()
	sender := &recordingSender{}
	identity := &fakeIdentity{memberships: byID}
	profiles := &fakeProfiles{payoutContact: map[string]string{"p-ok": "contact-ok"}}
	members := &fakeMembers{members: memberships}

	biz := NewLoanOfferBusiness(context.Background(), LoanOfferDeps{
		Product:  stawiproduct.ProductConfig{LoanProductID: "stawi", LoanTenurePeriods: 4, LoanInterestRatePA: 2400},
		Offers:   repo,
		Periods:  &fakePeriods{period: period},
		Members:  members,
		Identity: identity,
		Clients:  &fakeClients{profileByClient: map[string]string{"c-ok": "p-ok"}},
		Profiles: profiles,
		Lender:   lender,
		Notifier: notify.NewWithSender(sender, messages.Registry()),
	}).(*loanOfferBusiness)
	biz.now = func() time.Time { return now }

	return &offerFixture{
		biz: biz, repo: repo, lender: lender, sender: sender, identity: identity, profiles: profiles,
		members: members, window: window, now: now,
		group: &identityv1.ClientGroupObject{Id: testGroupID, Name: "Umoja Chama", CurrencyCode: "KES"},
	}
}

// openOffer stores an unanswered offer for the eligible member.
func (f *offerFixture) openOffer() *models.LoanOffer {
	expiry := f.now.Add(48 * time.Hour)
	return f.repo.put(&models.LoanOffer{
		MembershipID: "m-ok", LoanWindowID: testWindow, PeriodID: testPeriod,
		Amount: 800_000, Currency: "KES", ExpiryDate: &expiry, State: int32(constants.StateActive),
		Properties: data.JSONMap{propProfileID: "p-ok", propGroupName: "Umoja Chama"},
	})
}

func (f *offerFixture) accept(t *testing.T, offerID string) (*models.LoanOffer, error) {
	t.Helper()
	return f.biz.Respond(t.Context(), testGroupID, offerID, int32(models.LoanOfferResponseAccept))
}

// ---------------------------------------------------------------------------
// Offer generation
// ---------------------------------------------------------------------------

// Only the eligible member is offered, at the policy amount, once per window
// however often the window's offers are made.
func TestGenerateForWindow_OffersEligibleMembersOnce(t *testing.T) {
	f := newOfferFixture(t)

	made, err := f.biz.GenerateForWindow(t.Context(), f.group, f.window)
	require.NoError(t, err)
	assert.Equal(t, 1, made)

	offers, err := f.repo.GetByLoanWindowID(t.Context(), testWindow)
	require.NoError(t, err)
	require.Len(t, offers, 1)
	offer := offers[0]
	assert.Equal(t, "m-ok", offer.MembershipID)
	// 4 completed periods × 1,000.00 saved × 2.00 leverage.
	assert.Equal(t, int64(800_000), offer.Amount)
	assert.Equal(t, "p-ok", propString(offer, propProfileID))
	require.NotNil(t, offer.ExpiryDate)
	assert.True(t, offer.ExpiryDate.After(f.now))

	made, err = f.biz.GenerateForWindow(t.Context(), f.group, f.window)
	require.NoError(t, err)
	assert.Zero(t, made, "a second run offers nobody again")

	offers, err = f.repo.GetByLoanWindowID(t.Context(), testWindow)
	require.NoError(t, err)
	assert.Len(t, offers, 1)
	assert.Equal(t, []string{messages.GroupLoanOffered}, f.sender.templates(), "the member is told once")
}

// A member already offered elsewhere is not offered again, and a concurrent
// generation's offer is not duplicated.
func TestGenerateForWindow_SkipsMemberWithOpenOffer(t *testing.T) {
	f := newOfferFixture(t)
	f.repo.put(&models.LoanOffer{
		MembershipID: "m-ok", LoanWindowID: "older-window", State: int32(constants.StateActive),
	})

	made, err := f.biz.GenerateForWindow(t.Context(), f.group, f.window)
	require.NoError(t, err)
	assert.Zero(t, made)
}

func TestGenerateForWindow_NoSavingsNoOffers(t *testing.T) {
	f := newOfferFixture(t)
	first := &models.Period{GroupID: testGroupID, Position: 1}
	first.ID = testPeriod
	f.biz.periods = &fakePeriods{period: first}

	made, err := f.biz.GenerateForWindow(t.Context(), f.group, f.window)
	require.NoError(t, err)
	assert.Zero(t, made)
}

// ---------------------------------------------------------------------------
// Acceptance and origination
// ---------------------------------------------------------------------------

// Accepting originates the loan, pays it to the member's own contact and
// records each step; accepting again repeats none of it.
func TestRespondAccept_OriginatesAndDisbursesOnce(t *testing.T) {
	f := newOfferFixture(t)
	offer := f.openOffer()

	got, err := f.accept(t, offer.GetID())
	require.NoError(t, err)
	assert.Equal(t, models.OriginationDisbursed, got.OriginationStatus)

	stored := f.repo.get(t, offer.GetID())
	assert.Equal(t, models.OriginationDisbursed, stored.OriginationStatus)
	assert.Equal(t, int32(constants.StateInactive), stored.State)
	assert.NotEmpty(t, stored.ApplicationID)
	assert.Equal(t, "loan-"+stored.ApplicationID, stored.LoanAccountID)
	assert.Equal(t, "disb-"+stored.LoanAccountID, stored.DisbursementID)
	assert.Empty(t, propString(stored, propAttemptUntil), "the attempt is released")

	request := f.lender.requests[stored.ApplicationID]
	require.NotNil(t, request, "the request is written under the id the offer recorded")
	assert.Equal(t, "c-ok", request.GetClientId())
	assert.Equal(t, "contact-ok", request.GetProperties().AsMap()["payment_account_ref"],
		"the loan is paid to the member's own verified contact, by id")
	assert.Contains(t, f.lender.disbursements, "stawi:offer:"+offer.GetID())

	_, err = f.accept(t, offer.GetID())
	require.NoError(t, err)
	_, err = f.biz.CreateLoanAccount(t.Context(), "another-group", offer.GetID())
	require.Error(t, err, "an offer is not reachable through another group")
	_, err = f.biz.CreateLoanAccount(t.Context(), testGroupID, offer.GetID())
	require.NoError(t, err)
	sweep, err := f.biz.ResumePendingOrigination(t.Context(), 10)
	require.NoError(t, err)
	assert.Zero(t, sweep.Scanned)

	assert.Equal(t, 1, f.lender.submits)
	assert.Equal(t, 1, f.lender.approves)
	assert.Equal(t, 1, f.lender.accountCreates)
	assert.Equal(t, 1, f.lender.disburses)
	assert.Empty(t, f.sender.templates(), "loans, not stawi, tells the member the money was sent")
}

// A loans outage after the loan was made leaves the offer accepted and
// pending; the resume finishes it without making a second loan.
func TestRespondAccept_TransientFailureResumes(t *testing.T) {
	f := newOfferFixture(t)
	offer := f.openOffer()
	f.lender.failOnce["disburse"] = connect.NewError(connect.CodeUnavailable, "operations unavailable")

	got, err := f.accept(t, offer.GetID())
	require.NoError(t, err, "the acceptance stands while origination is pending")
	assert.Equal(t, models.OriginationPending, got.OriginationStatus)

	stored := f.repo.get(t, offer.GetID())
	assert.Equal(t, models.OriginationPending, stored.OriginationStatus)
	assert.NotEmpty(t, stored.LoanAccountID, "the loan made before the outage is recorded")
	assert.NotEmpty(t, propString(stored, propLastError))
	assert.Empty(t, propString(stored, propAttemptUntil))

	sweep, err := f.biz.ResumePendingOrigination(t.Context(), 10)
	require.NoError(t, err)
	assert.Equal(t, OriginationSweep{Scanned: 1, Disbursed: 1}, sweep)

	stored = f.repo.get(t, offer.GetID())
	assert.Equal(t, models.OriginationDisbursed, stored.OriginationStatus)
	assert.Empty(t, propString(stored, propLastError))
	assert.Equal(t, 1, f.lender.submits)
	assert.Equal(t, 1, f.lender.approves)
	assert.Equal(t, 1, f.lender.accountCreates, "the resume starts from the recorded loan")
	assert.Equal(t, 2, f.lender.disburses, "the payout is retried under the same key")
	assert.Len(t, f.lender.disbursements, 1)
}

// An approval whose reply was lost is read back, not repeated: approving an
// approved request is refused and would otherwise fail the offer.
func TestRespondAccept_LostApprovalReplyIsReadBack(t *testing.T) {
	f := newOfferFixture(t)
	offer := f.openOffer()
	f.lender.approveLosesReply = true

	got, err := f.accept(t, offer.GetID())
	require.NoError(t, err)
	assert.Equal(t, models.OriginationPending, got.OriginationStatus)

	sweep, err := f.biz.ResumePendingOrigination(t.Context(), 10)
	require.NoError(t, err)
	assert.Equal(t, 1, sweep.Disbursed)
	assert.Equal(t, 1, f.lender.approves)
	assert.Equal(t, 1, f.lender.submits)
}

// A refusal from loans marks the offer failed with the reason and tells the
// member; nothing is paid.
func TestRespondAccept_PermanentRefusalFails(t *testing.T) {
	f := newOfferFixture(t)
	offer := f.openOffer()
	f.lender.failAlways["approve"] = connect.NewError(connect.CodeFailedPrecondition, "client is not active")

	_, err := f.accept(t, offer.GetID())
	require.Error(t, err)

	stored := f.repo.get(t, offer.GetID())
	assert.Equal(t, models.OriginationFailed, stored.OriginationStatus)
	assert.Equal(t, int32(constants.StateInactive), stored.State)
	assert.NotEmpty(t, propString(stored, propFailureReason))
	assert.Empty(t, stored.LoanAccountID)
	assert.Zero(t, f.lender.disburses)
	assert.Equal(t, []string{messages.GroupLoanFailed}, f.sender.templates())

	// The failed offer is not resumed and answering again reports the failure.
	sweep, err := f.biz.ResumePendingOrigination(t.Context(), 10)
	require.NoError(t, err)
	assert.Zero(t, sweep.Scanned)
	_, err = f.accept(t, offer.GetID())
	require.Error(t, err)
	assert.Equal(t, 1, f.lender.approves)
}

// A payout refused after the loan was made closes the loan so its funding
// is released.
func TestRespondAccept_RefusedPayoutCancelsLoan(t *testing.T) {
	f := newOfferFixture(t)
	offer := f.openOffer()
	f.lender.failAlways["disburse"] = connect.NewError(connect.CodeFailedPrecondition, "payout refused")

	_, err := f.accept(t, offer.GetID())
	require.Error(t, err)

	stored := f.repo.get(t, offer.GetID())
	assert.Equal(t, models.OriginationFailed, stored.OriginationStatus)
	require.NotEmpty(t, stored.LoanAccountID)
	assert.Equal(t, []string{stored.LoanAccountID}, f.lender.cancelled)
	assert.Equal(t, true, stored.Properties[propLoanCancelled])
}

// A member without a verified mobile number has nowhere to be paid: the
// offer fails clearly before any loan exists.
func TestRespondAccept_NoPayoutContactFails(t *testing.T) {
	f := newOfferFixture(t)
	offer := f.openOffer()
	delete(f.profiles.payoutContact, "p-ok")

	_, err := f.accept(t, offer.GetID())
	require.Error(t, err)

	stored := f.repo.get(t, offer.GetID())
	assert.Equal(t, models.OriginationFailed, stored.OriginationStatus)
	assert.Contains(t, propString(stored, propFailureReason), "verified mobile number")
	assert.Zero(t, f.lender.submits)
}

// Another attempt holding the offer is left to finish; this call neither
// calls loans nor fails the offer.
func TestRespondAccept_AttemptInFlightIsLeftAlone(t *testing.T) {
	f := newOfferFixture(t)
	offer := f.openOffer()
	offer.Response = int32(models.LoanOfferResponseAccept)
	offer.OriginationStatus = models.OriginationPending
	setProp(offer, propAttemptUntil, f.now.Add(time.Minute).Format(time.RFC3339))
	f.repo.put(offer)

	got, err := f.accept(t, offer.GetID())
	require.NoError(t, err)
	assert.Equal(t, models.OriginationPending, got.OriginationStatus)
	assert.Zero(t, f.lender.submits)

	// Once the lease lapses, the next attempt takes over.
	f.biz.now = func() time.Time { return f.now.Add(3 * time.Minute) }
	sweep, err := f.biz.ResumePendingOrigination(t.Context(), 10)
	require.NoError(t, err)
	assert.Equal(t, 1, sweep.Disbursed)
}

// ---------------------------------------------------------------------------
// Expiry and decline
// ---------------------------------------------------------------------------

func TestRespond_ExpiredOfferRefused(t *testing.T) {
	f := newOfferFixture(t)
	offer := f.openOffer()
	f.biz.now = func() time.Time { return offer.ExpiryDate.Add(time.Second) }

	_, err := f.accept(t, offer.GetID())
	var appErr *apperrors.Error
	require.ErrorAs(t, err, &appErr)
	assert.Equal(t, apperrors.Gone, appErr.ErrorCode())
	assert.Zero(t, f.lender.submits)
	assert.Equal(t, int32(models.LoanOfferResponseNone), f.repo.get(t, offer.GetID()).Response)
}

func TestRespond_DeclineRecordsDecision(t *testing.T) {
	f := newOfferFixture(t)
	offer := f.openOffer()

	got, err := f.biz.Respond(t.Context(), testGroupID, offer.GetID(), int32(models.LoanOfferResponseReject))
	require.NoError(t, err)
	assert.Empty(t, got.OriginationStatus)

	stored := f.repo.get(t, offer.GetID())
	assert.Equal(t, int32(models.LoanOfferResponseReject), stored.Response)
	assert.Equal(t, int32(constants.StateInactive), stored.State)
	assert.Zero(t, f.lender.submits)

	_, err = f.accept(t, offer.GetID())
	require.Error(t, err, "a declined offer cannot be accepted afterwards")
}

func TestExpireStale_ClosesOnlyUnansweredExpiredOffers(t *testing.T) {
	f := newOfferFixture(t)
	stale := f.openOffer()
	past := f.now.Add(-time.Hour)
	stale.ExpiryDate = &past
	f.repo.put(stale)

	fresh := f.repo.put(&models.LoanOffer{
		MembershipID: "m-borrower", LoanWindowID: testWindow, State: int32(constants.StateActive),
		ExpiryDate: func() *time.Time { t := f.now.Add(time.Hour); return &t }(),
	})

	expired, err := f.biz.ExpireStale(t.Context(), f.now, 10)
	require.NoError(t, err)
	assert.Equal(t, 1, expired)
	assert.Equal(t, int32(constants.StateInactive), f.repo.get(t, stale.GetID()).State)
	assert.Equal(t, "expired", propString(f.repo.get(t, stale.GetID()), propClosedReason))
	assert.Equal(t, int32(constants.StateActive), f.repo.get(t, fresh.GetID()).State)
}

func TestPermanentRefusal(t *testing.T) {
	cases := []struct {
		err  error
		want bool
	}{
		{connect.NewError(connect.CodeInvalidArgument, "x"), true},
		{connect.NewError(connect.CodeFailedPrecondition, "x"), true},
		{connect.NewError(connect.CodeNotFound, "x"), true},
		{connect.NewError(connect.CodePermissionDenied, "x"), true},
		{connect.NewError(connect.CodeUnavailable, "x"), false},
		{connect.NewError(connect.CodeDeadlineExceeded, "x"), false},
		{connect.NewError(connect.CodeAlreadyExists, "x"), false},
		{apperrors.NewError(apperrors.Unprocessable, "x"), true},
		{apperrors.NewError(apperrors.ServiceUnavailable, "x"), false},
		{errOfferChanged, false},
		{errors.New("socket closed"), false},
	}
	for _, c := range cases {
		assert.Equal(t, c.want, permanentRefusal(c.err), "%v", c.err)
	}
}
