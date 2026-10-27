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

// Package tenantassert asserts the tenant every authenticated request runs
// as, independently of the RPC or HTTP framework in front of it.
//
// Frame's tenancy layer trusts the caller's claims and, for principals
// carrying the internal role, skips row-level tenancy binding altogether. That
// leaves two gaps this package closes for every service:
//
//   - a principal whose claims name no tenant is refused rather than treated
//     as "unscoped, allow";
//   - an internal principal (the only cross-tenant role) must name the tenant
//     it acts for — through a tenant_id field on the request message when the
//     message carries one, or through the X-Tenant-Id header otherwise — and
//     that tenant is bound as the request's row-level scope.
//
// Tenant principals always run as their own tenant; naming any other tenant
// is refused.
package tenantassert

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strings"

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/tenancy"
	"github.com/pitabwire/util"
)

// HeaderTenantID is the request header an internal principal uses to name
// the tenant it acts for when the request payload carries no tenant field.
const HeaderTenantID = "X-Tenant-Id"

var (
	// ErrMissingCallerIdentity is returned when a request carries no claims.
	ErrMissingCallerIdentity = errors.New("missing caller identity")

	// ErrUnscopedCaller is returned when a tenant principal presents claims
	// with no tenant: such a token names no scope, so nothing can be
	// evaluated against it.
	ErrUnscopedCaller = errors.New("caller claims carry no tenant")

	// ErrInternalTenantRequired is returned when an internal principal, the
	// only role allowed to act across tenants, omits the tenant it acts for.
	ErrInternalTenantRequired = errors.New("internal principal must name the tenant explicitly")

	// ErrTenantMismatch is returned when a request names a tenant other than
	// the one the caller belongs to.
	ErrTenantMismatch = errors.New("tenant mismatch")

	// ErrConflictingTenant is returned when the request field and the
	// X-Tenant-Id header disagree.
	ErrConflictingTenant = errors.New("request field and X-Tenant-Id header name different tenants")
)

// Resolve decides which tenant a request runs as.
//
// A tenant principal always runs as its own tenant, and a request naming any
// other tenant is refused. Claims with no tenant at all are refused outright.
// An internal principal carries no tenant of its own, so the requested tenant
// is authoritative for it and must be present. Errors are connect errors so
// they map directly onto both Connect and HTTP responses.
func Resolve(claims *security.AuthenticationClaims, requested string) (string, error) {
	if claims == nil {
		return "", connect.NewError(connect.CodeUnauthenticated, ErrMissingCallerIdentity.Error()).
			WithCause(ErrMissingCallerIdentity)
	}
	requested = strings.TrimSpace(requested)
	ctxTenant := strings.TrimSpace(claims.GetTenantID())

	if ctxTenant == "" {
		if !claims.IsInternalSystem() {
			return "", connect.NewError(connect.CodeUnauthenticated, ErrUnscopedCaller.Error()).
				WithCause(ErrUnscopedCaller)
		}
		if requested == "" {
			return "", connect.NewError(connect.CodeInvalidArgument, ErrInternalTenantRequired.Error()).
				WithCause(ErrInternalTenantRequired)
		}
		return requested, nil
	}

	if requested != "" && requested != ctxTenant {
		return "", connect.NewError(
			connect.CodePermissionDenied,
			fmt.Errorf("%w: request=%q ctx=%q", ErrTenantMismatch, requested, ctxTenant).
				Error(),
		).WithCause(ErrTenantMismatch)
	}
	return ctxTenant, nil
}

// requestedTenant merges the tenant named on the payload with the one named
// in the header. Either may be empty; both present must agree.
func requestedTenant(field, header string) (string, error) {
	field = strings.TrimSpace(field)
	header = strings.TrimSpace(header)
	switch {
	case field == "":
		return header, nil
	case header == "" || header == field:
		return field, nil
	default:
		return "", connect.NewError(connect.CodeInvalidArgument, ErrConflictingTenant.Error()).
			WithCause(ErrConflictingTenant)
	}
}

// bindInternal narrows an internal principal's row-level scope to the tenant
// it named. Frame's legacy binder marks internal callers Skip, which disables
// tenancy binding entirely; rebinding tenant-only (no partition list) keeps
// every partition of that tenant visible while excluding every other tenant.
//
// A tenant principal (a person) keeps the claims frame already bound for
// them, and their tenancy is also set as the context's tenancy: a service
// calls its peers under its own tenant-less service account, and the client
// names the tenant and partition it acts in (X-Tenant-Id, X-Partition-Id)
// only from the context's tenancy, so without this every peer call made
// while serving a person was refused for naming no tenant.
func bindInternal(ctx context.Context, claims *security.AuthenticationClaims, tenant string) context.Context {
	if claims == nil {
		return ctx
	}
	if !claims.IsInternalSystem() {
		if util.GetTenancy(ctx) == nil && strings.TrimSpace(claims.GetTenantID()) != "" {
			return util.SetTenancy(ctx, claims)
		}
		return ctx
	}
	return tenancy.WithClaims(ctx, &tenancy.Claims{
		TenantID: tenant,
		AccessID: claims.GetAccessID(),
	})
}

// httpStatus maps the connect error codes Resolve produces onto HTTP.
func httpStatus(err error) int {
	switch connect.CodeOf(err) { //nolint:exhaustive // only the codes Resolve produces are mapped
	case connect.CodeUnauthenticated:
		return http.StatusUnauthorized
	case connect.CodePermissionDenied:
		return http.StatusForbidden
	case connect.CodeInvalidArgument:
		return http.StatusBadRequest
	default:
		return http.StatusInternalServerError
	}
}
