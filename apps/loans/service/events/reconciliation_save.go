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

const ReconciliationSaveEvent = "reconciliation.save"

type ReconciliationSave struct {
	reconciliationRepo repository.ReconciliationRepository
}

func NewReconciliationSave(
	_ context.Context,
	reconciliationRepo repository.ReconciliationRepository,
) *ReconciliationSave {
	return &ReconciliationSave{reconciliationRepo: reconciliationRepo}
}

func (e *ReconciliationSave) Name() string     { return ReconciliationSaveEvent }
func (e *ReconciliationSave) PayloadType() any { return &models.Reconciliation{} }

func (e *ReconciliationSave) Validate(_ context.Context, payload any) error {
	r, ok := payload.(*models.Reconciliation)
	if !ok {
		return errors.New("payload is not of type models.Reconciliation")
	}
	if r.GetID() == "" {
		return errors.New("reconciliation ID should already have been set")
	}
	return nil
}

func (e *ReconciliationSave) Execute(ctx context.Context, payload any) error {
	r, ok := payload.(*models.Reconciliation)
	if !ok {
		return errors.New("payload is not of type models.Reconciliation")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "reconciliation_id": r.GetID()})
	defer logger.Release()

	existing, getErr := e.reconciliationRepo.GetByID(ctx, r.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.reconciliationRepo.Update(ctx, r); err != nil {
			logger.WithError(err).Error("could not update reconciliation in db")
			return err
		}
		return nil
	}

	if err := e.reconciliationRepo.Create(ctx, r); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create reconciliation in db")
		return err
	}

	return nil
}
