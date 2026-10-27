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

package repository

import (
	"context"
	"time"

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/frame/v3/workerpool"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
)

// ClaimOutcome is what Claim found for a loan request.
type ClaimOutcome int

const (
	// ClaimTaken means this call took a fresh claim and builds the allocation.
	ClaimTaken ClaimOutcome = iota
	// ClaimTakenOver means a previous call's lease lapsed before it finished:
	// this call now holds the claim and must void what that call left before
	// building the allocation afresh.
	ClaimTakenOver
	// ClaimHeld means another call is building the allocation right now.
	ClaimHeld
	// ClaimCompleted means the allocation is finished and persisted.
	ClaimCompleted
)

// LoanFundingClaimRepository owns the per-request allocation lock.
type LoanFundingClaimRepository interface {
	datastore.BaseRepository[*models.LoanFundingClaim]

	// Claim takes the allocation lock for a loan request, leased for
	// leaseSeconds. The returned lease identifies this holder to Complete and
	// ReleaseHeld; it is set only for ClaimTaken and ClaimTakenOver.
	Claim(
		ctx context.Context,
		claim *models.LoanFundingClaim,
		leaseSeconds int,
	) (outcome ClaimOutcome, lease time.Time, err error)

	// Complete marks the claim's allocation finished, only while lease is
	// still the claim's: false means another call took the claim over.
	Complete(ctx context.Context, loanRequestID string, lease time.Time) (bool, error)

	// Abandon turns the allocating claim this call holds under lease into an
	// abandoning one, which can no longer be completed, and reports whether
	// it did. A claim completed or taken over is left alone.
	Abandon(ctx context.Context, loanRequestID string, lease time.Time) (bool, error)

	// ReleaseHeld drops the allocating or abandoning claim this call holds under lease
	// after its allocation failed, so the request can be funded on a later
	// attempt, and reports whether it did. A completed claim, or one another
	// call took over, is never dropped.
	ReleaseHeld(ctx context.Context, loanRequestID string, lease time.Time) (bool, error)

	// HeldBy reports the claim's status and whether lease is still its
	// lease.
	HeldBy(ctx context.Context, loanRequestID string, lease time.Time) (status int32, held bool, err error)

	// Release drops the lock whoever holds it, so the request can be funded
	// afresh.
	Release(ctx context.Context, loanRequestID string) error
}

type loanFundingClaimRepository struct {
	datastore.BaseRepository[*models.LoanFundingClaim]
}

// NewLoanFundingClaimRepository creates a LoanFundingClaimRepository.
func NewLoanFundingClaimRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) LoanFundingClaimRepository {
	return &loanFundingClaimRepository{
		BaseRepository: datastore.NewBaseRepository(ctx, dbPool, workMan, func() *models.LoanFundingClaim {
			return &models.LoanFundingClaim{}
		}),
	}
}

func (r *loanFundingClaimRepository) Claim(
	ctx context.Context,
	claim *models.LoanFundingClaim,
	leaseSeconds int,
) (ClaimOutcome, time.Time, error) {
	// Postgres keeps microseconds; the lease must compare equal once stored.
	now := time.Now().UTC().Truncate(time.Microsecond)
	claim.Status = models.LoanFundingClaimAllocating
	claim.ClaimedAt = &now
	err := r.Pool().DB(ctx, false).Create(claim).Error
	if err == nil {
		return ClaimTaken, now, nil
	}
	if !data.ErrorIsDuplicateKey(err) {
		return ClaimHeld, time.Time{}, err
	}

	// The request is claimed already. An allocating claim whose lease lapsed
	// is taken over, in one conditional write, so only one caller wins it.
	var taken []struct{ ClaimedAt time.Time }
	err = r.Pool().DB(ctx, false).Raw(`UPDATE loan_funding_claims
SET status = ?, claimed_at = now(), modified_at = now(), version = version + 1
WHERE loan_request_id = ? AND deleted_at IS NULL AND status IN (?, ?)
  AND (claimed_at IS NULL OR claimed_at < now() - make_interval(secs => ?))
RETURNING claimed_at`, models.LoanFundingClaimAllocating, claim.LoanRequestID,
		models.LoanFundingClaimAllocating, models.LoanFundingClaimAbandoning, leaseSeconds).Scan(&taken).Error
	if err != nil {
		return ClaimHeld, time.Time{}, err
	}
	if len(taken) > 0 {
		return ClaimTakenOver, taken[0].ClaimedAt, nil
	}

	existing := &models.LoanFundingClaim{}
	if err = r.Pool().DB(ctx, false).
		First(existing, "loan_request_id = ?", claim.LoanRequestID).Error; err != nil {
		return ClaimHeld, time.Time{}, err
	}
	if existing.Status != models.LoanFundingClaimComplete {
		return ClaimHeld, time.Time{}, nil
	}
	return ClaimCompleted, time.Time{}, nil
}

func (r *loanFundingClaimRepository) Complete(
	ctx context.Context,
	loanRequestID string,
	lease time.Time,
) (bool, error) {
	result := r.Pool().DB(ctx, false).Exec(`UPDATE loan_funding_claims
SET status = ?, modified_at = now(), version = version + 1
WHERE loan_request_id = ? AND deleted_at IS NULL AND status = ? AND claimed_at = ?`,
		models.LoanFundingClaimComplete, loanRequestID, models.LoanFundingClaimAllocating, lease)
	return result.RowsAffected > 0, result.Error
}

func (r *loanFundingClaimRepository) Abandon(
	ctx context.Context,
	loanRequestID string,
	lease time.Time,
) (bool, error) {
	result := r.Pool().DB(ctx, false).Exec(`UPDATE loan_funding_claims
SET status = ?, modified_at = now(), version = version + 1
WHERE loan_request_id = ? AND deleted_at IS NULL AND status = ? AND claimed_at = ?`,
		models.LoanFundingClaimAbandoning, loanRequestID, models.LoanFundingClaimAllocating, lease)
	return result.RowsAffected > 0, result.Error
}

func (r *loanFundingClaimRepository) ReleaseHeld(
	ctx context.Context,
	loanRequestID string,
	lease time.Time,
) (bool, error) {
	result := r.Pool().DB(ctx, false).
		Unscoped().
		Where("loan_request_id = ? AND claimed_at = ? AND status IN ?", loanRequestID, lease,
			[]int32{models.LoanFundingClaimAllocating, models.LoanFundingClaimAbandoning}).
		Delete(&models.LoanFundingClaim{})
	return result.RowsAffected > 0, result.Error
}

func (r *loanFundingClaimRepository) HeldBy(
	ctx context.Context,
	loanRequestID string,
	lease time.Time,
) (int32, bool, error) {
	claim := &models.LoanFundingClaim{}
	err := r.Pool().DB(ctx, false).First(claim, "loan_request_id = ?", loanRequestID).Error
	if data.ErrorIsNoRows(err) {
		return 0, false, nil
	}
	if err != nil {
		return 0, false, err
	}
	held := claim.ClaimedAt != nil && claim.ClaimedAt.Equal(lease)
	return claim.Status, held, nil
}

func (r *loanFundingClaimRepository) Release(ctx context.Context, loanRequestID string) error {
	// Unscoped: a soft-deleted row still occupies the unique loan_request_id,
	// which would leave the request permanently unfundable.
	return r.Pool().DB(ctx, false).
		Unscoped().
		Where("loan_request_id = ?", loanRequestID).
		Delete(&models.LoanFundingClaim{}).Error
}
