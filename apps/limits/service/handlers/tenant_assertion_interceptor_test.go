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
	"testing"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

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

	_, err := interceptor(next)(ctx, req)
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

	_, err := interceptor(next)(ctx, req)
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

	_, err := interceptor(next)(ctx, req)
	require.Error(t, err)
	assert.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err),
		"cross-tenant payload must be rejected with PermissionDenied")
	assert.False(t, nextCalled, "next must NOT be called on tenant mismatch")
}

// TestTenantAssertionInterceptor_NilClaims_PassesThrough verifies that a request
// arriving without any auth claims in context is passed to next untouched.
func TestTenantAssertionInterceptor_NilClaims_PassesThrough(t *testing.T) {
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

	_, err := interceptor(next)(context.Background(), req)
	require.NoError(t, err)
	assert.True(t, nextCalled, "next must be called when no claims are present")
}
