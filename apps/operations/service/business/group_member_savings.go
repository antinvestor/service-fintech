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
	"fmt"
	"strings"
	"time"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

// GroupMemberSavingsQuery asks where members stand across a group's savings.
type GroupMemberSavingsQuery struct {
	GroupID       string
	Currency      string
	MembershipIDs []string
}

// MemberSavings is one member's savings record in a group, in minor units.
// Saved is what they paid against their periodic savings, partial payments
// included; Arrears is what they still owe on savings past due plus unpaid
// penalties.
type MemberSavings struct {
	MembershipID string
	Saved        int64
	Arrears      int64
}

// GroupMemberSavings folds the group's savings and penalty obligations into
// one row per requested member, in the order asked. A member with no
// obligations saved nothing and owes nothing. Only obligations in the
// group's currency count.
func (b *obligationBusiness) GroupMemberSavings(
	ctx context.Context,
	req GroupMemberSavingsQuery,
) ([]MemberSavings, error) {
	groupID := strings.TrimSpace(req.GroupID)
	currency := strings.ToUpper(strings.TrimSpace(req.Currency))
	switch {
	case groupID == "":
		return nil, apperrors.NewError(apperrors.BadRequest, "a group id is required")
	case currency == "":
		return nil, apperrors.NewError(apperrors.BadRequest, "a currency code is required")
	case len(req.MembershipIDs) == 0:
		return nil, apperrors.NewError(apperrors.BadRequest, "at least one member is required")
	case len(req.MembershipIDs) > maxGroupMembers:
		return nil, apperrors.NewError(apperrors.BadRequest, "too many members for one group")
	}

	rows := make(map[string]*MemberSavings, len(req.MembershipIDs))
	ids := make([]string, 0, len(req.MembershipIDs))
	for _, id := range req.MembershipIDs {
		id = strings.TrimSpace(id)
		if id == "" {
			return nil, apperrors.NewError(apperrors.BadRequest, "every member needs a membership id")
		}
		if _, seen := rows[id]; seen {
			continue
		}
		rows[id] = &MemberSavings{MembershipID: id}
		ids = append(ids, id)
	}

	obligations, err := b.obRepo.GetGroupMemberObligations(ctx, groupID, ids,
		[]string{obligationPeriodicSaving, obligationPenalty})
	if err != nil {
		return nil, fmt.Errorf("read group member obligations: %w", err)
	}

	now := time.Now().UTC()
	for _, obl := range obligations {
		row, ok := rows[obl.MembershipID]
		if !ok || !strings.EqualFold(obl.Currency, currency) {
			continue
		}
		accrueSavings(row, obl, now)
	}

	out := make([]MemberSavings, 0, len(ids))
	for _, id := range ids {
		out = append(out, *rows[id])
	}
	return out, nil
}

// accrueSavings adds one obligation to a member's record. A savings
// obligation not yet due is not arrears: the member still has time to pay.
// A penalty is charged only once something is overdue, so all of what is
// left of it is arrears.
func accrueSavings(row *MemberSavings, obl *models.Obligation, now time.Time) {
	owed := outstandingAmount(obl)
	switch obl.CauseType {
	case obligationPeriodicSaving:
		row.Saved += originalAmount(obl) - owed
		if obl.Deadline != nil && obl.Deadline.Before(now) {
			row.Arrears += owed
		}
	case obligationPenalty:
		row.Arrears += owed
	}
}
