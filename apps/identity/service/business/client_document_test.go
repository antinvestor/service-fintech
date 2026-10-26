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

	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"

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

// jpegBytes starts like a JPEG, which is what the content check reads.
func jpegBytes() []byte {
	return append([]byte{0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10, 'J', 'F', 'I', 'F', 0x00}, make([]byte, 64)...)
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
		ContentType: "image/jpeg", Filename: "front.jpg", Content: jpegBytes(),
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

	for _, kind := range []string{"photo", "file", "signature", " Photo "} {
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
		ContentType: "image/jpeg", Content: jpegBytes(),
	})
	s.Require().ErrorIs(err, ErrDocumentStoreUnavailable)
	_, err = clientData.Get(env.ctx, "client-nostore", "id_front_photo")
	s.Require().ErrorIs(err, ErrClientDataEntryNotFound)
}

// The bytes must be what the request says, and the kind one the field
// takes: a page sent as an image, or a PDF as a photo, is refused.
func (s *approvalWorkflowSuite) TestKYCDocumentContentMustMatchItsKind() {
	env := s.newEnv()
	store := &memDocuments{}
	clientData := env.documentBusiness(store)
	env.ensureClient("client-content")
	upload := func(valueType, contentType string, content []byte) error {
		_, err := clientData.UploadDocument(env.ctx, &identityv1.ClientDocumentUploadRequest{
			ClientId: "client-content", FieldKey: "proof_of_address", ValueType: valueType,
			ContentType: contentType, Content: content,
		})
		return err
	}
	pdf := append([]byte("%PDF-1.7\n"), make([]byte, 32)...)

	s.Require().ErrorIs(upload("photo", "image/jpeg", []byte("<html><script>x</script></html>")),
		ErrDocumentContentRejected, "a page is not an image")
	s.Require().ErrorIs(upload("photo", "image/png", jpegBytes()), ErrDocumentContentRejected,
		"the bytes must be the declared kind")
	s.Require().ErrorIs(upload("photo", "application/pdf", pdf), ErrDocumentContentRejected,
		"a photo is an image")
	s.Require().ErrorIs(upload("file", "image/jpeg", make([]byte, maxDocumentBytes+1)), ErrDocumentContentRejected)
	s.Zero(store.puts, "nothing refused is stored")

	s.Require().NoError(upload("file", "application/pdf", pdf), "a document may be a PDF")
}

// A field the client's form declares as a photo cannot be saved as text,
// and a typed field cannot take an upload.
func (s *approvalWorkflowSuite) TestKYCDocumentFollowsTheFormsFieldType() {
	env := s.newEnv()
	org := env.createOrganization("Docs SACCO", "docs-sacco")
	_, _ = env.fieldAgent(org, "agent-docs", "docs-team")
	asAgent := env.asRole("agent-docs", "member")
	claims := security.ClaimsFromContext(env.ctx)
	tmpl := &models.FormTemplate{OrganizationID: org.GetID(), Name: "Client KYC", TemplateVersion: 1,
		EntityType: clientFormEntityType, Fields: data.JSONMap{"items": []any{
			map[string]any{"key": "id_front_photo", "label": "ID front", "required": true,
				"field_type": float64(identityv1.FormFieldType_FORM_FIELD_TYPE_PHOTO)},
			map[string]any{"key": "national_id", "label": "National ID", "required": true,
				"field_type": float64(identityv1.FormFieldType_FORM_FIELD_TYPE_TEXT)},
		}},
		Status: int32(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_PUBLISHED)}
	tmpl.GenID(env.ctx)
	tmpl.TenantID, tmpl.PartitionID = claims.GetTenantID(), claims.GetPartitionID()
	s.Require().NoError(env.formTemplateRepo.Create(env.ctx, tmpl))

	client, err := env.clientBusiness.Save(asAgent, &fieldv1.ClientObject{Name: "Docs Borrower",
		Properties: propertiesStruct(map[string]any{clientPhoneNumberKey: "+256701000777"})})
	s.Require().NoError(err)
	clientData := env.documentBusiness(&memDocuments{})

	_, err = clientData.Save(asAgent, &models.ClientDataEntry{ClientID: client.GetId(),
		FieldKey: "id_front_photo", Value: "someone-elses-media", ValueType: "text"})
	s.Require().ErrorIs(err, ErrDocumentNeedsUpload, "the form says this field is a photo")

	_, err = clientData.UploadDocument(asAgent, &identityv1.ClientDocumentUploadRequest{
		ClientId: client.GetId(), FieldKey: "national_id", ValueType: "photo",
		ContentType: "image/jpeg", Content: jpegBytes(),
	})
	s.Require().ErrorIs(err, ErrNotADocument, "the form says this field is typed")

	_, err = clientData.UploadDocument(asAgent, &identityv1.ClientDocumentUploadRequest{
		ClientId: client.GetId(), FieldKey: "id_front_photo", ValueType: "photo",
		ContentType: "image/jpeg", Content: jpegBytes(),
	})
	s.Require().NoError(err)
}
