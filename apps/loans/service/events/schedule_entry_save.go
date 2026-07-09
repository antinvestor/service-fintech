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

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

const ScheduleEntrySaveEvent = "schedule_entry.save"

type ScheduleEntrySave struct {
	scheduleEntryRepo repository.ScheduleEntryRepository
}

func NewScheduleEntrySave(_ context.Context, scheduleEntryRepo repository.ScheduleEntryRepository) *ScheduleEntrySave {
	return &ScheduleEntrySave{scheduleEntryRepo: scheduleEntryRepo}
}

func (e *ScheduleEntrySave) Name() string     { return ScheduleEntrySaveEvent }
func (e *ScheduleEntrySave) PayloadType() any { return &models.ScheduleEntry{} }

func (e *ScheduleEntrySave) Validate(_ context.Context, payload any) error {
	se, ok := payload.(*models.ScheduleEntry)
	if !ok {
		return errors.New("payload is not of type models.ScheduleEntry")
	}
	if se.GetID() == "" {
		return errors.New("schedule entry ID should already have been set")
	}
	return nil
}

func (e *ScheduleEntrySave) Execute(ctx context.Context, payload any) error {
	se, ok := payload.(*models.ScheduleEntry)
	if !ok {
		return errors.New("payload is not of type models.ScheduleEntry")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "schedule_entry_id": se.GetID()})
	defer logger.Release()

	existing, getErr := e.scheduleEntryRepo.GetByID(ctx, se.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.scheduleEntryRepo.Update(ctx, se); err != nil {
			logger.WithError(err).Error("could not update schedule entry in db")
			return err
		}
		return nil
	}

	if err := e.scheduleEntryRepo.Create(ctx, se); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create schedule entry in db")
		return err
	}

	return nil
}
