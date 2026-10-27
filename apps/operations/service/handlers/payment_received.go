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
	"encoding/json"
	"fmt"
	"strings"

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"github.com/pitabwire/util/decimalx"
	moneyx "github.com/pitabwire/util/moneyx"

	"github.com/antinvestor/service-fintech/apps/operations/service/business"
)

// railPayment is an inbound payment as the payment service publishes it to
// a receive route: its model, encoded as JSON. Only the fields operations
// reads are declared; the payer is named by profile and contact id, never by
// number.
type railPayment struct {
	ID              string            `json:"ID"`
	TenantID        string            `json:"TenantID"`
	PartitionID     string            `json:"PartitionID"`
	SenderProfileID string            `json:"SenderProfileID"`
	SenderContactID string            `json:"SenderContactID"`
	Amount          *decimalx.Decimal `json:"amount"`
	Currency        string            `json:"Currency"`
	TransactionID   string            `json:"TransactionID"`
	ReferenceID     string            `json:"ReferenceID"`
	OutBound        bool              `json:"OutBound"`
	Extra           data.JSONMap      `json:"extra"`
}

// PaymentReceived consumes the payments the rail received for the lender
// and books each one: an individual's payment is matched to their loan or
// savings account and applied at once; anything else waits for staff in the
// unmatched list. The rail's payment id is the transaction id, so a
// redelivered message books nothing twice.
type PaymentReceived struct {
	routing business.PaymentRoutingBusiness
	subject string
}

// NewPaymentReceived builds the consumer. subject is this service's own
// identity, under which each payment is booked inside its partition.
func NewPaymentReceived(routing business.PaymentRoutingBusiness, subject string) *PaymentReceived {
	return &PaymentReceived{routing: routing, subject: subject}
}

// Handle books one received payment. A message that is not an inbound
// payment is dropped; a booking failure is returned so the queue redelivers.
func (h *PaymentReceived) Handle(ctx context.Context, _ map[string]string, message []byte) error {
	var p railPayment
	if err := json.Unmarshal(message, &p); err != nil {
		util.Log(ctx).WithError(err).Warn("received payment message is not a payment; dropped")
		return nil
	}
	if p.OutBound || p.ID == "" || p.Amount == nil || p.Currency == "" || p.PartitionID == "" {
		util.Log(ctx).WithField("payment_id", p.ID).Warn("received payment message is incomplete; dropped")
		return nil
	}
	amount := moneyx.ToSmallestUnit(moneyx.ToMoney(p.Currency, *p.Amount), moneyx.Decimals(p.Currency))
	if amount <= 0 {
		util.Log(ctx).WithField("payment_id", p.ID).Warn("received payment has no amount; dropped")
		return nil
	}

	properties := data.JSONMap{
		"rail_payment_id":     p.ID,
		"rail_transaction_id": p.TransactionID,
		"payer_contact_id":    p.SenderContactID,
	}
	// Only named, informational extras are kept: the payment's properties
	// also carry what identification and allocation decided (owner, profile,
	// remainder), which nothing on the wire may set.
	for _, key := range railExtrasKept() {
		if v := strings.TrimSpace(p.Extra.GetString(key)); v != "" {
			properties[key] = v
		}
	}

	_, err := h.routing.IdentifyPayment(h.actIn(ctx, p), map[string]interface{}{
		"transaction_id":  p.ID,
		"amount":          amount,
		"currency":        p.Currency,
		"payer_reference": p.SenderProfileID,
		"product_id":      p.Extra.GetString("product_id"),
		"group_id":        p.Extra.GetString("group_id"),
		"reference":       railReference(p),
		"properties":      properties,
	})
	if err != nil {
		return fmt.Errorf("book received payment %s: %w", p.ID, err)
	}
	return nil
}

// railExtrasKept are the extras a received payment's properties keep.
func railExtrasKept() []string { return []string{"prompt_id", "purpose"} }

// railReference is the account the payer said the money is for: the loan or
// savings account a collection prompt named, else what the payer quoted.
func railReference(p railPayment) string {
	for _, key := range []string{"loan_account_id", "savings_account_id"} {
		if v := strings.TrimSpace(p.Extra.GetString(key)); v != "" {
			return v
		}
	}
	return strings.TrimSpace(p.ReferenceID)
}

// actIn is ctx as this service acting inside the payment's partition. The
// topic carries only the payment service's messages, and every lookup that
// follows runs in this partition: a payment whose partition does not hold
// the loan or account it names matches nothing and waits for staff.
//
// The partition is also set as the context's tenancy. An internal
// principal's claims are read through it, so without it whatever tenancy the
// queue message carried would override the payment's; and the peer clients
// name the tenant they act in (X-Tenant-Id) only from it, so without it every
// lookup in the loans service is refused for naming no tenant.
func (h *PaymentReceived) actIn(ctx context.Context, p railPayment) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:    p.TenantID,
		PartitionID: p.PartitionID,
		Roles:       []string{security.ConstantSystemInternalRole},
	}
	claims.Subject = h.subject
	return util.SetTenancy(claims.ClaimsToContext(ctx, security.WithoutInternalTenancySkip()), claims)
}
