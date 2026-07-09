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
	"time"

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/seed/service/models"
)

// ErrCreditProfileNotFound is returned when no profile matches the filter.
var ErrCreditProfileNotFound = errors.New("seed credit profile not found")

// CreditProfileRepository owns the seed_credit_profiles table. Mutations
// that change counters or tier go through dedicated atomic methods so
// two concurrent credit-affecting events (a new loan request and a
// paid-off hook arriving at the same moment) serialise cleanly at the
// row level.
type CreditProfileRepository interface {
	datastore.BaseRepository[*models.CreditProfile]

	// GetByClientAndCurrency is the primary lookup path: seed always
	// scopes credit by (client, currency).
	GetByClientAndCurrency(
		ctx context.Context,
		clientID, currencyCode string,
	) (*models.CreditProfile, error)

	// Ensure upserts a fresh tier-1 profile if none exists. Safe to
	// call repeatedly; concurrent callers land on the same row via
	// the (client, currency) unique index.
	Ensure(
		ctx context.Context,
		clientID, currencyCode, productID string,
		parent *data.BaseModel,
	) (*models.CreditProfile, error)

	// AtomicMarkBorrowed is called when a loan request is approved and
	// the loan account has been created. Increments OutstandingLoanCount,
	// TotalBorrowed, and stamps LastBorrowedAt (and FirstBorrowedAt if
	// not yet set). Single SQL UPDATE so concurrent approvals cannot
	// race with concurrent repayments.
	AtomicMarkBorrowed(
		ctx context.Context,
		profileID string,
		amount int64,
	) (*models.CreditProfile, error)

	// AtomicRecordRepayment is called when a loan belonging to this
	// profile reaches PAID_OFF. Decrements OutstandingLoanCount,
	// increments SuccessfulRepayments and TotalRepaid, stamps
	// LastRepaidAt. Idempotency is the caller's responsibility: seed
	// uses a marker on the LoanRequest row to make sure this only
	// fires once per loan.
	AtomicRecordRepayment(
		ctx context.Context,
		profileID string,
		amount int64,
	) (*models.CreditProfile, error)

	// AtomicPromoteTier updates the cached Tier and MaxLoanAmount on the
	// profile after an evaluation decides the ladder rung has moved up.
	// Atomic so the read-then-write done by EvaluateTier cannot race
	// with a concurrent MarkBorrowed/RecordRepayment.
	AtomicPromoteTier(
		ctx context.Context,
		profileID string,
		newTier int32,
		newMaxLoanAmount int64,
	) (*models.CreditProfile, error)

	// AtomicSetStatus transitions Status independent of counters: used
	// by operator-triggered suspend / block / unblock flows.
	AtomicSetStatus(
		ctx context.Context,
		profileID string,
		status models.CreditProfileStatus,
	) (*models.CreditProfile, error)
}

type creditProfileRepository struct {
	datastore.BaseRepository[*models.CreditProfile]
	dbPool pool.Pool
}

// NewCreditProfileRepository constructs a repository bound to the given
// datastore pool.
func NewCreditProfileRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) CreditProfileRepository {
	return &creditProfileRepository{
		BaseRepository: datastore.NewBaseRepository[*models.CreditProfile](
			ctx, dbPool, workMan, func() *models.CreditProfile { return &models.CreditProfile{} },
		),
		dbPool: dbPool,
	}
}

func (r *creditProfileRepository) GetByClientAndCurrency(
	ctx context.Context,
	clientID, currencyCode string,
) (*models.CreditProfile, error) {
	entity := &models.CreditProfile{}
	err := r.dbPool.DB(ctx, true).
		Where("client_id = ? AND currency_code = ?", clientID, currencyCode).
		First(entity).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrCreditProfileNotFound
		}
		return nil, err
	}
	return entity, nil
}

func (r *creditProfileRepository) Ensure(
	ctx context.Context,
	clientID, currencyCode, productID string,
	parent *data.BaseModel,
) (*models.CreditProfile, error) {
	existing, err := r.GetByClientAndCurrency(ctx, clientID, currencyCode)
	if err == nil {
		return existing, nil
	}
	if !errors.Is(err, ErrCreditProfileNotFound) {
		return nil, err
	}

	row := &models.CreditProfile{
		ClientID:     clientID,
		CurrencyCode: currencyCode,
		ProductID:    productID,
		Status:       int32(models.CreditProfileStatusActive),
		Tier:         1,
	}
	row.GenID(ctx)
	if parent != nil {
		row.CopyPartitionInfo(parent)
	}

	if createErr := r.dbPool.DB(ctx, false).Create(row).Error; createErr != nil {
		if data.ErrorIsDuplicateKey(createErr) {
			return r.GetByClientAndCurrency(ctx, clientID, currencyCode)
		}
		return nil, createErr
	}
	return row, nil
}

func (r *creditProfileRepository) AtomicMarkBorrowed(
	ctx context.Context,
	profileID string,
	amount int64,
) (*models.CreditProfile, error) {
	if amount <= 0 {
		return nil, errors.New("borrow amount must be positive")
	}
	now := time.Now().UTC()
	// GORM "Updates" with a map preserves zero-value writes for the
	// last_borrowed_at timestamp, which is what we want here.
	result := r.dbPool.DB(ctx, false).
		Model(&models.CreditProfile{}).
		Where("id = ?", profileID).
		Updates(map[string]any{
			"outstanding_loan_count": gorm.Expr("outstanding_loan_count + 1"),
			"total_borrowed":         gorm.Expr("total_borrowed + ?", amount),
			"last_borrowed_at":       now,
			"first_borrowed_at":      gorm.Expr("COALESCE(first_borrowed_at, ?)", now),
			colModifiedAt:            now,
			colVersion:               gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, ErrCreditProfileNotFound
	}
	return r.GetByID(ctx, profileID)
}

func (r *creditProfileRepository) AtomicRecordRepayment(
	ctx context.Context,
	profileID string,
	amount int64,
) (*models.CreditProfile, error) {
	if amount < 0 {
		return nil, errors.New("repayment amount must be non-negative")
	}
	now := time.Now().UTC()
	result := r.dbPool.DB(ctx, false).
		Model(&models.CreditProfile{}).
		Where("id = ?", profileID).
		Updates(map[string]any{
			"outstanding_loan_count": gorm.Expr("GREATEST(outstanding_loan_count - 1, 0)"),
			"successful_repayments":  gorm.Expr("successful_repayments + 1"),
			"total_repaid":           gorm.Expr("total_repaid + ?", amount),
			"last_repaid_at":         now,
			colModifiedAt:            now,
			colVersion:               gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, ErrCreditProfileNotFound
	}
	return r.GetByID(ctx, profileID)
}

func (r *creditProfileRepository) AtomicPromoteTier(
	ctx context.Context,
	profileID string,
	newTier int32,
	newMaxLoanAmount int64,
) (*models.CreditProfile, error) {
	now := time.Now().UTC()
	result := r.dbPool.DB(ctx, false).
		Model(&models.CreditProfile{}).
		Where("id = ?", profileID).
		Updates(map[string]any{
			"tier":            newTier,
			"max_loan_amount": newMaxLoanAmount,
			colModifiedAt:     now,
			colVersion:        gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, ErrCreditProfileNotFound
	}
	return r.GetByID(ctx, profileID)
}

func (r *creditProfileRepository) AtomicSetStatus(
	ctx context.Context,
	profileID string,
	status models.CreditProfileStatus,
) (*models.CreditProfile, error) {
	now := time.Now().UTC()
	result := r.dbPool.DB(ctx, false).
		Model(&models.CreditProfile{}).
		Where("id = ?", profileID).
		Updates(map[string]any{
			"status":      int32(status),
			colModifiedAt: now,
			colVersion:    gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, ErrCreditProfileNotFound
	}
	return r.GetByID(ctx, profileID)
}
