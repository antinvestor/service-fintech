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
	"sync"
	"testing"

	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	paymentv1 "buf.build/gen/go/antinvestor/payment/protocolbuffers/go/v1"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/pkg/constants"
)

type fakeFieldClients struct {
	fieldv1connect.FieldServiceClient
	profiles map[string]string // client id -> profile id
}

func (f *fakeFieldClients) ClientGet(
	_ context.Context,
	req *fieldv1.ClientGetRequest,
) (*fieldv1.ClientGetResponse, error) {
	profileID, ok := f.profiles[req.GetId()]
	if !ok {
		return nil, connect.NewError(connect.CodeNotFound, "no client")
	}
	return &fieldv1.ClientGetResponse{Data: &fieldv1.ClientObject{Id: req.GetId(), ProfileId: profileID}}, nil
}

type fakeProfiles struct {
	profilev1connect.ProfileServiceClient
	contacts map[string][]string // profile id -> contact details
}

//nolint:revive,staticcheck // implements the generated profile client
func (f *fakeProfiles) GetById(
	_ context.Context,
	req *profilev1.GetByIdRequest,
) (*profilev1.GetByIdResponse, error) {
	details, ok := f.contacts[req.GetId()]
	if !ok {
		return nil, connect.NewError(connect.CodeNotFound, "no profile")
	}
	p := &profilev1.ProfileObject{Id: req.GetId()}
	for _, d := range details {
		p.Contacts = append(p.Contacts, &profilev1.ContactObject{Detail: d})
	}
	return &profilev1.GetByIdResponse{Data: p}, nil
}

// capturingPayment records the last Send request.
type capturingPayment struct {
	fakePayment
	mu   sync.Mutex
	last *paymentv1.SendRequest
}

func (c *capturingPayment) Send(ctx context.Context, req *paymentv1.SendRequest) (*paymentv1.SendResponse, error) {
	c.mu.Lock()
	c.last = req
	c.mu.Unlock()
	return c.fakePayment.Send(ctx, req)
}

func newDisbursementFixture(t *testing.T, extra data.JSONMap) (*executeFixture, *capturingPayment) {
	t.Helper()
	f := newExecuteFixture(t, int32(constants.StateJustCreated))
	f.repo.order.OrderType = constants.SafeInt32FromInt(constants.TransferTypeDisbursement)
	f.repo.order.ExtraData = extra
	pay := &capturingPayment{}
	f.biz.clients.PaymentClient = pay
	f.biz.clients.LenderIdentity = &fakeFieldClients{profiles: map[string]string{"client-1": "profile-1"}}
	f.biz.clients.ProfileClient = &fakeProfiles{contacts: map[string][]string{"profile-1": {"+256701000111"}}}
	return f, pay
}

func TestPayout_ClientRecipientResolvedAndDestinationSentToRail(t *testing.T) {
	f, pay := newDisbursementFixture(t, data.JSONMap{
		"recipient_client_id": "client-1",
		"payment_account_ref": "0701000111",
		"payment_channel":     "mobile_money",
	})

	require.NoError(t, f.biz.Execute(context.Background(), f.repo.order.GetID()))
	require.NotNil(t, pay.last)
	recipient := pay.last.GetData().GetRecipient()
	assert.Equal(t, "profile-1", recipient.GetProfileId(), "the client is paid through its profile")
	assert.Equal(t, "0701000111", recipient.GetDetail(), "the verified destination reaches the rail")
	assert.Equal(t, "mobile_money", pay.last.GetData().GetRoute())
}

func TestPayout_DestinationNotRecipientNeverPostsLedger(t *testing.T) {
	f, pay := newDisbursementFixture(t, data.JSONMap{
		"recipient_client_id": "client-1",
		"payment_account_ref": "+256709999999",
	})

	err := f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.ErrorIs(t, err, ErrPayoutDestinationNotRecipient)
	assert.Equal(t, 0, f.ledger.calls, "no money moves for a misdirected payout")
	assert.Empty(t, f.repo.snapshot().LedgerTransactionID)
	assert.Nil(t, pay.last)
}

func TestPayout_LegacyClientIDAsRecipientStillResolves(t *testing.T) {
	f, pay := newDisbursementFixture(t, data.JSONMap{
		"recipient_id":        "client-1",
		"payment_account_ref": "+256701000111",
	})

	require.NoError(t, f.biz.Execute(context.Background(), f.repo.order.GetID()))
	assert.Equal(t, "profile-1", pay.last.GetData().GetRecipient().GetProfileId())
}

func TestPayout_UnknownRecipientIsRefused(t *testing.T) {
	f, _ := newDisbursementFixture(t, data.JSONMap{"recipient_client_id": "client-missing"})

	err := f.biz.Execute(context.Background(), f.repo.order.GetID())
	require.ErrorIs(t, err, ErrPayoutRecipientUnresolved)
	assert.Equal(t, 0, f.ledger.calls)
}
