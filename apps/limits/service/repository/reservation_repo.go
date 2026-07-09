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

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/tenancy"
	"github.com/pitabwire/frame/v2/workerpool"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
)

// SubjectFilter narrows pending-sum queries to a specific subject ref.
type SubjectFilter struct {
	Type models.Subject
	ID   string
}

// ReservationRepository persists Reservation rows. Read paths route through
// the BaseRepository; aggregate queries (PendingSum, ListExpiredActive) drop
// to a raw pool because the BaseRepository surface does not cover them.
type ReservationRepository interface {
	Create(ctx context.Context, r *models.Reservation) error
	GetByID(ctx context.Context, id string) (*models.Reservation, error)
	GetByIdempotencyKey(ctx context.Context, key string) (*models.Reservation, error)
	PendingSum(ctx context.Context, action models.Action, currency string, subject SubjectFilter) (int64, error)
	// PendingSumTx is identical to PendingSum but executes within the supplied
	// gorm transaction so the read participates in the caller's advisory lock.
	PendingSumTx(
		ctx context.Context,
		tx *gorm.DB,
		action models.Action,
		currency string,
		subject SubjectFilter,
	) (int64, error)
	PendingCount(
		ctx context.Context,
		action models.Action,
		currency string,
		subject SubjectFilter,
		since time.Time,
	) (int64, error)
	// PendingCountTx is identical to PendingCount but executes within the supplied
	// gorm transaction so the read participates in the caller's advisory lock.
	PendingCountTx(
		ctx context.Context,
		tx *gorm.DB,
		action models.Action,
		currency string,
		subject SubjectFilter,
		since time.Time,
	) (int64, error)
	SetCommitted(ctx context.Context, id string, at time.Time) error
	// SetCommittedTx runs SetCommitted inside caller-supplied tx (with tenant scope + rows-affected guard).
	SetCommittedTx(ctx context.Context, tx *gorm.DB, id string, at time.Time) error
	SetReleased(ctx context.Context, id, reason string, at time.Time) error
	// SetReleasedTx runs SetReleased inside caller-supplied tx (with tenant scope + rows-affected guard).
	SetReleasedTx(ctx context.Context, tx *gorm.DB, id, reason string, at time.Time) error
	SetExpired(ctx context.Context, id string, at time.Time) error
	// BulkSetExpired transitions all rows in ids from 'active' to 'expired'
	// in a single UPDATE ... WHERE id IN (...) round-trip. Cross-tenant:
	// TenancyPartition is intentionally not applied (matches ListExpiredActive).
	// Returns the number of rows actually updated.
	BulkSetExpired(ctx context.Context, ids []string, at time.Time) (int, error)
	SetReversed(ctx context.Context, id string, at time.Time) error
	// SetReversedTx runs SetReversed inside caller-supplied tx with status='committed' guard.
	SetReversedTx(ctx context.Context, tx *gorm.DB, id string, at time.Time) error
	SetPendingApproval(ctx context.Context, id string) error
	SetActive(ctx context.Context, id string) error
	// SetActiveTx runs SetActive inside caller-supplied tx.
	SetActiveTx(ctx context.Context, tx *gorm.DB, id string) error
	ListExpiredActive(ctx context.Context, before time.Time, limit int) ([]*models.Reservation, error)
	// HardDeleteTerminalBefore permanently deletes terminal reservations
	// (committed, released, reversed, expired) whose modified_at is older than
	// cutoff. Processes in batches of 1000 to avoid lock storms. Cross-tenant.
	// Returns total rows deleted.
	HardDeleteTerminalBefore(ctx context.Context, cutoff time.Time) (int, error)
}

type reservationRepository struct {
	datastore.BaseRepository[*models.Reservation]
	dbPool pool.Pool
}

// NewReservationRepository constructs the repository.
func NewReservationRepository(ctx context.Context, p pool.Pool, workMan workerpool.Manager) ReservationRepository {
	r := &reservationRepository{dbPool: p}
	r.BaseRepository = datastore.NewBaseRepository[*models.Reservation](
		ctx, p, workMan,
		func() *models.Reservation { return &models.Reservation{} },
	)
	return r
}

func (r *reservationRepository) Create(ctx context.Context, m *models.Reservation) error {
	if m.ID == "" {
		m.ID = util.IDString()
	}
	return r.BaseRepository.Create(ctx, m)
}

func (r *reservationRepository) GetByIdempotencyKey(ctx context.Context, key string) (*models.Reservation, error) {
	db := r.dbPool.DB(ctx, true)
	var out models.Reservation
	if err := db.Where("idempotency_key = ?", key).First(&out).Error; err != nil {
		return nil, err
	}
	return &out, nil
}

func (r *reservationRepository) PendingSum(
	ctx context.Context,
	action models.Action,
	currency string,
	subject SubjectFilter,
) (int64, error) {
	db := r.dbPool.DB(ctx, true)
	var sum int64
	err := db.Table(models.Reservation{}.TableName()).
		Where("action = ? AND currency_code = ?", string(action), currency).
		Where("status IN ?", []string{string(models.ReservationStatusActive), string(models.ReservationStatusPendingApproval)}).
		Where("ttl_at > ?", time.Now().UTC()).
		Where("subject_refs @> ?::jsonb", subjectMatch(subject)).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&sum).Error
	if err != nil {
		return 0, err
	}
	return sum, nil
}

func (r *reservationRepository) PendingCount(
	ctx context.Context,
	action models.Action,
	currency string,
	subject SubjectFilter,
	since time.Time,
) (int64, error) {
	db := r.dbPool.DB(ctx, true)
	var count int64
	err := db.Table(models.Reservation{}.TableName()).
		Where("action = ? AND currency_code = ?", string(action), currency).
		Where("status IN ?", []string{string(models.ReservationStatusActive), string(models.ReservationStatusPendingApproval)}).
		Where("reserved_at >= ?", since).
		Where("subject_refs @> ?::jsonb", subjectMatch(subject)).
		Count(&count).Error
	return count, err
}

func (r *reservationRepository) PendingSumTx(
	ctx context.Context,
	tx *gorm.DB,
	action models.Action,
	currency string,
	subject SubjectFilter,
) (int64, error) {
	db := tx.WithContext(ctx)
	var sum int64
	err := db.Table(models.Reservation{}.TableName()).
		Where("action = ? AND currency_code = ?", string(action), currency).
		Where("status IN ?", []string{string(models.ReservationStatusActive), string(models.ReservationStatusPendingApproval)}).
		Where("ttl_at > ?", time.Now().UTC()).
		Where("subject_refs @> ?::jsonb", subjectMatch(subject)).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&sum).Error
	if err != nil {
		return 0, err
	}
	return sum, nil
}

func (r *reservationRepository) PendingCountTx(
	ctx context.Context,
	tx *gorm.DB,
	action models.Action,
	currency string,
	subject SubjectFilter,
	since time.Time,
) (int64, error) {
	db := tx.WithContext(ctx)
	var count int64
	err := db.Table(models.Reservation{}.TableName()).
		Where("action = ? AND currency_code = ?", string(action), currency).
		Where("status IN ?", []string{string(models.ReservationStatusActive), string(models.ReservationStatusPendingApproval)}).
		Where("reserved_at >= ?", since).
		Where("subject_refs @> ?::jsonb", subjectMatch(subject)).
		Count(&count).Error
	return count, err
}

// subjectMatch returns a JSON fragment suitable for the PostgreSQL jsonb @> operator.
func subjectMatch(s SubjectFilter) string {
	return `[{"type":"` + string(s.Type) + `","id":"` + s.ID + `"}]`
}

func (r *reservationRepository) SetCommitted(ctx context.Context, id string, at time.Time) error {
	db := r.dbPool.DB(ctx, false)
	res := db.Table(models.Reservation{}.TableName()).
		Where("id = ? AND status = ?", id, string(models.ReservationStatusActive)).
		Updates(map[string]any{
			colStatus:      string(models.ReservationStatusCommitted),
			"committed_at": at,
			colModifiedAt:  at,
		})
	if res.Error != nil {
		return res.Error
	}
	if res.RowsAffected == 0 {
		return errors.New("reservation: cannot commit (not active or missing)")
	}
	return nil
}

func (r *reservationRepository) SetCommittedTx(ctx context.Context, tx *gorm.DB, id string, at time.Time) error {
	res := tx.WithContext(ctx).
		Table(models.Reservation{}.TableName()).
		Where("id = ? AND status = ?", id, string(models.ReservationStatusActive)).
		Updates(map[string]any{
			colStatus:      string(models.ReservationStatusCommitted),
			"committed_at": at,
			colModifiedAt:  at,
		})
	if res.Error != nil {
		return res.Error
	}
	if res.RowsAffected == 0 {
		return errors.New("reservation: cannot commit (not active or wrong tenant)")
	}
	return nil
}

func (r *reservationRepository) SetReleased(ctx context.Context, id, reason string, at time.Time) error {
	db := r.dbPool.DB(ctx, false)
	res := db.Table(models.Reservation{}.TableName()).
		Where("id = ? AND status IN ?", id, []string{string(models.ReservationStatusActive), string(models.ReservationStatusPendingApproval)}).
		Updates(map[string]any{
			colStatus:     string(models.ReservationStatusReleased),
			"released_at": at,
			"notes":       reason,
			colModifiedAt: at,
		})
	if res.Error != nil {
		return res.Error
	}
	if res.RowsAffected == 0 {
		return errors.New("reservation: cannot release (terminal or missing)")
	}
	return nil
}

func (r *reservationRepository) SetReleasedTx(ctx context.Context, tx *gorm.DB, id, reason string, at time.Time) error {
	res := tx.WithContext(ctx).
		Table(models.Reservation{}.TableName()).
		Where("id = ? AND status IN ?", id, []string{string(models.ReservationStatusActive), string(models.ReservationStatusPendingApproval)}).
		Updates(map[string]any{
			colStatus:     string(models.ReservationStatusReleased),
			"released_at": at,
			"notes":       reason,
			colModifiedAt: at,
		})
	if res.Error != nil {
		return res.Error
	}
	if res.RowsAffected == 0 {
		return errors.New("reservation: cannot release (terminal, wrong tenant, or missing)")
	}
	return nil
}

func (r *reservationRepository) SetExpired(ctx context.Context, id string, at time.Time) error {
	db := r.dbPool.DB(ctx, false)
	return db.Table(models.Reservation{}.TableName()).
		Where("id = ? AND status = ?", id, string(models.ReservationStatusActive)).
		Updates(map[string]any{colStatus: string(models.ReservationStatusExpired), colModifiedAt: at}).Error
}

func (r *reservationRepository) BulkSetExpired(ctx context.Context, ids []string, at time.Time) (int, error) {
	if len(ids) == 0 {
		return 0, nil
	}
	// Cross-tenant: bypass RLS to match ListExpiredActive.
	ctx = tenancy.WithSkipEnforcement(ctx)
	res := r.dbPool.DB(ctx, false).
		Table(models.Reservation{}.TableName()).
		Where("id IN ? AND status = ?", ids, string(models.ReservationStatusActive)).
		Updates(map[string]any{
			colStatus:     string(models.ReservationStatusExpired),
			colModifiedAt: at,
		})
	return int(res.RowsAffected), res.Error
}

func (r *reservationRepository) SetReversed(ctx context.Context, id string, at time.Time) error {
	db := r.dbPool.DB(ctx, false)
	return db.Table(models.Reservation{}.TableName()).
		Where("id = ?", id).
		Updates(map[string]any{colStatus: string(models.ReservationStatusReversed), colModifiedAt: at}).Error
}

func (r *reservationRepository) SetReversedTx(ctx context.Context, tx *gorm.DB, id string, at time.Time) error {
	res := tx.WithContext(ctx).
		Table(models.Reservation{}.TableName()).
		Where("id = ? AND status = ?", id, string(models.ReservationStatusCommitted)).
		Updates(map[string]any{colStatus: string(models.ReservationStatusReversed), colModifiedAt: at})
	if res.Error != nil {
		return res.Error
	}
	if res.RowsAffected == 0 {
		return errors.New("reservation: cannot reverse (not committed, wrong tenant, or missing)")
	}
	return nil
}

func (r *reservationRepository) SetPendingApproval(ctx context.Context, id string) error {
	db := r.dbPool.DB(ctx, false)
	return db.Table(models.Reservation{}.TableName()).
		Where("id = ?", id).
		Updates(map[string]any{colStatus: string(models.ReservationStatusPendingApproval), colModifiedAt: time.Now().UTC()}).
		Error
}

func (r *reservationRepository) SetActive(ctx context.Context, id string) error {
	db := r.dbPool.DB(ctx, false)
	return db.Table(models.Reservation{}.TableName()).
		Where("id = ? AND status = ?", id, string(models.ReservationStatusPendingApproval)).
		Updates(map[string]any{colStatus: string(models.ReservationStatusActive), colModifiedAt: time.Now().UTC()}).
		Error
}

func (r *reservationRepository) SetActiveTx(ctx context.Context, tx *gorm.DB, id string) error {
	return tx.WithContext(ctx).
		Table(models.Reservation{}.TableName()).
		Where("id = ? AND status = ?", id, string(models.ReservationStatusPendingApproval)).
		Updates(map[string]any{colStatus: string(models.ReservationStatusActive), colModifiedAt: time.Now().UTC()}).
		Error
}

func (r *reservationRepository) HardDeleteTerminalBefore(ctx context.Context, cutoff time.Time) (int, error) {
	terminalStatuses := []string{
		string(models.ReservationStatusCommitted),
		string(models.ReservationStatusReleased),
		string(models.ReservationStatusReversed),
		string(models.ReservationStatusExpired),
	}
	total := 0
	// Cross-tenant: bypass RLS for terminal-row physical deletion.
	ctx = tenancy.WithSkipEnforcement(ctx)
	for {
		// Unscoped so GORM's soft-delete WHERE clause is bypassed; we physically
		// delete the rows.
		res := r.dbPool.DB(ctx, false).Unscoped().
			Where("status IN ? AND modified_at < ?", terminalStatuses, cutoff).
			Limit(hardDeleteBatchSize).
			Delete(&models.Reservation{})
		if res.Error != nil {
			return total, res.Error
		}
		total += int(res.RowsAffected)
		if res.RowsAffected < hardDeleteBatchSize {
			break
		}
	}
	return total, nil
}

func (r *reservationRepository) ListExpiredActive(
	ctx context.Context,
	before time.Time,
	limit int,
) ([]*models.Reservation, error) {
	if limit <= 0 {
		limit = 1000
	}
	// Reaper queries cross-tenant: bypass RLS tenancy enforcement.
	ctx = tenancy.WithSkipEnforcement(ctx)
	db := r.dbPool.DB(ctx, true)
	var rows []*models.Reservation
	err := db.Where("status = ? AND ttl_at < ?", string(models.ReservationStatusActive), before).
		Order("ttl_at ASC").
		Limit(limit).
		Find(&rows).Error
	return rows, err
}
