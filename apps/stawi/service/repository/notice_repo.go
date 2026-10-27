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

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
)

// NoticeRepository records the notifications stawi sent.
type NoticeRepository interface {
	// Claim records the notice and reports true, or reports false when a
	// notice with the same key was already recorded.
	Claim(ctx context.Context, notice *models.Notice) (bool, error)
	// Release forgets a claimed notice whose message could not be sent, so
	// a later run sends it.
	Release(ctx context.Context, key string) error
}

// NewNoticeRepository creates a new NoticeRepository.
func NewNoticeRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) NoticeRepository {
	return &noticeRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.Notice {
			return &models.Notice{}
		}),
	}
}

type noticeRepository struct {
	datastore.BaseRepository[*models.Notice]
}

func (r *noticeRepository) Claim(ctx context.Context, notice *models.Notice) (bool, error) {
	if err := r.Create(ctx, notice); err != nil {
		if data.ErrorIsDuplicateKey(err) {
			return false, nil
		}
		return false, err
	}
	return true, nil
}

func (r *noticeRepository) Release(ctx context.Context, key string) error {
	// Unscoped: a soft-deleted row would still hold the unique key.
	return r.Pool().DB(ctx, false).Unscoped().Where("key = ?", key).Delete(&models.Notice{}).Error
}
