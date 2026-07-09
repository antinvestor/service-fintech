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

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

type ApprovalCaseRepository interface {
	datastore.BaseRepository[*models.ApprovalCase]
	GetOpenBySubject(
		ctx context.Context,
		subjectType, subjectID, caseType string,
	) (*models.ApprovalCase, error)
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

func (r *approvalCaseRepository) GetOpenBySubject(
	ctx context.Context,
	subjectType, subjectID, caseType string,
) (*models.ApprovalCase, error) {
	approvalCase := &models.ApprovalCase{}
	err := r.Pool().DB(ctx, true).
		Where(
			"subject_type = ? AND subject_id = ? AND case_type = ? AND status IN ?",
			subjectType, subjectID, caseType, []string{"pending_verification", "pending_approval"},
		).
		Order("created_at DESC").
		First(approvalCase).Error
	if err != nil {
		return nil, err
	}
	return approvalCase, nil
}
