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

	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/data"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

type LoanProductBusiness interface {
	Save(ctx context.Context, obj *loansv1.LoanProductObject) (*loansv1.LoanProductObject, error)
	Get(ctx context.Context, id string) (*loansv1.LoanProductObject, error)
	Search(
		ctx context.Context,
		req *loansv1.LoanProductSearchRequest,
		consumer func(ctx context.Context, batch []*loansv1.LoanProductObject) error,
	) error
}

type loanProductBusiness struct {
	eventsMan       fevents.Manager
	loanProductRepo repository.LoanProductRepository
}

func NewLoanProductBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	loanProductRepo repository.LoanProductRepository,
) LoanProductBusiness {
	return &loanProductBusiness{
		eventsMan:       eventsMan,
		loanProductRepo: loanProductRepo,
	}
}

func (b *loanProductBusiness) Save(
	ctx context.Context,
	obj *loansv1.LoanProductObject,
) (*loansv1.LoanProductObject, error) {
	logger := util.Log(ctx).WithField("method", "LoanProductBusiness.Save")

	lp := models.LoanProductFromAPI(ctx, obj)

	err := b.eventsMan.Emit(ctx, events.LoanProductSaveEvent, lp)
	if err != nil {
		logger.WithError(err).Error("could not emit loan product save event")
		return nil, err
	}

	return lp.ToAPI(), nil
}

func (b *loanProductBusiness) Get(ctx context.Context, id string) (*loansv1.LoanProductObject, error) {
	lp, err := b.loanProductRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrLoanProductNotFound
	}
	return lp.ToAPI(), nil
}

func (b *loanProductBusiness) Search(
	ctx context.Context,
	req *loansv1.LoanProductSearchRequest,
	consumer func(ctx context.Context, batch []*loansv1.LoanProductObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "LoanProductBusiness.Search")

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
		andQueryVal["organization_id = ?"] = req.GetOrganizationId()
	}
	if req.GetProductType() != loansv1.LoanProductType_LOAN_PRODUCT_TYPE_UNSPECIFIED {
		andQueryVal["product_type = ?"] = int32(req.GetProductType())
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	if req.GetQuery() != "" {
		searchOpts = append(searchOpts,
			data.WithSearchFiltersOrByValue(
				map[string]any{searchableTSQuery: req.GetQuery()},
			),
		)
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.loanProductRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search loan products")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.LoanProduct) error {
		var apiResults []*loansv1.LoanProductObject
		for _, lp := range res {
			apiResults = append(apiResults, lp.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}
