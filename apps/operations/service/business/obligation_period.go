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
	"strings"
	"time"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// propertyOriginalAmount records what an obligation was worth when it was
// raised. Allocation consumes the Amount column in place, so settlement can
// only be derived by comparing what is left against this.
const propertyOriginalAmount = "original_amount"

// originalAmount reports what an obligation started at, falling back to its
// current amount for rows raised before the field existed.
func originalAmount(obl *models.Obligation) int64 {
	if obl.Properties != nil {
		if raw, ok := obl.Properties[propertyOriginalAmount]; ok {
			switch typed := raw.(type) {
			case float64:
				return int64(typed)
			case int64:
				return typed
			}
		}
	}
	return obl.Amount
}

// outstandingAmount is what a member still owes on an obligation.
func outstandingAmount(obl *models.Obligation) int64 {
	if obl.State != int32(constants.StateActive) || obl.Amount <= 0 {
		return 0
	}
	return obl.Amount
}

// CheckForMember reports whether a member has settled everything owed. The
// payment routing workflow uses it to decide whether to congratulate the payer.
func (b *obligationBusiness) CheckForMember(
	ctx context.Context,
	membershipID string,
) (map[string]interface{}, error) {
	membershipID = strings.TrimSpace(membershipID)
	if membershipID == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "a member id is required")
	}

	obligations, err := b.obRepo.GetByMembershipID(ctx, membershipID)
	if err != nil {
		return nil, err
	}

	var total int64
	outstandingCount := 0
	var nextDue *time.Time
	for _, obl := range obligations {
		owed := outstandingAmount(obl)
		if owed == 0 {
			continue
		}
		total += owed
		outstandingCount++
		if obl.Deadline != nil && (nextDue == nil || obl.Deadline.Before(*nextDue)) {
			nextDue = obl.Deadline
		}
	}

	return map[string]interface{}{
		fieldMemberID:         membershipID,
		fieldMembershipID:     membershipID,
		"all_met":             outstandingCount == 0,
		"outstanding_count":   outstandingCount,
		fieldTotalOutstanding: total,
		fieldDueDate:          formatDeadline(nextDue),
	}, nil
}

// formatDeadline renders an obligation deadline for a workflow template.
func formatDeadline(deadline *time.Time) string {
	if deadline == nil {
		return ""
	}
	return deadline.UTC().Format(time.RFC3339)
}
