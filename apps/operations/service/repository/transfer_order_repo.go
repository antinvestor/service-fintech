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

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// TransferOrderRepository provides data access for transfer orders.
type TransferOrderRepository interface {
	datastore.BaseRepository[*models.TransferOrder]
	// GetByReference looks up a transfer order by its caller-supplied reference.
	// The reference is used as an idempotency key: callers must pass a stable,
	// deterministic value (e.g. "repayment:{id}:principal") and a unique index
	// enforces at-most-one row per non-empty reference.
	GetByReference(ctx context.Context, reference string) (*models.TransferOrder, error)

	// CreateIfAbsent inserts the order synchronously. When a row with the same
	// reference already exists the caller's order is populated from it and no
	// second row is written, so Save is safe to retry and the returned order
	// always names a row that is readable right after the call.
	CreateIfAbsent(ctx context.Context, order *models.TransferOrder) error

	// ClaimState conditionally moves an order out of one of fromStates into
	// toState in a single UPDATE. It reports whether this caller won the claim.
	ClaimState(ctx context.Context, orderID string, fromStates []int32, toState int32) (bool, error)

	// ClaimStaleExecution re-claims an order another execution left in
	// StateCheckCreated before modifiedBefore. The predicate on modified_at
	// makes the claim exclusive: two resumers racing on the same stale row
	// both read the old timestamp, only one UPDATE matches it.
	ClaimStaleExecution(ctx context.Context, orderID string, modifiedBefore time.Time) (bool, error)

	// ReleaseExecution hands an order claimed for execution back to
	// StateJustCreated with the reason the attempt failed, so the next retry
	// re-enters instead of being told the order is already handled.
	ReleaseExecution(ctx context.Context, orderID, reason string) (bool, error)

	// MarkLedgerPosted records the ledger transaction id on the order so a
	// retry never posts the same movement twice.
	MarkLedgerPosted(ctx context.Context, orderID, ledgerTxnID string) error

	// ClaimPaymentInitiation sets payment_initiated_at exactly once. It
	// reports false when a previous attempt already reached the payment rail,
	// in which case the caller must not send a second payout.
	ClaimPaymentInitiation(ctx context.Context, orderID string) (bool, error)

	// RecordPaymentID stores the payment service's id for the payout.
	RecordPaymentID(ctx context.Context, orderID, paymentID string) error
}

// NewTransferOrderRepository creates a new TransferOrderRepository.
func NewTransferOrderRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) TransferOrderRepository {
	return &transferOrderRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.TransferOrder {
			return &models.TransferOrder{}
		}),
		dbPool: dbPool,
	}
}

type transferOrderRepository struct {
	datastore.BaseRepository[*models.TransferOrder]
	dbPool pool.Pool
}

func (r *transferOrderRepository) CreateIfAbsent(ctx context.Context, order *models.TransferOrder) error {
	err := r.dbPool.DB(ctx, false).Create(order).Error
	if err == nil {
		return nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return err
	}

	existing, refErr := r.GetByReference(ctx, order.Reference)
	if refErr != nil {
		return err
	}
	copyStoredOrder(order, existing)
	return nil
}

// copyStoredOrder aligns an in-memory order with the row that already owns its
// reference so callers execute the winning row rather than a phantom id.
func copyStoredOrder(order, existing *models.TransferOrder) {
	order.ID = existing.ID
	order.State = existing.State
	order.CreatedAt = existing.CreatedAt
	order.ModifiedAt = existing.ModifiedAt
	order.Version = existing.Version
}

func (r *transferOrderRepository) ClaimState(
	ctx context.Context,
	orderID string,
	fromStates []int32,
	toState int32,
) (bool, error) {
	// Table, not Model: an empty model instance has its primary key filled in
	// by the frame BaseModel hooks, which would add a bogus id to the WHERE.
	result := r.dbPool.DB(ctx, false).
		Table("transfer_orders").
		Where("deleted_at IS NULL AND id = ? AND state IN ?", orderID, fromStates).
		Updates(map[string]any{
			colState:      toState,
			colModifiedAt: time.Now().UTC(),
			colVersion:    gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (r *transferOrderRepository) GetByReference(
	ctx context.Context,
	reference string,
) (*models.TransferOrder, error) {
	if reference == "" {
		return nil, gorm.ErrRecordNotFound
	}
	entity := &models.TransferOrder{}
	err := r.dbPool.DB(ctx, true).Where("reference = ?", reference).First(entity).Error
	if err != nil {
		return nil, err
	}
	return entity, nil
}

func (r *transferOrderRepository) ClaimStaleExecution(
	ctx context.Context,
	orderID string,
	modifiedBefore time.Time,
) (bool, error) {
	result := r.dbPool.DB(ctx, false).
		Table("transfer_orders").
		Where("deleted_at IS NULL AND id = ? AND state = ? AND modified_at < ?",
			orderID, int32(constants.StateCheckCreated), modifiedBefore.UTC()).
		Updates(map[string]any{
			colModifiedAt: time.Now().UTC(),
			colVersion:    gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (r *transferOrderRepository) ReleaseExecution(ctx context.Context, orderID, reason string) (bool, error) {
	result := r.dbPool.DB(ctx, false).
		Table("transfer_orders").
		Where("deleted_at IS NULL AND id = ? AND state = ?", orderID, int32(constants.StateCheckCreated)).
		Updates(map[string]any{
			colState:         int32(constants.StateJustCreated),
			colFailureReason: reason,
			colModifiedAt:    time.Now().UTC(),
			colVersion:       gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (r *transferOrderRepository) MarkLedgerPosted(ctx context.Context, orderID, ledgerTxnID string) error {
	return r.dbPool.DB(ctx, false).
		Table("transfer_orders").
		Where("deleted_at IS NULL AND id = ?", orderID).
		Updates(map[string]any{
			colLedgerTxnID: ledgerTxnID,
			colModifiedAt:  time.Now().UTC(),
			colVersion:     gorm.Expr("version + 1"),
		}).Error
}

func (r *transferOrderRepository) ClaimPaymentInitiation(ctx context.Context, orderID string) (bool, error) {
	result := r.dbPool.DB(ctx, false).
		Table("transfer_orders").
		Where("deleted_at IS NULL AND id = ? AND payment_initiated_at IS NULL", orderID).
		Updates(map[string]any{
			colPaymentInitiatedAt: time.Now().UTC(),
			colModifiedAt:         time.Now().UTC(),
			colVersion:            gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (r *transferOrderRepository) RecordPaymentID(ctx context.Context, orderID, paymentID string) error {
	return r.dbPool.DB(ctx, false).
		Table("transfer_orders").
		Where("deleted_at IS NULL AND id = ?", orderID).
		Updates(map[string]any{
			colPaymentID:  paymentID,
			colModifiedAt: time.Now().UTC(),
			colVersion:    gorm.Expr("version + 1"),
		}).Error
}
