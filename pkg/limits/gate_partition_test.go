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

package limits_test

import (
	"context"
	"testing"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-fintech/pkg/limits"
)

type tenancyRecorder struct {
	stubLimitsClient
	reservePartition string
	commitPartition  string
}

func (r *tenancyRecorder) Reserve(
	ctx context.Context,
	req *limitsv1.ReserveRequest,
) (*limitsv1.ReserveResponse, error) {
	if t := util.GetTenancy(ctx); t != nil {
		r.reservePartition = t.GetPartitionID()
	}
	return r.stubLimitsClient.Reserve(ctx, req)
}

func (r *tenancyRecorder) Commit(
	ctx context.Context,
	req *limitsv1.CommitRequest,
) (*limitsv1.CommitResponse, error) {
	if t := util.GetTenancy(ctx); t != nil {
		r.commitPartition = t.GetPartitionID()
	}
	return r.stubLimitsClient.Commit(ctx, req)
}

type callerTenancy struct{}

func (callerTenancy) GetTenantID() string    { return "tenant-1" }
func (callerTenancy) GetPartitionID() string { return "branch-office" }
func (callerTenancy) GetAccessID() string    { return "" }

func TestGate_InPartitionEvaluatesInTheRecordsPartition(t *testing.T) {
	rec := &tenancyRecorder{stubLimitsClient: stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{Reservation: &limitsv1.ReservationObject{
			Id: "r1", Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
		}},
		commitResp: &limitsv1.CommitResponse{},
	}}
	ctx := util.SetTenancy(context.Background(), callerTenancy{})

	var handlerPartition string
	err := limits.Gate(ctx, rec, &limitsv1.LimitIntent{}, "key", limits.ModeEnforce,
		func(inner context.Context, _ string) error {
			handlerPartition = util.GetTenancy(inner).GetPartitionID()
			return nil
		},
		limits.InPartition("tenant-1", "agent-portfolio"),
	)
	require.NoError(t, err)

	assert.Equal(t, "agent-portfolio", rec.reservePartition, "limits evaluate where the record sits")
	assert.Equal(t, "agent-portfolio", rec.commitPartition)
	assert.Equal(t, "branch-office", handlerPartition, "the operation itself keeps the caller's tenancy")
}

func TestGate_InPartitionWithoutIDsKeepsCallerTenancy(t *testing.T) {
	rec := &tenancyRecorder{stubLimitsClient: stubLimitsClient{
		reserveResp: &limitsv1.ReserveResponse{Reservation: &limitsv1.ReservationObject{
			Id: "r1", Status: limitsv1.ReservationStatus_RESERVATION_STATUS_ACTIVE,
		}},
		commitResp: &limitsv1.CommitResponse{},
	}}
	ctx := util.SetTenancy(context.Background(), callerTenancy{})

	require.NoError(t, limits.Gate(ctx, rec, &limitsv1.LimitIntent{}, "key", limits.ModeEnforce,
		func(context.Context, string) error { return nil }, limits.InPartition("", "")))
	assert.Equal(t, "branch-office", rec.reservePartition)
}
