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

const MotionSaveEvent = "motion.save"

// NewMotionSave creates a new motion save event handler.
func NewMotionSave(_ context.Context, repo repository.MotionRepository) events.EventI {
	return &eventHandler[*models.Motion]{
		name:    MotionSaveEvent,
		factory: func() *models.Motion { return &models.Motion{} },
		validate: func(_ context.Context, motion *models.Motion) error {
			if motion.GroupID == "" {
				return errors.New("motion group ID is required")
			}
			return nil
		},
		repo: repo,
	}
}
