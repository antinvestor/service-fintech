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

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/seed/service/models"
)

// ErrLoanRequestNotFound is returned when no loan request matches the
// filter.
var ErrLoanRequestNotFound = errors.New("seed loan request not found")

// LoanRequestRepository owns the seed_loan_requests table. Every
// customer-initiated loan request goes through this repository, and
// downstream links (application id, loan account id, disbursement id)
// are back-filled as the pipeline progresses.
type LoanRequestRepository interface {
	datastore.BaseRepository[*models.LoanRequest]

	// GetByIdempotencyKey is the primary retry-convergence lookup: two
	// calls with the same key return the same row.
	GetByIdempotencyKey(ctx context.Context, key string) (*models.LoanRequest, error)

	// GetByLoanAccountID lets the paid-off hook resolve a seed loan
	// request from the loans-service loan account id that the hook
	// carries.
	GetByLoanAccountID(ctx context.Context, loanAccountID string) (*models.LoanRequest, error)
}

type loanRequestRepository struct {
	datastore.BaseRepository[*models.LoanRequest]
	dbPool pool.Pool
}

// NewLoanRequestRepository constructs a repository bound to the given pool.
func NewLoanRequestRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) LoanRequestRepository {
	return &loanRequestRepository{
		BaseRepository: datastore.NewBaseRepository[*models.LoanRequest](
			ctx, dbPool, workMan, func() *models.LoanRequest { return &models.LoanRequest{} },
		),
		dbPool: dbPool,
	}
}

func (r *loanRequestRepository) GetByIdempotencyKey(
	ctx context.Context,
	key string,
) (*models.LoanRequest, error) {
	if key == "" {
		return nil, ErrLoanRequestNotFound
	}
	entity := &models.LoanRequest{}
	err := r.dbPool.DB(ctx, true).
		Where("idempotency_key = ?", key).
		First(entity).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrLoanRequestNotFound
		}
		return nil, err
	}
	return entity, nil
}

func (r *loanRequestRepository) GetByLoanAccountID(
	ctx context.Context,
	loanAccountID string,
) (*models.LoanRequest, error) {
	if loanAccountID == "" {
		return nil, ErrLoanRequestNotFound
	}
	entity := &models.LoanRequest{}
	err := r.dbPool.DB(ctx, true).
		Where("loan_account_id = ?", loanAccountID).
		First(entity).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrLoanRequestNotFound
		}
		return nil, err
	}
	return entity, nil
}
