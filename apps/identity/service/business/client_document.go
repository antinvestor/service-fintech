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
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"buf.build/gen/go/antinvestor/files/connectrpc/go/v2/files/v1/filesv1connect"
	filesv1 "buf.build/gen/go/antinvestor/files/protocolbuffers/go/files/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

const (
	// documentLinkTTL is how long a reviewer's link to a document works.
	documentLinkTTL = 5 * time.Minute
	// documentChunkSize is how much of a document each upload message carries.
	documentChunkSize = 256 * 1024
)

var (
	// ErrDocumentNeedsUpload is returned when a photo, document or signature
	// is saved as a plain value: it must be uploaded, so the service holds
	// the only copy and nobody can point an entry at someone else's file.
	ErrDocumentNeedsUpload = apperrors.NewError(apperrors.BadRequest,
		"photos, documents and signatures are recorded with ClientDocumentUpload")
	// ErrDocumentStoreUnavailable is returned when documents cannot be
	// stored or read; the caller retries.
	ErrDocumentStoreUnavailable = apperrors.NewError(apperrors.ServiceUnavailable,
		"KYC documents cannot be stored or read right now; retry")
	// ErrNotADocument is returned when a link is asked for an entry that
	// holds a typed value.
	ErrNotADocument = apperrors.NewError(apperrors.BadRequest, "the entry is not a document")
	// ErrDocumentUnavailable is returned for a document entry whose file the
	// service does not hold.
	ErrDocumentUnavailable = apperrors.NewError(apperrors.NotFound,
		"the document is not available; upload it again")
)

// documentValueTypes are the entry types whose value is a stored file.
func documentValueTypes() map[string]bool {
	return map[string]bool{"photo": true, "file": true, "signature": true}
}

func isDocumentValueType(valueType string) bool { return documentValueTypes()[valueType] }

// Document is a KYC file to store.
type Document struct {
	ContentType string
	Filename    string
	Content     []byte
	// Key makes a retried upload of the same bytes store one file.
	Key string
}

// DocumentStore keeps KYC documents privately, owned by this service alone.
type DocumentStore interface {
	// Put stores the document and returns its id.
	Put(ctx context.Context, doc Document) (string, error)
	// Link returns a signed link to the document that works until expiry.
	Link(ctx context.Context, id string, ttl time.Duration) (string, error)
}

type filesDocumentStore struct {
	files filesv1connect.FilesServiceClient
}

// NewFilesDocumentStore keeps documents in the files service, uploaded as
// this service so it is their only owner.
func NewFilesDocumentStore(files filesv1connect.FilesServiceClient) DocumentStore {
	if files == nil {
		return nil
	}
	return &filesDocumentStore{files: files}
}

func (s *filesDocumentStore) Put(ctx context.Context, doc Document) (string, error) {
	stream, err := s.files.UploadContent(ctx)
	if err != nil {
		return "", err
	}
	if err = stream.Send(&filesv1.UploadContentRequest{
		Data: &filesv1.UploadContentRequest_Metadata{Metadata: &filesv1.UploadMetadata{
			ContentType: doc.ContentType,
			Filename:    doc.Filename,
			TotalSize:   int64(len(doc.Content)),
			Visibility:  filesv1.MediaMetadata_VISIBILITY_PRIVATE,
		}},
		IdempotencyKey: doc.Key,
	}); err != nil {
		return "", err
	}
	for start := 0; start < len(doc.Content); start += documentChunkSize {
		end := min(start+documentChunkSize, len(doc.Content))
		if err = stream.Send(&filesv1.UploadContentRequest{
			Data: &filesv1.UploadContentRequest_Chunk{Chunk: doc.Content[start:end]},
		}); err != nil {
			return "", err
		}
	}
	resp, err := stream.CloseAndReceive()
	if err != nil {
		return "", err
	}
	if resp.GetMediaId() == "" {
		return "", errors.New("files service returned no media id")
	}
	return resp.GetMediaId(), nil
}

func (s *filesDocumentStore) Link(ctx context.Context, id string, ttl time.Duration) (string, error) {
	resp, err := s.files.GetSignedDownloadUrl(ctx, &filesv1.GetSignedDownloadUrlRequest{
		MediaId:        id,
		ExpiresSeconds: int64(ttl / time.Second),
	})
	if err != nil {
		return "", err
	}
	return resp.GetDownloadUrl(), nil
}

// documentKey derives the upload's idempotency key from what is uploaded
// where, so a retried upload stores the same file once.
func documentKey(clientID, fieldKey string, content []byte) string {
	sum := sha256.New()
	sum.Write([]byte(clientID + "\x00" + fieldKey + "\x00"))
	sum.Write(content)
	return "kyc-" + hex.EncodeToString(sum.Sum(nil))[:40]
}

// UploadDocument stores a KYC document and records it as the client's entry
// for the field. The caller must be allowed to capture the client's data
// before anything is stored.
func (b *clientDataBusiness) UploadDocument(
	ctx context.Context,
	req *identityv1.ClientDocumentUploadRequest,
) (*models.ClientDataEntry, error) {
	if _, err := b.guard.authorize(ctx, req.GetClientId()); err != nil {
		return nil, err
	}
	if !isDocumentValueType(req.GetValueType()) {
		return nil, ErrNotADocument
	}
	if b.documents == nil {
		return nil, ErrDocumentStoreUnavailable
	}
	id, err := b.documents.Put(ctx, Document{
		ContentType: req.GetContentType(),
		Filename:    req.GetFilename(),
		Content:     req.GetContent(),
		Key:         documentKey(req.GetClientId(), req.GetFieldKey(), req.GetContent()),
	})
	if err != nil {
		return nil, fmt.Errorf("%w: %s", ErrDocumentStoreUnavailable, err.Error())
	}
	entry := &models.ClientDataEntry{
		ClientID:       req.GetClientId(),
		FieldKey:       req.GetFieldKey(),
		Value:          id,
		ValueType:      req.GetValueType(),
		SourceEntityID: req.GetSourceEntityId(),
		Properties: data.JSONMap{
			"content_type": req.GetContentType(),
			"filename":     req.GetFilename(),
			"size":         len(req.GetContent()),
		},
	}
	return b.save(ctx, entry)
}

// DocumentLink returns a short-lived link to a document entry for a caller
// who may see the client.
func (b *clientDataBusiness) DocumentLink(ctx context.Context, entryID string) (string, time.Time, error) {
	entry, err := b.entryRepo.GetByID(ctx, entryID)
	if err != nil {
		return "", time.Time{}, ErrClientDataEntryNotFound
	}
	if _, err = b.guard.authorize(ctx, entry.ClientID); err != nil {
		return "", time.Time{}, err
	}
	if !isDocumentValueType(entry.ValueType) {
		return "", time.Time{}, ErrNotADocument
	}
	if b.documents == nil {
		return "", time.Time{}, ErrDocumentStoreUnavailable
	}
	expires := time.Now().UTC().Add(documentLinkTTL)
	url, err := b.documents.Link(ctx, entry.Value, documentLinkTTL)
	if err != nil {
		// A file this service does not own was never uploaded through it.
		switch connect.CodeOf(err) { //nolint:exhaustive // only these mean the file is not ours
		case connect.CodeNotFound, connect.CodePermissionDenied, connect.CodeInvalidArgument:
			return "", time.Time{}, ErrDocumentUnavailable
		default:
			return "", time.Time{}, fmt.Errorf("%w: %s", ErrDocumentStoreUnavailable, err.Error())
		}
	}
	return url, expires, nil
}
