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
	"strconv"
	"strings"

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

// fileFieldTypes is the set of FormFieldType values whose submission values
// must be content URIs pointing to already-uploaded files — never inline
// base64 or data-URI payloads. Clients upload files directly to the files
// service and submit only the resulting content URI.
func fileFieldTypes() map[identityv1.FormFieldType]bool {
	//nolint:exhaustive // only file-like types need tracking; other types are not file fields
	return map[identityv1.FormFieldType]bool{
		identityv1.FormFieldType_FORM_FIELD_TYPE_PHOTO:     true,
		identityv1.FormFieldType_FORM_FIELD_TYPE_FILE:      true,
		identityv1.FormFieldType_FORM_FIELD_TYPE_SIGNATURE: true,
	}
}

type FormSubmissionBusiness interface {
	Save(ctx context.Context, obj *identityv1.FormSubmissionObject) (*identityv1.FormSubmissionObject, error)
	Get(ctx context.Context, id string) (*identityv1.FormSubmissionObject, error)
	Search(
		ctx context.Context,
		req *identityv1.FormSubmissionSearchRequest,
		consumer func(ctx context.Context, batch []*identityv1.FormSubmissionObject) error,
	) error
}

type formSubmissionBusiness struct {
	eventsMan          fevents.Manager
	formSubmissionRepo repository.FormSubmissionRepository
	formTemplateRepo   repository.FormTemplateRepository
}

func NewFormSubmissionBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	formSubmissionRepo repository.FormSubmissionRepository,
	formTemplateRepo repository.FormTemplateRepository,
) FormSubmissionBusiness {
	return &formSubmissionBusiness{
		eventsMan:          eventsMan,
		formSubmissionRepo: formSubmissionRepo,
		formTemplateRepo:   formTemplateRepo,
	}
}

func (b *formSubmissionBusiness) Save(
	ctx context.Context,
	obj *identityv1.FormSubmissionObject,
) (*identityv1.FormSubmissionObject, error) {
	logger := util.Log(ctx).WithField("method", "FormSubmissionBusiness.Save")

	fs := models.FormSubmissionFromAPI(ctx, obj)

	// Validate submission against template if template ID is provided.
	// This also validates file fields and populates FileRefs.
	if fs.TemplateID != "" {
		if err := b.validateAgainstTemplate(ctx, logger, fs); err != nil {
			return nil, err
		}
	}

	err := b.eventsMan.Emit(ctx, events.FormSubmissionSaveEvent, fs)
	if err != nil {
		logger.WithError(err).Error("could not emit form submission save event")
		return nil, err
	}

	return fs.ToAPI(), nil
}

// validateAgainstTemplate checks that the form submission includes all required
// fields defined in the form template, that the template is published, and that
// file-type fields contain content URIs (not inline data).
func (b *formSubmissionBusiness) validateAgainstTemplate( //nolint:gocognit // sequential validation logic
	ctx context.Context,
	logger *util.LogEntry,
	fs *models.FormSubmission,
) error {
	template, err := b.formTemplateRepo.GetByID(ctx, fs.TemplateID)
	if err != nil {
		return ErrFormTemplateNotFound
	}

	// Template must be published before accepting submissions.
	if template.Status != int32(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_PUBLISHED) {
		return ErrFormTemplateNotPublished
	}

	// Store template version at submission time.
	fs.TemplateVersion = template.Version

	// Check required fields are present in submission data.
	fields := models.FieldsToAPI(template.Fields)
	if len(fields) == 0 || fs.Data == nil {
		return nil
	}

	var missingFields []string
	var inlineFileFields []string
	fileRefs := make(map[string]string)

	for _, field := range fields {
		key := field.GetKey()
		if key == "" {
			continue
		}

		val, exists := fs.Data[key]
		if !exists {
			if field.GetRequired() {
				missingFields = append(missingFields, key)
			}
			continue
		}

		// For file-type fields, validate the value is a content URI and reject inline data.
		if fileFieldTypes()[field.GetFieldType()] {
			uri, isInline := validateFileFieldValue(val)
			if isInline {
				inlineFileFields = append(inlineFileFields, key)
				continue
			}
			if uri != "" {
				fileRefs[key] = uri
			}
		}
	}

	if len(missingFields) > 0 {
		logger.WithField("missing_fields", missingFields).
			WithField("template_id", fs.TemplateID).
			Warn("form submission missing required fields")
		return ErrFormSubmissionMissingFields
	}

	if len(inlineFileFields) > 0 {
		logger.WithField("inline_file_fields", inlineFileFields).
			WithField("template_id", fs.TemplateID).
			Warn("form submission contains inline file data instead of content URIs")
		return ErrFormSubmissionInlineFileData
	}

	// Populate FileRefs from validated file field values so callers can look up
	// content URIs by field key without walking the full data tree.
	if len(fileRefs) > 0 {
		if fs.FileRefs == nil {
			fs.FileRefs = make(data.JSONMap, len(fileRefs))
		}
		for key, uri := range fileRefs {
			fs.FileRefs[key] = uri
		}
	}

	return nil
}

// validateFileFieldValue checks whether a file field value is a content URI or
// inline data. Returns the URI string (if valid) and whether the value contains
// inline data that should be rejected.
func validateFileFieldValue(val any) (string, bool) {
	switch v := val.(type) {
	case string:
		if strings.HasPrefix(v, "data:") || looksLikeBase64(v) {
			return "", true
		}
		// Accept as content URI (e.g. "https://cdn.example.com/v1/media/download/...")
		return v, false

	case map[string]any:
		// Reject explicit file objects with inline data.
		if typeField, okType := v["_type"].(string); okType && typeField == "file" {
			return "", true
		}
		// Accept file_ref objects with a content URI.
		if typeField, okRef := v["_type"].(string); okRef && typeField == "file_ref" {
			if contentURI, okURI := v["content_uri"].(string); okURI {
				return contentURI, false
			}
		}
		return "", false

	default:
		return "", false
	}
}

// looksLikeBase64 does a quick heuristic check to detect raw base64 payloads
// that are clearly not URIs. It looks for long strings without URI-like characters.
func looksLikeBase64(s string) bool {
	// Short strings are likely not base64 file payloads.
	const minBase64FileLen = 256
	if len(s) < minBase64FileLen {
		return false
	}
	// If it contains "://" it's likely a URI, not base64.
	if strings.Contains(s, "://") {
		return false
	}
	// If it contains "/" or "+" which are common in base64 but the string has
	// no scheme, it's probably base64 data.
	return true
}

func (b *formSubmissionBusiness) Get(ctx context.Context, id string) (*identityv1.FormSubmissionObject, error) {
	fs, err := b.formSubmissionRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrFormSubmissionNotFound
	}
	return fs.ToAPI(), nil
}

func (b *formSubmissionBusiness) Search(
	ctx context.Context,
	req *identityv1.FormSubmissionSearchRequest,
	consumer func(ctx context.Context, batch []*identityv1.FormSubmissionObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "FormSubmissionBusiness.Search")

	var searchOpts []data.SearchOption

	cursor := req.GetCursor()
	if cursor != nil {
		offset, offsetErr := strconv.Atoi(cursor.GetPage())
		if offsetErr != nil {
			offset = 0
		}
		searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(int(cursor.GetLimit())))
	}

	andQueryVal := map[string]any{}
	if req.GetEntityId() != "" {
		andQueryVal["entity_id = ?"] = req.GetEntityId()
	}
	if req.GetEntityType() != "" {
		andQueryVal["entity_type = ?"] = req.GetEntityType()
	}
	if req.GetTemplateId() != "" {
		andQueryVal["template_id = ?"] = req.GetTemplateId()
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.formSubmissionRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search form submissions")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.FormSubmission) error {
		var apiResults []*identityv1.FormSubmissionObject
		for _, fs := range res {
			apiResults = append(apiResults, fs.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}
