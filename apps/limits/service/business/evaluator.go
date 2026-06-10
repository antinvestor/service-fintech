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
	"time"

	limitsv1 "buf.build/gen/go/antinvestor/limits/protocolbuffers/go/limits/v1"
	moneyx "github.com/pitabwire/util/moneyx"
	"gorm.io/gorm"

	"github.com/antinvestor/service-fintech/apps/limits/service/models"
	"github.com/antinvestor/service-fintech/apps/limits/service/repository"
)

// Evaluator computes per-policy verdicts. Pure logic on top of repo reads.
type Evaluator struct {
	resvRepo   repository.ReservationRepository
	ledgerRepo repository.LedgerRepository
}

func NewEvaluator(resvRepo repository.ReservationRepository, ledgerRepo repository.LedgerRepository) *Evaluator {
	return &Evaluator{resvRepo: resvRepo, ledgerRepo: ledgerRepo}
}

// Evaluate returns the verdict for the given policy applied to the intent.
// It reads from the read pool and is suitable for Check and other read-only callers.
func (e *Evaluator) Evaluate(
	ctx context.Context,
	p *models.Policy,
	subject repository.SubjectFilter,
	intent *limitsv1.LimitIntent,
	intentMinor int64,
) (*limitsv1.PolicyVerdict, error) {
	return e.evaluate(ctx, nil, p, subject, intent, intentMinor)
}

// EvaluateInTx is identical to Evaluate but routes rolling-window reads through
// the supplied gorm transaction. This ensures the reads participate in the
// advisory lock acquired inside the Reserve transaction, closing the TOCTOU race
// where two concurrent Reserves on the same subject could both see "below cap".
func (e *Evaluator) EvaluateInTx(
	ctx context.Context,
	tx *gorm.DB,
	p *models.Policy,
	subject repository.SubjectFilter,
	intent *limitsv1.LimitIntent,
	intentMinor int64,
) (*limitsv1.PolicyVerdict, error) {
	return e.evaluate(ctx, tx, p, subject, intent, intentMinor)
}

// evaluate is the shared core of Evaluate and EvaluateInTx. When tx is non-nil,
// rolling-window reads are routed through the transaction connection.
//
//nolint:gocognit,funlen // per-kind verdict matrix is clearer as one switch than split helpers
func (e *Evaluator) evaluate(
	ctx context.Context,
	tx *gorm.DB,
	p *models.Policy,
	subject repository.SubjectFilter,
	_ *limitsv1.LimitIntent,
	intentMinor int64,
) (*limitsv1.PolicyVerdict, error) {
	v := &limitsv1.PolicyVerdict{
		PolicyId:      p.ID,
		PolicyVersion: int32(p.Version), //nolint:gosec // version counters never approach int32 range
		Matched:       true,
		Mode:          policyModeToAPI(p.Mode),
	}

	switch p.LimitKind {
	case models.KindPerTxnMin:
		if intentMinor < p.Value {
			v.Breached = true
			v.Reason = "amount below per_txn_min"
		}
	case models.KindPerTxnMax:
		if intentMinor > p.Value {
			if approverTiersCover(p, intentMinor) {
				v.WouldRequireApproval = true
			} else {
				v.Breached = true
			}
			v.Reason = "amount above per_txn_max"
		}
	case models.KindRollingWindowAmount:
		since := time.Now().Add(-time.Duration(p.WindowSeconds) * time.Second)
		var committed int64
		var err error
		if tx != nil {
			committed, err = e.ledgerRepo.WindowSumTx(ctx, tx, p.Action, p.CurrencyCode, subject, since)
		} else {
			committed, err = e.ledgerRepo.WindowSum(ctx, p.Action, p.CurrencyCode, subject, since)
		}
		if err != nil {
			return nil, err
		}
		var pending int64
		if tx != nil {
			pending, err = e.resvRepo.PendingSumTx(ctx, tx, p.Action, p.CurrencyCode, subject)
		} else {
			pending, err = e.resvRepo.PendingSum(ctx, p.Action, p.CurrencyCode, subject)
		}
		if err != nil {
			return nil, err
		}
		usage := committed + pending
		v.CurrentUsage = moneyx.FromMinorUnitsByCurrency(p.CurrencyCode, usage)
		v.CapAmount = moneyx.FromMinorUnitsByCurrency(p.CurrencyCode, p.Value)
		if usage+intentMinor > p.Value {
			if approverTiersCover(p, intentMinor) {
				v.WouldRequireApproval = true
			} else {
				v.Breached = true
			}
			v.Reason = "rolling window amount exceeded"
		}
	case models.KindRollingWindowCount:
		since := time.Now().Add(-time.Duration(p.WindowSeconds) * time.Second)
		var committed int64
		var err error
		if tx != nil {
			committed, err = e.ledgerRepo.WindowCountTx(ctx, tx, p.Action, p.CurrencyCode, subject, since)
		} else {
			committed, err = e.ledgerRepo.WindowCount(ctx, p.Action, p.CurrencyCode, subject, since)
		}
		if err != nil {
			return nil, err
		}
		var pending int64
		if tx != nil {
			pending, err = e.resvRepo.PendingCountTx(ctx, tx, p.Action, p.CurrencyCode, subject, since)
		} else {
			pending, err = e.resvRepo.PendingCount(ctx, p.Action, p.CurrencyCode, subject, since)
		}
		if err != nil {
			return nil, err
		}
		count := committed + pending
		v.CurrentCount = count
		v.CapCount = p.Value
		if count+1 > p.Value {
			if approverTiersCover(p, intentMinor) {
				v.WouldRequireApproval = true
			} else {
				v.Breached = true
			}
			v.Reason = "rolling window count exceeded"
		}
	}

	return v, nil
}

// approverTier mirrors the JSON shape persisted in Policy.ApproverTiers.
type approverTier struct {
	UpTo      int64
	Role      string
	Approvers int32
}

func approverTiersCover(p *models.Policy, intentMinor int64) bool {
	tiers, err := unmarshalPolicyApproverTiers(p)
	if err != nil || len(tiers) == 0 {
		return false
	}
	for _, t := range tiers {
		if t.UpTo == 0 || intentMinor <= t.UpTo {
			return true
		}
	}
	return false
}

func unmarshalPolicyApproverTiers(p *models.Policy) ([]approverTier, error) {
	if len(p.ApproverTiers) == 0 {
		return nil, nil
	}
	type raw struct {
		UpTo      int64  `json:"up_to"`
		Role      string `json:"role"`
		Approvers int32  `json:"approvers"`
	}
	var rs []raw
	if err := json.Unmarshal(p.ApproverTiers, &rs); err != nil {
		return nil, err
	}
	out := make([]approverTier, len(rs))
	for i, r := range rs {
		out[i] = approverTier(r)
	}
	return out, nil
}

// pickTier finds the first approver tier whose up_to covers intentMinor.
func pickTier(p *models.Policy, intentMinor int64) (approverTier, bool) {
	tiers, _ := unmarshalPolicyApproverTiers(p)
	for _, t := range tiers {
		if t.UpTo == 0 || intentMinor <= t.UpTo {
			return t, true
		}
	}
	return approverTier{}, false
}

func policyModeToAPI(m models.Mode) limitsv1.PolicyMode {
	switch m {
	case models.ModeOff:
		return limitsv1.PolicyMode_POLICY_MODE_OFF
	case models.ModeShadow:
		return limitsv1.PolicyMode_POLICY_MODE_SHADOW
	case models.ModeEnforce:
		return limitsv1.PolicyMode_POLICY_MODE_ENFORCE
	default:
		return limitsv1.PolicyMode_POLICY_MODE_UNSPECIFIED
	}
}
