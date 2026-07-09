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

const WithdrawalSaveEvent = "withdrawal.save"

type WithdrawalSave struct {
	repo repository.WithdrawalRepository
}

func NewWithdrawalSave(_ context.Context, repo repository.WithdrawalRepository) *WithdrawalSave {
	return &WithdrawalSave{repo: repo}
}

func (e *WithdrawalSave) Name() string     { return WithdrawalSaveEvent }
func (e *WithdrawalSave) PayloadType() any { return &models.Withdrawal{} }

func (e *WithdrawalSave) Validate(_ context.Context, payload any) error {
	w, ok := payload.(*models.Withdrawal)
	if !ok {
		return errors.New("payload is not of type models.Withdrawal")
	}
	if w.GetID() == "" {
		return errors.New("withdrawal ID should already have been set")
	}
	return nil
}

func (e *WithdrawalSave) Execute(ctx context.Context, payload any) error {
	w, ok := payload.(*models.Withdrawal)
	if !ok {
		return errors.New("payload is not of type models.Withdrawal")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "withdrawal_id": w.GetID()})
	defer logger.Release()

	existing, getErr := e.repo.GetByID(ctx, w.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.repo.Update(ctx, w); err != nil {
			logger.WithError(err).Error("could not update withdrawal in db")
			return err
		}
		return nil
	}

	if err := e.repo.Create(ctx, w); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create withdrawal in db")
		return err
	}

	return nil
}
