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
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

type ReconciliationBusiness interface {
	Save(ctx context.Context, obj *loansv1.ReconciliationObject) (*loansv1.ReconciliationObject, error)
	Search(
		ctx context.Context,
		req *loansv1.ReconciliationSearchRequest,
		consumer func(ctx context.Context, batch []*loansv1.ReconciliationObject) error,
	) error
}

type reconciliationBusiness struct {
	eventsMan          fevents.Manager
	reconciliationRepo repository.ReconciliationRepository
}

func NewReconciliationBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	reconciliationRepo repository.ReconciliationRepository,
) ReconciliationBusiness {
	return &reconciliationBusiness{
		eventsMan:          eventsMan,
		reconciliationRepo: reconciliationRepo,
	}
}

func (b *reconciliationBusiness) Save(
	ctx context.Context,
	obj *loansv1.ReconciliationObject,
) (*loansv1.ReconciliationObject, error) {
	logger := util.Log(ctx).WithField("method", "ReconciliationBusiness.Save")

	recon := models.ReconciliationFromAPI(ctx, obj)

	err := b.eventsMan.Emit(ctx, events.ReconciliationSaveEvent, recon)
	if err != nil {
		logger.WithError(err).Error("could not emit reconciliation save event")
		return nil, err
	}

	return recon.ToAPI(), nil
}

//nolint:dupl // similar search logic for different entity types
func (b *reconciliationBusiness) Search(
	ctx context.Context,
	req *loansv1.ReconciliationSearchRequest,
	consumer func(ctx context.Context, batch []*loansv1.ReconciliationObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "ReconciliationBusiness.Search")

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
	if req.GetLoanAccountId() != "" {
		andQueryVal["loan_account_id = ?"] = req.GetLoanAccountId()
	}
	if req.GetStatus() != loansv1.ReconciliationStatus_RECONCILIATION_STATUS_UNSPECIFIED {
		andQueryVal["status = ?"] = int32(req.GetStatus())
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.reconciliationRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search reconciliations")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.Reconciliation) error {
		var apiResults []*loansv1.ReconciliationObject
		for _, r := range res {
			apiResults = append(apiResults, r.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}
