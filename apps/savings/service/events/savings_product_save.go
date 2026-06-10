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

const SavingsProductSaveEvent = "savings_product.save"

type SavingsProductSave struct {
	repo repository.SavingsProductRepository
}

func NewSavingsProductSave(_ context.Context, repo repository.SavingsProductRepository) *SavingsProductSave {
	return &SavingsProductSave{repo: repo}
}

func (e *SavingsProductSave) Name() string     { return SavingsProductSaveEvent }
func (e *SavingsProductSave) PayloadType() any { return &models.SavingsProduct{} }

func (e *SavingsProductSave) Validate(_ context.Context, payload any) error {
	sp, ok := payload.(*models.SavingsProduct)
	if !ok {
		return errors.New("payload is not of type models.SavingsProduct")
	}
	if sp.GetID() == "" {
		return errors.New("savings product ID should already have been set")
	}
	return nil
}

func (e *SavingsProductSave) Execute(ctx context.Context, payload any) error {
	sp, ok := payload.(*models.SavingsProduct)
	if !ok {
		return errors.New("payload is not of type models.SavingsProduct")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "savings_product_id": sp.GetID()})
	defer logger.Release()

	existing, getErr := e.repo.GetByID(ctx, sp.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.repo.Update(ctx, sp); err != nil {
			logger.WithError(err).Error("could not update savings product in db")
			return err
		}
		return nil
	}

	if err := e.repo.Create(ctx, sp); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create savings product in db")
		return err
	}

	return nil
}
