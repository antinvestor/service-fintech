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

package e2e_test

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"sync"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"buf.build/gen/go/antinvestor/funding/connectrpc/go/v2/funding/v1/fundingv1connect"
	fundingv1 "buf.build/gen/go/antinvestor/funding/protocolbuffers/go/funding/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/v2/identity/v1/identityv1connect"
	"buf.build/gen/go/antinvestor/ledger/connectrpc/go/v2/v1/ledgerv1connect"
	ledgerv1 "buf.build/gen/go/antinvestor/ledger/protocolbuffers/go/v1"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"buf.build/gen/go/antinvestor/notification/connectrpc/go/v2/notification/v1/notificationv1connect"
	notificationv1 "buf.build/gen/go/antinvestor/notification/protocolbuffers/go/notification/v1"
	"buf.build/gen/go/antinvestor/payment/connectrpc/go/v2/v1/paymentv1connect"
	paymentv1 "buf.build/gen/go/antinvestor/payment/protocolbuffers/go/v1"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"google.golang.org/protobuf/proto"
)

// The platform edge: every service the two real services talk to that is
// not under test runs here as a small in-memory Connect server. Each records
// what it was asked and answers from state the test sets up. None of them
// authenticates its callers; authentication is exercised on the real loans
// and operations servers.

// borrower is one person the lender serves: a field client on the identity
// service, backed by a profile that holds their verified mobile number. The
// number itself lives only in the profile fake.
type borrower struct {
	clientID  string
	profileID string
	contactID string
	msisdn    string
}

// platform holds the state every fake reads.
type platform struct {
	mu sync.Mutex

	borrowers map[string]*borrower // by client id
	// agentClients maps a field agent's profile to the member id and clients
	// they serve.
	agentMember  map[string]string
	agentClients map[string][]string

	sends    []*paymentv1.SendRequest
	payments map[string]*paymentv1.Payment // outbound payments by reference
	// payoutStatus is the status the rail reports for a payout reference
	// after it was accepted; unset means still in process.
	payoutStatus map[string]commonv1.STATUS
}

func newPlatform() *platform {
	return &platform{
		borrowers:    map[string]*borrower{},
		agentMember:  map[string]string{},
		agentClients: map[string][]string{},
		payments:     map[string]*paymentv1.Payment{},
		payoutStatus: map[string]commonv1.STATUS{},
	}
}

func (p *platform) addBorrower(b *borrower) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.borrowers[b.clientID] = b
}

func (p *platform) addAgent(profileID, memberID string, clients ...string) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.agentMember[profileID] = memberID
	p.agentClients[profileID] = append(p.agentClients[profileID], clients...)
}

func (p *platform) borrowerByProfile(profileID string) *borrower {
	for _, b := range p.borrowers {
		if b.profileID == profileID {
			return b
		}
	}
	return nil
}

// payoutSendsFor returns a copy of every Send the payment service received
// for a payout reference.
func (p *platform) payoutSendsFor(reference string) []*paymentv1.SendRequest {
	p.mu.Lock()
	defer p.mu.Unlock()
	var out []*paymentv1.SendRequest
	for _, s := range p.sends {
		if s.GetData().GetReferenceId() == reference {
			out = append(out, proto.CloneOf(s))
		}
	}
	return out
}

// settlePayout sets how the rail reports a payout it accepted.
func (p *platform) settlePayout(reference string, status commonv1.STATUS) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.payoutStatus[reference] = status
}

// serve mounts one fake on its own test server.
func serve(register func(*connect.Server)) *httptest.Server {
	server := connect.NewServer()
	register(server)
	mux := http.NewServeMux()
	connecthttp.Mount(mux, server)
	return httptest.NewServer(mux)
}

// --- field (identity binary): clients and who may act for them ---

type fakeField struct {
	fieldv1connect.UnimplementedFieldServiceHandler

	p *platform
}

func (f *fakeField) ClientGet(_ context.Context, req *fieldv1.ClientGetRequest) (*fieldv1.ClientGetResponse, error) {
	f.p.mu.Lock()
	defer f.p.mu.Unlock()
	b, ok := f.p.borrowers[req.GetId()]
	if !ok {
		return nil, connect.NewError(connect.CodeNotFound, "client "+req.GetId())
	}
	// Registered, KYC verified and consented: the client is active.
	return &fieldv1.ClientGetResponse{Data: &fieldv1.ClientObject{
		Id:        b.clientID,
		ProfileId: b.profileID,
		Name:      "Borrower " + b.clientID,
		State:     commonv1.STATE_ACTIVE,
	}}, nil
}

func (f *fakeField) ClientSearch(
	_ context.Context,
	req *fieldv1.ClientSearchRequest,
	stream fieldv1connect.FieldServiceClientSearchServerStream,
) error {
	f.p.mu.Lock()
	b := f.p.borrowerByProfile(req.GetProfileId())
	f.p.mu.Unlock()
	if b == nil {
		return nil
	}
	return stream.Send(&fieldv1.ClientSearchResponse{Data: []*fieldv1.ClientObject{{
		Id: b.clientID, ProfileId: b.profileID, State: commonv1.STATE_ACTIVE,
	}}})
}

func (f *fakeField) ClientAccessScope(
	_ context.Context,
	req *fieldv1.ClientAccessScopeRequest,
) (*fieldv1.ClientAccessScopeResponse, error) {
	f.p.mu.Lock()
	defer f.p.mu.Unlock()
	resp := &fieldv1.ClientAccessScopeResponse{
		MemberId:        f.p.agentMember[req.GetProfileId()],
		ServedClientIds: append([]string(nil), f.p.agentClients[req.GetProfileId()]...),
	}
	if b := f.p.borrowerByProfile(req.GetProfileId()); b != nil {
		resp.ClientId = b.clientID
	}
	return resp, nil
}

// --- profile: the borrower's verified mobile number, by contact id ---

type fakeProfile struct {
	profilev1connect.UnimplementedProfileServiceHandler

	p *platform
}

func (f *fakeProfile) GetById( //nolint:revive,staticcheck // the generated handler's name
	_ context.Context, req *profilev1.GetByIdRequest) (*profilev1.GetByIdResponse, error) {
	f.p.mu.Lock()
	defer f.p.mu.Unlock()
	b := f.p.borrowerByProfile(req.GetId())
	if b == nil {
		return nil, connect.NewError(connect.CodeNotFound, "profile "+req.GetId())
	}
	return &profilev1.GetByIdResponse{Data: &profilev1.ProfileObject{
		Id: b.profileID,
		Contacts: []*profilev1.ContactObject{{
			Id:       b.contactID,
			Type:     profilev1.ContactType_MSISDN,
			Detail:   b.msisdn,
			Verified: true,
			State:    commonv1.STATE_ACTIVE,
		}},
	}}, nil
}

// --- funding: every application is fully funded ---

type fakeFunding struct {
	fundingv1connect.UnimplementedFundingServiceHandler
}

// fullyFunded is what the fake funds per loan: more than any loan here.
const fullyFunded = int64(100_000_000_00)

func (f *fakeFunding) FundLoan(
	_ context.Context,
	_ *fundingv1.FundLoanRequest,
) (*fundingv1.FundLoanResponse, error) {
	return &fundingv1.FundLoanResponse{
		TotalAllocated: kes(fullyFunded),
		FullyFunded:    true,
	}, nil
}

func (f *fakeFunding) LoanRepaymentApply(
	_ context.Context,
	_ *fundingv1.LoanRepaymentApplyRequest,
) (*fundingv1.LoanRepaymentApplyResponse, error) {
	return &fundingv1.LoanRepaymentApplyResponse{Settled: true}, nil
}

func (f *fakeFunding) FundingRelease(
	_ context.Context,
	_ *fundingv1.FundingReleaseRequest,
) (*fundingv1.FundingReleaseResponse, error) {
	return &fundingv1.FundingReleaseResponse{}, nil
}

// --- limits: every intent is within limits ---

type fakeLimits struct {
	limitsv1connect.UnimplementedLimitsServiceHandler
}

func (f *fakeLimits) Reserve(_ context.Context, req *limitsv1.ReserveRequest) (*limitsv1.ReserveResponse, error) {
	return &limitsv1.ReserveResponse{Reservation: &limitsv1.ReservationObject{
		Id:     "reservation-" + req.GetIdempotencyKey(),
		Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
	}}, nil
}

func (f *fakeLimits) Commit(_ context.Context, _ *limitsv1.CommitRequest) (*limitsv1.CommitResponse, error) {
	return &limitsv1.CommitResponse{}, nil
}

func (f *fakeLimits) Release(_ context.Context, _ *limitsv1.ReleaseRequest) (*limitsv1.ReleaseResponse, error) {
	return &limitsv1.ReleaseResponse{}, nil
}

// --- notification: accepts every message ---

type fakeNotification struct {
	notificationv1connect.UnimplementedNotificationServiceHandler
}

func (f *fakeNotification) Send(
	_ context.Context,
	_ *notificationv1.SendRequest,
	_ notificationv1connect.NotificationServiceSendServerStream,
) error {
	return nil
}

// --- ledger: posts every balanced transaction ---

type fakeLedger struct {
	ledgerv1connect.UnimplementedLedgerServiceHandler
}

func (f *fakeLedger) CreateTransaction(
	_ context.Context,
	req *ledgerv1.CreateTransactionRequest,
) (*ledgerv1.CreateTransactionResponse, error) {
	return ledgerv1.CreateTransactionResponse_builder{
		Data: ledgerv1.Transaction_builder{Id: req.GetId()}.Build(),
	}.Build(), nil
}

func (f *fakeLedger) CreateAccount(
	_ context.Context,
	_ *ledgerv1.CreateAccountRequest,
) (*ledgerv1.CreateAccountResponse, error) {
	return ledgerv1.CreateAccountResponse_builder{}.Build(), nil
}

func (f *fakeLedger) CreateLedger(
	_ context.Context,
	_ *ledgerv1.CreateLedgerRequest,
) (*ledgerv1.CreateLedgerResponse, error) {
	return ledgerv1.CreateLedgerResponse_builder{}.Build(), nil
}

// --- payment: takes payouts and answers lookups by reference ---

type fakePayment struct {
	paymentv1connect.UnimplementedPaymentServiceHandler

	p *platform
}

// Send accepts a payout. Like the real rail it answers "in process": the
// outcome arrives later and is read back through Search.
func (f *fakePayment) Send(_ context.Context, req *paymentv1.SendRequest) (*paymentv1.SendResponse, error) {
	f.p.mu.Lock()
	defer f.p.mu.Unlock()
	f.p.sends = append(f.p.sends, proto.CloneOf(req))

	in := req.GetData()
	id := fmt.Sprintf("payout-%d", len(f.p.sends))
	f.p.payments[in.GetReferenceId()] = paymentv1.Payment_builder{
		Id:          id,
		ReferenceId: in.GetReferenceId(),
		Recipient:   in.GetRecipient(),
		Amount:      in.GetAmount(),
		Route:       in.GetRoute(),
		Outbound:    true,
		Status:      commonv1.STATUS_IN_PROCESS,
	}.Build()
	return paymentv1.SendResponse_builder{
		Data: commonv1.StatusResponse_builder{Id: id, Status: commonv1.STATUS_IN_PROCESS}.Build(),
	}.Build(), nil
}

func (f *fakePayment) Search(
	_ context.Context,
	req *commonv1.SearchRequest,
	stream paymentv1connect.PaymentServiceSearchServerStream,
) error {
	f.p.mu.Lock()
	payment, ok := f.p.payments[req.GetQuery()]
	if ok {
		payment = proto.CloneOf(payment)
		if status, settled := f.p.payoutStatus[req.GetQuery()]; settled {
			payment.SetStatus(status)
		}
	}
	f.p.mu.Unlock()
	if !ok {
		return nil
	}
	return stream.Send(paymentv1.SearchResponse_builder{Data: []*paymentv1.Payment{payment}}.Build())
}

// --- identity: workforce lookups are not part of this flow ---

type fakeIdentity struct {
	identityv1connect.UnimplementedIdentityServiceHandler
}

// fakes are the running platform-edge servers.
type fakes struct {
	field, profile, funding, limits, notification, ledger, payment, identity *httptest.Server
}

func startFakes(p *platform) *fakes {
	return &fakes{
		field: serve(func(s *connect.Server) { fieldv1connect.RegisterFieldServiceHandler(s, &fakeField{p: p}) }),
		profile: serve(func(s *connect.Server) {
			profilev1connect.RegisterProfileServiceHandler(s, &fakeProfile{p: p})
		}),
		funding: serve(func(s *connect.Server) {
			fundingv1connect.RegisterFundingServiceHandler(s, &fakeFunding{})
		}),
		limits: serve(func(s *connect.Server) { limitsv1connect.RegisterLimitsServiceHandler(s, &fakeLimits{}) }),
		notification: serve(func(s *connect.Server) {
			notificationv1connect.RegisterNotificationServiceHandler(s, &fakeNotification{})
		}),
		ledger: serve(func(s *connect.Server) { ledgerv1connect.RegisterLedgerServiceHandler(s, &fakeLedger{}) }),
		payment: serve(func(s *connect.Server) {
			paymentv1connect.RegisterPaymentServiceHandler(s, &fakePayment{p: p})
		}),
		identity: serve(func(s *connect.Server) {
			identityv1connect.RegisterIdentityServiceHandler(s, &fakeIdentity{})
		}),
	}
}

func (f *fakes) close() {
	for _, s := range []*httptest.Server{
		f.field, f.profile, f.funding, f.limits, f.notification, f.ledger, f.payment, f.identity,
	} {
		s.Close()
	}
}
