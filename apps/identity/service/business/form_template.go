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

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/data"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
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

func (b *formTemplateBusiness) Save(
	ctx context.Context,
	obj *identityv1.FormTemplateObject,
) (*identityv1.FormTemplateObject, error) {
	logger := util.Log(ctx).WithField("method", "FormTemplateBusiness.Save")

	ft := models.FormTemplateFromAPI(ctx, obj)

	if ft.Status == 0 {
		ft.Status = int32(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_DRAFT)
	}

	err := b.eventsMan.Emit(ctx, events.FormTemplateSaveEvent, ft)
	if err != nil {
		logger.WithError(err).Error("could not emit form template save event")
		return nil, err
	}

	return ft.ToAPI(), nil
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

	cursor := req.GetCursor()
	if cursor != nil {
		offset, offsetErr := strconv.Atoi(cursor.GetPage())
		if offsetErr != nil {
			offset = 0
		}
		searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(int(cursor.GetLimit())))
	}

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

	ft.Status = int32(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_PUBLISHED)
	ft.Version++

	if errEmit := b.eventsMan.Emit(ctx, events.FormTemplateSaveEvent, ft); errEmit != nil {
		logger.WithError(errEmit).Error("could not emit form template publish event")
		return nil, errEmit
	}

	return ft.ToAPI(), nil
}
