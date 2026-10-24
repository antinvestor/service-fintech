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
	"io"
	"testing"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/security"
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

// fakeStream feeds one canned request message and then io.EOF, as a unary or
// server-streaming RPC's request side does.
type fakeStream struct {
	msg  proto.Message
	sent bool
}

func (f *fakeStream) Receive(into any) error {
	if f.sent {
		return io.EOF
	}
	dst, ok := into.(proto.Message)
	if !ok {
		return errors.New("unexpected message type")
	}
	f.sent = true
	proto.Reset(dst)
	proto.Merge(dst, f.msg)
	return nil
}
func (f *fakeStream) SendHeaders() error { return nil }
func (f *fakeStream) Send(any) error     { return nil }

// run drives the interceptor around a handler that receives the request the
// way generated handlers do. received is the stamped message the handler (and
// so the business code) got; it is nil when the interceptor refused it.
func run(ctx context.Context, streamType connect.StreamType, req proto.Message) (proto.Message, error) {
	var received proto.Message
	handler := func(_ context.Context, _ connect.Spec, stream connect.ServerStream) error {
		dst := req.ProtoReflect().New().Interface()
		if err := stream.Receive(dst); err != nil {
			return err
		}
		received = dst
		return nil
	}
	err := handlers.TenantAssertionInterceptor()(
		handler,
	)(
		ctx,
		connect.Spec{StreamType: streamType},
		&fakeStream{msg: req},
	)
	return received, err
}

func reserve(tenant string) *limitsv1.ReserveRequest {
	return &limitsv1.ReserveRequest{Intent: &limitsv1.LimitIntent{
		TenantId: tenant,
		Action:   limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
	}}
}

// TestTenantAssertionInterceptor_EmptyTenantOverwritten covers path 3: when
// intent.tenant_id is empty the interceptor must fill it from the auth context.
func TestTenantAssertionInterceptor_EmptyTenantOverwritten(t *testing.T) {
	ctx := injectClaims(context.Background(), "tenant-A", "partition-A", "user-1")

	got, err := run(ctx, connect.StreamTypeUnary, reserve(""))
	require.NoError(t, err)
	require.NotNil(t, got, "the handler must receive the request when tenant_id is empty")
	assert.Equal(t, "tenant-A", got.(*limitsv1.ReserveRequest).GetIntent().GetTenantId(),
		"interceptor must overwrite empty tenant_id with the ctx-derived value")
	assert.Equal(t, "user-1", got.(*limitsv1.ReserveRequest).GetIntent().GetMakerId(),
		"maker_id is always the authenticated caller")
}

// TestTenantAssertionInterceptor_MatchingTenantPasses covers path 1: when
// intent.tenant_id is set and matches the auth context the request passes through
// unchanged.
func TestTenantAssertionInterceptor_MatchingTenantPasses(t *testing.T) {
	ctx := injectClaims(context.Background(), "tenant-A", "partition-A", "user-1")

	got, err := run(ctx, connect.StreamTypeUnary, reserve("tenant-A"))
	require.NoError(t, err)
	require.NotNil(t, got)
	assert.Equal(t, "tenant-A", got.(*limitsv1.ReserveRequest).GetIntent().GetTenantId(),
		"tenant_id must be preserved when it matches the auth context")
}

// TestTenantAssertionInterceptor_MismatchingTenantRejected covers path 2: when
// intent.tenant_id is set but differs from the auth context the interceptor must
// return PermissionDenied before the handler sees the request.
func TestTenantAssertionInterceptor_MismatchingTenantRejected(t *testing.T) {
	ctx := injectClaims(context.Background(), "tenant-A", "partition-A", "user-1")

	got, err := run(ctx, connect.StreamTypeUnary, reserve("tenant-B"))
	require.Error(t, err)
	assert.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err),
		"cross-tenant payload must be rejected with PermissionDenied")
	assert.Nil(t, got, "the handler must not receive a cross-tenant request")
}

// TestTenantAssertionInterceptor_NilClaims_FailsClosed verifies that a request
// arriving without any auth claims is rejected: with no claims there is nothing
// to assert the caller-supplied tenant and maker against.
func TestTenantAssertionInterceptor_NilClaims_FailsClosed(t *testing.T) {
	got, err := run(context.Background(), connect.StreamTypeUnary, reserve("some-tenant"))
	require.Error(t, err)
	assert.Equal(t, connect.CodeUnauthenticated, connect.CodeOf(err))
	assert.Nil(t, got, "the handler must not receive a request when no claims are present")
}

// TestTenantAssertionInterceptor_EmptyTenantClaims_Rejected covers the
// fail-closed rule: claims that name no tenant are refused rather than stamped
// with "", which would leave every downstream `tenant != ""` guard disabled.
func TestTenantAssertionInterceptor_EmptyTenantClaims_Rejected(t *testing.T) {
	ctx := injectClaims(context.Background(), "", "partition-A", "user-1")

	got, err := run(ctx, connect.StreamTypeUnary, reserve(""))
	require.Error(t, err)
	assert.Equal(t, connect.CodeUnauthenticated, connect.CodeOf(err))
	assert.Nil(t, got, "the handler must not receive a request from an unscoped caller")
}

// TestTenantAssertionInterceptor_InternalSystemHonoursRequestTenant covers the
// single cross-tenant exception: an internal-system principal carries no tenant
// of its own, so the tenant it names in the request is authoritative.
func TestTenantAssertionInterceptor_InternalSystemHonoursRequestTenant(t *testing.T) {
	claims := &security.AuthenticationClaims{Roles: []string{security.ConstantSystemInternalRole}}
	claims.Subject = "svc-loans"
	ctx := claims.ClaimsToContext(context.Background())

	got, err := run(ctx, connect.StreamTypeUnary, reserve("tenant-B"))
	require.NoError(t, err)
	assert.Equal(t, "tenant-B", got.(*limitsv1.ReserveRequest).GetIntent().GetTenantId())
}

// TestTenantAssertionInterceptor_InternalSystemWithoutTenantRejected verifies
// that the cross-tenant exception still demands an explicit tenant.
func TestTenantAssertionInterceptor_InternalSystemWithoutTenantRejected(t *testing.T) {
	claims := &security.AuthenticationClaims{Roles: []string{security.ConstantSystemInternalRole}}
	claims.Subject = "svc-loans"
	ctx := claims.ClaimsToContext(context.Background())

	got, err := run(ctx, connect.StreamTypeUnary, reserve(""))
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	assert.Nil(t, got)
}

// TestTenantAssertionInterceptor_StreamingHandlerStampsTenant is the regression
// test for the server-streaming RPCs (PolicySearch, ApprovalRequestList,
// LedgerSearch): their requests must be stamped like unary ones.
func TestTenantAssertionInterceptor_StreamingHandlerStampsTenant(t *testing.T) {
	ctx := injectClaims(context.Background(), "tenant-A", "partition-A", "user-1")

	got, err := run(ctx, connect.StreamTypeServer, &limitsv1.PolicySearchRequest{})
	require.NoError(t, err)
	assert.Equal(t, "tenant-A", got.(*limitsv1.PolicySearchRequest).GetTenantId(),
		"streaming request must be stamped with the auth-derived tenant")
}

// TestTenantAssertionInterceptor_StreamingHandlerRejectsCrossTenant proves the
// streaming path also refuses a payload naming another tenant.
func TestTenantAssertionInterceptor_StreamingHandlerRejectsCrossTenant(t *testing.T) {
	ctx := injectClaims(context.Background(), "tenant-A", "partition-A", "user-1")

	_, err := run(ctx, connect.StreamTypeServer, &limitsv1.LedgerSearchRequest{TenantId: "tenant-B"})
	require.Error(t, err)
	assert.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))
}

// TestTenantAssertionInterceptor_StreamingHandlerFailsClosedWithoutClaims keeps
// the streaming path aligned with the unary one.
func TestTenantAssertionInterceptor_StreamingHandlerFailsClosedWithoutClaims(t *testing.T) {
	_, err := run(context.Background(), connect.StreamTypeServer, &limitsv1.ApprovalRequestListRequest{})
	require.Error(t, err)
	assert.Equal(t, connect.CodeUnauthenticated, connect.CodeOf(err))
}
