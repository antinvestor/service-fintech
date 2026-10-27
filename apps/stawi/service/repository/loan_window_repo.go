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

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
)

// LoanWindowRepository provides data access for loan windows.
type LoanWindowRepository interface {
	datastore.BaseRepository[*models.LoanWindow]
	GetByGroupID(ctx context.Context, groupID string) ([]*models.LoanWindow, error)
}

// NewLoanWindowRepository creates a new LoanWindowRepository.
func NewLoanWindowRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) LoanWindowRepository {
	return &loanWindowRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.LoanWindow {
			return &models.LoanWindow{}
		}),
	}
}

type loanWindowRepository struct {
	datastore.BaseRepository[*models.LoanWindow]
}

func (r *loanWindowRepository) GetByGroupID(ctx context.Context, groupID string) ([]*models.LoanWindow, error) {
	var windows []*models.LoanWindow
	err := r.Pool().DB(ctx, true).Where("group_id = ?", groupID).Find(&windows).Error
	return windows, err
}
