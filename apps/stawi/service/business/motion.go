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

package business

import (
	"context"
	"errors"

	fevents "github.com/pitabwire/frame/v2/events"

	"github.com/antinvestor/service-fintech/apps/stawi/service/models"
	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
)

type motionBusiness struct {
	eventsMan fevents.Manager
	motRepo   repository.MotionRepository
}

func NewMotionBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	motRepo repository.MotionRepository,
) MotionBusiness {
	return &motionBusiness{eventsMan: eventsMan, motRepo: motRepo}
}

func (b *motionBusiness) Create(_ context.Context, _ *models.Motion) (*models.Motion, error) {
	return nil, errors.New("group motion operations are not yet available for this product")
}

func (b *motionBusiness) Vote(_ context.Context, _, _ string, _ int32) error {
	return errors.New("group motion operations are not yet available for this product")
}
