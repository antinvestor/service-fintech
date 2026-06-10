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

package events //nolint:dupl // similar event handlers for different entity types

import (
	"context"
	"errors"

	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

const FormTemplateSaveEvent = "form_template.save"

type FormTemplateSave struct {
	formTemplateRepo repository.FormTemplateRepository
}

func NewFormTemplateSave(_ context.Context, formTemplateRepo repository.FormTemplateRepository) *FormTemplateSave {
	return &FormTemplateSave{formTemplateRepo: formTemplateRepo}
}

func (e *FormTemplateSave) Name() string     { return FormTemplateSaveEvent }
func (e *FormTemplateSave) PayloadType() any { return &models.FormTemplate{} }

func (e *FormTemplateSave) Validate(_ context.Context, payload any) error {
	ft, ok := payload.(*models.FormTemplate)
	if !ok {
		return errors.New("payload is not of type models.FormTemplate")
	}
	if ft.GetID() == "" {
		return errors.New("form template ID should already have been set")
	}
	return nil
}

func (e *FormTemplateSave) Execute(ctx context.Context, payload any) error {
	ft, ok := payload.(*models.FormTemplate)
	if !ok {
		return errors.New("payload is not of type models.FormTemplate")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "form_template_id": ft.GetID()})
	defer logger.Release()

	existing, getErr := e.formTemplateRepo.GetByID(ctx, ft.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.formTemplateRepo.Update(ctx, ft); err != nil {
			logger.WithError(err).Error("could not update form template in db")
			return err
		}
		return nil
	}

	if err := e.formTemplateRepo.Create(ctx, ft); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create form template in db")
		return err
	}

	return nil
}
