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
	"strconv"

	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

type ClientRelationshipBusiness interface {
	Save(ctx context.Context, obj *fieldv1.ClientRelationshipObject) (*fieldv1.ClientRelationshipObject, error)
	Get(ctx context.Context, id string) (*fieldv1.ClientRelationshipObject, error)
	Search(
		ctx context.Context,
		req *fieldv1.ClientRelationshipSearchRequest,
		consumer func(ctx context.Context, batch []*fieldv1.ClientRelationshipObject) error,
	) error
}

type clientRelationshipBusiness struct {
	eventsMan fevents.Manager
	crRepo    repository.ClientRelationshipRepository
}

func NewClientRelationshipBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	crRepo repository.ClientRelationshipRepository,
) ClientRelationshipBusiness {
	return &clientRelationshipBusiness{
		eventsMan: eventsMan,
		crRepo:    crRepo,
	}
}

func (b *clientRelationshipBusiness) Save(
	ctx context.Context,
	obj *fieldv1.ClientRelationshipObject,
) (*fieldv1.ClientRelationshipObject, error) {
	logger := util.Log(ctx).WithField("method", "ClientRelationshipBusiness.Save")

	cr := models.ClientRelationshipFromAPI(ctx, obj)

	// If marking as primary, clear any existing primary for this client.
	if cr.IsPrimary {
		existing, _ := b.crRepo.GetPrimaryForClient(ctx, cr.ClientID)
		if existing != nil && existing.GetID() != cr.GetID() {
			existing.IsPrimary = false
			if err := b.eventsMan.Emit(ctx, events.ClientRelationshipSaveEvent, existing); err != nil {
				logger.WithError(err).Error("could not clear previous primary relationship")
				return nil, err
			}
		}
	}

	if err := b.eventsMan.Emit(ctx, events.ClientRelationshipSaveEvent, cr); err != nil {
		logger.WithError(err).Error("could not emit client relationship save event")
		return nil, err
	}

	return cr.ToAPI(), nil
}

func (b *clientRelationshipBusiness) Get(ctx context.Context, id string) (*fieldv1.ClientRelationshipObject, error) {
	cr, err := b.crRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrClientRelationshipNotFound
	}
	return cr.ToAPI(), nil
}

func (b *clientRelationshipBusiness) Search(
	ctx context.Context,
	req *fieldv1.ClientRelationshipSearchRequest,
	consumer func(ctx context.Context, batch []*fieldv1.ClientRelationshipObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "ClientRelationshipBusiness.Search")

	var searchOpts []data.SearchOption

	cursor := req.GetCursor()
	if cursor != nil {
		offset, offsetErr := strconv.Atoi(cursor.GetPage())
		if offsetErr != nil {
			offset = 0
		}
		searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(int(cursor.GetLimit())))
	}

	andQueryVal := map[string]any{}
	if req.GetClientId() != "" {
		andQueryVal["client_id = ?"] = req.GetClientId()
	}
	if req.GetMemberId() != "" {
		andQueryVal["member_id = ?"] = req.GetMemberId()
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.crRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search client relationships")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.ClientRelationship) error {
		var apiResults []*fieldv1.ClientRelationshipObject
		for _, cr := range res {
			apiResults = append(apiResults, cr.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}
