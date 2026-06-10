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

const ApprovalCaseSaveEvent = "approval_case.save"

type ApprovalCaseSave struct {
	repo repository.ApprovalCaseRepository
}

func NewApprovalCaseSave(_ context.Context, repo repository.ApprovalCaseRepository) *ApprovalCaseSave {
	return &ApprovalCaseSave{repo: repo}
}

func (e *ApprovalCaseSave) Name() string     { return ApprovalCaseSaveEvent }
func (e *ApprovalCaseSave) PayloadType() any { return &models.ApprovalCase{} }

func (e *ApprovalCaseSave) Validate(_ context.Context, payload any) error {
	approvalCase, ok := payload.(*models.ApprovalCase)
	if !ok {
		return errors.New("payload is not of type models.ApprovalCase")
	}
	if approvalCase.GetID() == "" {
		return errors.New("approval case ID should already have been set")
	}
	if approvalCase.SubjectType == "" || approvalCase.SubjectID == "" || approvalCase.CaseType == "" {
		return errors.New("approval case subject and type are required")
	}
	return nil
}

func (e *ApprovalCaseSave) Execute(ctx context.Context, payload any) error {
	approvalCase, ok := payload.(*models.ApprovalCase)
	if !ok {
		return errors.New("payload is not of type models.ApprovalCase")
	}

	logger := util.Log(ctx).WithFields(map[string]any{
		logFieldType:   e.Name(),
		"approval_id":  approvalCase.GetID(),
		"subject_type": approvalCase.SubjectType,
		"subject_id":   approvalCase.SubjectID,
	})
	defer logger.Release()

	existing, err := e.repo.GetByID(ctx, approvalCase.GetID())
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		logger.WithError(err).Error("failed to check existing approval case")
		return err
	}

	if existing != nil && existing.GetID() != "" {
		_, err = e.repo.Update(ctx, approvalCase)
		if err != nil {
			logger.WithError(err).Error("failed to update approval case")
			return err
		}
		return nil
	}

	if err = e.repo.Create(ctx, approvalCase); err != nil {
		logger.WithError(err).Error("failed to create approval case")
		return err
	}
	return nil
}
