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

	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/security"
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

// Interceptor returns a Connect interceptor that asserts and stamps the tenant
// of every RPC, streaming included. Place it directly after the tenancy access
// interceptor so claims are authenticated and partition access already checked.
//
// Unary RPCs resolve the tenant from the request message's tenant_id field
// (when the shape has one) and the X-Tenant-Id header; the field is rewritten
// with the resolved tenant so handlers never see a caller-chosen value.
// Streaming handlers resolve from the header before the handler runs and
// assert every received message against that tenant.
func Interceptor(opts ...Option) connect.Interceptor {
	return &interceptor{opts: newOptions(opts)}
}

type interceptor struct {
	opts options
}

func (i *interceptor) WrapUnary(next connect.UnaryFunc) connect.UnaryFunc {
	return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
		claims := security.ClaimsFromContext(ctx)
		field := i.opts.field(req.Any())
		named := ""
		if field != nil {
			named = field.Get()
		}
		requested, err := requestedTenant(named, req.Header().Get(HeaderTenantID))
		if err != nil {
			return nil, err
		}
		tenant, err := Resolve(claims, requested)
		if err != nil {
			return nil, err
		}
		if field != nil {
			field.Set(tenant)
		}
		return next(bindInternal(ctx, claims, tenant), req)
	}
}

// WrapStreamingClient is a pass-through: outbound client streams originate
// in this service, so there is no caller-supplied tenant to assert.
func (i *interceptor) WrapStreamingClient(next connect.StreamingClientFunc) connect.StreamingClientFunc {
	return next
}

func (i *interceptor) WrapStreamingHandler(next connect.StreamingHandlerFunc) connect.StreamingHandlerFunc {
	return func(ctx context.Context, conn connect.StreamingHandlerConn) error {
		claims := security.ClaimsFromContext(ctx)
		tenant, err := Resolve(claims, conn.RequestHeader().Get(HeaderTenantID))
		if err != nil {
			return err
		}
		wrapped := &stampingHandlerConn{StreamingHandlerConn: conn, tenant: tenant, field: i.opts.field}
		return next(bindInternal(ctx, claims, tenant), wrapped)
	}
}

// stampingHandlerConn asserts and stamps every request message a streaming
// handler receives against the tenant resolved when the stream opened.
type stampingHandlerConn struct {
	connect.StreamingHandlerConn
	tenant string
	field  FieldFunc
}

func (c *stampingHandlerConn) Receive(msg any) error {
	if err := c.StreamingHandlerConn.Receive(msg); err != nil {
		return err
	}
	field := c.field(msg)
	if field == nil {
		return nil
	}
	if _, err := requestedTenant(field.Get(), c.tenant); err != nil {
		return connect.NewError(connect.CodePermissionDenied, ErrTenantMismatch)
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
