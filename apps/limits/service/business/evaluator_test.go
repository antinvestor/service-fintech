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
	"encoding/json"
	"testing"
	"time"

	moneypb "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gorm.io/datatypes"
	"gorm.io/gorm"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// stubResvRepo satisfies just the methods Evaluator calls.
type stubResvRepo struct {
	sumByKey   map[string]int64
	countByKey map[string]int64
}

func (s *stubResvRepo) PendingSum(
	ctx context.Context,
	action models.Action,
	currency string,
	subject repository.SubjectFilter,
) (int64, error) {
	k := string(action) + "|" + currency + "|" + string(subject.Type) + "|" + subject.ID
	return s.sumByKey[k], nil
}

func (s *stubResvRepo) PendingCount(
	ctx context.Context,
	action models.Action,
	currency string,
	subject repository.SubjectFilter,
	since time.Time,
) (int64, error) {
	k := string(action) + "|" + currency + "|" + string(subject.Type) + "|" + subject.ID
	return s.countByKey[k], nil
}

func (s *stubResvRepo) PendingSumTx(
	_ context.Context,
	_ *gorm.DB,
	action models.Action,
	currency string,
	subject repository.SubjectFilter,
) (int64, error) {
	k := string(action) + "|" + currency + "|" + string(subject.Type) + "|" + subject.ID
	return s.sumByKey[k], nil
}

func (s *stubResvRepo) PendingCountTx(
	_ context.Context,
	_ *gorm.DB,
	action models.Action,
	currency string,
	subject repository.SubjectFilter,
	_ time.Time,
) (int64, error) {
	k := string(action) + "|" + currency + "|" + string(subject.Type) + "|" + subject.ID
	return s.countByKey[k], nil
}

// All other ReservationRepository methods are unused by Evaluator; provide no-op stubs.
func (s *stubResvRepo) Create(ctx context.Context, r *models.Reservation) error { return nil }
func (s *stubResvRepo) GetByID(ctx context.Context, id string) (*models.Reservation, error) {
	return nil, nil
}
func (s *stubResvRepo) GetByIdempotencyKey(ctx context.Context, key string) (*models.Reservation, error) {
	return nil, nil
}
func (s *stubResvRepo) SetCommitted(_ context.Context, _ string, _ time.Time) error { return nil }
func (s *stubResvRepo) SetCommittedTx(_ context.Context, _ *gorm.DB, _ string, _ time.Time) error {
	return nil
}
func (s *stubResvRepo) SetReleased(_ context.Context, _, _ string, _ time.Time) error { return nil }
func (s *stubResvRepo) SetReleasedTx(_ context.Context, _ *gorm.DB, _, _ string, _ time.Time) error {
	return nil
}
func (s *stubResvRepo) SetExpired(_ context.Context, _ string, _ time.Time) error { return nil }
func (s *stubResvRepo) BulkSetExpired(_ context.Context, _ []string, _ time.Time) (int, error) {
	return 0, nil
}
func (s *stubResvRepo) HardDeleteTerminalBefore(_ context.Context, _ time.Time) (int, error) {
	return 0, nil
}
func (s *stubResvRepo) SetReversed(_ context.Context, _ string, _ time.Time) error { return nil }
func (s *stubResvRepo) SetReversedTx(_ context.Context, _ *gorm.DB, _ string, _ time.Time) error {
	return nil
}
func (s *stubResvRepo) SetPendingApproval(_ context.Context, _ string) error      { return nil }
func (s *stubResvRepo) SetActive(_ context.Context, _ string) error               { return nil }
func (s *stubResvRepo) SetActiveTx(_ context.Context, _ *gorm.DB, _ string) error { return nil }

func (s *stubResvRepo) ListExpiredActive(
	ctx context.Context,
	before time.Time,
	limit int,
) ([]*models.Reservation, error) {
	return nil, nil
}

type stubLedgerRepo struct {
	sumByKey   map[string]int64
	countByKey map[string]int64
}

func (s *stubLedgerRepo) WindowSum(
	ctx context.Context,
	action models.Action,
	currency string,
	subject repository.SubjectFilter,
	since time.Time,
) (int64, error) {
	k := string(action) + "|" + currency + "|" + string(subject.Type) + "|" + subject.ID
	return s.sumByKey[k], nil
}

func (s *stubLedgerRepo) WindowSumTx(
	_ context.Context,
	_ *gorm.DB,
	action models.Action,
	currency string,
	subject repository.SubjectFilter,
	_ time.Time,
) (int64, error) {
	k := string(action) + "|" + currency + "|" + string(subject.Type) + "|" + subject.ID
	return s.sumByKey[k], nil
}

func (s *stubLedgerRepo) WindowCount(
	ctx context.Context,
	action models.Action,
	currency string,
	subject repository.SubjectFilter,
	since time.Time,
) (int64, error) {
	k := string(action) + "|" + currency + "|" + string(subject.Type) + "|" + subject.ID
	return s.countByKey[k], nil
}

func (s *stubLedgerRepo) WindowCountTx(
	_ context.Context,
	_ *gorm.DB,
	action models.Action,
	currency string,
	subject repository.SubjectFilter,
	_ time.Time,
) (int64, error) {
	k := string(action) + "|" + currency + "|" + string(subject.Type) + "|" + subject.ID
	return s.countByKey[k], nil
}

func (s *stubLedgerRepo) CreateBatch(ctx context.Context, entries []*models.LedgerEntry) error {
	return nil
}
func (s *stubLedgerRepo) MarkReversed(ctx context.Context, reservationID string, at time.Time) error {
	return nil
}

func (s *stubLedgerRepo) Search(
	ctx context.Context,
	f repository.LedgerSearchFilter,
	limit int,
	cursor string,
) (*repository.LedgerSearchResult, error) {
	return nil, nil
}

func (s *stubLedgerRepo) HardDeleteBefore(_ context.Context, _ time.Time) (int, error) {
	return 0, nil
}

func newPolicy(kind models.Kind, value int64, mode models.Mode, withApproverTiers bool) *models.Policy {
	p := &models.Policy{
		Action:        models.ActionLoanDisbursement,
		SubjectType:   models.SubjectClient,
		CurrencyCode:  "KES",
		LimitKind:     kind,
		WindowSeconds: 86400, // 24h, ignored by per-txn kinds
		Value:         value,
		Mode:          mode,
	}
	p.ID = "pol-1"
	p.Version = 1
	if withApproverTiers {
		j, _ := json.Marshal([]map[string]any{
			{"up_to": int64(0), "role": "branch_manager", "approvers": 1},
		})
		p.ApproverTiers = datatypes.JSON(j)
	}
	return p
}

func intentFor(amount int64) *limitsv1.LimitIntent {
	return &limitsv1.LimitIntent{
		Action:    limitsv1.LimitAction_LIMIT_ACTION_LOAN_DISBURSEMENT,
		TenantId:  "t-1",
		OrgUnitId: "branch-a",
		Amount:    &moneypb.Money{CurrencyCode: "KES", Units: amount / 100, Nanos: int32((amount % 100) * 10_000_000)},
		MakerId:   "wf-1",
	}
}

func TestEvaluator_PerTxnMin(t *testing.T) {
	e := NewEvaluator(&stubResvRepo{}, &stubLedgerRepo{})
	p := newPolicy(models.KindPerTxnMin, 100, models.ModeEnforce, false)
	v, err := e.Evaluate(
		context.Background(),
		p,
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"},
		intentFor(50),
		50,
	)
	require.NoError(t, err)
	assert.True(t, v.GetBreached(), "amount below min should breach")
}

func TestEvaluator_PerTxnMax_NoTiers_Breaches(t *testing.T) {
	e := NewEvaluator(&stubResvRepo{}, &stubLedgerRepo{})
	p := newPolicy(models.KindPerTxnMax, 100, models.ModeEnforce, false)
	v, err := e.Evaluate(
		context.Background(),
		p,
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"},
		intentFor(200),
		200,
	)
	require.NoError(t, err)
	assert.True(t, v.GetBreached())
	assert.False(t, v.GetWouldRequireApproval())
}

func TestEvaluator_PerTxnMax_WithTiers_RequiresApproval(t *testing.T) {
	e := NewEvaluator(&stubResvRepo{}, &stubLedgerRepo{})
	p := newPolicy(models.KindPerTxnMax, 100, models.ModeEnforce, true)
	v, err := e.Evaluate(
		context.Background(),
		p,
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"},
		intentFor(200),
		200,
	)
	require.NoError(t, err)
	assert.False(t, v.GetBreached())
	assert.True(t, v.GetWouldRequireApproval())
}

func TestEvaluator_RollingWindowAmount_UnderCap(t *testing.T) {
	committed := int64(200)
	pending := int64(300)
	resv := &stubResvRepo{sumByKey: map[string]int64{"loan_disbursement|KES|client|c1": pending}}
	ledger := &stubLedgerRepo{sumByKey: map[string]int64{"loan_disbursement|KES|client|c1": committed}}
	e := NewEvaluator(resv, ledger)
	p := newPolicy(models.KindRollingWindowAmount, 1000, models.ModeEnforce, false)
	v, err := e.Evaluate(
		context.Background(),
		p,
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"},
		intentFor(400),
		400,
	)
	require.NoError(t, err)
	assert.False(t, v.GetBreached())
	assert.Equal(t, int64(500), v.GetCurrentUsage().GetUnits()*100+int64(v.GetCurrentUsage().GetNanos())/10_000_000)
}

func TestEvaluator_RollingWindowAmount_OverCap(t *testing.T) {
	resv := &stubResvRepo{sumByKey: map[string]int64{"loan_disbursement|KES|client|c1": 300}}
	ledger := &stubLedgerRepo{sumByKey: map[string]int64{"loan_disbursement|KES|client|c1": 200}}
	e := NewEvaluator(resv, ledger)
	p := newPolicy(models.KindRollingWindowAmount, 1000, models.ModeEnforce, false)
	v, err := e.Evaluate(
		context.Background(),
		p,
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"},
		intentFor(600),
		600,
	)
	require.NoError(t, err)
	assert.True(t, v.GetBreached())
}

func TestEvaluator_RollingWindowCount_OverCap(t *testing.T) {
	resv := &stubResvRepo{countByKey: map[string]int64{"loan_disbursement|KES|client|c1": 2}}
	ledger := &stubLedgerRepo{countByKey: map[string]int64{"loan_disbursement|KES|client|c1": 3}}
	e := NewEvaluator(resv, ledger)
	p := newPolicy(models.KindRollingWindowCount, 5, models.ModeEnforce, false)
	v, err := e.Evaluate(
		context.Background(),
		p,
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"},
		intentFor(1),
		1,
	)
	require.NoError(t, err)
	assert.True(t, v.GetBreached())
	assert.Equal(t, int64(5), v.GetCurrentCount())
}

func TestEvaluator_ShadowMode(t *testing.T) {
	e := NewEvaluator(&stubResvRepo{}, &stubLedgerRepo{})
	p := newPolicy(models.KindPerTxnMax, 100, models.ModeShadow, false)
	v, err := e.Evaluate(
		context.Background(),
		p,
		repository.SubjectFilter{Type: models.SubjectClient, ID: "c1"},
		intentFor(200),
		200,
	)
	require.NoError(t, err)
	// Shadow mode still computes the verdict; the aggregator (Reserve) decides whether to block.
	assert.True(t, v.GetBreached())
	assert.Equal(t, limitsv1.PolicyMode_POLICY_MODE_SHADOW, v.GetMode())
}

func TestPickTier_Catchall(t *testing.T) {
	p := newPolicy(models.KindPerTxnMax, 100, models.ModeEnforce, true)
	tier, ok := PickTier(p, 1_000_000)
	assert.True(t, ok)
	assert.Equal(t, "branch_manager", tier.Role)
	assert.Equal(t, int32(1), tier.Approvers)
}
