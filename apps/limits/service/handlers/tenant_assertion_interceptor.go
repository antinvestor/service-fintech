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
	"fmt"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/security"
)

// TenantAssertionInterceptor enforces that any tenant_id carried in a request
// payload matches the partition derived from the authenticated context. For
// requests that pass tenant_id (Reserve), payload-trust is removed: the
// interceptor overwrites the field with the auth-derived value. For requests
// that pass only IDs (Commit/Release/Reverse), tenancy is enforced by the
// repository's scoped methods.
func TenantAssertionInterceptor() connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			claims := security.ClaimsFromContext(ctx)
			if claims == nil {
				return next(ctx, req)
			}
			// intent.tenant_id carries the tenant identifier (GetTenantID), not
			// the partition identifier. Use GetTenantID() as the authoritative value.
			ctxTenant := claims.GetTenantID()
			if r, ok := req.Any().(*limitsv1.ReserveRequest); ok {
				got := r.GetIntent().GetTenantId()
				if got != "" && got != ctxTenant {
					return nil, connect.NewError(connect.CodePermissionDenied,
						fmt.Errorf("tenant mismatch: intent=%q ctx=%q", got, ctxTenant))
				}
				if r.GetIntent() != nil {
					r.Intent.TenantId = ctxTenant
				}
			}
			return next(ctx, req)
		}
	}
}
