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

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/data"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

type InvestorBusiness interface {
	Save(ctx context.Context, obj *identityv1.InvestorObject) (*identityv1.InvestorObject, error)
	Get(ctx context.Context, id string) (*identityv1.InvestorObject, error)
	Search(
		ctx context.Context,
		req *identityv1.InvestorSearchRequest,
		consumer func(ctx context.Context, batch []*identityv1.InvestorObject) error,
	) error
}

type investorBusiness struct {
	eventsMan    fevents.Manager
	investorRepo repository.InvestorRepository
}

func NewInvestorBusiness(_ context.Context, eventsMan fevents.Manager,
	investorRepo repository.InvestorRepository,
) InvestorBusiness {
	return &investorBusiness{
		eventsMan:    eventsMan,
		investorRepo: investorRepo,
	}
}

func (b *investorBusiness) Save(
	ctx context.Context,
	obj *identityv1.InvestorObject,
) (*identityv1.InvestorObject, error) {
	logger := util.Log(ctx).WithField("method", "InvestorBusiness.Save")

	isNew := obj.GetId() == ""
	investor := models.InvestorFromAPI(ctx, obj)

	if isNew && investor.State == 0 {
		investor.State = int32(commonv1.STATE_CREATED.Number())
	}

	err := b.eventsMan.Emit(ctx, events.InvestorSaveEvent, investor)
	if err != nil {
		logger.WithError(err).Error("could not emit investor save event")
		return nil, err
	}

	return investor.ToAPI(), nil
}

func (b *investorBusiness) Get(ctx context.Context, id string) (*identityv1.InvestorObject, error) {
	investor, err := b.investorRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrInvestorNotFound
	}
	return investor.ToAPI(), nil
}

func (b *investorBusiness) Search(
	ctx context.Context,
	req *identityv1.InvestorSearchRequest,
	consumer func(ctx context.Context, batch []*identityv1.InvestorObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "InvestorBusiness.Search")

	var searchOpts []data.SearchOption

	cursor := req.GetCursor()
	if cursor != nil {
		offset, offsetErr := strconv.Atoi(cursor.GetPage())
		if offsetErr != nil {
			offset = 0
		}
		searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(int(cursor.GetLimit())))
	}

	if req.GetQuery() != "" {
		searchOpts = append(searchOpts,
			data.WithSearchFiltersOrByValue(
				map[string]any{searchableTSQuery: req.GetQuery()},
			),
		)
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.investorRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search investors")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.Investor) error {
		var apiResults []*identityv1.InvestorObject
		for _, investor := range res {
			apiResults = append(apiResults, investor.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}
