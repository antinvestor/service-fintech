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

	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
)

type SavingsAccountRepository interface {
	datastore.BaseRepository[*models.SavingsAccount]

	// ListDueForInterest returns up to limit active accounts whose interest
	// is not settled through periodEnd and that were not tried since
	// checkedBefore.
	ListDueForInterest(
		ctx context.Context,
		periodEnd, checkedBefore time.Time,
		limit int,
	) ([]*models.SavingsAccount, error)

	// MarkInterestChecked records a try on the account; with settled, its
	// interest counts as settled through periodEnd.
	MarkInterestChecked(ctx context.Context, id string, periodEnd time.Time, settled bool) error
}

type savingsAccountRepository struct {
	datastore.BaseRepository[*models.SavingsAccount]
}

func NewSavingsAccountRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) SavingsAccountRepository {
	return &savingsAccountRepository{
		BaseRepository: datastore.NewBaseRepository[*models.SavingsAccount](
			ctx, dbPool, workMan, func() *models.SavingsAccount { return &models.SavingsAccount{} },
		),
	}
}

func (r *savingsAccountRepository) ListDueForInterest(
	ctx context.Context,
	periodEnd, checkedBefore time.Time,
	limit int,
) ([]*models.SavingsAccount, error) {
	var out []*models.SavingsAccount
	err := r.Pool().DB(ctx, true).
		Where("deleted_at IS NULL AND status = ?", int32(savingsv1.SavingsAccountStatus_SAVINGS_ACCOUNT_STATUS_ACTIVE)).
		Where("interest_accrued_through IS NULL OR interest_accrued_through < ?", periodEnd.UTC()).
		Where("interest_checked_at IS NULL OR interest_checked_at < ?", checkedBefore.UTC()).
		Order("interest_checked_at NULLS FIRST, id").
		Limit(limit).
		Find(&out).Error
	return out, err
}

func (r *savingsAccountRepository) MarkInterestChecked(
	ctx context.Context,
	id string,
	periodEnd time.Time,
	settled bool,
) error {
	values := map[string]any{"interest_checked_at": time.Now().UTC()}
	if settled {
		values["interest_accrued_through"] = periodEnd.UTC()
	}
	return r.Pool().DB(ctx, false).Table("savings_accounts").
		Where("id = ? AND deleted_at IS NULL", id).Updates(values).Error
}
