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

const TenureSaveEvent = "tenure.save"

// NewTenureSave creates a new tenure save event handler.
func NewTenureSave(_ context.Context, repo repository.TenureRepository) events.EventI {
	return &eventHandler[*models.Tenure]{
		name:    TenureSaveEvent,
		factory: func() *models.Tenure { return &models.Tenure{} },
		validate: func(_ context.Context, tenure *models.Tenure) error {
			if tenure.GroupID == "" {
				return errors.New("tenure group ID is required")
			}
			return nil
		},
		repo: repo,
	}
}
