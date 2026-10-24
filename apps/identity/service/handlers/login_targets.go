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
	"encoding/json"
	"net"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"time"

	"golang.org/x/time/rate"

	"github.com/antinvestor/service-fintech/apps/identity/service/business"
)

const (
	loginTargetsRatePerSecond = 5
	loginTargetsBurst         = 20
	loginTargetsLimiterTTL    = 10 * time.Minute
)

// LoginTargetsHandler serves the pre-login organization picker. It is
// reachable without a token, so it only answers browsers from the origins
// that host the login flow and is rate limited per client address.
type LoginTargetsHandler struct {
	loginClientBusiness business.LoginClientBusiness
	allowedOrigins      map[string]struct{}

	mu       sync.Mutex
	limiters map[string]*clientLimiter
}

type clientLimiter struct {
	limiter  *rate.Limiter
	lastSeen time.Time
}

// NewLoginTargetsHandler builds the handler. redirectURIs are the OAuth
// redirect URIs registered for the login clients; their web origins are the
// only ones allowed to call this endpoint cross-origin.
func NewLoginTargetsHandler(lcb business.LoginClientBusiness, redirectURIs []string) *LoginTargetsHandler {
	return &LoginTargetsHandler{
		loginClientBusiness: lcb,
		allowedOrigins:      originsFromRedirectURIs(redirectURIs),
		limiters:            make(map[string]*clientLimiter),
	}
}

func (h *LoginTargetsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	h.applyCORS(w, r)
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if !h.allow(clientAddress(r)) {
		http.Error(w, "too many requests", http.StatusTooManyRequests)
		return
	}

	clientID := strings.TrimRight(strings.TrimPrefix(r.URL.Path, "/api/v1/login-targets/"), "/")
	if clientID == "" {
		http.Error(w, "client_id is required", http.StatusBadRequest)
		return
	}

	resp, err := h.loginClientBusiness.GetLoginTargets(r.Context(), clientID)
	if err != nil {
		http.Error(w, "failed to resolve login targets", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if encErr := json.NewEncoder(w).Encode(resp); encErr != nil {
		http.Error(w, "failed to encode response", http.StatusInternalServerError)
	}
}

// applyCORS echoes the request origin only when it is one of the login
// origins. Same-origin and non-browser callers carry no Origin header and
// need no CORS headers.
func (h *LoginTargetsHandler) applyCORS(w http.ResponseWriter, r *http.Request) {
	origin := r.Header.Get("Origin")
	if origin == "" {
		return
	}
	w.Header().Add("Vary", "Origin")
	if _, ok := h.allowedOrigins[strings.ToLower(origin)]; !ok {
		return
	}
	w.Header().Set("Access-Control-Allow-Origin", origin)
	w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
	w.Header().Set("Access-Control-Max-Age", "600")
}

func (h *LoginTargetsHandler) allow(addr string) bool {
	now := time.Now()

	h.mu.Lock()
	defer h.mu.Unlock()

	for key, cl := range h.limiters {
		if now.Sub(cl.lastSeen) > loginTargetsLimiterTTL {
			delete(h.limiters, key)
		}
	}

	cl, ok := h.limiters[addr]
	if !ok {
		cl = &clientLimiter{limiter: rate.NewLimiter(loginTargetsRatePerSecond, loginTargetsBurst)}
		h.limiters[addr] = cl
	}
	cl.lastSeen = now
	return cl.limiter.Allow()
}

// clientAddress prefers the first X-Forwarded-For hop (set by the ingress)
// and falls back to the socket address.
func clientAddress(r *http.Request) string {
	if fwd := r.Header.Get("X-Forwarded-For"); fwd != "" {
		if first, _, found := strings.Cut(fwd, ","); found || first != "" {
			return strings.TrimSpace(first)
		}
	}
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}

// originsFromRedirectURIs keeps the scheme://host[:port] of every http(s)
// redirect URI; custom app schemes have no browser origin and are skipped.
func originsFromRedirectURIs(redirectURIs []string) map[string]struct{} {
	origins := make(map[string]struct{}, len(redirectURIs))
	for _, raw := range redirectURIs {
		u, err := url.Parse(strings.TrimSpace(raw))
		if err != nil || u.Host == "" {
			continue
		}
		if u.Scheme != "http" && u.Scheme != "https" {
			continue
		}
		origins[strings.ToLower(u.Scheme+"://"+u.Host)] = struct{}{}
	}
	return origins
}
