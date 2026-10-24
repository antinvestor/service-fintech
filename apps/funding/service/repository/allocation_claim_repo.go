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

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
)

// LoanFundingClaimRepository owns the per-request allocation lock.
type LoanFundingClaimRepository interface {
	datastore.BaseRepository[*models.LoanFundingClaim]

	// Claim takes the allocation lock for a loan request. created=false means
	// another call already holds it and its allocation is (or will be) the
	// authoritative one.
	Claim(ctx context.Context, claim *models.LoanFundingClaim) (created bool, err error)

	// Release drops a lock whose allocation failed, so the request can be
	// funded on a later attempt.
	Release(ctx context.Context, loanRequestID string) error
}

type loanFundingClaimRepository struct {
	datastore.BaseRepository[*models.LoanFundingClaim]
}

// NewLoanFundingClaimRepository creates a LoanFundingClaimRepository.
func NewLoanFundingClaimRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) LoanFundingClaimRepository {
	return &loanFundingClaimRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.LoanFundingClaim {
			return &models.LoanFundingClaim{}
		}),
	}
}

func (r *loanFundingClaimRepository) Claim(ctx context.Context, claim *models.LoanFundingClaim) (bool, error) {
	err := r.Pool().DB(ctx, false).Create(claim).Error
	switch {
	case err == nil:
		return true, nil
	case data.ErrorIsDuplicateKey(err):
		return false, nil
	default:
		return false, err
	}
}

func (r *loanFundingClaimRepository) Release(ctx context.Context, loanRequestID string) error {
	// Unscoped: a soft-deleted row still occupies the unique loan_request_id,
	// which would leave the request permanently unfundable.
	return r.Pool().DB(ctx, false).
		Unscoped().
		Where("loan_request_id = ?", loanRequestID).
		Delete(&models.LoanFundingClaim{}).Error
}
