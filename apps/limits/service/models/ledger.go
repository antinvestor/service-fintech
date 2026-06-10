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
	"time"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"github.com/pitabwire/frame/data"
	moneyx "github.com/pitabwire/util/moneyx"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// LedgerEntry is the per-(reservation, subject) row used by rolling-window
// scans. Created when a reservation is committed; its ReversedAt is set
// when the reservation is reversed.
//
//nolint:recvcheck // TableName uses a value receiver per GORM convention; converters need pointers
type LedgerEntry struct {
	data.BaseModel `gorm:"embedded"`

	ReservationID string     `gorm:"column:reservation_id;type:varchar(50);not null;index:idx_ledger_resv"`
	OrgUnitID     string     `gorm:"column:org_unit_id;type:varchar(50)"`
	Action        Action     `gorm:"column:action;type:varchar(64);not null"`
	SubjectType   Subject    `gorm:"column:subject_type;type:varchar(32);not null"`
	SubjectID     string     `gorm:"column:subject_id;type:varchar(50);not null"`
	CurrencyCode  string     `gorm:"column:currency_code;type:varchar(3);not null"`
	Amount        int64      `gorm:"column:amount;not null;check:amount >= 0"`
	CommittedAt   time.Time  `gorm:"column:committed_at;type:timestamptz;not null"`
	ReversedAt    *time.Time `gorm:"column:reversed_at;type:timestamptz"`
}

func (LedgerEntry) TableName() string { return "limits_ledger" }

// ToAPI converts to the wire shape.
func (e *LedgerEntry) ToAPI() *limitsv1.LedgerEntryObject {
	out := &limitsv1.LedgerEntryObject{
		Id:            e.ID,
		ReservationId: e.ReservationID,
		TenantId:      e.TenantID,
		OrgUnitId:     e.OrgUnitID,
		Action:        actionToAPI(e.Action),
		SubjectType:   subjectToAPI(e.SubjectType),
		SubjectId:     e.SubjectID,
		Amount:        moneyx.FromMinorUnitsByCurrency(e.CurrencyCode, e.Amount),
		CommittedAt:   timestamppb.New(e.CommittedAt),
	}
	if e.ReversedAt != nil {
		out.ReversedAt = timestamppb.New(*e.ReversedAt)
	}
	return out
}
