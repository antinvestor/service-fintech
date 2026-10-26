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
	"time"

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/apps/seed/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

const (
	actionCreditProfileCapSet    = "seed.credit_profile.cap_set"
	actionCreditProfileCapLifted = "seed.credit_profile.cap_lifted"
	maxTempCapDuration           = 90 * 24 * time.Hour
	fieldTempCapAmount           = "temp_cap_amount"
	fieldTempCapExpiresAt        = "temp_cap_expires_at"
	maxTempCapReasonLen          = 500
)

// ErrTempCapInvalid is returned for a cap that is not a temporary lowering
// of the client's limit.
var ErrTempCapInvalid = apperrors.NewError(apperrors.BadRequest,
	"a temporary cap must be below the tier limit, expire within 90 days and give a reason")

// SetTempCap lowers what the client may borrow until expiresAt, or lifts the
// cap when amount is 0. The tier ladder stays the permanent limit: a cap can
// only lower it, never raise it, and it lapses on its own.
func (b *creditProfileBusiness) SetTempCap(
	ctx context.Context,
	clientID, currencyCode string,
	amount int64,
	expiresAt time.Time,
	actor, reason string,
) (*models.CreditProfile, error) {
	reason = strings.TrimSpace(reason)
	if clientID == "" || currencyCode == "" || reason == "" || len(reason) > maxTempCapReasonLen {
		return nil, ErrTempCapInvalid
	}
	profile, err := b.cpRepo.GetByClientAndCurrency(ctx, clientID, currencyCode)
	if err != nil {
		if errors.Is(err, repository.ErrCreditProfileNotFound) {
			return nil, apperrors.ErrDataNotFound.Extend("credit profile")
		}
		return nil, fmt.Errorf("load credit profile: %w", err)
	}

	now := time.Now().UTC()
	var expires *time.Time
	action := actionCreditProfileCapLifted
	if amount != 0 {
		if amount < 0 || amount >= profile.MaxLoanAmount ||
			!expiresAt.After(now) || expiresAt.Sub(now) > maxTempCapDuration {
			return nil, ErrTempCapInvalid
		}
		e := expiresAt.UTC()
		expires = &e
		action = actionCreditProfileCapSet
	}

	updated, err := b.cpRepo.SetTempCap(ctx, profile.GetID(), amount, expires, actor, reason)
	if err != nil {
		return nil, fmt.Errorf("set temporary cap: %w", err)
	}
	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityCreditProfile,
		EntityID:   updated.GetID(),
		Action:     action,
		ActorID:    actor,
		Reason:     reason,
		Before:     data.JSONMap{fieldTempCapAmount: profile.TempCapAmount},
		After: data.JSONMap{
			fieldTempCapAmount:    updated.TempCapAmount,
			fieldTempCapExpiresAt: updated.TempCapExpiresAt,
		},
		Metadata: data.JSONMap{fieldClientID: clientID, fieldCurrencyCode: currencyCode},
		Parent:   &updated.BaseModel,
	}, func(auErr error) {
		util.Log(ctx).WithError(auErr).Warn("audit emission failed for temporary cap")
	})
	return updated, nil
}
