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

	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/apps/seed/service/repository"
	"github.com/antinvestor/service-fintech/pkg/upsert"
)

// CreditProfileSaveEvent persists one-off credit profile snapshots.
// Runtime counter mutations (Mark borrowed, Record repayment, etc.)
// never go through this handler; they use the repository's atomic SQL
// paths directly. This handler exists for the initial Ensure call and
// for any operator-initiated full-row replace.
const CreditProfileSaveEvent = "seed_credit_profile.save"

type CreditProfileSave struct {
	repo repository.CreditProfileRepository
}

// NewCreditProfileSave wires a repository into a handler ready for
// registration via frame.WithRegisterEvents.
func NewCreditProfileSave(_ context.Context, repo repository.CreditProfileRepository) *CreditProfileSave {
	return &CreditProfileSave{repo: repo}
}

func (e *CreditProfileSave) Name() string     { return CreditProfileSaveEvent }
func (e *CreditProfileSave) PayloadType() any { return &models.CreditProfile{} }

func (e *CreditProfileSave) Validate(_ context.Context, payload any) error {
	cp, ok := payload.(*models.CreditProfile)
	if !ok {
		return errors.New("payload is not of type models.CreditProfile")
	}
	if cp.GetID() == "" {
		return errors.New("credit profile id should already have been set")
	}
	if cp.ClientID == "" {
		return errors.New("credit profile client id is required")
	}
	return nil
}

func (e *CreditProfileSave) Execute(ctx context.Context, payload any) error {
	cp, ok := payload.(*models.CreditProfile)
	if !ok {
		return errors.New("payload is not of type models.CreditProfile")
	}

	logger := util.Log(ctx).WithFields(map[string]any{
		"type":              e.Name(),
		"credit_profile_id": cp.GetID(),
		"client_id":         cp.ClientID,
	})
	defer logger.Release()

	if err := upsert.ByID(ctx, e.repo, cp); err != nil {
		logger.WithError(err).Error("could not persist credit profile")
		return err
	}
	return nil
}
