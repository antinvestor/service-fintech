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
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// ClientProductAccessBusiness grants and revokes a client's access to a loan
// product. It is what decides which products a borrower may request against.
type ClientProductAccessBusiness interface {
	Save(ctx context.Context, obj *loansv1.ClientProductAccessObject) (*loansv1.ClientProductAccessObject, error)
	Get(ctx context.Context, id string) (*loansv1.ClientProductAccessObject, error)
	Search(
		ctx context.Context,
		req *loansv1.ClientProductAccessSearchRequest,
		consumer func(ctx context.Context, batch []*loansv1.ClientProductAccessObject) error,
	) error
}

type clientProductAccessBusiness struct {
	eventsMan       fevents.Manager
	cpaRepo         repository.ClientProductAccessRepository
	loanProductRepo repository.LoanProductRepository
}

func NewClientProductAccessBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	cpaRepo repository.ClientProductAccessRepository,
	loanProductRepo repository.LoanProductRepository,
) ClientProductAccessBusiness {
	return &clientProductAccessBusiness{
		eventsMan:       eventsMan,
		cpaRepo:         cpaRepo,
		loanProductRepo: loanProductRepo,
	}
}

func (b *clientProductAccessBusiness) Save(
	ctx context.Context,
	obj *loansv1.ClientProductAccessObject,
) (*loansv1.ClientProductAccessObject, error) {
	logger := util.Log(ctx).WithField("method", "ClientProductAccessBusiness.Save")

	cpa := models.ClientProductAccessFromAPI(ctx, obj)
	if cpa == nil {
		return nil, apperrors.NewError(apperrors.BadRequest, "client product access payload is required")
	}
	if cpa.ClientID == "" || cpa.ProductID == "" {
		return nil, ErrClientProductAccessIncomplete
	}
	if _, err := b.loanProductRepo.GetByID(ctx, cpa.ProductID); err != nil {
		return nil, ErrLoanProductNotFound
	}

	// The grant is attributed to the authenticated caller, not to whoever the
	// payload names: this record is the audit trail for who opened a product
	// to a borrower.
	cpa.GrantedBy = callerSubject(ctx)
	if cpa.State == int32(commonv1.STATE_CREATED) {
		cpa.State = int32(commonv1.STATE_ACTIVE)
	}

	// One grant per client and product. Reusing the existing row keeps a
	// re-grant from colliding with the partition-scoped unique index.
	if existing, err := b.cpaRepo.GetByClientAndProduct(ctx, cpa.ClientID, cpa.ProductID); err == nil &&
		existing != nil {
		cpa.ID = existing.GetID()
	}

	if err := b.eventsMan.Emit(ctx, events.ClientProductAccessSaveEvent, cpa); err != nil {
		logger.WithError(err).Error("could not emit client product access save event")
		return nil, err
	}

	return cpa.ToAPI(), nil
}

func (b *clientProductAccessBusiness) Get(
	ctx context.Context,
	id string,
) (*loansv1.ClientProductAccessObject, error) {
	cpa, err := b.cpaRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrClientProductAccessNotFound
	}
	return cpa.ToAPI(), nil
}

func (b *clientProductAccessBusiness) Search(
	ctx context.Context,
	req *loansv1.ClientProductAccessSearchRequest,
	consumer func(ctx context.Context, batch []*loansv1.ClientProductAccessObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "ClientProductAccessBusiness.Search")

	andQueryVal := map[string]any{}
	if req.GetClientId() != "" {
		andQueryVal["client_id = ?"] = req.GetClientId()
	}
	if req.GetProductId() != "" {
		andQueryVal["product_id = ?"] = req.GetProductId()
	}

	return executeSearch(
		ctx,
		logger,
		b.cpaRepo.Search,
		req.GetCursor(),
		andQueryVal,
		"failed to search client product access",
		func(cpa *models.ClientProductAccess) *loansv1.ClientProductAccessObject {
			return cpa.ToAPI()
		},
		consumer,
	)
}
