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

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
)

const InvestorAccountSaveEvent = "investor_account.save"

// NewInvestorAccountSave creates a new investor account save event handler.
func NewInvestorAccountSave(_ context.Context, repo repository.InvestorAccountRepository) events.EventI {
	return &eventHandler[*models.InvestorAccount]{
		name:    InvestorAccountSaveEvent,
		factory: func() *models.InvestorAccount { return &models.InvestorAccount{} },
		validate: func(_ context.Context, ia *models.InvestorAccount) error {
			if ia.InvestorID == "" {
				return errors.New("investor_id is required")
			}
			if ia.Currency == "" {
				return errors.New("currency is required")
			}
			return nil
		},
		repo: repo,
	}
}
