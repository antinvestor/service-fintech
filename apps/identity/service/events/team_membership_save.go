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

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

const TeamMembershipSaveEvent = "team_membership.save"

type TeamMembershipSave struct {
	repo repository.TeamMembershipRepository
}

func NewTeamMembershipSave(_ context.Context, repo repository.TeamMembershipRepository) *TeamMembershipSave {
	return &TeamMembershipSave{repo: repo}
}

func (e *TeamMembershipSave) Name() string     { return TeamMembershipSaveEvent }
func (e *TeamMembershipSave) PayloadType() any { return &models.TeamMembership{} }

func (e *TeamMembershipSave) Validate(_ context.Context, payload any) error {
	m, ok := payload.(*models.TeamMembership)
	if !ok {
		return errors.New("payload is not of type models.TeamMembership")
	}
	if m.GetID() == "" {
		return errors.New("team membership ID should already have been set")
	}
	return nil
}

func (e *TeamMembershipSave) Execute(ctx context.Context, payload any) error {
	m, ok := payload.(*models.TeamMembership)
	if !ok {
		return errors.New("payload is not of type models.TeamMembership")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "membership_id": m.GetID()})
	defer logger.Release()

	existing, getErr := e.repo.GetByID(ctx, m.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.repo.Update(ctx, m); err != nil {
			logger.WithError(err).Error("could not update team membership in db")
			return err
		}
		return nil
	}

	if err := e.repo.Create(ctx, m); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create team membership in db")
		return err
	}

	return nil
}
