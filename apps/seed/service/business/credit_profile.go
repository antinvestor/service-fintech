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

// Package business implements the seed product's domain logic.
//
// The two central concepts are:
//
//   - CreditProfileBusiness owns the per-client credit state: tier,
//     limit, successful-repayments counter, and the policy that maps
//     repayment success to higher limits.
//
//   - LoanRequestBusiness owns the customer-initiated loan request
//     pipeline: eligibility, approval, downstream application/loan
//     creation, and disbursement. Lives in loan_request.go.
//
// Every important state change in both businesses captures a
// descriptive audit event via pkg/audit so the full history of a
// client's relationship with seed is reconstructable without replay.
package business

import (
	"context"
	"errors"
	"fmt"

	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"

	"github.com/pitabwire/frame/data"

	"github.com/antinvestor/service-fintech/apps/seed/service/models"
	"github.com/antinvestor/service-fintech/apps/seed/service/repository"
	"github.com/antinvestor/service-fintech/pkg/audit"
)

// ErrNoTierConfigured is returned when no CreditTierConfig rows exist
// for a product/currency. Seed refuses to make credit decisions on
// unconfigured tiers rather than guessing.
var ErrNoTierConfigured = errors.New("seed: no credit tier configured for product/currency")

// ErrProfileSuspended is returned when a credit profile's status is
// not Active: a suspended or blocked profile cannot borrow.
var ErrProfileSuspended = errors.New("seed: credit profile is not active")

// CreditProfileBusiness is the public seed credit surface.
//
// EnsureProfile and GetProfile are idempotent reads that are safe to
// call from the hot path of RequestLoan. RecordSuccessfulRepayment is
// the path the paid-off hook takes; it increments counters, promotes
// tier, and emits the audit event. EvaluateTier is exposed as a pure
// read so callers can preview what a profile would be promoted to
// without persisting.
type CreditProfileBusiness interface {
	EnsureProfile(
		ctx context.Context,
		clientID, currencyCode, productID string,
	) (*models.CreditProfile, error)

	GetProfile(
		ctx context.Context,
		clientID, currencyCode string,
	) (*models.CreditProfile, error)

	// EvaluateTier returns the tier a profile qualifies for given its
	// current counters. Pure function over (profile, tier ladder).
	EvaluateTier(
		ctx context.Context,
		profile *models.CreditProfile,
	) (*models.CreditTierConfig, error)

	// RecordSuccessfulRepayment is the paid-off hook: it increments the
	// SuccessfulRepayments counter, re-evaluates tier, persists any
	// promotion, and emits a descriptive audit event. Idempotency is
	// the caller's job (see LoanRequestBusiness.HandlePaidOff for the
	// marker-based guard).
	RecordSuccessfulRepayment(
		ctx context.Context,
		clientID, currencyCode string,
		repaidAmount int64,
		reason string,
	) (*models.CreditProfile, error)
}

type creditProfileBusiness struct {
	cpRepo      repository.CreditProfileRepository
	tierRepo    repository.CreditTierRepository
	eventsMan   fevents.Manager
	auditWriter *audit.Writer
}

// NewCreditProfileBusiness builds the business bound to its dependencies.
func NewCreditProfileBusiness(
	_ context.Context,
	cpRepo repository.CreditProfileRepository,
	tierRepo repository.CreditTierRepository,
	eventsMan fevents.Manager,
	auditWriter *audit.Writer,
) CreditProfileBusiness {
	return &creditProfileBusiness{
		cpRepo:      cpRepo,
		tierRepo:    tierRepo,
		eventsMan:   eventsMan,
		auditWriter: auditWriter,
	}
}

func (b *creditProfileBusiness) EnsureProfile(
	ctx context.Context,
	clientID, currencyCode, productID string,
) (*models.CreditProfile, error) {
	logger := util.Log(ctx).WithField("method", "CreditProfileBusiness.EnsureProfile").
		WithField("client_id", clientID)

	if clientID == "" || currencyCode == "" || productID == "" {
		return nil, errors.New("client id, currency code, and product id are required")
	}

	existing, err := b.cpRepo.GetByClientAndCurrency(ctx, clientID, currencyCode)
	if err == nil {
		return existing, nil
	}
	if !errors.Is(err, repository.ErrCreditProfileNotFound) {
		return nil, err
	}

	profile, ensureErr := b.cpRepo.Ensure(ctx, clientID, currencyCode, productID, nil)
	if ensureErr != nil {
		return nil, ensureErr
	}

	// Populate the initial tier and limit from policy so the brand-new
	// profile has an actionable MaxLoanAmount instead of zero.
	tier, evalErr := b.EvaluateTier(ctx, profile)
	if evalErr == nil && tier != nil {
		promoted, promoteErr := b.cpRepo.AtomicPromoteTier(
			ctx, profile.GetID(), tier.Tier, tier.MaxLoanAmount,
		)
		if promoteErr != nil {
			logger.WithError(promoteErr).
				Warn("could not set initial tier on new credit profile")
		} else {
			profile = promoted
		}
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityCreditProfile,
		EntityID:   profile.GetID(),
		Action:     "seed.credit_profile.created",
		Reason:     "client first seen by seed",
		After: data.JSONMap{
			fieldTier:          profile.Tier,
			fieldMaxLoanAmount: profile.MaxLoanAmount,
			fieldStatus:        profile.Status,
		},
		Metadata: data.JSONMap{
			fieldClientID:     clientID,
			fieldCurrencyCode: currencyCode,
			fieldProductID:    productID,
		},
		Parent: &profile.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for credit profile creation")
	})

	return profile, nil
}

func (b *creditProfileBusiness) GetProfile(
	ctx context.Context,
	clientID, currencyCode string,
) (*models.CreditProfile, error) {
	return b.cpRepo.GetByClientAndCurrency(ctx, clientID, currencyCode)
}

func (b *creditProfileBusiness) EvaluateTier(
	ctx context.Context,
	profile *models.CreditProfile,
) (*models.CreditTierConfig, error) {
	if profile == nil {
		return nil, errors.New("credit profile is required")
	}
	if profile.ProductID == "" || profile.CurrencyCode == "" {
		return nil, errors.New("credit profile is missing product or currency")
	}

	tiers, err := b.tierRepo.ListForProduct(ctx, profile.ProductID, profile.CurrencyCode)
	if err != nil {
		return nil, fmt.Errorf("list tiers: %w", err)
	}
	if len(tiers) == 0 {
		return nil, ErrNoTierConfigured
	}

	// Tiers come pre-ordered by MinSuccessfulRepayments ASC. Walk until
	// the threshold is no longer met, returning the last one that was.
	var best *models.CreditTierConfig
	for _, t := range tiers {
		if profile.SuccessfulRepayments >= t.MinSuccessfulRepayments {
			best = t
			continue
		}
		break
	}
	if best == nil {
		// No tier threshold met: fall back to the lowest rung. A brand-
		// new client with zero repayments sits at the first rung.
		best = tiers[0]
	}
	return best, nil
}

func (b *creditProfileBusiness) RecordSuccessfulRepayment(
	ctx context.Context,
	clientID, currencyCode string,
	repaidAmount int64,
	reason string,
) (*models.CreditProfile, error) {
	logger := util.Log(ctx).WithField("method", "CreditProfileBusiness.RecordSuccessfulRepayment").
		WithField("client_id", clientID)

	profile, err := b.cpRepo.GetByClientAndCurrency(ctx, clientID, currencyCode)
	if err != nil {
		return nil, err
	}

	before := snapshotProfile(profile)

	updated, err := b.cpRepo.AtomicRecordRepayment(ctx, profile.GetID(), repaidAmount)
	if err != nil {
		return nil, fmt.Errorf("record repayment: %w", err)
	}

	// Re-evaluate tier from the fresh row. If the ladder says the
	// client qualifies for a higher rung, apply the promotion atomically
	// and emit a second audit event so the promotion is independently
	// traceable from the repayment record.
	tier, evalErr := b.EvaluateTier(ctx, updated)
	if evalErr == nil && tier != nil && tier.Tier > updated.Tier {
		promoted, promoteErr := b.cpRepo.AtomicPromoteTier(
			ctx, updated.GetID(), tier.Tier, tier.MaxLoanAmount,
		)
		if promoteErr != nil {
			logger.WithError(promoteErr).
				Warn("could not promote credit profile tier after repayment")
		} else {
			b.auditWriter.RecordOrLog(ctx, audit.Record{
				EntityType: entityCreditProfile,
				EntityID:   promoted.GetID(),
				Action:     "seed.credit_profile.tier_promoted",
				Reason:     "successful repayment crossed tier threshold",
				Before: data.JSONMap{
					fieldTier:          updated.Tier,
					fieldMaxLoanAmount: updated.MaxLoanAmount,
				},
				After: data.JSONMap{
					fieldTier:          promoted.Tier,
					fieldMaxLoanAmount: promoted.MaxLoanAmount,
					"tier_name":        tier.Name,
				},
				Metadata: data.JSONMap{
					fieldClientID:           clientID,
					"successful_repayments": promoted.SuccessfulRepayments,
				},
				Parent: &promoted.BaseModel,
			}, func(auErr error) {
				logger.WithError(auErr).Warn("audit emission failed for tier promotion")
			})
			updated = promoted
		}
	}

	b.auditWriter.RecordOrLog(ctx, audit.Record{
		EntityType: entityCreditProfile,
		EntityID:   updated.GetID(),
		Action:     "seed.credit_profile.repayment_recorded",
		Reason:     reason,
		Before:     before,
		After:      snapshotProfile(updated),
		Metadata: data.JSONMap{
			fieldClientID:     clientID,
			fieldCurrencyCode: currencyCode,
			"repaid_amount":   repaidAmount,
		},
		Parent: &updated.BaseModel,
	}, func(auErr error) {
		logger.WithError(auErr).Warn("audit emission failed for repayment recording")
	})

	return updated, nil
}

// snapshotProfile captures the fields of a CreditProfile that matter for
// an audit before/after diff. Kept as a small helper rather than
// marshalling the whole struct because most fields (id, timestamps,
// partition info) are not interesting to the auditor.
func snapshotProfile(p *models.CreditProfile) data.JSONMap {
	if p == nil {
		return nil
	}
	return data.JSONMap{
		fieldTier:                p.Tier,
		fieldMaxLoanAmount:       p.MaxLoanAmount,
		"successful_repayments":  p.SuccessfulRepayments,
		"outstanding_loan_count": p.OutstandingLoanCount,
		"total_borrowed":         p.TotalBorrowed,
		"total_repaid":           p.TotalRepaid,
		fieldStatus:              p.Status,
	}
}
