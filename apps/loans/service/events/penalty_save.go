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

const PenaltySaveEvent = "penalty.save"

type PenaltySave struct {
	penaltyRepo repository.PenaltyRepository
}

func NewPenaltySave(_ context.Context, penaltyRepo repository.PenaltyRepository) *PenaltySave {
	return &PenaltySave{penaltyRepo: penaltyRepo}
}

func (e *PenaltySave) Name() string     { return PenaltySaveEvent }
func (e *PenaltySave) PayloadType() any { return &models.Penalty{} }

func (e *PenaltySave) Validate(_ context.Context, payload any) error {
	p, ok := payload.(*models.Penalty)
	if !ok {
		return errors.New("payload is not of type models.Penalty")
	}
	if p.GetID() == "" {
		return errors.New("penalty ID should already have been set")
	}
	return nil
}

func (e *PenaltySave) Execute(ctx context.Context, payload any) error {
	p, ok := payload.(*models.Penalty)
	if !ok {
		return errors.New("payload is not of type models.Penalty")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "penalty_id": p.GetID()})
	defer logger.Release()

	existing, getErr := e.penaltyRepo.GetByID(ctx, p.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.penaltyRepo.Update(ctx, p); err != nil {
			logger.WithError(err).Error("could not update penalty in db")
			return err
		}
		return nil
	}

	if err := e.penaltyRepo.Create(ctx, p); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create penalty in db")
		return err
	}

	return nil
}
