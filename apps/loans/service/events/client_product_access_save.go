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

const ClientProductAccessSaveEvent = "client_product_access.save"

type ClientProductAccessSave struct {
	cpaRepo repository.ClientProductAccessRepository
}

func NewClientProductAccessSave(
	_ context.Context,
	cpaRepo repository.ClientProductAccessRepository,
) *ClientProductAccessSave {
	return &ClientProductAccessSave{cpaRepo: cpaRepo}
}

func (e *ClientProductAccessSave) Name() string     { return ClientProductAccessSaveEvent }
func (e *ClientProductAccessSave) PayloadType() any { return &models.ClientProductAccess{} }

func (e *ClientProductAccessSave) Validate(_ context.Context, payload any) error {
	cpa, ok := payload.(*models.ClientProductAccess)
	if !ok {
		return errors.New("payload is not of type models.ClientProductAccess")
	}
	if cpa.GetID() == "" {
		return errors.New("client product access ID should already have been set")
	}
	return nil
}

func (e *ClientProductAccessSave) Execute(ctx context.Context, payload any) error {
	cpa, ok := payload.(*models.ClientProductAccess)
	if !ok {
		return errors.New("payload is not of type models.ClientProductAccess")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "cpa_id": cpa.GetID()})
	defer logger.Release()

	existing, getErr := e.cpaRepo.GetByID(ctx, cpa.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.cpaRepo.Update(ctx, cpa); err != nil {
			logger.WithError(err).Error("could not update client product access in db")
			return err
		}
		return nil
	}

	if err := e.cpaRepo.Create(ctx, cpa); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create client product access in db")
		return err
	}

	return nil
}
