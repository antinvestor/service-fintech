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

package events

import (
	"context"
	"errors"

	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

const CreditLimitChangeRequestSaveEvent = "credit_limit_change_request.save"

// CreditLimitChangeRequestSave handles persistence of credit limit change requests.
type CreditLimitChangeRequestSave struct {
	repo repository.CreditLimitChangeRequestRepository
}

func NewCreditLimitChangeRequestSave(
	_ context.Context,
	repo repository.CreditLimitChangeRequestRepository,
) *CreditLimitChangeRequestSave {
	return &CreditLimitChangeRequestSave{repo: repo}
}

func (e *CreditLimitChangeRequestSave) Name() string {
	return CreditLimitChangeRequestSaveEvent
}

func (e *CreditLimitChangeRequestSave) PayloadType() any {
	return &models.CreditLimitChangeRequest{}
}

func (e *CreditLimitChangeRequestSave) Validate(_ context.Context, payload any) error {
	req, ok := payload.(*models.CreditLimitChangeRequest)
	if !ok {
		return errors.New("invalid payload type for credit_limit_change_request.save")
	}
	if req.ClientID == "" {
		return errors.New("client_id is required")
	}
	return nil
}

func (e *CreditLimitChangeRequestSave) Execute(ctx context.Context, payload any) error {
	req, ok := payload.(*models.CreditLimitChangeRequest)
	if !ok {
		return errors.New("invalid payload type for credit_limit_change_request.save")
	}
	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "client_id": req.ClientID})

	existing, err := e.repo.GetByID(ctx, req.ID)
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		logger.WithError(err).Error("failed to check existing record")
		return err
	}

	if existing != nil && existing.GetID() != "" {
		_, err = e.repo.Update(ctx, req)
		if err != nil {
			logger.WithError(err).Error("failed to update record")
			return err
		}
		return nil
	}

	err = e.repo.Create(ctx, req)
	if err != nil {
		logger.WithError(err).Error("failed to create record")
		return err
	}
	return nil
}
