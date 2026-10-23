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

const LoanRequestSaveEvent = "loan_request.save"

type LoanRequestSave struct {
	loanRequestRepo repository.LoanRequestRepository
}

func NewLoanRequestSave(_ context.Context, loanRequestRepo repository.LoanRequestRepository) *LoanRequestSave {
	return &LoanRequestSave{loanRequestRepo: loanRequestRepo}
}

func (e *LoanRequestSave) Name() string     { return LoanRequestSaveEvent }
func (e *LoanRequestSave) PayloadType() any { return &models.LoanRequest{} }

func (e *LoanRequestSave) Validate(_ context.Context, payload any) error {
	lr, ok := payload.(*models.LoanRequest)
	if !ok {
		return errors.New("payload is not of type models.LoanRequest")
	}
	if lr.GetID() == "" {
		return errors.New("loan request ID should already have been set")
	}
	return nil
}

func (e *LoanRequestSave) Execute(ctx context.Context, payload any) error {
	lr, ok := payload.(*models.LoanRequest)
	if !ok {
		return errors.New("payload is not of type models.LoanRequest")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "loan_request_id": lr.GetID()})
	defer logger.Release()

	if err := upsert.ByID(ctx, e.loanRequestRepo, lr); err != nil {
		logger.WithError(err).Error("could not persist loan request")
		return err
	}

	return nil
}
