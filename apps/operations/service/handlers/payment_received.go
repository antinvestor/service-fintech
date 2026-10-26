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
	for k, v := range p.Extra {
		if _, taken := properties[k]; !taken {
			properties[k] = v
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

// actIn is ctx as this service acting inside the payment's partition.
func (h *PaymentReceived) actIn(ctx context.Context, p railPayment) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:    p.TenantID,
		PartitionID: p.PartitionID,
		Roles:       []string{security.ConstantSystemInternalRole},
	}
	claims.Subject = h.subject
	return claims.ClaimsToContext(ctx, security.WithoutInternalTenancySkip())
}
