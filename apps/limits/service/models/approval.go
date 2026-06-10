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

// ApprovalStatus is the state machine for an ApprovalRequest.
type ApprovalStatus string

const (
	ApprovalStatusPending             ApprovalStatus = "pending"
	ApprovalStatusApproved            ApprovalStatus = "approved"
	ApprovalStatusRejected            ApprovalStatus = "rejected"
	ApprovalStatusExpired             ApprovalStatus = "expired"
	ApprovalStatusAutoRejectedRecheck ApprovalStatus = "auto_rejected_on_recheck"
)

// ApprovalRequest is one approval gate per (reservation, triggering policy).
// Multiple requests may exist for a single reservation if multiple policies
// each require approval; the reservation transitions to ACTIVE only when
// every request reaches APPROVED.
//
//nolint:recvcheck // TableName uses a value receiver per GORM convention; converters need pointers
type ApprovalRequest struct {
	data.BaseModel `gorm:"embedded"`

	ReservationID      string         `gorm:"column:reservation_id;type:varchar(50);not null;index"`
	OrgUnitID          string         `gorm:"column:org_unit_id;type:varchar(50)"`
	Action             Action         `gorm:"column:action;type:varchar(64);not null"`
	CurrencyCode       string         `gorm:"column:currency_code;type:varchar(3);not null"`
	Amount             int64          `gorm:"column:amount;not null;check:amount >= 0"`
	TriggeringPolicyID string         `gorm:"column:triggering_policy_id;type:varchar(50);not null"`
	PolicyVersion      int32          `gorm:"column:policy_version;not null"`
	RequiredRole       string         `gorm:"column:required_role;type:varchar(64);not null"`
	RequiredCount      int32          `gorm:"column:required_count;not null;check:required_count between 1 and 11"`
	MakerID            string         `gorm:"column:maker_id;type:varchar(50);not null"`
	Status             ApprovalStatus `gorm:"column:status;type:varchar(32);not null"`
	SubmittedAt        time.Time      `gorm:"column:submitted_at;type:timestamptz;not null"`
	ExpiresAt          time.Time      `gorm:"column:expires_at;type:timestamptz;not null;index"`
	DecidedAt          *time.Time     `gorm:"column:decided_at;type:timestamptz"`
}

func (ApprovalRequest) TableName() string { return "limits_approval_requests" }

// ApprovalDecision records a single approver's vote on an approval request.
// The unique-on-(approval_request_id, approver_id) constraint (declared in
// the SQL migration) prevents double-voting.
type ApprovalDecision struct {
	data.BaseModel `gorm:"embedded"`

	ApprovalRequestID string    `gorm:"column:approval_request_id;type:varchar(50);not null;index"`
	ApproverID        string    `gorm:"column:approver_id;type:varchar(50);not null"`
	Decision          string    `gorm:"column:decision;type:varchar(16);not null"` // approve | reject
	Note              string    `gorm:"column:note;type:text"`
	DecidedAt         time.Time `gorm:"column:decided_at;type:timestamptz;not null"`
}

func (ApprovalDecision) TableName() string { return "limits_approval_decisions" }

// ToAPI builds the wire shape from a request and its decisions.
func (r *ApprovalRequest) ToAPI(decisions []*ApprovalDecision) *limitsv1.ApprovalRequestObject {
	out := &limitsv1.ApprovalRequestObject{
		Id:                 r.ID,
		ReservationId:      r.ReservationID,
		TenantId:           r.TenantID,
		OrgUnitId:          r.OrgUnitID,
		TriggeringPolicyId: r.TriggeringPolicyID,
		PolicyVersion:      r.PolicyVersion,
		Action:             actionToAPI(r.Action),
		Amount:             moneyx.FromMinorUnitsByCurrency(r.CurrencyCode, r.Amount),
		RequiredRole:       r.RequiredRole,
		RequiredCount:      r.RequiredCount,
		MakerId:            r.MakerID,
		Status:             approvalStatusToAPI(r.Status),
		SubmittedAt:        timestamppb.New(r.SubmittedAt),
		ExpiresAt:          timestamppb.New(r.ExpiresAt),
	}
	if r.DecidedAt != nil {
		out.DecidedAt = timestamppb.New(*r.DecidedAt)
	}
	for _, d := range decisions {
		out.Decisions = append(out.Decisions, &limitsv1.ApprovalDecisionObject{
			ApproverId: d.ApproverID,
			Decision:   d.Decision,
			Note:       d.Note,
			DecidedAt:  timestamppb.New(d.DecidedAt),
		})
	}
	return out
}

func approvalStatusToAPI(s ApprovalStatus) limitsv1.ApprovalStatus {
	switch s {
	case ApprovalStatusPending:
		return limitsv1.ApprovalStatus_APPROVAL_STATUS_PENDING
	case ApprovalStatusApproved:
		return limitsv1.ApprovalStatus_APPROVAL_STATUS_APPROVED
	case ApprovalStatusRejected:
		return limitsv1.ApprovalStatus_APPROVAL_STATUS_REJECTED
	case ApprovalStatusExpired:
		return limitsv1.ApprovalStatus_APPROVAL_STATUS_EXPIRED
	case ApprovalStatusAutoRejectedRecheck:
		return limitsv1.ApprovalStatus_APPROVAL_STATUS_AUTO_REJECTED_ON_RECHECK
	default:
		return limitsv1.ApprovalStatus_APPROVAL_STATUS_UNSPECIFIED
	}
}
