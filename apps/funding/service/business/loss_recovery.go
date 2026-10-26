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

	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/funding/service/models"
	"github.com/antinvestor/service-fintech/apps/funding/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
	"github.com/antinvestor/service-fintech/pkg/constants"
)

// ErrNoLossToRecover is returned for a recovery on a loan whose loss was
// never absorbed: there is no funder to give anything back to.
var ErrNoLossToRecover = apperrors.NewError(apperrors.Unprocessable,
	"the loan's loss was never charged to its funders")

// Recovery is principal paid back on a written-off loan.
type Recovery struct {
	LoanRequestID string
	ProductID     string
	Reference     string
	Principal     int64
	Currency      string
}

// RecoveryResult is what a recovery gave back to funders.
type RecoveryResult struct {
	Recovered int64
	Currency  string
	Settled   bool
}

// LossRecoveryBusiness returns principal recovered after a write-off to the
// funders who absorbed the loss: the most senior tranche first, the reverse
// of the order the loss was charged in. Whatever exceeds the loss the
// funders still carry stays the lender's recovery income.
type LossRecoveryBusiness struct {
	lossRepo     repository.LossAbsorptionRepository
	recoveryRepo repository.LossRecoveryRepository
	ftRepo       repository.FundingTrancheRepository
	poster       LedgerPoster
}

// NewLossRecoveryBusiness wires the recovery.
func NewLossRecoveryBusiness(
	lossRepo repository.LossAbsorptionRepository,
	recoveryRepo repository.LossRecoveryRepository,
	ftRepo repository.FundingTrancheRepository,
	poster LedgerPoster,
) *LossRecoveryBusiness {
	return &LossRecoveryBusiness{lossRepo: lossRepo, recoveryRepo: recoveryRepo, ftRepo: ftRepo, poster: poster}
}

// Apply records one recovery once, keyed on its reference, and posts the
// funders' shares to the ledger.
func (b *LossRecoveryBusiness) Apply(ctx context.Context, rec Recovery) (*RecoveryResult, error) {
	logger := util.Log(ctx).WithField("method", "LossRecoveryBusiness.Apply").
		WithField("loan_request_id", rec.LoanRequestID)
	if rec.Principal <= 0 {
		return nil, ErrLossAmountNotPositive
	}
	if stored, err := b.recoveryRepo.GetByReference(ctx, rec.Reference); err == nil && stored != nil {
		return b.settle(ctx, logger, stored)
	}

	absorption, err := b.lossRepo.GetByReference(ctx, lossReference(rec.LoanRequestID))
	if err != nil {
		if data.ErrorIsNoRows(err) {
			return nil, ErrNoLossToRecover
		}
		// Anything else is not an answer: the caller retries.
		return nil, apperrors.NewError(apperrors.ServiceUnavailable,
			"the loan's loss could not be read; retry the recovery")
	}
	absorbed, err := decodeShares(absorption.Properties)
	if err != nil {
		return nil, fmt.Errorf("read loss absorption %s: %w", absorption.GetID(), err)
	}

	shares, err := b.recoveryShares(ctx, absorbed, rec.Principal)
	if err != nil {
		return nil, err
	}
	var recovered int64
	movements := make([]repository.TrancheMovement, 0, len(shares))
	for _, s := range shares {
		recovered += s.Principal
		movements = append(movements, repository.TrancheMovement{
			TrancheID: s.TrancheID, InvestorAccountID: s.InvestorAccountID, Principal: s.Principal,
		})
	}
	recovery := &models.LossRecovery{
		LoanRequestID: rec.LoanRequestID,
		Reference:     rec.Reference,
		Principal:     rec.Principal,
		Recovered:     recovered,
		Currency:      absorption.Currency,
		ProductID:     rec.ProductID,
		Properties:    encodeShares(shares),
	}
	recovery.GenID(ctx)
	recovery.CopyPartitionInfo(&absorption.BaseModel)

	stored, _, err := b.recoveryRepo.ClaimAndApply(ctx, recovery, movements)
	if err != nil {
		if errors.Is(err, repository.ErrTrancheExposureChanged) {
			return nil, apperrors.NewError(apperrors.ServiceUnavailable,
				"a funder's loss changed while recovering; retry")
		}
		return nil, fmt.Errorf("apply recovery: %w", err)
	}
	return b.settle(ctx, logger, stored)
}

// recoveryShares walks the absorbed shares from the most senior tranche
// down and gives each back what it lost and has not yet recovered.
func (b *LossRecoveryBusiness) recoveryShares(
	ctx context.Context,
	absorbed []RepaymentShare,
	principal int64,
) ([]RepaymentShare, error) {
	remaining := principal
	var shares []RepaymentShare
	for i := len(absorbed) - 1; i >= 0 && remaining > 0; i-- {
		s := absorbed[i]
		tranche, err := b.ftRepo.GetByID(ctx, s.TrancheID)
		if err != nil {
			return nil, fmt.Errorf("load tranche %s: %w", s.TrancheID, err)
		}
		outstanding := min(s.Principal, tranche.LossAbsorbed) - tranche.LossRecovered
		if outstanding <= 0 {
			continue
		}
		back := min(outstanding, remaining)
		remaining -= back
		s.Principal = back
		shares = append(shares, s)
	}
	return shares, nil
}

// settle posts each funder's recovered share back from the product's
// bad-debt expense onto their capital (or the platform's first-loss
// reserve), the mirror of the absorption's postings.
func (b *LossRecoveryBusiness) settle(
	ctx context.Context,
	logger *util.LogEntry,
	stored *models.LossRecovery,
) (*RecoveryResult, error) {
	result := &RecoveryResult{
		Recovered: stored.Recovered,
		Currency:  stored.Currency,
		Settled:   stored.SettledAt != nil || stored.ProductID == "" || stored.Recovered == 0,
	}
	if result.Settled || b.poster == nil {
		return result, nil
	}
	shares, err := decodeShares(stored.Properties)
	if err != nil {
		return nil, fmt.Errorf("read loss recovery %s: %w", stored.GetID(), err)
	}
	expense := constants.ProductBadDebtExpenseAccount(stored.ProductID)
	for _, s := range shares {
		var credit string
		switch models.FundingSource(s.SourceType) {
		case models.FundingSourceInvestorAffiliated, models.FundingSourceInvestorGeneral:
			credit = constants.InvestorCapitalAccount(s.InvestorAccountID)
		case models.FundingSourcePlatformReserve:
			credit = constants.PlatformFirstLossAccount(stored.ProductID)
		case models.FundingSourceGroupSavings, models.FundingSourceGroupIncome, models.FundingSourceUnspecified:
			continue
		}
		posting := LedgerPosting{
			Reference: fmt.Sprintf("fund-recovery:%s:%s", stored.GetID(), s.TrancheID),
			Debit:     expense, Credit: credit,
			Amount: s.Principal, Currency: stored.Currency, Type: constants.TransferTypeInvestorPrincipalReturn,
			Description: "Funder share of a recovery on a written-off loan",
			Extra: data.JSONMap{
				fieldLoanRequestID:     stored.LoanRequestID,
				fieldTrancheID:         s.TrancheID,
				fieldInvestorAccountID: s.InvestorAccountID,
			},
		}
		if postErr := b.poster.Post(ctx, posting); postErr != nil {
			logger.WithError(postErr).WithField("posting_reference", posting.Reference).
				Warn("recovery share not yet posted; a later call finishes it")
			return result, nil
		}
	}
	if markErr := b.recoveryRepo.MarkSettled(ctx, stored.GetID()); markErr != nil {
		logger.WithError(markErr).Warn("recovery shares posted but not marked settled; a later call marks it")
		return result, nil
	}
	result.Settled = true
	return result, nil
}
