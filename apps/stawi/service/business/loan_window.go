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

package business

import (
	"context"

	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/stawi/service/repository"
	"github.com/antinvestor/service-fintech/pkg/calculation"
)

const (
	// defaultMaturityPeriod is the default number of periods before loan maturity.
	defaultMaturityPeriod = int32(4)
	// defaultGracePeriod is the default grace period in number of periods.
	defaultGracePeriod = int32(1)
	// defaultLoanTenure is the default loan tenure in number of periods.
	defaultLoanTenure = int32(4)
	// defaultCoolOff is the default cool-off period in number of periods.
	defaultCoolOff = int32(0)
)

type loanWindowBusiness struct {
	eventsMan fevents.Manager
	lwRepo    repository.LoanWindowRepository
}

func NewLoanWindowBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	lwRepo repository.LoanWindowRepository,
) LoanWindowBusiness {
	return &loanWindowBusiness{eventsMan: eventsMan, lwRepo: lwRepo}
}

func (b *loanWindowBusiness) Evaluate(ctx context.Context, groupID string) (map[string]interface{}, error) {
	logger := util.Log(ctx).WithField("method", "LoanWindowBusiness.Evaluate")

	// Count existing loan windows for this group to determine completed periods
	completedPeriods, err := b.lwRepo.CountByGroupID(ctx, groupID)
	if err != nil {
		logger.WithError(err).Warn("could not count loan windows, defaulting to 0")
		completedPeriods = 0
	}

	// Default cycle parameters from product config
	// These would typically come from group properties or product configuration
	maturityPeriod := defaultMaturityPeriod
	gracePeriod := defaultGracePeriod
	loanTenure := defaultLoanTenure
	coolOff := defaultCoolOff

	shouldOpen := calculation.ShouldOpenLoanWindow(completedPeriods, maturityPeriod, gracePeriod, loanTenure, coolOff)
	cycle := calculation.ActiveLoanWindowCycle(completedPeriods, maturityPeriod, gracePeriod, loanTenure, coolOff)

	logger.WithField("group_id", groupID).
		WithField("completed_periods", completedPeriods).
		WithField("should_open", shouldOpen).
		WithField("cycle_position", cycle).
		Info("loan window evaluation completed")

	return map[string]interface{}{
		fieldGroupID:        groupID,
		"should_open":       shouldOpen,
		"cycle_position":    cycle,
		"completed_periods": completedPeriods,
	}, nil
}
