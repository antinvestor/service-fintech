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
	"sync"
	"time"

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"connectrpc.com/connect/v2"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

// memDocuments keeps documents in memory under sequential ids, deduplicated
// on the upload key as the files service is.
type memDocuments struct {
	mu    sync.Mutex
	byKey map[string]string
	puts  int
}

func (m *memDocuments) Put(_ context.Context, doc Document) (string, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.byKey == nil {
		m.byKey = map[string]string{}
	}
	m.puts++
	if id, ok := m.byKey[doc.Key]; ok {
		return id, nil
	}
	id := "media-" + string(rune('a'+len(m.byKey)))
	m.byKey[doc.Key] = id
	return id, nil
}

func (m *memDocuments) Link(_ context.Context, id string, _ time.Duration) (string, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, held := range m.byKey {
		if held == id {
			return "https://files.example/signed/" + id, nil
		}
	}
	return "", connect.NewError(connect.CodePermissionDenied, "not the owner")
}

func (e *approvalWorkflowEnv) documentBusiness(store DocumentStore) ClientDataBusiness {
	return NewClientDataBusiness(e.ctx, e.eventsMan, e.clientDataRepo, e.clientDataHist,
		WithDocumentStore(store),
		WithKYCPolicy(NewKYCPolicy(e.internalTeamRepo, e.organizationRepo, e.formTemplateRepo, e.clientDataRepo)),
		WithClientGuard(e.clientRepo, e.workforceMemberRepo, e.teamMembershipRepo, e.crRepo))
}

// A document is stored by the service and recorded as the client's entry;
// a reviewer gets a short-lived link to it; retrying the same upload stores
// one file.
func (s *approvalWorkflowSuite) TestKYCDocumentIsStoredAndLinked() {
	env := s.newEnv()
	store := &memDocuments{}
	clientData := env.documentBusiness(store)
	env.ensureClient("client-doc")

	upload := &identityv1.ClientDocumentUploadRequest{
		ClientId: "client-doc", FieldKey: "id_front_photo", ValueType: "photo",
		ContentType: "image/jpeg", Filename: "front.jpg", Content: []byte("jpeg-bytes"),
	}
	entry, err := clientData.UploadDocument(env.ctx, upload)
	s.Require().NoError(err)
	s.Equal("photo", entry.ValueType)
	s.Equal("media-a", entry.Value)
	s.EqualValues(statusCollected, entry.VerificationStatus)

	again, err := clientData.UploadDocument(env.ctx, upload)
	s.Require().NoError(err)
	s.Equal(entry.Value, again.Value, "the same bytes are stored once")

	url, expires, err := clientData.DocumentLink(env.ctx, entry.GetID())
	s.Require().NoError(err)
	s.Equal("https://files.example/signed/media-a", url)
	s.WithinDuration(time.Now().Add(documentLinkTTL), expires, time.Minute)
}

// A document cannot be recorded as a plain value: an entry could otherwise
// point at a file somebody else holds.
func (s *approvalWorkflowSuite) TestKYCDocumentIsNeverSavedAsAPlainValue() {
	env := s.newEnv()
	clientData := env.documentBusiness(&memDocuments{})
	env.ensureClient("client-plain")

	for _, kind := range []string{"photo", "file", "signature"} {
		_, err := clientData.Save(env.ctx, &models.ClientDataEntry{
			ClientID: "client-plain", FieldKey: "id_front_photo", Value: "someone-elses-media", ValueType: kind,
		})
		s.Require().ErrorIs(err, ErrDocumentNeedsUpload, kind)
	}

	text, err := clientData.Save(env.ctx, &models.ClientDataEntry{
		ClientID: "client-plain", FieldKey: "national_id", Value: "CM9", ValueType: "text",
	})
	s.Require().NoError(err)
	_, _, err = clientData.DocumentLink(env.ctx, text.GetID())
	s.Require().ErrorIs(err, ErrNotADocument)
}

// Without the files service documents are refused, and nothing is recorded.
func (s *approvalWorkflowSuite) TestKYCDocumentRefusedWithoutAStore() {
	env := s.newEnv()
	clientData := env.documentBusiness(nil)
	env.ensureClient("client-nostore")

	_, err := clientData.UploadDocument(env.ctx, &identityv1.ClientDocumentUploadRequest{
		ClientId: "client-nostore", FieldKey: "id_front_photo", ValueType: "photo",
		ContentType: "image/jpeg", Content: []byte("x"),
	})
	s.Require().ErrorIs(err, ErrDocumentStoreUnavailable)
	_, err = clientData.Get(env.ctx, "client-nostore", "id_front_photo")
	s.Require().ErrorIs(err, ErrClientDataEntryNotFound)
}
