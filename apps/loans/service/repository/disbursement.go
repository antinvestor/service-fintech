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

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

type DisbursementRepository interface {
	datastore.BaseRepository[*models.Disbursement]
	GetByIdempotencyKey(ctx context.Context, key string) (*models.Disbursement, error)
	// ClaimIdempotencyKey inserts the disbursement, or hands back the row that
	// already owns the key. Reserving the key with the insert itself — rather
	// than reading first and writing later — is what keeps two concurrent
	// requests from both reaching the payment rail.
	ClaimIdempotencyKey(
		ctx context.Context,
		disb *models.Disbursement,
	) (stored *models.Disbursement, created bool, err error)
	UpdateColumns(ctx context.Context, id string, values map[string]any) (int64, error)
	// ListByLoanAccountID returns up to limit disbursements of a loan in
	// the order they were made.
	ListByLoanAccountID(ctx context.Context, loanAccountID string, limit int) ([]*models.Disbursement, error)
	// GetLiveByLoanAccountID returns the disbursement that is processing or
	// completed for the loan, if any. The partial unique index
	// uq_disb_partition_loan_live guarantees there is at most one.
	GetLiveByLoanAccountID(ctx context.Context, loanAccountID string) (*models.Disbursement, error)
}

// ErrLiveDisbursementExists is returned by ClaimIdempotencyKey when a
// different idempotency key already holds the loan's single live
// disbursement: the caller's key did not win and must not move money.
var ErrLiveDisbursementExists = errors.New("another disbursement is already live for this loan")

// liveDisbursementStatuses mirrors the predicate of uq_disb_partition_loan_live.
func liveDisbursementStatuses() []int32 {
	return []int32{
		int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_PROCESSING),
		int32(loansv1.DisbursementStatus_DISBURSEMENT_STATUS_COMPLETED),
	}
}

type disbursementRepository struct {
	entityRepository[*models.Disbursement]
}

func NewDisbursementRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) DisbursementRepository {
	return &disbursementRepository{
		entityRepository: newEntityRepository(ctx, dbPool, workMan, func() *models.Disbursement {
			return &models.Disbursement{}
		}),
	}
}

func (repo *disbursementRepository) GetByIdempotencyKey(
	ctx context.Context,
	key string,
) (*models.Disbursement, error) {
	return repo.findOneByField(ctx, "idempotency_key = ?", key)
}

func (repo *disbursementRepository) ClaimIdempotencyKey(
	ctx context.Context,
	disb *models.Disbursement,
) (*models.Disbursement, bool, error) {
	err := repo.Create(ctx, disb)
	if err == nil {
		return disb, true, nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return nil, false, err
	}

	existing, getErr := repo.GetByIdempotencyKey(ctx, disb.IdempotencyKey)
	if getErr == nil && existing != nil {
		return existing, false, nil
	}
	if !data.ErrorIsNoRows(getErr) {
		return nil, false, err
	}

	// The key is free, so the duplicate came from the live-disbursement
	// index: another key already owns this loan's payout.
	if live, liveErr := repo.GetLiveByLoanAccountID(ctx, disb.LoanAccountID); liveErr == nil && live != nil {
		return live, false, ErrLiveDisbursementExists
	}
	return nil, false, err
}

func (repo *disbursementRepository) GetLiveByLoanAccountID(
	ctx context.Context,
	loanAccountID string,
) (*models.Disbursement, error) {
	var row models.Disbursement
	err := repo.Pool().DB(ctx, false).
		Where("loan_account_id = ? AND status IN ?", loanAccountID, liveDisbursementStatuses()).
		Order("created_at DESC").
		First(&row).Error
	if err != nil {
		return nil, err
	}
	return &row, nil
}

func (repo *disbursementRepository) UpdateColumns(
	ctx context.Context,
	id string,
	values map[string]any,
) (int64, error) {
	return applyColumnUpdate(repo.Pool().DB(ctx, false), "disbursements", id, values)
}

// ListByLoanAccountID is served from idx_disb_loan_created.
func (repo *disbursementRepository) ListByLoanAccountID(
	ctx context.Context,
	loanAccountID string,
	limit int,
) ([]*models.Disbursement, error) {
	var rows []*models.Disbursement
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
