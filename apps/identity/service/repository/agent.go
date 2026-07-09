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

package repository

import (
	"context"

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

type AgentRepository interface {
	datastore.BaseRepository[*models.Agent]
	GetByBranchID(ctx context.Context, branchID string, offset, limit int) ([]*models.Agent, error)
	GetByParentAgentID(ctx context.Context, parentAgentID string, offset, limit int) ([]*models.Agent, error)
	GetByProfileID(ctx context.Context, profileID string) (*models.Agent, error)
	GetDescendants(ctx context.Context, agentID string, maxDepth int) ([]*models.Agent, error)
}

type agentRepository struct {
	datastore.BaseRepository[*models.Agent]
}

func NewAgentRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) AgentRepository {
	return &agentRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Agent](
			ctx, dbPool, workMan, func() *models.Agent { return &models.Agent{} },
		),
	}
}

// GetByBranchID returns agents assigned to a branch via the agent_branches join table.
func (repo *agentRepository) GetByBranchID(
	ctx context.Context,
	branchID string,
	offset, limit int,
) ([]*models.Agent, error) {
	var agents []*models.Agent
	err := repo.Pool().DB(ctx, true).
		Where("id IN (SELECT agent_id FROM agent_branches WHERE branch_id = ?)", branchID).
		Offset(offset).Limit(limit).
		Find(&agents).Error
	if err != nil {
		return nil, err
	}
	return agents, nil
}

func (repo *agentRepository) GetByParentAgentID(
	ctx context.Context,
	parentAgentID string,
	offset, limit int,
) ([]*models.Agent, error) {
	var agents []*models.Agent
	err := repo.Pool().DB(ctx, true).
		Where("parent_agent_id = ?", parentAgentID).
		Offset(offset).Limit(limit).
		Find(&agents).Error
	if err != nil {
		return nil, err
	}
	return agents, nil
}

func (repo *agentRepository) GetByProfileID(ctx context.Context, profileID string) (*models.Agent, error) {
	agent := models.Agent{}
	err := repo.Pool().DB(ctx, true).First(&agent, "profile_id = ?", profileID).Error
	if err != nil {
		return nil, err
	}
	return &agent, nil
}

// GetDescendants returns all descendants of the given agent using a recursive CTE.
// If maxDepth is 0, all descendants are returned regardless of depth.
func (repo *agentRepository) GetDescendants(
	ctx context.Context,
	agentID string,
	maxDepth int,
) ([]*models.Agent, error) {
	var agents []*models.Agent

	query := `
		WITH RECURSIVE agent_tree AS (
			SELECT *, 0 AS level FROM agents WHERE id = ?
			UNION ALL
			SELECT a.*, t.level + 1 FROM agents a
			JOIN agent_tree t ON a.parent_agent_id = t.id
			WHERE (? = 0 OR t.level < ?)
		)
		SELECT * FROM agent_tree WHERE id != ?
	`

	err := repo.Pool().DB(ctx, true).
		Raw(query, agentID, maxDepth, maxDepth, agentID).
		Scan(&agents).Error
	if err != nil {
		return nil, err
	}
	return agents, nil
}

// AgentBranchRepository manages agent-branch assignments.
type AgentBranchRepository interface {
	datastore.BaseRepository[*models.AgentBranch]
	GetByAgentID(ctx context.Context, agentID string) ([]*models.AgentBranch, error)
	GetByBranchID(ctx context.Context, branchID string) ([]*models.AgentBranch, error)
	GetByAgentAndBranch(ctx context.Context, agentID, branchID string) (*models.AgentBranch, error)
	DeleteByID(ctx context.Context, id string) error
}

type agentBranchRepository struct {
	datastore.BaseRepository[*models.AgentBranch]
}

func NewAgentBranchRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) AgentBranchRepository {
	return &agentBranchRepository{
		BaseRepository: datastore.NewBaseRepository[*models.AgentBranch](
			ctx, dbPool, workMan, func() *models.AgentBranch { return &models.AgentBranch{} },
		),
	}
}

func (repo *agentBranchRepository) GetByAgentID(ctx context.Context, agentID string) ([]*models.AgentBranch, error) {
	var results []*models.AgentBranch
	err := repo.Pool().DB(ctx, true).
		Where("agent_id = ?", agentID).
		Find(&results).Error
	if err != nil {
		return nil, err
	}
	return results, nil
}

func (repo *agentBranchRepository) GetByBranchID(ctx context.Context, branchID string) ([]*models.AgentBranch, error) {
	var results []*models.AgentBranch
	err := repo.Pool().DB(ctx, true).
		Where("branch_id = ?", branchID).
		Find(&results).Error
	if err != nil {
		return nil, err
	}
	return results, nil
}

func (repo *agentBranchRepository) GetByAgentAndBranch(
	ctx context.Context,
	agentID, branchID string,
) (*models.AgentBranch, error) {
	var result models.AgentBranch
	err := repo.Pool().DB(ctx, true).
		Where("agent_id = ? AND branch_id = ?", agentID, branchID).
		First(&result).Error
	if err != nil {
		return nil, err
	}
	return &result, nil
}

func (repo *agentBranchRepository) DeleteByID(ctx context.Context, id string) error {
	return repo.Pool().DB(ctx, false).
		Where("id = ?", id).
		Delete(&models.AgentBranch{}).Error
}
