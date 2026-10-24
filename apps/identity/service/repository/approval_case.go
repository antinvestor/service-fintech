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

	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

// ErrApprovalCaseTransitionConflict reports that the conditional status update
// matched no row: another decision landed first, or the case was deleted.
var ErrApprovalCaseTransitionConflict = errors.New("approval case is no longer in the expected status")

// openApprovalCaseStatuses are the statuses a case can still be decided from.
//
//nolint:gochecknoglobals // static domain constant
var openApprovalCaseStatuses = []string{"pending_verification", "pending_approval"}

type ApprovalCaseRepository interface {
	datastore.BaseRepository[*models.ApprovalCase]
	GetOpenBySubject(
		ctx context.Context,
		subjectType, subjectID, caseType string,
	) (*models.ApprovalCase, error)
	// Transition applies a decision with `UPDATE ... WHERE id = ? AND status IN ?`
	// so only one of two concurrent decisions can win.
	Transition(
		ctx context.Context,
		approvalCase *models.ApprovalCase,
		fromStatuses []string,
	) error
}

type approvalCaseRepository struct {
	datastore.BaseRepository[*models.ApprovalCase]
}

func NewApprovalCaseRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) ApprovalCaseRepository {
	return &approvalCaseRepository{
		BaseRepository: datastore.NewBaseRepository[*models.ApprovalCase](
			ctx, dbPool, workMan, func() *models.ApprovalCase { return &models.ApprovalCase{} },
		),
	}
}

// Transition persists a decision conditionally on the status the caller read.
// A read-check-emit sequence let a concurrent approve and reject both land;
// the conditional update makes the loser observable instead.
func (r *approvalCaseRepository) Transition(
	ctx context.Context,
	approvalCase *models.ApprovalCase,
	fromStatuses []string,
) error {
	return r.Pool().DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		result := tx.WithContext(ctx).
			Table((&models.ApprovalCase{}).TableName()).
			Where("id = ? AND status IN ? AND deleted_at IS NULL", approvalCase.GetID(), fromStatuses).
			Updates(map[string]any{
				"status":      approvalCase.Status,
				"verified_by": approvalCase.VerifiedBy,
				colVerifiedAt: approvalCase.VerifiedAt,
				"approved_by": approvalCase.ApprovedBy,
				"approved_at": approvalCase.ApprovedAt,
				"rejected_by": approvalCase.RejectedBy,
				"rejected_at": approvalCase.RejectedAt,
				"comment":     approvalCase.Comment,
				colModifiedAt: time.Now().UTC(),
				colVersion:    gorm.Expr("version + 1"),
			})
		if result.Error != nil {
			return result.Error
		}
		if result.RowsAffected == 0 {
			return ErrApprovalCaseTransitionConflict
		}
		return nil
	})
}

// GetOpenBySubject returns the open case for a subject, if any.
func (r *approvalCaseRepository) GetOpenBySubject(
	ctx context.Context,
	subjectType, subjectID, caseType string,
) (*models.ApprovalCase, error) {
	approvalCase := &models.ApprovalCase{}
	err := r.Pool().DB(ctx, true).
		Where(
			"subject_type = ? AND subject_id = ? AND case_type = ? AND status IN ?",
			subjectType, subjectID, caseType, openApprovalCaseStatuses,
		).
		Order("created_at DESC").
		First(approvalCase).Error
	if err != nil {
		return nil, err
	}
	return approvalCase, nil
}
