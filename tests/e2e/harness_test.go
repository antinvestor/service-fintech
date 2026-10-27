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

package e2e_test

import (
	"context"
	"errors"
	"net/http"
	"net/url"
	"sync"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/antinvestor/common/v3/interceptors"
	"github.com/pitabwire/frame/v3/security"
)

// Hosts the real services are reached under. Each service's clients are
// built before its peer is listening, so a client names its peer by host and
// the router resolves that host to the peer's test server on every request.
const (
	loansHost      = "http://loans.e2e"
	operationsHost = "http://operations.e2e"
)

// hostRouter sends each request to the test server registered for its host.
type hostRouter struct {
	mu      sync.RWMutex
	targets map[string]*url.URL
	next    http.RoundTripper
}

func newHostRouter() *hostRouter {
	return &hostRouter{targets: map[string]*url.URL{}, next: http.DefaultTransport}
}

func (r *hostRouter) route(host, target string) {
	u, err := url.Parse(target)
	if err != nil {
		panic(err)
	}
	r.mu.Lock()
	defer r.mu.Unlock()
	r.targets[host] = u
}

func (r *hostRouter) RoundTrip(req *http.Request) (*http.Response, error) {
	r.mu.RLock()
	target, ok := r.targets[req.URL.Host]
	r.mu.RUnlock()
	if !ok {
		return r.next.RoundTrip(req)
	}
	out := req.Clone(req.Context())
	out.URL.Scheme = target.Scheme
	out.URL.Host = target.Host
	out.Host = target.Host
	return r.next.RoundTrip(out)
}

// client builds a Connect client the way connection.NewServiceClient does:
// an HTTP transport (Connect GET for side-effect-free RPCs) wrapped in the
// bearer token and the platform's own partition-header interceptor, which
// carries the caller's tenancy to the peer.
func client(transport http.RoundTripper, base, token string) *connect.Client {
	httpClient := &http.Client{Transport: transport}
	return connect.NewClient(
		connecthttp.NewTransport(httpClient, base, connecthttp.WithHTTPGet()),
		bearer(token),
		interceptors.NewPartitionInfoInterceptor("e2e"),
	)
}

func bearer(token string) connect.ClientInterceptor {
	return func(next connect.ClientFunc) connect.ClientFunc {
		return func(ctx context.Context, spec connect.Spec) (connect.ClientStream, error) {
			if info, ok := connect.CallInfoForClientContext(ctx); ok {
				info.RequestHeader().Set("Authorization", "Bearer "+token)
			}
			return next(ctx, spec)
		}
	}
}

// tokens stands in for the OIDC provider: each opaque token names the claims
// a verified JWT would carry. The real servers authenticate with it through
// frame's own auth interceptor, so everything after token verification —
// tenancy enrichment for internal callers, the claims binder, the loans
// read scope and the internal-only checks — runs as in production.
type tokens struct {
	mu     sync.RWMutex
	claims map[string]*security.AuthenticationClaims
}

func newTokens() *tokens { return &tokens{claims: map[string]*security.AuthenticationClaims{}} }

func (t *tokens) issue(token string, claims *security.AuthenticationClaims) {
	t.mu.Lock()
	defer t.mu.Unlock()
	t.claims[token] = claims
}

var errUnknownToken = errors.New("unknown token")

func (t *tokens) Authenticate(
	ctx context.Context,
	token string,
	_ ...security.AuthOption,
) (context.Context, error) {
	t.mu.RLock()
	issued, ok := t.claims[token]
	t.mu.RUnlock()
	if !ok {
		return ctx, errUnknownToken
	}
	claims := *issued
	claims.Roles = append([]string(nil), issued.Roles...)
	claims.NormalizeIdentity()
	ctx = security.JwtToContext(ctx, token)
	return claims.ClaimsToContext(ctx), nil
}
