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

const RepaymentSaveEvent = "repayment.save"

type RepaymentSave struct {
	repaymentRepo repository.RepaymentRepository
}

func NewRepaymentSave(_ context.Context, repaymentRepo repository.RepaymentRepository) *RepaymentSave {
	return &RepaymentSave{repaymentRepo: repaymentRepo}
}

func (e *RepaymentSave) Name() string     { return RepaymentSaveEvent }
func (e *RepaymentSave) PayloadType() any { return &models.Repayment{} }

func (e *RepaymentSave) Validate(_ context.Context, payload any) error {
	r, ok := payload.(*models.Repayment)
	if !ok {
		return errors.New("payload is not of type models.Repayment")
	}
	if r.GetID() == "" {
		return errors.New("repayment ID should already have been set")
	}
	return nil
}

func (e *RepaymentSave) Execute(ctx context.Context, payload any) error {
	r, ok := payload.(*models.Repayment)
	if !ok {
		return errors.New("payload is not of type models.Repayment")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "repayment_id": r.GetID()})
	defer logger.Release()

	if err := upsert.ByID(ctx, e.repaymentRepo, r); err != nil {
		logger.WithError(err).Error("could not persist repayment")
		return err
	}

	return nil
}
