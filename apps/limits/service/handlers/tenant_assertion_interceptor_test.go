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

package handlers_test

import (
	"context"
	"errors"
	"net/http"
	"testing"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/proto"

	"github.com/antinvestor/service-fintech/apps/limits/service/handlers"
)

// injectClaims builds a context carrying authentication claims for the given
// tenant/partition/profile, mirroring the fixedClaimsInterceptor in the
// integration tests and the FrameBaseTestSuite.WithAuthClaims helper.
func injectClaims(ctx context.Context, tenantID, partitionID, profileID string) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:    tenantID,
		PartitionID: partitionID,
		AccessID:    util.IDString(),
		ContactID:   profileID,
		SessionID:   util.IDString(),
		DeviceID:    "test-device",
	}
	claims.Subject = profileID
	return claims.ClaimsToContext(ctx)
}

// TestTenantAssertionInterceptor_EmptyTenantOverwritten covers path 3: when
// intent.tenant_id is empty the interceptor must fill it from the auth context.
func TestTenantAssertionInterceptor_EmptyTenantOverwritten(t *testing.T) {
	ctx := injectClaims(context.Background(), "tenant-A", "partition-A", "user-1")

	intent := &limitsv1.LimitIntent{
		// TenantId deliberately left empty — this is the path under test.
		Action: limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
	}
	req := connect.NewRequest(&limitsv1.ReserveRequest{Intent: intent})

	interceptor := handlers.TenantAssertionInterceptor()
	var nextCalled bool
	next := func(_ context.Context, _ connect.AnyRequest) (connect.AnyResponse, error) {
		nextCalled = true
		return nil, nil //nolint:nilnil // stub next handler: response is ignored by these tests
	}

	_, err := interceptor.WrapUnary(next)(ctx, req)
	require.NoError(t, err)
	assert.True(t, nextCalled, "next must be called when tenant_id is empty")
	assert.Equal(t, "tenant-A", req.Msg.GetIntent().GetTenantId(),
		"interceptor must overwrite empty tenant_id with the ctx-derived value")
}

// TestTenantAssertionInterceptor_MatchingTenantPasses covers path 1: when
// intent.tenant_id is set and matches the auth context the request passes through
// unchanged.
func TestTenantAssertionInterceptor_MatchingTenantPasses(t *testing.T) {
	ctx := injectClaims(context.Background(), "tenant-A", "partition-A", "user-1")

	intent := &limitsv1.LimitIntent{
		TenantId: "tenant-A",
		Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
	}
	req := connect.NewRequest(&limitsv1.ReserveRequest{Intent: intent})

	interceptor := handlers.TenantAssertionInterceptor()
	var nextCalled bool
	next := func(_ context.Context, _ connect.AnyRequest) (connect.AnyResponse, error) {
		nextCalled = true
		return nil, nil //nolint:nilnil // stub next handler: response is ignored by these tests
	}

	_, err := interceptor.WrapUnary(next)(ctx, req)
	require.NoError(t, err)
	assert.True(t, nextCalled, "next must be called when tenant_id matches")
	assert.Equal(t, "tenant-A", req.Msg.GetIntent().GetTenantId(),
		"tenant_id must be preserved when it matches the auth context")
}

// TestTenantAssertionInterceptor_MismatchingTenantRejected covers path 2: when
// intent.tenant_id is set but differs from the auth context the interceptor must
// return PermissionDenied and must NOT call next.
func TestTenantAssertionInterceptor_MismatchingTenantRejected(t *testing.T) {
	ctx := injectClaims(context.Background(), "tenant-A", "partition-A", "user-1")

	intent := &limitsv1.LimitIntent{
		TenantId: "tenant-B", // deliberate mismatch
		Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
	}
	req := connect.NewRequest(&limitsv1.ReserveRequest{Intent: intent})

	interceptor := handlers.TenantAssertionInterceptor()
	var nextCalled bool
	next := func(_ context.Context, _ connect.AnyRequest) (connect.AnyResponse, error) {
		nextCalled = true
		return nil, nil //nolint:nilnil // stub next handler: response is ignored by these tests
	}

	_, err := interceptor.WrapUnary(next)(ctx, req)
	require.Error(t, err)
	assert.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err),
		"cross-tenant payload must be rejected with PermissionDenied")
	assert.False(t, nextCalled, "next must NOT be called on tenant mismatch")
}

// TestTenantAssertionInterceptor_NilClaims_FailsClosed verifies that a request
// arriving without any auth claims is rejected: with no claims there is nothing
// to assert the caller-supplied tenant and maker against.
func TestTenantAssertionInterceptor_NilClaims_FailsClosed(t *testing.T) {
	// No claims injected — raw background context.
	req := connect.NewRequest(&limitsv1.ReserveRequest{
		Intent: &limitsv1.LimitIntent{
			TenantId: "some-tenant",
			Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		},
	})

	interceptor := handlers.TenantAssertionInterceptor()
	var nextCalled bool
	next := func(_ context.Context, _ connect.AnyRequest) (connect.AnyResponse, error) {
		nextCalled = true
		return nil, nil //nolint:nilnil // stub next handler: response is ignored by these tests
	}

	_, err := interceptor.WrapUnary(next)(context.Background(), req)
	require.Error(t, err)
	assert.Equal(t, connect.CodeUnauthenticated, connect.CodeOf(err))
	assert.False(t, nextCalled, "next must NOT be called when no claims are present")
}

// TestTenantAssertionInterceptor_EmptyTenantClaims_Rejected covers the
// fail-closed rule: claims that name no tenant are refused rather than stamped
// with "", which would leave every downstream `tenant != ""` guard disabled.
func TestTenantAssertionInterceptor_EmptyTenantClaims_Rejected(t *testing.T) {
	ctx := injectClaims(context.Background(), "", "partition-A", "user-1")

	req := connect.NewRequest(&limitsv1.ReserveRequest{
		Intent: &limitsv1.LimitIntent{
			Action: limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		},
	})

	interceptor := handlers.TenantAssertionInterceptor()
	var nextCalled bool
	next := func(_ context.Context, _ connect.AnyRequest) (connect.AnyResponse, error) {
		nextCalled = true
		return nil, nil //nolint:nilnil // stub next handler: response is ignored by these tests
	}

	_, err := interceptor.WrapUnary(next)(ctx, req)
	require.Error(t, err)
	assert.Equal(t, connect.CodeUnauthenticated, connect.CodeOf(err))
	assert.False(t, nextCalled, "next must NOT be called for an unscoped caller")
}

// TestTenantAssertionInterceptor_InternalSystemHonoursRequestTenant covers the
// single cross-tenant exception: an internal-system principal carries no tenant
// of its own, so the tenant it names in the request is authoritative.
func TestTenantAssertionInterceptor_InternalSystemHonoursRequestTenant(t *testing.T) {
	claims := &security.AuthenticationClaims{Roles: []string{security.ConstantSystemInternalRole}}
	claims.Subject = "svc-loans"
	ctx := claims.ClaimsToContext(context.Background())

	req := connect.NewRequest(&limitsv1.ReserveRequest{
		Intent: &limitsv1.LimitIntent{
			TenantId: "tenant-B",
			Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		},
	})

	interceptor := handlers.TenantAssertionInterceptor()
	next := func(_ context.Context, _ connect.AnyRequest) (connect.AnyResponse, error) {
		return nil, nil //nolint:nilnil // stub next handler: response is ignored by these tests
	}

	_, err := interceptor.WrapUnary(next)(ctx, req)
	require.NoError(t, err)
	assert.Equal(t, "tenant-B", req.Msg.GetIntent().GetTenantId())
}

// TestTenantAssertionInterceptor_InternalSystemWithoutTenantRejected verifies
// that the cross-tenant exception still demands an explicit tenant.
func TestTenantAssertionInterceptor_InternalSystemWithoutTenantRejected(t *testing.T) {
	claims := &security.AuthenticationClaims{Roles: []string{security.ConstantSystemInternalRole}}
	claims.Subject = "svc-loans"
	ctx := claims.ClaimsToContext(context.Background())

	req := connect.NewRequest(&limitsv1.ReserveRequest{
		Intent: &limitsv1.LimitIntent{
			Action: limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		},
	})

	interceptor := handlers.TenantAssertionInterceptor()
	var nextCalled bool
	next := func(_ context.Context, _ connect.AnyRequest) (connect.AnyResponse, error) {
		nextCalled = true
		return nil, nil //nolint:nilnil // stub next handler: response is ignored by these tests
	}

	_, err := interceptor.WrapUnary(next)(ctx, req)
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	assert.False(t, nextCalled)
}

// fakeStreamingHandlerConn is the minimum connect.StreamingHandlerConn needed to
// drive WrapStreamingHandler: Receive copies a canned request message into the
// caller's message, exactly as the real server-streaming conn does.
type fakeStreamingHandlerConn struct {
	msg proto.Message
}

func (c *fakeStreamingHandlerConn) Spec() connect.Spec {
	return connect.Spec{StreamType: connect.StreamTypeServer}
}
func (c *fakeStreamingHandlerConn) Peer() connect.Peer           { return connect.Peer{} }
func (c *fakeStreamingHandlerConn) RequestHeader() http.Header   { return http.Header{} }
func (c *fakeStreamingHandlerConn) ResponseHeader() http.Header  { return http.Header{} }
func (c *fakeStreamingHandlerConn) ResponseTrailer() http.Header { return http.Header{} }
func (c *fakeStreamingHandlerConn) Send(any) error               { return nil }
func (c *fakeStreamingHandlerConn) Receive(into any) error {
	dst, ok := into.(proto.Message)
	if !ok {
		return errors.New("unexpected message type")
	}
	proto.Reset(dst)
	proto.Merge(dst, c.msg)
	return nil
}

// TestTenantAssertionInterceptor_StreamingHandlerStampsTenant is the regression
// test for the server-streaming RPCs: as a UnaryInterceptorFunc the interceptor
// never ran for them, so PolicySearch/ApprovalRequestList/LedgerSearch went
// unstamped.
func TestTenantAssertionInterceptor_StreamingHandlerStampsTenant(t *testing.T) {
	ctx := injectClaims(context.Background(), "tenant-A", "partition-A", "user-1")
	conn := &fakeStreamingHandlerConn{msg: &limitsv1.PolicySearchRequest{}}

	interceptor := handlers.TenantAssertionInterceptor()
	got := &limitsv1.PolicySearchRequest{}
	handler := func(_ context.Context, c connect.StreamingHandlerConn) error {
		return c.Receive(got)
	}

	require.NoError(t, interceptor.WrapStreamingHandler(handler)(ctx, conn))
	assert.Equal(t, "tenant-A", got.GetTenantId(),
		"streaming request must be stamped with the auth-derived tenant")
}

// TestTenantAssertionInterceptor_StreamingHandlerRejectsCrossTenant proves the
// streaming path also refuses a payload naming another tenant.
func TestTenantAssertionInterceptor_StreamingHandlerRejectsCrossTenant(t *testing.T) {
	ctx := injectClaims(context.Background(), "tenant-A", "partition-A", "user-1")
	conn := &fakeStreamingHandlerConn{msg: &limitsv1.LedgerSearchRequest{TenantId: "tenant-B"}}

	interceptor := handlers.TenantAssertionInterceptor()
	handler := func(_ context.Context, c connect.StreamingHandlerConn) error {
		return c.Receive(&limitsv1.LedgerSearchRequest{})
	}

	err := interceptor.WrapStreamingHandler(handler)(ctx, conn)
	require.Error(t, err)
	assert.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))
}

// TestTenantAssertionInterceptor_StreamingHandlerFailsClosedWithoutClaims keeps
// the streaming path aligned with the unary one.
func TestTenantAssertionInterceptor_StreamingHandlerFailsClosedWithoutClaims(t *testing.T) {
	conn := &fakeStreamingHandlerConn{msg: &limitsv1.ApprovalRequestListRequest{}}

	interceptor := handlers.TenantAssertionInterceptor()
	handler := func(_ context.Context, c connect.StreamingHandlerConn) error {
		return c.Receive(&limitsv1.ApprovalRequestListRequest{})
	}

	err := interceptor.WrapStreamingHandler(handler)(context.Background(), conn)
	require.Error(t, err)
	assert.Equal(t, connect.CodeUnauthenticated, connect.CodeOf(err))
}
