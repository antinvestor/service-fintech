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

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

type LoanRequestRepository interface {
	datastore.BaseRepository[*models.LoanRequest]
	GetByIdempotencyKey(ctx context.Context, key string) (*models.LoanRequest, error)
	GetByLoanAccountID(ctx context.Context, loanAccountID string) (*models.LoanRequest, error)
}

type loanRequestRepository struct {
	datastore.BaseRepository[*models.LoanRequest]
}

func NewLoanRequestRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) LoanRequestRepository {
	return &loanRequestRepository{
		BaseRepository: datastore.NewBaseRepository[*models.LoanRequest](
			ctx, dbPool, workMan, func() *models.LoanRequest { return &models.LoanRequest{} },
		),
	}
}

func (repo *loanRequestRepository) GetByIdempotencyKey(
	ctx context.Context,
	key string,
) (*models.LoanRequest, error) {
	lr := models.LoanRequest{}
	err := repo.Pool().DB(ctx, true).
		First(&lr, "idempotency_key = ?", key).Error
	if err != nil {
		return nil, err
	}
	return &lr, nil
}

func (repo *loanRequestRepository) GetByLoanAccountID(
	ctx context.Context,
	loanAccountID string,
) (*models.LoanRequest, error) {
	lr := models.LoanRequest{}
	err := repo.Pool().DB(ctx, true).
		First(&lr, "loan_account_id = ?", loanAccountID).Error
	if err != nil {
		return nil, err
	}
	return &lr, nil
}
