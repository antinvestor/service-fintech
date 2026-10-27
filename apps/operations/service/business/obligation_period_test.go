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
	"testing"
	"time"

	"github.com/pitabwire/frame/v3/data"

	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// periodObligationRepoStub serves a fixed period ledger and records the
// obligations raised against it.
type periodObligationRepoStub struct {
	obligationRepoStub

	byPeriod map[string][]*models.Obligation
	byCause  map[string][]*models.Obligation
}

func (r *periodObligationRepoStub) GetByPeriodID(
	_ context.Context,
	periodID string,
) ([]*models.Obligation, error) {
	return r.byPeriod[periodID], nil
}

func (r *periodObligationRepoStub) GetByCauseID(
	_ context.Context,
	causeID string,
) ([]*models.Obligation, error) {
	return r.byCause[causeID], nil
}

func (r *periodObligationRepoStub) GetByMembershipID(
	_ context.Context,
	membershipID string,
) ([]*models.Obligation, error) {
	var found []*models.Obligation
	for _, obligations := range r.byPeriod {
		for _, obl := range obligations {
			if obl.MembershipID == membershipID {
				found = append(found, obl)
			}
		}
	}
	return found, nil
}

func obligation(id, member, cause string, original, remaining int64, deadline time.Time) *models.Obligation {
	obl := &models.Obligation{
		MembershipID: member,
		CauseType:    cause,
		PeriodID:     "period-1",
		Amount:       remaining,
		Currency:     "KES",
		Deadline:     &deadline,
		State:        int32(constants.StateActive),
		Properties:   data.JSONMap{propertyOriginalAmount: float64(original)},
	}
	if remaining <= 0 {
		obl.State = int32(constants.StateInactive)
	}
	obl.ID = id
	return obl
}

func periodBusinessWith(obligations ...*models.Obligation) (*obligationBusiness, *paymentEventsManagerStub) {
	events := &paymentEventsManagerStub{}
	repo := &periodObligationRepoStub{
		byPeriod: map[string][]*models.Obligation{"period-1": obligations},
		byCause:  map[string][]*models.Obligation{},
	}
	return &obligationBusiness{eventsMan: events, obRepo: repo}, events
}

func TestCheckForMemberReportsAllMetWhenNothingOwed(t *testing.T) {
	t.Parallel()

	past := time.Now().UTC().Add(-time.Hour)
	biz, _ := periodBusinessWith(obligation("o1", "m1", obligationPeriodicSaving, 100, 0, past))

	result, err := biz.CheckForMember(t.Context(), "m1")
	if err != nil {
		t.Fatalf("CheckForMember: %v", err)
	}
	if result["all_met"] != true {
		t.Errorf("all_met = %v, want true", result["all_met"])
	}
	if result["outstanding_count"] != 0 {
		t.Errorf("outstanding_count = %v, want 0", result["outstanding_count"])
	}
}
