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
	"maps"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
)

type LoanRestructureRepository interface {
	datastore.BaseRepository[*models.LoanRestructure]
	ClaimDecision(
		ctx context.Context, id string, toState int32, decidedBy, reason string, resumeStale bool,
	) (bool, error)
	ReleaseDecision(ctx context.Context, id string) error
	CompleteDecision(ctx context.Context, id, oldScheduleID, newScheduleID string) error
}

type loanRestructureRepository struct {
	datastore.BaseRepository[*models.LoanRestructure]
}

func NewLoanRestructureRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) LoanRestructureRepository {
	return &loanRestructureRepository{
		BaseRepository: datastore.NewBaseRepository[*models.LoanRestructure](
			ctx, dbPool, workMan, func() *models.LoanRestructure { return &models.LoanRestructure{} },
		),
	}
}

// restructureDecisionLease is how long an approval that is being applied
// holds the restructure before another approval may take it over.
const restructureDecisionLease = 5 * time.Minute

// ClaimDecision moves a pending restructure into toState for decidedBy, in
// one conditional statement, so two deciders cannot both act on it. With
// resumeStale, an approval left half applied (state CHECKED) for longer than
// the lease may be claimed again; a rejection never takes one over.
func (repo *loanRestructureRepository) ClaimDecision(
	ctx context.Context,
	id string,
	toState int32,
	decidedBy, reason string,
	resumeStale bool,
) (bool, error) {
	values := map[string]any{colState: toState, "approved_by": decidedBy}
	if reason != "" {
		values["reason"] = reason
	}
	payload := map[string]any{colModifiedAt: time.Now().UTC(), colVersion: gorm.Expr(colVersion + " + 1")}
	maps.Copy(payload, values)
	query := repo.Pool().DB(ctx, false).Table("loan_restructures")
	if resumeStale {
		query = query.Where("id = ? AND deleted_at IS NULL AND (state = ? OR (state = ? AND modified_at < ?))",
			id, int32(commonv1.STATE_CREATED), int32(commonv1.STATE_CHECKED),
			time.Now().UTC().Add(-restructureDecisionLease))
	} else {
		query = query.Where("id = ? AND deleted_at IS NULL AND state = ?", id, int32(commonv1.STATE_CREATED))
	}
	result := query.Updates(payload)
	return result.RowsAffected > 0, result.Error
}

// ReleaseDecision hands a restructure whose approval could not be applied
// back to pending.
func (repo *loanRestructureRepository) ReleaseDecision(ctx context.Context, id string) error {
	_, err := applyColumnUpdate(repo.Pool().DB(ctx, false), "loan_restructures", id, map[string]any{
		colState: int32(commonv1.STATE_CREATED), "approved_by": "",
	})
	return err
}

// CompleteDecision records an applied approval.
func (repo *loanRestructureRepository) CompleteDecision(
	ctx context.Context,
	id, oldScheduleID, newScheduleID string,
) error {
	_, err := applyColumnUpdate(repo.Pool().DB(ctx, false), "loan_restructures", id, map[string]any{
		colState:          int32(commonv1.STATE_ACTIVE),
		"old_schedule_id": oldScheduleID,
		"new_schedule_id": newScheduleID,
	})
	return err
}
