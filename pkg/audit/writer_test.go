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

package audit_test

import (
	"context"
	"errors"
	"sync"
	"testing"

	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/frame/v3/queue"
	"github.com/pitabwire/frame/v3/security"

	"github.com/antinvestor/service-fintech/pkg/audit"
)

// recordingManager captures emitted payloads so tests can assert on the
// event the writer actually built.
type recordingManager struct {
	mu       sync.Mutex
	emitted  []*audit.Event
	emitErr  error
	emitName string
}

func (m *recordingManager) Add(fevents.EventI) {}

func (m *recordingManager) Get(string) (fevents.EventI, error) {
	return nil, errors.New("not implemented")
}

func (m *recordingManager) Emit(_ context.Context, name string, payload any) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.emitName = name
	if m.emitErr != nil {
		return m.emitErr
	}
	ev, ok := payload.(*audit.Event)
	if !ok {
		return errors.New("payload is not an *audit.Event")
	}
	m.emitted = append(m.emitted, ev)
	return nil
}

func (m *recordingManager) Handler() queue.SubscribeWorker { return nil }
func (m *recordingManager) Strict() bool                   { return true }
func (m *recordingManager) SetStrict(bool)                 {}

func (m *recordingManager) last() *audit.Event {
	m.mu.Lock()
	defer m.mu.Unlock()
	if len(m.emitted) == 0 {
		return nil
	}
	return m.emitted[len(m.emitted)-1]
}

func userContext(t *testing.T, partitionID, profileID, contactID string) context.Context {
	t.Helper()
	claims := &security.AuthenticationClaims{
		PartitionID: partitionID,
		TenantID:    "tenant-1",
		ProfileID:   profileID,
		ContactID:   contactID,
	}
	return claims.ClaimsToContext(t.Context())
}

func validRecord() audit.Record {
	return audit.Record{
		EntityType: "loan_account",
		EntityID:   "loan-1",
		Action:     "loan.disbursed",
	}
}

func TestRecordDerivesActorFromClaims(t *testing.T) {
	man := &recordingManager{}
	w := audit.NewWriter(man)

	ctx := userContext(t, "partition-1", "profile-1", "contact-1")
	if err := w.Record(ctx, validRecord()); err != nil {
		t.Fatalf("Record: %v", err)
	}

	ev := man.last()
	if ev == nil {
		t.Fatal("no event emitted")
	}
	if ev.ActorID != "profile-1" {
		t.Errorf("ActorID = %q, want %q", ev.ActorID, "profile-1")
	}
	if ev.ActorType != "user" {
		t.Errorf("ActorType = %q, want %q", ev.ActorType, "user")
	}
	if ev.PartitionID != "partition-1" {
		t.Errorf("PartitionID = %q, want %q", ev.PartitionID, "partition-1")
	}
	if man.emitName != audit.EventSaveEvent {
		t.Errorf("emitted on %q, want %q", man.emitName, audit.EventSaveEvent)
	}
}

func TestRecordKeepsExplicitActor(t *testing.T) {
	man := &recordingManager{}
	w := audit.NewWriter(man)

	r := validRecord()
	r.ActorID = "explicit-actor"
	r.ActorType = "system"

	ctx := userContext(t, "partition-1", "profile-1", "contact-1")
	if err := w.Record(ctx, r); err != nil {
		t.Fatalf("Record: %v", err)
	}

	ev := man.last()
	if ev.ActorID != "explicit-actor" || ev.ActorType != "system" {
		t.Errorf("actor = (%q, %q), want (explicit-actor, system)", ev.ActorID, ev.ActorType)
	}
}

func TestRecordLabelsServiceActor(t *testing.T) {
	man := &recordingManager{}
	w := audit.NewWriter(man)

	claims := &security.AuthenticationClaims{
		PartitionID: "partition-1",
		ProfileID:   "service-profile",
		ServiceName: "service_loans",
	}
	ctx := claims.ClaimsToContext(t.Context())

	if err := w.Record(ctx, validRecord()); err != nil {
		t.Fatalf("Record: %v", err)
	}
	if got := man.last().ActorType; got != "service" {
		t.Errorf("ActorType = %q, want %q", got, "service")
	}
}

func TestRecordRequiresPartition(t *testing.T) {
	man := &recordingManager{}
	w := audit.NewWriter(man)

	err := w.Record(t.Context(), validRecord())
	if !errors.Is(err, audit.ErrAuditNoPartition) {
		t.Fatalf("Record without partition: got %v, want ErrAuditNoPartition", err)
	}
	if man.last() != nil {
		t.Error("event was emitted despite missing partition")
	}
}

func TestRecordTakesPartitionFromParent(t *testing.T) {
	man := &recordingManager{}
	w := audit.NewWriter(man)

	parent := &data.BaseModel{PartitionID: "partition-parent", TenantID: "tenant-parent"}
	r := validRecord()
	r.Parent = parent

	if err := w.Record(t.Context(), r); err != nil {
		t.Fatalf("Record: %v", err)
	}
	if got := man.last().PartitionID; got != "partition-parent" {
		t.Errorf("PartitionID = %q, want %q", got, "partition-parent")
	}
}

func TestRecordWithoutEventsManagerFails(t *testing.T) {
	w := audit.NewWriter(nil)

	ctx := userContext(t, "partition-1", "profile-1", "contact-1")
	if err := w.Record(ctx, validRecord()); !errors.Is(err, audit.ErrAuditDisabled) {
		t.Fatalf("Record on disabled writer: got %v, want ErrAuditDisabled", err)
	}
}

func TestRecordRejectsIncompleteRecord(t *testing.T) {
	man := &recordingManager{}
	w := audit.NewWriter(man)
	ctx := userContext(t, "partition-1", "profile-1", "contact-1")

	for name, r := range map[string]audit.Record{
		"no entity type": {Action: "loan.disbursed"},
		"no action":      {EntityType: "loan_account"},
	} {
		t.Run(name, func(t *testing.T) {
			if err := w.Record(ctx, r); err == nil {
				t.Fatal("expected an error")
			}
		})
	}
}

func TestRecordOrLogSurfacesFailure(t *testing.T) {
	man := &recordingManager{emitErr: errors.New("queue down")}
	w := audit.NewWriter(man)

	var captured error
	ctx := userContext(t, "partition-1", "profile-1", "contact-1")
	w.RecordOrLog(ctx, validRecord(), func(err error) { captured = err })

	if captured == nil {
		t.Fatal("RecordOrLog swallowed the emit failure")
	}
}

func TestEventSaveValidateRequiresPartition(t *testing.T) {
	handler := audit.NewEventSave(t.Context(), nil)

	ev := &audit.Event{EntityType: "loan_account", Action: "loan.disbursed"}
	ev.ID = "audit-1"

	if err := handler.Validate(t.Context(), ev); !errors.Is(err, audit.ErrAuditNoPartition) {
		t.Fatalf("Validate without partition: got %v, want ErrAuditNoPartition", err)
	}

	ev.PartitionID = "partition-1"
	if err := handler.Validate(t.Context(), ev); err != nil {
		t.Fatalf("Validate with partition: %v", err)
	}
}
