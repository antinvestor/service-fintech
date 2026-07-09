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

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
)

const LoanWindowSaveEvent = "loan_window.save"

// NewLoanWindowSave creates a new loan window save event handler.
func NewLoanWindowSave(_ context.Context, repo repository.LoanWindowRepository) events.EventI {
	return &baseEventHandler[*models.LoanWindow]{
		name:    LoanWindowSaveEvent,
		factory: func() *models.LoanWindow { return &models.LoanWindow{} },
		validate: func(_ context.Context, lw *models.LoanWindow) error {
			if lw.GroupID == "" {
				return errors.New("group_id is required")
			}
			return nil
		},
		repo: repo,
	}
}
