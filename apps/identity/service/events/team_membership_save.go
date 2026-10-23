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

	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
	"github.com/antinvestor/service-fintech/pkg/upsert"
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

	if err := upsert.ByID(ctx, e.repo, m); err != nil {
		logger.WithError(err).Error("could not save team membership in db")
		return err
	}

	return nil
}
