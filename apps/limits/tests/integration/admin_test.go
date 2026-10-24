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

// Package integration provides full-stack RPC lifecycle tests for the limits
// admin service. Tests run against a real Postgres testcontainer and a real
// Connect-over-HTTP transport using net/http/httptest.Server. This catches
// serialisation / transport regressions that in-process unit tests miss.
//
// Auth approach: the server mux is mounted with a single fixedClaimsInterceptor
// that injects deterministic tenant/partition claims into every request context.
// This deliberately skips the production auth stack (JWT + Keto) because this
// test's job is to exercise the handler→business→repository path, not the
// security path (which has its own tests).
package integration

import (
	"context"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	moneypb "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"buf.build/gen/go/antinvestor/limits/connectrpc/go/v2/limits/v1/limitsv1connect"
	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/frametests"
	"github.com/pitabwire/frame/v3/frametests/definition"
	testpostgres "github.com/pitabwire/frame/v3/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"
	"google.golang.org/protobuf/types/known/durationpb"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/handlers"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// fixedClaimsInterceptor is a Connect server-side interceptor that injects
// deterministic authentication claims into every incoming request context.
// This allows the handler/business/repository chain to see proper
// tenant+partition scoping without requiring a real JWT or Keto in tests.
type fixedClaimsInterceptor struct {
	tenantID    string
	partitionID string
	profileID   string
	// roles carries the approver tier roles the Decide path enforces.
	roles []string
}

// server returns the claims injection as a connect server interceptor; it
// covers unary and streaming RPCs alike.
func (f *fixedClaimsInterceptor) server() connect.ServerInterceptor {
	return func(next connect.ServerFunc) connect.ServerFunc {
		return func(ctx context.Context, spec connect.Spec, stream connect.ServerStream) error {
			return next(f.injectClaims(ctx), spec, stream)
		}
	}
}

func (f *fixedClaimsInterceptor) injectClaims(ctx context.Context) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:    f.tenantID,
		PartitionID: f.partitionID,
		AccessID:    util.IDString(),
		ContactID:   f.profileID,
		SessionID:   util.IDString(),
		DeviceID:    "test-device",
		Roles:       f.roles,
	}
	claims.Subject = f.profileID
	return claims.ClaimsToContext(ctx)
}

// AdminIntegrationSuite exercises the full Save→Update→Search→Delete→Get-NotFound
// lifecycle over a real Connect-over-HTTP transport backed by a Postgres testcontainer.
type AdminIntegrationSuite struct {
	frametests.FrameBaseTestSuite

	// client is a generated Connect client pointing at the test httptest.Server.
	client limitsv1connect.LimitsAdminServiceClient

	// serverCleanup tears down the httptest.Server after each test.
	serverCleanup func()
}

func (s *AdminIntegrationSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts("limits_int_test", definition.WithUserName("test")),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *AdminIntegrationSuite) SetupTest() {
	ctx := s.T().Context()
	// Auth claims used for the initial Frame service setup (e.g. pool init).
	ctx = s.WithAuthClaims(ctx, "tenant-int", "partition-int", "test-user")

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-integration-test"),
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
	biz := business.NewPolicyBusiness(policyRepo, versionRepo, nil, nil, nil, nil)
	adminH := handlers.NewAdminService(biz, nil, nil, nil)

	// Mount the handler with the fixedClaimsInterceptor so the business layer
	// sees proper tenant+partition scoping on every HTTP request.
	claimsInterceptor := &fixedClaimsInterceptor{
		tenantID:    "tenant-int",
		partitionID: "partition-int",
		profileID:   "test-user",
	}
	server := connect.NewServer(claimsInterceptor.server())
	limitsv1connect.RegisterLimitsAdminServiceHandler(server, adminH)

	mux := http.NewServeMux()
	connecthttp.Mount(mux, server)

	srv := httptest.NewServer(mux)
	s.serverCleanup = srv.Close
	s.T().Cleanup(s.serverCleanup)

	s.client = limitsv1connect.NewLimitsAdminServiceClient(connect.NewClient(connecthttp.NewTransport(
		srv.Client(),
		srv.URL,
	)))
}

func (s *AdminIntegrationSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// TestFullLifecycle exercises Save (create) → Save (update/enforce) → Search → Delete → Get-NotFound
// as a single ordered test. This mirrors a real admin workflow and validates the
// full Connect-over-HTTP serialisation path end-to-end.
func (s *AdminIntegrationSuite) TestFullLifecycle() {
	ctx := s.T().Context()

	// ── Step 1: create policy in SHADOW mode ─────────────────────────────────
	in := &limitsv1.PolicyObject{
		Scope:         limitsv1.PolicyScope_POLICY_SCOPE_ORG,
		Action:        limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		SubjectType:   limitsv1.SubjectType_SUBJECT_TYPE_CLIENT,
		CurrencyCode:  "KES",
		LimitKind:     limitsv1.LimitKind_LIMIT_KIND_PER_TXN_MAX,
		CapAmount:     &moneypb.Money{CurrencyCode: "KES", Units: 500},
		Mode:          limitsv1.PolicyMode_POLICY_MODE_SHADOW,
		EffectiveFrom: timestamppb.New(time.Now().UTC()),
		ApprovalTtl:   durationpb.New(72 * time.Hour),
	}

	saveResp, err := s.client.PolicySave(ctx, &limitsv1.PolicySaveRequest{Data: in})
	s.Require().NoError(err)
	policyID := saveResp.GetData().GetId()
	s.NotEmpty(policyID, "created policy must have an ID")
	s.Equal(limitsv1.PolicyMode_POLICY_MODE_SHADOW, saveResp.GetData().GetMode())

	// ── Step 2: update policy to ENFORCE mode ────────────────────────────────
	updated := saveResp.GetData()
	updated.Mode = limitsv1.PolicyMode_POLICY_MODE_ENFORCE

	updateResp, err := s.client.PolicySave(ctx, &limitsv1.PolicySaveRequest{Data: updated})
	s.Require().NoError(err)
	s.Equal(policyID, updateResp.GetData().GetId(), "update must preserve policy ID")
	s.Equal(limitsv1.PolicyMode_POLICY_MODE_ENFORCE, updateResp.GetData().GetMode())

	// ── Step 3: search returns the policy (server-streaming via Connect) ──────
	searchStream, err := s.client.PolicySearch(ctx, &limitsv1.PolicySearchRequest{})
	s.Require().NoError(err)

	var found bool
	var streamErr error
	for {
		msg, err := searchStream.Receive()
		if err != nil {
			streamErr = err
			break
		}
		for _, p := range msg.GetData() {
			if p.GetId() == policyID {
				found = true
			}
		}
	}
	if errors.Is(streamErr, io.EOF) {
		streamErr = nil
	}
	if searchErr := streamErr; searchErr != nil && !errors.Is(searchErr, io.EOF) {
		s.Require().NoError(searchErr, "search stream closed with error")
	}
	s.True(found, "search must return the saved policy")

	// ── Step 4: delete the policy ────────────────────────────────────────────
	_, err = s.client.PolicyDelete(ctx, &limitsv1.PolicyDeleteRequest{Id: policyID})
	s.Require().NoError(err)

	// ── Step 5: get after delete must return NotFound ────────────────────────
	_, err = s.client.PolicyGet(ctx, &limitsv1.PolicyGetRequest{Id: policyID})
	s.Require().Error(err)
	s.Equal(connect.CodeNotFound, connect.CodeOf(err), "deleted policy must return NotFound")
}

func TestAdminIntegrationSuite(t *testing.T) {
	suite.Run(t, new(AdminIntegrationSuite))
}
