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

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
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

	// MarkPayoutFailed records that the payment rail rejected the payout.
	// The order keeps its claim and payment id so it cannot be paid twice,
	// and executeInner refuses to complete it until it is reversed.
	MarkPayoutFailed(ctx context.Context, orderID, paymentID, reason string) error

	// SetPayoutOutcome moves a payout that is not failed to status:
	// pending or confirmed. A failed payout keeps its failure.
	SetPayoutOutcome(ctx context.Context, orderID, status string) error

	// ListPayoutsToReconcile returns up to limit payout orders of the given
	// types that reached the rail before before and whose outcome is not
	// known, those checked longest ago first.
	ListPayoutsToReconcile(
		ctx context.Context,
		orderTypes []int,
		before time.Time,
		limit int,
	) ([]*models.TransferOrder, error)

	// TouchPayoutChecked records that the outcome was asked for now.
	TouchPayoutChecked(ctx context.Context, orderID string) error

	// ListLateFailedPayouts returns up to limit orders that completed and
	// whose payout the rail failed afterwards, whose originator has not been
	// told.
	ListLateFailedPayouts(ctx context.Context, limit int) ([]*models.TransferOrder, error)

	// MarkOriginatorNotified records that the originator was told.
	MarkOriginatorNotified(ctx context.Context, orderID string) error

	// RetakePaymentInitiation swaps a stale payout claim for a fresh one in a
	// single compare-and-swap on the observed claim time, so of several
	// resumers that all saw the same stale claim exactly one may send. It
	// never touches a claim that recorded a payment id.
	RetakePaymentInitiation(ctx context.Context, orderID string, observed time.Time) (bool, error)

	// ConsumeObligationForOrder consumes amount from the obligation and marks
	// the allocation order consumed in one transaction, so there is never an
	// order whose obligation was consumed without the order saying so, nor an
	// order marked consumed whose obligation was not. It reports false when
	// the obligation could not be consumed (nothing is changed) and errors
	// when the order could not be marked (nothing is committed).
	ConsumeObligationForOrder(ctx context.Context, orderID, obligationID string, amount int64) (bool, error)

	// MarkFailedIfUnposted moves an order to StateShutdown only while neither
	// its ledger leg nor its payout has progressed. An order that has posted
	// or reached the rail cannot be declared failed; it must be reversed.
	MarkFailedIfUnposted(ctx context.Context, orderID string) (bool, error)

	// ListUnexecutedAllocations returns up to limit orders a payment
	// allocation raised that have not been posted and that nobody has
	// touched since before: an individual borrower's repayment, a group
	// member's payment moved into their suspense, and what that suspense
	// paid towards the member's obligations.
	ListUnexecutedAllocations(ctx context.Context, before time.Time, limit int) ([]*models.TransferOrder, error)
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
	order.Amount = existing.Amount
	order.Currency = existing.Currency
	order.ObligationConsumed = existing.ObligationConsumed
	order.LedgerTransactionID = existing.LedgerTransactionID
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

func (r *transferOrderRepository) RetakePaymentInitiation(
	ctx context.Context,
	orderID string,
	observed time.Time,
) (bool, error) {
	result := r.dbPool.DB(ctx, false).
		Table("transfer_orders").
		Where("deleted_at IS NULL AND id = ? AND payment_initiated_at = ? AND (payment_id IS NULL OR payment_id = '')",
			orderID, observed.UTC()).
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

func (r *transferOrderRepository) MarkFailedIfUnposted(ctx context.Context, orderID string) (bool, error) {
	result := r.dbPool.DB(ctx, false).
		Table("transfer_orders").
		Where("deleted_at IS NULL AND id = ? AND state IN ? "+
			"AND (ledger_transaction_id IS NULL OR ledger_transaction_id = '') AND payment_initiated_at IS NULL",
			orderID, []int32{
				int32(constants.StateJustCreated),
				int32(constants.StateCheckCreated),
				int32(constants.StateActive),
			}).
		Updates(map[string]any{
			colState:      int32(constants.StateShutdown),
			colModifiedAt: time.Now().UTC(),
			colVersion:    gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (r *transferOrderRepository) MarkPayoutFailed(ctx context.Context, orderID, paymentID, reason string) error {
	return r.dbPool.DB(ctx, false).
		Table("transfer_orders").
		Where("deleted_at IS NULL AND id = ? AND (payment_id IS NULL OR payment_id = '' OR payment_id = ?)",
			orderID, paymentID).
		Updates(map[string]any{
			colPayoutStatus:  models.PayoutStatusFailed,
			colPaymentID:     paymentID,
			colFailureReason: reason,
			colModifiedAt:    time.Now().UTC(),
			colVersion:       gorm.Expr("version + 1"),
		}).Error
}

func (r *transferOrderRepository) SetPayoutOutcome(ctx context.Context, orderID, status string) error {
	return r.dbPool.DB(ctx, false).
		Table("transfer_orders").
		Where("deleted_at IS NULL AND id = ? AND (payout_status IS NULL OR payout_status <> ?)",
			orderID, models.PayoutStatusFailed).
		Updates(map[string]any{
			colPayoutStatus:     status,
			"payout_checked_at": time.Now().UTC(),
			colModifiedAt:       time.Now().UTC(),
			colVersion:          gorm.Expr("version + 1"),
		}).Error
}

func (r *transferOrderRepository) ListPayoutsToReconcile(
	ctx context.Context,
	orderTypes []int,
	before time.Time,
	limit int,
) ([]*models.TransferOrder, error) {
	var orders []*models.TransferOrder
	err := r.dbPool.DB(ctx, true).
		Where("deleted_at IS NULL AND order_type IN ? AND payment_initiated_at IS NOT NULL "+
			"AND payment_initiated_at < ? AND (payout_status IS NULL OR payout_status IN ?)",
			orderTypes, before.UTC(), []string{"", models.PayoutStatusPending}).
		Order("payout_checked_at NULLS FIRST, payment_initiated_at").
		Limit(limit).
		Find(&orders).Error
	return orders, err
}

func (r *transferOrderRepository) TouchPayoutChecked(ctx context.Context, orderID string) error {
	return r.dbPool.DB(ctx, false).
		Table("transfer_orders").
		Where("deleted_at IS NULL AND id = ?", orderID).
		Update("payout_checked_at", time.Now().UTC()).Error
}

func (r *transferOrderRepository) ListLateFailedPayouts(
	ctx context.Context,
	limit int,
) ([]*models.TransferOrder, error) {
	var orders []*models.TransferOrder
	err := r.dbPool.DB(ctx, true).
		Where("deleted_at IS NULL AND payout_status = ? AND state = ? AND originator_notified_at IS NULL",
			models.PayoutStatusFailed, int32(constants.StateInactive)).
		Order("modified_at").
		Limit(limit).
		Find(&orders).Error
	return orders, err
}

func (r *transferOrderRepository) MarkOriginatorNotified(ctx context.Context, orderID string) error {
	return r.dbPool.DB(ctx, false).
		Table("transfer_orders").
		Where("deleted_at IS NULL AND id = ?", orderID).
		Update("originator_notified_at", time.Now().UTC()).Error
}

func (r *transferOrderRepository) ConsumeObligationForOrder(
	ctx context.Context,
	orderID, obligationID string,
	amount int64,
) (bool, error) {
	if amount <= 0 {
		return false, nil
	}
	consumed := false
	err := r.dbPool.DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		obl := tx.Table("obligations").
			Where("deleted_at IS NULL AND id = ? AND state = ? AND amount >= ?",
				obligationID, int32(constants.StateActive), amount).
			Updates(map[string]any{
				"amount": gorm.Expr("amount - ?", amount),
				colState: gorm.Expr(
					"CASE WHEN amount - ? <= 0 THEN ? ELSE state END",
					amount,
					int32(constants.StateInactive),
				),
				colModifiedAt: time.Now().UTC(),
				colVersion:    gorm.Expr("version + 1"),
			})
		if obl.Error != nil {
			return obl.Error
		}
		if obl.RowsAffected == 0 {
			return nil
		}
		mark := tx.Table("transfer_orders").
			Where("deleted_at IS NULL AND id = ? AND obligation_consumed = false", orderID).
			Updates(map[string]any{
				"obligation_consumed": true,
				colModifiedAt:         time.Now().UTC(),
				colVersion:            gorm.Expr("version + 1"),
			})
		if mark.Error != nil {
			return mark.Error
		}
		if mark.RowsAffected == 0 {
			return errOrderAlreadyConsumed
		}
		consumed = true
		return nil
	})
	if err != nil {
		return false, err
	}
	return consumed, nil
}

// errOrderAlreadyConsumed aborts the consume transaction when the order was
// already marked: the obligation debit above is rolled back with it.
var errOrderAlreadyConsumed = errors.New("transfer order already marked consumed")

// Allocation order references ("payment:<id>:loan:<id>" for a borrower's
// repayment, "payment:<id>:member:<id>" for a member's payment moved into
// their suspense, "payment:<id>:obligation:<id>" for what the suspense paid).
// Obligation orders count only when marked suspense-funded: older ones were
// left to the group workflows and their suspense was never funded here.
const (
	borrowerRepaymentReference = "payment:%:loan:%"
	memberSuspenseReference    = "payment:%:member:%"
	memberObligationReference  = "payment:%:obligation:%"
)

func (r *transferOrderRepository) ListUnexecutedAllocations(
	ctx context.Context,
	before time.Time,
	limit int,
) ([]*models.TransferOrder, error) {
	var orders []*models.TransferOrder
	err := r.dbPool.DB(ctx, true).
		Where("deleted_at IS NULL AND state IN ? AND extra_data ->> 'source' = ? AND modified_at < ?",
			[]int32{int32(constants.StateJustCreated), int32(constants.StateCheckCreated)},
			"payment_allocation", before.UTC()).
		Where("(reference LIKE ? OR reference LIKE ? OR "+
			"(reference LIKE ? AND extra_data ->> 'suspense_funded' = 'true'))",
			borrowerRepaymentReference, memberSuspenseReference, memberObligationReference).
		Order("modified_at").
		Limit(limit).
		Find(&orders).Error
	if err != nil {
		return nil, err
	}
	return orders, nil
}
