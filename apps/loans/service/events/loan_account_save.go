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

const LoanAccountSaveEvent = "loan_account.save"

type LoanAccountSave struct {
	loanAccountRepo repository.LoanAccountRepository
}

func NewLoanAccountSave(_ context.Context, loanAccountRepo repository.LoanAccountRepository) *LoanAccountSave {
	return &LoanAccountSave{loanAccountRepo: loanAccountRepo}
}

func (e *LoanAccountSave) Name() string     { return LoanAccountSaveEvent }
func (e *LoanAccountSave) PayloadType() any { return &models.LoanAccount{} }

func (e *LoanAccountSave) Validate(_ context.Context, payload any) error {
	la, ok := payload.(*models.LoanAccount)
	if !ok {
		return errors.New("payload is not of type models.LoanAccount")
	}
	if la.GetID() == "" {
		return errors.New("loan account ID should already have been set")
	}
	return nil
}

func (e *LoanAccountSave) Execute(ctx context.Context, payload any) error {
	la, ok := payload.(*models.LoanAccount)
	if !ok {
		return errors.New("payload is not of type models.LoanAccount")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "loan_account_id": la.GetID()})
	defer logger.Release()

	if err := upsert.ByID(ctx, e.loanAccountRepo, la); err != nil {
		logger.WithError(err).Error("could not persist loan account")
		return err
	}

	return nil
}
