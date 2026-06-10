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

	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

const AgentSaveEvent = "agent.save"

type AgentSave struct {
	agentRepo repository.AgentRepository
}

func NewAgentSave(_ context.Context, agentRepo repository.AgentRepository) *AgentSave {
	return &AgentSave{agentRepo: agentRepo}
}

func (e *AgentSave) Name() string     { return AgentSaveEvent }
func (e *AgentSave) PayloadType() any { return &models.Agent{} }

func (e *AgentSave) Validate(_ context.Context, payload any) error {
	agent, ok := payload.(*models.Agent)
	if !ok {
		return errors.New("payload is not of type models.Agent")
	}
	if agent.GetID() == "" {
		return errors.New("agent ID should already have been set")
	}
	return nil
}

func (e *AgentSave) Execute(ctx context.Context, payload any) error {
	agent, ok := payload.(*models.Agent)
	if !ok {
		return errors.New("payload is not of type models.Agent")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "agent_id": agent.GetID()})
	defer logger.Release()

	existing, getErr := e.agentRepo.GetByID(ctx, agent.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.agentRepo.Update(ctx, agent); err != nil {
			logger.WithError(err).Error("could not update agent in db")
			return err
		}
		return nil
	}

	if err := e.agentRepo.Create(ctx, agent); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create agent in db")
		return err
	}

	return nil
}
