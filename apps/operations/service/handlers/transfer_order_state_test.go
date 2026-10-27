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
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	operationsv1 "buf.build/gen/go/antinvestor/operations/protocolbuffers/go/operations/v1"
	moneyx "github.com/pitabwire/util/moneyx"
	"github.com/stretchr/testify/assert"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// A caller cannot hand operations an order that is already executing or
// already done: whatever state it names, a new order starts just created.
// (The proto STATE and the stored state are different enumerations;
// STATE_ACTIVE, which loans sends, is the stored "executing".)
func TestNewTransferOrderStartsJustCreatedWhateverStateTheCallerNames(t *testing.T) {
	for _, state := range []commonv1.STATE{
		commonv1.STATE_CREATED, commonv1.STATE_CHECKED, commonv1.STATE_ACTIVE,
		commonv1.STATE_INACTIVE, commonv1.STATE_DELETED,
	} {
		order := transferOrderFromAPI(context.Background(), &operationsv1.TransferOrderObject{
			DebitAccountRef:  "debit",
			CreditAccountRef: "credit",
			Amount:           moneyx.FromMinorUnitsByCurrency("KES", 1_000_00),
			Reference:        "disbursement:key",
			State:            state,
		})
		assert.Zero(t, order.State, "state %s must not be taken from the caller", state)
	}
}

// Callers read STATE_INACTIVE as "executed and settled". Only an executed
// order may read so; an order not yet executed, or closed without settling,
// must not.
func TestTransferOrderStateOnTheWire(t *testing.T) {
	cases := map[int32]commonv1.STATE{
		constants.StateJustCreated:  commonv1.STATE_CREATED,
		constants.StateCheckCreated: commonv1.STATE_CHECKED,
		constants.StateActive:       commonv1.STATE_ACTIVE,
		constants.StateInactive:     commonv1.STATE_INACTIVE,
		constants.StateDeleted:      commonv1.STATE_DELETED,
		constants.StateShutdown:     commonv1.STATE_DELETED,
	}
	for stored, want := range cases {
		got := transferOrderToAPI(&models.TransferOrder{State: stored, Currency: "KES"}).GetState()
		assert.Equal(t, want, got, "stored state %d", stored)
	}
}
