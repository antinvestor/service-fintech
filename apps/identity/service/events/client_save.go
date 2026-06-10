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

const ClientSaveEvent = "client.save"

type ClientSave struct {
	clientRepo repository.ClientRepository
}

func NewClientSave(_ context.Context, clientRepo repository.ClientRepository) *ClientSave {
	return &ClientSave{clientRepo: clientRepo}
}

func (e *ClientSave) Name() string     { return ClientSaveEvent }
func (e *ClientSave) PayloadType() any { return &models.Client{} }

func (e *ClientSave) Validate(_ context.Context, payload any) error {
	client, ok := payload.(*models.Client)
	if !ok {
		return errors.New("payload is not of type models.Client")
	}
	if client.GetID() == "" {
		return errors.New("client ID should already have been set")
	}
	return nil
}

func (e *ClientSave) Execute(ctx context.Context, payload any) error {
	client, ok := payload.(*models.Client)
	if !ok {
		return errors.New("payload is not of type models.Client")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "client_id": client.GetID()})
	defer logger.Release()

	existing, getErr := e.clientRepo.GetByID(ctx, client.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.clientRepo.Update(ctx, client); err != nil {
			logger.WithError(err).Error("could not update client in db")
			return err
		}
		return nil
	}

	if err := e.clientRepo.Create(ctx, client); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create client in db")
		return err
	}

	return nil
}
