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
	"encoding/json"
	"errors"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/types/known/structpb"
)

// ─── Enum mappers (proto ↔ string typed alias) ────────────────────────

func scopeFromAPI(s limitsv1.PolicyScope) (Scope, error) {
	switch s {
	case limitsv1.PolicyScope_POLICY_SCOPE_PLATFORM:
		return ScopePlatform, nil
	case limitsv1.PolicyScope_POLICY_SCOPE_ORG:
		return ScopeOrg, nil
	case limitsv1.PolicyScope_POLICY_SCOPE_ORG_UNIT:
		return ScopeOrgUnit, nil
	case limitsv1.PolicyScope_POLICY_SCOPE_UNSPECIFIED:
		return "", errors.New("policy: invalid scope")
	default:
		return "", errors.New("policy: invalid scope")
	}
}

func scopeToAPI(s Scope) limitsv1.PolicyScope {
	switch s {
	case ScopePlatform:
		return limitsv1.PolicyScope_POLICY_SCOPE_PLATFORM
	case ScopeOrg:
		return limitsv1.PolicyScope_POLICY_SCOPE_ORG
	case ScopeOrgUnit:
		return limitsv1.PolicyScope_POLICY_SCOPE_ORG_UNIT
	default:
		return limitsv1.PolicyScope_POLICY_SCOPE_UNSPECIFIED
	}
}

func subjectFromAPI(s limitsv1.SubjectType) (Subject, error) {
	switch s {
	case limitsv1.SubjectType_SUBJECT_TYPE_CLIENT:
		return SubjectClient, nil
	case limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT:
		return SubjectAccount, nil
	case limitsv1.SubjectType_SUBJECT_TYPE_PRODUCT:
		return SubjectProduct, nil
	case limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION:
		return SubjectOrganization, nil
	case limitsv1.SubjectType_SUBJECT_TYPE_ORG_UNIT:
		return SubjectOrgUnit, nil
	case limitsv1.SubjectType_SUBJECT_TYPE_WORKFORCE_MEMBER:
		return SubjectWorkforceMember, nil
	case limitsv1.SubjectType_SUBJECT_TYPE_UNSPECIFIED:
		return "", errors.New("policy: invalid subject type")
	default:
		return "", errors.New("policy: invalid subject type")
	}
}

func subjectToAPI(s Subject) limitsv1.SubjectType {
	switch s {
	case SubjectClient:
		return limitsv1.SubjectType_SUBJECT_TYPE_CLIENT
	case SubjectAccount:
		return limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT
	case SubjectProduct:
		return limitsv1.SubjectType_SUBJECT_TYPE_PRODUCT
	case SubjectOrganization:
		return limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION
	case SubjectOrgUnit:
		return limitsv1.SubjectType_SUBJECT_TYPE_ORG_UNIT
	case SubjectWorkforceMember:
		return limitsv1.SubjectType_SUBJECT_TYPE_WORKFORCE_MEMBER
	default:
		return limitsv1.SubjectType_SUBJECT_TYPE_UNSPECIFIED
	}
}

func actionFromAPI(a limitsv1.LimitAction) (Action, error) {
	switch a {
	case limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT:
		return ActionLoanDisbursement, nil
	case limitsv1.LimitAction_LIMIT_ACTION_LOAN_REQUEST:
		return ActionLoanRequest, nil
	case limitsv1.LimitAction_LIMIT_ACTION_LOAN_REPAYMENT:
		return ActionLoanRepayment, nil
	case limitsv1.LimitAction_LIMIT_ACTION_SAVINGS_DEPOSIT:
		return ActionSavingsDeposit, nil
	case limitsv1.LimitAction_LIMIT_ACTION_SAVINGS_WITHDRAWAL:
		return ActionSavingsWithdrawal, nil
	case limitsv1.LimitAction_LIMIT_ACTION_TRANSFER_ORDER_EXECUTE:
		return ActionTransferOrderExecute, nil
	case limitsv1.LimitAction_LIMIT_ACTION_INCOMING_PAYMENT:
		return ActionIncomingPayment, nil
	case limitsv1.LimitAction_LIMIT_ACTION_FUNDING_INFLOW:
		return ActionFundingInflow, nil
	case limitsv1.LimitAction_LIMIT_ACTION_FUNDING_OUTFLOW:
		return ActionFundingOutflow, nil
	case limitsv1.LimitAction_LIMIT_ACTION_STAWI_CONTRIBUTION:
		return ActionStawiContribution, nil
	case limitsv1.LimitAction_LIMIT_ACTION_STAWI_PAYOUT:
		return ActionStawiPayout, nil
	case limitsv1.LimitAction_LIMIT_ACTION_UNSPECIFIED:
		return "", errors.New("policy: invalid action")
	default:
		return "", errors.New("policy: invalid action")
	}
}

func actionToAPI(a Action) limitsv1.LimitAction {
	switch a {
	case ActionLoanDisbursement:
		return limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT
	case ActionLoanRequest:
		return limitsv1.LimitAction_LIMIT_ACTION_LOAN_REQUEST
	case ActionLoanRepayment:
		return limitsv1.LimitAction_LIMIT_ACTION_LOAN_REPAYMENT
	case ActionSavingsDeposit:
		return limitsv1.LimitAction_LIMIT_ACTION_SAVINGS_DEPOSIT
	case ActionSavingsWithdrawal:
		return limitsv1.LimitAction_LIMIT_ACTION_SAVINGS_WITHDRAWAL
	case ActionTransferOrderExecute:
		return limitsv1.LimitAction_LIMIT_ACTION_TRANSFER_ORDER_EXECUTE
	case ActionIncomingPayment:
		return limitsv1.LimitAction_LIMIT_ACTION_INCOMING_PAYMENT
	case ActionFundingInflow:
		return limitsv1.LimitAction_LIMIT_ACTION_FUNDING_INFLOW
	case ActionFundingOutflow:
		return limitsv1.LimitAction_LIMIT_ACTION_FUNDING_OUTFLOW
	case ActionStawiContribution:
		return limitsv1.LimitAction_LIMIT_ACTION_STAWI_CONTRIBUTION
	case ActionStawiPayout:
		return limitsv1.LimitAction_LIMIT_ACTION_STAWI_PAYOUT
	default:
		return limitsv1.LimitAction_LIMIT_ACTION_UNSPECIFIED
	}
}

func kindFromAPI(k limitsv1.LimitKind) (Kind, error) {
	switch k {
	case limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MIN:
		return KindPerTxnMin, nil
	case limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX:
		return KindPerTxnMax, nil
	case limitsv1.LimitKind_LIMIT_KIND_ROLLING_WINDOW_AMOUNT:
		return KindRollingWindowAmount, nil
	case limitsv1.LimitKind_LIMIT_KIND_ROLLING_WINDOW_COUNT:
		return KindRollingWindowCount, nil
	case limitsv1.LimitKind_LIMIT_KIND_UNSPECIFIED:
		return "", errors.New("policy: invalid kind")
	default:
		return "", errors.New("policy: invalid kind")
	}
}

func kindToAPI(k Kind) limitsv1.LimitKind {
	switch k {
	case KindPerTxnMin:
		return limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MIN
	case KindPerTxnMax:
		return limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX
	case KindRollingWindowAmount:
		return limitsv1.LimitKind_LIMIT_KIND_ROLLING_WINDOW_AMOUNT
	case KindRollingWindowCount:
		return limitsv1.LimitKind_LIMIT_KIND_ROLLING_WINDOW_COUNT
	default:
		return limitsv1.LimitKind_LIMIT_KIND_UNSPECIFIED
	}
}

func modeFromAPI(m limitsv1.PolicyMode) (Mode, error) {
	switch m {
	case limitsv1.PolicyMode_POLICY_MODE_OFF:
		return ModeOff, nil
	case limitsv1.PolicyMode_POLICY_MODE_SHADOW:
		return ModeShadow, nil
	case limitsv1.PolicyMode_POLICY_MODE_ENFORCE:
		return ModeEnforce, nil
	case limitsv1.PolicyMode_POLICY_MODE_UNSPECIFIED:
		return "", errors.New("policy: invalid mode")
	default:
		return "", errors.New("policy: invalid mode")
	}
}

func modeToAPI(m Mode) limitsv1.PolicyMode {
	switch m {
	case ModeOff:
		return limitsv1.PolicyMode_POLICY_MODE_OFF
	case ModeShadow:
		return limitsv1.PolicyMode_POLICY_MODE_SHADOW
	case ModeEnforce:
		return limitsv1.PolicyMode_POLICY_MODE_ENFORCE
	default:
		return limitsv1.PolicyMode_POLICY_MODE_UNSPECIFIED
	}
}

// ─── JSON helpers for AttributeFilter (Struct) and ApproverTiers ─────

func marshalStruct(s *structpb.Struct) ([]byte, error) {
	if s == nil {
		return nil, nil
	}
	return protojson.Marshal(s)
}

func unmarshalStruct(b []byte) (*structpb.Struct, error) {
	if len(b) == 0 {
		//nolint:nilnil // empty column yields no struct and no error by contract
		return nil, nil
	}
	out := &structpb.Struct{}
	if err := protojson.Unmarshal(b, out); err != nil {
		return nil, err
	}
	return out, nil
}

func marshalApproverTiers(tiers []*limitsv1.ApproverTier) ([]byte, error) {
	type tierJSON struct {
		UpTo      int64  `json:"up_to"`
		Role      string `json:"role"`
		Approvers int32  `json:"approvers"`
	}
	out := make([]tierJSON, len(tiers))
	for i, t := range tiers {
		out[i] = tierJSON{UpTo: t.GetUpTo(), Role: t.GetRole(), Approvers: t.GetApprovers()}
	}
	return json.Marshal(out)
}

// ActionFromAPISafe returns ("", nil) for UNSPECIFIED so callers can use a
// zero-valued enum in search filters meaning "any action".
func ActionFromAPISafe(a limitsv1.LimitAction) (Action, error) {
	if a == limitsv1.LimitAction_LIMIT_ACTION_UNSPECIFIED {
		return "", nil
	}
	return actionFromAPI(a)
}

// ActionToAPISafe converts a stored Action back to the wire enum.
// Returns LIMIT_ACTION_UNSPECIFIED for unknown or empty values.
func ActionToAPISafe(a Action) limitsv1.LimitAction { return actionToAPI(a) }

// SubjectFromAPISafe is the search-friendly variant of subjectFromAPI.
func SubjectFromAPISafe(s limitsv1.SubjectType) (Subject, error) {
	if s == limitsv1.SubjectType_SUBJECT_TYPE_UNSPECIFIED {
		return "", nil
	}
	return subjectFromAPI(s)
}

// ModeFromAPISafe is the search-friendly variant of modeFromAPI.
func ModeFromAPISafe(m limitsv1.PolicyMode) (Mode, error) {
	if m == limitsv1.PolicyMode_POLICY_MODE_UNSPECIFIED {
		return "", nil
	}
	return modeFromAPI(m)
}

// ApprovalStatusFromAPISafe converts a proto ApprovalStatus to the stored string alias.
// Returns ("", nil) for UNSPECIFIED so the filter means "any status".
func ApprovalStatusFromAPISafe(s limitsv1.ApprovalStatus) (ApprovalStatus, error) {
	switch s {
	case limitsv1.ApprovalStatus_APPROVAL_STATUS_UNSPECIFIED:
		return "", nil
	case limitsv1.ApprovalStatus_APPROVAL_STATUS_PENDING:
		return ApprovalStatusPending, nil
	case limitsv1.ApprovalStatus_APPROVAL_STATUS_APPROVED:
		return ApprovalStatusApproved, nil
	case limitsv1.ApprovalStatus_APPROVAL_STATUS_REJECTED:
		return ApprovalStatusRejected, nil
	case limitsv1.ApprovalStatus_APPROVAL_STATUS_EXPIRED:
		return ApprovalStatusExpired, nil
	case limitsv1.ApprovalStatus_APPROVAL_STATUS_AUTO_REJECTED_ON_RECHECK:
		return ApprovalStatusAutoRejectedRecheck, nil
	default:
		return "", errors.New("approval: invalid status")
	}
}

func unmarshalApproverTiers(b []byte) ([]*limitsv1.ApproverTier, error) {
	if len(b) == 0 {
		return nil, nil
	}
	type tierJSON struct {
		UpTo      int64  `json:"up_to"`
		Role      string `json:"role"`
		Approvers int32  `json:"approvers"`
	}
	var raw []tierJSON
	if err := json.Unmarshal(b, &raw); err != nil {
		return nil, err
	}
	out := make([]*limitsv1.ApproverTier, len(raw))
	for i, t := range raw {
		out[i] = &limitsv1.ApproverTier{UpTo: t.UpTo, Role: t.Role, Approvers: t.Approvers}
	}
	return out, nil
}

// ─── Subject-ref JSON marshallers (used by Reservation) ──────────────

func marshalSubjectRefs(refs []*limitsv1.SubjectRef) ([]byte, error) {
	if len(refs) == 0 {
		return []byte("[]"), nil
	}
	type sr struct {
		Type string `json:"type"`
		ID   string `json:"id"`
	}
	out := make([]sr, len(refs))
	for i, r := range refs {
		out[i] = sr{Type: subjectTypeJSON(r.GetType()), ID: r.GetId()}
	}
	return json.Marshal(out)
}

func unmarshalSubjectRefs(b []byte) ([]*limitsv1.SubjectRef, error) {
	if len(b) == 0 {
		return nil, nil
	}
	type sr struct {
		Type string `json:"type"`
		ID   string `json:"id"`
	}
	var raw []sr
	if err := json.Unmarshal(b, &raw); err != nil {
		return nil, err
	}
	out := make([]*limitsv1.SubjectRef, len(raw))
	for i, r := range raw {
		out[i] = &limitsv1.SubjectRef{Type: subjectTypeFromJSON(r.Type), Id: r.ID}
	}
	return out, nil
}

func subjectTypeJSON(t limitsv1.SubjectType) string {
	switch t {
	case limitsv1.SubjectType_SUBJECT_TYPE_CLIENT:
		return "client"
	case limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT:
		return "account"
	case limitsv1.SubjectType_SUBJECT_TYPE_PRODUCT:
		return "product"
	case limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION:
		return "organization"
	case limitsv1.SubjectType_SUBJECT_TYPE_ORG_UNIT:
		return "org_unit"
	case limitsv1.SubjectType_SUBJECT_TYPE_WORKFORCE_MEMBER:
		return "workforce_member"
	case limitsv1.SubjectType_SUBJECT_TYPE_UNSPECIFIED:
		return ""
	default:
		return ""
	}
}

func subjectTypeFromJSON(s string) limitsv1.SubjectType {
	switch s {
	case "client":
		return limitsv1.SubjectType_SUBJECT_TYPE_CLIENT
	case "account":
		return limitsv1.SubjectType_SUBJECT_TYPE_ACCOUNT
	case "product":
		return limitsv1.SubjectType_SUBJECT_TYPE_PRODUCT
	case "organization":
		return limitsv1.SubjectType_SUBJECT_TYPE_ORGANIZATION
	case "org_unit":
		return limitsv1.SubjectType_SUBJECT_TYPE_ORG_UNIT
	case "workforce_member":
		return limitsv1.SubjectType_SUBJECT_TYPE_WORKFORCE_MEMBER
	default:
		return limitsv1.SubjectType_SUBJECT_TYPE_UNSPECIFIED
	}
}
