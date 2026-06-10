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

package events //nolint:dupl // similar event handlers for different entity types

import (
	"context"
	"errors"

	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
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

	existing, getErr := e.repaymentScheduleRepo.GetByID(ctx, rs.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.repaymentScheduleRepo.Update(ctx, rs); err != nil {
			logger.WithError(err).Error("could not update repayment schedule in db")
			return err
		}
		return nil
	}

	if err := e.repaymentScheduleRepo.Create(ctx, rs); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create repayment schedule in db")
		return err
	}

	return nil
}
