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
	"fmt"
	"strconv"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	loansv1 "buf.build/gen/go/antinvestor/loans/protocolbuffers/go/loans/v1"
	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/events"
	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

type LoanRestructureBusiness interface {
	Create(ctx context.Context, obj *loansv1.LoanRestructureObject) (*loansv1.LoanRestructureObject, error)
	Approve(ctx context.Context, id string) (*loansv1.LoanRestructureObject, error)
	Reject(ctx context.Context, id, reason string) (*loansv1.LoanRestructureObject, error)
	Search(
		ctx context.Context,
		req *loansv1.LoanRestructureSearchRequest,
		consumer func(ctx context.Context, batch []*loansv1.LoanRestructureObject) error,
	) error
}

type loanRestructureBusiness struct {
	eventsMan           fevents.Manager
	loanRestructureRepo repository.LoanRestructureRepository
	loanAccountRepo     repository.LoanAccountRepository
	scheduleBusiness    RepaymentScheduleBusiness
}

func NewLoanRestructureBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	loanRestructureRepo repository.LoanRestructureRepository,
	loanAccountRepo repository.LoanAccountRepository,
	scheduleBusiness RepaymentScheduleBusiness,
) LoanRestructureBusiness {
	return &loanRestructureBusiness{
		eventsMan:           eventsMan,
		loanRestructureRepo: loanRestructureRepo,
		loanAccountRepo:     loanAccountRepo,
		scheduleBusiness:    scheduleBusiness,
	}
}

func (b *loanRestructureBusiness) Create(
	ctx context.Context,
	obj *loansv1.LoanRestructureObject,
) (*loansv1.LoanRestructureObject, error) {
	logger := util.Log(ctx).WithField("method", "LoanRestructureBusiness.Create")

	lr := models.LoanRestructureFromAPI(ctx, obj)
	lr.State = int32(commonv1.STATE_CREATED)

	err := b.eventsMan.Emit(ctx, events.LoanRestructureSaveEvent, lr)
	if err != nil {
		logger.WithError(err).Error("could not emit loan restructure save event")
		return nil, err
	}

	return lr.ToAPI(), nil
}

func (b *loanRestructureBusiness) Approve(
	ctx context.Context,
	id string,
) (*loansv1.LoanRestructureObject, error) {
	logger := util.Log(ctx).WithField("method", "LoanRestructureBusiness.Approve")

	lr, err := b.loanRestructureRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrRestructureNotFound
	}

	if commonv1.STATE(lr.State) != commonv1.STATE_CREATED {
		return nil, ErrRestructureNotPending
	}

	lr.State = int32(commonv1.STATE_ACTIVE)

	err = b.eventsMan.Emit(ctx, events.LoanRestructureSaveEvent, lr)
	if err != nil {
		logger.WithError(err).Error("could not emit loan restructure save event")
		return nil, err
	}

	// Apply restructure to loan account: update terms and regenerate schedule
	la, laErr := b.loanAccountRepo.GetByID(ctx, lr.LoanAccountID)
	if laErr != nil {
		logger.WithError(laErr).Error("could not load loan account for restructure")
		return nil, fmt.Errorf("loan account not found for restructure: %w", laErr)
	}

	// Update loan terms from restructure
	if lr.NewInterestRate > 0 {
		la.InterestRate = lr.NewInterestRate
	}
	if lr.NewTermDays > 0 {
		la.TermDays = lr.NewTermDays
	}

	// Transition to RESTRUCTURED
	la.Status = int32(loansv1.LoanStatus_LOAN_STATUS_RESTRUCTURED)

	if emitErr := b.eventsMan.Emit(ctx, events.LoanAccountSaveEvent, la); emitErr != nil {
		logger.WithError(emitErr).Error("could not save restructured loan account")
		return nil, emitErr
	}

	// Regenerate repayment schedule with the updated terms.
	if b.scheduleBusiness != nil {
		if _, schedErr := b.scheduleBusiness.Generate(ctx, la.GetID()); schedErr != nil {
			logger.WithError(schedErr).Error("could not regenerate schedule after restructure")
		}
	}

	return lr.ToAPI(), nil
}

func (b *loanRestructureBusiness) Reject(
	ctx context.Context,
	id, reason string,
) (*loansv1.LoanRestructureObject, error) {
	logger := util.Log(ctx).WithField("method", "LoanRestructureBusiness.Reject")

	lr, err := b.loanRestructureRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrRestructureNotFound
	}

	if commonv1.STATE(lr.State) != commonv1.STATE_CREATED {
		return nil, ErrRestructureNotPending
	}

	lr.State = int32(commonv1.STATE_INACTIVE)
	lr.Reason = reason

	err = b.eventsMan.Emit(ctx, events.LoanRestructureSaveEvent, lr)
	if err != nil {
		logger.WithError(err).Error("could not emit loan restructure save event")
		return nil, err
	}

	return lr.ToAPI(), nil
}

func (b *loanRestructureBusiness) Search(
	ctx context.Context,
	req *loansv1.LoanRestructureSearchRequest,
	consumer func(ctx context.Context, batch []*loansv1.LoanRestructureObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "LoanRestructureBusiness.Search")

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

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.loanRestructureRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search loan restructures")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.LoanRestructure) error {
		var apiResults []*loansv1.LoanRestructureObject
		for _, lr := range res {
			apiResults = append(apiResults, lr.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}
