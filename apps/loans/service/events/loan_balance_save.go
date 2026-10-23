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

	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
	"github.com/antinvestor/service-fintech/pkg/upsert"
)

const LoanBalanceSaveEvent = "loan_balance.save"

type LoanBalanceSave struct {
	loanBalanceRepo repository.LoanBalanceRepository
}

func NewLoanBalanceSave(_ context.Context, loanBalanceRepo repository.LoanBalanceRepository) *LoanBalanceSave {
	return &LoanBalanceSave{loanBalanceRepo: loanBalanceRepo}
}

func (e *LoanBalanceSave) Name() string     { return LoanBalanceSaveEvent }
func (e *LoanBalanceSave) PayloadType() any { return &models.LoanBalance{} }

func (e *LoanBalanceSave) Validate(_ context.Context, payload any) error {
	lb, ok := payload.(*models.LoanBalance)
	if !ok {
		return errors.New("payload is not of type models.LoanBalance")
	}
	if lb.GetID() == "" {
		return errors.New("loan balance ID should already have been set")
	}
	return nil
}

func (e *LoanBalanceSave) Execute(ctx context.Context, payload any) error {
	lb, ok := payload.(*models.LoanBalance)
	if !ok {
		return errors.New("payload is not of type models.LoanBalance")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "loan_balance_id": lb.GetID()})
	defer logger.Release()

	if err := upsert.ByID(ctx, e.loanBalanceRepo, lb); err != nil {
		logger.WithError(err).Error("could not persist loan balance")
		return err
	}

	return nil
}
