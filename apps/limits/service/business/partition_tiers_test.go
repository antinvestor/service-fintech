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
	"context"
	"errors"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
)

// treeAncestry is a fixed partition tree:
//
//	p-org ─ p-region ─┬─ p-branch ── p-unit
//	                  └─ p-branch-2
type treeAncestry struct{ err error }

func (t treeAncestry) Chain(_ context.Context, id string) ([]string, error) {
	if t.err != nil {
		return nil, t.err
	}
	parent := map[string]string{
		"p-region": "p-org", "p-branch": "p-region", "p-branch-2": "p-region", "p-unit": "p-branch",
	}
	chain := []string{id}
	for p, ok := parent[id]; ok; p, ok = parent[p] {
		chain = append(chain, p)
	}
	return chain, nil
}

// TestPartitionTiers_AncestorsBindDescendantsOnly pins the hierarchy rule on
// a tree of any depth: a cap set on a partition binds that partition and
// every partition below it; a child may tighten but a looser child policy
// never lifts an ancestor's cap; and a policy on one branch never reaches a
// sibling branch or the partitions above it.
func (s *ReservationBusinessSuite) TestPartitionTiers_AncestorsBindDescendantsOnly() {
	ctx, biz, _, policyRepo, _ := s.resvEnv("tenant-a", "p-org", business.WithPartitionAncestry(treeAncestry{}))
	action := limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT
	in := func(partition string) context.Context {
		return s.WithAuthClaims(ctx, "tenant-a", partition, "test-user")
	}
	capAt := func(partition string, units int64) {
		seedPolicy(in(partition), s.T(), policyRepo, perTxnMaxPolicy("KES", units,
			limitsv1.PolicyMode_POLICY_MODE_ENFORCE, action, limitsv1.SubjectType_SUBJECT_TYPE_CLIENT))
	}
	capAt("p-org", 100_000)
	capAt("p-region", 80_000)
	capAt("p-branch", 50_000)
	capAt("p-unit", 200_000)    // looser than its ancestors: must not lift them
	capAt("p-branch-2", 10_000) // a sibling's tightening stays with the sibling

	cases := []struct {
		name      string
		partition string
		units     int64
		allowed   bool
	}{
		{"within every ancestor cap", "p-unit", 45_000, true},
		{"the branch cap binds the unit below it", "p-unit", 55_000, false},
		{"a looser child cap cannot lift the organization cap", "p-unit", 150_000, false},
		{"a sibling's tighter cap does not reach this branch", "p-unit", 15_000, true},
		{"the sibling branch is held to its own tighter cap", "p-branch-2", 15_000, false},
		{"the region cap binds the sibling branch", "p-branch-2", 5_000, true},
		{"the region cap binds the region", "p-region", 90_000, false},
		{"a branch cap does not reach its parent", "p-region", 70_000, true},
		{"only the organization cap binds the root", "p-org", 95_000, true},
		{"the organization cap binds the root", "p-org", 105_000, false},
	}
	for _, tc := range cases {
		resp, err := biz.Check(in(tc.partition), kesIntent(action, tc.units))
		s.Require().NoError(err, tc.name)
		s.Equal(tc.allowed, resp.GetAllowed(), tc.name)
	}
}

// TestPartitionTiers_UnplaceablePartitionFailsClosed: when the partition
// tree cannot be read, evaluation refuses rather than skipping the caps set
// on ancestors.
func (s *ReservationBusinessSuite) TestPartitionTiers_UnplaceablePartitionFailsClosed() {
	ctx, biz, _, _, _ := s.resvEnv("tenant-a", "p-unit",
		business.WithPartitionAncestry(treeAncestry{err: errors.New("tenancy unavailable")}))

	_, err := biz.Check(ctx, kesIntent(limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT, 1))
	s.Require().Error(err)
	var connectErr *connect.Error
	s.Require().ErrorAs(err, &connectErr)
	s.Equal(connect.CodeUnavailable, connectErr.Code())
}
