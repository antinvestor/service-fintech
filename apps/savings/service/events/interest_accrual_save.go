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

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"
)

const InterestAccrualSaveEvent = "interest_accrual.save"

type InterestAccrualSave struct {
	repo repository.InterestAccrualRepository
}

func NewInterestAccrualSave(_ context.Context, repo repository.InterestAccrualRepository) *InterestAccrualSave {
	return &InterestAccrualSave{repo: repo}
}

func (e *InterestAccrualSave) Name() string     { return InterestAccrualSaveEvent }
func (e *InterestAccrualSave) PayloadType() any { return &models.InterestAccrual{} }

func (e *InterestAccrualSave) Validate(_ context.Context, payload any) error {
	ia, ok := payload.(*models.InterestAccrual)
	if !ok {
		return errors.New("payload is not of type models.InterestAccrual")
	}
	if ia.GetID() == "" {
		return errors.New("interest accrual ID should already have been set")
	}
	return nil
}

func (e *InterestAccrualSave) Execute(ctx context.Context, payload any) error {
	ia, ok := payload.(*models.InterestAccrual)
	if !ok {
		return errors.New("payload is not of type models.InterestAccrual")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "interest_accrual_id": ia.GetID()})
	defer logger.Release()

	existing, getErr := e.repo.GetByID(ctx, ia.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.repo.Update(ctx, ia); err != nil {
			logger.WithError(err).Error("could not update interest accrual in db")
			return err
		}
		return nil
	}

	if err := e.repo.Create(ctx, ia); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create interest accrual in db")
		return err
	}

	return nil
}
