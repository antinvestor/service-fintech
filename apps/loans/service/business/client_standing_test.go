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

package business

import (
	"context"
	"errors"
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/field/connectrpc/go/v2/field/v1/fieldv1connect"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type stubFieldClients struct {
	fieldv1connect.FieldServiceClient
	states map[string]commonv1.STATE
	err    error
}

func (s *stubFieldClients) ClientGet(
	_ context.Context,
	req *fieldv1.ClientGetRequest,
) (*fieldv1.ClientGetResponse, error) {
	if s.err != nil {
		return nil, s.err
	}
	return &fieldv1.ClientGetResponse{Data: &fieldv1.ClientObject{
		Id: req.GetId(), State: s.states[req.GetId()],
	}}, nil
}

func TestApprove_RequiresAnActivatedClient(t *testing.T) {
	tests := []struct {
		name    string
		state   commonv1.STATE
		err     error
		wantErr error
	}{
		{name: "active client is approved", state: commonv1.STATE_ACTIVE},
		{name: "client awaiting activation", state: commonv1.STATE_CREATED, wantErr: ErrClientNotActive},
		{name: "inactive client", state: commonv1.STATE_INACTIVE, wantErr: ErrClientNotActive},
		{name: "identity unreachable", err: errors.New("down"), wantErr: ErrClientStandingUnverifiable},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			lr := submittedLoanRequest()
			b := buildLRBusiness(&stubLoanRequestRepo{request: lr}, &stubLoanProductRepo{}, nil, false)
			b.clientStanding = NewFieldClientStanding(&stubFieldClients{
				states: map[string]commonv1.STATE{lr.ClientID: tt.state},
				err:    tt.err,
			})

			result, err := b.Approve(context.Background(), lr.GetID())
			if tt.wantErr != nil {
				require.ErrorIs(t, err, tt.wantErr)
				assert.Equal(t, int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_SUBMITTED), lr.Status,
					"the request stays submitted")
				return
			}
			require.NoError(t, err)
			assert.Equal(t, loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED, result.GetStatus())
		})
	}
}
