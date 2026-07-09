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
	"testing"
	"time"

	moneypb "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/frametests"
	"github.com/pitabwire/frame/v2/frametests/definition"
	testpostgres "github.com/pitabwire/frame/v2/frametests/deps/testpostgres"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"
	"google.golang.org/protobuf/types/known/durationpb"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
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

	versions, err := s.biz.ListVersions(ctx, out.GetId())
	s.Require().NoError(err)
	s.Len(versions, 1)
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

	versions, err := s.biz.ListVersions(ctx, first.GetId())
	s.Require().NoError(err)
	s.Len(versions, 2)
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
