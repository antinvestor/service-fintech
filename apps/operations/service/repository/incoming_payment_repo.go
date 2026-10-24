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

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
)

// IncomingPaymentRepository provides data access for incoming payments.
type IncomingPaymentRepository interface {
	datastore.BaseRepository[*models.IncomingPayment]
	GetByTransactionID(ctx context.Context, transactionID string) (*models.IncomingPayment, error)

	// CreateIfAbsent inserts the payment synchronously. A concurrent insert of
	// the same transaction_id loses the race against the unique index; the
	// winner's row is read back and returned so both callers converge on one
	// payment record.
	CreateIfAbsent(ctx context.Context, payment *models.IncomingPayment) (*models.IncomingPayment, error)

	// ClaimState conditionally moves a payment out of one of fromStates into
	// toState in a single UPDATE, reporting whether this caller won the claim.
	ClaimState(ctx context.Context, paymentID string, fromStates []int32, toState int32) (bool, error)

	// SetAllocationOutcome writes the post-allocation state together with the
	// amount left unallocated, and releases the allocation lease. It is fenced
	// by the lease: only the run holding lease may write, so a run whose lease
	// was taken over as stale cannot overwrite a newer outcome. The remainder
	// is the payer's suspense balance, so it is recorded on the row rather
	// than recomputed from the ledger. It reports whether the write landed.
	SetAllocationOutcome(
		ctx context.Context,
		paymentID string,
		lease time.Time,
		state int32,
		remaining int64,
	) (bool, error)

	// ClaimAllocation takes the allocation lease on a payment: it succeeds
	// when no run holds it, or the holder's lease is older than staleBefore.
	// Exactly one of several concurrent callers wins and receives the row as
	// it is after the claim, carrying the lease in AllocatingAt.
	ClaimAllocation(ctx context.Context, paymentID string, staleBefore time.Time) (*models.IncomingPayment, bool, error)

	// ReleaseAllocation drops the lease held as lease without recording an
	// outcome, for a run that could not do its work.
	ReleaseAllocation(ctx context.Context, paymentID string, lease time.Time) error

	// GetWithSuspenseByOwnerID returns the owner's payments that still carry an
	// unallocated remainder, oldest first.
	GetWithSuspenseByOwnerID(ctx context.Context, ownerID string) ([]*models.IncomingPayment, error)

	// MarkConfirmed stamps the confirmation timestamp exactly once, reporting
	// whether this call was the one that stamped it.
	MarkConfirmed(ctx context.Context, paymentID string, at time.Time) (bool, error)
}

// NewIncomingPaymentRepository creates a new IncomingPaymentRepository.
func NewIncomingPaymentRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) IncomingPaymentRepository {
	return &incomingPaymentRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.IncomingPayment {
			return &models.IncomingPayment{}
		}),
	}
}

// colProperties is the JSONB column carrying per-payment metadata, and
// propertyRemainingAmount the key inside it holding the unallocated remainder.
const (
	colProperties           = "properties"
	propertyRemainingAmount = "remaining_amount"
	propertyConfirmedAt     = "confirmed_at"
)

type incomingPaymentRepository struct {
	datastore.BaseRepository[*models.IncomingPayment]
}

func (r *incomingPaymentRepository) CreateIfAbsent(
	ctx context.Context,
	payment *models.IncomingPayment,
) (*models.IncomingPayment, error) {
	err := r.Pool().DB(ctx, false).Create(payment).Error
	if err == nil {
		return payment, nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return nil, err
	}
	existing, getErr := r.GetByTransactionID(ctx, payment.TransactionID)
	if getErr != nil {
		return nil, err
	}
	return existing, nil
}

func (r *incomingPaymentRepository) ClaimState(
	ctx context.Context,
	paymentID string,
	fromStates []int32,
	toState int32,
) (bool, error) {
	// Table, not Model: an empty model instance has its primary key filled in
	// by the frame BaseModel hooks, which would add a bogus id to the WHERE.
	result := r.Pool().DB(ctx, false).
		Table("incoming_payments").
		Where("deleted_at IS NULL AND id = ? AND state IN ?", paymentID, fromStates).
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

func (r *incomingPaymentRepository) SetAllocationOutcome(
	ctx context.Context,
	paymentID string,
	lease time.Time,
	state int32,
	remaining int64,
) (bool, error) {
	if remaining < 0 {
		remaining = 0
	}
	result := r.Pool().DB(ctx, false).
		Table("incoming_payments").
		Where("deleted_at IS NULL AND id = ? AND allocating_at = ?", paymentID, lease.UTC()).
		Updates(map[string]any{
			colState:        state,
			colAllocatingAt: nil,
			colProperties: gorm.Expr(
				"COALESCE("+colProperties+", '{}'::jsonb) || jsonb_build_object(?::text, ?::bigint)",
				propertyRemainingAmount, remaining,
			),
			colModifiedAt: time.Now().UTC(),
			colVersion:    gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (r *incomingPaymentRepository) GetWithSuspenseByOwnerID(
	ctx context.Context,
	ownerID string,
) ([]*models.IncomingPayment, error) {
	var payments []*models.IncomingPayment
	err := r.Pool().DB(ctx, true).
		Where("deleted_at IS NULL AND owner_id = ?", ownerID).
		Where("coalesce((properties ->> ?)::bigint, 0) > 0", propertyRemainingAmount).
		Order("created_at ASC").
		Find(&payments).Error
	return payments, err
}

func (r *incomingPaymentRepository) MarkConfirmed(
	ctx context.Context,
	paymentID string,
	at time.Time,
) (bool, error) {
	result := r.Pool().DB(ctx, false).
		Table("incoming_payments").
		Where("deleted_at IS NULL AND id = ?", paymentID).
		Where("properties -> ? IS NULL", propertyConfirmedAt).
		Updates(map[string]any{
			colProperties: gorm.Expr(
				"coalesce(properties, '{}'::jsonb) || jsonb_build_object(?::text, ?::text)",
				propertyConfirmedAt, at.Format(time.RFC3339),
			),
			colModifiedAt: time.Now().UTC(),
			colVersion:    gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (r *incomingPaymentRepository) GetByTransactionID(
	ctx context.Context,
	transactionID string,
) (*models.IncomingPayment, error) {
	ip := models.IncomingPayment{}
	err := r.Pool().DB(ctx, true).First(&ip, "transaction_id = ?", transactionID).Error
	if err != nil {
		return nil, err
	}
	return &ip, nil
}

const colAllocatingAt = "allocating_at"

func (r *incomingPaymentRepository) ClaimAllocation(
	ctx context.Context,
	paymentID string,
	staleBefore time.Time,
) (*models.IncomingPayment, bool, error) {
	// Microsecond precision matches what Postgres stores, so the value we
	// write is the value a later fenced UPDATE compares against.
	lease := time.Now().UTC().Truncate(time.Microsecond)
	result := r.Pool().DB(ctx, false).
		Table("incoming_payments").
		Where("deleted_at IS NULL AND id = ? AND (allocating_at IS NULL OR allocating_at < ?)",
			paymentID, staleBefore.UTC()).
		Updates(map[string]any{
			colAllocatingAt: lease,
			colModifiedAt:   lease,
			colVersion:      gorm.Expr("version + 1"),
		})
	if result.Error != nil {
		return nil, false, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, false, nil
	}
	fresh, err := r.GetByID(ctx, paymentID)
	if err != nil {
		return nil, false, err
	}
	return fresh, true, nil
}

func (r *incomingPaymentRepository) ReleaseAllocation(ctx context.Context, paymentID string, lease time.Time) error {
	return r.Pool().DB(ctx, false).
		Table("incoming_payments").
		Where("deleted_at IS NULL AND id = ? AND allocating_at = ?", paymentID, lease.UTC()).
		Updates(map[string]any{
			colAllocatingAt: nil,
			colModifiedAt:   time.Now().UTC(),
			colVersion:      gorm.Expr("version + 1"),
		}).Error
}
