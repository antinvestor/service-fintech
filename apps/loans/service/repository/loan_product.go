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

package repository //nolint:dupl // similar patterns for different entity types

import (
	"context"

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

type LoanProductRepository interface {
	datastore.BaseRepository[*models.LoanProduct]
	GetByCode(ctx context.Context, code string) (*models.LoanProduct, error)
}

type loanProductRepository struct {
	datastore.BaseRepository[*models.LoanProduct]
}

func NewLoanProductRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) LoanProductRepository {
	return &loanProductRepository{
		BaseRepository: datastore.NewBaseRepository[*models.LoanProduct](
			ctx, dbPool, workMan, func() *models.LoanProduct { return &models.LoanProduct{} },
		),
	}
}

func (repo *loanProductRepository) GetByCode(
	ctx context.Context,
	code string,
) (*models.LoanProduct, error) {
	loanProduct := models.LoanProduct{}
	err := repo.Pool().DB(ctx, true).
		First(&loanProduct, "code = ?", code).Error
	if err != nil {
		return nil, err
	}
	return &loanProduct, nil
}
