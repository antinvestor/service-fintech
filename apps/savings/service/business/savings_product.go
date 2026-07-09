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
	savingsv1 "buf.build/gen/go/antinvestor/savings/protocolbuffers/go/savings/v1"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/savings/service/events"
	"github.com/antinvestor/service-fintech/apps/savings/service/models"
	"github.com/antinvestor/service-fintech/apps/savings/service/repository"
)

type SavingsProductBusiness interface {
	Save(ctx context.Context, obj *savingsv1.SavingsProductObject) (*savingsv1.SavingsProductObject, error)
	Get(ctx context.Context, id string) (*savingsv1.SavingsProductObject, error)
	Search(
		ctx context.Context,
		req *savingsv1.SavingsProductSearchRequest,
		consumer func(ctx context.Context, batch []*savingsv1.SavingsProductObject) error,
	) error
}

type savingsProductBusiness struct {
	eventsMan fevents.Manager
	spRepo    repository.SavingsProductRepository
}

func NewSavingsProductBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	spRepo repository.SavingsProductRepository,
) SavingsProductBusiness {
	return &savingsProductBusiness{
		eventsMan: eventsMan,
		spRepo:    spRepo,
	}
}

func (b *savingsProductBusiness) Save(
	ctx context.Context,
	obj *savingsv1.SavingsProductObject,
) (*savingsv1.SavingsProductObject, error) {
	logger := util.Log(ctx).WithField("method", "SavingsProductBusiness.Save")

	isNew := obj.GetId() == ""
	sp := models.SavingsProductFromAPI(ctx, obj)

	if isNew && sp.State == 0 {
		sp.State = int32(commonv1.STATE_CREATED.Number())
	}

	err := b.eventsMan.Emit(ctx, events.SavingsProductSaveEvent, sp)
	if err != nil {
		logger.WithError(err).Error("could not emit savings product save event")
		return nil, err
	}

	return sp.ToAPI(), nil
}

func (b *savingsProductBusiness) Get(ctx context.Context, id string) (*savingsv1.SavingsProductObject, error) {
	sp, err := b.spRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrSavingsProductNotFound
	}
	return sp.ToAPI(), nil
}

func (b *savingsProductBusiness) Search(
	ctx context.Context,
	req *savingsv1.SavingsProductSearchRequest,
	consumer func(ctx context.Context, batch []*savingsv1.SavingsProductObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "SavingsProductBusiness.Search")

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
	if req.GetOrganizationId() != "" {
		andQueryVal["bank_id = ?"] = req.GetOrganizationId()
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	if req.GetQuery() != "" {
		searchOpts = append(searchOpts,
			data.WithSearchFiltersOrByValue(
				map[string]any{"searchable @@ websearch_to_tsquery( 'english', ?) ": req.GetQuery()},
			),
		)
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.spRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search savings products")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.SavingsProduct) error {
		var apiResults []*savingsv1.SavingsProductObject
		for _, sp := range res {
			apiResults = append(apiResults, sp.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}
