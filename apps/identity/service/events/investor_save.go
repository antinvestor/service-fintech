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

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

const InvestorSaveEvent = "investor.save"

type InvestorSave struct {
	investorRepo repository.InvestorRepository
}

func NewInvestorSave(_ context.Context, investorRepo repository.InvestorRepository) *InvestorSave {
	return &InvestorSave{investorRepo: investorRepo}
}

func (e *InvestorSave) Name() string     { return InvestorSaveEvent }
func (e *InvestorSave) PayloadType() any { return &models.Investor{} }

func (e *InvestorSave) Validate(_ context.Context, payload any) error {
	investor, ok := payload.(*models.Investor)
	if !ok {
		return errors.New("payload is not of type models.Investor")
	}
	if investor.GetID() == "" {
		return errors.New("investor ID should already have been set")
	}
	return nil
}

func (e *InvestorSave) Execute(ctx context.Context, payload any) error {
	investor, ok := payload.(*models.Investor)
	if !ok {
		return errors.New("payload is not of type models.Investor")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "investor_id": investor.GetID()})
	defer logger.Release()

	existing, getErr := e.investorRepo.GetByID(ctx, investor.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.investorRepo.Update(ctx, investor); err != nil {
			logger.WithError(err).Error("could not update investor in db")
			return err
		}
		return nil
	}

	if err := e.investorRepo.Create(ctx, investor); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create investor in db")
		return err
	}

	return nil
}
