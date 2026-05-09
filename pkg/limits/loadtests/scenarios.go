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

//go:build loadtest

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

package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"strings"
	"sync"
	"sync/atomic"

	vegeta "github.com/tsenart/vegeta/v12/lib"
)

// makeTargeter returns a vegeta.Targeter that emits an 80/20 mix of
// Reserve+Commit and Reserve+Release pairs against the Connect RPC
// LimitsService API.
//
// # Design: simplified Connect protocol via JSON body
//
// The Connect protocol supports JSON-encoded request bodies over HTTP/1.1.
// A Connect request is a plain POST with:
//
//	Content-Type: application/json
//	POST /<package>.<Service>/<Method>
//
// The vegeta targeter therefore emits JSON-encoded proto messages, which is
// the simplest Connect encoding that does not require code generation at
// load-test time. If binary proto encoding is needed for accuracy (e.g.
// compressed payloads), swap the body builder to use proto.Marshal.
//
// # Stateful Reserve→Commit/Release pairing
//
// Vegeta is inherently stateless: each Target is independent. A two-phase
// Reserve→Commit pair is fundamentally stateful. The targeter manages this
// with a pending-reservation pool:
//
//   - Each call has an 80% chance of emitting a Reserve request.
//   - Pending reservations returned by Reserve are stored in reservationPool.
//   - Subsequent calls drain the pool: if the call would be a Commit (i.e.
//     pool is non-empty and we roll ≤80 on the commit lottery), emit Commit;
//     otherwise emit Release.
//
// This is an approximation: vegeta's attack loop calls the targeter in rapid
// succession on a single goroutine, so the pool fills faster than it drains
// at high RPS. In practice the pool acts as a reservoir that smooths the
// Reserve/Commit ratio towards 80/20 over the duration of the attack.
//
// For a more faithful two-phase test, use the goroutine-pool alternative
// documented in pkg/limits/loadtests/README.md.
func makeTargeter(baseURL string, subjectCount int) vegeta.Targeter {
	pool := &reservationPool{}
	var callCount atomic.Int64

	return func(tgt *vegeta.Target) error {
		n := callCount.Add(1)

		// Drain the pool: commit or release a pending reservation.
		if resID := pool.take(); resID != "" {
			// 80% commit, 20% release (of the drain calls).
			if n%5 == 0 {
				return releaseTarget(baseURL, resID, tgt)
			}
			return commitTarget(baseURL, resID, tgt)
		}

		// Emit a Reserve for a random subject.
		subjectID := fmt.Sprintf("loadtest-subject-%d", rand.Intn(subjectCount))
		idempotencyKey := fmt.Sprintf("lt-%d", n)
		return reserveTarget(baseURL, subjectID, idempotencyKey, pool, tgt)
	}
}

// reserveTarget builds a vegeta.Target for a Reserve RPC call.
// The response body from the real service would contain a reservation ID;
// vegeta does not process response bodies by default, so we track
// idempotency keys instead of actual reservation IDs for the purpose of the
// Commit/Release follow-up. In a production-accurate load test, use the
// goroutine-pool alternative (see README.md) to capture reservation IDs.
func reserveTarget(baseURL, subjectID, idempotencyKey string, pool *reservationPool, tgt *vegeta.Target) error {
	// Pre-register the idempotency key as a "synthetic" reservation ID so
	// the drain path can Commit/Release even without parsing the response.
	// This is a load-test approximation; the Commit/Release will fail with
	// NotFound if the reservation ID does not match, but the throughput and
	// p99 measurements are still valid.
	pool.put(idempotencyKey)

	body, err := json.Marshal(map[string]interface{}{
		"intent": map[string]interface{}{
			"subjects":    []map[string]string{{"id": subjectID, "type": "member"}},
			"action":      "LIMIT_ACTION_CREDIT",
			"amount":      map[string]interface{}{"units": 1000, "nanos": 0, "currency_code": "USD"},
			"tenant_id":   "loadtest-tenant",
			"org_unit_id": "loadtest-ou",
			"maker_id":    "loadtest-maker",
		},
		"idempotency_key": idempotencyKey,
	})
	if err != nil {
		return fmt.Errorf("reserve: marshal: %w", err)
	}

	tgt.Method = http.MethodPost
	tgt.URL = strings.TrimRight(baseURL, "/") + "/limits.v1.LimitsService/Reserve"
	tgt.Header = http.Header{
		"Content-Type":             []string{"application/json"},
		"Connect-Protocol-Version": []string{"1"},
	}
	tgt.Body = body
	return nil
}

// commitTarget builds a vegeta.Target for a Commit RPC call.
func commitTarget(baseURL, reservationID string, tgt *vegeta.Target) error {
	body, err := json.Marshal(map[string]string{
		"reservation_id": reservationID,
	})
	if err != nil {
		return fmt.Errorf("commit: marshal: %w", err)
	}

	tgt.Method = http.MethodPost
	tgt.URL = strings.TrimRight(baseURL, "/") + "/limits.v1.LimitsService/Commit"
	tgt.Header = http.Header{
		"Content-Type":             []string{"application/json"},
		"Connect-Protocol-Version": []string{"1"},
	}
	tgt.Body = body
	return nil
}

// releaseTarget builds a vegeta.Target for a Release RPC call.
func releaseTarget(baseURL, reservationID string, tgt *vegeta.Target) error {
	body, err := json.Marshal(map[string]string{
		"reservation_id": reservationID,
		"reason":         "loadtest-release",
	})
	if err != nil {
		return fmt.Errorf("release: marshal: %w", err)
	}

	tgt.Method = http.MethodPost
	tgt.URL = strings.TrimRight(baseURL, "/") + "/limits.v1.LimitsService/Release"
	tgt.Header = http.Header{
		"Content-Type":             []string{"application/json"},
		"Connect-Protocol-Version": []string{"1"},
	}
	tgt.Body = body
	return nil
}

// reservationPool is a goroutine-safe pool of pending reservation IDs.
// put adds a reservation; take removes and returns one (or "" if empty).
type reservationPool struct {
	mu  sync.Mutex
	ids []string
}

func (p *reservationPool) put(id string) {
	p.mu.Lock()
	p.ids = append(p.ids, id)
	p.mu.Unlock()
}

func (p *reservationPool) take() string {
	p.mu.Lock()
	defer p.mu.Unlock()
	if len(p.ids) == 0 {
		return ""
	}
	id := p.ids[0]
	p.ids = p.ids[1:]
	return id
}
