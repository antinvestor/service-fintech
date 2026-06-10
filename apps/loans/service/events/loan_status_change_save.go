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

	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/loans/service/models"
	"github.com/antinvestor/service-fintech/apps/loans/service/repository"
)

const LoanStatusChangeSaveEvent = "loan_status_change.save"

type LoanStatusChangeSave struct {
	loanStatusChangeRepo repository.LoanStatusChangeRepository
}

func NewLoanStatusChangeSave(
	_ context.Context,
	loanStatusChangeRepo repository.LoanStatusChangeRepository,
) *LoanStatusChangeSave {
	return &LoanStatusChangeSave{loanStatusChangeRepo: loanStatusChangeRepo}
}

func (e *LoanStatusChangeSave) Name() string     { return LoanStatusChangeSaveEvent }
func (e *LoanStatusChangeSave) PayloadType() any { return &models.LoanStatusChange{} }

func (e *LoanStatusChangeSave) Validate(_ context.Context, payload any) error {
	lsc, ok := payload.(*models.LoanStatusChange)
	if !ok {
		return errors.New("payload is not of type models.LoanStatusChange")
	}
	if lsc.GetID() == "" {
		return errors.New("loan status change ID should already have been set")
	}
	return nil
}

// Execute persists a loan status change as an append-only audit record.
// Status transitions are historical facts and must never be rewritten:
// a duplicate-key insert is treated as idempotent success (the prior
// replay of the same event), while any other error fails the handler
// so the event pipeline retries. There is no update path.
func (e *LoanStatusChangeSave) Execute(ctx context.Context, payload any) error {
	lsc, ok := payload.(*models.LoanStatusChange)
	if !ok {
		return errors.New("payload is not of type models.LoanStatusChange")
	}

	logger := util.Log(ctx).WithFields(map[string]any{logFieldType: e.Name(), "loan_status_change_id": lsc.GetID()})
	defer logger.Release()

	if err := e.loanStatusChangeRepo.Create(ctx, lsc); err != nil {
		if data.ErrorIsDuplicateKey(err) {
			return nil
		}
		logger.WithError(err).Error("could not create loan status change in db")
		return err
	}
	return nil
}
