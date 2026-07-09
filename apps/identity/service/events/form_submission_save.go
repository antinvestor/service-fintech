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

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

const FormSubmissionSaveEvent = "form_submission.save"

type FormSubmissionSave struct {
	formSubmissionRepo repository.FormSubmissionRepository
}

func NewFormSubmissionSave(
	_ context.Context,
	formSubmissionRepo repository.FormSubmissionRepository,
) *FormSubmissionSave {
	return &FormSubmissionSave{formSubmissionRepo: formSubmissionRepo}
}

func (e *FormSubmissionSave) Name() string     { return FormSubmissionSaveEvent }
func (e *FormSubmissionSave) PayloadType() any { return &models.FormSubmission{} }

func (e *FormSubmissionSave) Validate(_ context.Context, payload any) error {
	fs, ok := payload.(*models.FormSubmission)
	if !ok {
		return errors.New("payload is not of type models.FormSubmission")
	}
	if fs.GetID() == "" {
		return errors.New("form submission ID should already have been set")
	}
	return nil
}

func (e *FormSubmissionSave) Execute(ctx context.Context, payload any) error {
	fs, ok := payload.(*models.FormSubmission)
	if !ok {
		return errors.New("payload is not of type models.FormSubmission")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "form_submission_id": fs.GetID()})
	defer logger.Release()

	existing, getErr := e.formSubmissionRepo.GetByID(ctx, fs.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.formSubmissionRepo.Update(ctx, fs); err != nil {
			logger.WithError(err).Error("could not update form submission in db")
			return err
		}
		return nil
	}

	if err := e.formSubmissionRepo.Create(ctx, fs); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create form submission in db")
		return err
	}

	return nil
}
