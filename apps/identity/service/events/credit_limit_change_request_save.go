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

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
	"github.com/antinvestor/service-fintech/pkg/upsert"
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

	if err := upsert.ByID(ctx, e.repo, req); err != nil {
		logger.WithError(err).Error("failed to save credit limit change request")
		return err
	}
	return nil
}
