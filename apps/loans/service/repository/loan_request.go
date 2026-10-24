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

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

type LoanRequestRepository interface {
	datastore.BaseRepository[*models.LoanRequest]
	GetByIdempotencyKey(ctx context.Context, key string) (*models.LoanRequest, error)
	GetByLoanAccountID(ctx context.Context, loanAccountID string) (*models.LoanRequest, error)
	// ClaimForLoanCreation moves an APPROVED request to LOAN_CREATED and
	// stamps the loan account onto it, in one conditional statement. Only the
	// first caller wins, which is what stops a second LoanAccountCreate from
	// reserving funding twice.
	ClaimForLoanCreation(ctx context.Context, requestID, loanAccountID string) (bool, error)
	// ReleaseLoanCreationClaim puts a claimed request back to APPROVED when
	// the loan it was claimed for could not be written, so the request can be
	// retried instead of being stranded pointing at an account that does not
	// exist.
	ReleaseLoanCreationClaim(ctx context.Context, requestID, loanAccountID string) error
	// ClaimStatus is the conditional write behind every request decision.
	ClaimStatus(
		ctx context.Context,
		requestID string,
		fromStatuses []int32,
		toStatus int32,
		values map[string]any,
	) (bool, error)
}

type loanRequestRepository struct {
	datastore.BaseRepository[*models.LoanRequest]
}

func NewLoanRequestRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) LoanRequestRepository {
	return &loanRequestRepository{
		BaseRepository: datastore.NewBaseRepository[*models.LoanRequest](
			ctx, dbPool, workMan, func() *models.LoanRequest { return &models.LoanRequest{} },
		),
	}
}

func (repo *loanRequestRepository) GetByIdempotencyKey(
	ctx context.Context,
	key string,
) (*models.LoanRequest, error) {
	lr := models.LoanRequest{}
	err := repo.Pool().DB(ctx, true).
		First(&lr, "idempotency_key = ?", key).Error
	if err != nil {
		return nil, err
	}
	return &lr, nil
}

func (repo *loanRequestRepository) GetByLoanAccountID(
	ctx context.Context,
	loanAccountID string,
) (*models.LoanRequest, error) {
	lr := models.LoanRequest{}
	err := repo.Pool().DB(ctx, true).
		First(&lr, "loan_account_id = ?", loanAccountID).Error
	if err != nil {
		return nil, err
	}
	return &lr, nil
}

// ClaimStatus moves a request out of one of fromStatuses into toStatus and
// writes values in the same conditional UPDATE. It reports whether this
// caller won; a loser read a status that has since changed.
func (repo *loanRequestRepository) ClaimStatus(
	ctx context.Context,
	requestID string,
	fromStatuses []int32,
	toStatus int32,
	values map[string]any,
) (bool, error) {
	payload := map[string]any{
		colStatus:     toStatus,
		colModifiedAt: time.Now().UTC(),
		colVersion:    gorm.Expr(colVersion + " + 1"),
	}
	for k, v := range values {
		payload[k] = v
	}
	result := repo.Pool().DB(ctx, false).
		Table("loan_requests").
		Where("id = ? AND status IN ? AND deleted_at IS NULL", requestID, fromStatuses).
		Updates(payload)
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (repo *loanRequestRepository) ClaimForLoanCreation(
	ctx context.Context,
	requestID, loanAccountID string,
) (bool, error) {
	result := repo.Pool().DB(ctx, false).
		Table("loan_requests").
		Where("id = ? AND status = ? AND deleted_at IS NULL", requestID,
			int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED)).
		Updates(map[string]any{
			colStatus:         int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_LOAN_CREATED),
			"loan_account_id": loanAccountID,
			colModifiedAt:     time.Now().UTC(),
			colVersion:        gorm.Expr(colVersion + " + 1"),
		})
	if result.Error != nil {
		return false, result.Error
	}
	return result.RowsAffected > 0, nil
}

func (repo *loanRequestRepository) ReleaseLoanCreationClaim(
	ctx context.Context,
	requestID, loanAccountID string,
) error {
	return repo.Pool().DB(ctx, false).
		Table("loan_requests").
		Where("id = ? AND status = ? AND loan_account_id = ? AND deleted_at IS NULL", requestID,
			int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_LOAN_CREATED), loanAccountID).
		Updates(map[string]any{
			colStatus:         int32(loansv1.LoanRequestStatus_LOAN_REQUEST_STATUS_APPROVED),
			"loan_account_id": "",
			colModifiedAt:     time.Now().UTC(),
			colVersion:        gorm.Expr(colVersion + " + 1"),
		}).Error
}
