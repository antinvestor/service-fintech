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

package tenantassert

import (
	"context"
	"net/http"

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/security"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/reflect/protoregistry"
)

// Option configures the interceptor and middleware.
type Option func(*options)

type options struct {
	field FieldFunc
}

// WithTenantField replaces the default proto-reflection field lookup with a
// service-specific one, for request shapes that carry the tenant somewhere
// reflection does not find it.
func WithTenantField(f FieldFunc) Option {
	return func(o *options) {
		if f != nil {
			o.field = f
		}
	}
}

func newOptions(opts []Option) options {
	o := options{field: ProtoTenantField}
	for _, apply := range opts {
		apply(&o)
	}
	return o
}

// Interceptor returns a Connect server interceptor that asserts and stamps the
// tenant of every RPC, streaming included. Place it directly after the tenancy
// access interceptor so claims are authenticated and partition access already
// checked.
//
// RPCs with a single request message (unary and server-streaming) resolve the
// tenant from the request's tenant_id field (when the shape has one) and the
// X-Tenant-Id header before the handler runs; the field is rewritten with the
// resolved tenant so handlers never see a caller-chosen value. Client and bidi
// streams resolve from the header and assert every received message against
// that tenant.
func Interceptor(opts ...Option) connect.ServerInterceptor {
	o := newOptions(opts)
	return func(next connect.ServerFunc) connect.ServerFunc {
		return func(ctx context.Context, spec connect.Spec, stream connect.ServerStream) error {
			claims := security.ClaimsFromContext(ctx)
			header := requestHeader(ctx, HeaderTenantID)
			if spec.StreamType == connect.StreamTypeUnary || spec.StreamType == connect.StreamTypeServer {
				return serveSingleRequest(ctx, spec, stream, next, claims, header, o)
			}
			tenant, err := Resolve(claims, header)
			if err != nil {
				return err
			}
			wrapped := &stampingStream{ServerStream: stream, tenant: tenant, field: o.field}
			return next(bindInternal(ctx, claims, tenant), spec, wrapped)
		}
	}
}

// serveSingleRequest reads the one request message up front, so the tenant it
// names can be resolved and bound to the context the handler runs with, then
// hands the stamped message to the handler.
func serveSingleRequest(
	ctx context.Context,
	spec connect.Spec,
	stream connect.ServerStream,
	next connect.ServerFunc,
	claims *security.AuthenticationClaims,
	header string,
	o options,
) error {
	msg, err := newRequestMessage(spec)
	if err != nil {
		return err
	}
	if err = stream.Receive(msg); err != nil {
		return err
	}
	field := o.field(msg)
	named := ""
	if field != nil {
		named = field.Get()
	}
	requested, err := requestedTenant(named, header)
	if err != nil {
		return err
	}
	tenant, err := Resolve(claims, requested)
	if err != nil {
		return err
	}
	if field != nil {
		field.Set(tenant)
	}
	return next(bindInternal(ctx, claims, tenant), spec, &replayStream{ServerStream: stream, first: msg})
}

// newRequestMessage allocates the request message type of the RPC from the
// method descriptor the generated code registers as the spec's schema.
func newRequestMessage(spec connect.Spec) (proto.Message, error) {
	md, ok := spec.Schema.(protoreflect.MethodDescriptor)
	if !ok {
		return nil, connect.NewError(connect.CodeInternal, "tenant assertion: method schema unavailable")
	}
	mt, err := protoregistry.GlobalTypes.FindMessageByName(md.Input().FullName())
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, "tenant assertion: request type unknown").WithCause(err)
	}
	return mt.New().Interface(), nil
}

func requestHeader(ctx context.Context, key string) string {
	if info, ok := connect.CallInfoForServerContext(ctx); ok {
		return info.RequestHeader().Get(key)
	}
	return ""
}

// replayStream returns the already-received, stamped request message on the
// handler's first Receive and defers to the underlying stream after that.
type replayStream struct {
	connect.ServerStream
	first    proto.Message
	replayed bool
}

func (r *replayStream) Receive(msg any) error {
	if r.replayed {
		return r.ServerStream.Receive(msg)
	}
	r.replayed = true
	dst, ok := msg.(proto.Message)
	if !ok {
		return connect.NewError(connect.CodeInternal, "tenant assertion: request is not a protobuf message")
	}
	proto.Reset(dst)
	proto.Merge(dst, r.first)
	return nil
}

// stampingStream asserts and stamps every request message a client or bidi
// stream receives against the tenant resolved when the stream opened.
type stampingStream struct {
	connect.ServerStream
	tenant string
	field  FieldFunc
}

func (c *stampingStream) Receive(msg any) error {
	if err := c.ServerStream.Receive(msg); err != nil {
		return err
	}
	field := c.field(msg)
	if field == nil {
		return nil
	}
	if _, err := requestedTenant(field.Get(), c.tenant); err != nil {
		return connect.NewError(connect.CodePermissionDenied, ErrTenantMismatch.Error()).WithCause(ErrTenantMismatch)
	}
	field.Set(c.tenant)
	return nil
}

// Middleware is the http.Handler form for services that expose plain HTTP
// routes. Mount it after frame's authentication middleware. The tenant is
// resolved from the claims and the X-Tenant-Id header; internal principals
// are bound to the named tenant for the rest of the request.
func Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		claims := security.ClaimsFromContext(r.Context())
		tenant, err := Resolve(claims, r.Header.Get(HeaderTenantID))
		if err != nil {
			http.Error(w, err.Error(), httpStatus(err))
			return
		}
		next.ServeHTTP(w, r.WithContext(bindInternal(r.Context(), claims, tenant)))
	})
}
