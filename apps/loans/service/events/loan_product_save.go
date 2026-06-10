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

package events //nolint:dupl // similar event handlers for different entity types

import (
	"context"
	"errors"

	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

const LoanProductSaveEvent = "loan_product.save"

type LoanProductSave struct {
	loanProductRepo repository.LoanProductRepository
}

func NewLoanProductSave(_ context.Context, loanProductRepo repository.LoanProductRepository) *LoanProductSave {
	return &LoanProductSave{loanProductRepo: loanProductRepo}
}

func (e *LoanProductSave) Name() string     { return LoanProductSaveEvent }
func (e *LoanProductSave) PayloadType() any { return &models.LoanProduct{} }

func (e *LoanProductSave) Validate(_ context.Context, payload any) error {
	lp, ok := payload.(*models.LoanProduct)
	if !ok {
		return errors.New("payload is not of type models.LoanProduct")
	}
	if lp.GetID() == "" {
		return errors.New("loan product ID should already have been set")
	}
	return nil
}

func (e *LoanProductSave) Execute(ctx context.Context, payload any) error {
	lp, ok := payload.(*models.LoanProduct)
	if !ok {
		return errors.New("payload is not of type models.LoanProduct")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "loan_product_id": lp.GetID()})
	defer logger.Release()

	existing, getErr := e.loanProductRepo.GetByID(ctx, lp.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.loanProductRepo.Update(ctx, lp); err != nil {
			logger.WithError(err).Error("could not update loan product in db")
			return err
		}
		return nil
	}

	if err := e.loanProductRepo.Create(ctx, lp); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create loan product in db")
		return err
	}

	return nil
}
