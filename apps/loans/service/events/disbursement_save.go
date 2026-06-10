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

const DisbursementSaveEvent = "disbursement.save"

type DisbursementSave struct {
	repo repository.DisbursementRepository
}

func NewDisbursementSave(_ context.Context, repo repository.DisbursementRepository) *DisbursementSave {
	return &DisbursementSave{repo: repo}
}

func (e *DisbursementSave) Name() string     { return DisbursementSaveEvent }
func (e *DisbursementSave) PayloadType() any { return &models.Disbursement{} }

func (e *DisbursementSave) Validate(_ context.Context, payload any) error {
	d, ok := payload.(*models.Disbursement)
	if !ok {
		return errors.New("payload is not of type models.Disbursement")
	}
	if d.GetID() == "" {
		return errors.New("disbursement ID should already have been set")
	}
	return nil
}

func (e *DisbursementSave) Execute(ctx context.Context, payload any) error {
	d, ok := payload.(*models.Disbursement)
	if !ok {
		return errors.New("payload is not of type models.Disbursement")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "disbursement_id": d.GetID()})
	defer logger.Release()

	existing, getErr := e.repo.GetByID(ctx, d.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.repo.Update(ctx, d); err != nil {
			logger.WithError(err).Error("could not update disbursement in db")
			return err
		}
		return nil
	}

	if err := e.repo.Create(ctx, d); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create disbursement in db")
		return err
	}

	return nil
}
