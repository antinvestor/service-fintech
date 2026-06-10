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
	"github.com/pitabwire/frame/data"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

type MembershipBusiness interface {
	Save(ctx context.Context, membership *models.Membership) (*models.Membership, error)
	Get(ctx context.Context, id string) (*models.Membership, error)
	Search(
		ctx context.Context,
		query, groupID, profileID string,
		role, membershipType int32,
		consumer func(ctx context.Context, batch []*models.Membership) error,
	) error
}

type membershipBusiness struct {
	eventsMan      fevents.Manager
	groupRepo      repository.ClientGroupRepository
	membershipRepo repository.MembershipRepository
}

func NewMembershipBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	groupRepo repository.ClientGroupRepository,
	membershipRepo repository.MembershipRepository,
) MembershipBusiness {
	return &membershipBusiness{
		eventsMan:      eventsMan,
		groupRepo:      groupRepo,
		membershipRepo: membershipRepo,
	}
}

func (b *membershipBusiness) Save(
	ctx context.Context,
	membership *models.Membership,
) (*models.Membership, error) {
	logger := util.Log(ctx).WithField("method", "MembershipBusiness.Save")

	// Validate group exists
	_, err := b.groupRepo.GetByID(ctx, membership.GroupID)
	if err != nil {
		logger.WithError(err).Warn("group not found for membership")
		return nil, ErrGroupNotFound
	}

	isNew := membership.GetID() == ""

	if isNew && membership.State == 0 {
		membership.State = int32(commonv1.STATE_CREATED.Number())
	}

	if isNew {
		membership.GenID(ctx)
	}

	err = b.eventsMan.Emit(ctx, events.MembershipSaveEvent, membership)
	if err != nil {
		logger.WithError(err).Error("could not emit membership save event")
		return nil, err
	}

	return membership, nil
}

func (b *membershipBusiness) Get(ctx context.Context, id string) (*models.Membership, error) {
	membership, err := b.membershipRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrMembershipNotFound
	}
	return membership, nil
}

func (b *membershipBusiness) Search(
	ctx context.Context,
	query, groupID, profileID string,
	role, membershipType int32,
	consumer func(ctx context.Context, batch []*models.Membership) error,
) error {
	logger := util.Log(ctx).WithField("method", "MembershipBusiness.Search")

	var searchOpts []data.SearchOption

	andQueryVal := map[string]any{}
	if groupID != "" {
		andQueryVal["group_id = ?"] = groupID
	}
	if profileID != "" {
		andQueryVal["profile_id = ?"] = profileID
	}
	if role != 0 {
		andQueryVal["role = ?"] = role
	}
	if membershipType != 0 {
		andQueryVal["membership_type = ?"] = membershipType
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
	results, err := b.membershipRepo.Search(ctx, sq)
	if err != nil {
		logger.WithError(err).Error("failed to search memberships")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.Membership) error {
		return consumer(ctx, res)
	})
}
