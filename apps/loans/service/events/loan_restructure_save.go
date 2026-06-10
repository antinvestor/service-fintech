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

const LoanRestructureSaveEvent = "loan_restructure.save"

type LoanRestructureSave struct {
	loanRestructureRepo repository.LoanRestructureRepository
}

func NewLoanRestructureSave(
	_ context.Context,
	loanRestructureRepo repository.LoanRestructureRepository,
) *LoanRestructureSave {
	return &LoanRestructureSave{loanRestructureRepo: loanRestructureRepo}
}

func (e *LoanRestructureSave) Name() string     { return LoanRestructureSaveEvent }
func (e *LoanRestructureSave) PayloadType() any { return &models.LoanRestructure{} }

func (e *LoanRestructureSave) Validate(_ context.Context, payload any) error {
	lr, ok := payload.(*models.LoanRestructure)
	if !ok {
		return errors.New("payload is not of type models.LoanRestructure")
	}
	if lr.GetID() == "" {
		return errors.New("loan restructure ID should already have been set")
	}
	return nil
}

func (e *LoanRestructureSave) Execute(ctx context.Context, payload any) error {
	lr, ok := payload.(*models.LoanRestructure)
	if !ok {
		return errors.New("payload is not of type models.LoanRestructure")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "loan_restructure_id": lr.GetID()})
	defer logger.Release()

	existing, getErr := e.loanRestructureRepo.GetByID(ctx, lr.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.loanRestructureRepo.Update(ctx, lr); err != nil {
			logger.WithError(err).Error("could not update loan restructure in db")
			return err
		}
		return nil
	}

	if err := e.loanRestructureRepo.Create(ctx, lr); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create loan restructure in db")
		return err
	}

	return nil
}
