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

package events

import (
	"context"
	"errors"

	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/upsert"
)

const RepaymentScheduleSaveEvent = "repayment_schedule.save"

type RepaymentScheduleSave struct {
	repaymentScheduleRepo repository.RepaymentScheduleRepository
}

func NewRepaymentScheduleSave(
	_ context.Context,
	repaymentScheduleRepo repository.RepaymentScheduleRepository,
) *RepaymentScheduleSave {
	return &RepaymentScheduleSave{repaymentScheduleRepo: repaymentScheduleRepo}
}

func (e *RepaymentScheduleSave) Name() string     { return RepaymentScheduleSaveEvent }
func (e *RepaymentScheduleSave) PayloadType() any { return &models.RepaymentSchedule{} }

func (e *RepaymentScheduleSave) Validate(_ context.Context, payload any) error {
	rs, ok := payload.(*models.RepaymentSchedule)
	if !ok {
		return errors.New("payload is not of type models.RepaymentSchedule")
	}
	if rs.GetID() == "" {
		return errors.New("repayment schedule ID should already have been set")
	}
	return nil
}

func (e *RepaymentScheduleSave) Execute(ctx context.Context, payload any) error {
	rs, ok := payload.(*models.RepaymentSchedule)
	if !ok {
		return errors.New("payload is not of type models.RepaymentSchedule")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "repayment_schedule_id": rs.GetID()})
	defer logger.Release()

	if err := upsert.ByID(ctx, e.repaymentScheduleRepo, rs); err != nil {
		logger.WithError(err).Error("could not persist repayment schedule")
		return err
	}
	// A loan has one active schedule, the newest, whichever save landed last.
	if err := e.repaymentScheduleRepo.KeepLatestActive(ctx, rs.LoanAccountID); err != nil {
		logger.WithError(err).Error("could not settle the loan's active schedule")
		return err
	}

	return nil
}
