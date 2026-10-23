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

package tenantassert_test

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/frame/v2/tenancy"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/antinvestor/service-fintech/pkg/tenantassert"
)

func tenantClaims(tenant string) *security.AuthenticationClaims {
	return &security.AuthenticationClaims{
		TenantID:         tenant,
		PartitionID:      "partition-a",
		RegisteredClaims: jwt.RegisteredClaims{Subject: "profile-a"},
	}
}

func internalClaims(tenant string) *security.AuthenticationClaims {
	c := tenantClaims(tenant)
	c.Roles = []string{security.ConstantSystemInternalRole}
	c.AccessID = "access-internal"
	return c
}

func ctxWith(t *testing.T, claims *security.AuthenticationClaims) context.Context {
	t.Helper()
	if claims == nil {
		return t.Context()
	}
	return claims.ClaimsToContext(t.Context())
}

func TestResolve_Matrix(t *testing.T) {
	cases := []struct {
		name      string
		claims    *security.AuthenticationClaims
		requested string
		want      string
		wantCode  connect.Code
		wantErr   error
	}{
		{name: "no claims", claims: nil,
			wantCode: connect.CodeUnauthenticated, wantErr: tenantassert.ErrMissingCallerIdentity},
		{name: "tenant principal runs as own tenant", claims: tenantClaims("t1"), want: "t1"},
		{name: "tenant principal naming own tenant", claims: tenantClaims("t1"), requested: "t1", want: "t1"},
		{name: "tenant principal naming other tenant", claims: tenantClaims("t1"), requested: "t2",
			wantCode: connect.CodePermissionDenied, wantErr: tenantassert.ErrTenantMismatch},
		{name: "tenant principal with empty tenant fails closed", claims: tenantClaims(""), requested: "t1",
			wantCode: connect.CodeUnauthenticated, wantErr: tenantassert.ErrUnscopedCaller},
		{name: "internal with tenant in claims", claims: internalClaims("t1"), want: "t1"},
		{name: "internal with claims tenant naming other", claims: internalClaims("t1"), requested: "t2",
			wantCode: connect.CodePermissionDenied, wantErr: tenantassert.ErrTenantMismatch},
		{name: "internal without tenant must name one", claims: internalClaims(""),
			wantCode: connect.CodeInvalidArgument, wantErr: tenantassert.ErrInternalTenantRequired},
		{name: "internal without tenant naming one", claims: internalClaims(""), requested: " t9 ", want: "t9"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got, err := tenantassert.Resolve(tc.claims, tc.requested)
			if tc.wantErr != nil {
				require.Error(t, err)
				require.Equal(t, tc.wantCode, connect.CodeOf(err))
				require.ErrorIs(t, err, tc.wantErr)
				return
			}
			require.NoError(t, err)
			require.Equal(t, tc.want, got)
		})
	}
}

func TestProtoTenantField(t *testing.T) {
	t.Run("top level field", func(t *testing.T) {
		msg := &limitsv1.PolicySearchRequest{TenantId: "t1"}
		f := tenantassert.ProtoTenantField(msg)
		require.NotNil(t, f)
		require.Equal(t, "t1", f.Get())
		f.Set("t2")
		require.Equal(t, "t2", msg.GetTenantId())
	})
	t.Run("nested populated object", func(t *testing.T) {
		msg := &limitsv1.ReserveRequest{Intent: &limitsv1.LimitIntent{TenantId: "t1"}}
		f := tenantassert.ProtoTenantField(msg)
		require.NotNil(t, f)
		require.Equal(t, "t1", f.Get())
		f.Set("t2")
		require.Equal(t, "t2", msg.GetIntent().GetTenantId())
	})
	t.Run("nested object not populated is nil", func(t *testing.T) {
		require.Nil(t, tenantassert.ProtoTenantField(&limitsv1.ReserveRequest{}))
	})
	t.Run("shape without tenant is nil", func(t *testing.T) {
		require.Nil(t, tenantassert.ProtoTenantField(&emptypb.Empty{}))
		require.Nil(t, tenantassert.ProtoTenantField("not a proto"))
		require.Nil(t, tenantassert.ProtoTenantField(nil))
	})
}

func TestInterceptor_Unary(t *testing.T) {
	cases := []struct {
		name       string
		claims     *security.AuthenticationClaims
		msg        *limitsv1.PolicySearchRequest
		header     string
		wantCode   connect.Code
		wantTenant string
		wantBound  string
	}{
		{name: "tenant principal stamps own tenant", claims: tenantClaims("t1"),
			msg: &limitsv1.PolicySearchRequest{}, wantTenant: "t1"},
		{name: "tenant principal cannot name other tenant in field", claims: tenantClaims("t1"),
			msg: &limitsv1.PolicySearchRequest{TenantId: "t2"}, wantCode: connect.CodePermissionDenied},
		{name: "tenant principal cannot name other tenant in header", claims: tenantClaims("t1"),
			msg: &limitsv1.PolicySearchRequest{}, header: "t2", wantCode: connect.CodePermissionDenied},
		{name: "unauthenticated", claims: nil, msg: &limitsv1.PolicySearchRequest{},
			wantCode: connect.CodeUnauthenticated},
		{name: "internal with no tenant anywhere fails closed", claims: internalClaims(""),
			msg: &limitsv1.PolicySearchRequest{}, wantCode: connect.CodeInvalidArgument},
		{name: "internal names tenant in field and is bound to it", claims: internalClaims(""),
			msg: &limitsv1.PolicySearchRequest{TenantId: "t7"}, wantTenant: "t7", wantBound: "t7"},
		{name: "internal names tenant in header and is bound to it", claims: internalClaims(""),
			msg: &limitsv1.PolicySearchRequest{}, header: "t8", wantTenant: "t8", wantBound: "t8"},
		{name: "field and header disagree", claims: internalClaims(""),
			msg: &limitsv1.PolicySearchRequest{TenantId: "t7"}, header: "t8", wantCode: connect.CodeInvalidArgument},
		{name: "internal with claims tenant is rebound without skip", claims: internalClaims("t1"),
			msg: &limitsv1.PolicySearchRequest{}, wantTenant: "t1", wantBound: "t1"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			var ran bool
			var bound *tenancy.Claims
			next := func(ctx context.Context, _ connect.AnyRequest) (connect.AnyResponse, error) {
				ran = true
				bound = tenancy.ClaimsFromContext(ctx)
				return connect.NewResponse(&emptypb.Empty{}), nil
			}
			req := connect.NewRequest(tc.msg)
			if tc.header != "" {
				req.Header().Set(tenantassert.HeaderTenantID, tc.header)
			}

			_, err := tenantassert.Interceptor().WrapUnary(next)(ctxWith(t, tc.claims), req)

			if tc.wantCode != 0 {
				require.Error(t, err)
				require.Equal(t, tc.wantCode, connect.CodeOf(err))
				require.False(t, ran, "handler must not run on a refused request")
				return
			}
			require.NoError(t, err)
			require.Equal(t, tc.wantTenant, tc.msg.GetTenantId(), "field must be stamped with the resolved tenant")
			require.NotNil(t, bound)
			if tc.wantBound != "" {
				require.Equal(t, tc.wantBound, bound.TenantID)
				require.False(t, bound.Skip, "internal principal must not keep the tenancy skip")
				require.Empty(t, bound.PartitionIDs, "tenant-only binding keeps every partition of the tenant visible")
			}
		})
	}
}

func TestInterceptor_UnaryWithoutTenantField_UsesHeaderOnly(t *testing.T) {
	var ran bool
	next := func(context.Context, connect.AnyRequest) (connect.AnyResponse, error) {
		ran = true
		return connect.NewResponse(&emptypb.Empty{}), nil
	}
	wrap := tenantassert.Interceptor().WrapUnary(next)

	_, err := wrap(ctxWith(t, internalClaims("")), connect.NewRequest(&emptypb.Empty{}))
	require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	require.False(t, ran)

	req := connect.NewRequest(&emptypb.Empty{})
	req.Header().Set(tenantassert.HeaderTenantID, "t3")
	_, err = wrap(ctxWith(t, internalClaims("")), req)
	require.NoError(t, err)
	require.True(t, ran)
}

func TestInterceptor_CustomFieldFunc(t *testing.T) {
	var stamped string
	custom := func(msg any) *tenantassert.Field {
		if _, ok := msg.(*emptypb.Empty); !ok {
			return nil
		}
		return &tenantassert.Field{Get: func() string { return "" }, Set: func(v string) { stamped = v }}
	}
	next := func(context.Context, connect.AnyRequest) (connect.AnyResponse, error) {
		return connect.NewResponse(&emptypb.Empty{}), nil
	}
	_, err := tenantassert.Interceptor(tenantassert.WithTenantField(custom)).
		WrapUnary(next)(ctxWith(t, tenantClaims("t1")), connect.NewRequest(&emptypb.Empty{}))
	require.NoError(t, err)
	require.Equal(t, "t1", stamped)
}

// fakeStream is a minimal StreamingHandlerConn feeding scripted messages.
type fakeStream struct {
	connect.StreamingHandlerConn
	header http.Header
	queue  []*limitsv1.PolicySearchRequest
}

func (f *fakeStream) RequestHeader() http.Header { return f.header }

func (f *fakeStream) Receive(msg any) error {
	if len(f.queue) == 0 {
		return errors.New("eof")
	}
	target, ok := msg.(*limitsv1.PolicySearchRequest)
	if !ok {
		return errors.New("unexpected message type")
	}
	target.TenantId = f.queue[0].GetTenantId()
	f.queue = f.queue[1:]
	return nil
}

func TestInterceptor_Streaming(t *testing.T) {
	t.Run("internal without header is refused before the handler runs", func(t *testing.T) {
		ran := false
		next := func(context.Context, connect.StreamingHandlerConn) error { ran = true; return nil }
		err := tenantassert.Interceptor().WrapStreamingHandler(next)(
			ctxWith(t, internalClaims("")), &fakeStream{header: http.Header{}})
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		require.False(t, ran)
	})

	t.Run("messages are stamped and mismatches refused", func(t *testing.T) {
		stream := &fakeStream{
			header: http.Header{},
			queue: []*limitsv1.PolicySearchRequest{
				{}, {TenantId: "t1"}, {TenantId: "t2"},
			},
		}
		var bound *tenancy.Claims
		next := func(ctx context.Context, conn connect.StreamingHandlerConn) error {
			bound = tenancy.ClaimsFromContext(ctx)
			first := &limitsv1.PolicySearchRequest{}
			require.NoError(t, conn.Receive(first))
			require.Equal(t, "t1", first.GetTenantId(), "empty field stamped with resolved tenant")

			second := &limitsv1.PolicySearchRequest{}
			require.NoError(t, conn.Receive(second))
			require.Equal(t, "t1", second.GetTenantId())

			third := &limitsv1.PolicySearchRequest{}
			err := conn.Receive(third)
			require.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))
			return nil
		}
		err := tenantassert.Interceptor().WrapStreamingHandler(next)(ctxWith(t, tenantClaims("t1")), stream)
		require.NoError(t, err)
		require.NotNil(t, bound)
		require.Equal(t, "t1", bound.TenantID)
	})

	t.Run("internal names tenant via header", func(t *testing.T) {
		stream := &fakeStream{
			header: http.Header{tenantassert.HeaderTenantID: []string{"t5"}},
			queue:  []*limitsv1.PolicySearchRequest{{}},
		}
		next := func(ctx context.Context, conn connect.StreamingHandlerConn) error {
			bound := tenancy.ClaimsFromContext(ctx)
			require.Equal(t, "t5", bound.TenantID)
			require.False(t, bound.Skip)
			msg := &limitsv1.PolicySearchRequest{}
			require.NoError(t, conn.Receive(msg))
			require.Equal(t, "t5", msg.GetTenantId())
			return nil
		}
		err := tenantassert.Interceptor().WrapStreamingHandler(next)(ctxWith(t, internalClaims("")), stream)
		require.NoError(t, err)
	})
}

func TestMiddleware(t *testing.T) {
	cases := []struct {
		name       string
		claims     *security.AuthenticationClaims
		header     string
		wantStatus int
		wantBound  string
	}{
		{name: "no claims", claims: nil, wantStatus: http.StatusUnauthorized},
		{name: "unscoped tenant principal", claims: tenantClaims(""), wantStatus: http.StatusUnauthorized},
		{name: "tenant principal passes", claims: tenantClaims("t1"), wantStatus: http.StatusOK, wantBound: "t1"},
		{name: "tenant principal naming other tenant", claims: tenantClaims("t1"), header: "t2",
			wantStatus: http.StatusForbidden},
		{name: "internal without header", claims: internalClaims(""), wantStatus: http.StatusBadRequest},
		{name: "internal with header is bound", claims: internalClaims(""), header: "t4",
			wantStatus: http.StatusOK, wantBound: "t4"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			var bound *tenancy.Claims
			h := tenantassert.Middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				bound = tenancy.ClaimsFromContext(r.Context())
				w.WriteHeader(http.StatusOK)
			}))
			req := httptest.NewRequestWithContext(ctxWith(t, tc.claims), http.MethodPost, "/x", nil)
			if tc.header != "" {
				req.Header.Set(tenantassert.HeaderTenantID, tc.header)
			}
			rec := httptest.NewRecorder()

			h.ServeHTTP(rec, req)

			require.Equal(t, tc.wantStatus, rec.Code, rec.Body.String())
			if tc.wantBound != "" {
				require.NotNil(t, bound)
				require.Equal(t, tc.wantBound, bound.TenantID)
				require.False(t, bound.Skip)
			}
		})
	}
}
