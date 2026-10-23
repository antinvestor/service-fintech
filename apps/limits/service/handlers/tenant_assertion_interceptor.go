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

package handlers

import (
	"context"
	"errors"
	"fmt"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/security"
)

// errMissingCallerIdentity is returned when a request carries no claims at all.
var errMissingCallerIdentity = errors.New("missing caller identity")

// errUnscopedCaller is returned when a human/tenant principal presents claims
// with no tenant. Such a token names no scope, so no tenanted RPC can be
// evaluated against it.
var errUnscopedCaller = errors.New("caller claims carry no tenant")

// errInternalTenantRequired is returned when an internal-system principal —
// the only role allowed to act across tenants — omits the tenant it is acting
// for.
var errInternalTenantRequired = errors.New("internal principal must name tenant_id explicitly")

// tenantAssertionInterceptor removes payload-trust from every request that
// carries caller-supplied identity.
//
//   - tenant_id: rejected when it names a tenant other than the caller's, then
//     overwritten with the auth-derived value.
//   - maker_id: always overwritten from the caller's claims. It drives the
//     maker-cannot-approve-own-request check, so a client that could choose it
//     could approve its own high-value disbursement.
//
// Requests that carry only IDs (Commit/Release/Reverse) are covered by the
// business layer's tenant assertion against the stored row.
//
// It fails closed twice over: a request with no claims never reaches a handler,
// and a request whose claims carry no tenant is rejected rather than stamped
// with an empty tenant that every downstream guard would then treat as
// "unscoped, allow". Internal-system principals are the single exception; they
// act across tenants and must therefore name the tenant in the request.
//
// Both unary and server-streaming handlers are covered: the streaming RPCs
// (PolicySearch, ApprovalRequestList, LedgerSearch) receive their request
// message through the handler connection, so the connection is wrapped and the
// stamping runs on Receive.
type tenantAssertionInterceptor struct{}

// TenantAssertionInterceptor returns the interceptor that asserts and stamps
// caller-supplied identity on every limits RPC, streaming included.
func TenantAssertionInterceptor() connect.Interceptor {
	return tenantAssertionInterceptor{}
}

func (tenantAssertionInterceptor) WrapUnary(next connect.UnaryFunc) connect.UnaryFunc {
	return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
		if err := stampFromContext(ctx, req.Any()); err != nil {
			return nil, err
		}
		return next(ctx, req)
	}
}

// WrapStreamingClient is a pass-through: outbound client streams originate in
// this service, so there is no caller-supplied payload to assert.
func (tenantAssertionInterceptor) WrapStreamingClient(
	next connect.StreamingClientFunc,
) connect.StreamingClientFunc {
	return next
}

func (tenantAssertionInterceptor) WrapStreamingHandler(
	next connect.StreamingHandlerFunc,
) connect.StreamingHandlerFunc {
	return func(ctx context.Context, conn connect.StreamingHandlerConn) error {
		return next(ctx, &stampingHandlerConn{StreamingHandlerConn: conn, ctx: ctx})
	}
}

// stampingHandlerConn asserts and stamps every request message a streaming
// handler receives.
type stampingHandlerConn struct {
	connect.StreamingHandlerConn
	//nolint:containedctx // the handler ctx carries the claims Receive must assert against
	ctx context.Context
}

func (c *stampingHandlerConn) Receive(msg any) error {
	if err := c.StreamingHandlerConn.Receive(msg); err != nil {
		return err
	}
	return stampFromContext(c.ctx, msg)
}

func stampFromContext(ctx context.Context, msg any) error {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return connect.NewError(connect.CodeUnauthenticated, errMissingCallerIdentity)
	}
	return stampIdentity(msg, claims)
}

// tenantField is the caller-supplied identity carried by one request shape.
type tenantField struct {
	get      func() string
	set      func(string)
	setMaker func(string)
}

// tenantFieldOf returns the identity carried by msg, or nil when the shape
// carries none and there is nothing to assert.
func tenantFieldOf(msg any) *tenantField {
	switch r := msg.(type) {
	case *limitsv1.ReserveRequest:
		return intentTenantField(r.GetIntent())
	case *limitsv1.CheckRequest:
		return intentTenantField(r.GetIntent())
	case *limitsv1.PolicySearchRequest:
		return &tenantField{get: r.GetTenantId, set: func(v string) { r.TenantId = v }}
	case *limitsv1.ApprovalRequestListRequest:
		return &tenantField{get: r.GetTenantId, set: func(v string) { r.TenantId = v }}
	case *limitsv1.LedgerSearchRequest:
		return &tenantField{get: r.GetTenantId, set: func(v string) { r.TenantId = v }}
	case *limitsv1.PolicySaveRequest:
		data := r.GetData()
		if data == nil {
			return nil
		}
		return &tenantField{get: data.GetTenantId, set: func(v string) { data.TenantId = v }}
	default:
		return nil
	}
}

func intentTenantField(intent *limitsv1.LimitIntent) *tenantField {
	if intent == nil {
		return nil
	}
	return &tenantField{
		get:      intent.GetTenantId,
		set:      func(v string) { intent.TenantId = v },
		setMaker: func(v string) { intent.MakerId = v },
	}
}

// stampIdentity asserts the caller-supplied identity of msg and rewrites it
// from the authenticated claims.
func stampIdentity(msg any, claims *security.AuthenticationClaims) error {
	field := tenantFieldOf(msg)
	if field == nil {
		return nil
	}

	tenant, err := resolveTenant(claims, field.get())
	if err != nil {
		return err
	}

	field.set(tenant)
	if field.setMaker != nil {
		field.setMaker(claims.GetProfileID())
	}
	return nil
}

// resolveTenant decides which tenant a request runs as.
//
// A tenant principal always runs as its own tenant, and a payload naming any
// other tenant is refused. Claims with no tenant at all are refused outright:
// stamping "" would leave every downstream `if tenant != ""` guard disabled.
//
// An internal-system principal is the documented cross-tenant exception (see
// docs/runbook/limits-rollout.md). It carries no tenant of its own, so the
// request field is authoritative for it and must be present.
func resolveTenant(claims *security.AuthenticationClaims, requested string) (string, error) {
	ctxTenant := claims.GetTenantID()

	if ctxTenant == "" {
		if !claims.IsInternalSystem() {
			return "", connect.NewError(connect.CodeUnauthenticated, errUnscopedCaller)
		}
		if requested == "" {
			return "", connect.NewError(connect.CodeInvalidArgument, errInternalTenantRequired)
		}
		return requested, nil
	}

	if requested != "" && requested != ctxTenant {
		return "", connect.NewError(connect.CodePermissionDenied,
			fmt.Errorf("tenant mismatch: request=%q ctx=%q", requested, ctxTenant))
	}
	return ctxTenant, nil
}
