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

	"github.com/pitabwire/frame/v2/data"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/frame/v2/queue"

	"github.com/antinvestor/service-fintech/apps/operations/service/events"
	"github.com/antinvestor/service-fintech/apps/operations/service/models"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// capturingEventsManager records every transfer order emitted so the
// redistribution split can be asserted without a database.
type capturingEventsManager struct {
	orders []*models.TransferOrder
}

func (e *capturingEventsManager) Add(fevents.EventI) {}

func (e *capturingEventsManager) Get(string) (fevents.EventI, error) {
	return nil, errUnexpectedStubCall
}

func (e *capturingEventsManager) Emit(_ context.Context, name string, payload any) error {
	if name != events.TransferOrderSaveEvent {
		return nil
	}
	order, ok := payload.(*models.TransferOrder)
	if !ok {
		return errUnexpectedStubCall
	}
	e.orders = append(e.orders, order)
	return nil
}

func (e *capturingEventsManager) Handler() queue.SubscribeWorker { return nil }
func (e *capturingEventsManager) Strict() bool                   { return true }
func (e *capturingEventsManager) SetStrict(bool)                 {}

// byReference indexes captured orders by their idempotency reference.
func (e *capturingEventsManager) byReference() map[string]*models.TransferOrder {
	result := make(map[string]*models.TransferOrder, len(e.orders))
	for _, order := range e.orders {
		result[order.Reference] = order
	}
	return result
}

type stubLoanFundingReader struct {
	fundings []*LoanFundingInfo
	err      error
}

func (r *stubLoanFundingReader) GetByLoanRequestID(
	context.Context,
	string,
) ([]*LoanFundingInfo, error) {
	return r.fundings, r.err
}

type stubTrancheManager struct {
	tranches map[string][]*FundingTrancheInfo
	saved    []*FundingTrancheInfo
}

func (m *stubTrancheManager) GetByLoanFundingID(
	_ context.Context,
	loanFundingID string,
) ([]*FundingTrancheInfo, error) {
	return m.tranches[loanFundingID], nil
}

func (m *stubTrancheManager) Save(_ context.Context, tranche *FundingTrancheInfo) error {
	m.saved = append(m.saved, tranche)
	return nil
}

func newFunding(id string, source FundingSource, ownerID string, proportionBP int64) *LoanFundingInfo {
	info := &LoanFundingInfo{
		OwnerID:     ownerID,
		FundingType: int32(source),
		Proportion:  proportionBP,
	}
	info.ID = id
	return info
}

func newRepaymentOrder(extra data.JSONMap) *models.TransferOrder {
	order := &models.TransferOrder{
		DebitAccountRef:  "member:suspense",
		CreditAccountRef: "group:bank",
		Amount:           1000,
		Currency:         "KES",
		OrderType:        constants.TransferTypeLoanRepayment,
		ExtraData:        extra,
	}
	order.ID = "source-order"
	return order
}

func newRedistributionBusiness(
	evts *capturingEventsManager,
	lfRepo LoanFundingReader,
	ftRepo FundingTrancheManager,
) *transferOrderBusiness {
	return &transferOrderBusiness{
		eventsMan: evts,
		lfRepo:    lfRepo,
		ftRepo:    ftRepo,
	}
}

// The last funding source absorbs the rounding remainder so the split always
// sums back to the repayment amount.
func TestRedistributeRepaymentSplitsWithoutLosingMinorUnits(t *testing.T) {
	t.Parallel()

	evts := &capturingEventsManager{}
	fundings := []*LoanFundingInfo{
		newFunding("f1", FundingSourceGroupSavings, "member-1", 3333),
		newFunding("f2", FundingSourceGroupSavings, "member-2", 3333),
		newFunding("f3", FundingSourceGroupSavings, "member-3", 3334),
	}
	b := newRedistributionBusiness(evts, &stubLoanFundingReader{fundings: fundings}, nil)

	source := newRepaymentOrder(data.JSONMap{"loan_request_id": "lr-1"})
	b.redistributeRepayment(context.Background(), source, 1000, "principal", constants.TransferTypeLoanRepayment)

	if len(evts.orders) != 3 {
		t.Fatalf("expected one order per funding source, got %d", len(evts.orders))
	}

	var total int64
	for _, order := range evts.orders {
		total += order.Amount
	}
	if total != 1000 {
		t.Fatalf("redistribution must sum to the repayment amount, got %d", total)
	}

	byRef := evts.byReference()
	last := byRef["redist:principal:source-order:f3"]
	if last == nil {
		t.Fatal("expected an order for the final funding source")
	}
	if last.Amount != 334 {
		t.Fatalf("the last tranche must absorb the remainder, got %d", last.Amount)
	}
}

// A single funding source receives the whole repayment.
func TestRedistributeRepaymentSingleSourceTakesEverything(t *testing.T) {
	t.Parallel()

	evts := &capturingEventsManager{}
	fundings := []*LoanFundingInfo{newFunding("f1", FundingSourceGroupSavings, "member-1", 10000)}
	b := newRedistributionBusiness(evts, &stubLoanFundingReader{fundings: fundings}, nil)

	source := newRepaymentOrder(data.JSONMap{"loan_request_id": "lr-1"})
	b.redistributeRepayment(context.Background(), source, 777, "principal", constants.TransferTypeLoanRepayment)

	if len(evts.orders) != 1 {
		t.Fatalf("expected one order, got %d", len(evts.orders))
	}
	if evts.orders[0].Amount != 777 {
		t.Fatalf("expected the whole amount, got %d", evts.orders[0].Amount)
	}
}

// Investor interest is netted down by the platform fee and withholding tax,
// each of which gets its own order.
func TestRedistributeInterestDeductsFeeAndTax(t *testing.T) {
	t.Parallel()

	evts := &capturingEventsManager{}
	fundings := []*LoanFundingInfo{
		newFunding("f1", FundingSourceInvestorGeneral, "investor-1", 10000),
	}
	b := newRedistributionBusiness(evts, &stubLoanFundingReader{fundings: fundings}, nil)

	source := newRepaymentOrder(data.JSONMap{
		"loan_request_id":    "lr-1",
		"platform_fee_bp":    float64(500),
		"withholding_tax_bp": float64(1500),
	})
	b.redistributeRepayment(
		context.Background(), source, 10_000, "interest", constants.TransferTypeLoanInterestRepayment,
	)

	byRef := evts.byReference()
	fee := byRef["platform_fee:source-order:f1"]
	tax := byRef["wht:source-order:f1"]
	net := byRef["redist:interest:source-order:f1"]

	if fee == nil || tax == nil || net == nil {
		t.Fatalf("expected fee, tax and net orders, got %d orders", len(evts.orders))
	}
	if fee.Amount != 500 {
		t.Fatalf("expected a 5%% platform fee of 500, got %d", fee.Amount)
	}
	if tax.Amount != 1500 {
		t.Fatalf("expected 15%% withholding tax of 1500, got %d", tax.Amount)
	}
	if net.Amount != 8000 {
		t.Fatalf("expected net interest of 8000, got %d", net.Amount)
	}
	if want := constants.SafeInt32FromInt(constants.TransferTypeInvestorIncomeDistribution); net.OrderType != want {
		t.Fatalf("investor interest must be an income distribution, got type %d", net.OrderType)
	}
}

// Investor principal returns are typed as principal returns, with no
// deductions.
func TestRedistributePrincipalToInvestorHasNoDeductions(t *testing.T) {
	t.Parallel()

	evts := &capturingEventsManager{}
	fundings := []*LoanFundingInfo{
		newFunding("f1", FundingSourceInvestorAffiliated, "investor-1", 10000),
	}
	b := newRedistributionBusiness(evts, &stubLoanFundingReader{fundings: fundings}, nil)

	source := newRepaymentOrder(data.JSONMap{"loan_request_id": "lr-1"})
	b.redistributeRepayment(context.Background(), source, 5000, "principal", constants.TransferTypeLoanRepayment)

	if len(evts.orders) != 1 {
		t.Fatalf("expected a single principal return order, got %d", len(evts.orders))
	}
	order := evts.orders[0]
	if order.Amount != 5000 {
		t.Fatalf("principal must not be netted down, got %d", order.Amount)
	}
	if want := constants.SafeInt32FromInt(constants.TransferTypeInvestorPrincipalReturn); order.OrderType != want {
		t.Fatalf("expected an investor principal return, got type %d", order.OrderType)
	}
}

// Tranche counters follow the gross share, not the netted payout.
func TestRedistributeUpdatesTrancheCounters(t *testing.T) {
	t.Parallel()

	evts := &capturingEventsManager{}
	tranche := &FundingTrancheInfo{}
	tranche.ID = "t1"
	ftRepo := &stubTrancheManager{tranches: map[string][]*FundingTrancheInfo{"f1": {tranche}}}
	fundings := []*LoanFundingInfo{
		newFunding("f1", FundingSourceInvestorGeneral, "investor-1", 10000),
	}
	b := newRedistributionBusiness(evts, &stubLoanFundingReader{fundings: fundings}, ftRepo)

	source := newRepaymentOrder(data.JSONMap{"loan_request_id": "lr-1"})
	b.redistributeRepayment(
		context.Background(), source, 10_000, "interest", constants.TransferTypeLoanInterestRepayment,
	)

	if len(ftRepo.saved) != 1 {
		t.Fatalf("expected the tranche to be saved once, got %d", len(ftRepo.saved))
	}
	if ftRepo.saved[0].InterestEarned != 10_000 {
		t.Fatalf("tranche must record gross interest, got %d", ftRepo.saved[0].InterestEarned)
	}
}

// Without a loan request there is nothing to redistribute against.
func TestRedistributeWithoutLoanRequestEmitsNothing(t *testing.T) {
	t.Parallel()

	evts := &capturingEventsManager{}
	b := newRedistributionBusiness(evts, &stubLoanFundingReader{}, nil)

	source := newRepaymentOrder(nil)
	b.redistributeRepayment(context.Background(), source, 1000, "principal", constants.TransferTypeLoanRepayment)

	if len(evts.orders) != 0 {
		t.Fatalf("expected no orders, got %d", len(evts.orders))
	}
}
