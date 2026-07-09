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

	"github.com/pitabwire/frame/v2/events"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/apps/operations/service/repository"
)

const TransferOrderSaveEvent = "transfer_order.save"

// NewTransferOrderSave creates a new transfer order save event handler.
func NewTransferOrderSave(_ context.Context, repo repository.TransferOrderRepository) events.EventI {
	return &eventHandler[*models.TransferOrder]{
		name:    TransferOrderSaveEvent,
		factory: func() *models.TransferOrder { return &models.TransferOrder{} },
		validate: func(_ context.Context, to *models.TransferOrder) error {
			if to.DebitAccountRef == "" {
				return errors.New("debit_account_ref is required")
			}
			if to.CreditAccountRef == "" {
				return errors.New("credit_account_ref is required")
			}
			return nil
		},
		repo: repo,
	}
}
