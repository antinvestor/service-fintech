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
	"gorm.io/gorm"
)

// ErrBalanceGuardViolated is returned when a balance mutation inside a
// settlement transaction matched no row because its SQL guard failed.
var ErrBalanceGuardViolated = errors.New("balance guard rejected the mutation")

// claimRow inserts entity and, when the insert loses to an existing row on a
// unique index, re-reads that row through reread. created reports whether
// this call performed the insert.
func claimRow[T any](
	ctx context.Context,
	db *gorm.DB,
	entity *T,
	reread func(ctx context.Context) (*T, error),
) (*T, bool, error) {
	err := db.Create(entity).Error
	if err == nil {
		return entity, true, nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return nil, false, err
	}
	existing, rereadErr := reread(ctx)
	if rereadErr != nil {
		return nil, false, err
	}
	return existing, false, nil
}

// balanceUpdate applies a guarded arithmetic update to the balance row inside
// tx and reports ErrBalanceGuardViolated when the guard matched nothing.
func balanceUpdate(tx *gorm.DB, savingsAccountID, guard string, guardArgs []any, values map[string]any) error {
	values[colModifiedAt] = time.Now().UTC()
	values[colVersion] = gorm.Expr("version + 1")

	where := []any{savingsAccountID}
	where = append(where, guardArgs...)

	res := tx.Table("savings_balances").
		Where("savings_account_id = ? AND deleted_at IS NULL"+guard, where...).
		Updates(values)
	if res.Error != nil {
		return res.Error
	}
	if res.RowsAffected == 0 {
		return ErrBalanceGuardViolated
	}
	return nil
}
