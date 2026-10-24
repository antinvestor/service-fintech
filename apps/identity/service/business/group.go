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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

type ClientGroupBusiness interface {
	Save(ctx context.Context, group *models.ClientGroup) (*models.ClientGroup, error)
	Get(ctx context.Context, id string) (*models.ClientGroup, error)
	Search(
		ctx context.Context,
		query, ownerMemberID, orgUnitID string,
		cursor *commonv1.PageCursor,
		consumer func(ctx context.Context, batch []*models.ClientGroup) error,
	) error
}

type clientGroupBusiness struct {
	eventsMan     fevents.Manager
	workforceRepo repository.WorkforceMemberRepository
	orgUnitRepo   repository.OrgUnitRepository
	groupRepo     repository.ClientGroupRepository
}

func NewClientGroupBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	workforceRepo repository.WorkforceMemberRepository,
	orgUnitRepo repository.OrgUnitRepository,
	groupRepo repository.ClientGroupRepository,
) ClientGroupBusiness {
	return &clientGroupBusiness{
		eventsMan:     eventsMan,
		workforceRepo: workforceRepo,
		orgUnitRepo:   orgUnitRepo,
		groupRepo:     groupRepo,
	}
}

func (b *clientGroupBusiness) Save(ctx context.Context, group *models.ClientGroup) (*models.ClientGroup, error) {
	logger := util.Log(ctx).WithField("method", "ClientGroupBusiness.Save")

	// AgentID carries the owning workforce member since the agent model retired.
	if group.AgentID == "" {
		return nil, ErrGroupOwnerRequired
	}
	owner, err := b.workforceRepo.GetByID(ctx, group.AgentID)
	if err != nil {
		logger.WithError(err).Warn("owning workforce member not found for group")
		return nil, ErrWorkforceMemberNotFound
	}
	if commonv1.STATE(owner.State) != commonv1.STATE_ACTIVE &&
		commonv1.STATE(owner.State) != commonv1.STATE_CREATED {
		return nil, ErrWorkforceMemberInactive
	}

	// BranchID carries the owning org unit.
	if group.BranchID != "" {
		if _, unitErr := b.orgUnitRepo.GetByID(ctx, group.BranchID); unitErr != nil {
			logger.WithError(unitErr).Warn("org unit not found for group")
			return nil, ErrOrgUnitNotFound
		}
	}

	isNew := group.GetID() == ""

	if isNew && group.State == 0 {
		group.State = int32(commonv1.STATE_CREATED.Number())
	}

	if isNew {
		group.GenID(ctx)
	} else if err = carryStoredTenancy(ctx, b.groupRepo, group); err != nil {
		return nil, err
	}

	err = b.eventsMan.Emit(ctx, events.ClientGroupSaveEvent, group)
	if err != nil {
		logger.WithError(err).Error("could not emit client group save event")
		return nil, err
	}

	return group, nil
}

func (b *clientGroupBusiness) Get(ctx context.Context, id string) (*models.ClientGroup, error) {
	group, err := b.groupRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrGroupNotFound
	}
	return group, nil
}

//nolint:dupl // client group and membership search share a filter shape
func (b *clientGroupBusiness) Search(
	ctx context.Context,
	query, ownerMemberID, orgUnitID string,
	cursor *commonv1.PageCursor,
	consumer func(ctx context.Context, batch []*models.ClientGroup) error,
) error {
	logger := util.Log(ctx).WithField("method", "ClientGroupBusiness.Search")

	searchOpts, cursorErr := cursorSearchOptions(cursor)
	if cursorErr != nil {
		return cursorErr
	}

	andQueryVal := map[string]any{}
	if ownerMemberID != "" {
		andQueryVal["agent_id = ?"] = ownerMemberID
	}
	if orgUnitID != "" {
		andQueryVal["branch_id = ?"] = orgUnitID
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	if query != "" {
		searchOpts = append(searchOpts,
			data.WithSearchFiltersOrByValue(
				map[string]any{searchableTSQuery: query},
			),
		)
	}

	sq := data.NewSearchQuery(searchOpts...)
	results, err := b.groupRepo.Search(ctx, sq)
	if err != nil {
		logger.WithError(err).Error("failed to search client groups")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.ClientGroup) error {
		return consumer(ctx, res)
	})
}
