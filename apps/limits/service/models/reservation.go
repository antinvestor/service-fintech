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
	"errors"
	"time"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"github.com/pitabwire/frame/v2/data"
	moneyx "github.com/pitabwire/util/moneyx"
	"google.golang.org/protobuf/types/known/timestamppb"
	"gorm.io/datatypes"
)

// ReservationStatus is the state machine for a reservation.
type ReservationStatus string

const (
	ReservationStatusActive          ReservationStatus = "active"
	ReservationStatusPendingApproval ReservationStatus = "pending_approval"
	ReservationStatusCommitted       ReservationStatus = "committed"
	ReservationStatusReleased        ReservationStatus = "released"
	ReservationStatusReversed        ReservationStatus = "reversed"
	ReservationStatusExpired         ReservationStatus = "expired"
)

// Reservation is the per-intent hold against the usage budget.
//
//nolint:recvcheck // TableName uses a value receiver per GORM convention; converters need pointers
type Reservation struct {
	data.BaseModel `gorm:"embedded"`

	IdempotencyKey        string            `gorm:"column:idempotency_key;type:varchar(80);not null"`
	OrgUnitID             string            `gorm:"column:org_unit_id;type:varchar(50);index:idx_resv_window,priority:1"`
	Action                Action            `gorm:"column:action;type:varchar(64);not null;index:idx_resv_window,priority:2"`
	CurrencyCode          string            `gorm:"column:currency_code;type:varchar(3);not null;index:idx_resv_window,priority:3"`
	Amount                int64             `gorm:"column:amount;not null;check:amount >= 0"`
	SubjectRefs           datatypes.JSON    `gorm:"column:subject_refs;type:jsonb;not null"`
	MakerID               string            `gorm:"column:maker_id;type:varchar(50);not null"`
	Status                ReservationStatus `gorm:"column:status;type:varchar(24);not null;index:idx_resv_window,priority:4"`
	PoliciesEvaluated     datatypes.JSON    `gorm:"column:policies_evaluated;type:jsonb;not null"`
	IsShadow              bool              `gorm:"column:is_shadow;not null;default:false"`
	ReservedAt            time.Time         `gorm:"column:reserved_at;type:timestamptz;not null"`
	TTLAt                 time.Time         `gorm:"column:ttl_at;type:timestamptz;not null;index:idx_resv_ttl"`
	CommittedAt           *time.Time        `gorm:"column:committed_at;type:timestamptz;index:idx_resv_window,priority:5"`
	ReleasedAt            *time.Time        `gorm:"column:released_at;type:timestamptz"`
	ReversesReservationID *string           `gorm:"column:reverses_reservation_id;type:varchar(50);index"`
	Notes                 string            `gorm:"column:notes;type:text"`
}

func (Reservation) TableName() string { return "limits_reservations" }

// ReservationFromIntent constructs an unsaved Reservation from a wire intent.
// The IsShadow flag and Status are decided by the evaluator afterwards.
func ReservationFromIntent(intent *limitsv1.LimitIntent, idempotencyKey string) (*Reservation, error) {
	if intent == nil {
		return nil, errors.New("reservation: nil intent")
	}
	currency := intent.GetAmount().GetCurrencyCode()
	amountMinor, err := moneyx.ToMinorUnitsByCurrency(intent.GetAmount(), currency)
	if err != nil {
		return nil, err
	}
	action, err := actionFromAPI(intent.GetAction())
	if err != nil {
		return nil, err
	}
	subjectsJSON, err := marshalSubjectRefs(intent.GetSubjects())
	if err != nil {
		return nil, err
	}
	return &Reservation{
		IdempotencyKey: idempotencyKey,
		OrgUnitID:      intent.GetOrgUnitId(),
		Action:         action,
		CurrencyCode:   currency,
		Amount:         amountMinor,
		SubjectRefs:    datatypes.JSON(subjectsJSON),
		MakerID:        intent.GetMakerId(),
		Status:         ReservationStatusActive, // overridden by evaluator if approval required
		ReservedAt:     time.Now().UTC(),
	}, nil
}

// ToAPI converts a persisted Reservation to its wire shape.
func (r *Reservation) ToAPI() *limitsv1.ReservationObject {
	out := &limitsv1.ReservationObject{
		Id:             r.ID,
		TenantId:       r.TenantID,
		IdempotencyKey: r.IdempotencyKey,
		OrgUnitId:      r.OrgUnitID,
		Action:         actionToAPI(r.Action),
		Amount:         moneyx.FromMinorUnitsByCurrency(r.CurrencyCode, r.Amount),
		MakerId:        r.MakerID,
		Status:         reservationStatusToAPI(r.Status),
		IsShadow:       r.IsShadow,
		ReservedAt:     timestamppb.New(r.ReservedAt),
		TtlAt:          timestamppb.New(r.TTLAt),
	}
	if subjects, err := unmarshalSubjectRefs(r.SubjectRefs); err == nil {
		out.Subjects = subjects
	}
	if r.CommittedAt != nil {
		out.CommittedAt = timestamppb.New(*r.CommittedAt)
	}
	if r.ReleasedAt != nil {
		out.ReleasedAt = timestamppb.New(*r.ReleasedAt)
	}
	return out
}

func reservationStatusToAPI(s ReservationStatus) limitsv1.ReservationStatus {
	switch s {
	case ReservationStatusActive:
		return limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE
	case ReservationStatusPendingApproval:
		return limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL
	case ReservationStatusCommitted:
		return limitsv1.ReservationStatus_RESERVATION_STATUS_COMMITTED
	case ReservationStatusReleased:
		return limitsv1.ReservationStatus_RESERVATION_STATUS_RELEASED
	case ReservationStatusReversed:
		return limitsv1.ReservationStatus_RESERVATION_STATUS_REVERSED
	case ReservationStatusExpired:
		return limitsv1.ReservationStatus_RESERVATION_STATUS_EXPIRED
	default:
		return limitsv1.ReservationStatus_RESERVATION_STATUS_UNSPECIFIED
	}
}
