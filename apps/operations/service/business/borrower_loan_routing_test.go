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
	"net/http"
	"net/http/httptest"
	"testing"

	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"buf.build/gen/go/antinvestor/loans/connectrpc/go/v2/loans/v1/loansv1connect"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/pitabwire/frame/v3/data"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/pkg/clients"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

type borrowerFieldServer struct {
	fieldv1connect.UnimplementedFieldServiceHandler
	clients []*fieldv1.ClientObject
}

func (s *borrowerFieldServer) ClientSearch(
	_ context.Context,
	req *fieldv1.ClientSearchRequest,
	stream fieldv1connect.FieldServiceClientSearchServerStream,
) error {
	var out []*fieldv1.ClientObject
	for _, c := range s.clients {
		if req.GetProfileId() == "" || c.GetProfileId() == req.GetProfileId() {
			out = append(out, c)
		}
	}
	return stream.Send(&fieldv1.ClientSearchResponse{Data: out})
}

func (s *borrowerFieldServer) ClientGet(
	_ context.Context,
	req *fieldv1.ClientGetRequest,
) (*fieldv1.ClientGetResponse, error) {
	for _, c := range s.clients {
		if c.GetId() == req.GetId() {
			return &fieldv1.ClientGetResponse{Data: c}, nil
		}
	}
	return nil, connect.NewError(connect.CodeNotFound, "no client")
}

type borrowerLoansServer struct {
	loansv1connect.UnimplementedLoanManagementServiceHandler
	loans []*loansv1.LoanAccountObject
}

func (s *borrowerLoansServer) LoanAccountGet(
	_ context.Context,
	req *loansv1.LoanAccountGetRequest,
) (*loansv1.LoanAccountGetResponse, error) {
	for _, l := range s.loans {
		if l.GetId() == req.GetId() {
			return &loansv1.LoanAccountGetResponse{Data: l}, nil
		}
	}
	return nil, connect.NewError(connect.CodeNotFound, "no loan")
}

func (s *borrowerLoansServer) LoanAccountSearch(
	_ context.Context,
	req *loansv1.LoanAccountSearchRequest,
	stream loansv1connect.LoanManagementServiceLoanAccountSearchServerStream,
) error {
	var out []*loansv1.LoanAccountObject
	for _, l := range s.loans {
		if l.GetClientId() == req.GetClientId() {
			out = append(out, l)
		}
	}
	return stream.Send(&loansv1.LoanAccountSearchResponse{Data: out})
}

type contactProfiles struct {
	fakeProfiles
	byContact map[string]string
}

func (c *contactProfiles) GetByContact(
	_ context.Context,
	req *profilev1.GetByContactRequest,
) (*profilev1.GetByContactResponse, error) {
	id, ok := c.byContact[req.GetContact()]
	if !ok {
		return nil, connect.NewError(connect.CodeNotFound, "no profile")
	}
	return &profilev1.GetByContactResponse{Data: &profilev1.ProfileObject{Id: id}}, nil
}

func serveConnect(t *testing.T, register func(*connect.Server)) *connect.Client {
	t.Helper()
	mux := http.NewServeMux()
	server := connect.NewServer()
	register(server)
	connecthttp.Mount(mux, server)
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)
	return connect.NewClient(connecthttp.NewTransport(srv.Client(), srv.URL))
}

func newBorrowerRouting(
	t *testing.T,
	loans []*loansv1.LoanAccountObject,
) (*paymentRoutingBusiness, *incomingPaymentRepoStub, *allocOrderRepoStub) {
	t.Helper()
	field := &borrowerFieldServer{clients: []*fieldv1.ClientObject{{Id: "client-1", ProfileId: "profile-1"}}}
	fieldCli := fieldv1connect.NewFieldServiceClient(serveConnect(t, func(s *connect.Server) {
		fieldv1connect.RegisterFieldServiceHandler(s, field)
	}))
	loansSrv := &borrowerLoansServer{loans: loans}
	loansCli := loansv1connect.NewLoanManagementServiceClient(serveConnect(t, func(s *connect.Server) {
		loansv1connect.RegisterLoanManagementServiceHandler(s, loansSrv)
	}))
	paymentRepo := newIncomingPaymentRepoStub()
	orders := &allocOrderRepoStub{}
	return &paymentRoutingBusiness{
		eventsMan: &paymentEventsManagerStub{paymentRepo: paymentRepo},
		ipRepo:    paymentRepo,
		obRepo:    &obligationRepoStub{},
		toRepo:    orders,
		clients: &clients.PlatformClients{
			LenderIdentity: fieldCli,
			LenderLoanMgmt: loansCli,
			ProfileClient:  &contactProfiles{byContact: map[string]string{"+256701000111": "profile-1"}},
		},
	}, paymentRepo, orders
}

func activeLoan(id string) *loansv1.LoanAccountObject {
	return &loansv1.LoanAccountObject{Id: id, ClientId: "client-1", ProductId: "prod-1",
		Status: loansv1.LoanStatus_LOAN_STATUS_ACTIVE}
}

func TestBorrowerPaymentMatchedByPhoneAndBookedToTheLoan(t *testing.T) {
	routing, payments, orders := newBorrowerRouting(t, []*loansv1.LoanAccountObject{
		activeLoan("loan-1"),
		{Id: "loan-old", ClientId: "client-1", Status: loansv1.LoanStatus_LOAN_STATUS_PAID_OFF},
	})

	result, err := routing.IdentifyPayment(context.Background(), map[string]interface{}{
		"transaction_id":  "txn-b1",
		"amount":          int64(50_000),
		"currency":        "UGX",
		"payer_reference": "+256701000111",
		"properties":      data.JSONMap{},
	})
	require.NoError(t, err)
	assert.Equal(t, strategyBorrowerLoan, result["strategy"])
	assert.Equal(t, "loan-1", result["loan_id"])

	paymentID, _ := result["payment_id"].(string)
	payment, err := payments.GetByID(context.Background(), paymentID)
	require.NoError(t, err)
	assert.Equal(t, ownerTypeClientLoan, payment.OwnerType)

	alloc, err := routing.AllocatePayment(context.Background(), paymentID)
	require.NoError(t, err)
	assert.Equal(t, int64(50_000), alloc["allocated_amount"])

	order := orders.byReference["payment:"+paymentID+":loan:loan-1"]
	require.NotNil(t, order)
	assert.Equal(t, constants.ProductExternalCashAccount("prod-1"), order.DebitAccountRef)
	assert.Equal(t, constants.MemberLoansAccount("client-1"), order.CreditAccountRef)
	assert.Equal(t, int32(constants.TransferTypeLoanRepayment), order.OrderType)
	assert.Equal(t, allocationSourceMarker, order.ExtraData.GetString(extraKeySource))
	assert.Equal(t, channelMobileMoney, order.ExtraData.GetString(extraRepaymentChannel))
	assert.Equal(t, "loan-1", order.ExtraData.GetString("loan_id"))
}

func TestBorrowerPaymentMatchedByLoanReference(t *testing.T) {
	routing, _, _ := newBorrowerRouting(t, []*loansv1.LoanAccountObject{activeLoan("loan-1"), activeLoan("loan-2")})

	result, err := routing.IdentifyPayment(context.Background(), map[string]interface{}{
		"transaction_id":  "txn-b2",
		"amount":          int64(10_000),
		"currency":        "UGX",
		"reference":       "loan-2",
		"payer_reference": "+256701000111",
		"properties":      data.JSONMap{},
	})
	require.NoError(t, err)
	assert.Equal(t, "loan-2", result["loan_id"], "the quoted loan wins over the phone lookup")
}

func TestBorrowerPaymentWithTwoLoansAndNoReferenceIsNotGuessed(t *testing.T) {
	routing, _, _ := newBorrowerRouting(t, []*loansv1.LoanAccountObject{activeLoan("loan-1"), activeLoan("loan-2")})

	result, err := routing.IdentifyPayment(context.Background(), map[string]interface{}{
		"transaction_id":  "txn-b3",
		"amount":          int64(10_000),
		"currency":        "UGX",
		"payer_reference": "+256701000111",
		"product_id":      "prod-1",
		"properties":      data.JSONMap{},
	})
	require.NoError(t, err)
	assert.Equal(t, "unidentified", result["strategy"])
}
