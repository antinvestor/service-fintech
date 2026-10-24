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
	"time"

	"github.com/pitabwire/frame/v3/datastore/pool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

// ClientConsentChallengeRepository stores consent challenges. Attempts and
// use are counted with conditional writes so concurrent submissions cannot
// exceed the budget or use a challenge twice.
type ClientConsentChallengeRepository interface {
	Create(ctx context.Context, c *models.ClientConsentChallenge) error
	GetByID(ctx context.Context, id string) (*models.ClientConsentChallenge, error)
	// TakeAttempt spends one attempt on a live, unused challenge and reports
	// whether one was left.
	TakeAttempt(ctx context.Context, id string, maxAttempts int, now time.Time) (bool, error)
	// MarkUsed consumes the challenge and reports whether this call did.
	MarkUsed(ctx context.Context, id string, now time.Time) (bool, error)
}

type clientConsentChallengeRepository struct {
	pool pool.Pool
}

// NewClientConsentChallengeRepository builds the repository.
func NewClientConsentChallengeRepository(dbPool pool.Pool) ClientConsentChallengeRepository {
	return &clientConsentChallengeRepository{pool: dbPool}
}

func (r *clientConsentChallengeRepository) table(ctx context.Context) *gorm.DB {
	return r.pool.DB(ctx, false).Table(models.ClientConsentChallenge{}.TableName())
}

func (r *clientConsentChallengeRepository) Create(ctx context.Context, c *models.ClientConsentChallenge) error {
	return r.pool.DB(ctx, false).Create(c).Error
}

func (r *clientConsentChallengeRepository) GetByID(
	ctx context.Context,
	id string,
) (*models.ClientConsentChallenge, error) {
	c := &models.ClientConsentChallenge{}
	if err := r.pool.DB(ctx, true).First(c, "id = ?", id).Error; err != nil {
		return nil, err
	}
	return c, nil
}

func (r *clientConsentChallengeRepository) TakeAttempt(
	ctx context.Context,
	id string,
	maxAttempts int,
	now time.Time,
) (bool, error) {
	res := r.table(ctx).
		Where("deleted_at IS NULL AND id = ? AND used_at IS NULL AND expires_at > ? AND attempts < ?",
			id, now, maxAttempts).
		Updates(map[string]any{"attempts": gorm.Expr("attempts + 1"), "modified_at": now})
	return res.RowsAffected == 1, res.Error
}

func (r *clientConsentChallengeRepository) MarkUsed(ctx context.Context, id string, now time.Time) (bool, error) {
	res := r.table(ctx).
		Where("deleted_at IS NULL AND id = ? AND used_at IS NULL", id).
		Updates(map[string]any{"used_at": now, "modified_at": now})
	return res.RowsAffected == 1, res.Error
}
