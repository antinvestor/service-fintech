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
	"strings"

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
	"github.com/antinvestor/service-fintech/pkg/upsert"
)

type FormTemplateBusiness interface {
	Save(ctx context.Context, obj *identityv1.FormTemplateObject) (*identityv1.FormTemplateObject, error)
	Get(ctx context.Context, id string) (*identityv1.FormTemplateObject, error)
	Search(
		ctx context.Context,
		req *identityv1.FormTemplateSearchRequest,
		consumer func(ctx context.Context, batch []*identityv1.FormTemplateObject) error,
	) error
	Publish(ctx context.Context, id string) (*identityv1.FormTemplateObject, error)
}

type formTemplateBusiness struct {
	eventsMan        fevents.Manager
	formTemplateRepo repository.FormTemplateRepository
}

func NewFormTemplateBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	formTemplateRepo repository.FormTemplateRepository,
) FormTemplateBusiness {
	return &formTemplateBusiness{
		eventsMan:        eventsMan,
		formTemplateRepo: formTemplateRepo,
	}
}

// Save stores a draft template. A published or archived template is never
// rewritten: clients already submitted against it, so a change is a new
// draft (KYC uses the newest published version). Status changes only through
// Publish, and the version only through publishing, so neither is taken from
// the caller for a template that already exists.
//
// The write is synchronous so a Publish straight after a Save finds the row.
func (b *formTemplateBusiness) Save(
	ctx context.Context,
	obj *identityv1.FormTemplateObject,
) (*identityv1.FormTemplateObject, error) {
	if err := validateFormTemplate(obj); err != nil {
		return nil, err
	}

	ft := models.FormTemplateFromAPI(ctx, obj)
	stored, err := b.formTemplateRepo.GetByID(ctx, ft.GetID())
	switch {
	case err == nil:
		if stored.Status != int32(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_DRAFT) {
			return nil, ErrFormTemplateNotDraft
		}
		applyStoredTenancy(ft, stored)
		ft.TemplateVersion = stored.TemplateVersion
	case data.ErrorIsNoRows(err):
		if ft.TemplateVersion < 0 {
			ft.TemplateVersion = 0
		}
	default:
		return nil, fmt.Errorf("load form template: %w", err)
	}
	ft.Status = int32(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_DRAFT)

	if err = upsert.ByID(ctx, b.formTemplateRepo, ft); err != nil {
		util.Log(ctx).WithError(err).WithField("form_template_id", ft.GetID()).
			Error("could not save form template")
		return nil, fmt.Errorf("save form template: %w", err)
	}
	return ft.ToAPI(), nil
}

// validateFormTemplate refuses a template no one could fill in, or one that
// would collect a phone number or email address: contacts are kept on the
// borrower's profile, never in KYC data.
func validateFormTemplate(obj *identityv1.FormTemplateObject) error {
	if obj == nil || strings.TrimSpace(obj.GetName()) == "" ||
		strings.TrimSpace(obj.GetEntityType()) == "" || strings.TrimSpace(obj.GetOrganizationId()) == "" {
		return ErrFormTemplateInvalid
	}
	seen := make(map[string]struct{}, len(obj.GetFields()))
	for _, field := range obj.GetFields() {
		key := strings.TrimSpace(field.GetKey())
		if key == "" || strings.TrimSpace(field.GetLabel()) == "" ||
			field.GetFieldType() == identityv1.FormFieldType_FORM_FIELD_TYPE_UNSPECIFIED {
			return ErrFormTemplateInvalid
		}
		if _, dup := seen[key]; dup {
			return ErrFormTemplateDuplicateField
		}
		seen[key] = struct{}{}
		fieldType := field.GetFieldType()
		if fieldType == identityv1.FormFieldType_FORM_FIELD_TYPE_PHONE ||
			fieldType == identityv1.FormFieldType_FORM_FIELD_TYPE_EMAIL {
			return ErrFormTemplateContactField
		}
		if (fieldType == identityv1.FormFieldType_FORM_FIELD_TYPE_SELECT ||
			fieldType == identityv1.FormFieldType_FORM_FIELD_TYPE_MULTI_SELECT) && len(field.GetOptions()) == 0 {
			return ErrFormTemplateInvalid
		}
	}
	return nil
}

func (b *formTemplateBusiness) Get(ctx context.Context, id string) (*identityv1.FormTemplateObject, error) {
	ft, err := b.formTemplateRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrFormTemplateNotFound
	}
	return ft.ToAPI(), nil
}

func (b *formTemplateBusiness) Search(
	ctx context.Context,
	req *identityv1.FormTemplateSearchRequest,
	consumer func(ctx context.Context, batch []*identityv1.FormTemplateObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "FormTemplateBusiness.Search")

	var searchOpts []data.SearchOption

	cursorOpts, cursorErr := cursorSearchOptions(req.GetCursor())
	if cursorErr != nil {
		return cursorErr
	}
	searchOpts = append(searchOpts, cursorOpts...)

	andQueryVal := map[string]any{}
	if req.GetOrganizationId() != "" {
		andQueryVal["organization_id = ?"] = req.GetOrganizationId()
	}
	if req.GetStatus() != identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_UNSPECIFIED {
		andQueryVal["status = ?"] = int32(req.GetStatus())
	}
	if req.GetEntityType() != "" {
		andQueryVal["entity_type = ?"] = req.GetEntityType()
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	if req.GetQuery() != "" {
		searchOpts = append(searchOpts,
			data.WithSearchFiltersOrByValue(
				map[string]any{searchableTSQuery: req.GetQuery()},
			),
		)
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.formTemplateRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search form templates")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.FormTemplate) error {
		var apiResults []*identityv1.FormTemplateObject
		for _, ft := range res {
			apiResults = append(apiResults, ft.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}

func (b *formTemplateBusiness) Publish(ctx context.Context, id string) (*identityv1.FormTemplateObject, error) {
	logger := util.Log(ctx).WithField("method", "FormTemplateBusiness.Publish")

	ft, err := b.formTemplateRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrFormTemplateNotFound
	}

	if ft.Status != int32(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_DRAFT) {
		return nil, ErrFormTemplateNotDraft
	}

	// The status flip and the version bump are one conditional statement, so
	// a concurrent publish cannot bump the version twice or land on a
	// template that already left draft.
	published, err := b.formTemplateRepo.Publish(
		ctx,
		id,
		actorFromClaims(ctx),
		int32(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_DRAFT),
		int32(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_PUBLISHED),
	)
	switch {
	case err == nil:
	case errors.Is(err, repository.ErrFormTemplateNotInStatus):
		return nil, ErrFormTemplateNotDraft
	default:
		logger.WithError(err).Error("could not publish form template")
		return nil, fmt.Errorf("publish form template: %w", err)
	}

	return published.ToAPI(), nil
}
