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

package business_test

import (
	"context"
	"errors"
	"testing"

	"github.com/antinvestor/service-fintech/apps/seed/service/business"
	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/apps/seed/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

// statusRepo holds one profile and records the status writes it receives.
type statusRepo struct {
	repository.CreditProfileRepository

	profile *models.CreditProfile
	writes  []models.CreditProfileStatus
}

func (r *statusRepo) GetByClientAndCurrency(_ context.Context, _, _ string) (*models.CreditProfile, error) {
	if r.profile == nil {
		return nil, repository.ErrCreditProfileNotFound
	}
	return r.profile, nil
}

func (r *statusRepo) AtomicSetStatus(
	_ context.Context,
	_ string,
	status models.CreditProfileStatus,
) (*models.CreditProfile, error) {
	r.writes = append(r.writes, status)
	updated := *r.profile
	updated.Status = int32(status)
	return &updated, nil
}

func TestSetStatus_Transitions(t *testing.T) {
	t.Parallel()

	const (
		active    = models.CreditProfileStatusActive
		suspended = models.CreditProfileStatusSuspended
		blocked   = models.CreditProfileStatusBlocked
	)

	type transition struct {
		from, to models.CreditProfileStatus
	}
	tests := []struct {
		name       string
		move       transition
		reason     string
		missing    bool
		wantStatus models.CreditProfileStatus
		wantWrites int
		wantCode   int
	}{
		{
			name: "active can be suspended", move: transition{active, suspended}, reason: "review",
			wantStatus: suspended, wantWrites: 1,
		},
		{
			name: "active can be blocked", move: transition{active, blocked}, reason: "fraud",
			wantStatus: blocked, wantWrites: 1,
		},
		{
			name: "suspended can be blocked", move: transition{suspended, blocked}, reason: "fraud",
			wantStatus: blocked, wantWrites: 1,
		},
		{
			name: "suspended can be reinstated", move: transition{suspended, active}, reason: "resolved",
			wantStatus: active, wantWrites: 1,
		},
		{
			name: "blocked can be reinstated", move: transition{blocked, active}, reason: "resolved",
			wantStatus: active, wantWrites: 1,
		},
		{
			name: "blocked cannot be downgraded to suspended", move: transition{blocked, suspended}, reason: "x",
			wantCode: apperrors.Conflict,
		},
		{
			name: "reinstating an active profile is idempotent", move: transition{active, active}, reason: "x",
			wantStatus: active,
		},
		{
			name: "suspending a suspended profile is idempotent", move: transition{suspended, suspended}, reason: "x",
			wantStatus: suspended,
		},
		{
			name: "reason is required", move: transition{active, suspended}, reason: "  ",
			wantCode: apperrors.BadRequest,
		},
		{
			name: "unspecified target is rejected", move: transition{active, models.CreditProfileStatusUnspecified},
			reason: "x", wantCode: apperrors.BadRequest,
		},
		{
			name: "missing profile is not found", move: transition{active, suspended}, reason: "x", missing: true,
			wantCode: apperrors.NotFound,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			repo := &statusRepo{}
			if !tt.missing {
				repo.profile = &models.CreditProfile{ClientID: "c-1", CurrencyCode: "KES", Status: int32(tt.move.from)}
			}
			biz := business.NewCreditProfileBusiness(context.Background(), repo, nil, nil, audit.NewWriter(nil))

			got, err := biz.SetStatus(context.Background(), "c-1", "KES", tt.move.to, tt.reason)

			if tt.wantCode != 0 {
				assertRefused(t, err, tt.wantCode, repo.writes)
				return
			}
			if err != nil {
				t.Fatalf("SetStatus: %v", err)
			}
			if models.CreditProfileStatus(got.Status) != tt.wantStatus {
				t.Errorf("status = %d, want %d", got.Status, tt.wantStatus)
			}
			if len(repo.writes) != tt.wantWrites {
				t.Errorf("wrote %d times, want %d", len(repo.writes), tt.wantWrites)
			}
		})
	}
}

// assertRefused checks that a transition was refused with the expected
// apperrors code and that nothing was written.
func assertRefused(t *testing.T, err error, wantCode int, writes []models.CreditProfileStatus) {
	t.Helper()

	var appErr *apperrors.Error
	if !errors.As(err, &appErr) {
		t.Fatalf("err = %v, want an apperrors.Error with code %d", err, wantCode)
	}
	if appErr.ErrorCode() != wantCode {
		t.Fatalf("code = %d, want %d (%s)", appErr.ErrorCode(), wantCode, appErr.Message())
	}
	if len(writes) != 0 {
		t.Errorf("a refused transition wrote %v", writes)
	}
}
