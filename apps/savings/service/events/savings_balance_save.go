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

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"
)

const SavingsBalanceSaveEvent = "savings_balance.save"

// SavingsBalanceSave persists savings balance initialisation events. Runtime
// mutations to the balance (Credit / Reserve / DebitReserved / ReleaseReserved)
// go through the repository's atomic SQL path directly, not through this
// handler, so here we only handle the initial zero-row provisioning that
// happens when a savings account is created.
type SavingsBalanceSave struct {
	repo repository.SavingsBalanceRepository
}

func NewSavingsBalanceSave(_ context.Context, repo repository.SavingsBalanceRepository) *SavingsBalanceSave {
	return &SavingsBalanceSave{repo: repo}
}

func (e *SavingsBalanceSave) Name() string     { return SavingsBalanceSaveEvent }
func (e *SavingsBalanceSave) PayloadType() any { return &models.SavingsBalance{} }

func (e *SavingsBalanceSave) Validate(_ context.Context, payload any) error {
	sb, ok := payload.(*models.SavingsBalance)
	if !ok {
		return errors.New("payload is not of type models.SavingsBalance")
	}
	if sb.GetID() == "" {
		return errors.New("savings balance ID should already have been set")
	}
	if sb.SavingsAccountID == "" {
		return errors.New("savings balance requires a savings_account_id")
	}
	return nil
}

func (e *SavingsBalanceSave) Execute(ctx context.Context, payload any) error {
	sb, ok := payload.(*models.SavingsBalance)
	if !ok {
		return errors.New("payload is not of type models.SavingsBalance")
	}

	logger := util.Log(ctx).WithFields(map[string]any{
		logFieldType:         e.Name(),
		"savings_balance_id": sb.GetID(),
		"savings_account_id": sb.SavingsAccountID,
	})
	defer logger.Release()

	existing, getErr := e.repo.GetByID(ctx, sb.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.repo.Update(ctx, sb); err != nil {
			logger.WithError(err).Error("could not update savings balance in db")
			return err
		}
		return nil
	}

	if err := e.repo.Create(ctx, sb); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create savings balance in db")
		return err
	}

	return nil
}
