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

func TestReconcilePeriodSplitsSettledSavingsFromPenalties(t *testing.T) {
	t.Parallel()

	past := time.Now().UTC().Add(-48 * time.Hour)
	biz, _ := periodBusinessWith(
		// 1000 raised, 400 left: 600 settled.
		obligation("o1", "m1", obligationPeriodicSaving, 1000, 400, past),
		obligation("o2", "m1", obligationPenalty, 100, 100, past),
		// fully settled savings for a second member.
		obligation("o3", "m2", obligationPeriodicSaving, 500, 0, past),
	)

	result, err := biz.ReconcilePeriod(t.Context(), "period-1")
	if err != nil {
		t.Fatalf("ReconcilePeriod: %v", err)
	}

	members, ok := result["members"].([]map[string]interface{})
	if !ok || len(members) != 2 {
		t.Fatalf("expected two member rows, got %#v", result["members"])
	}

	first := members[0]
	if first["savings_total"] != int64(600) {
		t.Errorf("m1 savings_total = %v, want 600", first["savings_total"])
	}
	if first["penalties"] != int64(100) {
		t.Errorf("m1 penalties = %v, want 100", first["penalties"])
	}
	if members[1]["savings_total"] != int64(500) {
		t.Errorf("m2 savings_total = %v, want 500", members[1]["savings_total"])
	}
	if result["total_outstanding"] != int64(500) {
		t.Errorf("total_outstanding = %v, want 500", result["total_outstanding"])
	}
}

func TestOutstandingForPeriodOmitsSettledMembers(t *testing.T) {
	t.Parallel()

	past := time.Now().UTC().Add(-24 * time.Hour)
	biz, _ := periodBusinessWith(
		obligation("o1", "m1", obligationPeriodicSaving, 1000, 250, past),
		obligation("o2", "m2", obligationPeriodicSaving, 1000, 0, past),
	)

	result, err := biz.OutstandingForPeriod(t.Context(), "period-1")
	if err != nil {
		t.Fatalf("OutstandingForPeriod: %v", err)
	}

	members, _ := result["members"].([]map[string]interface{})
	if len(members) != 1 {
		t.Fatalf("expected only the unsettled member, got %#v", members)
	}
	if members[0][fieldMemberID] != "m1" {
		t.Errorf("member = %v, want m1", members[0][fieldMemberID])
	}
	if members[0]["amount_outstanding"] != int64(250) {
		t.Errorf("amount_outstanding = %v, want 250", members[0]["amount_outstanding"])
	}
	if result["count"] != 1 {
		t.Errorf("count = %v, want 1", result["count"])
	}
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

func TestCalculatePenaltiesForPeriodSkipsCurrentAndAlreadyPenalised(t *testing.T) {
	t.Parallel()

	past := time.Now().UTC().Add(-72 * time.Hour)
	future := time.Now().UTC().Add(72 * time.Hour)

	overdue := obligation("o1", "m1", obligationPeriodicSaving, 1000, 1000, past)
	current := obligation("o2", "m2", obligationPeriodicSaving, 1000, 1000, future)
	penalised := obligation("o3", "m3", obligationPeriodicSaving, 1000, 1000, past)

	events := &paymentEventsManagerStub{}
	repo := &periodObligationRepoStub{
		byPeriod: map[string][]*models.Obligation{"period-1": {overdue, current, penalised}},
		byCause: map[string][]*models.Obligation{
			penaltyCausePrefix + "o3": {obligation("p3", "m3", obligationPenalty, 100, 100, past)},
		},
	}
	biz := &obligationBusiness{eventsMan: events, obRepo: repo}

	result, err := biz.CalculatePenaltiesForPeriod(t.Context(), "period-1")
	if err != nil {
		t.Fatalf("CalculatePenaltiesForPeriod: %v", err)
	}

	if result["penalties_created"] != 1 {
		t.Fatalf("penalties_created = %v, want 1", result["penalties_created"])
	}
	if len(events.emitted) != 1 {
		t.Fatalf("expected one emitted penalty, got %d", len(events.emitted))
	}
	raised, ok := events.emitted[0].payload.(*models.Obligation)
	if !ok {
		t.Fatalf("emitted payload is %T, want *models.Obligation", events.emitted[0].payload)
	}
	if raised.CauseID != penaltyCausePrefix+"o1" {
		t.Errorf("penalty cause_id = %q, want %q", raised.CauseID, penaltyCausePrefix+"o1")
	}
	if raised.Amount <= 0 {
		t.Errorf("penalty amount = %d, want positive", raised.Amount)
	}
}

func TestSummariseMemberObligationsSplitsSavingsFromLoanRepayment(t *testing.T) {
	t.Parallel()

	due := time.Now().UTC().Add(24 * time.Hour)
	rows := summariseMemberObligations([]*models.Obligation{
		obligation("o1", "m1", obligationPeriodicSaving, 300, 300, due),
		obligation("o2", "m1", "loan_principal", 700, 700, due),
	})

	if len(rows) != 1 {
		t.Fatalf("expected one member row, got %d", len(rows))
	}
	if rows[0]["savings_due"] != int64(300) {
		t.Errorf("savings_due = %v, want 300", rows[0]["savings_due"])
	}
	if rows[0]["loan_repayment_due"] != int64(700) {
		t.Errorf("loan_repayment_due = %v, want 700", rows[0]["loan_repayment_due"])
	}
	if rows[0]["total_due"] != int64(1000) {
		t.Errorf("total_due = %v, want 1000", rows[0]["total_due"])
	}
}
