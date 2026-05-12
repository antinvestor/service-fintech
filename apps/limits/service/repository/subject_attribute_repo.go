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

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
)

// SubjectAttributeRepository caches subject attribute snapshots for fast
// policy predicate evaluation.
type SubjectAttributeRepository interface {
	Get(ctx context.Context, subjectType models.Subject, subjectID string) (*models.SubjectAttributeSnapshot, error)
	Upsert(ctx context.Context, snap *models.SubjectAttributeSnapshot) error
}

type subjectAttributeRepository struct {
	datastore.BaseRepository[*models.SubjectAttributeSnapshot]
	dbPool pool.Pool
}

// NewSubjectAttributeRepository constructs the repository.
func NewSubjectAttributeRepository(
	ctx context.Context,
	p pool.Pool,
	workMan workerpool.Manager,
) SubjectAttributeRepository {
	r := &subjectAttributeRepository{dbPool: p}
	r.BaseRepository = datastore.NewBaseRepository[*models.SubjectAttributeSnapshot](
		ctx, p, workMan,
		func() *models.SubjectAttributeSnapshot { return &models.SubjectAttributeSnapshot{} },
	)
	return r
}

func (r *subjectAttributeRepository) Get(
	ctx context.Context,
	subjectType models.Subject,
	subjectID string,
) (*models.SubjectAttributeSnapshot, error) {
	db := r.dbPool.DB(ctx, true)
	var out models.SubjectAttributeSnapshot
	err := db.Where("subject_type = ? AND subject_id = ?", string(subjectType), subjectID).First(&out).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &out, nil
}

func (r *subjectAttributeRepository) Upsert(ctx context.Context, snap *models.SubjectAttributeSnapshot) error {
	existing, err := r.Get(ctx, snap.SubjectType, snap.SubjectID)
	if err != nil {
		return err
	}
	if existing == nil {
		if snap.ID == "" {
			snap.ID = util.IDString()
		}
		if snap.FetchedAt.IsZero() {
			snap.FetchedAt = time.Now().UTC()
		}
		return r.BaseRepository.Create(ctx, snap)
	}
	db := r.dbPool.DB(ctx, false)
	return db.Table(models.SubjectAttributeSnapshot{}.TableName()).
		Where("id = ?", existing.ID).
		Updates(map[string]any{
			"attributes":  snap.Attributes,
			"fetched_at":  time.Now().UTC(),
			"modified_at": time.Now().UTC(),
		}).Error
}
