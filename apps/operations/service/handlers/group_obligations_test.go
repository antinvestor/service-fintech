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
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/apps/operations/service/business"
)

// obligationRecorder records what the handler asks the business to do.
type obligationRecorder struct {
	business.ObligationBusiness

	raised *business.GroupObligationsRaise
	closed *business.GroupPeriodClose
}

func (r *obligationRecorder) RaiseGroupObligations(
	_ context.Context,
	req business.GroupObligationsRaise,
) (*business.GroupPeriodStanding, error) {
	r.raised = &req
	return &business.GroupPeriodStanding{Currency: req.Currency, Members: []business.GroupMemberStanding{{
		MembershipID: "m1", ProfileID: "p1", Raised: true, Due: 150_000, Outstanding: 150_000,
	}}, Outstanding: 150_000}, nil
}

func (r *obligationRecorder) CloseGroupPeriod(
	_ context.Context,
	req business.GroupPeriodClose,
) (*business.GroupPeriodStanding, error) {
	r.closed = &req
	return &business.GroupPeriodStanding{Currency: "KES"}, nil
}

func internalCaller() context.Context {
	return (&security.AuthenticationClaims{
		Roles: []string{security.ConstantSystemInternalRole},
	}).ClaimsToContext(context.Background())
}

// What members owe comes only from the group service; a person holding the
// permission is still refused.
func TestGroupObligationsAreManagedOnlyByInternalServices(t *testing.T) {
	rec := &obligationRecorder{}
	srv := NewOperationsServer(nil, nil, rec, nil, nil, nil)
	staff := (&security.AuthenticationClaims{Roles: []string{"operator"}}).ClaimsToContext(context.Background())

	_, err := srv.GroupObligationsRaise(staff, &operationsv1.GroupObligationsRaiseRequest{GroupId: "g1"})
	require.Error(t, err)
	assert.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))
	_, err = srv.GroupPeriodClose(staff, &operationsv1.GroupPeriodCloseRequest{GroupId: "g1"})
	require.Error(t, err)
	assert.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))
	assert.Nil(t, rec.raised)
	assert.Nil(t, rec.closed)
}

func TestGroupObligationsRaiseConvertsMoneyToMinorUnits(t *testing.T) {
	rec := &obligationRecorder{}
	srv := NewOperationsServer(nil, nil, rec, nil, nil, nil)

	resp, err := srv.GroupObligationsRaise(internalCaller(), &operationsv1.GroupObligationsRaiseRequest{
		GroupId: "g1", PeriodId: "p1", CurrencyCode: "KES", DueAt: "2026-11-02T00:00:00Z",
		Members: []*operationsv1.GroupMemberObligation{{
			MembershipId: "m1", ProfileId: "p1",
			Amount: &commonv1.Money{CurrencyCode: "KES", Units: 1500},
		}},
	})
	require.NoError(t, err)
	require.NotNil(t, rec.raised)
	assert.EqualValues(t, 150_000, rec.raised.Members[0].Amount)
	assert.Equal(t, int64(1500), resp.GetMembers()[0].GetDue().GetUnits())

	_, err = srv.GroupObligationsRaise(internalCaller(), &operationsv1.GroupObligationsRaiseRequest{
		GroupId: "g1", PeriodId: "p1", CurrencyCode: "KES", DueAt: "2026-11-02T00:00:00Z",
		Members: []*operationsv1.GroupMemberObligation{{
			MembershipId: "m1", Amount: &commonv1.Money{CurrencyCode: "UGX", Units: 1500},
		}},
	})
	require.Error(t, err, "an amount in another currency is refused")

	_, err = srv.GroupObligationsRaise(internalCaller(), &operationsv1.GroupObligationsRaiseRequest{
		GroupId: "g1", PeriodId: "p1", CurrencyCode: "KES", DueAt: "next week",
	})
	require.Error(t, err, "the due date must be RFC3339")
}
