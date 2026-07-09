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

package repository

import (
	"context"

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

type FormSubmissionRepository interface {
	datastore.BaseRepository[*models.FormSubmission]
	GetByEntityAndTemplate(ctx context.Context, entityID, templateID string) (*models.FormSubmission, error)
}

type formSubmissionRepository struct {
	datastore.BaseRepository[*models.FormSubmission]
}

func NewFormSubmissionRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) FormSubmissionRepository {
	return &formSubmissionRepository{
		BaseRepository: datastore.NewBaseRepository[*models.FormSubmission](
			ctx, dbPool, workMan, func() *models.FormSubmission { return &models.FormSubmission{} },
		),
	}
}

func (repo *formSubmissionRepository) GetByEntityAndTemplate(
	ctx context.Context,
	entityID, templateID string,
) (*models.FormSubmission, error) {
	fs := models.FormSubmission{}
	err := repo.Pool().DB(ctx, true).
		First(&fs, "entity_id = ? AND template_id = ?", entityID, templateID).Error
	if err != nil {
		return nil, err
	}
	return &fs, nil
}
