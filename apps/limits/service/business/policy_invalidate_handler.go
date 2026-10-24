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

package business

import (
	"context"
	"errors"

	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/limits/service/events"
)

// PolicyInvalidateHandler is the Frame event subscriber that drops the local
// candidate-policy cache when any replica saves or deletes a policy.
// PolicyBusiness emits events.EventPolicyInvalidate after every committed
// change; registering this handler with frame.WithRegisterEvents lets every
// replica that receives the event purge immediately instead of waiting for
// the cache TTL. The TTL remains the upper bound for a replica that misses
// the event.
type PolicyInvalidateHandler struct {
	cache *PolicyCache
}

// NewPolicyInvalidateHandler wires the subscriber to the cache it purges. A
// nil cache yields a handler that validates and acknowledges events without
// doing anything, so registration is always safe.
func NewPolicyInvalidateHandler(cache *PolicyCache) *PolicyInvalidateHandler {
	return &PolicyInvalidateHandler{cache: cache}
}

// Name is the event topic this handler consumes.
func (h *PolicyInvalidateHandler) Name() string { return events.EventPolicyInvalidate }

// PayloadType tells the events pipeline how to decode the queued payload.
func (h *PolicyInvalidateHandler) PayloadType() any { return &events.PolicyInvalidatePayload{} }

// Validate rejects payloads that are not a PolicyInvalidatePayload. A malformed
// payload is final: retrying it can never succeed.
func (h *PolicyInvalidateHandler) Validate(_ context.Context, payload any) error {
	if _, ok := payload.(*events.PolicyInvalidatePayload); !ok {
		return errors.New("payload is not of type events.PolicyInvalidatePayload")
	}
	return nil
}

// Execute purges the local cache. Purging is idempotent, so a redelivered
// event is harmless.
func (h *PolicyInvalidateHandler) Execute(ctx context.Context, payload any) error {
	p, ok := payload.(*events.PolicyInvalidatePayload)
	if !ok {
		return errors.New("payload is not of type events.PolicyInvalidatePayload")
	}
	if h.cache == nil {
		return nil
	}
	h.cache.InvalidateTenant(p.TenantID)
	util.Log(ctx).
		With("policy_id", p.PolicyID).
		With("tenant_id", p.TenantID).
		Debug("limits: candidate-policy cache purged on invalidation event")
	return nil
}
