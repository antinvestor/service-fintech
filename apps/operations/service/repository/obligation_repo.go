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

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
)

// ObligationRepository provides data access for obligations.
type ObligationRepository interface {
	datastore.BaseRepository[*models.Obligation]
	GetByMembershipID(ctx context.Context, membershipID string) ([]*models.Obligation, error)
	GetByPeriodID(ctx context.Context, periodID string) ([]*models.Obligation, error)
	GetByCauseID(ctx context.Context, causeID string) ([]*models.Obligation, error)
}

// NewObligationRepository creates a new ObligationRepository.
func NewObligationRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) ObligationRepository {
	return &obligationRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.Obligation {
			return &models.Obligation{}
		}),
	}
}

// stateActive is the numeric value for the active state used in database queries.
const stateActive = 3

type obligationRepository struct {
	datastore.BaseRepository[*models.Obligation]
}

func (r *obligationRepository) GetByMembershipID(
	ctx context.Context,
	membershipID string,
) ([]*models.Obligation, error) {
	var obligations []*models.Obligation
	err := r.Pool().DB(ctx, true).
		Where("membership_id = ? AND state = ?", membershipID, stateActive).
		Order("deadline ASC").
		Find(&obligations).Error
	return obligations, err
}

func (r *obligationRepository) GetByPeriodID(ctx context.Context, periodID string) ([]*models.Obligation, error) {
	var obligations []*models.Obligation
	err := r.Pool().DB(ctx, true).Where("period_id = ?", periodID).Find(&obligations).Error
	return obligations, err
}

func (r *obligationRepository) GetByCauseID(ctx context.Context, causeID string) ([]*models.Obligation, error) {
	var obligations []*models.Obligation
	err := r.Pool().DB(ctx, true).Where("cause_id = ?", causeID).Find(&obligations).Error
	return obligations, err
}
