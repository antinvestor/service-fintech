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

package business_test

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util/moneyx"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"golang.org/x/crypto/nacl/box"

	"github.com/antinvestor/service-fintech/apps/seed/service/business"
	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/apps/seed/service/repository"
	"github.com/antinvestor/service-fintech/apps/seed/service/ussd"
	"github.com/antinvestor/service-fintech/pkg/messages"
	"github.com/antinvestor/service-fintech/pkg/notify"
)

// --- peers ------------------------------------------------------------------

type ussdField struct {
	fieldv1connect.UnimplementedFieldServiceHandler
	clients []*fieldv1.ClientObject
}

func (f *ussdField) ClientSearch(
	_ context.Context, req *fieldv1.ClientSearchRequest, stream fieldv1connect.FieldServiceClientSearchServerStream,
) error {
	var out []*fieldv1.ClientObject
	for _, c := range f.clients {
		if c.GetProfileId() == req.GetProfileId() {
			out = append(out, c)
		}
	}
	return stream.Send(&fieldv1.ClientSearchResponse{Data: out})
}

type ussdLoans struct {
	loansv1connect.UnimplementedLoanManagementServiceHandler
	mu         sync.Mutex
	loans      []*loansv1.LoanAccountObject
	balance    *loansv1.LoanBalanceObject
	entries    []*loansv1.ScheduleEntryObject
	collection *loansv1.InitiateCollectionRequest
}

func (l *ussdLoans) LoanAccountSearch(
	_ context.Context, req *loansv1.LoanAccountSearchRequest,
	stream loansv1connect.LoanManagementServiceLoanAccountSearchServerStream,
) error {
	var out []*loansv1.LoanAccountObject
	for _, a := range l.loans {
		if a.GetClientId() == req.GetClientId() {
			out = append(out, a)
		}
	}
	return stream.Send(&loansv1.LoanAccountSearchResponse{Data: out})
}

func (l *ussdLoans) LoanBalanceGet(
	_ context.Context, _ *loansv1.LoanBalanceGetRequest,
) (*loansv1.LoanBalanceGetResponse, error) {
	return &loansv1.LoanBalanceGetResponse{Data: l.balance}, nil
}

func (l *ussdLoans) RepaymentScheduleGet(
	_ context.Context, _ *loansv1.RepaymentScheduleGetRequest,
) (*loansv1.RepaymentScheduleGetResponse, error) {
	return &loansv1.RepaymentScheduleGetResponse{Data: &loansv1.RepaymentScheduleObject{Entries: l.entries}}, nil
}

func (l *ussdLoans) InitiateCollection(
	_ context.Context, req *loansv1.InitiateCollectionRequest,
) (*loansv1.InitiateCollectionResponse, error) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.collection = req
	return &loansv1.InitiateCollectionResponse{Status: "prompted"}, nil
}

type ussdProfiles struct {
	profilev1connect.UnimplementedProfileServiceHandler
	mu           sync.Mutex
	contacts     []*profilev1.ContactObject
	codeSentTo   string
	verification string
	goodCode     string
}

//nolint:revive,staticcheck // the generated interface names it GetById
func (p *ussdProfiles) GetById(_ context.Context, req *profilev1.GetByIdRequest) (*profilev1.GetByIdResponse, error) {
	return &profilev1.GetByIdResponse{Data: &profilev1.ProfileObject{Id: req.GetId(), Contacts: p.contacts}}, nil
}

func (p *ussdProfiles) CreateContactVerification(
	_ context.Context, req *profilev1.CreateContactVerificationRequest,
) (*profilev1.CreateContactVerificationResponse, error) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.codeSentTo, p.verification = req.GetContactId(), req.GetId()
	return &profilev1.CreateContactVerificationResponse{Id: req.GetId(), Success: true}, nil
}

func (p *ussdProfiles) CheckVerification(
	_ context.Context, req *profilev1.CheckVerificationRequest,
) (*profilev1.CheckVerificationResponse, error) {
	return &profilev1.CheckVerificationResponse{
		Id: req.GetId(), Success: req.GetId() == p.verification && req.GetCode() == p.goodCode,
	}, nil
}

func serve(t *testing.T, register func(*connect.Server)) *connect.Client {
	t.Helper()
	mux := http.NewServeMux()
	server := connect.NewServer()
	register(server)
	connecthttp.Mount(mux, server)
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)
	return connect.NewClient(connecthttp.NewTransport(srv.Client(), srv.URL))
}

// --- seed collaborators -------------------------------------------------------

type memPins struct {
	repository.UssdPinRepository
	mu   sync.Mutex
	rows map[string]*models.UssdPin
}

func (m *memPins) GetByProfile(_ context.Context, profileID string) (*models.UssdPin, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, p := range m.rows {
		if p.ProfileID == profileID {
			cp := *p
			return &cp, nil
		}
	}
	return nil, nil //nolint:nilnil // mirrors the repository
}

func (m *memPins) Ensure(ctx context.Context, profileID string) (*models.UssdPin, error) {
	if p, _ := m.GetByProfile(ctx, profileID); p != nil {
		return p, nil
	}
	m.mu.Lock()
	p := &models.UssdPin{ProfileID: profileID}
	p.ID = "pin-" + profileID
	m.rows[p.ID] = p
	m.mu.Unlock()
	return m.GetByProfile(ctx, profileID)
}

func (m *memPins) RecordVerification(_ context.Context, id, verificationID string, at time.Time) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.rows[id].VerificationID, m.rows[id].VerificationRequestedAt = verificationID, &at
	return nil
}

func (m *memPins) SetPin(_ context.Context, id, hash string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	r := m.rows[id]
	r.PinHash, r.FailedAttempts, r.LockedUntil, r.VerificationID = hash, 0, nil, ""
	return nil
}

func (m *memPins) RecordFailure(_ context.Context, id string, maxAttempts int32, lockUntil time.Time) (int32, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	r := m.rows[id]
	r.FailedAttempts++
	if r.FailedAttempts >= maxAttempts {
		r.LockedUntil = &lockUntil
	}
	return r.FailedAttempts, nil
}

func (m *memPins) ClearFailures(_ context.Context, id string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.rows[id].FailedAttempts, m.rows[id].LockedUntil = 0, nil
	return nil
}

type recordingLoanRequests struct {
	business.LoanRequestBusiness
	got  []business.RequestLoanInput
	err  error
	tier string
}

func (r *recordingLoanRequests) RequestLoan(
	ctx context.Context,
	in business.RequestLoanInput,
) (*models.LoanRequest, error) {
	r.got = append(r.got, in)
	if claims := security.ClaimsFromContext(ctx); claims != nil {
		r.tier = claims.GetPartitionID()
	}
	return &models.LoanRequest{}, r.err
}

type fixedCredit struct {
	business.CreditProfileBusiness
	profile *models.CreditProfile
}

func (f *fixedCredit) GetProfile(context.Context, string, string) (*models.CreditProfile, error) {
	return f.profile, nil
}

type sentMessages struct {
	mu  sync.Mutex
	got []*notificationv1.Notification
}

func (s *sentMessages) Send(_ context.Context, n *notificationv1.Notification) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.got = append(s.got, n)
	return nil
}

func (s *sentMessages) templates() []string {
	s.mu.Lock()
	defer s.mu.Unlock()
	var out []string
	for _, n := range s.got {
		out = append(out, n.GetTemplate())
	}
	return out
}

// --- harness ------------------------------------------------------------------

type ussdHarness struct {
	biz      business.UssdBusiness
	opener   *ussd.Opener
	public   [32]byte
	pins     *memPins
	loans    *ussdLoans
	profiles *ussdProfiles
	requests *recordingLoanRequests
	sent     *sentMessages
}

func newUssdHarness(t *testing.T) *ussdHarness {
	t.Helper()
	public, private, err := box.GenerateKey(rand.Reader)
	require.NoError(t, err)
	opener, err := ussd.NewOpener(base64.StdEncoding.EncodeToString(private[:]))
	require.NoError(t, err)

	h := &ussdHarness{
		opener: opener, public: *public,
		pins:  &memPins{rows: map[string]*models.UssdPin{}},
		loans: &ussdLoans{},
		profiles: &ussdProfiles{goodCode: "246810", contacts: []*profilev1.ContactObject{
			{Id: "contact-1", Type: profilev1.ContactType_MSISDN, Verified: true, State: commonv1.STATE_ACTIVE},
		}},
		requests: &recordingLoanRequests{},
		sent:     &sentMessages{},
	}
	field := &ussdField{clients: []*fieldv1.ClientObject{{Id: "client-1", ProfileId: "profile-1",
		State: commonv1.STATE_ACTIVE, TenantId: "tenant-l", PartitionId: "partition-lender"}}}

	h.biz = business.NewUssdBusiness(business.UssdDeps{
		Opener: opener,
		Pins:   h.pins,
		Field: fieldv1connect.NewFieldServiceClient(serve(t, func(s *connect.Server) {
			fieldv1connect.RegisterFieldServiceHandler(s, field)
		})),
		Loans: loansv1connect.NewLoanManagementServiceClient(serve(t, func(s *connect.Server) {
			loansv1connect.RegisterLoanManagementServiceHandler(s, h.loans)
		})),
		Profiles: profilev1connect.NewProfileServiceClient(serve(t, func(s *connect.Server) {
			profilev1connect.RegisterProfileServiceHandler(s, h.profiles)
		})),
		LoanRequests: h.requests,
		Credit: &fixedCredit{profile: &models.CreditProfile{
			Status: int32(models.CreditProfileStatusActive), MaxLoanAmount: 500_000,
		}},
		Notifier:       notify.NewWithSender(h.sent, messages.Registry()),
		ProductID:      "seed",
		Currency:       "KES",
		LenderName:     "Seed",
		ServiceSubject: "service_seed",
	})
	require.NotNil(t, h.biz)
	return h
}

func (h *ussdHarness) seal(t *testing.T, value string) string {
	t.Helper()
	sealed, err := box.SealAnonymous(nil, []byte(value), &h.public, rand.Reader)
	require.NoError(t, err)
	return "sealed:" + base64.StdEncoding.EncodeToString(sealed)
}

func (h *ussdHarness) session(id string, data map[string]string) business.UssdSession {
	return business.UssdSession{ID: id, ProfileID: "profile-1", ContactID: "contact-1", Data: data}
}

func (h *ussdHarness) setPIN(t *testing.T, pin string) {
	t.Helper()
	ctx := context.Background()
	require.NoError(
		t,
		h.biz.HandleSession(ctx, h.session("s-code", map[string]string{ussd.KeyPinStep: ussd.PinSendCode})),
	)
	require.NoError(t, h.biz.HandleSession(ctx, h.session("s-pin", map[string]string{
		ussd.KeyPinStep:    ussd.PinHaveCode,
		ussd.KeyOTP:        h.seal(t, h.profiles.goodCode),
		ussd.KeyNewPIN:     h.seal(t, pin),
		ussd.KeyConfirmPIN: h.seal(t, pin),
	})))
}

// --- tests ----------------------------------------------------------------------

func TestUssdPinIsSetOnlyWithTheCodeSentToTheBorrower(t *testing.T) {
	h := newUssdHarness(t)
	ctx := context.Background()

	require.NoError(t, h.biz.HandleSession(ctx, h.session("s1", map[string]string{ussd.KeyPinStep: ussd.PinSendCode})))
	assert.Equal(t, "contact-1", h.profiles.codeSentTo, "the code goes to the contact the borrower dialled from")

	// A wrong code sets nothing.
	require.NoError(t, h.biz.HandleSession(ctx, h.session("s2", map[string]string{
		ussd.KeyOTP: h.seal(t, "000000"), ussd.KeyNewPIN: h.seal(t, "4321"), ussd.KeyConfirmPIN: h.seal(t, "4321"),
	})))
	pin, err := h.pins.GetByProfile(ctx, "profile-1")
	require.NoError(t, err)
	assert.Empty(t, pin.PinHash)
	assert.Contains(t, h.sent.templates(), messages.UssdRequestFailed)

	// PINs that differ set nothing.
	require.NoError(t, h.biz.HandleSession(ctx, h.session("s3", map[string]string{
		ussd.KeyOTP: h.seal(t, "246810"), ussd.KeyNewPIN: h.seal(t, "4321"), ussd.KeyConfirmPIN: h.seal(t, "1234"),
	})))
	pin, _ = h.pins.GetByProfile(ctx, "profile-1")
	assert.Empty(t, pin.PinHash)

	// The right code and matching PINs set it; only a hash is kept.
	require.NoError(t, h.biz.HandleSession(ctx, h.session("s4", map[string]string{
		ussd.KeyOTP: h.seal(t, "246810"), ussd.KeyNewPIN: h.seal(t, "4321"), ussd.KeyConfirmPIN: h.seal(t, "4321"),
	})))
	pin, _ = h.pins.GetByProfile(ctx, "profile-1")
	require.NotEmpty(t, pin.PinHash)
	assert.NotContains(t, pin.PinHash, "4321")
	assert.True(t, ussd.CheckPIN(pin.PinHash, "4321"))
	assert.Contains(t, h.sent.templates(), messages.UssdPinSet)
}

func TestUssdBorrowNeedsTheRightPIN(t *testing.T) {
	h := newUssdHarness(t)
	ctx := context.Background()

	// No PIN yet: refused and told.
	require.NoError(t, h.biz.HandleSession(ctx, h.session("b0", map[string]string{
		ussd.KeyAmount: "3000", ussd.KeyPIN: h.seal(t, "4321"),
	})))
	assert.Empty(t, h.requests.got)

	h.setPIN(t, "4321")

	// A PIN typed in the clear is never trusted.
	require.NoError(t, h.biz.HandleSession(ctx, h.session("b1", map[string]string{
		ussd.KeyAmount: "3000", ussd.KeyPIN: "4321",
	})))
	assert.Empty(t, h.requests.got)

	require.NoError(t, h.biz.HandleSession(ctx, h.session("b2", map[string]string{
		ussd.KeyAmount: "3000", ussd.KeyPIN: h.seal(t, "4321"),
	})))
	require.Len(t, h.requests.got, 1)
	got := h.requests.got[0]
	assert.Equal(t, "client-1", got.ClientID)
	assert.Equal(t, int64(300_000), got.Amount, "whole shillings become minor units")
	assert.Equal(t, "ussd:b2", got.IdempotencyKey, "a redelivered session never borrows twice")
	assert.Equal(t, "partition-lender", h.requests.tier, "the request is made in the borrower's partition")
}

func TestUssdWrongPINLocksAfterFiveTries(t *testing.T) {
	h := newUssdHarness(t)
	ctx := context.Background()
	h.setPIN(t, "4321")

	for i := range 5 {
		require.NoError(t, h.biz.HandleSession(ctx, h.session("w"+string(rune('0'+i)), map[string]string{
			ussd.KeyAmount: "1000", ussd.KeyPIN: h.seal(t, "9999"),
		})))
	}
	pin, _ := h.pins.GetByProfile(ctx, "profile-1")
	require.NotNil(t, pin.LockedUntil)

	// Even the right PIN is refused while locked.
	require.NoError(t, h.biz.HandleSession(ctx, h.session("w-right", map[string]string{
		ussd.KeyAmount: "1000", ussd.KeyPIN: h.seal(t, "4321"),
	})))
	assert.Empty(t, h.requests.got)
}

func TestUssdRepayPromptsTheBorrowersOwnPhone(t *testing.T) {
	h := newUssdHarness(t)
	ctx := context.Background()
	h.loans.loans = []*loansv1.LoanAccountObject{{Id: "loan-abc123", ClientId: "client-1", ProductId: "seed",
		Status: loansv1.LoanStatus_LOAN_STATUS_ACTIVE}}
	h.loans.balance = &loansv1.LoanBalanceObject{TotalOutstanding: moneyx.FromMinorUnitsByCurrency("KES", 900_000)}
	h.loans.entries = []*loansv1.ScheduleEntryObject{
		{InstallmentNumber: 1, Status: loansv1.ScheduleEntryStatus_SCHEDULE_ENTRY_STATUS_PAID,
			Outstanding: moneyx.FromMinorUnitsByCurrency("KES", 0)},
		{InstallmentNumber: 2, Status: loansv1.ScheduleEntryStatus_SCHEDULE_ENTRY_STATUS_DUE, DueDate: "2026-11-03",
			Outstanding: moneyx.FromMinorUnitsByCurrency("KES", 300_000)},
	}

	require.NoError(
		t,
		h.biz.HandleSession(ctx, h.session("r1", map[string]string{ussd.KeyPayOption: ussd.PayNextInstalment})),
	)
	require.NotNil(t, h.loans.collection)
	assert.Equal(t, "loan-abc123", h.loans.collection.GetLoanAccountId())
	assert.Equal(t, "contact-1", h.loans.collection.GetContactId())
	assert.Equal(t, int64(3000), h.loans.collection.GetCollectionAmount().GetUnits())

	require.NoError(t, h.biz.HandleSession(ctx, h.session("r2", map[string]string{
		ussd.KeyPayOption: ussd.PayOther, ussd.KeyPayAmount: "1500",
	})))
	assert.Equal(t, int64(1500), h.loans.collection.GetCollectionAmount().GetUnits())

	require.NoError(
		t,
		h.biz.HandleSession(ctx, h.session("r3", map[string]string{ussd.KeyPayOption: ussd.PayFullBalance})),
	)
	assert.Equal(t, int64(9000), h.loans.collection.GetCollectionAmount().GetUnits())
}

func TestUssdStateIsWhatTheMenuShowsNow(t *testing.T) {
	h := newUssdHarness(t)
	ctx := context.Background()

	// A client with no PIN: may set one, may not borrow yet.
	rows, err := h.biz.State(ctx, "profile-1")
	require.NoError(t, err)
	assert.Len(t, rows[ussd.RowClient], 1)
	assert.Empty(t, rows[ussd.RowBorrow])
	assert.Contains(t, rows, ussd.RowLoan, "every row name is returned so stale rows clear")

	h.setPIN(t, "4321")
	rows, err = h.biz.State(ctx, "profile-1")
	require.NoError(t, err)
	require.Len(t, rows[ussd.RowBorrow], 1)
	assert.Equal(t, "KES 5,000.00", rows[ussd.RowBorrow][0]["limit"])

	// With a loan running: its balance shows and borrowing is off.
	h.loans.loans = []*loansv1.LoanAccountObject{{Id: "loan-abc123", ClientId: "client-1", ProductId: "seed",
		Status: loansv1.LoanStatus_LOAN_STATUS_ACTIVE}}
	h.loans.balance = &loansv1.LoanBalanceObject{TotalOutstanding: moneyx.FromMinorUnitsByCurrency("KES", 900_000)}
	rows, err = h.biz.State(ctx, "profile-1")
	require.NoError(t, err)
	require.Len(t, rows[ussd.RowLoan], 1)
	assert.Equal(t, "ABC123", rows[ussd.RowLoan][0]["loan_ref"])
	assert.Empty(t, rows[ussd.RowBorrow])

	// Someone who is not a seed client sees nothing.
	rows, err = h.biz.State(ctx, "stranger")
	require.NoError(t, err)
	assert.Empty(t, rows[ussd.RowClient])
}
