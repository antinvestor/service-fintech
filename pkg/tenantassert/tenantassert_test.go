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
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/tenancy"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
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

// probe is a server method the interceptor fronts in tests. It records the
// context the handler ran with and reads every request message it is given.
type probe struct {
	ran     bool
	bound   *tenancy.Claims
	inspect func(ctx context.Context, stream connect.ServerStream) error
}

func method(t *testing.T, service, name string) protoreflect.MethodDescriptor {
	t.Helper()
	md := limitsv1.File_limits_v1_limits_proto.Services().ByName(protoreflect.Name(service)).
		Methods().ByName(protoreflect.Name(name))
	require.NotNil(t, md)
	return md
}

// call runs one RPC through a real connect.Server with the interceptor, the
// way the transport would: request headers on the server CallInfo and the
// request messages on the stream.
func call(
	ctx context.Context,
	t *testing.T,
	interceptor connect.ServerInterceptor,
	md protoreflect.MethodDescriptor,
	streamType connect.StreamType,
	header string,
	p *probe,
	msgs ...proto.Message,
) error {
	t.Helper()
	spec := connect.Spec{StreamType: streamType, Schema: md, Procedure: "/test/" + string(md.Name())}
	server := connect.NewServer(interceptor)
	server.Register(
		connect.Method{
			Spec: spec,
			Handler: func(ctx context.Context, _ connect.Spec, stream connect.ServerStream) error {
				p.ran = true
				p.bound = tenancy.ClaimsFromContext(ctx)
				if p.inspect != nil {
					return p.inspect(ctx, stream)
				}
				return nil
			},
		},
	)
	info := &connect.CallInfo{Spec: spec}
	if header != "" {
		info.RequestHeader().Set(tenantassert.HeaderTenantID, header)
	}
	return server.Call(ctx, spec.Procedure, info, &fakeStream{queue: msgs})
}

// fakeStream feeds scripted request messages and discards responses.
type fakeStream struct {
	queue []proto.Message
}

func (f *fakeStream) Receive(msg any) error {
	if len(f.queue) == 0 {
		return io.EOF
	}
	dst, ok := msg.(proto.Message)
	if !ok {
		return errors.New("unexpected message type")
	}
	proto.Merge(dst, f.queue[0])
	f.queue = f.queue[1:]
	return nil
}

func (f *fakeStream) SendHeaders() error { return nil }
func (f *fakeStream) Send(any) error     { return nil }

func receivePolicySearch(got **limitsv1.PolicySearchRequest) func(context.Context, connect.ServerStream) error {
	return func(_ context.Context, stream connect.ServerStream) error {
		msg := &limitsv1.PolicySearchRequest{}
		if err := stream.Receive(msg); err != nil {
			return err
		}
		*got = msg
		return nil
	}
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
	md := method(t, "LimitsAdminService", "PolicySearch")
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			var got *limitsv1.PolicySearchRequest
			p := &probe{inspect: receivePolicySearch(&got)}

			err := call(ctxWith(t, tc.claims), t, tenantassert.Interceptor(), md,
				connect.StreamTypeUnary, tc.header, p, tc.msg)

			if tc.wantCode != 0 {
				require.Error(t, err)
				require.Equal(t, tc.wantCode, connect.CodeOf(err))
				require.False(t, p.ran, "handler must not run on a refused request")
				return
			}
			require.NoError(t, err)
			require.NotNil(t, got)
			require.Equal(t, tc.wantTenant, got.GetTenantId(), "field must be stamped with the resolved tenant")
			require.NotNil(t, p.bound)
			if tc.wantBound != "" {
				require.Equal(t, tc.wantBound, p.bound.TenantID)
				require.False(t, p.bound.Skip, "internal principal must not keep the tenancy skip")
				require.Empty(
					t,
					p.bound.PartitionIDs,
					"tenant-only binding keeps every partition of the tenant visible",
				)
			}
		})
	}
}

func TestInterceptor_ServerStreamResolvesFromTheRequestLikeUnary(t *testing.T) {
	var got *limitsv1.PolicySearchRequest
	p := &probe{inspect: receivePolicySearch(&got)}

	err := call(ctxWith(t, internalClaims("")), t, tenantassert.Interceptor(),
		method(t, "LimitsAdminService", "PolicySearch"), connect.StreamTypeServer, "", p,
		&limitsv1.PolicySearchRequest{TenantId: "t9"})
	require.NoError(t, err)
	require.Equal(t, "t9", got.GetTenantId())
	require.Equal(t, "t9", p.bound.TenantID)
}

func TestInterceptor_UnaryWithoutTenantField_UsesHeaderOnly(t *testing.T) {
	md := method(t, "LimitsService", "Commit")

	p := &probe{}
	err := call(ctxWith(t, internalClaims("")), t, tenantassert.Interceptor(), md,
		connect.StreamTypeUnary, "", p, &limitsv1.CommitRequest{ReservationId: "r1"})
	require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	require.False(t, p.ran)

	p = &probe{}
	err = call(ctxWith(t, internalClaims("")), t, tenantassert.Interceptor(), md,
		connect.StreamTypeUnary, "t3", p, &limitsv1.CommitRequest{ReservationId: "r1"})
	require.NoError(t, err)
	require.True(t, p.ran)
	require.Equal(t, "t3", p.bound.TenantID)
}

func TestInterceptor_CustomFieldFunc(t *testing.T) {
	var stamped string
	custom := func(msg any) *tenantassert.Field {
		if _, ok := msg.(*limitsv1.CommitRequest); !ok {
			return nil
		}
		return &tenantassert.Field{Get: func() string { return "" }, Set: func(v string) { stamped = v }}
	}
	err := call(ctxWith(t, tenantClaims("t1")), t, tenantassert.Interceptor(tenantassert.WithTenantField(custom)),
		method(t, "LimitsService", "Commit"), connect.StreamTypeUnary, "", &probe{}, &limitsv1.CommitRequest{})
	require.NoError(t, err)
	require.Equal(t, "t1", stamped)
}

func TestInterceptor_Streaming(t *testing.T) {
	md := method(t, "LimitsAdminService", "PolicySearch")

	t.Run("internal without header is refused before the handler runs", func(t *testing.T) {
		p := &probe{}
		err := call(ctxWith(t, internalClaims("")), t, tenantassert.Interceptor(), md,
			connect.StreamTypeBidi, "", p)
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		require.False(t, p.ran)
	})

	t.Run("messages are stamped and mismatches refused", func(t *testing.T) {
		p := &probe{inspect: func(_ context.Context, stream connect.ServerStream) error {
			first := &limitsv1.PolicySearchRequest{}
			require.NoError(t, stream.Receive(first))
			require.Equal(t, "t1", first.GetTenantId(), "empty field stamped with resolved tenant")

			second := &limitsv1.PolicySearchRequest{}
			require.NoError(t, stream.Receive(second))
			require.Equal(t, "t1", second.GetTenantId())

			third := &limitsv1.PolicySearchRequest{}
			err := stream.Receive(third)
			require.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))
			return nil
		}}
		err := call(ctxWith(t, tenantClaims("t1")), t, tenantassert.Interceptor(), md, connect.StreamTypeBidi, "", p,
			&limitsv1.PolicySearchRequest{}, &limitsv1.PolicySearchRequest{TenantId: "t1"},
			&limitsv1.PolicySearchRequest{TenantId: "t2"})
		require.NoError(t, err)
		require.NotNil(t, p.bound)
		require.Equal(t, "t1", p.bound.TenantID)
	})

	t.Run("internal names tenant via header", func(t *testing.T) {
		p := &probe{inspect: func(_ context.Context, stream connect.ServerStream) error {
			msg := &limitsv1.PolicySearchRequest{}
			require.NoError(t, stream.Receive(msg))
			require.Equal(t, "t5", msg.GetTenantId())
			return nil
		}}
		err := call(ctxWith(t, internalClaims("")), t, tenantassert.Interceptor(), md, connect.StreamTypeBidi, "t5", p,
			&limitsv1.PolicySearchRequest{})
		require.NoError(t, err)
		require.Equal(t, "t5", p.bound.TenantID)
		require.False(t, p.bound.Skip)
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
