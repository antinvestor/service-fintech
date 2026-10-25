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

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

type LoanAccountRepository interface {
	datastore.BaseRepository[*models.LoanAccount]
	// GetByLoanRequestID resolves the single loan account created for a loan
	// request. It is what makes LoanAccountCreate idempotent.
	GetByLoanRequestID(ctx context.Context, loanRequestID string) (*models.LoanAccount, error)
	// UpdateColumns writes only the named columns, leaving every other column
	// as the database holds it. Whole-entity writes over an asynchronous
	// event queue lose concurrent updates; targeted writes do not.
	UpdateColumns(ctx context.Context, id string, values map[string]any) (int64, error)
	// ClaimStatus moves a loan account from one status to another only if it
	// still holds fromStatus, reporting whether the claim succeeded.
	ClaimStatus(ctx context.Context, id string, fromStatus, toStatus int32) (bool, error)
	// PageByStatus walks the loans in a status in id order, starting after
	// afterID. Keyset paging rather than offset paging, because a scan that
	// changes the status it is iterating over would otherwise shift rows
	// under the offset and skip loans entirely.
	PageByStatus(ctx context.Context, status int32, afterID string, limit int) ([]*models.LoanAccount, error)
	// ClaimForAssessment leases up to limit loans due for a delinquency
	// assessment and pushes each one's next assessment a day ahead.
	// Concurrent callers never receive the same loan.
	ClaimForAssessment(ctx context.Context, limit int) ([]*models.LoanAccount, error)
	// AssessSoon brings a loan's next delinquency assessment forward to now,
	// so a repayment that clears arrears is reflected on the next run.
	AssessSoon(ctx context.Context, loanAccountID string) error
	// ClaimRepaymentLock takes the loan's repayment lease, so repayments on
	// one loan are allocated one at a time. A lease older than the timeout is
	// taken over, so a crashed holder never blocks the loan for long.
	ClaimRepaymentLock(ctx context.Context, loanAccountID string) (bool, error)
	// ReleaseRepaymentLock gives the lease back.
	ReleaseRepaymentLock(ctx context.Context, loanAccountID string) error
}

type loanAccountRepository struct {
	datastore.BaseRepository[*models.LoanAccount]
}

func NewLoanAccountRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) LoanAccountRepository {
	return &loanAccountRepository{
		BaseRepository: datastore.NewBaseRepository[*models.LoanAccount](
			ctx, dbPool, workMan, func() *models.LoanAccount { return &models.LoanAccount{} },
		),
	}
}

func (repo *loanAccountRepository) GetByLoanRequestID(
	ctx context.Context,
	loanRequestID string,
) (*models.LoanAccount, error) {
	la := models.LoanAccount{}
	err := repo.Pool().DB(ctx, true).
		First(&la, "loan_request_id = ?", loanRequestID).Error
	if err != nil {
		return nil, err
	}
	return &la, nil
}

func (repo *loanAccountRepository) UpdateColumns(
	ctx context.Context,
	id string,
	values map[string]any,
) (int64, error) {
	return applyColumnUpdate(repo.Pool().DB(ctx, false), "loan_accounts", id, values)
}

func (repo *loanAccountRepository) ClaimStatus(
	ctx context.Context,
	id string,
	fromStatus, toStatus int32,
) (bool, error) {
	result := repo.Pool().DB(ctx, false).
		Table("loan_accounts").
		Where("id = ? AND status = ? AND deleted_at IS NULL", id, fromStatus).
		Updates(map[string]any{
			colStatus:     toStatus,
			colModifiedAt: time.Now().UTC(),
			colVersion:    gorm.Expr(colVersion + " + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (repo *loanAccountRepository) PageByStatus(
	ctx context.Context,
	status int32,
	afterID string,
	limit int,
) ([]*models.LoanAccount, error) {
	var accounts []*models.LoanAccount

	query := repo.Pool().DB(ctx, true).
		Where("status = ?", status).
		Order("id ASC").
		Limit(limit)
	if afterID != "" {
		query = query.Where("id > ?", afterID)
	}

	if err := query.Find(&accounts).Error; err != nil {
		return nil, err
	}
	return accounts, nil
}

// ClaimForAssessment claims through FOR UPDATE SKIP LOCKED on the
// idx_la_assessment_due index. The claim is the schedule: a loan whose
// assessment fails is looked at again the next day.
func (repo *loanAccountRepository) ClaimForAssessment(ctx context.Context, limit int) ([]*models.LoanAccount, error) {
	var rows []*models.LoanAccount
	err := repo.Pool().DB(ctx, false).Raw(`
UPDATE loan_accounts SET next_assessment_at = now() + interval '1 day'
WHERE id IN (
    SELECT id FROM loan_accounts
    WHERE status IN (2, 3, 6) AND deleted_at IS NULL AND next_assessment_at <= now()
    ORDER BY next_assessment_at
    LIMIT ?
    FOR UPDATE SKIP LOCKED
)
RETURNING *`, limit).Scan(&rows).Error
	return rows, err
}

func (repo *loanAccountRepository) AssessSoon(ctx context.Context, loanAccountID string) error {
	return repo.Pool().DB(ctx, false).
		Table("loan_accounts").
		Where("id = ? AND deleted_at IS NULL", loanAccountID).
		Update("next_assessment_at", gorm.Expr("now()")).Error
}

// repaymentLockLease bounds how long a repayment may hold its loan.
const repaymentLockLeaseSeconds = 120

func (repo *loanAccountRepository) ClaimRepaymentLock(ctx context.Context, loanAccountID string) (bool, error) {
	result := repo.Pool().DB(ctx, false).Exec(`UPDATE loan_accounts SET repayment_locked_at = now()
WHERE id = ? AND deleted_at IS NULL
  AND (repayment_locked_at IS NULL OR repayment_locked_at < now() - make_interval(secs => ?))`,
		loanAccountID, repaymentLockLeaseSeconds)
	return result.RowsAffected > 0, result.Error
}

func (repo *loanAccountRepository) ReleaseRepaymentLock(ctx context.Context, loanAccountID string) error {
	return repo.Pool().DB(ctx, false).Exec(
		`UPDATE loan_accounts SET repayment_locked_at = NULL WHERE id = ?`, loanAccountID).Error
}
