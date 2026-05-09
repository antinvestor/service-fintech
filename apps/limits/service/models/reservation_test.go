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

package models

import (
	"testing"
	"time"

	moneypb "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/timestamppb"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
)

func TestReservationFromIntent(t *testing.T) {
	intent := &limitsv1.LimitIntent{
		Action:    limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		TenantId:  "t-1",
		OrgUnitId: "branch-a",
		Amount:    &moneypb.Money{CurrencyCode: "KES", Units: 100, Nanos: 0},
		Subjects:  []*limitsv1.SubjectRef{{Type: limitsv1.SubjectType_SUBJECT_TYPE_CLIENT, Id: "c1"}},
		MakerId:   "wf-1",
	}
	r, err := ReservationFromIntent(intent, "idem-1")
	require.NoError(t, err)
	assert.Equal(t, "idem-1", r.IdempotencyKey)
	assert.Equal(t, "branch-a", r.OrgUnitID)
	assert.Equal(t, ActionLoanDisbursement, r.Action)
	assert.Equal(t, "KES", r.CurrencyCode)
	assert.Equal(t, int64(10000), r.Amount) // 100.00 KES = 10000 minor units
	assert.Equal(t, "wf-1", r.MakerID)
	assert.Equal(t, ReservationStatusActive, r.Status) // default until evaluator overrides
}

func TestReservationToAPI(t *testing.T) {
	now := time.Date(2026, 5, 1, 0, 0, 0, 0, time.UTC)
	r := &Reservation{
		IdempotencyKey: "idem-1",
		OrgUnitID:      "branch-a",
		Action:         ActionLoanDisbursement,
		CurrencyCode:   "KES",
		Amount:         10000,
		MakerID:        "wf-1",
		Status:         ReservationStatusCommitted,
		ReservedAt:     now,
		TTLAt:          now.Add(5 * time.Minute),
	}
	r.ID = "res-1"
	r.TenantID = "t-1"
	out := r.ToAPI()
	assert.Equal(t, "res-1", out.GetId())
	assert.Equal(t, "t-1", out.GetTenantId())
	assert.Equal(t, limitsv1.ReservationStatus_RESERVATION_STATUS_COMMITTED, out.GetStatus())
	assert.Equal(t, int64(100), out.GetAmount().GetUnits())
	assert.Equal(t, timestamppb.New(now).AsTime(), out.GetReservedAt().AsTime())
}

func TestReservationTableName(t *testing.T) {
	assert.Equal(t, "limits_reservations", Reservation{}.TableName())
}
