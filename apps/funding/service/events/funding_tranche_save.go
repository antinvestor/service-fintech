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

const FundingTrancheSaveEvent = "funding_tranche.save"

// NewFundingTrancheSave creates a new funding tranche save event handler.
func NewFundingTrancheSave(_ context.Context, repo repository.FundingTrancheRepository) events.EventI {
	return &eventHandler[*models.FundingTranche]{
		name:    FundingTrancheSaveEvent,
		factory: func() *models.FundingTranche { return &models.FundingTranche{} },
		validate: func(_ context.Context, ft *models.FundingTranche) error {
			if ft.LoanFundingID == "" {
				return errors.New("loan_funding_id is required")
			}
			return nil
		},
		repo: repo,
	}
}
