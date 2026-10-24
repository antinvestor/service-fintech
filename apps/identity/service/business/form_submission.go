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
	"fmt"
	"net/url"
	"strings"

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
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
	if err := carryStoredTenancy(ctx, b.formSubmissionRepo, fs); err != nil {
		return nil, err
	}

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
func (b *formSubmissionBusiness) validateAgainstTemplate(
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
	fs.TemplateVersion = template.TemplateVersion

	// Check required fields are present in submission data.
	fields := models.FieldsToAPI(template.Fields)
	if len(fields) == 0 || fs.Data == nil {
		return nil
	}

	outcome := classifyTemplateFields(fields, fs.Data)
	missingFields := outcome.missing
	inlineFileFields := outcome.inline
	invalidFileFields := outcome.invalid
	fileRefs := outcome.fileRefs

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

	if len(invalidFileFields) > 0 {
		logger.WithField("invalid_file_fields", invalidFileFields).
			WithField("template_id", fs.TemplateID).
			Warn("form submission contains file values that are not https content URIs")
		return ErrFormSubmissionInvalidFileURI
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

// templateFieldOutcome is what one pass over a template's fields found in a
// submission: which required keys are absent, which file fields carried
// inline data, which carried a value that is not an allowed URI, and the
// accepted URIs keyed by field.
type templateFieldOutcome struct {
	missing  []string
	inline   []string
	invalid  []string
	fileRefs map[string]string
}

func classifyTemplateFields(
	fields []*identityv1.FormFieldDefinition,
	submitted data.JSONMap,
) templateFieldOutcome {
	outcome := templateFieldOutcome{fileRefs: make(map[string]string)}
	for _, field := range fields {
		key := field.GetKey()
		if key == "" {
			continue
		}

		val, exists := submitted[key]
		if !exists {
			if field.GetRequired() {
				outcome.missing = append(outcome.missing, key)
			}
			continue
		}

		if !fileFieldTypes()[field.GetFieldType()] {
			continue
		}
		uri, kind := classifyFileFieldValue(val)
		switch kind {
		case fileValueURI:
			outcome.fileRefs[key] = uri
		case fileValueInline:
			outcome.inline = append(outcome.inline, key)
		case fileValueInvalid:
			outcome.invalid = append(outcome.invalid, key)
		case fileValueAbsent:
		}
	}
	return outcome
}

// fileValueKind classifies what a file-type field carried.
type fileValueKind int

const (
	// fileValueAbsent is a value that carries no file at all, such as a
	// structured object without a file marker; nothing is recorded for it.
	fileValueAbsent fileValueKind = iota
	// fileValueURI is an https content URI that passed the allowlist.
	fileValueURI
	// fileValueInline is a data URI, a base64 payload, or an inline file
	// object: content that must be uploaded to the files service instead.
	fileValueInline
	// fileValueInvalid is anything else: a URI on a forbidden scheme, one with
	// credentials or no host, or free text where a reference was expected.
	fileValueInvalid
)

// classifyFileFieldValue decides whether a file field value is an acceptable
// content URI, inline data, or neither. Stored URIs are later rendered by
// clients, so only https references with a host and no userinfo are kept.
func classifyFileFieldValue(val any) (string, fileValueKind) {
	switch v := val.(type) {
	case string:
		return classifyFileFieldString(v)

	case map[string]any:
		typeField, _ := v["_type"].(string)
		switch typeField {
		case "file":
			// Explicit file objects carry inline bytes.
			return "", fileValueInline
		case "file_ref":
			contentURI, okURI := v["content_uri"].(string)
			if !okURI {
				return "", fileValueInvalid
			}
			return classifyFileFieldString(contentURI)
		default:
			return "", fileValueAbsent
		}

	default:
		return "", fileValueAbsent
	}
}

func classifyFileFieldString(raw string) (string, fileValueKind) {
	value := strings.TrimSpace(raw)
	if value == "" {
		return "", fileValueInvalid
	}
	if strings.HasPrefix(strings.ToLower(value), "data:") {
		return "", fileValueInline
	}
	if err := validateContentURI(value); err == nil {
		return value, fileValueURI
	}
	if looksLikeBase64(value) {
		return "", fileValueInline
	}
	return "", fileValueInvalid
}

// errContentURINotAllowed is the internal reason a content URI was refused;
// callers surface ErrFormSubmissionInvalidFileURI, never this text.
var errContentURINotAllowed = errors.New("content uri is not an https reference with a host")

// validateContentURI enforces the file reference allowlist: absolute https
// URIs with a host and without userinfo. javascript:, data:, file:, http: and
// scheme-less values are all refused.
func validateContentURI(raw string) error {
	parsed, err := url.Parse(raw)
	if err != nil {
		return fmt.Errorf("parse content uri: %w", err)
	}
	if !strings.EqualFold(parsed.Scheme, "https") {
		return errContentURINotAllowed
	}
	if parsed.Hostname() == "" {
		return errContentURINotAllowed
	}
	if parsed.User != nil {
		return errContentURINotAllowed
	}
	return nil
}

// looksLikeBase64 reports whether s is a long run of base64 alphabet
// characters, the shape of an inline file payload. It is only consulted for
// values that already failed the URI allowlist, so free text of any length
// (which carries spaces or punctuation outside the alphabet) is not mistaken
// for a payload.
func looksLikeBase64(s string) bool {
	const minBase64FileLen = 256
	if len(s) < minBase64FileLen {
		return false
	}
	for _, r := range s {
		switch {
		case r >= 'A' && r <= 'Z', r >= 'a' && r <= 'z', r >= '0' && r <= '9':
		case r == '+', r == '/', r == '=', r == '-', r == '_':
		default:
			return false
		}
	}
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

	cursorOpts, cursorErr := cursorSearchOptions(req.GetCursor())
	if cursorErr != nil {
		return cursorErr
	}
	searchOpts = append(searchOpts, cursorOpts...)

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
