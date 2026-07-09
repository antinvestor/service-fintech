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

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"
)

const SavingsAccountSaveEvent = "savings_account.save"

type SavingsAccountSave struct {
	repo repository.SavingsAccountRepository
}

func NewSavingsAccountSave(_ context.Context, repo repository.SavingsAccountRepository) *SavingsAccountSave {
	return &SavingsAccountSave{repo: repo}
}

func (e *SavingsAccountSave) Name() string     { return SavingsAccountSaveEvent }
func (e *SavingsAccountSave) PayloadType() any { return &models.SavingsAccount{} }

func (e *SavingsAccountSave) Validate(_ context.Context, payload any) error {
	sa, ok := payload.(*models.SavingsAccount)
	if !ok {
		return errors.New("payload is not of type models.SavingsAccount")
	}
	if sa.GetID() == "" {
		return errors.New("savings account ID should already have been set")
	}
	return nil
}

func (e *SavingsAccountSave) Execute(ctx context.Context, payload any) error {
	sa, ok := payload.(*models.SavingsAccount)
	if !ok {
		return errors.New("payload is not of type models.SavingsAccount")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "savings_account_id": sa.GetID()})
	defer logger.Release()

	existing, getErr := e.repo.GetByID(ctx, sa.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.repo.Update(ctx, sa); err != nil {
			logger.WithError(err).Error("could not update savings account in db")
			return err
		}
		return nil
	}

	if err := e.repo.Create(ctx, sa); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create savings account in db")
		return err
	}

	return nil
}
