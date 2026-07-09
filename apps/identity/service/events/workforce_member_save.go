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

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

const WorkforceMemberSaveEvent = "workforce_member.save"

type WorkforceMemberSave struct {
	repo repository.WorkforceMemberRepository
}

func NewWorkforceMemberSave(_ context.Context, repo repository.WorkforceMemberRepository) *WorkforceMemberSave {
	return &WorkforceMemberSave{repo: repo}
}

func (e *WorkforceMemberSave) Name() string     { return WorkforceMemberSaveEvent }
func (e *WorkforceMemberSave) PayloadType() any { return &models.WorkforceMember{} }

func (e *WorkforceMemberSave) Validate(_ context.Context, payload any) error {
	m, ok := payload.(*models.WorkforceMember)
	if !ok {
		return errors.New("payload is not of type models.WorkforceMember")
	}
	if m.GetID() == "" {
		return errors.New("workforce member ID should already have been set")
	}
	return nil
}

func (e *WorkforceMemberSave) Execute(ctx context.Context, payload any) error {
	m, ok := payload.(*models.WorkforceMember)
	if !ok {
		return errors.New("payload is not of type models.WorkforceMember")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "member_id": m.GetID()})
	defer logger.Release()

	existing, getErr := e.repo.GetByID(ctx, m.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.repo.Update(ctx, m); err != nil {
			logger.WithError(err).Error("could not update workforce member in db")
			return err
		}
		return nil
	}

	if err := e.repo.Create(ctx, m); err != nil && !data.ErrorIsDuplicateKey(err) {
		logger.WithError(err).Error("could not create workforce member in db")
		return err
	}

	return nil
}
