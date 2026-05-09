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
	"google.golang.org/protobuf/types/known/durationpb"
	"google.golang.org/protobuf/types/known/timestamppb"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
)

func TestPolicyFromAPIToModelRoundTrip(t *testing.T) {
	in := &limitsv1.PolicyObject{
		Id:            "pol-001",
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		OrgUnitId:     "branch-a",
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_ROLLING_WINDOW_AMOUNT,
		Window:        durationpb.New(24 * time.Hour),
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: 10_000, Nanos: 0},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_ENFORCE,
		ApprovalTtl:   durationpb.New(72 * time.Hour),
		EffectiveFrom: timestamppb.New(time.Date(2026, 5, 1, 0, 0, 0, 0, time.UTC)),
		Notes:         "test policy",
	}

	pol, err := PolicyFromAPI(in)
	require.NoError(t, err)
	assert.Equal(t, "pol-001", pol.ID)
	assert.Equal(t, ScopeOrg, pol.Scope)
	assert.Equal(t, "branch-a", pol.OrgUnitID)
	assert.Equal(t, ActionLoanDisbursement, pol.Action)
	assert.Equal(t, SubjectClient, pol.SubjectType)
	assert.Equal(t, "KES", pol.CurrencyCode)
	assert.Equal(t, KindRollingWindowAmount, pol.LimitKind)
	assert.Equal(t, int64(86400), pol.WindowSeconds)
	assert.Equal(t, int64(1_000_000), pol.Value) // 10_000.00 KES = 1_000_000 minor units
	assert.Equal(t, ModeEnforce, pol.Mode)
	assert.Equal(t, int64(259200), pol.ApprovalTTLSec)

	out := pol.ToAPI()
	assert.Equal(t, in.GetId(), out.GetId())
	assert.Equal(t, in.GetCurrencyCode(), out.GetCurrencyCode())
	assert.Equal(t, in.GetCapAmount().GetUnits(), out.GetCapAmount().GetUnits())
}

func TestPolicyFromAPIRejectsCurrencyMismatch(t *testing.T) {
	in := &limitsv1.PolicyObject{
		CurrencyCode: "USD",
		LimitKind:    limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:    &moneypb.Money{CurrencyCode: "KES", Units: 100},
	}
	_, err := PolicyFromAPI(in)
	require.Error(t, err)
}

func TestPolicyTableName(t *testing.T) {
	assert.Equal(t, "limits_policies", Policy{}.TableName())
	assert.Equal(t, "limits_policy_versions", PolicyVersion{}.TableName())
}
