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

// Package models defines the persistence-layer types for the limits
// service. All models embed data.BaseModel so tenancy, audit, and version
// fields are managed by Frame's BeforeCreate/BeforeUpdate hooks.
package models

import (
	"errors"
	"time"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"github.com/pitabwire/frame/data"
	moneyx "github.com/pitabwire/util/moneyx"
	"google.golang.org/protobuf/types/known/durationpb"
	"google.golang.org/protobuf/types/known/timestamppb"
	"gorm.io/datatypes"
)

// Scope is a typed string alias so the GORM column is constrained at the
// type level. Like Mode, Kind, Subject, and Action below, keep the string
// values stable — they are persisted and surface in audit logs.
type Scope string

const (
	ScopePlatform Scope = "platform"
	ScopeOrg      Scope = "org"
	ScopeOrgUnit  Scope = "org_unit"
)

type Mode string

const (
	ModeOff     Mode = "off"
	ModeShadow  Mode = "shadow"
	ModeEnforce Mode = "enforce"
)

type Kind string

const (
	KindPerTxnMin           Kind = "per_txn_min"
	KindPerTxnMax           Kind = "per_txn_max"
	KindRollingWindowAmount Kind = "rolling_window_amount"
	KindRollingWindowCount  Kind = "rolling_window_count"
)

type Subject string

const (
	SubjectClient          Subject = "client"
	SubjectAccount         Subject = "account"
	SubjectProduct         Subject = "product"
	SubjectOrganization    Subject = "organization"
	SubjectOrgUnit         Subject = "org_unit"
	SubjectWorkforceMember Subject = "workforce_member"
)

type Action string

const (
	ActionLoanDisbursement     Action = "loan_disbursement"
	ActionLoanRequest          Action = "loan_request"
	ActionLoanRepayment        Action = "loan_repayment"
	ActionSavingsDeposit       Action = "savings_deposit"
	ActionSavingsWithdrawal    Action = "savings_withdrawal"
	ActionTransferOrderExecute Action = "transfer_order_execute"
	ActionIncomingPayment      Action = "incoming_payment"
	ActionFundingInflow        Action = "funding_inflow"
	ActionFundingOutflow       Action = "funding_outflow"
	ActionStawiContribution    Action = "stawi_contribution"
	ActionStawiPayout          Action = "stawi_payout"
)

// defaultApprovalTTL is applied when a policy does not specify an approval TTL.
const defaultApprovalTTL = 72 * time.Hour

// Policy is the rule definition. Tenant/Partition/Audit fields come from BaseModel.
//
//nolint:recvcheck // TableName uses a value receiver per GORM convention; converters need pointers
type Policy struct {
	data.BaseModel `gorm:"embedded"`

	Scope           Scope          `gorm:"column:scope;type:varchar(16);not null;index:idx_policy_lookup,priority:1"`
	OrgUnitID       string         `gorm:"column:org_unit_id;type:varchar(50);index:idx_policy_lookup,priority:2"`
	Action          Action         `gorm:"column:action;type:varchar(64);not null;index:idx_policy_lookup,priority:3"`
	SubjectType     Subject        `gorm:"column:subject_type;type:varchar(32);not null;index:idx_policy_lookup,priority:4"`
	CurrencyCode    string         `gorm:"column:currency_code;type:varchar(3);index:idx_policy_lookup,priority:5"`
	LimitKind       Kind           `gorm:"column:limit_kind;type:varchar(32);not null"`
	WindowSeconds   int64          `gorm:"column:window_seconds;not null;default:0"`
	Value           int64          `gorm:"column:value;not null;check:value >= 0"`
	Mode            Mode           `gorm:"column:mode;type:varchar(16);not null;default:'shadow'"`
	AttributeFilter datatypes.JSON `gorm:"column:attribute_filter;type:jsonb"`
	ApproverTiers   datatypes.JSON `gorm:"column:approver_tiers;type:jsonb"`
	ApprovalTTLSec  int64          `gorm:"column:approval_ttl_sec;not null;default:259200"`
	EffectiveFrom   time.Time      `gorm:"column:effective_from;type:timestamptz;not null"`
	EffectiveTo     *time.Time     `gorm:"column:effective_to;type:timestamptz"`
	Notes           string         `gorm:"column:notes;type:text"`
}

// TableName overrides the default snake_cased pluralisation.
func (Policy) TableName() string { return "limits_policies" }

// PolicyVersion is an append-only history row written on every save.
// Snapshot is the JSON-serialised pre-update state of the policy.
type PolicyVersion struct {
	data.BaseModel `gorm:"embedded"`

	PolicyID string         `gorm:"column:policy_id;type:varchar(50);not null;index"`
	Version  int32          `gorm:"column:version;not null"`
	Snapshot datatypes.JSON `gorm:"column:snapshot;type:jsonb;not null"`
}

func (PolicyVersion) TableName() string { return "limits_policy_versions" }

// PolicyFromAPI converts a wire PolicyObject into the persisted Policy. Returns
// errors for currency mismatches between the policy currency and the cap.
func PolicyFromAPI(in *limitsv1.PolicyObject) (*Policy, error) {
	if in == nil {
		return nil, errors.New("policy: nil input")
	}

	scope, err := scopeFromAPI(in.GetScope())
	if err != nil {
		return nil, err
	}
	subject, err := subjectFromAPI(in.GetSubjectType())
	if err != nil {
		return nil, err
	}
	action, err := actionFromAPI(in.GetAction())
	if err != nil {
		return nil, err
	}
	kind, err := kindFromAPI(in.GetLimitKind())
	if err != nil {
		return nil, err
	}
	mode, err := modeFromAPI(in.GetMode())
	if err != nil {
		return nil, err
	}

	value, err := valueFromAPI(in, kind)
	if err != nil {
		return nil, err
	}

	pol := &Policy{
		Scope:         scope,
		OrgUnitID:     in.GetOrgUnitId(),
		Action:        action,
		SubjectType:   subject,
		CurrencyCode:  in.GetCurrencyCode(),
		LimitKind:     kind,
		Value:         value,
		Mode:          mode,
		Notes:         in.GetNotes(),
		EffectiveFrom: timestampOrNow(in.GetEffectiveFrom()),
	}
	pol.ID = in.GetId()

	if d := in.GetWindow(); d != nil {
		pol.WindowSeconds = int64(d.AsDuration().Seconds())
	}
	if d := in.GetApprovalTtl(); d != nil {
		pol.ApprovalTTLSec = int64(d.AsDuration().Seconds())
	} else {
		pol.ApprovalTTLSec = int64(defaultApprovalTTL / time.Second)
	}
	if t := in.GetEffectiveTo(); t != nil {
		tt := t.AsTime()
		pol.EffectiveTo = &tt
	}

	if in.GetAttributeFilter() != nil {
		b, marshalErr := marshalStruct(in.GetAttributeFilter())
		if marshalErr != nil {
			return nil, marshalErr
		}
		pol.AttributeFilter = datatypes.JSON(b)
	}
	if len(in.GetApproverTiers()) > 0 {
		b, marshalErr := marshalApproverTiers(in.GetApproverTiers())
		if marshalErr != nil {
			return nil, marshalErr
		}
		pol.ApproverTiers = datatypes.JSON(b)
	}

	return pol, nil
}

// ToAPI converts a Policy back to the wire shape.
func (p *Policy) ToAPI() *limitsv1.PolicyObject {
	out := &limitsv1.PolicyObject{
		Id:            p.ID,
		TenantId:      p.TenantID,
		Scope:         scopeToAPI(p.Scope),
		OrgUnitId:     p.OrgUnitID,
		Action:        actionToAPI(p.Action),
		SubjectType:   subjectToAPI(p.SubjectType),
		CurrencyCode:  p.CurrencyCode,
		LimitKind:     kindToAPI(p.LimitKind),
		Mode:          modeToAPI(p.Mode),
		Notes:         p.Notes,
		Version:       int32(p.Version), //nolint:gosec // version counters never approach int32 range
		EffectiveFrom: timestamppb.New(p.EffectiveFrom),
		ApprovalTtl:   durationpb.New(time.Duration(p.ApprovalTTLSec) * time.Second),
		CreatedAt:     timestamppb.New(p.CreatedAt),
		ModifiedAt:    timestamppb.New(p.ModifiedAt),
	}
	if p.WindowSeconds > 0 {
		out.Window = durationpb.New(time.Duration(p.WindowSeconds) * time.Second)
	}
	if p.LimitKind == KindRollingWindowCount {
		out.CapCount = p.Value
	} else {
		out.CapAmount = moneyx.FromMinorUnitsByCurrency(p.CurrencyCode, p.Value)
	}
	if p.EffectiveTo != nil {
		out.EffectiveTo = timestamppb.New(*p.EffectiveTo)
	}
	if len(p.AttributeFilter) > 0 {
		s, err := unmarshalStruct(p.AttributeFilter)
		if err == nil {
			out.AttributeFilter = s
		}
	}
	if len(p.ApproverTiers) > 0 {
		tiers, err := unmarshalApproverTiers(p.ApproverTiers)
		if err == nil {
			out.ApproverTiers = tiers
		}
	}
	return out
}

func valueFromAPI(in *limitsv1.PolicyObject, kind Kind) (int64, error) {
	if kind == KindRollingWindowCount {
		return in.GetCapCount(), nil
	}
	capAmt := in.GetCapAmount()
	if capAmt == nil {
		return 0, nil
	}
	return moneyx.ToMinorUnitsByCurrency(capAmt, in.GetCurrencyCode())
}

func timestampOrNow(t *timestamppb.Timestamp) time.Time {
	if t == nil {
		return time.Now().UTC()
	}
	return t.AsTime()
}
