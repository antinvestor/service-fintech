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
	"errors"
	"time"

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

// ErrFormTemplateNotInStatus reports that the conditional status update
// matched no row: the template left the expected status first, or is gone.
var ErrFormTemplateNotInStatus = errors.New("form template is not in the expected status")

type FormTemplateRepository interface {
	datastore.BaseRepository[*models.FormTemplate]
	// Publish moves a template from fromStatus to toStatus and bumps its
	// template version in one conditional statement, so of two concurrent
	// publishes exactly one lands and the version is bumped once.
	Publish(
		ctx context.Context,
		id, actorID string,
		fromStatus, toStatus int32,
	) (*models.FormTemplate, error)
}

type formTemplateRepository struct {
	datastore.BaseRepository[*models.FormTemplate]
}

func NewFormTemplateRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) FormTemplateRepository {
	return &formTemplateRepository{
		BaseRepository: datastore.NewBaseRepository[*models.FormTemplate](
			ctx, dbPool, workMan, func() *models.FormTemplate { return &models.FormTemplate{} },
		),
	}
}

func (repo *formTemplateRepository) Publish(
	ctx context.Context,
	id, actorID string,
	fromStatus, toStatus int32,
) (*models.FormTemplate, error) {
	published := &models.FormTemplate{}
	err := repo.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		result := tx.WithContext(ctx).
			Table((&models.FormTemplate{}).TableName()).
			Where("id = ? AND status = ? AND deleted_at IS NULL", id, fromStatus).
			Updates(map[string]any{
				"status":           toStatus,
				"template_version": gorm.Expr("template_version + 1"),
				colModifiedAt:      time.Now().UTC(),
				colModifiedBy:      actorID,
				colVersion:         gorm.Expr("version + 1"),
			})
		if result.Error != nil {
			return result.Error
		}
		if result.RowsAffected == 0 {
			return ErrFormTemplateNotInStatus
		}
		return tx.WithContext(ctx).First(published, "id = ?", id).Error
	})
	if err != nil {
		return nil, err
	}
	return published, nil
}
