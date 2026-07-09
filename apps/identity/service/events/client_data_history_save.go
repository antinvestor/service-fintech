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

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

const ClientDataEntryHistorySaveEvent = "client_data_entry_history.save"

type ClientDataEntryHistorySave struct {
	historyRepo repository.ClientDataEntryHistoryRepository
}

func NewClientDataEntryHistorySave(
	_ context.Context,
	historyRepo repository.ClientDataEntryHistoryRepository,
) *ClientDataEntryHistorySave {
	return &ClientDataEntryHistorySave{historyRepo: historyRepo}
}

func (e *ClientDataEntryHistorySave) Name() string     { return ClientDataEntryHistorySaveEvent }
func (e *ClientDataEntryHistorySave) PayloadType() any { return &models.ClientDataEntryHistory{} }

func (e *ClientDataEntryHistorySave) Validate(_ context.Context, payload any) error {
	history, ok := payload.(*models.ClientDataEntryHistory)
	if !ok {
		return errors.New("payload is not of type models.ClientDataEntryHistory")
	}
	if history.GetID() == "" {
		return errors.New("client data entry history ID should already have been set")
	}
	return nil
}

func (e *ClientDataEntryHistorySave) Execute(ctx context.Context, payload any) error {
	history, ok := payload.(*models.ClientDataEntryHistory)
	if !ok {
		return errors.New("payload is not of type models.ClientDataEntryHistory")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "history_id": history.GetID()})
	defer logger.Release()

	if err := e.historyRepo.Create(ctx, history); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create client data entry history in db")
		return err
	}

	return nil
}
