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

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

type RepaymentRepository interface {
	datastore.BaseRepository[*models.Repayment]
	GetByIdempotencyKey(ctx context.Context, key string) (*models.Repayment, error)
	// ClaimIdempotencyKey inserts the repayment, or hands back the row that
	// already owns the key, so a retry can never post a second set of
	// transfer orders for the same payment.
	ClaimIdempotencyKey(
		ctx context.Context,
		rep *models.Repayment,
	) (stored *models.Repayment, created bool, err error)
	UpdateColumns(ctx context.Context, id string, values map[string]any) (int64, error)
	// ListByLoanAccountID returns up to limit repayments of a loan in
	// posting order.
	ListByLoanAccountID(ctx context.Context, loanAccountID string, limit int) ([]*models.Repayment, error)
	// ListUnapplied returns up to limit repayments of a loan that were
	// recorded but never applied, oldest first.
	ListUnapplied(ctx context.Context, loanAccountID string, limit int) ([]*models.Repayment, error)
	// ClaimFundingUnsettled leases up to limit repayments that are still to
	// be shared out to funders and whose lease is free or older than
	// leaseSeconds. Concurrent callers never receive the same repayment.
	ClaimFundingUnsettled(ctx context.Context, limit, leaseSeconds int) ([]*models.Repayment, error)
	// MarkFundingSettled records that the repayment's funder shares are done.
	MarkFundingSettled(ctx context.Context, id string, note string) error
}

type repaymentRepository struct {
	datastore.BaseRepository[*models.Repayment]
}

func NewRepaymentRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) RepaymentRepository {
	return &repaymentRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Repayment](
			ctx, dbPool, workMan, func() *models.Repayment { return &models.Repayment{} },
		),
	}
}

func (repo *repaymentRepository) GetByIdempotencyKey(
	ctx context.Context,
	key string,
) (*models.Repayment, error) {
	repayment := models.Repayment{}
	err := repo.Pool().DB(ctx, true).
		First(&repayment, "idempotency_key = ?", key).Error
	if err != nil {
		return nil, err
	}
	return &repayment, nil
}

func (repo *repaymentRepository) ClaimIdempotencyKey(
	ctx context.Context,
	rep *models.Repayment,
) (*models.Repayment, bool, error) {
	err := repo.Create(ctx, rep)
	if err == nil {
		return rep, true, nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return nil, false, err
	}

	existing, getErr := repo.GetByIdempotencyKey(ctx, rep.IdempotencyKey)
	if getErr != nil {
		return nil, false, err
	}
	return existing, false, nil
}

func (repo *repaymentRepository) UpdateColumns(
	ctx context.Context,
	id string,
	values map[string]any,
) (int64, error) {
	return applyColumnUpdate(repo.Pool().DB(ctx, false), "repayments", id, values)
}

// ListByLoanAccountID returns up to limit repayments of a loan in posting
// order. It is served from idx_rep_loan_created, so the statement path reads
// one index range instead of scanning the table.
func (repo *repaymentRepository) ListByLoanAccountID(
	ctx context.Context,
	loanAccountID string,
	limit int,
) ([]*models.Repayment, error) {
	var rows []*models.Repayment
	err := repo.Pool().DB(ctx, true).
		Where("loan_account_id = ?", loanAccountID).
		Order("created_at ASC, id ASC").
		Limit(limit).
		Find(&rows).Error
	if err != nil {
		return nil, err
	}
	return rows, nil
}

// ListUnapplied reads the loan's range of idx_rep_loan_created; a loan has
// at most a handful of repayments still to apply.
func (repo *repaymentRepository) ListUnapplied(
	ctx context.Context,
	loanAccountID string,
	limit int,
) ([]*models.Repayment, error) {
	var rows []*models.Repayment
	err := repo.Pool().DB(ctx, false).
		Where("loan_account_id = ? AND applied_at IS NULL", loanAccountID).
		Order("created_at ASC, id ASC").
		Limit(limit).
		Find(&rows).Error
	if err != nil {
		return nil, err
	}
	return rows, nil
}

// ClaimFundingUnsettled leases a batch through FOR UPDATE SKIP LOCKED, so
// any number of job runs can work the backlog at once.
func (repo *repaymentRepository) ClaimFundingUnsettled(
	ctx context.Context,
	limit, leaseSeconds int,
) ([]*models.Repayment, error) {
	var rows []*models.Repayment
	err := repo.Pool().DB(ctx, false).Raw(`
UPDATE repayments SET funding_claimed_at = now()
WHERE id IN (
    SELECT id FROM repayments
    WHERE funding_settled_at IS NULL AND applied_at IS NOT NULL AND status IN (2, 3, 4) AND deleted_at IS NULL
      AND (funding_claimed_at IS NULL OR funding_claimed_at < now() - make_interval(secs => ?))
    ORDER BY created_at
    LIMIT ?
    FOR UPDATE SKIP LOCKED
)
RETURNING *`, leaseSeconds, limit).Scan(&rows).Error
	return rows, err
}

func (repo *repaymentRepository) MarkFundingSettled(ctx context.Context, id string, note string) error {
	values := map[string]any{"funding_settled_at": time.Now().UTC()}
	if note != "" {
		values["properties"] = gorm.Expr(
			"COALESCE(properties, '{}'::jsonb) || jsonb_build_object('funding_note', ?::text)", note)
	}
	_, err := repo.UpdateColumns(ctx, id, values)
	return err
}
