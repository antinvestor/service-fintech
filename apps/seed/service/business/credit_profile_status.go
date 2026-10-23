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
	"errors"
	"fmt"
	"strings"

	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/apps/seed/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

// Audit actions recorded for operator-driven status changes.
const (
	actionCreditProfileSuspended  = "seed.credit_profile.suspended"
	actionCreditProfileBlocked    = "seed.credit_profile.blocked"
	actionCreditProfileReinstated = "seed.credit_profile.reinstated"
)

// ErrProfileStatusTransition is the base of every refused status change. The
// concrete error names the states so the operator knows what to do first.
var ErrProfileStatusTransition = apperrors.NewError(apperrors.Conflict,
	"credit profile status cannot change from its current state")

// SetStatus applies an operator-driven status change to the client's credit
// profile in one currency and records an audit row describing it.
//
// Transitions are: Active → Suspended, Active or Suspended → Blocked, and
// Suspended or Blocked → Active (reinstate). Setting the status the profile
// already has is a no-op that still succeeds, so a retried request is safe.
// Every other transition is refused with 409 rather than silently applied:
// a blocked profile must be reinstated deliberately, never downgraded to
// suspended by accident.
func (b *creditProfileBusiness) SetStatus(
	ctx context.Context,
	clientID, currencyCode string,
	status models.CreditProfileStatus,
	reason string,
) (*models.CreditProfile, error) {
	logger := util.Log(ctx).WithField("method", "CreditProfileBusiness.SetStatus").
		WithField(fieldClientID, clientID).
		WithField(fieldStatus, int32(status))

	action, ok := statusAction(status)
	if !ok {
		return nil, apperrors.NewError(apperrors.BadRequest, "unsupported credit profile status")
	}
	if strings.TrimSpace(reason) == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "a reason is required for a status change")
	}
	if clientID == "" || currencyCode == "" {
		return nil, apperrors.NewError(apperrors.BadRequest, "client id and currency code are required")
	}

	profile, err := b.cpRepo.GetByClientAndCurrency(ctx, clientID, currencyCode)
	if err != nil {
		if errors.Is(err, repository.ErrCreditProfileNotFound) {
			return nil, apperrors.ErrDataNotFound.Extend("credit profile")
		}
		return nil, fmt.Errorf("load credit profile: %w", err)
	}

	current := models.CreditProfileStatus(profile.Status)
	if current == status {
		return profile, nil
	}
	if !statusTransitionAllowed(current, status) {
		return nil, ErrProfileStatusTransition.Extend(
			fmt.Sprintf("from %s to %s", statusName(current), statusName(status)))
	}

	updated, err := b.cpRepo.AtomicSetStatus(ctx, profile.GetID(), status)
	if err != nil {
		if errors.Is(err, repository.ErrCreditProfileNotFound) {
			return nil, apperrors.ErrDataNotFound.Extend("credit profile")
		}
		return nil, fmt.Errorf("set credit profile status: %w", err)
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityCreditProfile,
		EntityID:   updated.GetID(),
		Action:     action,
		Reason:     reason,
		Before:     data.JSONMap{fieldStatus: profile.Status},
		After:      data.JSONMap{fieldStatus: updated.Status},
		Metadata: data.JSONMap{
			fieldClientID:     clientID,
			fieldCurrencyCode: currencyCode,
		},
		Parent: &updated.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for credit profile status change")
	})

	return updated, nil
}

func statusAction(status models.CreditProfileStatus) (string, bool) {
	switch status {
	case models.CreditProfileStatusSuspended:
		return actionCreditProfileSuspended, true
	case models.CreditProfileStatusBlocked:
		return actionCreditProfileBlocked, true
	case models.CreditProfileStatusActive:
		return actionCreditProfileReinstated, true
	case models.CreditProfileStatusUnspecified:
		return "", false
	default:
		return "", false
	}
}

func statusTransitionAllowed(from, to models.CreditProfileStatus) bool {
	switch to {
	case models.CreditProfileStatusSuspended:
		return from == models.CreditProfileStatusActive
	case models.CreditProfileStatusBlocked:
		return from == models.CreditProfileStatusActive || from == models.CreditProfileStatusSuspended
	case models.CreditProfileStatusActive:
		return from == models.CreditProfileStatusSuspended || from == models.CreditProfileStatusBlocked
	case models.CreditProfileStatusUnspecified:
		return false
	default:
		return false
	}
}

func statusName(status models.CreditProfileStatus) string {
	switch status {
	case models.CreditProfileStatusActive:
		return "active"
	case models.CreditProfileStatusSuspended:
		return "suspended"
	case models.CreditProfileStatusBlocked:
		return "blocked"
	case models.CreditProfileStatusUnspecified:
		return "unspecified"
	default:
		return "unknown"
	}
}
