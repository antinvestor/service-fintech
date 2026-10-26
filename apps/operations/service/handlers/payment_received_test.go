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

package handlers

import (
	"context"
	"errors"
	"testing"

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/operations/service/business"
)

// identifyRecorder records what the consumer asks routing to book.
type identifyRecorder struct {
	business.PaymentRoutingBusiness

	got    map[string]interface{}
	claims *security.AuthenticationClaims
	err    error
}

func (r *identifyRecorder) IdentifyPayment(
	ctx context.Context,
	paymentData map[string]interface{},
) (map[string]interface{}, error) {
	r.got = paymentData
	r.claims = security.ClaimsFromContext(ctx)
	return map[string]interface{}{}, r.err
}

// A payment as the payment service publishes it: its model as JSON.
const railPaymentJSON = `{
  "ID": "pay-rail-1",
  "TenantID": "tenant-1",
  "PartitionID": "partition-1",
  "SenderProfileID": "profile-1",
  "SenderContactID": "contact-1",
  "amount": "30000",
  "Currency": "UGX",
  "TransactionID": "MTN-77",
  "ReferenceID": "",
  "OutBound": false,
  "extra": {"product_id": "prod-1", "loan_account_id": "loan-1", "prompt_id": "pay-rail-1"}
}`

func TestReceivedPaymentIsBookedInItsPartitionByProfile(t *testing.T) {
	rec := &identifyRecorder{}
	h := NewPaymentReceived(rec, "service_operations")

	require.NoError(t, h.Handle(context.Background(), nil, []byte(railPaymentJSON)))

	require.NotNil(t, rec.got)
	assert.Equal(t, "pay-rail-1", rec.got["transaction_id"], "the rail's payment id makes redelivery book once")
	assert.Equal(t, int64(30_000), rec.got["amount"])
	assert.Equal(t, "UGX", rec.got["currency"])
	assert.Equal(t, "profile-1", rec.got["payer_reference"], "the payer is named by profile, never by number")
	assert.Equal(t, "prod-1", rec.got["product_id"])
	assert.Equal(t, "loan-1", rec.got["reference"])
	props, ok := rec.got["properties"].(data.JSONMap)
	require.True(t, ok)
	assert.Equal(t, "contact-1", props.GetString("payer_contact_id"))
	assert.Equal(t, "MTN-77", props.GetString("rail_transaction_id"))

	require.NotNil(t, rec.claims)
	assert.True(t, rec.claims.IsInternalSystem())
	assert.Equal(t, "tenant-1", rec.claims.GetTenantID())
	assert.Equal(t, "partition-1", rec.claims.GetPartitionID())
}

func TestReceivedPaymentMessagesThatAreNotInboundAreDropped(t *testing.T) {
	for name, msg := range map[string]string{
		"not json":     `not a payment`,
		"outbound":     `{"ID":"p","PartitionID":"x","amount":"10","Currency":"UGX","OutBound":true}`,
		"no amount":    `{"ID":"p","PartitionID":"x","Currency":"UGX"}`,
		"no partition": `{"ID":"p","amount":"10","Currency":"UGX"}`,
	} {
		t.Run(name, func(t *testing.T) {
			rec := &identifyRecorder{}
			require.NoError(t, NewPaymentReceived(rec, "svc").Handle(context.Background(), nil, []byte(msg)))
			assert.Nil(t, rec.got)
		})
	}
}

func TestReceivedPaymentBookingFailureIsRedelivered(t *testing.T) {
	rec := &identifyRecorder{err: errors.New("database unavailable")}
	err := NewPaymentReceived(rec, "svc").Handle(context.Background(), nil, []byte(railPaymentJSON))
	require.Error(t, err)
}
