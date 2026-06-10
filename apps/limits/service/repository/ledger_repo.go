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

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/tenancy"
	"github.com/pitabwire/frame/workerpool"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
)

type LedgerRepository interface {
	CreateBatch(ctx context.Context, entries []*models.LedgerEntry) error
	WindowSum(
		ctx context.Context,
		action models.Action,
		currency string,
		subject SubjectFilter,
		since time.Time,
	) (int64, error)
	// WindowSumTx is identical to WindowSum but executes within the supplied
	// gorm transaction, ensuring the read participates in the caller's tx
	// and therefore observes the advisory lock acquired by Reserve.
	WindowSumTx(
		ctx context.Context,
		tx *gorm.DB,
		action models.Action,
		currency string,
		subject SubjectFilter,
		since time.Time,
	) (int64, error)
	WindowCount(
		ctx context.Context,
		action models.Action,
		currency string,
		subject SubjectFilter,
		since time.Time,
	) (int64, error)
	// WindowCountTx is identical to WindowCount but executes within the supplied
	// gorm transaction, ensuring the read participates in the caller's tx
	// and therefore observes the advisory lock acquired by Reserve.
	WindowCountTx(
		ctx context.Context,
		tx *gorm.DB,
		action models.Action,
		currency string,
		subject SubjectFilter,
		since time.Time,
	) (int64, error)
	MarkReversed(ctx context.Context, reservationID string, at time.Time) error
	Search(ctx context.Context, f LedgerSearchFilter, limit int, cursor string) (*LedgerSearchResult, error)
	// HardDeleteBefore permanently deletes ledger entries whose committed_at
	// is older than cutoff. Processes in batches of 1000. Cross-tenant.
	// Returns total rows deleted.
	HardDeleteBefore(ctx context.Context, cutoff time.Time) (int, error)
}

type LedgerSearchFilter struct {
	Action       models.Action
	SubjectType  models.Subject
	SubjectID    string
	CurrencyCode string
	From         time.Time
	To           time.Time
}

type LedgerSearchResult struct {
	Items      []*models.LedgerEntry
	NextCursor string
}

type ledgerRepository struct {
	datastore.BaseRepository[*models.LedgerEntry]
	dbPool pool.Pool
}

func NewLedgerRepository(ctx context.Context, p pool.Pool, workMan workerpool.Manager) LedgerRepository {
	r := &ledgerRepository{dbPool: p}
	r.BaseRepository = datastore.NewBaseRepository[*models.LedgerEntry](
		ctx, p, workMan,
		func() *models.LedgerEntry { return &models.LedgerEntry{} },
	)
	return r
}

func (r *ledgerRepository) CreateBatch(ctx context.Context, entries []*models.LedgerEntry) error {
	for _, e := range entries {
		if e.ID == "" {
			e.ID = util.IDString()
		}
	}
	db := r.dbPool.DB(ctx, false)
	return db.Create(&entries).Error
}

func (r *ledgerRepository) WindowSum(
	ctx context.Context,
	action models.Action,
	currency string,
	subject SubjectFilter,
	since time.Time,
) (int64, error) {
	db := r.dbPool.DB(ctx, true)
	var sum int64
	err := db.Table(models.LedgerEntry{}.TableName()).
		Where("action = ? AND currency_code = ? AND subject_type = ? AND subject_id = ?",
			string(action), currency, string(subject.Type), subject.ID).
		Where("committed_at >= ? AND reversed_at IS NULL", since).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&sum).Error
	return sum, err
}

func (r *ledgerRepository) WindowSumTx(
	ctx context.Context,
	tx *gorm.DB,
	action models.Action,
	currency string,
	subject SubjectFilter,
	since time.Time,
) (int64, error) {
	db := tx.WithContext(ctx)
	var sum int64
	err := db.Table(models.LedgerEntry{}.TableName()).
		Where("action = ? AND currency_code = ? AND subject_type = ? AND subject_id = ?",
			string(action), currency, string(subject.Type), subject.ID).
		Where("committed_at >= ? AND reversed_at IS NULL", since).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&sum).Error
	return sum, err
}

func (r *ledgerRepository) WindowCount(
	ctx context.Context,
	action models.Action,
	currency string,
	subject SubjectFilter,
	since time.Time,
) (int64, error) {
	db := r.dbPool.DB(ctx, true)
	var count int64
	err := db.Table(models.LedgerEntry{}.TableName()).
		Where("action = ? AND currency_code = ? AND subject_type = ? AND subject_id = ?",
			string(action), currency, string(subject.Type), subject.ID).
		Where("committed_at >= ? AND reversed_at IS NULL", since).
		Count(&count).Error
	return count, err
}

func (r *ledgerRepository) WindowCountTx(
	ctx context.Context,
	tx *gorm.DB,
	action models.Action,
	currency string,
	subject SubjectFilter,
	since time.Time,
) (int64, error) {
	db := tx.WithContext(ctx)
	var count int64
	err := db.Table(models.LedgerEntry{}.TableName()).
		Where("action = ? AND currency_code = ? AND subject_type = ? AND subject_id = ?",
			string(action), currency, string(subject.Type), subject.ID).
		Where("committed_at >= ? AND reversed_at IS NULL", since).
		Count(&count).Error
	return count, err
}

func (r *ledgerRepository) MarkReversed(ctx context.Context, reservationID string, at time.Time) error {
	db := r.dbPool.DB(ctx, false)
	return db.Table(models.LedgerEntry{}.TableName()).
		Where("reservation_id = ? AND reversed_at IS NULL", reservationID).
		Update("reversed_at", at).Error
}

func (r *ledgerRepository) HardDeleteBefore(ctx context.Context, cutoff time.Time) (int, error) {
	total := 0
	// Cross-tenant cleanup: bypass RLS tenancy enforcement.
	ctx = tenancy.WithSkipEnforcement(ctx)
	for {
		res := r.dbPool.DB(ctx, false).Unscoped().
			Where("committed_at < ?", cutoff).
			Limit(hardDeleteBatchSize).
			Delete(&models.LedgerEntry{})
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

func (r *ledgerRepository) Search(
	ctx context.Context,
	f LedgerSearchFilter,
	limit int,
	cursor string,
) (*LedgerSearchResult, error) {
	if limit <= 0 {
		limit = 50
	}
	db := r.dbPool.DB(ctx, true).
		Table(models.LedgerEntry{}.TableName()).
		Where("deleted_at IS NULL")
	if f.Action != "" {
		db = db.Where("action = ?", string(f.Action))
	}
	if f.SubjectType != "" {
		db = db.Where("subject_type = ?", string(f.SubjectType))
	}
	if f.SubjectID != "" {
		db = db.Where("subject_id = ?", f.SubjectID)
	}
	if f.CurrencyCode != "" {
		db = db.Where("currency_code = ?", f.CurrencyCode)
	}
	if !f.From.IsZero() {
		db = db.Where("committed_at >= ?", f.From)
	}
	if !f.To.IsZero() {
		db = db.Where("committed_at < ?", f.To)
	}
	if cursor != "" {
		db = db.Where("id > ?", cursor)
	}
	var rows []*models.LedgerEntry
	if err := db.Order("id ASC").Limit(limit + 1).Find(&rows).Error; err != nil {
		return nil, err
	}
	out := &LedgerSearchResult{}
	if len(rows) > limit {
		out.NextCursor = rows[limit-1].ID
		rows = rows[:limit]
	}
	out.Items = rows
	return out, nil
}
