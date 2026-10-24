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
	"strconv"
	"testing"
	"time"

	moneypb "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/frametests"
	"github.com/pitabwire/frame/v3/frametests/definition"
	testpostgres "github.com/pitabwire/frame/v3/frametests/deps/testpostgres"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"
	"google.golang.org/protobuf/types/known/durationpb"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

type PolicyBusinessSuite struct {
	frametests.FrameBaseTestSuite
	biz business.PolicyBusiness
}

func (s *PolicyBusinessSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *PolicyBusinessSuite) SetupTest() {
	ctx := s.T().Context()
	ctx = s.WithAuthClaims(ctx, "tenant-a", "partition-a", "test-user")

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-business-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctx, dbManager, ""))

	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	workMan := svc.WorkManager()
	policyRepo := repository.NewPolicyRepository(ctx, dbPool, workMan)
	versionRepo := repository.NewPolicyVersionRepository(ctx, dbPool, workMan)
	s.biz = business.NewPolicyBusiness(policyRepo, versionRepo, nil, nil, nil, nil)
}

func (s *PolicyBusinessSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

func (s *PolicyBusinessSuite) TestSaveCreatesPolicyAndVersion0() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "")
	in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_SHADOW)
	out, err := s.biz.Save(ctx, in)
	s.Require().NoError(err)
	s.NotEmpty(out.GetId())
	s.Equal(int32(1), out.GetVersion())

	history, err := s.biz.History(ctx, out.GetId(), nil)
	s.Require().NoError(err)
	s.Require().Len(history.Items, 1)
	s.Equal(int32(1), history.Items[0].Version)
	s.Empty(history.NextCursor)
}

func (s *PolicyBusinessSuite) TestSaveOnExistingPolicyAppendsVersion() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "")
	in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_SHADOW)
	first, err := s.biz.Save(ctx, in)
	s.Require().NoError(err)

	in.Id = first.GetId()
	in.Mode = limitsv1.PolicyMode_POLICY_MODE_ENFORCE
	second, err := s.biz.Save(ctx, in)
	s.Require().NoError(err)
	s.Equal(int32(2), second.GetVersion())
	s.Equal(limitsv1.PolicyMode_POLICY_MODE_ENFORCE, second.GetMode())

	history, err := s.biz.History(ctx, first.GetId(), nil)
	s.Require().NoError(err)
	s.Require().Len(history.Items, 2)
	s.Equal(int32(2), history.Items[0].Version, "history is newest first")
	s.Equal(limitsv1.PolicyMode_POLICY_MODE_ENFORCE, history.Items[0].Snapshot.GetMode())
	s.Equal(int32(1), history.Items[1].Version)
	s.Equal(limitsv1.PolicyMode_POLICY_MODE_SHADOW, history.Items[1].Snapshot.GetMode())
}

// TestHistoryPagesNewestFirst walks a five-version history two rows at a time
// and asserts the cursor hands back every version exactly once, newest first,
// and goes empty on the last page.
func (s *PolicyBusinessSuite) TestHistoryPagesNewestFirst() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "")
	in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_SHADOW)
	saved, err := s.biz.Save(ctx, in)
	s.Require().NoError(err)
	for i := range 4 {
		in.Id = saved.GetId()
		in.Version = saved.GetVersion()
		in.Notes = "edit " + strconv.Itoa(i+1)
		saved, err = s.biz.Save(ctx, in)
		s.Require().NoError(err)
	}

	var seen []int32
	cursor := &moneypb.PageCursor{Limit: 2}
	for range 4 {
		page, pErr := s.biz.History(ctx, saved.GetId(), cursor)
		s.Require().NoError(pErr)
		s.Require().LessOrEqual(len(page.Items), 2)
		for _, item := range page.Items {
			seen = append(seen, item.Version)
		}
		if page.NextCursor == "" {
			break
		}
		cursor = &moneypb.PageCursor{Limit: 2, Page: page.NextCursor}
	}
	s.Equal([]int32{5, 4, 3, 2, 1}, seen)

	_, err = s.biz.History(ctx, saved.GetId(), &moneypb.PageCursor{Page: "not-a-version"})
	s.Require().ErrorIs(err, business.ErrInvalidPolicy)

	_, err = s.biz.History(ctx, "missing-policy", nil)
	s.Require().ErrorIs(err, business.ErrPolicyNotFound)
}

func (s *PolicyBusinessSuite) TestSaveRejectsCurrencyMismatch() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "")
	in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_SHADOW)
	in.CapAmount = &moneypb.Money{CurrencyCode: "USD", Units: 100, Nanos: 0}
	_, err := s.biz.Save(ctx, in)
	s.Require().Error(err)
}

func (s *PolicyBusinessSuite) TestGetReturnsLatest() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "")
	in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_SHADOW)
	saved, err := s.biz.Save(ctx, in)
	s.Require().NoError(err)

	got, err := s.biz.Get(ctx, saved.GetId())
	s.Require().NoError(err)
	s.Equal(saved.GetId(), got.GetId())
}

func (s *PolicyBusinessSuite) TestDeleteSoftDeletesAndHidesFromGet() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "")
	in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_SHADOW)
	saved, err := s.biz.Save(ctx, in)
	s.Require().NoError(err)

	s.Require().NoError(s.biz.Delete(ctx, saved.GetId()))
	_, err = s.biz.Get(ctx, saved.GetId())
	s.Require().Error(err)
}

// TestSaveRejectsZeroCap asserts a "maximum" policy needs a real cap. A zero
// cap breaches every positive amount, so an operator who forgets the field
// would block the whole action rather than limit it.
func (s *PolicyBusinessSuite) TestSaveRejectsZeroCap() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "test-user")
	in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_ENFORCE)
	in.CapAmount = nil

	_, err := s.biz.Save(ctx, in)
	s.Require().Error(err)
	s.Require().ErrorIs(err, business.ErrInvalidPolicy)
}

// TestSaveClampsApprovalTTL asserts the stored approval window is the one the
// runtime will grant: an unset TTL becomes the default, a window shorter than
// the reaper's useful horizon is raised to the minimum (such requests would
// otherwise expire before a human can act), and a sane window is kept as is.
func (s *PolicyBusinessSuite) TestSaveClampsApprovalTTL() {
	cases := []struct {
		name string
		ttl  *durationpb.Duration
		want time.Duration
	}{
		{name: "unset falls back to default", ttl: nil, want: models.DefaultApprovalTTL},
		{name: "zero falls back to default", ttl: durationpb.New(0), want: models.DefaultApprovalTTL},
		{name: "below minimum is clamped up", ttl: durationpb.New(time.Minute), want: models.MinApprovalTTL},
		{name: "normal value is kept", ttl: durationpb.New(2 * time.Hour), want: 2 * time.Hour},
	}
	for _, tc := range cases {
		s.Run(tc.name, func() {
			ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "test-user")
			in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_ENFORCE)
			in.ApprovalTtl = tc.ttl

			out, err := s.biz.Save(ctx, in)
			s.Require().NoError(err)
			s.Equal(tc.want, out.GetApprovalTtl().AsDuration())

			stored, err := s.biz.Get(ctx, out.GetId())
			s.Require().NoError(err)
			s.Equal(tc.want, stored.GetApprovalTtl().AsDuration(), "the persisted row carries the clamped value")
		})
	}
}

// TestSaveSortsApproverTiers asserts the ladder is stored ascending with the
// catch-all last. pickTier returns the first covering tier, so a catch-all
// entered first would push every amount, however small, to the highest tier.
func (s *PolicyBusinessSuite) TestSaveSortsApproverTiers() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "test-user")
	in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_ENFORCE)
	in.ApproverTiers = []*limitsv1.ApproverTier{
		{UpTo: 0, Role: "cfo", Approvers: 2},
		{UpTo: 500000, Role: "branch_manager", Approvers: 1},
	}

	out, err := s.biz.Save(ctx, in)
	s.Require().NoError(err)
	s.Require().Len(out.GetApproverTiers(), 2)
	s.Equal("branch_manager", out.GetApproverTiers()[0].GetRole())
	s.Equal(int64(500000), out.GetApproverTiers()[0].GetUpTo())
	s.Equal("cfo", out.GetApproverTiers()[1].GetRole(), "the catch-all tier must come last")
}

// TestSaveRejectsInvalidApproverTiers asserts a tier without a role is refused
// with the dedicated sentinel rather than surfacing later as a runtime failure
// to resolve an approver.
func (s *PolicyBusinessSuite) TestSaveRejectsInvalidApproverTiers() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "test-user")
	in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_ENFORCE)
	in.ApproverTiers = []*limitsv1.ApproverTier{{UpTo: 100, Role: "", Approvers: 1}}

	_, err := s.biz.Save(ctx, in)
	s.Require().Error(err)
	s.Require().ErrorIs(err, business.ErrApproverTiersInvalid)
}

// TestSaveRejectsStaleVersion asserts a concurrent edit is refused instead of
// silently clobbering the other operator's change.
func (s *PolicyBusinessSuite) TestSaveRejectsStaleVersion() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "test-user")
	in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_SHADOW)
	first, err := s.biz.Save(ctx, in)
	s.Require().NoError(err)

	// Operator A saves, moving the stored version on.
	in.Id = first.GetId()
	in.Version = first.GetVersion()
	in.Notes = "operator A"
	second, err := s.biz.Save(ctx, in)
	s.Require().NoError(err)
	s.Greater(second.GetVersion(), first.GetVersion())

	// Operator B still holds the version they loaded before A saved.
	in.Version = first.GetVersion()
	in.Notes = "operator B"
	_, err = s.biz.Save(ctx, in)
	s.Require().Error(err)
	s.Require().ErrorIs(err, business.ErrPolicyVersionConflict)
}

// TestSaveRejectsPlatformScopeForTenantOperator asserts a tenant operator
// cannot create a cap that binds every other tenant.
func (s *PolicyBusinessSuite) TestSaveRejectsPlatformScopeForTenantOperator() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "test-user")
	in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_ENFORCE)
	in.Scope = limitsv1.PolicyScope_POLICY_SCOPE_PLATFORM

	_, err := s.biz.Save(ctx, in)
	s.Require().Error(err)
	s.Require().ErrorIs(err, business.ErrPolicyScopeForbidden)
}

func (s *PolicyBusinessSuite) TestSaveKeepsTheBranchTierUnambiguous() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-a", "partition-a", "test-user")

	noBranch := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_ENFORCE)
	noBranch.Scope = limitsv1.PolicyScope_POLICY_SCOPE_ORG_UNIT
	_, err := s.biz.Save(ctx, noBranch)
	s.Require().ErrorIs(err, business.ErrInvalidPolicy, "a branch policy must name its branch")

	orgWithBranch := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_ENFORCE)
	orgWithBranch.OrgUnitId = "branch-a"
	_, err = s.biz.Save(ctx, orgWithBranch)
	s.Require().ErrorIs(err, business.ErrInvalidPolicy, "an organization policy must not name a branch")

	branch := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_ENFORCE)
	branch.Scope = limitsv1.PolicyScope_POLICY_SCOPE_ORG_UNIT
	branch.OrgUnitId = " branch-a "
	saved, err := s.biz.Save(ctx, branch)
	s.Require().NoError(err)
	s.Equal("branch-a", saved.GetOrgUnitId())
}

func goodPolicyAPI(currency string, mode limitsv1.PolicyMode) *limitsv1.PolicyObject {
	return &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  currency,
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: currency, Units: 100, Nanos: 0},
		Mode:          mode,
		EffectiveFrom: timestamppb.New(time.Now().UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
	}
}

func TestPolicyBusinessSuite(t *testing.T) {
	suite.Run(t, new(PolicyBusinessSuite))
}
