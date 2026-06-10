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
)

const BranchSaveEvent = "branch.save"

type BranchSave struct {
	branchRepo repository.BranchRepository
}

func NewBranchSave(_ context.Context, branchRepo repository.BranchRepository) *BranchSave {
	return &BranchSave{branchRepo: branchRepo}
}

func (e *BranchSave) Name() string     { return BranchSaveEvent }
func (e *BranchSave) PayloadType() any { return &models.Branch{} }

func (e *BranchSave) Validate(_ context.Context, payload any) error {
	branch, ok := payload.(*models.Branch)
	if !ok {
		return errors.New("payload is not of type models.Branch")
	}
	if branch.GetID() == "" {
		return errors.New("branch ID should already have been set")
	}
	return nil
}

func (e *BranchSave) Execute(ctx context.Context, payload any) error {
	branch, ok := payload.(*models.Branch)
	if !ok {
		return errors.New("payload is not of type models.Branch")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "branch_id": branch.GetID()})
	defer logger.Release()

	_, getErr := e.branchRepo.GetByID(ctx, branch.GetID())
	if getErr != nil {
		err := e.branchRepo.Create(ctx, branch)
		if err != nil {
			logger.WithError(err).Error("could not create branch in db")
			return err
		}
	} else {
		_, err := e.branchRepo.Update(ctx, branch)
		if err != nil {
			logger.WithError(err).Error("could not update branch in db")
			return err
		}
	}

	return nil
}
