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

package business_test

import (
	"time"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"google.golang.org/protobuf/types/known/durationpb"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
)

// TestReserve_ApprovalTTLIsOneSourceOfTruth asserts that a pending-approval
// reservation and its approval request always expire together, and that the
// deadline is the policy's clamped approval TTL: a stored zero (legacy row)
// falls back to the default instead of producing an instantly-expired
// approval, a sub-minimum value is raised to the minimum, and a normal value
// is honoured.
func (s *ReservationBusinessSuite) TestReserve_ApprovalTTLIsOneSourceOfTruth() {
	cases := []struct {
		name    string
		ttl     time.Duration
		wantTTL time.Duration
	}{
		{name: "zero falls back to default", ttl: 0, wantTTL: models.DefaultApprovalTTL},
		{name: "below minimum is clamped up", ttl: time.Minute, wantTTL: models.MinApprovalTTL},
		{name: "normal value is honoured", ttl: 2 * time.Hour, wantTTL: 2 * time.Hour},
	}
	for _, tc := range cases {
		s.Run(tc.name, func() {
			ctx, biz, dbPool, policyRepo, _ := s.resvEnv("tenant-a", "partition-a")

			// Seed through the repository (not PolicyBusiness.Save) so the row
			// carries exactly the raw TTL, as a legacy or hand-edited row would.
			in := approvalPolicy(1000, 1)
			in.ApprovalTtl = durationpb.New(tc.ttl)
			seedPolicy(ctx, s.T(), policyRepo, in)

			before := time.Now().UTC()
			resp, err := biz.Reserve(
				ctx,
				kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 5000),
				"ttl-"+tc.name,
				5*time.Minute,
			)
			s.Require().NoError(err)
			s.Require().Equal(limitsv1.ReservationStatus_RESERVATION_STATUS_PENDING_APPROVAL,
				resp.GetReservation().GetStatus())
			after := time.Now().UTC()

			ttlAt := resp.GetReservation().GetTtlAt().AsTime()
			s.WithinRange(ttlAt, before.Add(tc.wantTTL), after.Add(tc.wantTTL),
				"reservation ttl_at must be now + the clamped approval TTL")

			var approvals []*models.ApprovalRequest
			s.Require().NoError(dbPool.DB(ctx, true).
				Where("reservation_id = ?", resp.GetReservation().GetId()).
				Find(&approvals).Error)
			s.Require().Len(approvals, 1)
			s.Equal(models.ApprovalStatusPending, approvals[0].Status)
			s.WithinDuration(ttlAt, approvals[0].ExpiresAt, time.Millisecond,
				"approval expires_at and reservation ttl_at must be the same instant")
			s.True(approvals[0].ExpiresAt.After(after), "the approval must not be born expired")
		})
	}
}
