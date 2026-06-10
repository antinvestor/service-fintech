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

package business_test

import (
	"context"
	"sync"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/frame/queue"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/limits/service/business"
	"github.com/antinvestor/service-fintech/apps/limits/service/events"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// stubEventsManager records every Emit call for test assertions.
// It implements fevents.Manager with no-op Add/Get/Handler and a
// recording Emit, so tests can assert which events were emitted.
type stubEventsManager struct {
	mu      sync.Mutex
	emitted []emittedEvent
}

type emittedEvent struct {
	Name    string
	Payload any
}

func (s *stubEventsManager) Add(_ fevents.EventI) {}
func (s *stubEventsManager) Get(_ string) (fevents.EventI, error) {
	return nil, nil //nolint:nilnil // no-op stub: tests never look up events
}
func (s *stubEventsManager) Handler() queue.SubscribeWorker { return nil }

// Strict / SetStrict satisfy events.Manager (frame >=v1.98.2); the stub
// never consumes from a queue, so strict mode is irrelevant here.
func (s *stubEventsManager) Strict() bool   { return true }
func (s *stubEventsManager) SetStrict(bool) {}
func (s *stubEventsManager) Emit(_ context.Context, name string, payload any) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.emitted = append(s.emitted, emittedEvent{Name: name, Payload: payload})
	return nil
}

func (s *stubEventsManager) find(name string) (emittedEvent, bool) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, e := range s.emitted {
		if e.Name == name {
			return e, true
		}
	}
	return emittedEvent{}, false
}

// buildPolicyBizWithStub provisions an isolated DB schema and returns a
// PolicyBusiness wired with the provided events manager stub.
func (s *PolicyBusinessSuite) buildPolicyBizWithStub(
	ctx context.Context,
	stub fevents.Manager,
) business.PolicyBusiness {
	s.T().Helper()

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	_, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("limits-events-test"),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })
	svc.Init(ctx)

	dbManager := svc.DatastoreManager()
	s.Require().NoError(repository.Migrate(ctx, dbManager, ""))
	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)

	workMan := svc.WorkManager()
	policyRepo := repository.NewPolicyRepository(ctx, dbPool, workMan)
	versionRepo := repository.NewPolicyVersionRepository(ctx, dbPool, workMan)
	return business.NewPolicyBusiness(policyRepo, versionRepo, stub, nil, nil, nil)
}

// TestSaveEmitsPolicyInvalidate verifies that Save emits
// limits.policy.invalidate.v1 with the correct PolicyID and Action.
func (s *PolicyBusinessSuite) TestSaveEmitsPolicyInvalidate() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-emit", "partition-emit", "")

	stub := &stubEventsManager{}
	biz := s.buildPolicyBizWithStub(ctx, stub)

	in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_ENFORCE)
	out, err := biz.Save(ctx, in)
	s.Require().NoError(err)
	s.Require().NotEmpty(out.GetId())

	ev, ok := stub.find(events.EventPolicyInvalidate)
	s.Require().True(ok, "expected %s to be emitted", events.EventPolicyInvalidate)

	payload, ok := ev.Payload.(events.PolicyInvalidatePayload)
	s.Require().True(ok, "payload type mismatch: got %T", ev.Payload)
	s.Equal(out.GetId(), payload.PolicyID)
	s.Equal("loan_disbursement", payload.Action)
}

// TestDeleteEmitsPolicyInvalidate verifies that Delete also emits the
// policy-invalidate event so multi-replica LRU caches drop the entry.
func (s *PolicyBusinessSuite) TestDeleteEmitsPolicyInvalidate() {
	ctx := s.WithAuthClaims(s.T().Context(), "tenant-emit-del", "partition-emit-del", "")

	stub := &stubEventsManager{}
	biz := s.buildPolicyBizWithStub(ctx, stub)

	in := goodPolicyAPI("KES", limitsv1.PolicyMode_POLICY_MODE_SHADOW)
	out, err := biz.Save(ctx, in)
	s.Require().NoError(err)

	// Reset so only the Delete emission is captured.
	stub.mu.Lock()
	stub.emitted = nil
	stub.mu.Unlock()

	s.Require().NoError(biz.Delete(ctx, out.GetId()))

	ev, ok := stub.find(events.EventPolicyInvalidate)
	s.Require().True(ok, "expected %s to be emitted on Delete", events.EventPolicyInvalidate)

	payload, ok := ev.Payload.(events.PolicyInvalidatePayload)
	s.Require().True(ok, "payload type mismatch: got %T", ev.Payload)
	s.Equal(out.GetId(), payload.PolicyID)
}
